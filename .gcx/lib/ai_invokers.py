"""
AI Invokers
===========

Codex, Gemini, Claude CLI 표준화된 인터페이스
모든 AI 호출을 통합하고 출력을 파싱하는 핵심 모듈
"""

import os
import json
import subprocess
from dataclasses import dataclass
from typing import Dict, List, Optional, Any
from pathlib import Path

from .gcx_core import get_timestamp


@dataclass
class AIResult:
    """AI 실행 결과 데이터 클래스"""
    success: bool
    output: str
    parsed: Optional[Dict[str, Any]]
    error: Optional[str]
    ai_type: str
    model: str
    duration: float  # seconds


class BaseAIInvoker:
    """기본 AI Invoker 클래스"""

    def __init__(self):
        self.default_timeout = 300  # 5 minutes

    def _run_command(
        self,
        cmd: List[str],
        timeout: Optional[int] = None,
        encoding: str = "utf-8"
    ) -> subprocess.CompletedProcess:
        """
        명령어 실행 (공통 로직)

        Args:
            cmd: 실행할 명령어 리스트
            timeout: 타임아웃 (초)
            encoding: 출력 인코딩

        Returns:
            subprocess.CompletedProcess 객체
        """
        import time

        # 환경 변수 설정
        env = os.environ.copy()
        env["NO_COLOR"] = "1"
        env["LANG"] = "ko_KR.UTF-8"  # 한글 출력 지원

        start_time = time.time()

        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                encoding=encoding,
                errors="replace",  # 인코딩 에러 무시
                timeout=timeout or self.default_timeout,
                env=env
            )
            duration = time.time() - start_time
            result.duration = duration
            return result

        except subprocess.TimeoutExpired as e:
            duration = time.time() - start_time
            # 타임아웃 결과 생성
            result = subprocess.CompletedProcess(
                cmd, 124, stdout="", stderr=f"Timeout after {duration:.1f}s"
            )
            result.duration = duration
            return result

    def _extract_code_blocks(self, text: str, language: Optional[str] = None) -> List[str]:
        """
        마크다운 코드 블록 추출

        Args:
            text: 입력 텍스트
            language: 언어 필터 (예: "python", "typescript")

        Returns:
            추출된 코드 블록 리스트
        """
        import re

        pattern = r"```(\w+)?\n(.*?)```"
        matches = re.findall(pattern, text, re.DOTALL)

        if language:
            return [code for lang, code in matches if lang == language]
        else:
            return [code for _, code in matches]


class CodexInvoker(BaseAIInvoker):
    """Codex CLI Invoker"""

    def __init__(self):
        super().__init__()
        self.default_model = "gpt-5.1-codex"
        self.default_reasoning = "high"  # NOT "xhigh"!

    def invoke(
        self,
        prompt: str,
        mode: str = "generate",
        model: Optional[str] = None,
        reasoning: Optional[str] = None,
        output_file: Optional[str] = None
    ) -> AIResult:
        """
        Codex 실행

        Args:
            prompt: 프롬프트
            mode: 모드 (generate, tdd, security, audit)
            model: 모델 (기본: gpt-5.1-codex)
            reasoning: Reasoning effort (low, medium, high)
            output_file: 출력 파일 경로

        Returns:
            AIResult 객체
        """
        import time

        model = model or self.default_model
        reasoning = reasoning or self.default_reasoning

        # 모드별 프롬프트 포맷팅
        formatted_prompt = self._format_prompt(prompt, mode, reasoning)

        # 명령어 구성
        cmd = ["codex", "exec", "-m", model, formatted_prompt]

        # 실행
        start_time = time.time()
        result = self._run_command(cmd)
        duration = time.time() - start_time

        # 출력 파싱
        parsed = self._parse_output(result.stdout, mode)

        # 파일 저장
        if output_file and result.returncode == 0:
            Path(output_file).parent.mkdir(parents=True, exist_ok=True)
            with open(output_file, "w", encoding="utf-8") as f:
                f.write(result.stdout)

        return AIResult(
            success=result.returncode == 0,
            output=result.stdout,
            parsed=parsed,
            error=result.stderr if result.returncode != 0 else None,
            ai_type="codex",
            model=model,
            duration=duration
        )

    def _format_prompt(self, prompt: str, mode: str, reasoning: str) -> str:
        """모드별 프롬프트 포맷팅"""

        if mode == "tdd":
            return f"""{prompt}

요구사항:
- 테스트 먼저 작성 (TDD)
- Jest/Vitest 사용
- 한글 주석 포함
- Given-When-Then 패턴

Reasoning: {reasoning.capitalize()}
"""
        elif mode == "security":
            return f"""{prompt}

보안 감사 요구사항:
- OWASP Top 10 체크
- 인증/인가 검증
- 입력 검증
- XSS, SQL Injection 확인
- 발견사항 우선순위별 분류 (Critical/High/Medium/Low)

Report in Korean
Reasoning: {reasoning.capitalize()}
"""
        elif mode == "audit":
            return f"""{prompt}

코드 감사 요구사항:
- 순환 복잡도 분석
- 중복 코드 탐지
- 성능 병목 지점
- Over-engineering 확인
- 개선 제안

Report in Korean
Reasoning: {reasoning.capitalize()}
"""
        else:  # generate
            return f"""{prompt}

요구사항:
- Production-ready code
- TypeScript 사용
- 한글 주석
- JSDoc 문서화

Reasoning: {reasoning.capitalize()}
"""

    def _parse_output(self, output: str, mode: str) -> Dict[str, Any]:
        """출력 파싱 (모드별)"""

        parsed = {
            "raw": output,
            "code_blocks": self._extract_code_blocks(output),
            "has_korean": bool(__import__('re').search(r'[가-힣]', output))
        }

        if mode == "security":
            # 보안 발견사항 추출
            parsed["security_findings"] = self._extract_security_findings(output)

        elif mode == "tdd":
            # 테스트 코드 추출
            parsed["test_code"] = self._extract_code_blocks(output, "typescript") or \
                                  self._extract_code_blocks(output, "javascript")

        return parsed

    def _extract_security_findings(self, output: str) -> List[Dict]:
        """보안 발견사항 추출"""
        import re

        findings = []
        severity_pattern = r"(Critical|High|Medium|Low):\s*(.+)"

        for match in re.finditer(severity_pattern, output, re.MULTILINE):
            findings.append({
                "severity": match.group(1),
                "description": match.group(2).strip()
            })

        return findings


class ClaudeInvoker(BaseAIInvoker):
    """Claude CLI Invoker"""

    def __init__(self):
        super().__init__()
        self.default_model = "sonnet"  # alias

    def invoke(
        self,
        prompt: str,
        model: Optional[str] = None,
        output_file: Optional[str] = None
    ) -> AIResult:
        """
        Claude 실행

        Args:
            prompt: 프롬프트
            model: 모델 (sonnet, opus, haiku)
            output_file: 출력 파일 경로

        Returns:
            AIResult 객체
        """
        import time

        model = model or self.default_model

        # 명령어 구성
        cmd = ["claude", "-p", prompt, "--model", model]

        # 실행
        start_time = time.time()
        result = self._run_command(cmd)
        duration = time.time() - start_time

        # 출력 파싱
        parsed = {
            "raw": output,
            "code_blocks": self._extract_code_blocks(result.stdout),
            "has_korean": bool(__import__('re').search(r'[가-힣]', result.stdout))
        }

        # 파일 저장
        if output_file and result.returncode == 0:
            Path(output_file).parent.mkdir(parents=True, exist_ok=True)
            with open(output_file, "w", encoding="utf-8") as f:
                f.write(result.stdout)

        return AIResult(
            success=result.returncode == 0,
            output=result.stdout,
            parsed=parsed,
            error=result.stderr if result.returncode != 0 else None,
            ai_type="claude",
            model=model,
            duration=duration
        )


class GeminiInvoker(BaseAIInvoker):
    """Gemini CLI Invoker"""

    def __init__(self):
        super().__init__()
        self.default_model = "gemini-2.0-flash-exp"

    def invoke(
        self,
        prompt: str,
        mode: str = "orchestrate",
        model: Optional[str] = None,
        output_file: Optional[str] = None
    ) -> AIResult:
        """
        Gemini 실행

        Args:
            prompt: 프롬프트
            mode: 모드 (orchestrate, design, finalize)
            model: 모델
            output_file: 출력 파일 경로

        Returns:
            AIResult 객체
        """
        import time

        model = model or self.default_model

        # 모드별 프롬프트 포맷팅
        formatted_prompt = self._format_prompt(prompt, mode)

        # 명령어 구성 (Gemini CLI 예시 - 실제 구현에 따라 다를 수 있음)
        cmd = ["gemini", "exec", "-m", model, formatted_prompt]

        # 실행
        start_time = time.time()
        result = self._run_command(cmd)
        duration = time.time() - start_time

        # 출력 파싱
        parsed = {
            "raw": result.stdout,
            "has_korean": bool(__import__('re').search(r'[가-힣]', result.stdout))
        }

        # 파일 저장
        if output_file and result.returncode == 0:
            Path(output_file).parent.mkdir(parents=True, exist_ok=True)
            with open(output_file, "w", encoding="utf-8") as f:
                f.write(result.stdout)

        return AIResult(
            success=result.returncode == 0,
            output=result.stdout,
            parsed=parsed,
            error=result.stderr if result.returncode != 0 else None,
            ai_type="gemini",
            model=model,
            duration=duration
        )

    def _format_prompt(self, prompt: str, mode: str) -> str:
        """모드별 프롬프트 포맷팅"""

        if mode == "design":
            return f"""UI/UX Design (ABSOLUTE AUTHORITY):
{prompt}

Requirements:
- User-centered design
- Accessibility (WCAG 2.1)
- Responsive layout
- Modern aesthetics

Report in Korean
"""
        elif mode == "finalize":
            return f"""Final Report Generation:
{prompt}

Requirements:
- Executive summary
- Deliverables list with file paths
- Quality metrics
- Next steps

Format: Korean Markdown
"""
        else:  # orchestrate
            return prompt


# 편의 함수
def invoke_codex(prompt: str, **kwargs) -> AIResult:
    """Codex 빠른 실행"""
    invoker = CodexInvoker()
    return invoker.invoke(prompt, **kwargs)


def invoke_claude(prompt: str, **kwargs) -> AIResult:
    """Claude 빠른 실행"""
    invoker = ClaudeInvoker()
    return invoker.invoke(prompt, **kwargs)


def invoke_gemini(prompt: str, **kwargs) -> AIResult:
    """Gemini 빠른 실행"""
    invoker = GeminiInvoker()
    return invoker.invoke(prompt, **kwargs)


if __name__ == "__main__":
    # 간단한 테스트
    print("=== AI Invokers Test ===")
    print("\n[1/3] Testing Codex Invoker...")

    codex = CodexInvoker()
    result = codex.invoke(
        "간단한 TypeScript 함수 작성: 두 수를 더하는 add 함수",
        mode="generate"
    )

    print(f"Success: {result.success}")
    print(f"Duration: {result.duration:.2f}s")
    print(f"Has Korean: {result.parsed['has_korean']}")
    print(f"Code blocks: {len(result.parsed['code_blocks'])}")

    if result.success:
        print("\n출력 (첫 200자):")
        print(result.output[:200])
    else:
        print(f"\n오류: {result.error}")

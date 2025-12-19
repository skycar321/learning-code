#!/usr/bin/env python3
"""
PostToolUse Hook (Bash)
========================

Bash 도구 사용 후 자동 실행되는 Hook
- AI 출력 파싱
- Baton 업데이트
- 진행 상황 추적
"""

import sys
import os
import re
from pathlib import Path
from datetime import datetime

# 프로젝트 라이브러리 경로 추가
project_root = Path(__file__).parent.parent.parent
sys.path.insert(0, str(project_root / ".claude" / "lib"))

from context_manager import BatonManager, PhaseResult


def parse_ai_output(output: str) -> dict:
    """
    AI 출력에서 구조화된 정보 추출

    Args:
        output: AI 명령어 출력

    Returns:
        파싱된 정보 딕셔너리
    """
    parsed = {
        "has_error": False,
        "created_files": [],
        "modified_files": [],
        "ai_type": None,
        "phase": None
    }

    # 에러 감지
    if re.search(r"error|failed|exception", output, re.IGNORECASE):
        parsed["has_error"] = True

    # 파일 생성/수정 감지
    file_patterns = [
        r"(?:created|wrote|saved):\s*(.+\.(?:py|js|ts|md|json))",
        r"(?:modified|updated):\s*(.+\.(?:py|js|ts|md|json))"
    ]

    for pattern in file_patterns:
        matches = re.findall(pattern, output, re.MULTILINE)
        if "created" in pattern or "wrote" in pattern:
            parsed["created_files"].extend(matches)
        else:
            parsed["modified_files"].extend(matches)

    # AI 타입 감지 (codex, gemini, claude)
    if "codex" in output.lower():
        parsed["ai_type"] = "codex"
    elif "gemini" in output.lower():
        parsed["ai_type"] = "gemini"
    elif "claude" in output.lower():
        parsed["ai_type"] = "claude"

    # Phase 감지
    phase_keywords = {
        "requirement": "requirement-capture",
        "planning": "plan-architect",
        "tdd": "tdd-generator",
        "implementation": "implementation",
        "design": "design-review",
        "qa": "qa-validator",
        "finalize": "finalize-reporter"
    }

    for keyword, phase in phase_keywords.items():
        if keyword in output.lower():
            parsed["phase"] = phase
            break

    return parsed


def main():
    """PostToolUse Hook 메인 함수"""
    try:
        # Bash 명령어 출력 가져오기
        output = os.environ.get("CLAUDE_TOOL_OUTPUT", "")
        command = os.environ.get("CLAUDE_TOOL_COMMAND", "")

        # AI 관련 명령어만 처리 (codex, gemini 등)
        if not any(ai in command.lower() for ai in ["codex", "gemini", "claude"]):
            # AI 명령어가 아니면 스킵
            sys.exit(0)

        # 출력 파싱
        parsed = parse_ai_output(output)

        # Baton 업데이트 (phase 정보가 있는 경우만)
        if parsed["phase"] and parsed["ai_type"]:
            manager = BatonManager(project_root)
            baton = manager.load_baton()

            if baton:
                # PhaseResult 업데이트
                phase_result = manager.get_phase_result(parsed["phase"])

                if phase_result:
                    # 기존 결과 업데이트
                    if not parsed["has_error"]:
                        phase_result.status = "completed"
                        phase_result.completed_at = datetime.now().isoformat()
                        phase_result.output_files.extend(parsed["created_files"])
                        manager.add_phase_result(phase_result)
                else:
                    # 새 결과 생성
                    phase_result = PhaseResult(
                        phase_name=parsed["phase"],
                        status="in_progress" if not parsed["has_error"] else "failed",
                        ai_type=parsed["ai_type"],
                        model="unknown",  # 명령어에서 추출 필요
                        started_at=datetime.now().isoformat(),
                        output_files=parsed["created_files"],
                        error="에러 발생" if parsed["has_error"] else None
                    )
                    manager.add_phase_result(phase_result)

    except Exception as e:
        # Hook 에러는 조용히 처리
        pass


if __name__ == "__main__":
    main()

# GCX v5 Claude Code 통합 구현 계획 (v4.0)

## 0. 요약
본 문서는 아래 자료를 통합 검토하여 GCX v5 프로토콜을 Claude Code에 안정적으로 반영하기 위한 v4 계획서입니다.

**통합 입력 문서**
- 원본: `gcx skill agent hook plan.md`
- v2 피드백: `GCX_v5_Integration_Plan_v2.md`
- GCX 프로토콜 문서:
  - `C:/Users/Nam/.gemini/commands/nam/_cross_ai_invocation_v5.md`
  - `C:/Users/Nam/.gemini/commands/nam/GCX_MASTER_PROTOCOL_v5.md`
  - `C:/Users/Nam/.gemini/commands/nam/_gcx_roles_v5.md`
  - `C:/Users/Nam/.gemini/commands/nam/gcx-project-v5.toml`
  - `C:/Users/Nam/.gemini/commands/nam/gcx-query-v5.toml`
- Claude Code 공식 문서:
  - `C:/Users/Nam/Desktop/Workspace/learning-code/docs/claude/`

**핵심 목표**
- `/gcx-project "Task"` 한 번으로 Gemini → Claude → Codex 6단계 체인 자동 실행
- MSYS2 UCRT64 **Zsh 단일 환경** 고정 (PowerShell 제거)
- UTF-8 인코딩 안정성 확보
- Context Baton(JSON)으로 상태/아티팩트/오류 통합 관리
- Retry + Resume + Idempotency(재실행 안전성) 확보

---

## 1. v4 변경점 (v3 대비)
- Zsh 단일 환경 확정 (Bash/PowerShell 제거)
- Claude Code 공식 Hook/Skill/Subagent 스펙 반영
- Headless mode/출력 포맷 옵션 반영
- v5 Master Protocol 디렉터리 구조로 정렬
- 모델 정책(허용/금지) 및 reasoning 설정 명문화
- MCP 스코프/보안 주의사항 추가

---

## 2. 핵심 원칙
1. **No Simulation**: AI 응답을 시뮬레이션하지 않고 실제 CLI 실행
2. **Zsh Only**: 모든 스크립트는 Zsh
3. **TDD 강제**: 테스트 → 구현 순서 고정
4. **Gemini 디자인 권한**: UI/UX 최종 결정권은 Gemini
5. **안정성 우선**: Retry/Resume/Fail-safe 기본 포함

---

## 3. 전체 아키텍처
```
User: /gcx-project "Build REST API"
    |
    v
Skill: gcx-project-v5
  - v5 프로토콜 로드
  - 6단계 Subagent 체인 오케스트레이션
  - 진행 상황 실시간 표시
    |
    v
Subagent Chain (File-Based Handoff)
  [Step 1/6] Requirement Capture
  [Step 2/6] Plan Architect
  [Step 3/6] TDD Generator
  [Step 4/6] Implementation
  [Step 5/6] QA Validator
  [Step 6/6] Finalize Reporter
    |
    v
Hooks
  - UserPromptSubmit: 요구사항 자동 캡처
  - PreToolUse: 환경 검증 + 위험 명령 차단
  - PostToolUse: AI 출력 파싱 + 메트릭 로깅
  - SubagentStop: 체크포인트 저장
    |
    v
Final Report (Korean) + Commit Suggestion
```

---

## 4. 실제 실행 순서 (시퀀스)
```
User
  |
  | /gcx-project "Task"
  v
Hook: UserPromptSubmit
  - 요구사항 캡처
  - Baton 초기화
  |
  v
Skill: gcx-project-v5
  |
  | Step 1 -> Subagent: requirement-capture
  |   - Result Block 반환
  |   - Baton update
  |
  | Step 2 -> Subagent: plan-architect
  |   - Result Block 반환
  |   - Baton update
  |
  | Step 3 -> Subagent: tdd-generator
  |   - Result Block 반환
  |   - Baton update
  |
  | Step 4 -> Subagent: implementation-executor
  |   - Result Block 반환
  |   - Baton update
  |
  | Step 5 -> Subagent: qa-validator
  |   - Result Block 반환
  |   - Baton update
  |
  | Step 6 -> Subagent: finalize-reporter
  |   - Result Block 반환
  |   - Baton update
  v
Hook: SubagentStop
  - 체크포인트 저장
  - 상태 갱신
  |
  v
Final Report + Commit Suggestion
```

---

## 5. 역할과 권한 (GCX Roles v5)
### 5.1 Gemini (Orchestrator)
- 요구사항 캡처, 전체 플로우 조율, 최종 통합
- UI/UX 디자인에 대한 **절대 권한**

### 5.2 Claude (Architect/Reviewer)
- 아키텍처/품질/보안/성능 검토
- UI/UX 디자인에는 관여 금지

### 5.3 Codex (Generator/Auditor)
- TDD 기반 테스트 생성과 구현
- 보안 감사, 품질 분석, 리팩토링

**Conflict Rules**
- UI/UX 결정: Gemini > Claude/Codex
- 코드 품질: Claude (review) > Codex (implementation)
- 보안 승인: Claude + Codex 동시 승인 필요

---

## 6. 환경 표준 (Zsh Only)
**필수**: MSYS2 UCRT64 + Zsh 5.9+
```zsh
export LANG=ko_KR.UTF-8
export LC_ALL=ko_KR.UTF-8
export NO_COLOR=1
```

**Preflight 예시**
```zsh
#!/usr/bin/env zsh
# .gcx/templates/preflight_check_v5.zsh

if [[ "$MSYSTEM" != "UCRT64" ]]; then
  echo "Not in MSYS2 UCRT64"; exit 1
fi
if [[ -z "$ZSH_VERSION" ]]; then
  echo "Not running Zsh"; exit 1
fi
if [[ "$LANG" != "ko_KR.UTF-8" ]]; then
  export LANG=ko_KR.UTF-8
  export LC_ALL=ko_KR.UTF-8
fi
REASONING=$(grep "model_reasoning_effort" ~/.codex/config.toml | cut -d'"' -f2)
if [[ "$REASONING" == "xhigh" ]]; then
  echo "Fix reasoning effort: xhigh -> high"; exit 1
fi
```

### 6.1 Invocation 패턴 (Zsh)
**파일 기반 핸드오프**
```zsh
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
LOG_DIR=".gcx/pipeline/logs"
mkdir -p "$LOG_DIR"

claude -p "Plan..." --model sonnet | tee "$LOG_DIR/claude_plan_$TIMESTAMP.md"
codex exec -m "gpt-5.1-codex" "Implement: $(cat $LOG_DIR/claude_plan_$TIMESTAMP.md)" \
  | tee "$LOG_DIR/codex_impl_$TIMESTAMP.ts"
```

**Named Pipes 스트리밍**
```zsh
mkfifo /tmp/pipe1 /tmp/pipe2
claude -p "Plan..." --model sonnet > /tmp/pipe1 &
codex exec -m "gpt-5.1-codex" "$(cat /tmp/pipe1)" > /tmp/pipe2 &
cat /tmp/pipe2
rm -f /tmp/pipe1 /tmp/pipe2
```

**Associative Arrays (모델 관리)**
```zsh
typeset -A AI_MODELS
AI_MODELS=( claude "claude-sonnet-4-5" codex "gpt-5.1-codex" )
CLAUDE_MODEL=${AI_MODELS[claude]}
CODEX_MODEL=${AI_MODELS[codex]}
```

**병렬 검증**
```zsh
claude -p "Review..." --model sonnet > claude_review.md &
codex exec -m "gpt-5.1-codex" "Audit..." > codex_audit.md &
wait
```

---

## 7. 모델 정책 (Strict)
### Claude
- `sonnet` / `claude-sonnet-4-5` (default)
- `opus` / `claude-opus-4-5`
- `haiku` / `claude-haiku-4-5`

### Codex
- `gpt-5.1-codex` (default)
- `gpt-5.1-codex-max`
- `gpt-5.1-codex-mini`
- `gpt-5.2`

### Not Supported (금지)
- `gpt-4o-mini`, `gpt-4.1`, `gpt-4`

### Reasoning Effort
- `high`, `medium`, `low`만 지원
- `xhigh` 금지

---

## 8. 디렉터리 구조 (v5 Master Protocol)
```
.gcx/
├── 00_requirements/        # 요구사항 저장 (필수)
├── 01_planning/            # 계획 산출물
├── 02_implementation/      # 구현 단계
│   ├── tests/              # TDD 테스트
│   └── ...
├── 03_verification/        # QA/검증
├── pipeline/
│   ├── logs/               # gemini_*.log, claude_*.log, codex_*.log
│   ├── pipe_gemini_claude  # Named pipes
│   └── pipe_claude_codex
├── templates/              # Zsh 템플릿
├── tests/                  # 테스트 스크립트
├── output/                 # 최종 산출물
└── review/                 # Over-engineering 리뷰
```

---

## 9. Context Baton v3 스키마
```json
{
  "version": "v3",
  "session_id": "gcx_20251219_143022",
  "command": "/gcx-project \"Build REST API\"",
  "status": "in_progress",
  "current_step": 2,
  "steps_total": 6,
  "artifacts": {
    "requirements": ".gcx/00_requirements/req_20251219_143022.md",
    "plan": ".gcx/01_planning/plan_20251219_143022.md",
    "tests": ".gcx/02_implementation/tests/test_20251219_143022.ts",
    "source_dir": "src/",
    "qa_report": ".gcx/03_verification/security_report_20251219_143022.md",
    "final_report": ".gcx/output/final_report_20251219_143022.md"
  },
  "metrics": {
    "start_time_utc": "2025-12-19T05:30:22Z",
    "step_durations_sec": {"1": 45, "2": 120},
    "ai_invocations": 7,
    "warnings": 1
  },
  "budgets": {
    "max_retries": 3,
    "per_step_timeout_sec": 900,
    "max_tokens_per_step": 12000
  },
  "approvals": {
    "requires_human_review": true,
    "approved": false
  },
  "git_snapshot": {
    "branch": "main",
    "dirty": true,
    "last_commit": "abc1234"
  },
  "errors": [],
  "warnings": [],
  "last_updated_utc": "2025-12-19T05:34:10Z"
}
```

**필수 규칙**
- `atomic write` 사용
- `.gcx/locks/session_<id>.lock`로 동시 실행 방지
- `errors`는 구조화 항목 유지 (code, message, step, time)

---

## 10. Subagent 계약 (Claude Code 공식 스펙 반영)
### 10.1 Frontmatter 표준
```yaml
---
name: requirement-capture
description: Captures user requirements and saves to .gcx/00_requirements/
tools: Read, Write, Bash
model: sonnet
permissionMode: default
skills: gcx-project-v5
---
```

### 10.2 Subagent 위치 및 우선순위
- 프로젝트: `.claude/agents/` (우선순위 높음)
- 사용자: `~/.claude/agents/`

### 10.3 주요 필드 요약
- `name`: 소문자/하이픈만 허용
- `description`: 언제 사용해야 하는지 명확히 서술
- `tools`: 생략 시 전체 도구 상속
- `model`: sonnet/opus/haiku 또는 `inherit`
- `permissionMode`: default/acceptEdits/bypassPermissions/plan/ignore
- `skills`: 서브에이전트 시작 시 자동 로드

### 10.4 Result Block (필수)
```json
{
  "result": {
    "step": 2,
    "status": "ok",
  "summary": "Architecture plan generated",
  "artifacts": {"plan": ".gcx/01_planning/plan_20251219_143022.md"},
    "warnings": [],
    "errors": []
  }
}
```

### 10.5 Resumable Subagents
- subagent 실행 시 agentId 기록
- 필요 시 resume 파라미터로 이어서 실행 가능

---

## 11. Skill 설계 (Claude Code 스펙 반영)
### 11.1 SKILL.md 구조
```yaml
---
name: gcx-project-v5
description: GCX v5 프로젝트 전체 워크플로우. /gcx-project 요청 시 사용.
allowed-tools: Read, Write, Bash, Glob, Grep
---
```

### 11.2 Skill 동작 특성
- Claude Code에서 Skill은 **모델 자동 호출**
- Slash Command와 다르므로 description에 트리거 문구 포함 필수

### 11.3 Skill 위치
- 개인: `~/.claude/skills/`
- 프로젝트: `.claude/skills/`

### 11.4 Frontmatter 규칙
- `name`: 소문자/숫자/하이픈만 허용 (최대 64자)
- `description`: 사용 조건과 역할을 구체적으로 작성
- `allowed-tools`: 지정 시 해당 도구만 사용 가능

---

## 12. Claude Code 설정 파일 위치
- `~/.claude/settings.json` (User settings)
- `.claude/settings.json` (Project settings)
- `.claude/settings.local.json` (Local project)
- `~/.claude.json` (Global state)
- `.mcp.json` (Project MCP servers)

### 12.1 Output Style 참고
- `/output-style` 또는 `.claude/settings.local.json`의 `outputStyle` 필드로 변경
- 커스텀 스타일은 `.claude/output-styles/` 또는 `~/.claude/output-styles/`
- 커스텀 스타일에서 `keep-coding-instructions` 사용 가능

---

## 13. Hooks (Claude Code 공식 스펙 반영)
### 13.1 이벤트 목록
- PreToolUse
- PermissionRequest
- PostToolUse
- UserPromptSubmit
- Notification
- Stop
- SubagentStop
- PreCompact
- SessionStart
- SessionEnd

### 13.2 설정 예시 (matcher 구조)
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python .gcx/hooks/pre_bash.py"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python .gcx/hooks/post_bash.py"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "python .gcx/hooks/user_prompt.py"
          }
        ]
      }
    ]
  }
}
```

### 13.3 보안 주의
- Hook은 현재 사용자 권한으로 실행됨
- hook 스크립트는 반드시 검토 후 등록

---

## 14. Headless Mode (CLI)
**권장 사용**
```bash
claude -p "PROMPT" --output-format json
```

**권장 옵션**
- `--output-format json` 또는 `stream-json`
- `--allowedTools` / `--disallowedTools` 권한 제어
- `--resume` / `--continue` 세션 재개

---

## 15. GCX Project Pipeline (v5)
### Step 0: 환경 확인
- MSYS2 UCRT64, Zsh 5.9+, UTF-8

### Step 1: Requirement Capture (필수)
- `.gcx/00_requirements/req_YYYYMMDD_HHMMSS.md` 저장
```markdown
# User Request

**Date**: YYYY-MM-DD HH:MM:SS KST
**Task**: [요청 내용]

## Requirements
- [요구사항]

## Expected Output
- [결과물]
```

### Step 2: Model Selection
- 사용자에게 Claude/Codex 모델 선택 요청

### Step 3: Plan (Claude)
- 아키텍처/요구사항/데이터 흐름 작성

### Step 4: TDD (Codex)
- 테스트 먼저 생성

### Step 5: Implementation (Codex)
- 4-layer 구현 + Claude Quality Gate

### Step 5.5: Over-Engineering Review (옵션)
- Claude: YAGNI/KISS 점검
- Codex: 복잡도/중복/LOC 분석
- 출력: `.gcx/review/over_engineering_review.md`

### Step 6: QA (Codex)
- 보안 스캔 + 통합 테스트

### Step 7: Finalize (Gemini)
- 최종 리포트 + 커밋 제안

**Commit 정책**
- 자동 커밋 금지 (NEVER auto-commit)

---

## 16. GCX Query Pipeline (v5)
**분류 타입**: debug / arch / fe / concept

**예시 라우팅**
- debug: Codex 분석 → Claude 검증 → Gemini 통합
- arch: Claude 설계 → Codex 검증 → Gemini 통합
- fe: Gemini 디자인 → Codex 구현 → Claude 품질
- concept: Claude 설명 → Codex 예제 → Gemini 요약

---

## 17. 관측성 (Observability)
- `.gcx/metrics/ai_invocations.jsonl`
- `.gcx/metrics/hook_events.jsonl`
- `.gcx/metrics/step_summary.jsonl`
- `.gcx/pipeline/logs/*.log`

**표준 필드**
- `timestamp`, `session_id`, `step`, `ai_type`, `duration_ms`, `status`, `error_code`

---

## 18. 보안 & 안전
- Path allowlist + traversal 차단
- secrets 마스킹 (.env, secrets.*)
- Hook 위험 명령 차단
- MCP 사용 시 허용 목록 검토

---

## 19. MCP 연동 요약
- 설정 파일: `.mcp.json`, `~/.claude.json`
- 스코프: local / project / user
- Windows stdio MCP는 `cmd /c` 래핑 필요
- MCP 출력 제한: `MAX_MCP_OUTPUT_TOKENS` 환경변수 사용

---

## 20. 테스트 전략
- Unit: context_manager, validators, path_normalizer
- Integration: hooks + baton update
- E2E: /gcx-project 전체 플로우
- Golden Transcript: 결과 파일 해시 비교

---

## 21. 핵심 파일 예시
### 21.1 `.gcx/lib/ai_invokers.py` (Codex 호출 예시)
```python
class CodexInvoker:
    def invoke(self, prompt: str, mode: str = "generate",
               reasoning: str = "high", output_file: str = None) -> Dict:
        env = os.environ.copy()
        env["NO_COLOR"] = "1"
        env["LANG"] = "ko_KR.UTF-8"

        cmd = ["codex", "exec", "-m", "gpt-5.1-codex", prompt]
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            encoding="utf-8",
            env=env,
            timeout=300
        )

        parsed = self._parse_output(result.stdout, mode)
        return {
            "success": result.returncode == 0,
            "output": result.stdout,
            "parsed": parsed
        }
```

### 21.2 `.gcx/hooks/post_bash.py` (파싱/로깅 예시)
```python
def hook_post_bash(hook_input: dict):
    cmd = hook_input["tool_input"]["command"]

    if "codex exec" in cmd:
        ai_type = "codex"
    elif "claude -p" in cmd:
        ai_type = "claude"
    elif "gemini" in cmd:
        ai_type = "gemini"
    else:
        return

    output = hook_input.get("stdout", "")
    parsed = parse_ai_output(output, ai_type)

    log_metric("ai_invocation", {
        "ai_type": ai_type,
        "timestamp": get_timestamp(),
        "output_length": len(output),
        "has_korean": has_korean_chars(output)
    })

    if "security" in cmd and ai_type == "codex":
        findings = extract_security_findings(output)
        save_security_report(findings)
```

### 21.3 `.gcx/hooks/user_prompt.py` (요구사항 자동 캡처 예시)
```python
#!/usr/bin/env python3
import sys
import json
from pathlib import Path

def main() -> None:
    try:
        hook_input = json.load(sys.stdin)
        user_message = hook_input.get("user_message", "")

        if "/gcx-" in user_message:
            timestamp = get_timestamp()
            req_file = f".gcx/00_requirements/req_{timestamp}.md"

            Path(req_file).parent.mkdir(parents=True, exist_ok=True)
            with open(req_file, "w", encoding="utf-8") as f:
                f.write(f"# User Request\n\n{user_message}\n\n**Timestamp**: {timestamp}\n")

            log_metric("gcx_invocation", {
                "timestamp": timestamp,
                "command": user_message
            })

        print(json.dumps({"action": "proceed"}))
    except Exception:
        print(json.dumps({"action": "proceed"}))

if __name__ == "__main__":
    main()
```

### 21.4 `.gcx/lib/context_manager.py` (Baton 스켈레톤)
```python
import json
import os
from typing import Any, Dict

class ContextManager:
    def __init__(self, path: str) -> None:
        self.path = path
        self.lock_path = f"{path}.lock"

    def load(self) -> Dict[str, Any]:
        if not os.path.exists(self.path):
            return {}
        with open(self.path, "r", encoding="utf-8") as f:
            return json.load(f)

    def save_atomic(self, data: Dict[str, Any]) -> None:
        tmp_path = f"{self.path}.tmp"
        with open(tmp_path, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        os.replace(tmp_path, self.path)
```

### 21.5 `.gcx/hooks/pre_bash.py` (가드레일 예시)
```python
#!/usr/bin/env python3
import sys
import json

BLOCKLIST = [" rm ", " del ", " shutdown", " format "]

def main() -> None:
    try:
        hook_input = json.load(sys.stdin)
        cmd = hook_input.get("tool_input", {}).get("command", "")
        lowered = f" {cmd.lower()} "
        for token in BLOCKLIST:
            if token in lowered:
                print(json.dumps({"action": "deny", "message": "Blocked"}))
                return
        print(json.dumps({"action": "proceed"}))
    except Exception:
        print(json.dumps({"action": "proceed"}))

if __name__ == "__main__":
    main()
```

### 21.6 `.gcx/hooks/subagent_stop.py` (체크포인트 예시)
```python
#!/usr/bin/env python3
import sys
import json
from pathlib import Path

def main() -> None:
    try:
        hook_input = json.load(sys.stdin)
        session_id = hook_input.get("session_id", "unknown")
        checkpoint_path = Path(f".gcx/checkpoints/session_{session_id}.json")
        checkpoint_path.parent.mkdir(parents=True, exist_ok=True)

        with open(checkpoint_path, "w", encoding="utf-8") as f:
            json.dump(hook_input, f, ensure_ascii=False, indent=2)

        print(json.dumps({"action": "proceed"}))
    except Exception:
        print(json.dumps({"action": "proceed"}))

if __name__ == "__main__":
    main()
```

---

## 22. 버전 비교 (v1/v2/v3/v4)
| 항목 | v1 (원본) | v2 (Gemini) | v3 | v4 (현재) |
|------|-----------|-------------|----|-----------|
| Shell | MSYS2 기준 | Win/MSYS2 | Win/MSYS2 | Zsh Only (PowerShell 제거) |
| Context Baton | 없음 | JSON Baton | v3 스키마 | v3 스키마 + 공식 스펙 통합 |
| Hooks | 단순 스크립트 | Fail-safe 강조 | Result Block | 공식 matcher 구조 반영 |
| Claude Code 문서 반영 | 최소 | 일부 | 일부 | Skills/Subagents/Hooks/Headless 반영 |
| MCP | 언급 없음 | 제한 | 제한 | 스코프/보안 포함 |
| 디렉터리 구조 | 기본 | 일부 정리 | v3 구조 | v5 Master 구조 정렬 |

---

## 23. 참고 문서
- GCX v5 프로토콜: `C:/Users/Nam/.gemini/GEMINI_v5.md`
- Cross Invocation: `C:/Users/Nam/.gemini/commands/nam/_cross_ai_invocation_v5.md`
- Master Protocol: `C:/Users/Nam/.gemini/commands/nam/GCX_MASTER_PROTOCOL_v5.md`
- Roles: `C:/Users/Nam/.gemini/commands/nam/_gcx_roles_v5.md`
- Claude Code Docs: `C:/Users/Nam/Desktop/Workspace/learning-code/docs/claude/`

---

**v4 작성 완료**

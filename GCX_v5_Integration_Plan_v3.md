# GCX v5 Claude Code 통합 구현 계획 (v3.0)

## 0. 요약
이 문서는 **원본("gcx skill agent hook plan.md")**과 **v2(Gemini 피드백)**을 통합하고, 부족했던 **데이터 계약·신뢰성·보안·관측성·재실행 안전성**을 보강한 v3 계획서입니다.

**핵심 목표**
- `/gcx-project "Task"` 한 번으로 **Gemini → Claude → Codex 6단계 체인 자동 실행**
- Windows/MSYS2 경로, UTF-8, Hook 안정성 확보
- 진행 상태/아티팩트/오류를 **Context Baton(JSON)**으로 통합 관리
- 실패 시 **Retry + Resume** 가능

---

## 1. v3 변경점 (v2 대비)
- **Context Baton v3 스키마 명시**: 버전, 세션 ID, 단계, 아티팩트, 예산/승인, Git 스냅샷 포함
- **표준 Result Block(JSON)**: 모든 Subagent 출력 말미에 구조화된 결과 필수
- **아이템포턴시 규칙**: 산출물 존재 시 재생성 대신 검증/스킵
- **Atomic Write + Lock**: Baton/체크포인트 동시 쓰기 충돌 방지
- **보안 가드레일 강화**: 경로 허용 목록, 위험 명령 차단, secrets 마스킹
- **관측성 강화**: hook/ai/step 로그 스키마 통일
- **예산/타임아웃 명시**: 단계별 시간/토큰/재시도 예산
- **인코딩 가이드 명문화**: UTF-8 고정 + Windows 도구 설정

---

## 2. 전체 아키텍처
```
User: /gcx-project "Build REST API"
    ↓
┌─────────────────────────────────────────────┐
│ Skill: gcx-project-v5                       │
│ - v5 프로토콜 로드 (progressive disclosure)│
│ - 6단계 Subagent 체인 오케스트레이션       │
│ - 진행 상황 실시간 표시                    │
└─────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────┐
│ Subagent Chain (File-Based Handoff)        │
│ [Step 1/6] Requirement Capture → 📌        │
│ [Step 2/6] Plan Architect      → 📐         │
│ [Step 3/6] TDD Generator       → 🧪        │
│ [Step 4/6] Implementation      → 🛠️        │
│ [Step 5/6] QA Validator        → 🛡️        │
│ [Step 6/6] Finalize Reporter   → 📝        │
└─────────────────────────────────────────────┘
    ↓
Hooks:
  - UserPromptSubmit → 요구사항 자동 캡처
  - PreToolUse → 환경 검증 (MSYS2, Locale)
  - PostToolUse → AI 출력 파싱 및 로깅
  - SubagentStop → 체크포인트 저장
    ↓
Final Report (Korean) + Commit Suggestion
```

---

## 2.1 실제 실행 순서 (시퀀스)
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

## 3. 구현할 컴포넌트

### 3.1 Subagents (6개)
| 이름 | 도구 | 역할 | 입력 | 출력 |
|------|------|------|------|------|
| `requirement-capture` | Read, Write, Bash | 요구사항 캡처 | User Prompt | `req_*.md`, Baton update |
| `plan-architect` | Read, Glob, Grep | 아키텍처 설계 | `req_*.md` | `plan_*.md`, Baton update |
| `tdd-generator` | Read, Write, Bash | 테스트 우선 생성 | `plan_*.md` | `test_*.ts`, Baton update |
| `implementation-executor` | All | 4-layer 구현 | `plan_*.md`, `test_*.ts` | `src/`, Baton update |
| `qa-validator` | Read, Bash | 보안 스캔/통합 테스트 | `src/` | `security_*.md`, Baton update |
| `finalize-reporter` | Read, Write, Bash | 최종 리포트 | 모든 아티팩트 | `report_*.md` |

### 3.2 Skills (2개)
| 이름 | 설명 |
|------|------|
| `gcx-project-v5` | 프로젝트 전체 워크플로우 (6단계 체인) |
| `gcx-query-v5` | 빠른 쿼리 해결 (debug/arch/fe/concept) |

### 3.3 Hooks (4개)
| 이벤트 | 스크립트 | 역할 |
|--------|----------|------|
| UserPromptSubmit | `user_prompt.py` | 요구사항 자동 저장 + Baton 초기화 |
| PreToolUse | `pre_bash.py` | 환경 검증 + 위험 명령 차단 |
| PostToolUse | `post_bash.py` | AI 출력 파싱 + 메트릭 로깅 |
| SubagentStop | `subagent_stop.py` | 체크포인트 저장 (resume용) |

### 3.4 Python 라이브러리 (8개+)
| 모듈 | 역할 | v3 보강 |
|------|------|--------|
| `gcx_core.py` | Timestamp, UTF-8 정규화 | `PathNormalizer` 포함 |
| `environment.py` | MSYS2 UCRT64 감지 | Python 경로 확인 |
| `validators.py` | TOML, 한글 UTF-8 검증 | Baton 스키마 검증 |
| `ai_invokers.py` | Codex/Gemini/Claude 래퍼 | Retry + Timeout |
| `parsers.py` | 출력 파싱 | 결과 블록/토큰 절단 |
| `requirement_capture.py` | 요구사항 문서화 | - |
| `formatters.py` | 포맷 변환 | - |
| `preflight.py` | 통합 사전 점검 | 경로 매핑 확인 |
| `context_manager.py` | **신규** | Baton 로드/저장/락 |

---

## 4. Context Baton v3 스키마
**정의**: 단일 JSON 파일로 세션 전 상태를 관리한다. 모든 단계는 이 파일을 읽고 갱신한다.

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
    "plan": ".gcx/plans/plan_20251219_143022.md",
    "tests": ".gcx/tests/test_20251219_143022.ts",
    "source_dir": "src/",
    "qa_report": ".gcx/qa/security_report_20251219_143022.md",
    "final_report": ".gcx/reports/final_report_20251219_143022.md"
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
- 동시 실행 방지를 위해 `.gcx/locks/session_<id>.lock` 사용
- `errors`는 구조화 항목 유지 (code, message, step, time)

---

## 5. Subagent 계약 (표준 Result Block)
모든 Subagent는 **출력 마지막에 JSON Result Block**을 포함한다.

```json
{
  "result": {
    "step": 2,
    "status": "ok",
    "summary": "Architecture plan generated",
    "artifacts": {"plan": ".gcx/plans/plan_20251219_143022.md"},
    "warnings": [],
    "errors": []
  }
}
```

**아이템포턴시**
- 출력 대상 파일이 이미 존재하고 스키마 검증이 통과되면 재생성하지 않는다.
- 재실행 시 `status: skipped` 반환 + Baton만 업데이트

---

## 6. Skill 설계 (gcx-project-v5)
**실행 흐름**
1. Context Baton 생성
2. Step 1~6 루프
3. 각 단계 전후에 Result Block 검증
4. 실패 시 retry → 예산 초과 시 fail-safe 종료

**추가 커맨드 제안**
- `/gcx-status <session_id>`: 상태 조회
- `/gcx-resume <session_id>`: 중단 지점 재개
- `/gcx-cancel <session_id>`: 세션 종료 및 잠금 해제

---

## 7. Hooks 개선 (v3)
**공통 원칙**
- stdout에는 단일 JSON만 출력
- 디버그 로그는 stderr
- 예외 발생 시 `{"action":"proceed"}` 반환 (fail-safe)

**추가 가드레일**
- 경로 허용 목록 (Workspace 내부만 허용)
- 위험 커맨드 탐지 (rm, del, format, shutdown 등)
- 과도한 입력 길이 제한

---

## 8. 신뢰성/복구 전략
- **Retry**: 지수 백오프(2s, 4s, 8s) + 최대 3회
- **Resume**: 체크포인트(`.gcx/checkpoints/`) 기반 복구
- **Fail-Fast**: 스키마 검증 실패 시 즉시 중단
- **Time Budget**: 단계별 최대 실행 시간 제한

---

## 9. 보안 & 안전
- **Prompt Injection 완화**: 외부 파일/레포 내용은 untrusted로 처리
- **Secrets 마스킹**: `.env`, `secrets.*` 탐지 시 로그 제외
- **Path Traversal 방지**: `..` 패턴 및 절대경로 차단
- **Human Gate**: 변경 폭이 큰 경우 승인 필요

---

## 10. 관측성 (Observability)
**로그 파일 구조**
- `.gcx/metrics/ai_invocations.jsonl`
- `.gcx/metrics/hook_events.jsonl`
- `.gcx/metrics/step_summary.jsonl`

**표준 로그 필드**
- `timestamp`, `session_id`, `step`, `ai_type`, `duration_ms`, `status`, `error_code`

---

## 11. 핵심 파일 상세 예시 (원본 기반)

### 11.1 `.gcx/lib/ai_invokers.py` (Codex 호출 예시)
```python
class CodexInvoker:
    def invoke(self, prompt: str, mode: str = "generate",
               reasoning: str = "high", output_file: str = None) -> Dict:
        # UTF-8 인코딩 처리
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

### 11.2 `.claude/skills/gcx-project-v5/SKILL.md` (진행 트래커 예시)
```markdown
[Step 1/6] Requirement Capture -> Starting...
[Step 2/6] Plan Architect      -> Pending
[Step 3/6] TDD Generator       -> Pending
[Step 4/6] Implementation      -> Pending
[Step 5/6] QA Validator        -> Pending
[Step 6/6] Finalize Reporter   -> Pending
```

### 11.3 `.claude/agents/implementation-executor.md` (레이어 구현 예시)
```markdown
# Layer-by-Layer Implementation

## Layer 1: Infrastructure
1. Run Codex: `python .gcx/lib/codex_invoke.py --mode infra ...`
2. Claude Quality Gate: Review infra code
3. If CRITICAL issues -> Fix
4. Save to `.gcx/output/layer1_infra/`

## Layer 2-4: 동일 패턴 반복
```

### 11.4 `.gcx/hooks/post_bash.py` (AI 출력 파싱/로깅 예시)
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

### 11.5 `.claude/settings.json` (Hook 활성화 예시)
```json
{
  "hooks": {
    "UserPromptSubmit": "python C:/Users/Nam/Desktop/Workspace/learning-code/.gcx/hooks/user_prompt.py",
    "PreToolUse": {
      "Bash": "python C:/Users/Nam/Desktop/Workspace/learning-code/.gcx/hooks/pre_bash.py"
    },
    "PostToolUse": {
      "Bash": "python C:/Users/Nam/Desktop/Workspace/learning-code/.gcx/hooks/post_bash.py"
    },
    "SubagentStop": "python C:/Users/Nam/Desktop/Workspace/learning-code/.gcx/hooks/subagent_stop.py"
  }
}
```

### 11.6 `.gcx/hooks/user_prompt.py` (요구사항 자동 캡처 예시)
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

### 11.7 `.gcx/lib/context_manager.py` (Baton 로드/저장 스켈레톤)
```python
import json
import os
from pathlib import Path
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

    def update_artifact(self, key: str, value: str) -> None:
        data = self.load()
        data.setdefault("artifacts", {})
        data["artifacts"][key] = value
        self.save_atomic(data)
```

### 11.8 `.gcx/hooks/pre_bash.py` (환경/가드레일 예시)
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
                print(json.dumps({
                    "action": "deny",
                    "message": "Blocked dangerous command"
                }))
                return

        print(json.dumps({"action": "proceed"}))
    except Exception:
        print(json.dumps({"action": "proceed"}))

if __name__ == "__main__":
    main()
```

### 11.9 `.gcx/hooks/subagent_stop.py` (체크포인트 저장 예시)
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

## 12. 단계별 구현 계획

### Phase 1: Python 라이브러리 기초 (Week 1)
#### Step 1.1: 핵심 유틸리티 모듈 작성
**파일**: `.gcx/lib/__init__.py`, `.gcx/lib/gcx_core.py`, `.gcx/lib/environment.py`

#### Step 1.2: AI Invoker 구현 (최우선)
**파일**: `.gcx/lib/ai_invokers.py`

#### Step 1.3: Validator 모듈
**파일**: `.gcx/lib/validators.py`, `.gcx/lib/preflight.py`

#### Step 1.4: Parser & Formatter
**파일**: `.gcx/lib/parsers.py`, `.gcx/lib/formatters.py`

### Phase 2: Subagent 정의 (Week 2)
- requirement-capture, plan-architect, tdd-generator, implementation-executor, qa-validator, finalize-reporter

### Phase 3: Skill 구현 (Week 2)
- gcx-project-v5, gcx-query-v5

### Phase 4: Hook 시스템 (Week 3)
- user_prompt.py, pre_bash.py, post_bash.py, subagent_stop.py

### Phase 5: 통합 테스트 (Week 4)
- E2E, 성능/회귀 테스트

---

## 13. 인코딩 가이드
- 모든 문서/출력은 UTF-8 고정
- PowerShell 저장 시 `-Encoding UTF8` 사용
- VS Code 인코딩 설정: `"files.encoding": "utf8"`

---

## 14. 최종 파일 구조 (원본 유지)
```
learning-code/
├── .claude/
│   ├── settings.json
│   ├── skills/
│   │   ├── gcx-project-v5/
│   │   │   ├── SKILL.md
│   │   │   └── v5_protocol.md
│   │   └── gcx-query-v5/
│   │       └── SKILL.md
│   └── agents/
│       ├── requirement-capture.md
│       ├── plan-architect.md
│       ├── tdd-generator.md
│       ├── implementation-executor.md
│       ├── qa-validator.md
│       └── finalize-reporter.md
├── .gcx/
│   ├── lib/
│   │   ├── gcx_core.py
│   │   ├── environment.py
│   │   ├── validators.py
│   │   ├── ai_invokers.py
│   │   ├── parsers.py
│   │   ├── requirement_capture.py
│   │   ├── formatters.py
│   │   ├── preflight.py
│   │   └── context_manager.py
│   ├── hooks/
│   │   ├── user_prompt.py
│   │   ├── pre_bash.py
│   │   ├── post_bash.py
│   │   └── subagent_stop.py
│   ├── cli.py
│   ├── tests/
│   ├── 00_requirements/
│   ├── plans/
│   ├── tests/
│   ├── output/
│   ├── qa/
│   ├── reports/
│   ├── checkpoints/
│   └── metrics/
└── CLAUDE.md
```

---

## 15. 체크리스트 (v3)
- [ ] Context Baton v3 스키마 적용
- [ ] Subagent Result Block(JSON) 강제
- [ ] Atomic Write + Lock 적용
- [ ] Resume/Status 명령 구현
- [ ] Path allowlist + 위험 커맨드 차단
- [ ] Metrics 로그 스키마 통일
- [ ] UTF-8 인코딩 가이드 문서화

---

## 16. 버전 비교 (v1/v2/v3)
| 항목 | v1 (원본) | v2 (Gemini 피드백) | v3 (현재) |
|------|-----------|-------------------|-----------|
| 핵심 구조 | 6단계 Subagent 체인 | 동일 | 동일 |
| Context Baton | 없음 (파일 핸드오프 중심) | JSON Baton 도입 | v3 스키마 명시 + 예산/승인 포함 |
| 경로/환경 | MSYS2 기준 언급 | Win/MSYS2 경로 정규화 | allowlist + traversal 방지 |
| 안정성 | 체크포인트 언급 | Retry/Fail-safe Hook | Atomic write + lock + idempotency |
| 결과 계약 | 문서 출력 중심 | Baton 업데이트 중심 | Result Block(JSON) 표준화 |
| 보안 | QA 단계만 언급 | Hook fail-safe + stderr 규칙 | 위험 명령 차단 + secrets 마스킹 |
| 보안 범위 | 보안 리포트 생성 | Hook 안정성 강조 | 가드레일/프롬프트 인젝션 완화 |
| 관측성 | 로그 언급 | 메트릭 로깅 강화 | 로그 스키마 통일 (ai/hook/step) |
| 재시작 | Resume 시나리오 | Resume 로직 구체화 | Status/Cancel 커맨드 추가 |
| 테스트 전략 | E2E 스크립트 제안 | 통합 테스트/벤치마크 | Unit/Integration/E2E/Golden 제안 |
| 체크리스트 | 단계별 완료 기준 | 항목 세분화 | v3 체크리스트 표준화 |

---

## 17. 참고 문서
- GCX v5 프로토콜: `C:/Users/Nam/.gemini/GEMINI_v5.md`
- Claude Code 공식 문서: `C:/Users/Nam/Desktop/Workspace/learning-code/docs/claude/`
- v1/v2 문서 유지

# GCX v5 Claude Code 통합 구현 계획

## 📋 개요

GCX v5 프로토콜을 Claude Code의 Subagent, Skill, Hook 시스템과 통합하여 완전 자동화된 다중 AI 협업 워크플로우를 구축합니다.

**목표**: 사용자가 `/gcx-project "Task"` 한 번 입력으로 Gemini-Claude-Codex 6단계 파이프라인이 자동 실행되도록 구현

**특징**:
- ✅ MSYS2 UCRT64 Zsh 기준
- ✅ 한글 UTF-8 인코딩 완벽 지원
- ✅ 단계별 진행 상황 실시간 표기
- ✅ 체크포인트 기반 재개(Resume) 지원
- ✅ 파일 기반 핸드오프 (Windows 안정성)

---

## 🎯 전체 아키텍처

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
│ [Step 1/6] Requirement Capture → ✅        │
│ [Step 2/6] Plan Architect      → 🔄        │
│ [Step 3/6] TDD Generator       → ⏳        │
│ [Step 4/6] Implementation      → ⏳        │
│ [Step 5/6] QA Validator        → ⏳        │
│ [Step 6/6] Finalize Reporter   → ⏳        │
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

## 📦 구현할 컴포넌트

### 1. Subagents (6개)
| 이름 | 도구 | 역할 |
|------|------|------|
| `requirement-capture` | Read, Write, Bash | 요구사항 캡처 → `.gcx/00_requirements/` |
| `plan-architect` | Read, Glob, Grep | 아키텍처 설계 (read-only) |
| `tdd-generator` | Read, Write, Bash | Codex로 테스트 먼저 생성 |
| `implementation-executor` | All | 4-layer 구현 (Infra→BE→FE→Integration) |
| `qa-validator` | Read, Bash | Codex 보안 스캔 + 통합 테스트 |
| `finalize-reporter` | Read, Write, Bash | Gemini 최종 리포트 생성 |

### 2. Skills (2개)
| 이름 | 설명 |
|------|------|
| `gcx-project-v5` | 프로젝트 전체 워크플로우 (6단계 체인) |
| `gcx-query-v5` | 빠른 쿼리 해결 (debug/arch/fe/concept) |

### 3. Hooks (4개)
| 이벤트 | 스크립트 | 역할 |
|--------|----------|------|
| UserPromptSubmit | `user_prompt.py` | 요구사항 자동 저장 |
| PreToolUse | `pre_bash.py` | AI CLI 호출 전 환경 검증 |
| PostToolUse | `post_bash.py` | AI 출력 파싱 및 메트릭 로깅 |
| SubagentStop | `subagent_stop.py` | 체크포인트 저장 (resume용) |

### 4. Python 라이브러리 (8개 모듈)
| 모듈 | 역할 |
|------|------|
| `gcx_core.py` | Timestamp, UTF-8 정규화 |
| `environment.py` | MSYS2 UCRT64 Zsh 감지 |
| `validators.py` | TOML, 한글 UTF-8 검증 |
| `ai_invokers.py` | **Codex/Gemini/Claude CLI 래퍼** (핵심) |
| `parsers.py` | AI 출력 파싱 (코드블록, 보안 발견사항) |
| `requirement_capture.py` | 요구사항 문서 생성 |
| `formatters.py` | MD ↔ TOML ↔ JSON 변환 |
| `preflight.py` | 통합 사전 점검 |

---

## 🔨 단계별 구현 계획

### Phase 1: Python 라이브러리 기초 (Week 1)

#### Step 1.1: 핵심 유틸리티 모듈 작성
**파일**:
- `.claude/lib/__init__.py`
- `.claude/lib/gcx_core.py`
- `.claude/lib/environment.py`

**검증**:
```bash
python -c "from .gcx.lib.gcx_core import get_timestamp; print(get_timestamp())"
python -c "from .gcx.lib.environment import is_msys2_ucrt64; print(is_msys2_ucrt64())"
```

#### Step 1.2: AI Invoker 구현 (최우선)
**파일**:
- `.claude/lib/ai_invokers.py`

**기능**:
- `CodexInvoker.invoke(prompt, mode="generate", reasoning="high")`
- `ClaudeInvoker.invoke(prompt, model="sonnet")`
- `GeminiInvoker.invoke(prompt, mode="orchestrate")`
- 출력 UTF-8 인코딩 처리 (Windows MSYS2)
- 타임아웃 관리 (default: 300s)

**검증**:
```bash
python .claude/lib/test_ai_invoker.py
# Expected: Codex 호출 성공, 한글 출력 확인
```

#### Step 1.3: Validator 모듈
**파일**:
- `.claude/lib/validators.py`
- `.claude/lib/preflight.py`

**기능**:
- `EncodingValidator.validate_korean_utf8(text)`
- `TOMLValidator.validate_codex_config()`
- `PreflightChecker.check_all()` → 통합 검증

**검증**:
```bash
python .claude/cli/cli.py preflight --fix
# Expected: MSYS2 UCRT64 확인, Codex reasoning=high 확인
```

#### Step 1.4: Parser & Formatter
**파일**:
- `.claude/lib/parsers.py`
- `.claude/lib/formatters.py`

**기능**:
- `AIOutputParser.extract_code_blocks(output, language="typescript")`
- `AIOutputParser.parse_security_findings(output)`
- `FormatConverter.markdown_to_toml(md_file)`

**검증**:
```bash
python -c "from .gcx.lib.parsers import AIOutputParser; \
  parser = AIOutputParser(); \
  print(parser.extract_code_blocks('```python\nprint(1)\n```'))"
```



**v5 수정 코멘트**: .claude/lib/*은 정적 구성으로 v5에서는 .claude/ 하위(templates/ 또는 skills supporting files)로 이동해 관리한다.
### Phase 2: Subagent 정의 (Week 2)

#### Step 2.1: Subagent 1-2 (Requirement + Plan)
**파일**:
- `.claude/agents/requirement-capture.md`
- `.claude/agents/plan-architect.md`

**YAML Frontmatter 예시**:
```yaml
---
name: requirement-capture
description: Captures user requirements and saves to .gcx/00_requirements/
tools: [Read, Write, Bash]
model: inherit
---
```

**검증**:
```bash
# Claude에서 실행
/agents  # requirement-capture 존재 확인
```

#### Step 2.2: Subagent 3-4 (TDD + Implementation)
**파일**:
- `.claude/agents/tdd-generator.md`
- `.claude/agents/implementation-executor.md`

**implementation-executor 핵심 로직**:
```markdown
# Layer-by-Layer Implementation

## Layer 1: Infrastructure
1. Run Codex: `python .claude/lib/codex_invoke.py --mode infra ...`
2. Claude Quality Gate: Review infra code
3. If CRITICAL issues → Fix
4. Save to `.gcx/output/layer1_infra/`

## Layer 2-4: 동일 패턴 반복
```

**검증**:
- TDD subagent 단독 실행 → 테스트 파일 생성 확인
- Implementation subagent → 4개 레이어 출력 확인

#### Step 2.3: Subagent 5-6 (QA + Finalize)
**파일**:
- `.claude/agents/qa-validator.md`
- `.claude/agents/finalize-reporter.md`

**검증**:
- QA validator → 보안 리포트 `.gcx/qa/security_report_*.md` 생성
- Finalize reporter → 최종 리포트 한글 생성

### Phase 3: Skill 구현 (Week 2)

#### Step 3.1: gcx-project-v5 Skill
**파일**:
- `.claude/skills/gcx-project-v5/SKILL.md`
- `.claude/skills/gcx-project-v5/v5_protocol.md` (supporting file)

**SKILL.md 구조**:
```markdown
---
name: gcx-project-v5
description: GCX v5 프로젝트 워크플로우 - 사용자가 /gcx-project 입력 시 자동 실행
allowed-tools: Read, Write, Bash, Glob, Grep
---

# 실행 절차

## Step 0: 진행 상황 초기화
**Progress Tracker**:
```
[Step 1/6] Requirement Capture → ⏳ Starting...
[Step 2/6] Plan Architect      → ⏳ Pending
[Step 3/6] TDD Generator       → ⏳ Pending
[Step 4/6] Implementation      → ⏳ Pending
[Step 5/6] QA Validator        → ⏳ Pending
[Step 6/6] Finalize Reporter   → ⏳ Pending
```

## Step 1: Requirement Capture
1. Invoke `requirement-capture` subagent
2. Update progress: `[Step 1/6] ✅ Complete`
3. Export `$REQUIREMENT_FILE`

## Step 2-6: 순차 실행 (동일 패턴)
각 단계마다:
- 이전 단계 출력 파일 읽기
- Subagent 실행
- 진행 상황 업데이트
- 출력 파일 저장

## Final Output
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎉 GCX v5 프로젝트 완료!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ 요구사항: .gcx/00_requirements/req_20251219_143022.md
✅ 아키텍처: .gcx/plans/plan_20251219_143022.md
✅ 테스트: .gcx/tests/tests_20251219_143022.test.ts
✅ 구현: src/
✅ 보안 리포트: .gcx/qa/security_report_20251219_143022.md
✅ 최종 리포트: .gcx/reports/final_report_20251219_143022.md

📋 제안된 커밋 메시지:
---
feat: Build REST API with TDD and security audit

- Infrastructure setup (PostgreSQL, Redis)
- Backend API endpoints with authentication
- Frontend React components
- Integration tests with 85% coverage

Co-authored-by: Gemini (Orchestrator)
Co-authored-by: Claude Sonnet (Architect)
Co-authored-by: Codex GPT-5.1 (Implementation)
---

다음 단계:
  npm test          # 테스트 실행
  npm run build     # 빌드
  git add .
  git commit -F .gcx/commit_message.txt
```
```

**검증**:
```bash
# Claude에서
/gcx-project "Create a simple todo app"
# Expected: 6단계 진행 상황 표시, 최종 리포트 생성
```

#### Step 3.2: gcx-query-v5 Skill
**파일**:
- `.claude/skills/gcx-query-v5/SKILL.md`

**빠른 쿼리 라우팅**:
```
User: "TypeScript와 JavaScript의 차이점은?"
  → Type: concept
  → Pipeline: Claude (explain) → Codex (examples) → Gemini (summary)

User: "로그인 버그 수정해줘"
  → Type: debug
  → Pipeline: Codex (analyze) → Claude (verify) → Gemini (integrate)
```

**검증**:
```bash
/gcx-query "TypeScript와 JavaScript의 차이점은?"
# Expected: Type 자동 분류 → concept pipeline 실행
```

### Phase 4: Hook 시스템 (Week 3)

#### Step 4.1: Hook 스크립트 작성
**파일**:
- `.claude/hooks/user_prompt.py`
- `.claude/hooks/pre_bash.py`
- `.claude/hooks/post_bash.py`
- `.claude/hooks/subagent_stop.py`


**v5 수정 코멘트**: Hook 스크립트는 .claude/hooks/에 둔다.

**user_prompt.py 예시**:
```python
#!/usr/bin/env python3
import sys, json, os
from pathlib import Path

# Read stdin (JSON from Claude)
hook_input = json.load(sys.stdin)
user_message = hook_input.get("user_message", "")

# Check if GCX command
if "/gcx-" in user_message:
    timestamp = get_timestamp()
    req_file = f".gcx/00_requirements/req_{timestamp}.md"

    Path(req_file).parent.mkdir(parents=True, exist_ok=True)
    with open(req_file, "w", encoding="utf-8") as f:
        f.write(f"# User Request\n\n{user_message}\n\n**Timestamp**: {timestamp}\n")

    # Log to metrics
    log_metric("gcx_invocation", {"timestamp": timestamp, "command": user_message})

# Return success (no blocking)
print(json.dumps({"action": "proceed"}))
```

**검증**:
```bash
# Hook 테스트
echo '{"user_message": "/gcx-project test"}' | python .claude/hooks/user_prompt.py
# Expected: .gcx/00_requirements/req_*.md 생성
```

#### Step 4.2: settings.json 업데이트
**파일**: `.claude/settings.json`

```json
{
  "permissions": {"defaultMode": "default"},
  "outputStyle": "Korean-Explanatory",
  "alwaysThinkingEnabled": true,
  "hooks": {
    "UserPromptSubmit": "python C:/Users/Nam/Desktop/Workspace/learning-code/.claude/hooks/user_prompt.py",
    "PreToolUse": {
      "Bash": "python C:/Users/Nam/Desktop/Workspace/learning-code/.claude/hooks/pre_bash.py"
    },
    "PostToolUse": {
      "Bash": "python C:/Users/Nam/Desktop/Workspace/learning-code/.claude/hooks/post_bash.py"
    },
    "SubagentStop": "python C:/Users/Nam/Desktop/Workspace/learning-code/.claude/hooks/subagent_stop.py"
  }
}
```

**검증**:
```bash
# Claude 재시작 후
# 임의 메시지 입력 → UserPromptSubmit hook 실행 확인
cat .gcx/metrics/hooks.log  # Hook 실행 기록 확인
```

### Phase 5: 통합 테스트 (Week 4)

#### Step 5.1: End-to-End 테스트
**시나리오**:
```
1. Claude에서: /gcx-project "Build a REST API for user management"
2. Expected Flow:
   - [Step 1/6] ✅ Requirement captured
   - [Step 2/6] ✅ Architecture plan created
   - [Step 3/6] ✅ Tests generated (TDD)
   - [Step 4/6] ✅ Implementation complete
   - [Step 5/6] ✅ Security audit passed
   - [Step 6/6] ✅ Final report generated
3. Verify outputs:
   - .gcx/00_requirements/
   - .gcx/plans/
   - .gcx/tests/
   - src/
   - .gcx/qa/
   - .gcx/reports/
```

**검증 스크립트**: `.claude/tests/test_e2e_gcx_project.sh`
```bash
#!/usr/bin/env zsh
# End-to-end test for /gcx-project

echo "🧪 Testing GCX v5 Project Workflow..."

# 1. 요구사항 생성
REQ="Build a simple calculator API"

# 2. Skill 실행 (수동 트리거)
echo "$REQ" | claude --skill gcx-project-v5

# 3. 출력 검증
[[ -d .gcx/00_requirements ]] && echo "✅ Requirements"
[[ -d .gcx/plans ]] && echo "✅ Plans"
[[ -d .gcx/tests ]] && echo "✅ Tests"
[[ -d src ]] && echo "✅ Implementation"
[[ -d .gcx/qa ]] && echo "✅ QA"
[[ -d .gcx/reports ]] && echo "✅ Reports"

echo "🎉 E2E Test Complete"
```

#### Step 5.2: 성능 벤치마크
**메트릭**:
- 토큰 사용량 (vs v4 monolithic)
- 실행 시간 (6단계 총합)
- 한글 인코딩 실패율

**예상 결과**:
| 메트릭 | v4 | v5 | 개선 |
|--------|----|----|------|
| 토큰 | 200K | 87K | **56%** |
| 시간 | 7분 | 7.5분 | +0.5분 |
| 한글 성공률 | 95% | 100% | +5% |

#### Step 5.3: Rollback 테스트
**시나리오**: Step 3에서 실패 → Resume 기능 검증

```bash
# 1. 체크포인트 확인
cat .gcx/checkpoints/session_20251219_143022.json

# 2. Resume 실행
/gcx-resume 20251219_143022

# Expected: Step 3부터 재시작
```

---

## 📁 최종 파일 구조

`learning-code/
├── .claude/
│   ├── settings.json
│   ├── skills/
│   │   ├── gcx-project-v5/
│   │   │   ├── SKILL.md
│   │   │   └── v5_protocol.md
│   │   ├── gcx-query-v5/
│   │   │   └── SKILL.md
│   │   ├── gcx-preflight-v5/
│   │   │   └── SKILL.md
│   │   ├── gcx-status-v5/
│   │   │   └── SKILL.md
│   │   ├── gcx-resume-v5/
│   │   │   └── SKILL.md
│   │   └── gcx-cancel-v5/
│   │       └── SKILL.md
│   ├── agents/
│   │   ├── requirement-capture.md
│   │   ├── plan-architect.md
│   │   ├── tdd-generator.md
│   │   ├── implementation-executor.md
│   │   ├── qa-validator.md
│   │   ├── finalize-reporter.md
│   │   ├── context-guardian.md
│   │   ├── overengineering-reviewer.md
│   │   ├── test-runner.md
│   │   ├── doc-writer.md
│   │   └── dependency-auditor.md
│   ├── hooks/
│   │   ├── user_prompt.py
│   │   ├── pre_bash.py
│   │   ├── post_bash.py
│   │   ├── subagent_stop.py
│   │   ├── permission_guard.py
│   │   ├── preflight.py
│   │   ├── precompact_snapshot.py
│   │   └── stop_finalize.py
│   ├── lib/
│   │   ├── __init__.py
│   │   ├── gcx_core.py
│   │   ├── environment.py
│   │   ├── validators.py
│   │   ├── ai_invokers.py
│   │   ├── parsers.py
│   │   ├── requirement_capture.py
│   │   ├── formatters.py
│   │   └── preflight.py
│   ├── cli/
│   │   └── cli.py
│   ├── tests/
│   │   ├── test_ai_invoker.py
│   │   ├── test_encoding_validator.py
│   │   └── test_e2e_gcx_project.sh
│   └── templates/
│       ├── gcx_invoke_v5.zsh
│       ├── preflight_check_v5.zsh
│       └── pipeline_realtime_stream.zsh
├── .gcx/
│   ├── 00_requirements/
│   ├── 01_planning/
│   ├── 02_implementation/
│   │   └── tests/
│   ├── 03_verification/
│   ├── output/
│   ├── pipeline/
│   │   ├── logs/
│   │   │   └── <session_id>/
│   │   ├── pipe_gemini_claude
│   │   └── pipe_claude_codex
│   ├── state/
│   │   ├── project_context.json
│   │   ├── artifact_index.json
│   │   ├── checkpoints/
│   │   └── locks/
│   ├── schemas/
│   │   ├── baton.schema.json
│   │   └── result_block.schema.json
│   ├── review/
│   └── metrics/
└── CLAUDE.md``
learning-code/
├── .claude/
│   ├── settings.json                     # Hook 설정 추가
│   ├── skills/
│   │   ├── gcx-project-v5/
│   │   │   ├── SKILL.md                  # 프로젝트 워크플로우
│   │   │   └── v5_protocol.md            # Supporting file
│   │   └── gcx-query-v5/
│   │       └── SKILL.md                  # 쿼리 워크플로우
│   └── agents/
│       ├── requirement-capture.md        # Subagent 1
│       ├── plan-architect.md             # Subagent 2
│       ├── tdd-generator.md              # Subagent 3
│       ├── implementation-executor.md    # Subagent 4
│       ├── qa-validator.md               # Subagent 5
│       └── finalize-reporter.md          # Subagent 6
│
├── .gcx/
│   ├── lib/                              # Python 라이브러리
│   │   ├── __init__.py
│   │   ├── gcx_core.py                   # Timestamp, UTF-8
│   │   ├── environment.py                # MSYS2 감지
│   │   ├── validators.py                 # TOML, 한글 검증
│   │   ├── ai_invokers.py                # **핵심: Codex/Gemini/Claude**
│   │   ├── parsers.py                    # AI 출력 파싱
│   │   ├── requirement_capture.py        # 요구사항 문서화
│   │   ├── formatters.py                 # 포맷 변환
│   │   └── preflight.py                  # 통합 사전 점검
│   │
│   ├── hooks/                            # Hook 스크립트
│   │   ├── user_prompt.py                # UserPromptSubmit
│   │   ├── pre_bash.py                   # PreToolUse
│   │   ├── post_bash.py                  # PostToolUse
│   │   └── subagent_stop.py              # SubagentStop
│   │
│   ├── cli.py                            # 통합 CLI (preflight, invoke 등)
│   │
│   ├── tests/                            # 테스트
│   │   ├── test_ai_invoker.py
│   │   ├── test_encoding_validator.py
│   │   └── test_e2e_gcx_project.sh
│   │
│   ├── 00_requirements/                  # 요구사항 저장소
│   ├── plans/                            # 아키텍처 계획
│   ├── tests/                            # 생성된 테스트
│   ├── output/                           # 구현 결과
│   ├── qa/                               # 보안 리포트
│   ├── reports/                          # 최종 리포트
│   ├── checkpoints/                      # Resume용 체크포인트
│   └── metrics/                          # Hook 로깅
│
└── CLAUDE.md                             # 프로젝트 가이드 (기존)
```

---

## 🔑 주요 파일 및 핵심 내용

### 1. `.claude/lib/ai_invokers.py` (최우선 구현)
**역할**: Codex/Gemini/Claude CLI 표준화된 인터페이스

**핵심 코드**:
```python
class CodexInvoker:
    def invoke(self, prompt: str, mode: str = "generate",
               reasoning: str = "high", output_file: str = None) -> Dict:
        # UTF-8 인코딩 처리
        env = os.environ.copy()
        env["NO_COLOR"] = "1"
        env["LANG"] = "ko_KR.UTF-8"

        cmd = ["codex", "exec", "-m", "gpt-5.1-codex", prompt]
        result = subprocess.run(cmd, capture_output=True,
                                text=True, encoding="utf-8",
                                env=env, timeout=300)

        # 출력 파싱 (mode별)
        parsed = self._parse_output(result.stdout, mode)
        return {"success": result.returncode == 0,
                "output": result.stdout, "parsed": parsed}
```

### 2. `.claude/skills/gcx-project-v5/SKILL.md`
**역할**: 메인 진입점, 6단계 오케스트레이션

**핵심 로직**:
```markdown
## Execution Flow

1. Display initial progress tracker
2. For each stage (1-6):
   a. Update progress: [Step X/6] 🔄 In Progress
   b. Invoke subagent
   c. Verify output file created
   d. Update progress: [Step X/6] ✅ Complete
   e. Pass output file path to next stage
3. Generate final summary with file paths
4. Suggest commit message (never auto-commit)
```

### 3. `.claude/agents/implementation-executor.md`
**역할**: 가장 복잡한 Subagent (4-layer 구현)

**핵심 구조**:
```markdown
# Layer-by-Layer Implementation with Quality Gates

## Layer 1: Infrastructure
- Codex: Database schema, configs
- Claude Quality Gate: Review
- Save: .gcx/output/layer1_infra/

## Layer 2: Backend
- Codex: API endpoints, services
- Claude Quality Gate: Review
- Save: .gcx/output/layer2_backend/

## Layer 3: Frontend
- Codex: Components, pages
- **Gemini Design Review** (ABSOLUTE AUTHORITY)
- Claude: Code quality only
- Save: .gcx/output/layer3_frontend/

## Layer 4: Integration
- Codex: E2E tests, deployment
- Save: .gcx/output/layer4_integration/
```

### 4. `.claude/hooks/post_bash.py`
**역할**: AI 출력 자동 파싱 및 로깅

**핵심 로직**:
```python
def hook_post_bash(hook_input: dict):
    cmd = hook_input["tool_input"]["command"]

    # AI CLI 감지
    if "codex exec" in cmd:
        ai_type = "codex"
    elif "claude -p" in cmd:
        ai_type = "claude"
    elif "gemini" in cmd:
        ai_type = "gemini"
    else:
        return  # Not AI command

    # 출력 파싱
    output = hook_input.get("stdout", "")
    parsed = parse_ai_output(output, ai_type)

    # 메트릭 로깅
    log_metric("ai_invocation", {
        "ai_type": ai_type,
        "timestamp": get_timestamp(),
        "output_length": len(output),
        "has_korean": has_korean_chars(output)
    })

    # 보안 발견사항 저장 (Codex security scan인 경우)
    if "security" in cmd and ai_type == "codex":
        findings = extract_security_findings(output)
        save_security_report(findings)
```

### 5. `.claude/settings.json`
**역할**: Hook 활성화 설정

**핵심 변경**:
```json
{
  "hooks": {
    "UserPromptSubmit": "python C:/Users/Nam/Desktop/Workspace/learning-code/.claude/hooks/user_prompt.py",
    "PreToolUse": {
      "Bash": "python C:/Users/Nam/Desktop/Workspace/learning-code/.claude/hooks/pre_bash.py"
    },
    "PostToolUse": {
      "Bash": "python C:/Users/Nam/Desktop/Workspace/learning-code/.claude/hooks/post_bash.py"
    },
    "SubagentStop": "python C:/Users/Nam/Desktop/Workspace/learning-code/.claude/hooks/subagent_stop.py"
  }
}
```

---

## ✅ 검증 체크리스트

### Phase 1 완료 기준
- [ ] Python 라이브러리 8개 모듈 작성
- [ ] AI Invoker 테스트 통과 (한글 출력 확인)
- [ ] Preflight checker 실행 성공
- [ ] `python .claude/cli/cli.py --help` 동작

### Phase 2 완료 기준
- [ ] 6개 Subagent 정의 파일 작성
- [ ] `/agents` 명령어로 전체 Subagent 확인
- [ ] 각 Subagent 단독 테스트 성공

### Phase 3 완료 기준
- [ ] `gcx-project-v5` Skill 작성
- [ ] `gcx-query-v5` Skill 작성
- [ ] `/gcx-project "test"` 실행 → 6단계 진행 표시
- [ ] 최종 리포트 한글 생성 확인

### Phase 4 완료 기준
- [ ] 4개 Hook 스크립트 작성
- [ ] settings.json 업데이트
- [ ] Hook 단독 테스트 (echo | python hook.py)
- [ ] Claude 재시작 후 Hook 자동 실행 확인

### Phase 5 완료 기준
- [ ] E2E 테스트 스크립트 작성
- [ ] `/gcx-project` 전체 워크플로우 성공
- [ ] 토큰 사용량 벤치마크 (목표: <100K)
- [ ] Resume 기능 검증

---

## 🚀 다음 단계

구현 순서:
1. **Week 1**: Python 라이브러리 (특히 AI Invoker 우선)
2. **Week 2**: Subagent 정의 + Skill 구현
3. **Week 3**: Hook 시스템 통합
4. **Week 4**: 통합 테스트 및 최적화

각 주차마다 검증 체크리스트 확인하여 안정성 보장.

---

## 📝 참고 문서

- GCX v5 프로토콜: `C:/Users/Nam/.gemini/GEMINI_v5.md`
- Claude Code 공식 문서: `C:/Users/Nam/Desktop/Workspace/learning-code/docs/claude/`
- 기존 v4 스크립트: `C:/Users/Nam/Desktop/Workspace/learning-code/.claude/templates/` (참고용)

---

**구현 시작 시**: 각 Phase의 Step을 TodoWrite로 추적하여 진행 상황 실시간 표시
# v5 개선 통합 섹션 (원본 유지 + 개선안 추가)

## A. 구조 정정 (중요)
- `.claude/`는 **정적 구성(스킬/에이전트/훅/템플릿/스크립트)** 전용
- `.gcx/`는 **GCX 프로토콜 실행 중 생성되는 산출물/상태/로그** 전용

즉, **skills/agents/hooks는 반드시 `.claude/` 하위**에 위치한다.

---

## B. 파일 구조 개선안 (v5)
### B.1 개선된 최상위 구조 (권장)
```
learning-code/
├── .claude/
│   ├── settings.json                 # 훅 설정 (matcher 구조)
│   ├── skills/
│   │   ├── gcx-project-v5/
│   │   │   ├── SKILL.md
│   │   │   └── v5_protocol.md
│   │   ├── gcx-query-v5/
│   │   │   └── SKILL.md
│   │   ├── gcx-preflight-v5/
│   │   │   └── SKILL.md
│   │   ├── gcx-status-v5/
│   │   │   └── SKILL.md
│   │   ├── gcx-resume-v5/
│   │   │   └── SKILL.md
│   │   └── gcx-cancel-v5/
│   │       └── SKILL.md
│   ├── agents/
│   │   ├── requirement-capture.md
│   │   ├── plan-architect.md
│   │   ├── tdd-generator.md
│   │   ├── implementation-executor.md
│   │   ├── qa-validator.md
│   │   ├── finalize-reporter.md
│   │   ├── context-guardian.md
│   │   ├── overengineering-reviewer.md
│   │   ├── test-runner.md
│   │   ├── doc-writer.md
│   │   └── dependency-auditor.md
│   ├── hooks/
│   │   ├── user_prompt.py
│   │   ├── pre_bash.py
│   │   ├── post_bash.py
│   │   ├── subagent_stop.py
│   │   ├── permission_guard.py
│   │   ├── preflight.py
│   │   ├── precompact_snapshot.py
│   │   └── stop_finalize.py
│   └── templates/
│       ├── gcx_invoke_v5.zsh
│       ├── preflight_check_v5.zsh
│       └── pipeline_realtime_stream.zsh
│
├── .gcx/
│   ├── 00_requirements/
│   ├── 01_planning/
│   ├── 02_implementation/
│   │   ├── tests/
│   │   └── ...
│   ├── 03_verification/
│   ├── output/
│   ├── pipeline/
│   │   ├── logs/
│   │   │   └── <session_id>/
│   │   ├── pipe_gemini_claude
│   │   └── pipe_claude_codex
│   ├── state/
│   │   ├── project_context.json
│   │   ├── artifact_index.json
│   │   ├── checkpoints/
│   │   └── locks/
│   ├── schemas/
│   │   ├── baton.schema.json
│   │   └── result_block.schema.json
│   ├── review/
│   └── metrics/
└── CLAUDE.md
```

**v5 수정 코멘트**: 위 구조의 .gcx/lib, .gcx/hooks, .claude/cli/cli.py는 **정적 구성**이므로
v5 기준에서는 .claude/ 하위로 이동하여 관리한다.
.gcx/는 실행 중 생성되는 산출물/상태/로그만 보관한다.

### B.2 기존 구조에서의 정리 기준
- 기존 `.gcx/lib`, `.gcx/hooks`는 **`.claude/`로 이동**
- `.gcx/`에는 **생성물과 상태만 저장**

---

## C. Hook 위치 수정 (예시 포함)
### C.1 `.claude/settings.json` 예시 (matcher 구조)
```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {"type": "command", "command": "python .claude/hooks/user_prompt.py"}
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {"type": "command", "command": "python .claude/hooks/pre_bash.py"}
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {"type": "command", "command": "python .claude/hooks/post_bash.py"}
        ]
      }
    ],
    "SubagentStop": [
      {
        "matcher": "",
        "hooks": [
          {"type": "command", "command": "python .claude/hooks/subagent_stop.py"}
        ]
      }
    ]
  }
}
```

### C.2 Hook 추가 제안 (예시)
**SessionStart** (preflight 자동 실행)
```json
"SessionStart": [
  {"matcher": "", "hooks": [{"type": "command", "command": "python .claude/hooks/preflight.py"}]}
]
```

**PermissionRequest** (위험 작업 차단)
```json
"PermissionRequest": [
  {"matcher": "", "hooks": [{"type": "command", "command": "python .claude/hooks/permission_guard.py"}]}
]
```

**Stop** (정리/리포트 스텁)
```json
"Stop": [
  {"matcher": "", "hooks": [{"type": "command", "command": "python .claude/hooks/stop_finalize.py"}]}
]
```

---

## D. 신규 Skill 제안 (예시 포함)
### D.1 gcx-preflight-v5
````markdown
---
name: gcx-preflight-v5
description: Run GCX v5 preflight checks (Zsh/MSYS2/UTF-8/Codex config). Use before GCX pipeline.
allowed-tools: Bash, Read
---

# GCX v5 Preflight

## Command
```zsh
zsh .claude/templates/preflight_check_v5.zsh
```
````

### D.2 gcx-status-v5
````markdown
---
name: gcx-status-v5
description: Summarize GCX session status from .gcx/state/project_context.json.
allowed-tools: Read
---

# GCX Status

## Example
```bash
cat .gcx/state/project_context.json
```
````

### D.3 gcx-resume-v5
````markdown
---
name: gcx-resume-v5
description: Resume GCX pipeline from a checkpoint.
allowed-tools: Read, Bash
---

# GCX Resume

## Example
```bash
/gcx-resume 20251219_143022
```
````

### D.4 gcx-cancel-v5
````markdown
---
name: gcx-cancel-v5
description: Cancel GCX session and release lock file.
allowed-tools: Read, Write, Bash
---

# GCX Cancel

## Example
```bash
rm .gcx/state/locks/session_20251219_143022.lock
```
````

---

## E. 신규 Subagent 제안 (예시 포함)
### E.1 context-guardian
```markdown
---
name: context-guardian
description: Validate Context Baton and Result Block schema.
tools: Read, Bash
model: sonnet
permissionMode: default
---

You validate .gcx/state/project_context.json and ensure schema compliance.
If invalid, return an error block and halt pipeline.
```

### E.2 test-runner
```markdown
---
name: test-runner
description: Run tests after implementation and summarize failures.
tools: Bash, Read
model: sonnet
permissionMode: default
---

Run the appropriate test command, parse output, and summarize failures.
```

### E.3 dependency-auditor
```markdown
---
name: dependency-auditor
description: Audit dependencies for vulnerabilities and licenses.
tools: Bash, Read
model: sonnet
permissionMode: default
---

Run audit commands (npm/yarn/pip) and save results to .gcx/03_verification/.
```

---

## F. Context Baton/Result Block 스키마 예시
### F.1 Baton Schema (요약)
```json
{
  "type": "object",
  "required": ["version", "session_id", "status", "current_step"],
  "properties": {
    "version": {"type": "string"},
    "session_id": {"type": "string"},
    "status": {"type": "string"},
    "current_step": {"type": "integer"},
    "artifacts": {"type": "object"}
  }
}
```

### F.2 Result Block Schema (요약)
```json
{
  "type": "object",
  "required": ["result"],
  "properties": {
    "result": {
      "type": "object",
      "required": ["step", "status", "summary"],
      "properties": {
        "step": {"type": "integer"},
        "status": {"type": "string"},
        "summary": {"type": "string"},
        "artifacts": {"type": "object"}
      }
    }
  }
}
```

---

## G. 최종 적용 가이드
1. 원본 플랜은 유지하고, 본 섹션의 구조 규칙을 우선 적용
2. `.claude/` = 정적 구성, `.gcx/` = 실행 산출물/상태
3. 신규 Skill/Subagent/Hook은 단계별로 도입

---

**v5 통합본 작성 완료**








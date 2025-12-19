# GCX v5 Claude Code 통합 구현 계획 (v2.0)

## 📋 개요

GCX v5 프로토콜을 Claude Code의 Subagent, Skill, Hook 시스템과 통합하여 완전 자동화된 다중 AI 협업 워크플로우를 구축합니다.
**v2.0 변경점**: 컨텍스트 전달 프로토콜(JSON Baton) 강화, MSYS2/Windows 경로 정규화 전략 구체화, 에러 복구(Retry) 로직 추가.

**목표**: 사용자가 `/gcx-project "Task"` 한 번 입력으로 Gemini-Claude-Codex 6단계 파이프라인이 자동 실행되도록 구현

**특징**:
- ✅ **Cross-Platform Pathing**: Windows(`C:\`)와 MSYS2(`/c/`) 경로 자동 변환
- ✅ **Context Baton**: 단계별 상태와 아티팩트 위치를 추적하는 JSON 기반 컨텍스트 전달
- ✅ **Fault Tolerance**: AI 호출 실패 시 자동 재시도 및 로깅
- ✅ **Secure Hooks**: Stdin/Stdout 비동기 처리로 Hook 멈춤 현상 방지

---

## 🎯 전체 아키텍처 (Enhanced)

```
User: /gcx-project "Build REST API"
    ↓
┌─────────────────────────────────────────────┐
│ Skill: gcx-project-v5                       │
│ - Context Baton 생성 (project_context.json) │
│ - 6단계 Subagent 체인 오케스트레이션        │
│ - Progress TUI (Text UI) 표시               │
└─────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────┐
│ Subagent Chain (Context Baton Handover)     │
│ [Step 1] Req Capture → Update Baton → ✅    │
│ [Step 2] Architect   → Update Baton → 🔄    │
│ [Step 3] TDD Gen     → Update Baton → ⏳    │
│ [Step 4] Implementation (Layered)   → ⏳    │
│ [Step 5] QA Validator               → ⏳    │
│ [Step 6] Finalize Reporter          → ⏳    │
└─────────────────────────────────────────────┘
    ↓
Hooks (Python Wrappers):
  - UserPromptSubmit → 요구사항 자동 캡처 & Baton 초기화
  - PreToolUse → 경로 정규화 & 환경 검증
  - PostToolUse → AI 출력 파싱, Baton 업데이트, 메트릭
  - SubagentStop → 체크포인트 자동 저장 (JSON Dump)
```

---

## 📦 구현할 컴포넌트 (v2.0 업데이트)

### 1. Subagents (6개 - 역할 유지)
| 이름 | 도구 | Input | Output |
|------|------|-------|--------|
| `requirement-capture` | Read, Write, Bash | User Prompt | `req_*.md`, Baton Update |
| `plan-architect` | Read, Glob, Grep | `req_*.md` | `plan_*.md`, Baton Update |
| `tdd-generator` | Read, Write, Bash | `plan_*.md` | `test_*.ts`, Baton Update |
| `implementation-executor` | All | `plan_*.md`, `test_*.ts` | `src/`, Baton Update |
| `qa-validator` | Read, Bash | `src/` | `security_*.md`, Baton Update |
| `finalize-reporter` | Read, Write, Bash | All Artifacts | `report_*.md` |

### 2. Python 라이브러리 (강화됨)

| 모듈 | 역할 | v2.0 추가 사항 |
|------|------|----------------|
| `gcx_core.py` | Core Utils | `PathNormalizer` (Win↔Unix 변환) |
| `context_manager.py` | **New** | Context Baton(JSON) 로드/저장/검증 |
| `ai_invokers.py` | AI Wrapper | `RetryStrategy` (Exponential Backoff) |
| `environment.py` | Env Check | Python Path 감지 (`sys.executable`) |
| `validators.py` | Validation | Baton Schema 검증 |
| `parsers.py` | Output Parsing | Token Limit Truncation (요약 처리) |
| `formatters.py` | Conversion | - |
| `preflight.py` | Check | Path Mapping 점검 추가 |

---

## 🔑 Key Concepts: v2.0 핵심 기술

### 1. Context Baton Protocol (`project_context.json`)
단순 파일 전달이 아닌, 프로젝트의 전체 상태를 담은 JSON 객체를 관리합니다.

```json
{
  "project_id": "proj_20251219_1430",
  "status": "in_progress",
  "current_step": 3,
  "artifacts": {
    "requirements": ".gcx/00_requirements/req_20251219.md",
    "architecture": ".gcx/plans/plan_20251219.md",
    "tests": ".gcx/tests/test_20251219.ts",
    "source_dir": "src/"
  },
  "metrics": {
    "start_time": 1734586200,
    "step_durations": {"step1": 45, "step2": 120}
  },
  "errors": []
}
```

### 2. Path Normalization (경로 정규화)
MSYS2 Bash와 Windows PowerShell, Python 간의 경로 충돌을 방지합니다.

```python
# .gcx/lib/gcx_core.py
class PathNormalizer:
    @staticmethod
    def to_unix(path_str):
        # C:\Users\Nam -> /c/Users/Nam
        return subprocess.check_output(["cygpath", "-u", path_str]).strip()

    @staticmethod
    def to_windows(path_str):
        # /c/Users/Nam -> C:\Users\Nam
        return subprocess.check_output(["cygpath", "-w", path_str]).strip()
```

---

## 🔨 단계별 구현 계획 (Refined)

### Phase 1: Core Lib & Context Manager (Week 1)

#### Step 1.1: Context Manager 구현
**파일**: `.gcx/lib/context_manager.py`
**기능**:
- `load_context(path)`: JSON 로드 및 스키마 검증
- `update_artifact(key, path)`: 아티팩트 경로 등록 (자동 경로 정규화)
- `save_checkpoint()`: 안전한 쓰기 (Atomic Write)

#### Step 1.2: Path Normalizer & AI Invoker
**파일**: `.gcx/lib/gcx_core.py`, `.gcx/lib/ai_invokers.py`
**개선**:
- `ai_invokers.py`에 `max_retries=3` 로직 추가.
- API 타임아웃/에러 발생 시 즉시 실패하지 않고 2초, 4초 대기 후 재시도.

### Phase 2: Skill & Subagent with Baton (Week 2)

#### Step 2.1: Skill 로직 변경 (`gcx-project-v5`)
**SKILL.md**:
```markdown
# Execution
1. Initialize `project_context.json`
2. Loop Steps 1 to 6:
   a. Load Context
   b. Invoke Subagent (passing context file path)
   c. Subagent reads context -> performs task -> updates context
   d. Refresh Context from file
   e. Update Progress UI
```

#### Step 2.2: Subagent 프롬프트 최적화
각 Subagent의 시스템 프롬프트에 다음 지침 추가:
> "작업 완료 후 반드시 `.gcx/lib/context_manager.py`를 사용하여 아티팩트 경로를 업데이트하시오."

### Phase 3: Robust Hooks (Week 3)

#### Step 3.1: Hook 입출력 격리
Claude Code의 Hook은 표준 입출력(stdio)을 사용하므로, Python 스크립트에서 불필요한 `print()`가 JSON 파싱을 깨뜨리지 않도록 `stderr`로 로그를 돌립니다.

**user_prompt.py**:
```python
import sys, json

# 로그는 stderr로
print("DEBUG: Starting hook...", file=sys.stderr)

try:
    input_data = json.load(sys.stdin)
    # ... logic ...
    print(json.dumps({"action": "proceed"})) # 유일한 stdout
except Exception as e:
    print(json.dumps({"action": "proceed"}), file=sys.stdout) # Fail-safe
```

### Phase 4: Integration & Security (Week 4)

#### Step 4.1: Settings & Permissions
**settings.json**:
```json
{
  "approvedTools": ["read_file", "write_file", "run_shell_command"],
  "hooks": {
    "UserPromptSubmit": "python -u .gcx/hooks/user_prompt.py", 
    "PreToolUse": {
      "Bash": "python -u .gcx/hooks/pre_bash.py"
    }
  }
}
```
*Note: `python -u` (unbuffered) 옵션 사용하여 파이프 병목 방지.*

---

## ✅ 검증 체크리스트 (v2.0)

- [ ] **Context Baton**: JSON 파일이 단계별로 올바르게 업데이트되는가?
- [ ] **Path Safety**: MSYS2(`/c/...`) 경로가 Windows Python에서 오류 없이 열리는가?
- [ ] **Retry Logic**: 인터넷 연결 해제 시뮬레이션 시 AI Invoker가 재시도하는가?
- [ ] **Hook Stability**: Hook 스크립트 에러가 발생해도 Claude 자체가 멈추지 않는가? (Fail-safe)
- [ ] **Encoding**: 한글 출력이 깨지지 않고 최종 리포트에 담기는가?

---

## 🚀 시작 가이드

1. **라이브러리 설치**:
   ```bash
   pip install toml  # 필요한 경우
   ```
2. **Preflight Check**:
   ```bash
   python .gcx/cli.py preflight --v2
   ```
3. **Run Project**:
   ```bash
   /gcx-project "Create a distinct color palette generator"
   ```
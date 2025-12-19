# GCX v6 Claude Code Integration Plan

## 📋 개요

GCX v6 프로토콜을 Claude Code의 Subagent, Skill, Hook 시스템과 통합하여 완전 자동화된 다중 AI 협업 워크플로우를 구축합니다.
**v6 주요 변경점**: **완벽한 Zsh Native 지원**, **정적/동적 자산의 엄격한 분리**, **경로 정규화 사전 검증(Cygpath)**, **Gemini 디자인 권한 명시**.

**목표**: 사용자가 `/gcx-project "Task"` 한 번 입력으로 Gemini-Claude-Codex 6단계 파이프라인이 자동 실행되도록 구현

**특징**:
- ✅ **Zsh Native**: 모든 쉘 스크립트는 `.zsh` 확장자와 문법을 따름
- ✅ **Static/Dynamic Separation**: 설정/로직(`.claude/`)과 산출물(`.gcx/`) 분리
- ✅ **Path Safety**: `cygpath` 필수 확인 및 경로 정규화
- ✅ **Gemini Authority**: UI/UX 디자인에 대한 Gemini의 절대적 권한 명시

---

## 🎯 전체 아키텍처

```
User: /gcx-project "Build REST API"
    ↓
┌─────────────────────────────────────────────┐
│ Skill: gcx-project-v6                       │
│ - v6 프로토콜 로드 (progressive disclosure) │
│ - 6단계 Subagent 체인 오케스트레이션        │
│ - 진행 상황 실시간 표시 (Zsh TUI)           │
└─────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────┐
│ Subagent Chain (Context Baton Handover)     │
│ [Step 1/6] Requirement Capture → ✅        │
│ [Step 2/6] Plan Architect      → 🔄        │
│ [Step 3/6] TDD Generator       → ⏳        │
│ [Step 4/6] Implementation      → ⏳        │
│ [Step 5/6] QA Validator        → ⏳        │
│ [Step 6/6] Finalize Reporter   → ⏳        │
└─────────────────────────────────────────────┘
    ↓
Hooks (Python Wrappers):
  - UserPromptSubmit → 요구사항 자동 캡처 & Baton 초기화
  - PreToolUse (Bash/run_shell_command) → 환경 검증 (MSYS2, Locale, Cygpath)
  - PostToolUse (Bash/run_shell_command) → AI 출력 파싱, Baton 업데이트
  - SubagentStop → 체크포인트 자동 저장 (JSON Dump)
    ↓
Final Report (Korean) + Commit Suggestion
```

---

## 📦 디렉토리 구조 (Final Truth)

```
learning-code/
├── .claude/                          # [STATIC] 설정, 템플릿, 로직
│   ├── settings.json                 # Hook 설정 (matcher 구조)
│   ├── skills/
│   │   ├── gcx-project-v6/
│   │   │   ├── SKILL.md
│   │   │   └── v6_protocol.md
│   │   ├── gcx-query-v6/
│   │   │   └── SKILL.md
│   │   ├── gcx-preflight-v6/
│   │   │   └── SKILL.md
│   │   ├── gcx-status-v6/
│   │   │   └── SKILL.md
│   │   ├── gcx-resume-v6/
│   │   │   └── SKILL.md
│   │   └── gcx-cancel-v6/
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
│   │   ├── gcx_core.py               # PathNormalizer (cygpath)
│   │   ├── context_manager.py        # Baton Protocol
│   │   ├── environment.py            # MSYS2/Zsh 감지
│   │   ├── validators.py
│   │   ├── ai_invokers.py            # Retry Logic
│   │   ├── parsers.py
│   │   ├── requirement_capture.py
│   │   ├── formatters.py
│   │   └── preflight.py
│   ├── cli/
│   │   └── cli.py
│   └── templates/
│       ├── gcx_invoke_v6.zsh
│       ├── preflight_check_v6.zsh
│       └── pipeline_realtime_stream.zsh
│
├── .gcx/                             # [DYNAMIC] 산출물, 상태, 로그
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
│   │   ├── project_context.json      # Context Baton
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

---

## 🔨 단계별 구현 계획

### Phase 1: Python 라이브러리 기초 (Week 1)

#### Step 1.1: 핵심 유틸리티 및 경로 정규화
**파일**: `.claude/lib/gcx_core.py`
**기능**:
- `PathNormalizer`: `cygpath -u` (Win→Unix), `cygpath -w` (Unix→Win) 필수 구현.
- `Preflight`: `cygpath` 명령어 존재 여부 확인 로직 추가.

```python
# .claude/lib/gcx_core.py (Snippet)
import subprocess

class PathNormalizer:
    @staticmethod
    def check_cygpath():
        try:
            subprocess.run(["cygpath", "--version"], capture_output=True, check=True)
            return True
        except (FileNotFoundError, subprocess.CalledProcessError):
            return False
            
    # ... to_unix, to_windows methods ...
```

#### Step 1.2: AI Invoker (Retry Logic)
**파일**: `.claude/lib/ai_invokers.py`
**기능**:
- `CodexInvoker`, `ClaudeInvoker`, `GeminiInvoker`
- `RetryStrategy`: API 타임아웃 시 2초, 4초 대기 후 재시도 (Exponential Backoff).

#### Step 1.3: Context Manager
**파일**: `.claude/lib/context_manager.py`
**기능**:
- `project_context.json` 로드/저장.
- 스키마 검증 (`.gcx/schemas/baton.schema.json` 참조).

### Phase 2: Subagent 정의 (Week 2)

#### Step 2.1: Gemini 권한 명시 (`implementation-executor.md`)
**파일**: `.claude/agents/implementation-executor.md`

```markdown
# Layer 3: Frontend Implementation
- **Gemini Design Review (ABSOLUTE AUTHORITY)**:
    - You MUST invoke Gemini to review the visual design, layout, and user experience.
    - Claude/Codex opinions on aesthetics are VOID. Only technical code quality matters.
    - If Gemini requests a design change, it is MANDATORY.
```

#### Step 2.2: Subagent 1-6 정의
모든 Subagent는 작업 완료 후 `.claude/lib/context_manager.py`를 호출하여 상태를 업데이트해야 함.

### Phase 3: Skill & Zsh Templates (Week 2)

#### Step 3.1: Zsh Templates
**파일**: `.claude/templates/gcx_invoke_v6.zsh`
**내용**:
- `#!/usr/bin/env zsh` Shebang 필수.
- Associative Arrays 사용.
- UTF-8 환경 변수 설정.

#### Step 3.2: Skills
`gcx-project-v6`, `gcx-preflight-v6` 등 상기 디렉토리 구조에 맞춰 생성.

### Phase 4: Hook 시스템 (Week 3)

#### Step 4.1: Settings 업데이트 (Matcher 구조)
**파일**: `.claude/settings.json`
**주의**: 도구 이름 `Bash`는 내부적으로 `run_shell_command`를 포함할 수 있음.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash", 
        "hooks": [{"type": "command", "command": "python .claude/hooks/pre_bash.py"}]
      },
      {
        "matcher": "run_shell_command",
        "hooks": [{"type": "command", "command": "python .claude/hooks/pre_bash.py"}]
      }
    ]
    // ... other hooks
  }
}
```

### Phase 5: 통합 테스트 (Week 4)

#### Step 5.1: E2E Test (Zsh)
**파일**: `.claude/tests/test_e2e_gcx_project.zsh`
**검증**:
- `cygpath` 동작 확인.
- 한글 입출력 깨짐 없음 확인.
- Context Baton 업데이트 확인.
- 최종 리포트 생성 확인.

---

## ✅ 검증 체크리스트 (v6)

- [ ] **Zsh Native**: 모든 쉘 스크립트가 `.zsh`이며 `#!/usr/bin/env zsh`로 시작하는가?
- [ ] **Path Safety**: `cygpath`가 없는 환경에서 명확한 에러 메시지를 띄우는가?
- [ ] **Static/Dynamic**: `.claude/`에는 코드만, `.gcx/`에는 데이터만 저장되는가?
- [ ] **Gemini Authority**: 프론트엔드 구현 시 Gemini의 디자인 리뷰 절차가 강제되는가?
- [ ] **Hook Stability**: `run_shell_command`와 `Bash` 모두에 대해 Hook이 정상 작동하는가?

---

## 🚀 시작 가이드

1. **Preflight Check (v6)**:
   ```zsh
   zsh .claude/templates/preflight_check_v6.zsh
   ```
2. **Library Implementation**:
   ```bash
   # Create directory structure first
   mkdir -p .claude/{lib,hooks,agents,skills,templates,tests,cli}
   mkdir -p .gcx/{state,output,pipeline,logs}
   ```
3. **Run Project**:
   ```bash
   /gcx-project-v6 "Create a modern dashboard"
   ```
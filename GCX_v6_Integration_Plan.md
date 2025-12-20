# GCX v6.1 Claude Code Integration Plan (Updated)

## 📋 개요

GCX v6 프로토콜을 Claude Code의 Subagent, Skill, Hook 시스템과 통합하여 완전 자동화된 다중 AI 협업 워크플로우를 구축합니다.
**v6.1 주요 변경점**: **완벽한 Zsh Native 지원**, **정적/동적 자산의 엄격한 분리**, **경로 정규화 사전 검증(Cygpath)**, **Gemini 디자인 권한 명시**, **모델 설정 분리**.

**목표**: 사용자가 `/gcx-project "Task"` 한 번 입력으로 Gemini-Claude-Codex 6단계 파이프라인이 자동 실행되도록 구현

**특징**:

- ✅ **Zsh Native**: 기본 셸은 `zsh`, 차선책은 `bash` (settings.json에서 설정)
- ✅ **Static/Dynamic Separation**: 설정/로직(`.claude/`)과 산출물(`.gcx/`) 분리
- ✅ **Path Safety**: `cygpath` 필수 확인 및 경로 정규화
- ✅ **Gemini Authority**: UI/UX 디자인에 대한 Gemini의 절대적 권한 명시
- ✅ **Model Config Separation**: AI 모델 버전을 별도 설정 파일로 분리 (사용자 업데이트 용이)

---

## 🖥️ 터미널 설정 (Shell Configuration)

### 기본 셸 우선순위

1. **zsh** (기본): MSYS2 UCRT64 환경의 Zsh 사용
2. **bash** (차선): Zsh 사용 불가 시 Bash로 폴백

### settings.json 터미널 설정

```json
{
  "terminal": {
    "shell": {
      "default": "zsh",
      "fallback": "bash",
      "path": {
        "zsh": "/usr/bin/zsh",
        "bash": "/usr/bin/bash"
      }
    },
    "encoding": "UTF-8",
    "locale": "ko_KR.UTF-8"
  }
}
```

### Zsh 감지 및 폴백 로직

```python
# .claude/lib/environment.py
import shutil

def get_shell():
    """Zsh 우선, Bash 차선 셸 반환"""
    zsh_path = shutil.which("zsh")
    if zsh_path:
        return zsh_path, "zsh"

    bash_path = shutil.which("bash")
    if bash_path:
        print("⚠️ Zsh 미설치 - Bash로 폴백합니다.")
        return bash_path, "bash"

    raise EnvironmentError("❌ Zsh 또는 Bash가 설치되어 있지 않습니다.")
```

---

## 🤖 모델 설정 분리 (Model Configuration)

### 모델 설정 파일

**파일**: `.claude/config/models.json`

사용자가 최신 모델로 쉽게 업데이트할 수 있도록 AI 모델 버전을 별도 파일로 분리합니다.

```json
{
  "$schema": "./.gcx/schemas/models.schema.json",
  "version": "1.0.0",
  "lastUpdated": "2025-12-19",

  "models": {
    "claude": {
      "default": "claude-sonnet-4-20250514",
      "planning": "claude-opus-4-5-20251101",
      "quick": "claude-3-5-haiku-20241022",
      "alias": {
        "sonnet": "claude-sonnet-4-20250514",
        "opus": "claude-opus-4-5-20251101",
        "haiku": "claude-3-5-haiku-20241022"
      }
    },
    "codex": {
      "default": "codex-1",
      "reasoning": "o3",
      "quick": "gpt-4.1-mini",
      "alias": {
        "max": "codex-1",
        "standard": "o4-mini"
      }
    },
    "gemini": {
      "default": "gemini-2.5-pro",
      "design": "gemini-2.5-pro",
      "quick": "gemini-2.5-flash",
      "alias": {
        "pro": "gemini-2.5-pro",
        "flash": "gemini-2.5-flash"
      }
    }
  },

  "taskMapping": {
    "requirement-capture": {
      "primary": "gemini.default",
      "fallback": "claude.default"
    },
    "plan-architect": {
      "primary": "claude.planning",
      "fallback": "gemini.default"
    },
    "tdd-generator": {
      "primary": "codex.default",
      "fallback": "claude.default"
    },
    "implementation": {
      "primary": "codex.default",
      "fallback": "claude.default"
    },
    "design-review": { "primary": "gemini.design", "fallback": null },
    "qa-validator": {
      "primary": "codex.reasoning",
      "fallback": "claude.default"
    },
    "finalize-reporter": {
      "primary": "gemini.default",
      "fallback": "claude.default"
    }
  }
}
```

### 모델 설정 로더

```python
# .claude/lib/model_config.py
import json
from pathlib import Path
from typing import Optional, Tuple

class ModelConfig:
    _config = None
    CONFIG_PATH = Path(__file__).parent.parent / "config" / "models.json"

    @classmethod
    def load(cls, force_reload: bool = False) -> dict:
        """모델 설정 로드 (Singleton)"""
        if cls._config is None or force_reload:
            with open(cls.CONFIG_PATH, "r", encoding="utf-8") as f:
                cls._config = json.load(f)
        return cls._config

    @classmethod
    def get_model(cls, ai_type: str, purpose: str = "default") -> str:
        """AI 타입과 용도에 따른 모델 반환"""
        config = cls.load()
        models = config.get("models", {})
        if ai_type not in models:
            raise ValueError(f"Unknown AI type: {ai_type}")
        ai_config = models[ai_type]
        if purpose in ai_config.get("alias", {}):
            return ai_config["alias"][purpose]
        return ai_config.get(purpose, ai_config["default"])

    @classmethod
    def get_task_model(cls, task_name: str) -> Tuple[str, Optional[str]]:
        """태스크에 매핑된 모델 반환 (primary, fallback)"""
        config = cls.load()
        mapping = config.get("taskMapping", {}).get(task_name, {})
        primary = mapping.get("primary", "claude.default")
        fallback = mapping.get("fallback")
        ai_type, purpose = primary.split(".")
        primary_model = cls.get_model(ai_type, purpose)
        fallback_model = None
        if fallback:
            fb_type, fb_purpose = fallback.split(".")
            fallback_model = cls.get_model(fb_type, fb_purpose)
        return primary_model, fallback_model
```

### 모델 업데이트 방법

사용자는 `.claude/config/models.json` 파일만 수정하면 됩니다.

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
│   ├── settings.json                 # Hook 설정 (matcher 구조) + 터미널 설정
│   ├── config/
│   │   └── models.json               # [NEW] AI 모델 설정 (분리됨)
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
│   │   └── ...
│   ├── hooks/
│   │   ├── user_prompt.py
│   │   ├── pre_bash.py
│   │   ├── post_bash.py
│   │   ├── subagent_stop.py
│   │   └── ...
│   ├── lib/
│   │   ├── __init__.py
│   │   ├── gcx_core.py               # PathNormalizer (cygpath)
│   │   ├── model_config.py           # [NEW] 모델 설정 로더
│   │   ├── context_manager.py        # Baton Protocol
│   │   ├── environment.py            # MSYS2/Zsh 감지 + 셸 폴백
│   │   ├── ai_invokers.py            # Retry Logic (ModelConfig 연동)
│   │   └── ...
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
│   ├── 03_verification/
│   ├── output/
│   ├── pipeline/
│   ├── state/
│   │   ├── project_context.json      # Context Baton
│   │   └── ...
│   ├── schemas/
│   │   ├── baton.schema.json
│   │   ├── result_block.schema.json
│   │   └── models.schema.json        # [NEW] 모델 설정 스키마
│   ├── review/
│   └── metrics/
└── CLAUDE.md
```

---

## 🔨 단계별 구현 계획

### Phase 2: Subagent 정의 (Week 2)

#### Step 2.1: Subagent Frontmatter 표준 (Claude 공식 문서 준수)

**파일**: `.claude/agents/*.md`

모든 Subagent는 다음 YAML frontmatter 형식을 따릅니다:

```yaml
---
name: requirement-capture
description: 사용자 요구사항을 캡처하고 .gcx/00_requirements/에 저장합니다. 프로젝트 시작 시 자동 사용됩니다.
tools: Read, Write, Bash, Glob
model: inherit
permissionMode: default
skills: gcx-preflight-v6
---
# Requirement Capture Agent
```

#### Step 2.2: Gemini 권한 명시 (`implementation-executor.md`)

```yaml
---
name: implementation-executor
description: 4-layer 구현을 수행합니다 (Infra→BE→FE→Integration). Frontend 레이어에서 Gemini 디자인 리뷰는 필수입니다.
tools: Read, Write, Edit, Bash, Glob, Grep
model: inherit
permissionMode: acceptEdits
---

# Implementation Executor Agent

## Layer 3: Frontend Implementation
- **Gemini Design Review (ABSOLUTE AUTHORITY)**:
    - You MUST invoke Gemini to review the visual design, layout, and user experience.
    - Claude/Codex opinions on aesthetics are VOID. Only technical code quality matters.
    - If Gemini requests a design change, it is MANDATORY.
```

### Phase 3: Skill Frontmatter 표준 (Claude 공식 문서 준수)

**파일**: `.claude/skills/gcx-project-v6/SKILL.md`

```yaml
---
name: gcx-project-v6
description: GCX v6 프로젝트 전체 워크플로우. /gcx-project 입력 시 6단계 Gemini-Claude-Codex 파이프라인을 자동 실행합니다.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task
---
# GCX Project v6
```

### Phase 4: Hook 시스템 (Week 3)

#### Step 4.1: Settings 업데이트 (Matcher 구조 + 터미널 설정)

**파일**: `.claude/settings.json`

**중요**:

- Hook 경로는 `$CLAUDE_PROJECT_DIR` 환경변수 사용 권장 (공식 문서 준수).

```json
{
  "terminal": {
    "shell": {
      "default": "zsh",
      "fallback": "bash"
    },
    "encoding": "UTF-8",
    "locale": "ko_KR.UTF-8"
  },
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "python \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/user_prompt.py"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/pre_bash.py"
          }
        ]
      },
      {
        "matcher": "run_shell_command",
        "hooks": [
          {
            "type": "command",
            "command": "python \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/pre_bash.py"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash|run_shell_command",
        "hooks": [
          {
            "type": "command",
            "command": "python \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/post_bash.py"
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "python \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/subagent_stop.py"
          }
        ]
      }
    ]
  }
}
```

---

## ✅ 검증 체크리스트 (v6.1)

### 기본 요구사항

- [ ] **Zsh Native**: 모든 쉘 스크립트가 `.zsh`이며 `#!/usr/bin/env zsh`로 시작하는가?
- [ ] **Bash Fallback**: Zsh 미설치 환경에서 Bash로 정상 폴백되는가?
- [ ] **Path Safety**: `cygpath`가 없는 환경에서 명확한 에러 메시지를 띄우는가?
- [ ] **Static/Dynamic**: `.claude/`에는 코드만, `.gcx/`에는 데이터만 저장되는가?

### AI 모델 설정

- [ ] **Model Config**: `.claude/config/models.json` 파일이 정상 로드되는가?
- [ ] **Task Mapping**: 각 태스크에 올바른 모델이 매핑되는가?
- [ ] **Model Update**: 사용자가 models.json만 수정해서 모델 변경이 가능한가?

### 통합 테스트

- [ ] **Gemini Authority**: 프론트엔드 구현 시 Gemini의 디자인 리뷰 절차가 강제되는가?
- [ ] **Hook Stability**: `run_shell_command`와 `Bash` 모두에 대해 Hook이 정상 작동하는가?
- [ ] **Subagent Chain**: 6단계 파이프라인이 순차적으로 실행되는가?
- [ ] **Context Baton**: 각 단계 간 Context가 올바르게 전달되는가?

---

## 🚀 시작 가이드

1. **Preflight Check (v6)**:
   ```zsh
   zsh .claude/templates/preflight_check_v6.zsh
   ```
2. **Library Implementation**:
   ```bash
   mkdir -p .claude/{lib,hooks,agents,skills,templates,tests,cli,config}
   mkdir -p .gcx/{state,output,pipeline,logs,schemas}
   ```
3. **Model Configuration**:
   ```bash
   # 모델 설정 파일 생성 후 필요시 모델 버전 수정
   ```
4. **Run Project**:
   ```bash
   /gcx-project-v6 "Create a modern dashboard"
   ```

---

## 📝 변경 이력

| 버전 | 날짜       | 변경 내용                                                            |
| ---- | ---------- | -------------------------------------------------------------------- |
| v6.2 | 2025-12-20 | 스키마 체계 완성 (result_block, phase_output, ai_exchange, request_batch) |
| v6.2 | 2025-12-20 | Hook Windows 호환성 수정 (Python 내부 환경변수 처리)                 |
| v6.1 | 2025-12-19 | 터미널 설정 섹션 추가 (zsh 기본, bash 차선)                          |
| v6.1 | 2025-12-19 | 모델 설정 분리 섹션 추가 (models.json)                               |
| v6.1 | 2025-12-19 | Hook 경로를 $CLAUDE_PROJECT_DIR 사용으로 변경                        |
| v6.1 | 2025-12-19 | Subagent/Skill frontmatter 예시를 Claude 공식 문서 형식으로 업데이트 |
| v6.0 | 2025-12-18 | 초기 v6 통합 계획 (Gemini/Codex 피드백 반영)                         |

---

## 🚀 구현 진행 상황

### 완료 항목 (2025-12-19 22:00 KST)

#### ✅ Phase 1: 디렉토리 구조 및 설정
- [x] `.claude/` 및 `.gcx/` 디렉토리 구조 생성
  - `.claude/{lib,hooks,agents,skills,templates,tests,cli,config}`
  - `.gcx/{state,schemas,metrics}`
- [x] 기존 라이브러리 파일 마이그레이션 (`.gcx/lib/` → `.claude/lib/`)
  - `gcx_core.py`
  - `environment.py`
  - `ai_invokers.py`
  - `__init__.py`

#### ✅ Phase 2: 모델 설정 시스템
- [x] `.claude/config/models.json` 생성
  - Claude, Codex, Gemini 모델 정의
  - Task별 모델 매핑 설정
- [x] `.claude/lib/model_config.py` 구현
  - Singleton 패턴 적용
  - 모델 조회 API (`get_model`, `get_task_model`)
  - 설정 검증 기능

#### ✅ Phase 3: Context Manager
- [x] `.claude/lib/context_manager.py` 구현
  - `ContextBaton` 데이터 클래스
  - `BatonMetadata`, `PhaseResult` 구조
  - `BatonManager` (CRUD 기능)
  - 체크포인트 시스템

#### ✅ Phase 4: Hook 시스템
- [x] `.claude/hooks/user_prompt.py` - 사용자 프롬프트 제출 Hook
- [x] `.claude/hooks/pre_bash.py` - Bash 실행 전 검증 Hook
- [x] `.claude/hooks/post_bash.py` - Bash 실행 후 파싱 Hook
- [x] `.claude/hooks/subagent_stop.py` - Subagent 종료 Hook
- [x] Hook 실행 권한 부여 (`chmod +x`)

#### ✅ Phase 5: Settings 파일
- [x] `.claude/settings.json` 생성
  - 터미널 설정 (Zsh/Bash)
  - Hook 설정 (matcher 구조)
  - Output Style 설정

#### ✅ Phase 6: Subagent 정의
- [x] `.claude/agents/requirement-capture.md`
- [x] `.claude/agents/plan-architect.md`
- [x] `.claude/agents/tdd-generator.md`
- [x] `.claude/agents/implementation-executor.md`
- [x] `.claude/agents/qa-validator.md`
- [x] `.claude/agents/finalize-reporter.md`

#### ✅ Phase 7: Skill 정의
- [x] `.claude/skills/gcx-project-v6/SKILL.md`
- [x] `.claude/skills/gcx-project-v6/v6_protocol.md`

#### ✅ Phase 8: Templates 및 Schema
- [x] `.claude/templates/preflight_check_v6.zsh`
- [x] `.gcx/schemas/models.schema.json`
- [x] `.gcx/schemas/baton.schema.json`

#### ✅ Phase 9: 스키마 체계 완성 (2025-12-20)
- [x] `.gcx/schemas/result_block.schema.json` - AI 결과 블록 표준 양식
- [x] `.gcx/schemas/phase_output.schema.json` - Phase 출력 문서 표준 양식
- [x] `.gcx/schemas/ai_exchange.schema.json` - AI간 문서 교환 표준 양식
- [x] `.gcx/schemas/request_batch.schema.json` - 요청 배치(그룹화) 스키마
- [x] `.gcx/schemas/README.md` - 스키마 사용법 문서

#### ✅ Phase 10: Hook Windows 호환성 수정 (2025-12-20)
- [x] `.claude/settings.json` Hook 환경변수 처리 수정
  - `$CLAUDE_PROJECT_DIR` → Python 내부에서 `os.environ.get()` 사용
  - 모든 Hook 명령어 패턴 통일

### 구현 완료 요약

```
총 파일 생성: 29개
- 라이브러리: 6개 (.claude/lib/)
- Hook: 4개 (.claude/hooks/)
- Subagent: 6개 (.claude/agents/)
- Skill: 2개 (.claude/skills/gcx-project-v6/)
- 설정: 2개 (.claude/config/, .claude/settings.json)
- Template: 1개 (.claude/templates/)
- Schema: 7개 (.gcx/schemas/) - 신규 5개 추가
- 문서: 1개 (.gcx/schemas/README.md)
```

### 다음 단계 (미구현)

#### 🔲 추가 Skill 구현
- [ ] `gcx-query-v6` - Baton 상태 조회
- [ ] `gcx-preflight-v6` - 환경 검증
- [ ] `gcx-status-v6` - 진행 상황 조회
- [ ] `gcx-resume-v6` - 중단된 세션 재개
- [ ] `gcx-cancel-v6` - 세션 취소

#### 🔲 통합 테스트
- [ ] Preflight Check 스크립트 실행 테스트
- [ ] 모델 설정 로더 테스트
- [ ] Context Baton CRUD 테스트
- [ ] Hook 실행 테스트
- [ ] End-to-End 파이프라인 테스트

#### 🔲 문서화
- [ ] 사용자 가이드 작성
- [ ] API 레퍼런스 작성
- [ ] 트러블슈팅 가이드 작성

---
name: gcx-project-v6
description: GCX v6 프로젝트 전체 워크플로우. /gcx-project 입력 시 6단계 Gemini-Claude-Codex 파이프라인을 자동 실행합니다.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task
---

# GCX Project v6

GCX v6 프로토콜을 사용하여 Gemini-Claude-Codex 6단계 파이프라인을 자동으로 실행하는 스킬입니다.

## 사용 방법

```bash
/gcx-project "REST API 서버 구현"
```

## 실행 흐름

### Phase 1: Requirement Capture (Gemini)
**담당**: `requirement-capture` Subagent
**AI**: Gemini 2.5 Pro
**산출물**: `.gcx/00_requirements/user_request_[timestamp].md`

```
사용자 요청 분석 및 구조화
→ 기능 요구사항 추출
→ 비기능 요구사항 정리
→ 우선순위 설정
```

### Phase 2: Plan Architect (Claude)
**담당**: `plan-architect` Subagent
**AI**: Claude Opus 4.5
**산출물**:
- `.gcx/01_planning/TRD.md`
- `.gcx/01_planning/IMPLEMENTATION_PLAN.md`

```
요구사항 분석
→ 시스템 아키텍처 설계
→ 기술 스택 선정
→ 4-Layer 구현 계획 수립
```

### Phase 3: TDD Generator (Codex)
**담당**: `tdd-generator` Subagent
**AI**: Codex-1
**산출물**: `tests/**/*.test.ts`, `.gcx/02_implementation/TEST_PLAN.md`

```
계획 분석
→ 테스트 전략 수립
→ Given-When-Then 패턴으로 테스트 작성
→ Fixtures 생성
```

### Phase 4: Implementation (Codex + Gemini)
**담당**: `implementation-executor` Subagent
**AI**: Codex-1 (Backend), Gemini 2.5 Pro (Frontend Design)
**산출물**: 모든 구현 코드

```
Layer 1: Infrastructure (Docker, DB, ENV)
→ Layer 2: Backend (API, Service, Repository)
→ Layer 3: Frontend (UI/UX) ⚠️ Gemini 디자인 승인 필수
→ Layer 4: Integration (E2E Tests)
```

**중요**: Frontend 레이어에서 Gemini의 디자인 리뷰는 **절대적 권한**을 가집니다.

### Phase 5: QA Validation (Codex)
**담당**: `qa-validator` Subagent
**AI**: Codex O3
**산출물**: `.gcx/03_verification/QA_REPORT.md`

```
테스트 실행 (커버리지 확인)
→ Codex Security Audit (OWASP Top 10)
→ 성능 체크
→ 코드 품질 검증
→ Production Ready 판정
```

### Phase 6: Finalize & Report (Gemini)
**담당**: `finalize-reporter` Subagent
**AI**: Gemini 2.5 Pro
**산출물**: `.gcx/output/FINAL_REPORT.md`

```
산출물 수집
→ Baton 분석
→ 최종 보고서 생성
→ 커밋 메시지 제안
```

## Context Baton Protocol

각 Subagent는 **Context Baton**을 통해 이전 단계의 결과를 받습니다:

```json
{
  "metadata": {
    "session_id": "20251219_143022_a3f7",
    "current_phase": "plan-architect",
    "total_phases": 6
  },
  "user_request": "REST API 서버 구현",
  "requirements": { ... },
  "planning": { ... },
  "implementation": { ... },
  "phase_results": [...]
}
```

Baton은 `.gcx/state/project_context.json`에 저장되며, 각 단계가 완료될 때마다 업데이트됩니다.

## 모델 설정

모델은 `.claude/config/models.json`에서 관리됩니다.

```json
{
  "taskMapping": {
    "requirement-capture": { "primary": "gemini.default" },
    "plan-architect": { "primary": "claude.planning" },
    "tdd-generator": { "primary": "codex.default" },
    "implementation": { "primary": "codex.default" },
    "design-review": { "primary": "gemini.design" },
    "qa-validator": { "primary": "codex.reasoning" },
    "finalize-reporter": { "primary": "gemini.default" }
  }
}
```

사용자는 `models.json`만 수정하면 모든 AI 모델 버전을 업데이트할 수 있습니다.

## Hooks

GCX v6는 다음 Hooks를 사용합니다:

1. **UserPromptSubmit**: Baton 초기화, 요구사항 자동 캡처
2. **PreToolUse (Bash)**: 환경 검증 (MSYS2, Locale, Cygpath)
3. **PostToolUse (Bash)**: AI 출력 파싱, Baton 업데이트
4. **SubagentStop**: 체크포인트 자동 저장

모든 Hook은 `.claude/hooks/`에 Python 스크립트로 구현되어 있습니다.

## 실행 예시

### 1. 프로젝트 시작

```bash
/gcx-project "사용자 인증과 게시물 CRUD가 있는 REST API 서버"
```

### 2. 진행 상황 확인

실시간 진행 상황이 표시됩니다:

```
[Step 1/6] Requirement Capture → ✅
[Step 2/6] Plan Architect      → 🔄
[Step 3/6] TDD Generator       → ⏳
[Step 4/6] Implementation      → ⏳
[Step 5/6] QA Validator        → ⏳
[Step 6/6] Finalize Reporter   → ⏳
```

### 3. 최종 결과

6단계가 모두 완료되면 최종 보고서와 커밋 제안이 제공됩니다.

## 디렉토리 구조

```
learning-code/
├── .claude/                    # 정적 설정, 로직
│   ├── config/
│   │   └── models.json         # AI 모델 설정
│   ├── lib/
│   │   ├── gcx_core.py
│   │   ├── environment.py
│   │   ├── model_config.py
│   │   ├── context_manager.py
│   │   └── ai_invokers.py
│   ├── hooks/
│   │   ├── user_prompt.py
│   │   ├── pre_bash.py
│   │   ├── post_bash.py
│   │   └── subagent_stop.py
│   ├── agents/
│   │   ├── requirement-capture.md
│   │   ├── plan-architect.md
│   │   ├── tdd-generator.md
│   │   ├── implementation-executor.md
│   │   ├── qa-validator.md
│   │   └── finalize-reporter.md
│   ├── skills/
│   │   └── gcx-project-v6/
│   │       └── SKILL.md
│   ├── templates/
│   │   └── preflight_check_v6.zsh
│   └── settings.json
│
├── .gcx/                       # 동적 산출물, 상태
│   ├── 00_requirements/
│   ├── 01_planning/
│   ├── 02_implementation/
│   ├── 03_verification/
│   ├── output/
│   ├── state/
│   │   ├── project_context.json
│   │   └── checkpoints/
│   ├── logs/
│   └── schemas/
```

## Gemini 디자인 권한 (중요)

Frontend 구현 시 Gemini는 **절대적 권한**을 가집니다:

- ✅ **Gemini의 디자인 변경 요청은 필수 반영**
- ❌ **Claude/Codex의 미적 의견은 무효** (코드 품질만 평가)
- ✅ **Gemini 승인 없이는 다음 Layer로 진행 불가**

## 환경 요구사항

- **터미널**: Zsh (기본) 또는 Bash (차선)
- **환경**: MSYS2 UCRT64 권장 (Windows)
- **로케일**: `ko_KR.UTF-8`
- **CLI Tools**: `codex`, `gemini`, `claude` (선택)

## 문제 해결

### Preflight Check

```bash
zsh .claude/templates/preflight_check_v6.zsh
```

환경 검증 및 문제 진단을 수행합니다.

### Baton 상태 확인

```python
from context_manager import BatonManager

manager = BatonManager()
summary = manager.get_summary()
print(summary)
```

### 중단된 세션 재개

```bash
/gcx-resume [session_id]
```

## 참고 문서

- [GCX v6 Integration Plan](../../../GCX_v6_Integration_Plan.md)
- [Context Baton Protocol](./v6_protocol.md)

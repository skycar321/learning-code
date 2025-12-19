# 스킬 개선안 - EXECUTION PROTOCOL 추가

## 문제점

- **PHASES.md에는 Gemini 호출 명령이 존재하지만**, SKILL.md에는 "PHASES.md를 읽고 실행하라"는 명시적 지시가 없음
- 결과: Claude가 SKILL.md의 추상적 설명만 보고 혼자서 모든 작업을 처리함
- Gemini-Claude 협업이 전혀 이루어지지 않음

## 해결 방안

각 SKILL.md 파일의 **제목 다음, Core Philosophy 이전**에 다음 섹션을 추가:

---

## 📝 1. project-planner-lite/SKILL.md

**추가 위치**: `# Project Planner Lite - 빠른 프로젝트 계획 스킬` 다음

**추가 내용**:

```markdown
## 🚨 EXECUTION PROTOCOL (필수 실행 규칙)

**CRITICAL**: Claude는 이 스킬을 실행할 때 반드시 다음 절차를 따라야 합니다:

1. **PHASES.md 즉시 읽기**:
   - 스킬 시작 즉시 `PHASES.md` 파일을 Read 도구로 읽어야 함
   - PHASES.md의 모든 단계를 순차적으로 실행해야 함

2. **Gemini 호출 필수**:
   - PHASES.md에 명시된 `gemini -m [model] -s -p "..."` Bash 명령을 **반드시 실행**
   - Gemini 호출 없이 다음 단계로 진행 금지
   - Example: `gemini -m gemini-2.5-pro -s -p "Create an Integrated Requirements Document..."`

3. **검증 PASS 확인**:
   - 각 Phase마다 Gemini의 검증 결과가 PASS일 때만 다음 단계 진행
   - ISSUE 발견 시 LOOP 프로세스 따름 (최대 1회 in Lite version)

4. **사용자 승인 필수**:
   - 각 Phase 완료 후 AskUserQuestion으로 사용자 승인 받기
   - 승인 없이 다음 Phase 진행 금지

5. **AI Collaborator 기록**:
   - 문서 생성 완료 후 MODIFY_HISTORY.md에 Gemini 협업 내용 기록
   - Model 이름 (예: gemini-2.5-pro), 검증 상태, 주요 피드백 포함

6. **절대 단독 작업 금지**:
   - Claude가 혼자서 IRD/WORKPLAN을 작성하는 것은 **이 스킬의 목적에 위배됨**
   - 반드시 "Gemini Draft → Claude Validation → User Approval" 프로세스를 따라야 함

---
```

---

## 📝 2. project-planner/SKILL.md

**추가 위치**: `# Project Planner - PRD/TRD/Plan/Task Generator` 다음

**추가 내용**:

```markdown
## 🚨 EXECUTION PROTOCOL (필수 실행 규칙)

**CRITICAL**: Claude는 이 스킬을 실행할 때 반드시 다음 절차를 따라야 합니다:

1. **PHASES.md 즉시 읽기**:
   - 스킬 시작 즉시 `PHASES.md` 파일을 Read 도구로 읽어야 함
   - PHASES.md의 모든 단계(Phase 1-5)를 순차적으로 실행해야 함

2. **Gemini 호출 필수**:
   - 각 Phase마다 PHASES.md에 명시된 `gemini -m [model] -s -p "..."` Bash 명령을 **반드시 실행**
   - Gemini 호출 없이 다음 Phase로 진행 금지
   - Example: `gemini -m gemini-2.5-pro -s -a ui-mockup.png -p "Create a detailed PRD..."`

3. **검증 PASS 확인**:
   - 각 Phase마다 Gemini Draft → Claude Validation → User Approval 순서 엄수
   - Claude는 PHASES.md의 Validation Checklist를 사용해 Gemini 결과물 검증
   - ISSUE 발견 시 LOOP 프로세스 따름 (최대 3회)

4. **사용자 승인 필수**:
   - 각 Phase 완료 후 AskUserQuestion으로 사용자 승인 받기
   - 승인 없이 다음 Phase 진행 금지

5. **AI Collaborator 기록**:
   - 최종 문서 생성 완료 후 MODIFY_HISTORY.md에 Gemini 협업 내용 기록
   - 각 Phase별로 사용한 Model 이름 (예: gemini-3-pro-preview), 검증 상태 기록
   - 주요 피드백 내용 포함

6. **절대 단독 작업 금지**:
   - Claude가 혼자서 PRD/TRD/WorkPlan을 작성하는 것은 **이 스킬의 목적에 위배됨**
   - 반드시 "Gemini Draft → Claude Validation → User Approval" 프로세스를 따라야 함
   - Gemini가 1차 작성자, Claude는 검증자 역할

---
```

---

## 📝 3. implementation-executor-lite/SKILL.md

**추가 위치**: `# Implementation Executor Lite - 빠른 구현 실행 스킬` 다음

**추가 내용**:

```markdown
## 🚨 EXECUTION PROTOCOL (필수 실행 규칙)

**CRITICAL**: Claude는 이 스킬을 실행할 때 반드시 다음 절차를 따라야 합니다:

1. **PHASES.md 즉시 읽기**:
   - 스킬 시작 즉시 `PHASES.md` 파일을 Read 도구로 읽어야 함
   - PHASES.md의 3단계 프로세스(Setup → Development → Basic QA)를 순차적으로 실행해야 함

2. **Claude 구현 → Gemini 검증 패턴**:
   - **Phase 1 (Setup)**: Claude가 환경 설정 → Gemini Quick Validation
   - **Phase 2 (Development)**: Claude가 Backend/Frontend 구현 → Gemini Code Review
   - **Phase 3 (Basic QA)**: Claude가 테스트 → Gemini MVP Ready Validation
   - PHASES.md에 명시된 `gemini -m [model] -s -p "..."` Bash 명령을 **반드시 실행**

3. **Gemini 검증 필수**:
   - 각 Phase 완료 후 Gemini 호출 없이 다음 Phase로 진행 금지
   - Example Phase 1: `gemini -m gemini-2.5-flash -s -p "Validate the following setup..."`
   - Example Phase 2: `gemini -m gemini-2.5-pro -s -p "Review the following implementation..."`
   - Example Phase 3: `gemini -m gemini-2.5-pro -s -p "Perform MVP Ready validation..."`

4. **LOOP 프로세스**:
   - Gemini가 ISSUE 발견 시 Claude가 즉시 수정
   - 최대 1-2회 반복 (Lite 버전)
   - PASS 받아야만 다음 Phase 진행

5. **AI Collaborator 기록**:
   - 최종 MVP 완성 후 MODIFY_HISTORY.md에 Gemini 협업 내용 기록
   - 각 Phase별 사용한 Model, 검증 상태 (PASS/NEEDS_FIX), 주요 피드백 포함

6. **절대 단독 작업 금지**:
   - Claude가 혼자서 구현하고 검증까지 모두 처리하는 것은 **이 스킬의 목적에 위배됨**
   - 반드시 "Claude Implementation → Gemini Validation" 프로세스를 따라야 함
   - Gemini 검증 없이 "MVP Ready" 선언 금지

---
```

---

## 📝 4. implementation-executor/SKILL.md

**추가 위치**: `# Implementation Executor (구현 실행 스킬)` 다음

**추가 내용**:

```markdown
## 🚨 EXECUTION PROTOCOL (필수 실행 규칙)

**CRITICAL**: Claude는 이 스킬을 실행할 때 반드시 다음 절차를 따라야 합니다:

1. **PHASES.md 즉시 읽기**:
   - 스킬 시작 즉시 `PHASES.md` 파일을 Read 도구로 읽어야 함
   - PHASES.md의 6단계 프로세스를 순차적으로 실행해야 함
   - Phase 0: Input Validation → Phase 1: Infrastructure → Phase 2: Backend → Phase 3: Frontend → Phase 4: Integration → Phase 5: Multi-Stage QA → Phase 6: Final Verification

2. **레이어별 구현/검증 패턴**:
   - **Infrastructure, Backend, Integration, QA**: Claude 구현 → Gemini 검증
   - **Frontend**: Gemini 구현 → Claude 검증 (대량 컴포넌트 생성)
   - PHASES.md에 명시된 `gemini -m [model] -s -p "..."` Bash 명령을 **반드시 실행**

3. **Gemini 검증 필수**:
   - 각 Phase/Group 완료 후 Gemini Batch Review 필수
   - Example (Infrastructure): `gemini -m [model] -s -p "Validate the following infrastructure setup..."`
   - Example (Backend): `gemini -m [model] -s -p "Review the following backend implementation batch..."`
   - Example (Integration): `gemini -m [model] -s -p "Validate overall integration..."`
   - Gemini 검증 PASS 없이 다음 Phase 진행 금지

4. **프로덕션 레디 LOOP**:
   - Phase 5 (Multi-Stage QA)에서 Gemini가 Production Ready 확인
   - Layer-wise QA → Integration QA → E2E QA → Production Ready Check
   - ISSUE 발견 시 Claude 수정 → Gemini 재검증 (최대 5회)
   - NOT_READY 상태에서 완료 금지

5. **AI Collaborator 기록**:
   - Phase 6 완료 후 MODIFY_HISTORY.md에 **모든 Gemini 검증 단계** 기록
   - 사용한 Model 이름, 각 Phase별 검증 상태 (PASS/NEEDS_FIX/PRODUCTION_READY) 기록
   - 총 Gemini 호출 횟수 (~30-50회) 포함

6. **절대 단독 작업 금지**:
   - Claude가 혼자서 구현하고 검증까지 모두 처리하는 것은 **이 스킬의 목적에 위배됨**
   - 반드시 "Claude 구현 → Gemini 철저한 검증" LOOP 프로세스 따라야 함
   - Gemini의 Production Ready 승인 없이 배포 준비 완료 선언 금지

---
```

---

## ⚠️ 수정 방법

1. VS Code나 Cursor에서 각 스킬 디렉토리의 `SKILL.md` 파일 열기
2. 제목 (#) 다음, `## Core Philosophy` 이전에 위의 `## 🚨 EXECUTION PROTOCOL` 섹션 전체 복사/붙여넣기
3. 저장
4. 다음 스킬 실행 시부터 Gemini 협업이 정상 작동할 것

## ✅ 기대 효과

- Claude가 SKILL.md 읽을 때 EXECUTION PROTOCOL을 먼저 보고 PHASES.md를 필수로 읽게 됨
- PHASES.md의 구체적인 Gemini 호출 명령을 실제로 실행하게 됨
- MODIFY_HISTORY.md에 Gemini 협업 내용이 정확히 기록됨
- "AI Collaborator: 없음 (Claude 단독 작업)" 문제 해결

---

**생성일**: 2025-11-30
**작성자**: Claude Code

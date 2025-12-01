#!/usr/bin/env python3
"""
Command 파일 자동 업데이트 스크립트
4개 Command 파일에 EXECUTION PROTOCOL 섹션을 추가합니다.
"""

import os
from pathlib import Path

# Command 파일 경로
COMMANDS_DIR = Path(r"C:\Users\Nam\.claude\commands\nam")

# 업데이트할 Command 파일 목록
COMMANDS = [
    "project-planner-lite.md",
    "project-planner.md",
    "implementation-executor-lite.md",
    "implementation-executor.md"
]

# 각 Command별 EXECUTION PROTOCOL 템플릿
PROTOCOLS = {
    "project-planner-lite.md": """---
name: nam:project-planner-lite
description: 작은 프로젝트와 빠른 프로토타입을 위한 경량 계획 스킬 실행
---

# 🚨 EXECUTION PROTOCOL (필수 실행 규칙)

**CRITICAL**: 이 명령을 실행할 때 Claude는 반드시 다음 절차를 따라야 합니다:

## 1. PHASES.md 즉시 읽기
```
Read: C:/Users/Nam/.claude/skills/project-planner-lite/PHASES.md
```
- 스킬 시작 즉시 PHASES.md 파일을 읽어야 함
- PHASES.md의 모든 단계를 순차적으로 실행해야 함

## 2. Gemini 호출 필수
- PHASES.md에 명시된 **모든** `gemini -m [model] -s -p "..."` Bash 명령을 실행
- Gemini 호출 없이 다음 단계로 진행 **절대 금지**
- Example:
  ```bash
  gemini -m gemini-2.5-pro -s -p "Create an Integrated Requirements Document..."
  ```

## 3. 검증 PASS 확인
- 각 Phase마다 Gemini의 출력을 검증
- Claude는 Gemini 초안을 보완하는 역할
- ISSUE 발견 시 LOOP 프로세스 따름 (최대 1회)

## 4. 사용자 승인 필수
- 각 Phase 완료 후 AskUserQuestion으로 사용자 승인 받기
- 승인 없이 다음 Phase 진행 금지

## 5. AI Collaborator 기록
- 문서 생성 완료 후 MODIFY_HISTORY.md에 Gemini 협업 내용 기록
- Model 이름, 검증 상태, 주요 피드백 포함

## 6. 절대 단독 작업 금지
- Claude가 혼자서 IRD/WORKPLAN을 작성하는 것은 **이 스킬의 목적에 위배됨**
- 반드시 "Gemini Draft → Claude Validation → User Approval" 프로세스 따름

---

# Project Planner Lite Launcher

This skill provides a lightweight 2-phase planning process:

## Features
- **Phase 1**: IRD (Integrated Requirements Document)
  - Combined functional and technical requirements
  - ~30-50 lines of concise documentation

- **Phase 2**: WORKPLAN (Actionable Work Plan)
  - 3-5 implementation phases
  - Task breakdown with priorities (P0/P1/P2)
  - Estimated time per task (1-8 hours)

## Best For
- Small projects (1-4 weeks)
- Quick prototypes and MVPs
- Clear requirements (no complex analysis needed)
- 1-3 person teams

## Time Required
- **Total**: 1-2 hours for complete planning
- **Output**: 2 documents (~80 lines total)

## Next Step
After completion, use `/nam:implementation-executor-lite` for quick implementation.

---

**Now reading PHASES.md and executing...**
""",

    "project-planner.md": """---
name: nam:project-planner
description: 사용자 요구사항에서 PRD → TRD → 작업 계획 → Task 분할까지 체계적 프로젝트 계획 수립
---

# 🚨 EXECUTION PROTOCOL (필수 실행 규칙)

**CRITICAL**: 이 명령을 실행할 때 Claude는 반드시 다음 절차를 따라야 합니다:

## 1. PHASES.md 즉시 읽기
```
Read: C:/Users/Nam/.claude/skills/project-planner/PHASES.md
```
- 스킬 시작 즉시 PHASES.md 파일을 읽어야 함
- PHASES.md의 모든 5단계를 순차적으로 실행해야 함

## 2. Gemini 호출 필수
- PHASES.md에 명시된 **모든** `gemini -m [model] -s -p "..."` Bash 명령을 실행
- 각 Phase마다 Gemini 호출 필요 (총 5회)
- Gemini 호출 없이 다음 단계로 진행 **절대 금지**

## 3. 검증 PASS 확인
- 각 Phase마다 Gemini의 검증 결과가 PASS일 때만 다음 단계 진행
- ISSUE 발견 시 LOOP 프로세스 따름 (최대 3회)

## 4. 사용자 승인 필수
- 각 Phase 완료 후 AskUserQuestion으로 사용자 승인 받기
- 승인 없이 다음 Phase 진행 금지

## 5. AI Collaborator 기록
- 각 문서 생성 완료 후 MODIFY_HISTORY.md에 Gemini 협업 내용 기록
- Model 이름, 검증 상태, 주요 피드백 포함

## 6. 절대 단독 작업 금지
- Claude가 혼자서 PRD/TRD/작업계획을 작성하는 것은 **이 스킬의 목적에 위배됨**
- 반드시 "Gemini Draft → Claude Validation → User Approval" 프로세스 따름

---

# Project Planner - 체계적 프로젝트 계획 스킬

5단계 Gemini-Claude 협업으로 완벽한 프로젝트 계획 수립

## 생성 문서
1. **PRD.md** - Product Requirements Document
2. **TRD.md** - Technical Requirements Document
3. **WORKPLAN_Overall.md** - 전체 작업 계획
4. **WORKPLAN_Detailed.md** - 상세 작업 계획
5. **TASKS.md** - 실행 가능한 Task 목록

## 예상 시간
- **Total**: 3-6 hours
- **Output**: 5 documents (~500 lines total)

## 적용 대상
- 대규모 프로젝트
- 엔터프라이즈 시스템
- 복잡한 아키텍처
- 다수 이해관계자

## Next Step
After completion, use `/nam:implementation-executor` for production-ready implementation.

---

**Now reading PHASES.md and executing...**
""",

    "implementation-executor-lite.md": """---
name: nam:implementation-executor-lite
description: 작은 프로젝트의 빠른 구현을 위한 경량 실행 스킬 (Setup→Development→Basic QA)
---

# 🚨 EXECUTION PROTOCOL (필수 실행 규칙)

**CRITICAL**: 이 명령을 실행할 때 Claude는 반드시 다음 절차를 따라야 합니다:

## 1. PHASES.md 즉시 읽기
```
Read: C:/Users/Nam/.claude/skills/implementation-executor-lite/PHASES.md
```
- 스킬 시작 즉시 PHASES.md 파일을 읽어야 함
- PHASES.md의 모든 단계를 순차적으로 실행해야 함

## 2. Gemini 호출 필수
- PHASES.md에 명시된 **모든** `gemini -m [model] -s -p "..."` Bash 명령을 실행
- 각 Phase 완료 전 Gemini 검증 필수
- Gemini 호출 없이 다음 단계로 진행 **절대 금지**

## 3. 검증 PASS 확인
- 각 Phase 완료 후 Gemini에게 코드 검증 요청
- PASS일 때만 다음 단계 진행
- ISSUE 발견 시 즉시 수정 (최대 1회 반복)

## 4. 사용자 승인 필수
- 각 Phase 완료 후 AskUserQuestion으로 사용자 승인 받기
- 승인 없이 다음 Phase 진행 금지

## 5. AI Collaborator 기록
- 각 Phase 완료 후 MODIFY_HISTORY.md에 Gemini 협업 내용 기록
- Model 이름, 검증 상태, 발견된 이슈 및 수정 사항 포함

## 6. 절대 단독 작업 금지
- Claude가 혼자서 코드를 작성하고 검증하는 것은 **이 스킬의 목적에 위배됨**
- 반드시 "Claude Implementation → Gemini Validation → Fix if needed" 프로세스 따름

---

# Implementation Executor Lite

3단계 빠른 구현 프로세스:

## Phases
1. **Setup**: 환경 설정 및 프로젝트 초기화
2. **Development**: 핵심 기능 구현
3. **Basic QA**: 기본 테스트 및 빌드 확인

## Best For
- MVP 개발
- 프로토타입
- 1-2주 프로젝트
- 빠른 검증 필요한 경우

## Time Required
- **Total**: 1-2 days
- **Output**: Working MVP

## Prerequisites
- WORKPLAN.md 필요 (project-planner-lite 실행 후)

---

**Now reading PHASES.md and executing...**
""",

    "implementation-executor.md": """---
name: nam:implementation-executor
description: 프로덕션 레디 구현 실행 스킬 (인프라→BE→FE→통합→QA→최종검증)
---

# 🚨 EXECUTION PROTOCOL (필수 실행 규칙)

**CRITICAL**: 이 명령을 실행할 때 Claude는 반드시 다음 절차를 따라야 합니다:

## 1. PHASES.md 즉시 읽기
```
Read: C:/Users/Nam/.claude/skills/implementation-executor/PHASES.md
```
- 스킬 시작 즉시 PHASES.md 파일을 읽어야 함
- PHASES.md의 모든 6단계를 순차적으로 실행해야 함

## 2. Gemini 호출 필수
- PHASES.md에 명시된 **모든** `gemini -m [model] -s -p "..."` Bash 명령을 실행
- 각 Phase 완료 전 Gemini 검증 필수 (총 6회)
- Gemini 호출 없이 다음 단계로 진행 **절대 금지**

## 3. 검증 PASS 확인
- 각 Phase 완료 후 Gemini에게 코드 검증 요청
- PASS일 때만 다음 단계 진행
- ISSUE 발견 시 LOOP 프로세스 따름 (최대 3회)

## 4. 사용자 승인 필수
- 각 Phase 완료 후 AskUserQuestion으로 사용자 승인 받기
- 승인 없이 다음 Phase 진행 금지

## 5. AI Collaborator 기록
- 각 Phase 완료 후 MODIFY_HISTORY.md에 Gemini 협업 내용 기록
- Model 이름, 검증 상태, 발견된 이슈 및 수정 사항 포함

## 6. 절대 단독 작업 금지
- Claude가 혼자서 코드를 작성하고 검증하는 것은 **이 스킬의 목적에 위배됨**
- 반드시 "Claude Implementation → Gemini Validation → Fix if needed" 프로세스 따름

---

# Implementation Executor

프로덕션 배포 가능한 완전한 구현 프로세스:

## Phases
1. **Infrastructure**: 인프라 및 환경 구성
2. **Backend**: 백엔드 API 구현
3. **Frontend**: 프론트엔드 UI 구현
4. **Integration**: 통합 및 E2E 테스트
5. **QA**: 종합적 품질 보증
6. **Final Validation**: 프로덕션 레디 최종 검증

## Best For
- 프로덕션 배포 대상 프로젝트
- 엔터프라이즈 시스템
- 높은 품질 요구사항
- 3주+ 개발 기간

## Time Required
- **Total**: 2-4 weeks
- **Output**: Production-ready application

## Prerequisites
- WORKPLAN_Detailed.md 필요 (project-planner 실행 후)

---

**Now reading PHASES.md and executing...**
"""
}

def update_command_file(filename: str):
    """Command 파일에 EXECUTION PROTOCOL 추가"""
    filepath = COMMANDS_DIR / filename

    if not filepath.exists():
        print(f"❌ 파일 없음: {filepath}")
        return False

    # 백업 생성
    backup_path = filepath.with_suffix('.md.bak')
    with open(filepath, 'r', encoding='utf-8') as f:
        original_content = f.read()

    with open(backup_path, 'w', encoding='utf-8') as f:
        f.write(original_content)
    print(f"📦 백업 생성: {backup_path}")

    # 새 내용으로 교체
    new_content = PROTOCOLS[filename]

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(new_content)

    print(f"✅ 업데이트 완료: {filename}")
    return True

def main():
    print("=" * 70)
    print("Command 파일 EXECUTION PROTOCOL 자동 추가 스크립트")
    print("=" * 70)
    print()

    if not COMMANDS_DIR.exists():
        print(f"❌ Commands 디렉토리 없음: {COMMANDS_DIR}")
        return

    print(f"📂 Commands 디렉토리: {COMMANDS_DIR}")
    print(f"📝 업데이트 대상: {len(COMMANDS)}개 파일")
    print()

    success_count = 0
    for cmd_file in COMMANDS:
        print(f"\n{'─' * 70}")
        print(f"처리 중: {cmd_file}")
        print(f"{'─' * 70}")

        if update_command_file(cmd_file):
            success_count += 1
        else:
            print(f"⚠️  실패: {cmd_file}")

    print()
    print("=" * 70)
    print(f"✨ 완료: {success_count}/{len(COMMANDS)}개 파일 업데이트됨")
    print("=" * 70)
    print()
    print("📌 백업 파일: *.md.bak")
    print("📌 복원 방법: mv file.md.bak file.md")

if __name__ == "__main__":
    main()

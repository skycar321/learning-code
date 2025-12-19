#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
스킬 파일 자동 업데이트 스크립트
EXECUTION PROTOCOL 섹션을 각 SKILL.md에 추가
"""

import os
import sys

# UTF-8 출력 설정 (Windows 호환)
if sys.platform == 'win32':
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

# 스킬 디렉토리 경로
SKILLS_DIR = r"C:\Users\Nam\.claude\skills"

# 각 스킬별 EXECUTION PROTOCOL 내용
PROTOCOLS = {
    "project-planner-lite": """## 🚨 EXECUTION PROTOCOL (필수 실행 규칙)

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

""",

    "project-planner": """## 🚨 EXECUTION PROTOCOL (필수 실행 규칙)

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

""",

    "implementation-executor-lite": """## 🚨 EXECUTION PROTOCOL (필수 실행 규칙)

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

""",

    "implementation-executor": """## 🚨 EXECUTION PROTOCOL (필수 실행 규칙)

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

"""
}

def update_skill_file(skill_name):
    """특정 스킬 파일 업데이트"""
    skill_path = os.path.join(SKILLS_DIR, skill_name, "SKILL.md")

    if not os.path.exists(skill_path):
        print(f"[ERROR] 파일 없음: {skill_path}")
        return False

    try:
        # 파일 읽기 (UTF-8 인코딩)
        with open(skill_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # 이미 EXECUTION PROTOCOL이 있는지 확인
        if "## 🚨 EXECUTION PROTOCOL" in content:
            print(f"[SKIP] 이미 EXECUTION PROTOCOL 존재: {skill_name}")
            return False

        # "## Core Philosophy" 찾기
        marker = "## Core Philosophy"
        if marker not in content:
            print(f"[ERROR] 'Core Philosophy' 섹션을 찾을 수 없음: {skill_name}")
            return False

        # EXECUTION PROTOCOL 삽입
        protocol = PROTOCOLS.get(skill_name, "")
        if not protocol:
            print(f"[ERROR] Protocol 정의 없음: {skill_name}")
            return False

        new_content = content.replace(marker, protocol + marker)

        # Version 업데이트
        new_content = new_content.replace("**Version**: 1.0.0", "**Version**: 1.1.0")

        # Last Updated 날짜 업데이트
        import datetime
        today = datetime.datetime.now().strftime("%Y-%m-%d")
        if "**Last Updated**:" in new_content:
            import re
            new_content = re.sub(
                r'\*\*Last Updated\*\*: \d{4}-\d{2}-\d{2}',
                f'**Last Updated**: {today}',
                new_content
            )

        # 파일 쓰기
        with open(skill_path, 'w', encoding='utf-8') as f:
            f.write(new_content)

        print(f"[OK] 성공: {skill_name}/SKILL.md 업데이트 완료")
        return True

    except Exception as e:
        print(f"[ERROR] 오류 발생 ({skill_name}): {e}")
        return False

def main():
    """메인 함수"""
    print("=" * 60)
    print("스킬 파일 자동 업데이트 시작")
    print("=" * 60)
    print()

    skills = [
        "project-planner-lite",
        "project-planner",
        "implementation-executor-lite",
        "implementation-executor"
    ]

    results = []
    for skill in skills:
        print(f"처리 중: {skill}...")
        success = update_skill_file(skill)
        results.append((skill, success))
        print()

    print("=" * 60)
    print("처리 완료 요약")
    print("=" * 60)
    for skill, success in results:
        status = "[OK]" if success else "[SKIP/ERROR]"
        print(f"{status} {skill}")
    print()

    success_count = sum(1 for _, success in results if success)
    print(f"전체: {len(results)}개 중 {success_count}개 성공")
    print()

    if success_count > 0:
        print("다음 스킬 실행부터 Gemini-Claude 협업이 정상 작동합니다!")

if __name__ == "__main__":
    main()

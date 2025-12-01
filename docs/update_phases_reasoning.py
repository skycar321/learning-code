#!/usr/bin/env python3
"""
PHASES.md 파일들에 Reasoning Level 사용 가이드를 추가하는 스크립트
"""

import os
from pathlib import Path

# 업데이트 대상 디렉토리
SKILLS_DIR = Path.home() / ".claude" / "skills"

# cx-* 및 gcx-* 스킬 폴더 목록
TARGET_SKILLS = [
    "cx-executor",
    "cx-executor-lite",
    "cx-planner",
    "cx-planner-lite",
    "gcx-executor",
    "gcx-executor-lite",
    "gcx-planner",
    "gcx-planner-lite",
]

# PHASES.md 파일 맨 위에 추가할 섹션
SETUP_SECTION = """# Step 0: Codex 모델 및 Reasoning Level 설정

**IMPORTANT**: 이 스킬을 실행하기 전에 다음 정보가 필요합니다:

1. **Codex 모델**: 커맨드 파일에서 사용자가 선택한 모델
   - `gpt-5.1-codex-max`, `gpt-5.1-codex`, `gpt-5.1-codex-mini`, `gpt-5.1` 중 하나

2. **Reasoning Level** (gpt-5.1-codex-max만 해당):
   - `low`, `medium`, `high`, `extra_high` 중 하나
   - 다른 모델 선택 시에는 불필요

## Codex 호출 방법

### gpt-5.1-codex-max 사용 시:
```bash
codex exec -c model_reasoning_effort=[selected_reasoning_level] -m gpt-5.1-codex-max "프롬프트..."
```

**예시**:
```bash
codex exec -c model_reasoning_effort=medium -m gpt-5.1-codex-max "Validate the code quality..."
```

### 다른 모델 사용 시:
```bash
codex exec -m [selected_model] "프롬프트..."
```

**예시**:
```bash
codex exec -m gpt-5.1-codex "Validate the code quality..."
```

---

"""


def update_phases_file(file_path: Path) -> bool:
    """PHASES.md 파일 업데이트"""
    try:
        content = file_path.read_text(encoding='utf-8')
        original_content = content

        # 이미 "Step 0: Codex 모델" 섹션이 있으면 스킵
        if "Step 0: Codex 모델" in content:
            print(f"[SKIP] Already has Step 0: {file_path.parent.name}/PHASES.md")
            return False

        # 파일 시작 부분에 Setup 섹션 추가
        # 첫 번째 # 헤더 앞에 삽입
        lines = content.split('\n')
        new_lines = []
        inserted = False

        for i, line in enumerate(lines):
            if not inserted and line.startswith('# ') and not line.startswith('# Step 0'):
                # 첫 번째 # 헤더 앞에 Setup 섹션 삽입
                new_lines.extend(SETUP_SECTION.rstrip('\n').split('\n'))
                new_lines.append('')
                inserted = True

            new_lines.append(line)

        content = '\n'.join(new_lines)

        # codex exec/full-auto 명령어 업데이트
        # [selected_model] 표기를 유지하되, 주석 추가
        content = content.replace(
            'codex exec -m [selected_model]',
            'codex exec -c model_reasoning_effort=[selected_reasoning_level] -m [selected_model]'
        )
        content = content.replace(
            'codex full-auto -m [selected_model]',
            'codex full-auto -c model_reasoning_effort=[selected_reasoning_level] -m [selected_model]'
        )

        if content != original_content:
            file_path.write_text(content, encoding='utf-8')
            print(f"[OK] Updated: {file_path.parent.name}/PHASES.md")
            return True
        else:
            print(f"[SKIP] No changes needed: {file_path.parent.name}/PHASES.md")
            return False

    except Exception as e:
        print(f"[ERROR] Error updating {file_path}: {e}")
        return False


def main():
    """메인 실행 함수"""
    print("=" * 60)
    print("PHASES.md Reasoning Level 가이드 추가 스크립트")
    print("=" * 60)
    print(f"작업 디렉토리: {SKILLS_DIR}")
    print()

    if not SKILLS_DIR.exists():
        print(f"[ERROR] 디렉토리가 존재하지 않습니다: {SKILLS_DIR}")
        return

    updated_count = 0
    skipped_count = 0
    error_count = 0

    for skill_name in TARGET_SKILLS:
        skill_dir = SKILLS_DIR / skill_name
        phases_file = skill_dir / "PHASES.md"

        if not phases_file.exists():
            print(f"[SKIP] 파일이 존재하지 않음: {skill_name}/PHASES.md")
            skipped_count += 1
            continue

        result = update_phases_file(phases_file)
        if result:
            updated_count += 1
        elif result is False:
            error_count += 1
        else:
            skipped_count += 1

    print()
    print("=" * 60)
    print(f"작업 완료!")
    print(f"- 업데이트됨: {updated_count}개")
    print(f"- 변경 없음: {skipped_count}개")
    print(f"- 오류: {error_count}개")
    print("=" * 60)


if __name__ == "__main__":
    main()

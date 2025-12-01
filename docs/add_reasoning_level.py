#!/usr/bin/env python3
"""
Codex 커맨드 파일에 Reasoning Level 선택 기능을 추가하는 스크립트
"""

import os
from pathlib import Path

# 업데이트 대상 파일 경로
COMMANDS_DIR = Path.home() / ".claude" / "commands" / "nam"

# cx-* 및 gcx-* 파일 목록
CX_FILES = [
    "cx-executor.md",
    "cx-executor-lite.md",
    "cx-planner.md",
    "cx-planner-lite.md",
    "cx-task.md",
]

GCX_FILES = [
    "gcx-executor.md",
    "gcx-executor-lite.md",
    "gcx-planner.md",
    "gcx-planner-lite.md",
    "gcx-task.md",
]

# 추가할 Reasoning Level 섹션
REASONING_LEVEL_SECTION = '''
## 0.2 Reasoning Level 선택 (gpt-5.1-codex-max 전용)

**gpt-5.1-codex-max 모델을 선택한 경우에만** 추가로 Reasoning Level을 선택합니다.

**AskUserQuestion 실행** (gpt-5.1-codex-max 선택 시):
```
Question: "gpt-5.1-codex-max의 Reasoning Level을 선택하세요"
Header: "Reasoning Level"
MultiSelect: false
Options:
1. "Low (빠른 응답)"
   Description: "가벼운 추론, 빠른 응답 속도"
2. "Medium (기본값, 권장)"
   Description: "속도와 추론 깊이의 균형, 일반적인 작업에 적합"
3. "High (최대 추론)"
   Description: "복잡한 문제에 대한 깊은 추론"
4. "Extra high (초고도 추론)"
   Description: "매우 복잡한 문제를 위한 최대 추론 깊이"
```

**선택 후**: 선택된 Reasoning Level을 저장하고 모든 Codex 호출 시 사용합니다.

**Reasoning Level 매핑**:
- "Low (빠른 응답)" → `low`
- "Medium (기본값, 권장)" → `medium`
- "High (최대 추론)" → `high`
- "Extra high (초고도 추론)" → `extra_high`

'''

# GCX용 Reasoning Level 섹션 (0.3으로 번호 조정)
GCX_REASONING_LEVEL_SECTION = '''
## 0.3 Reasoning Level 선택 (gpt-5.1-codex-max 전용)

**gpt-5.1-codex-max 모델을 선택한 경우에만** 추가로 Reasoning Level을 선택합니다.

**AskUserQuestion 실행** (gpt-5.1-codex-max 선택 시):
```
Question: "gpt-5.1-codex-max의 Reasoning Level을 선택하세요"
Header: "Reasoning Level"
MultiSelect: false
Options:
1. "Low (빠른 응답)"
   Description: "가벼운 추론, 빠른 응답 속도"
2. "Medium (기본값, 권장)"
   Description: "속도와 추론 깊이의 균형, 일반적인 작업에 적합"
3. "High (최대 추론)"
   Description: "복잡한 문제에 대한 깊은 추론"
4. "Extra high (초고도 추론)"
   Description: "매우 복잡한 문제를 위한 최대 추론 깊이"
```

**선택 후**: 선택된 Reasoning Level을 저장하고 모든 Codex 호출 시 사용합니다.

**Reasoning Level 매핑**:
- "Low (빠른 응답)" → `low`
- "Medium (기본값, 권장)" → `medium`
- "High (최대 추론)" → `high`
- "Extra high (초고도 추론)" → `extra_high`

'''


def update_cx_file(file_path: Path) -> bool:
    """cx-* 파일에 Reasoning Level 섹션 추가"""
    try:
        content = file_path.read_text(encoding='utf-8')
        original_content = content

        # "## 0.2 Codex 호출 패턴" 찾아서 그 앞에 Reasoning Level 섹션 삽입
        if "## 0.2 Codex 호출 패턴" in content:
            content = content.replace(
                "## 0.2 Codex 호출 패턴",
                REASONING_LEVEL_SECTION + "## 0.3 Codex 호출 패턴"
            )

        # "## 0.2 Codex 호출 패턴"이 없고 다른 패턴이 있는 경우 처리
        elif "**선택 후**: 선택된 모델을 저장하고" in content:
            # "선택 후" 문장 다음에 Reasoning Level 섹션 추가
            content = content.replace(
                "**선택 후**: 선택된 모델을 저장하고 모든 Codex 호출 시 사용합니다",
                "**선택 후**: 선택된 모델을 저장하고 모든 Codex 호출 시 사용합니다" + REASONING_LEVEL_SECTION
            )

        # Codex 호출 명령어에 reasoning level 추가 설명
        if "codex exec -m" in content and "model_reasoning_effort" not in content:
            content = content.replace(
                "codex exec -m [선택된모델]",
                "codex exec -c model_reasoning_effort=[레벨] -m [선택된모델]"
            )
            content = content.replace(
                "codex full-auto -m [선택된모델]",
                "codex full-auto -c model_reasoning_effort=[레벨] -m [선택된모델]"
            )

        if content != original_content:
            file_path.write_text(content, encoding='utf-8')
            print(f"[OK] Updated: {file_path.name}")
            return True
        else:
            print(f"[SKIP] No changes needed: {file_path.name}")
            return False

    except Exception as e:
        print(f"[ERROR] Error updating {file_path.name}: {e}")
        return False


def update_gcx_file(file_path: Path) -> bool:
    """gcx-* 파일에 Reasoning Level 섹션 추가 (0.3으로)"""
    try:
        content = file_path.read_text(encoding='utf-8')
        original_content = content

        # "## 0.2 Codex 모델 선택" 섹션 다음에 Reasoning Level 섹션 삽입
        # "---" 구분선 앞에 삽입
        if "## 0.2 Codex 모델 선택" in content:
            # 0.2 섹션 끝에서 다음 "---" 전에 삽입
            lines = content.split('\n')
            new_lines = []
            in_codex_section = False
            section_ended = False

            for i, line in enumerate(lines):
                new_lines.append(line)

                if "## 0.2 Codex 모델 선택" in line:
                    in_codex_section = True

                if in_codex_section and not section_ended:
                    # "```" 닫기 후 빈 줄 찾기
                    if line == "```" and i + 1 < len(lines):
                        # 다음 줄이 빈 줄이고 그 다음이 "---"인지 확인
                        if i + 2 < len(lines) and lines[i + 1] == "" and lines[i + 2] == "---":
                            # 여기에 Reasoning Level 섹션 삽입
                            new_lines.append("")
                            new_lines.extend(GCX_REASONING_LEVEL_SECTION.rstrip('\n').split('\n'))
                            section_ended = True

            content = '\n'.join(new_lines)

        if content != original_content:
            file_path.write_text(content, encoding='utf-8')
            print(f"[OK] Updated: {file_path.name}")
            return True
        else:
            print(f"[SKIP] No changes needed: {file_path.name}")
            return False

    except Exception as e:
        print(f"[ERROR] Error updating {file_path.name}: {e}")
        return False


def main():
    """메인 실행 함수"""
    print("=" * 60)
    print("Codex Reasoning Level 선택 기능 추가 스크립트")
    print("=" * 60)
    print(f"작업 디렉토리: {COMMANDS_DIR}")
    print()

    if not COMMANDS_DIR.exists():
        print(f"[ERROR] 디렉토리가 존재하지 않습니다: {COMMANDS_DIR}")
        return

    updated_count = 0
    skipped_count = 0
    error_count = 0

    print("=== CX-* 파일 처리 ===")
    for filename in CX_FILES:
        file_path = COMMANDS_DIR / filename

        if not file_path.exists():
            print(f"[SKIP] 파일이 존재하지 않음: {filename}")
            skipped_count += 1
            continue

        result = update_cx_file(file_path)
        if result:
            updated_count += 1
        elif result is False:
            error_count += 1
        else:
            skipped_count += 1

    print()
    print("=== GCX-* 파일 처리 ===")
    for filename in GCX_FILES:
        file_path = COMMANDS_DIR / filename

        if not file_path.exists():
            print(f"[SKIP] 파일이 존재하지 않음: {filename}")
            skipped_count += 1
            continue

        result = update_gcx_file(file_path)
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

#!/usr/bin/env python3
"""
Codex 모델 이름을 최신 버전으로 업데이트하는 스크립트

구버전:
- gpt-4.1
- o4-mini

신버전:
- gpt-5.1-codex-max
- gpt-5.1-codex
- gpt-5.1-codex-mini
- gpt-5.1
"""

import os
import re
from pathlib import Path

# 업데이트 대상 파일 경로
COMMANDS_DIR = Path.home() / ".claude" / "commands" / "nam"

# cx-* 및 gcx-* 파일 목록
TARGET_FILES = [
    "cx-executor.md",
    "cx-executor-lite.md",
    "cx-planner.md",
    "cx-planner-lite.md",
    "cx-task.md",
    "gcx-executor.md",
    "gcx-executor-lite.md",
    "gcx-planner.md",
    "gcx-planner-lite.md",
    "gcx-task.md",
]

# 구버전 모델 선택 옵션 패턴 (AskUserQuestion 내부)
OLD_OPTIONS_PATTERN = r'''Options:
1\. "gpt-4\.1 \(대부분의 경우 권장\)"
   Description: "코드 리뷰.*?최적화"
2\. "o4-mini \(빠른 처리\)"
   Description: ".*?피드백"
3\. "Let AI decide \(자동 선택\)"
   Description: "Claude가.*?선택"'''

# 신버전 모델 선택 옵션 (표준화)
NEW_OPTIONS = '''Options:
1. "gpt-5.1-codex-max (최고 품질, 권장)"
   Description: "깊은 추론과 빠른 속도, 코드 품질 검증 최적화"
2. "gpt-5.1-codex (균형)"
   Description: "Codex 최적화, 대부분의 프로젝트에 적합"
3. "gpt-5.1-codex-mini (빠른 처리)"
   Description: "단순한 코드 검증, 빠른 피드백, 저렴한 비용"
4. "gpt-5.1 (범용)"
   Description: "일반적인 추론, 코드 외 작업 포함 시"'''

# gcx-* 파일용 대체 패턴 (Codex 모델 선택 부분만)
GCX_OLD_OPTIONS_PATTERN = r'''1\. "gpt-4\.1 \(대부분의 경우 권장\)"
   Description: "코드 리뷰.*?최적화"
2\. "o4-mini \(빠른 처리\)"
   Description: ".*?피드백"
3\. "Let AI decide \(자동 선택\)"
   Description: "Claude가.*?선택"'''

GCX_NEW_OPTIONS = '''1. "gpt-5.1-codex-max (최고 품질, 권장)"
   Description: "깊은 추론과 빠른 속도, 코드 품질 검증 최적화"
2. "gpt-5.1-codex (균형)"
   Description: "Codex 최적화, 대부분의 프로젝트에 적합"
3. "gpt-5.1-codex-mini (빠른 처리)"
   Description: "단순한 코드 검증, 빠른 피드백, 저렴한 비용"
4. "gpt-5.1 (범용)"
   Description: "일반적인 추론, 코드 외 작업 포함 시"'''


def update_file(file_path: Path) -> bool:
    """파일의 Codex 모델 이름을 업데이트"""
    try:
        # 파일 읽기 (UTF-8)
        content = file_path.read_text(encoding='utf-8')
        original_content = content

        # gcx-* 파일인지 확인
        is_gcx = file_path.name.startswith('gcx-')

        if is_gcx:
            # gcx-* 파일: Codex 모델 선택 부분만 업데이트
            pattern = GCX_OLD_OPTIONS_PATTERN
            replacement = GCX_NEW_OPTIONS
        else:
            # cx-* 파일: 전체 Options 블록 업데이트
            pattern = OLD_OPTIONS_PATTERN
            replacement = NEW_OPTIONS

        # 정규식 대체 (DOTALL 플래그로 여러 줄 매칭)
        content = re.sub(pattern, replacement, content, flags=re.DOTALL)

        # 변경 사항이 있으면 파일 저장
        if content != original_content:
            file_path.write_text(content, encoding='utf-8')
            print(f"[OK] Updated: {file_path.name}")
            return True
        else:
            print(f"[SKIP]  No changes needed: {file_path.name}")
            return False

    except Exception as e:
        print(f"[ERROR] Error updating {file_path.name}: {e}")
        return False


def main():
    """메인 실행 함수"""
    print("=" * 60)
    print("Codex 모델 이름 업데이트 스크립트")
    print("=" * 60)
    print(f"작업 디렉토리: {COMMANDS_DIR}")
    print()

    if not COMMANDS_DIR.exists():
        print(f"[ERROR] 디렉토리가 존재하지 않습니다: {COMMANDS_DIR}")
        return

    updated_count = 0
    skipped_count = 0
    error_count = 0

    for filename in TARGET_FILES:
        file_path = COMMANDS_DIR / filename

        if not file_path.exists():
            print(f"[SKIP]  파일이 존재하지 않음: {filename}")
            skipped_count += 1
            continue

        result = update_file(file_path)
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

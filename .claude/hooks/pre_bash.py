#!/usr/bin/env python3
"""
PreToolUse Hook (Bash)
=======================

Bash 도구 사용 전 자동 실행되는 Hook
- 환경 검증 (MSYS2, Locale, Cygpath)
- 경로 정규화 사전 검증
"""

import sys
import os
import shutil
from pathlib import Path

# 프로젝트 라이브러리 경로 추가
project_root = Path(__file__).parent.parent.parent
sys.path.insert(0, str(project_root / ".claude" / "lib"))

from environment import is_msys2_ucrt64, is_korean_locale, get_msystem


def check_cygpath() -> bool:
    """cygpath 명령어 존재 확인"""
    return shutil.which("cygpath") is not None


def main():
    """PreToolUse Hook 메인 함수"""
    try:
        # 명령어 가져오기 (환경 변수 또는 stdin)
        command = os.environ.get("CLAUDE_TOOL_COMMAND", "")

        # 중요: Bash 명령어가 경로를 다루는 경우만 검증
        # 모든 명령어에 대해 검증하면 성능 저하 발생
        needs_path_check = any(
            keyword in command
            for keyword in ["cd ", "mkdir", "cp ", "mv ", "ls ", "./", "../"]
        )

        if not needs_path_check:
            # 경로 관련 명령어가 아니면 검증 스킵
            sys.exit(0)

        # Cygpath 확인 (Windows 환경에서만)
        if os.name == "nt" or "MSYSTEM" in os.environ:
            if not check_cygpath():
                print("⚠️ cygpath가 설치되어 있지 않습니다", file=sys.stderr)
                print("   MSYS2 UCRT64 환경 사용을 권장합니다", file=sys.stderr)
                # 경고만 출력하고 계속 진행 (차단하지 않음)

        # 환경 권장사항 (로그만, 차단 X)
        if not is_msys2_ucrt64():
            msystem = get_msystem() or "MSYS2 아님"
            # 조용히 로깅만 (stderr는 사용자에게 표시되지 않음)
            pass

    except Exception as e:
        # Hook 에러는 조용히 처리
        pass


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
UserPromptSubmit Hook
======================

사용자 프롬프트 제출 시 자동으로 실행되는 Hook
- 요구사항 자동 캡처
- Baton 초기화
"""

import sys
import os
from pathlib import Path

# 프로젝트 라이브러리 경로 추가
project_root = Path(__file__).parent.parent.parent
sys.path.insert(0, str(project_root / ".claude" / "lib"))

from context_manager import BatonManager
from gcx_core import get_session_id, get_timestamp, ensure_directory


def main():
    """UserPromptSubmit Hook 메인 함수"""
    try:
        # 환경 변수에서 사용자 입력 가져오기
        # Claude Code는 Hook에 사용자 입력을 환경 변수로 전달합니다
        user_input = os.environ.get("CLAUDE_USER_INPUT", "")

        # GCX 프로젝트 시작 명령어 감지
        if user_input.startswith("/gcx-project"):
            # Baton 초기화
            manager = BatonManager(project_root)
            session_id = get_session_id()

            # 요청 추출 (명령어 뒤의 텍스트)
            parts = user_input.split(" ", 1)
            user_request = parts[1].strip('"\'') if len(parts) > 1 else "프로젝트 요청"

            # Baton 생성
            baton = manager.create_baton(user_request, session_id)

            # 요구사항 디렉토리 생성
            req_dir = ensure_directory(project_root / ".gcx" / "00_requirements")

            # 자동 캡처 파일 생성
            timestamp = get_timestamp()
            req_file = req_dir / f"user_request_{timestamp}.md"

            with open(req_file, "w", encoding="utf-8") as f:
                f.write(f"# 사용자 요청\n\n")
                f.write(f"**세션 ID**: {session_id}\n")
                f.write(f"**타임스탬프**: {timestamp}\n\n")
                f.write(f"## 요청 내용\n\n{user_request}\n")

            print(f"✅ GCX v6 세션 시작: {session_id}")
            print(f"📝 요구사항 저장: {req_file.relative_to(project_root)}")

    except Exception as e:
        # Hook 에러는 조용히 처리 (사용자 경험 방해 최소화)
        print(f"⚠️ UserPromptSubmit Hook 경고: {e}", file=sys.stderr)
        pass


if __name__ == "__main__":
    main()

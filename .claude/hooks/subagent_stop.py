#!/usr/bin/env python3
"""
SubagentStop Hook
==================

Subagent 종료 시 자동 실행되는 Hook
- 체크포인트 자동 저장
- Baton 상태 업데이트
- 진행 상황 로깅
"""

import sys
import os
import json
from pathlib import Path
from datetime import datetime

# 프로젝트 라이브러리 경로 추가
project_root = Path(__file__).parent.parent.parent
sys.path.insert(0, str(project_root / ".claude" / "lib"))

from context_manager import BatonManager
from gcx_core import get_timestamp, ensure_directory


def save_checkpoint(baton_data: dict, checkpoint_dir: Path) -> Path:
    """
    체크포인트 저장

    Args:
        baton_data: Baton 데이터
        checkpoint_dir: 체크포인트 디렉토리

    Returns:
        저장된 체크포인트 파일 경로
    """
    timestamp = get_timestamp("compact")
    session_id = baton_data.get("metadata", {}).get("session_id", "unknown")
    current_phase = baton_data.get("metadata", {}).get("current_phase", "unknown")

    checkpoint_file = checkpoint_dir / f"checkpoint_{session_id}_{current_phase}_{timestamp}.json"

    with open(checkpoint_file, "w", encoding="utf-8") as f:
        json.dump(baton_data, f, ensure_ascii=False, indent=2)

    return checkpoint_file


def log_progress(baton_data: dict, log_file: Path):
    """
    진행 상황 로깅

    Args:
        baton_data: Baton 데이터
        log_file: 로그 파일 경로
    """
    metadata = baton_data.get("metadata", {})
    session_id = metadata.get("session_id", "unknown")
    current_phase = metadata.get("current_phase", "unknown")
    updated_at = metadata.get("updated_at", datetime.now().isoformat())

    phase_results = baton_data.get("phase_results", [])
    completed_count = sum(1 for pr in phase_results if pr.get("status") == "completed")
    total_phases = metadata.get("total_phases", 6)

    log_entry = (
        f"[{updated_at}] "
        f"Session: {session_id} | "
        f"Phase: {current_phase} | "
        f"Progress: {completed_count}/{total_phases}\n"
    )

    # 로그 파일에 append
    with open(log_file, "a", encoding="utf-8") as f:
        f.write(log_entry)


def main():
    """SubagentStop Hook 메인 함수"""
    try:
        # Subagent 정보 가져오기 (환경 변수)
        agent_name = os.environ.get("CLAUDE_AGENT_NAME", "unknown")
        agent_status = os.environ.get("CLAUDE_AGENT_STATUS", "unknown")

        # Baton 로드
        manager = BatonManager(project_root)
        baton = manager.load_baton()

        if not baton:
            # Baton이 없으면 스킵
            sys.exit(0)

        baton_data = baton.to_dict()

        # 체크포인트 저장
        checkpoint_dir = ensure_directory(project_root / ".gcx" / "state" / "checkpoints")
        checkpoint_file = save_checkpoint(baton_data, checkpoint_dir)

        # 진행 상황 로깅
        log_dir = ensure_directory(project_root / ".gcx" / "logs")
        log_file = log_dir / "progress.log"
        log_progress(baton_data, log_file)

        # 성공 메시지 (stderr에만 출력, 사용자에게는 보이지 않음)
        print(
            f"✅ Checkpoint saved: {checkpoint_file.name}",
            file=sys.stderr
        )

    except Exception as e:
        # Hook 에러는 조용히 처리
        pass


if __name__ == "__main__":
    main()

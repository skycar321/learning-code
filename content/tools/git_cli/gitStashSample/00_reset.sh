#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

REMOTE_DIR="$SCRIPT_DIR/remote-repo.git"
LOCAL_DIR="$SCRIPT_DIR/my-workspace"
COLLEAGUE_DIR="$SCRIPT_DIR/colleague-workspace"

echo ">>> [00_reset] 이전 실습 데이터를 삭제하고 있습니다..."
rm -rf "$REMOTE_DIR" "$LOCAL_DIR" "$COLLEAGUE_DIR"

echo ">>> ✅ 초기화가 완료되었습니다."
echo "다음 단계 (Git Bash): bash 01_setup.sh"
echo "다음 단계 (PowerShell): powershell -ExecutionPolicy Bypass -File .\01_setup.ps1"
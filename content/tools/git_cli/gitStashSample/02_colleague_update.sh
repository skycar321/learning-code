#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REMOTE_DIR="$SCRIPT_DIR/remote-repo.git"
COLLEAGUE_DIR="$SCRIPT_DIR/colleague-workspace"
SRC_DIR="$SCRIPT_DIR/src_samples"

if [ ! -d "$REMOTE_DIR" ]; then
  echo "❌ Missing setup. Run: bash 01_setup.sh"
  exit 1
fi

echo ">>> [02_colleague_update] Updating dev branch (Complex v1.1 Update)..."
cd "$COLLEAGUE_DIR"
git checkout dev

# 동료의 CoreService v1.1 복사
cp "$SRC_DIR/CoreService_v1.1_Remote.java" CoreService.java

git add CoreService.java
git commit -m "feat: improve commonUtil performance (v1.1) and add archiving"
git push origin dev

echo ">>> [02_colleague_update] Done."
echo "✅ Next (Git Bash): bash 03_user_mixed_work.sh"
echo "✅ Next (PowerShell): powershell -ExecutionPolicy Bypass -File .\03_user_mixed_work.ps1"

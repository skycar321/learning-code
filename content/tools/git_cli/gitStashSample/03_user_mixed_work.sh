#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REMOTE_DIR="$SCRIPT_DIR/remote-repo.git"
LOCAL_DIR="$SCRIPT_DIR/my-workspace"
SRC_DIR="$SCRIPT_DIR/src_samples"

if [ ! -d "$REMOTE_DIR" ]; then
  echo "❌ Missing setup. Run previous steps."
  exit 1
fi

if [ -d "$LOCAL_DIR" ]; then
  echo "❌ Local workspace already exists. Run: bash 00_reset.sh"
  exit 1
fi

echo ">>> [03_user_mixed_work] Setting up user workspace..."
cd "$SCRIPT_DIR"
git clone "$REMOTE_DIR" "$LOCAL_DIR"
cd "$LOCAL_DIR"

git reset --hard HEAD~1

# 사용자의 CoreService (v1.0 기반 + SR1/SR2 혼합) 복사
cp "$SRC_DIR/CoreService_Local_Mixed.java" CoreService.java

cat <<EOF > sr2_config.properties
# SR2 Configuration
report.type=pdf
report.margin=10px
EOF

echo ">>> [03_user_mixed_work] Done."
echo "⚠️  [Scenario] 3-Way Conflict Prepared (Top, Middle, Bottom)."
echo "✅ Next (Git Bash): cd my-workspace"

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POWERSHELL_EXE="powershell.exe"

if ! command -v "$POWERSHELL_EXE" >/dev/null 2>&1; then
  echo "powershell.exe not found in PATH."
  exit 1
fi

: "${GCX_FIX_CODEX_WRAPPER:=1}"

exec "$POWERSHELL_EXE" -ExecutionPolicy Bypass -File "$SCRIPT_DIR/gcx_apply_all.ps1"

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POWERSHELL_EXE="powershell.exe"

is_wsl() {
  if [[ -n "${WSL_DISTRO_NAME-}" || -n "${WSL_INTEROP-}" ]]; then
    return 0
  fi
  if [[ -r /proc/version ]] && grep -qi microsoft /proc/version 2>/dev/null; then
    return 0
  fi
  return 1
}

if is_wsl; then
  echo "ERROR: Detected WSL. Run this script from MSYS2 (UCRT64), not WSL."
  echo "Tip: In MSYS2, Windows drives are mounted as /c/..., not /mnt/c/..."
  exit 1
fi

if ! command -v "$POWERSHELL_EXE" >/dev/null 2>&1; then
  echo "powershell.exe not found in PATH."
  exit 1
fi

: "${GCX_FIX_CODEX_WRAPPER:=1}"
: "${GCX_FIX_VSCODE_DROP:=1}"

exec "$POWERSHELL_EXE" -ExecutionPolicy Bypass -File "$SCRIPT_DIR/gcx_apply_all_v2.ps1"

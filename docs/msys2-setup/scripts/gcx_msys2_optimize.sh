#!/usr/bin/env bash
set -euo pipefail

# GCX MSYS2 optimization orchestrator (non-WSL)
# - Backs up key files to .gcx/state/msys2_backups
# - Runs local MSYS2 setup/repair scripts in a safe order
# - Optional installs only when missing

ROOT=""
find_root() {
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/.claude/settings.json" ]]; then
      ROOT="$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

if ! find_root; then
  echo "Could not find repo root (missing .claude/settings.json)."
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_BASE="$ROOT/.gcx/state/msys2_backups"
TS="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="$BACKUP_BASE/backup_$TS"
mkdir -p "$BACKUP_DIR"

MANIFEST="$BACKUP_DIR/backup_manifest.txt"
touch "$MANIFEST"

backup_file() {
  local src="$1"
  if [[ -f "$src" ]]; then
    cp -f "$src" "$BACKUP_DIR/$(basename "$src")"
    echo "$src" >> "$MANIFEST"
  fi
}

# Backups (best-effort)
backup_file "/etc/passwd"
backup_file "$HOME/.bashrc"
backup_file "$HOME/.zshrc"
backup_file "$HOME/.zprofile"
backup_file "$HOME/.zshenv"

log() { echo "[GCX] $*"; }

run_script() {
  local path="$1"
  if [[ -f "$path" ]]; then
    log "Running: $(basename "$path")"
    bash "$path" </dev/null || true
  else
    log "Skip (missing): $path"
  fi
}

log "Backup directory: $BACKUP_DIR"

# Ensure /etc/passwd exists (needed by fix_default_shell.sh)
if [[ ! -f /etc/passwd ]]; then
  if command -v mkpasswd >/dev/null 2>&1; then
    log "Creating /etc/passwd with mkpasswd"
    mkpasswd -l -c > /etc/passwd
  else
    log "mkpasswd not found; /etc/passwd will remain missing"
  fi
fi

# Optional installs (only if missing)
if [[ "${GCX_INCLUDE_INSTALL:-0}" == "1" ]]; then
  if ! command -v zsh >/dev/null 2>&1; then
    run_script "$SCRIPT_DIR/1_msys2_auto_install.sh"
  fi
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    run_script "$SCRIPT_DIR/2_install_ohmyzsh.sh"
  fi
  if ! command -v node >/dev/null 2>&1; then
    run_script "$SCRIPT_DIR/install_nodejs_npm.sh"
  fi
fi

# Non-install optimizations
run_script "$SCRIPT_DIR/fix_default_shell.sh"
run_script "$SCRIPT_DIR/fix_zsh_setup.sh"
run_script "$SCRIPT_DIR/fix_zshrc_error.sh"
run_script "$SCRIPT_DIR/fix_windows_terminal_path.sh"
run_script "$SCRIPT_DIR/fix_claude_gemini_wrappers.sh"
run_script "$SCRIPT_DIR/check_node_path.sh"
run_script "$SCRIPT_DIR/diagnose_terminal.sh"

log "Done."
log "Backup: $BACKUP_DIR"

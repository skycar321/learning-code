#!/usr/bin/env bash
set -euo pipefail

# Revert GCX MSYS2 optimizations using latest backup in .gcx/state/msys2_backups

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

BACKUP_BASE="$ROOT/.gcx/state/msys2_backups"
if [[ ! -d "$BACKUP_BASE" ]]; then
  echo "No backup directory: $BACKUP_BASE"
  exit 1
fi

BACKUP_DIR="${1:-}"
if [[ -z "$BACKUP_DIR" ]]; then
  BACKUP_DIR="$(ls -1 "$BACKUP_BASE" | sort | tail -n1)"
  BACKUP_DIR="$BACKUP_BASE/$BACKUP_DIR"
fi

if [[ ! -d "$BACKUP_DIR" ]]; then
  echo "Backup not found: $BACKUP_DIR"
  exit 1
fi

restore_file() {
  local src="$1"
  local dst="$2"
  if [[ -f "$src" ]]; then
    cp -f "$src" "$dst"
  fi
}

restore_file "$BACKUP_DIR/passwd" "/etc/passwd"
restore_file "$BACKUP_DIR/.bashrc" "$HOME/.bashrc"
restore_file "$BACKUP_DIR/.zshrc" "$HOME/.zshrc"
restore_file "$BACKUP_DIR/.zprofile" "$HOME/.zprofile"
restore_file "$BACKUP_DIR/.zshenv" "$HOME/.zshenv"

echo "[GCX] Restored from: $BACKUP_DIR"
echo "[GCX] Restart MSYS2 shell to apply."

#!/usr/bin/env bash
set -euo pipefail

log() { printf '[GCX] %s\n' "$*"; }
warn() { printf '[GCX][WARN] %s\n' "$*" >&2; }
err() { printf '[GCX][ERROR] %s\n' "$*" >&2; }

user="${USER:-$(whoami)}"

if ! command -v zsh >/dev/null 2>&1; then
  err "zsh not found. Install with: pacman -S zsh"
  exit 1
fi

zsh_bin="$(command -v zsh)"

ensure_passwd() {
  if [[ -f /etc/passwd ]]; then
    return 0
  fi
  if command -v mkpasswd >/dev/null 2>&1; then
    log "Creating /etc/passwd with mkpasswd"
    if mkpasswd -l -c > /etc/passwd 2>/dev/null; then
      log "/etc/passwd created"
    else
      warn "Failed to write /etc/passwd (permissions). Try running MSYS2 as admin."
    fi
  else
    warn "mkpasswd not found; /etc/passwd remains missing"
  fi
}

update_passwd_shell() {
  if [[ ! -f /etc/passwd ]]; then
    return 0
  fi
  if ! grep -q "^${user}:" /etc/passwd; then
    warn "User '$user' not found in /etc/passwd"
    return 0
  fi
  if sed -E -i.bak "s|^(${user}:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:).*|\\1${zsh_bin}|" /etc/passwd 2>/dev/null; then
    log "Default shell set to $zsh_bin in /etc/passwd"
  else
    warn "Failed to update /etc/passwd (permissions)"
  fi
}

ensure_bashrc_block() {
  local bashrc="$HOME/.bashrc"
  local start="# >>> GCX auto zsh"
  local end="# <<< GCX auto zsh"
  if [[ ! -f "$bashrc" ]]; then
    touch "$bashrc"
  fi
  if grep -q "$start" "$bashrc"; then
    return 0
  fi
  cat >> "$bashrc" <<'EOF'

# >>> GCX auto zsh
if [ -t 1 ] && [ -z "${ZSH_VERSION-}" ] && [ -z "${GCX_DISABLE_AUTO_ZSH-}" ]; then
  if command -v zsh >/dev/null 2>&1; then
    export SHELL="$(command -v zsh)"
    exec zsh
  fi
fi
# <<< GCX auto zsh
EOF
  log "Added auto zsh block to ~/.bashrc"
}

log "Start: $(date '+%Y-%m-%d %H:%M:%S')"
ensure_passwd
update_passwd_shell
ensure_bashrc_block

export SHELL="$zsh_bin"
log "SHELL set to $SHELL (current session)"
log "Done."

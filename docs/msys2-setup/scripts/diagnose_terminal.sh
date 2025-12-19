#!/usr/bin/env bash
# MSYS2 terminal diagnostics (ASCII-safe)
# Usage: bash diagnose_terminal.sh

set -u

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()    { echo -e "${CYAN}i${NC} $1"; }
log_ok()      { echo -e "${GREEN}ok${NC} $1"; }
log_warn()    { echo -e "${YELLOW}warn${NC} $1"; }
log_err()     { echo -e "${RED}err${NC} $1"; }
log_header()  { echo -e "\n${BLUE}== $1 ==${NC}"; }

clear || true
echo -e "${BLUE}MSYS2 Terminal Diagnostics${NC}\n"

issues=0

log_header "1) Environment"
log_info "USER: ${USER:-'(not set)'}"
log_info "HOME: ${HOME:-'(not set)'}"
log_info "SHELL: ${SHELL:-'(not set)'}"
log_info "MSYSTEM: ${MSYSTEM:-'(not set)'}"
log_info "PATH (head): ${PATH:0:120}..."

log_header "2) Default shell"
if [[ "${SHELL:-}" == "/usr/bin/zsh" || "${SHELL:-}" == "/bin/zsh" ]]; then
  log_ok "Default shell is zsh"
else
  log_warn "Default shell is not zsh: ${SHELL:-'(not set)'}"
  log_info "Fix: run docs/msys2-setup/scripts/fix_default_shell.sh"
  issues=$((issues+1))
fi

log_header "3) /etc/passwd"
if [[ -f /etc/passwd ]]; then
  user_line="$(grep "^${USER}:" /etc/passwd 2>/dev/null || true)"
  if [[ -n "$user_line" ]]; then
    login_shell="$(echo "$user_line" | awk -F: '{print $NF}')"
    log_info "Login shell: $login_shell"
    if [[ "$login_shell" == "/usr/bin/zsh" || "$login_shell" == "/bin/zsh" ]]; then
      log_ok "/etc/passwd uses zsh"
    else
      log_warn "/etc/passwd does not use zsh"
      issues=$((issues+1))
    fi
  else
    log_warn "User entry not found in /etc/passwd"
    issues=$((issues+1))
  fi
else
  log_warn "/etc/passwd not found (MSYS2 may not be configured)"
  issues=$((issues+1))
fi

log_header "4) zsh installed"
if command -v zsh >/dev/null 2>&1; then
  log_ok "zsh path: $(command -v zsh)"
  log_info "zsh version: $(zsh --version | head -n1)"
else
  log_err "zsh not installed"
  log_info "Fix: pacman -S zsh"
  issues=$((issues+1))
fi

log_header "5) oh-my-zsh / plugins"
if [[ -d "$HOME/.oh-my-zsh" ]]; then
  log_ok "oh-my-zsh found"
else
  log_warn "oh-my-zsh not found"
  issues=$((issues+1))
fi
[[ -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]] && log_ok "powerlevel10k found" || log_warn "powerlevel10k missing"
[[ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]] && log_ok "zsh-autosuggestions found" || log_warn "zsh-autosuggestions missing"
[[ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]] && log_ok "zsh-syntax-highlighting found" || log_warn "zsh-syntax-highlighting missing"

log_header "6) .zshrc / .bashrc"
if [[ -f "$HOME/.zshrc" ]]; then
  log_ok ".zshrc exists"
  grep -q 'ZSH="$HOME/.oh-my-zsh"' "$HOME/.zshrc" && log_ok "oh-my-zsh configured" || log_warn "oh-my-zsh config missing"
  grep -q 'powerlevel10k/powerlevel10k' "$HOME/.zshrc" && log_ok "p10k theme configured" || log_warn "p10k theme missing"
else
  log_warn ".zshrc not found"
  issues=$((issues+1))
fi

if [[ -f "$HOME/.bashrc" ]]; then
  grep -q "exec zsh" "$HOME/.bashrc" && log_ok ".bashrc auto zsh enabled" || log_warn ".bashrc auto zsh not set"
else
  log_warn ".bashrc not found"
fi

log_header "7) VS Code profile"
vscode_settings="$HOME/AppData/Roaming/Code/User/settings.json"
vscode_settings_alt="/c/Users/$USER/AppData/Roaming/Code/User/settings.json"
if [[ -f "$vscode_settings" || -f "$vscode_settings_alt" ]]; then
  settings_file="$vscode_settings"
  [[ -f "$vscode_settings_alt" ]] && settings_file="$vscode_settings_alt"
  if grep -q "MSYS2 UCRT64" "$settings_file" 2>/dev/null; then
    log_ok "VS Code profile includes MSYS2 UCRT64"
  else
    log_warn "VS Code profile missing MSYS2 UCRT64"
  fi
else
  log_warn "VS Code settings.json not found"
fi

log_header "8) Fonts (MesloLGS)"
if [[ -d "/c/Windows/Fonts" ]]; then
  count=$(find /c/Windows/Fonts -iname "*MesloLGS*" 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$count" -gt 0 ]]; then
    log_ok "MesloLGS found: $count"
  else
    log_warn "MesloLGS not found"
  fi
else
  log_warn "Windows Fonts dir not found"
fi

log_header "Summary"
if [[ "$issues" -eq 0 ]]; then
  log_ok "No blocking issues detected"
else
  log_warn "Issues detected: $issues"
  log_info "Re-run: bash docs/msys2-setup/scripts/fix_default_shell.sh"
fi

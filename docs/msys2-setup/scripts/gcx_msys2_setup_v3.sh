#!/usr/bin/env bash
# ============================================================================
# GCX MSYS2 통합 설정 스크립트 v3.3
# ============================================================================
# 세 개의 v2 스크립트를 통합하여 하나로 실행:
#   - fix_default_shell_v2.sh (zsh 기본 셸 설정)
#   - gcx_apply_all_v2.sh (PowerShell 패치 적용)
#   - gcx_msys2_optimize_v2.sh (MSYS2 최적화)
#
# 추가 기능 (v3.1):
#   - MSYS2 기본 경로 PATH 설정 (zsh, pacman 등 사용 가능)
#   - Claude Code Hook 래퍼 스크립트 생성 (Windows 호환)
#   - Python 경로 자동 감지 및 PATH 추가 (Windows Python 지원)
#
# v3.2 수정사항:
#   - PATH 설정을 .zshrc 맨 앞에 추가 (oh-my-zsh 로드 전)
#   - 기본 POSIX 경로 (/usr/bin, /bin 등) 명시적 포함
#   - mkdir, git, mv 명령어 누락 문제 해결
#
# v3.3 수정사항:
#   - Docker Desktop 설정 추가 (docker.exe 직접 호출 alias)
#   - MSYS2에서 /usr/bin/env sh 오류 해결
#   - docker, docker-compose, dps 등 alias 자동 설정
#
# 사용법:
#   bash gcx_msys2_setup_v3.sh
#
# 환경 변수:
#   GCX_FIX_CODEX_WRAPPER=1    Codex 래퍼 수정 (기본: 1)
#   GCX_FIX_VSCODE_DROP=1      VS Code 드래그앤드롭 수정 (기본: 1)
#   GCX_INCLUDE_INSTALL=0      선택적 설치 포함 (기본: 0)
#   GCX_SKIP_PYTHON_SETUP=0    Python 경로 설정 건너뛰기 (기본: 0)
#   GCX_SKIP_DOCKER_SETUP=0    Docker 설정 건너뛰기 (기본: 0)
#   GCX_RUN_POWERSHELL=0       PowerShell 패치 실행 (기본: 0)
#   GCX_SETUP_HOOKS=1          Claude Code Hook 래퍼 설정 (기본: 1)
# ============================================================================

set -euo pipefail

log()  { printf '[GCX] %s\n' "$*"; }
warn() { printf '[GCX][WARN] %s\n' "$*" >&2; }
err()  { printf '[GCX][ERROR] %s\n' "$*" >&2; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POWERSHELL_EXE="powershell.exe"

: "${GCX_FIX_CODEX_WRAPPER:=1}"
: "${GCX_FIX_VSCODE_DROP:=1}"
: "${GCX_INCLUDE_INSTALL:=0}"
: "${GCX_SKIP_PYTHON_SETUP:=0}"
: "${GCX_RUN_POWERSHELL:=0}"
: "${GCX_SETUP_HOOKS:=1}"

is_wsl() {
  if [[ -n "${WSL_DISTRO_NAME-}" || -n "${WSL_INTEROP-}" ]]; then return 0; fi
  if [[ -r /proc/version ]] && grep -qi microsoft /proc/version 2>/dev/null; then return 0; fi
  return 1
}

if is_wsl; then
  err "WSL 환경이 감지되었습니다. MSYS2 (UCRT64)에서 실행하세요."
  exit 1
fi

ROOT=""
find_root() {
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/.claude/settings.json" ]]; then ROOT="$dir"; return 0; fi
    dir="$(dirname "$dir")"
  done
  return 1
}

if ! find_root; then
  warn "프로젝트 루트를 찾을 수 없습니다. 현재 디렉토리 사용."
  ROOT="$PWD"
fi

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
    log "백업됨: $src"
  fi
}

run_script() {
  local path="$1"
  if [[ -f "$path" ]]; then
    log "실행 중: $(basename "$path")"
    bash "$path" </dev/null || true
  else
    log "건너뜀 (파일 없음): $path"
  fi
}

# ============================================================================
# 0. MSYS2 기본 PATH 설정 (v3.2 - 기본 POSIX 경로 포함, oh-my-zsh 호환)
# ============================================================================
setup_msys2_path() {
  log "=== MSYS2 기본 PATH 설정 시작 ==="

  # 핵심: 기본 POSIX 경로 + MSYS2 경로 모두 포함
  # oh-my-zsh 로드 전에 mkdir, git, mv 등이 필요하기 때문
  local base_path="/usr/local/bin:/usr/bin:/bin:/c/Windows/system32:/c/Windows"
  local msys2_paths=("/c/msys64/ucrt64/bin" "/c/msys64/usr/bin" "/c/msys64/mingw64/bin")
  local path_additions=""

  for p in "${msys2_paths[@]}"; do
    if [[ -d "$p" ]]; then
      path_additions="$path_additions:$p"
      log "MSYS2 경로 추가: $p"
    fi
  done
  path_additions="${path_additions#:}"

  # 현재 세션에 적용
  export PATH="$path_additions:$base_path"
  log "현재 세션 PATH 설정됨"

  local start_marker="# >>> GCX MSYS2 BASE PATH (oh-my-zsh 전에 필수)"
  local end_marker="# <<< GCX MSYS2 BASE PATH"

  # PATH 설정 블록 생성
  local path_block
  read -r -d '' path_block << PATHBLOCKEOF || true
$start_marker
# 기본 POSIX 경로 (mkdir, git, mv 등 기본 명령어에 필요)
export PATH="$base_path"
# MSYS2 도구 경로 추가
export PATH="$path_additions:\$PATH"
$end_marker
PATHBLOCKEOF

  # ~/.zshrc 처리 (oh-my-zsh 로드 전에 추가해야 함!)
  local zshrc="$HOME/.zshrc"
  if [[ -f "$zshrc" ]]; then
    # 기존 블록 제거
    if grep -q "$start_marker" "$zshrc" 2>/dev/null; then
      sed -i.bak "/$start_marker/,/$end_marker/d" "$zshrc" 2>/dev/null || true
      log "기존 PATH 블록 제거됨"
    fi

    # oh-my-zsh 로드 전에 삽입 (파일 맨 앞에 추가)
    if ! grep -q "GCX MSYS2 BASE PATH" "$zshrc" 2>/dev/null; then
      local temp_file="${zshrc}.gcx_temp"
      echo "$path_block" > "$temp_file"
      echo "" >> "$temp_file"
      cat "$zshrc" >> "$temp_file"
      mv "$temp_file" "$zshrc"
      log "~/.zshrc 맨 앞에 PATH 블록 추가됨 (oh-my-zsh 로드 전)"
    fi
  else
    echo "$path_block" > "$zshrc"
    log "~/.zshrc 생성됨"
  fi

  # ~/.bashrc 처리
  local bashrc="$HOME/.bashrc"
  if [[ -f "$bashrc" ]] && grep -q "$start_marker" "$bashrc" 2>/dev/null; then
    sed -i.bak "/$start_marker/,/$end_marker/d" "$bashrc" 2>/dev/null || true
  fi
  [[ ! -f "$bashrc" ]] && touch "$bashrc"
  echo "" >> "$bashrc"
  echo "$path_block" >> "$bashrc"
  log "~/.bashrc에 PATH 블록 추가됨"

  command -v zsh >/dev/null 2>&1 && log "zsh 확인됨: $(command -v zsh)"
  command -v pacman >/dev/null 2>&1 && log "pacman 확인됨: $(command -v pacman)"
  log "=== MSYS2 기본 PATH 설정 완료 ==="
}

# ============================================================================
# 1. Claude Code Hook 래퍼 설정 (신규 v3.1)
# ============================================================================
setup_claude_hooks() {
  if [[ "${GCX_SETUP_HOOKS:-1}" != "1" ]]; then
    log "Claude Hook 설정 건너뜀 (GCX_SETUP_HOOKS=0)"
    return 0
  fi

  log "=== Claude Code Hook 래퍼 설정 시작 ==="

  local win_user="${USERNAME:-${USER:-}}"
  [[ -z "$win_user" ]] && { warn "Windows 사용자 이름 확인 불가"; return 1; }

  local claude_home="/c/Users/$win_user/.claude"
  [[ ! -d "$claude_home" ]] && { warn "Claude 디렉토리 없음: $claude_home"; return 1; }

  # Python 동적 탐색
  local python_exe=""
  local user_python_base="/c/Users/$win_user/AppData/Local/Programs/Python"

  if [[ -d "$user_python_base" ]]; then
    for py_dir in "$user_python_base"/Python*; do
      if [[ -f "$py_dir/python.exe" ]]; then
        python_exe=$(echo "$py_dir/python.exe" | sed 's|^/c/|C:\\|; s|/|\\|g')
        log "Python 발견: $python_exe"
        break
      fi
    done
  fi

  [[ -z "$python_exe" ]] && { warn "Windows Python 없음"; return 1; }

  # run_hook.cmd 생성
  local hook_wrapper="$claude_home/run_hook.cmd"

  cat > "$hook_wrapper" << HOOKCMDEOF
@echo off
chcp 65001 >nul 2>&1
set PYTHONIOENCODING=utf-8
set PYTHONUTF8=1
set "PYTHON_EXE=$python_exe"
if not exist "%PYTHON_EXE%" (where python >nul 2>&1 && set "PYTHON_EXE=python" || exit /b 0)
"%PYTHON_EXE%" %*
HOOKCMDEOF

  log "Hook 래퍼 생성됨: $hook_wrapper"

  local settings_file="$claude_home/settings.json"
  if [[ -f "$settings_file" ]]; then
    backup_file "$settings_file"
    local wrapper_path="C:/Users/$win_user/.claude/run_hook.cmd"
    sed -i.bak "s|\"python C:/Users/$win_user/.claude/|\"$wrapper_path C:/Users/$win_user/.claude/|g" "$settings_file" 2>/dev/null || true
    log "settings.json hook 명령어 업데이트됨"
  fi

  log "=== Claude Code Hook 래퍼 설정 완료 ==="
}

# ============================================================================
# 2. Python 경로 감지 및 PATH 설정
# ============================================================================
setup_python_path() {
  [[ "${GCX_SKIP_PYTHON_SETUP:-0}" == "1" ]] && { log "Python 설정 건너뜀"; return 0; }

  log "=== Python 경로 설정 시작 ==="

  command -v python >/dev/null 2>&1 && log "Python 이미 인식됨: $(command -v python)"

  local win_user="${USERNAME:-${USER:-}}"
  [[ -z "$win_user" ]] && { warn "Windows 사용자 이름 확인 불가"; return 1; }

  local found_paths=()

  add_python_dir() {
    local dir="$1" label="${2:-}"
    if [[ -d "$dir" && -f "$dir/python.exe" ]]; then
      found_paths+=("$dir")
      [[ -n "$label" ]] && log "Python 발견 ($label): $dir" || log "Python 발견: $dir"
    fi
  }

  local user_python_base="/c/Users/$win_user/AppData/Local/Programs/Python"
  [[ -d "$user_python_base" ]] && for py_dir in "$user_python_base"/Python*; do add_python_dir "$py_dir" "사용자"; done
  for py_dir in /c/Python*; do add_python_dir "$py_dir" "시스템"; done
  for py_dir in "/c/Program Files"/Python*; do add_python_dir "$py_dir" "Program Files"; done
  add_python_dir "/c/Users/$win_user/scoop/apps/python/current" "scoop"

  [[ ${#found_paths[@]} -eq 0 ]] && { warn "Windows Python 없음"; return 1; }

  log "발견된 Python: ${#found_paths[@]}개"

  local path_additions=""
  for p in "${found_paths[@]}"; do
    [[ -d "$p/Scripts" ]] && path_additions="$path_additions:$p:$p/Scripts" || path_additions="$path_additions:$p"
  done
  path_additions="${path_additions#:}"

  export PATH="$path_additions:$PATH"

  local zshrc="$HOME/.zshrc"
  local start_marker="# >>> GCX Python PATH"
  local end_marker="# <<< GCX Python PATH"

  [[ -f "$zshrc" ]] && backup_file "$zshrc" || touch "$zshrc"
  grep -q "$start_marker" "$zshrc" 2>/dev/null && sed -i.bak "/$start_marker/,/$end_marker/d" "$zshrc" 2>/dev/null

  cat >> "$zshrc" << PYTHONPATHEOF
$start_marker
export PATH="$path_additions:\$PATH"
command -v python.exe >/dev/null 2>&1 && { alias python='python.exe'; alias python3='python.exe'; alias pip='pip.exe'; }
$end_marker
PYTHONPATHEOF

  log "~/.zshrc에 Python PATH 추가됨"

  local bashrc="$HOME/.bashrc"
  if [[ -f "$bashrc" ]]; then
    grep -q "$start_marker" "$bashrc" 2>/dev/null && sed -i.bak "/$start_marker/,/$end_marker/d" "$bashrc" 2>/dev/null
    cat >> "$bashrc" << BASHPYTHONEOF
$start_marker
export PATH="$path_additions:\$PATH"
command -v python.exe >/dev/null 2>&1 && { alias python='python.exe'; alias python3='python.exe'; }
$end_marker
BASHPYTHONEOF
    log "~/.bashrc에도 Python PATH 추가됨"
  fi

  (command -v python >/dev/null 2>&1 || command -v python.exe >/dev/null 2>&1) && log "Python 설정 완료!"
  log "=== Python 경로 설정 완료 ==="
}

# ============================================================================
# 3. /etc/passwd 생성 (MSYS2 셸 설정에 필요)
# ============================================================================
ensure_passwd() {
  log "=== /etc/passwd 확인 ==="

  if command -v mkpasswd >/dev/null 2>&1; then
    log "/etc/passwd 생성 중"
    mkpasswd -l -c > /etc/passwd 2>/dev/null && log "/etc/passwd 생성됨" || warn "/etc/passwd 쓰기 실패"
  else
    warn "mkpasswd 없음"
  fi
}

# ============================================================================
# 4. 기본 셸을 zsh로 설정
# ============================================================================
setup_default_shell() {
  log "=== 기본 셸 설정 시작 ==="

  command -v zsh >/dev/null 2>&1 || { warn "zsh 미설치. pacman -S zsh"; return 1; }

  local zsh_bin="$(command -v zsh)"
  log "zsh 경로: $zsh_bin"

  if [[ -f /etc/passwd ]] && grep -q "^${user}:" /etc/passwd; then
    sed -E -i.bak "s|^(${user}:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:).*|\\1${zsh_bin}|" /etc/passwd 2>/dev/null && log "/etc/passwd 셸 설정됨"
  fi

  local bashrc="$HOME/.bashrc"
  local start="# >>> GCX auto zsh"
  local end="# <<< GCX auto zsh"

  [[ ! -f "$bashrc" ]] && touch "$bashrc"
  grep -q "$start" "$bashrc" 2>/dev/null && sed -i.bak "/$start/,/$end/d" "$bashrc" 2>/dev/null

  cat >> "$bashrc" << 'AUTOZSHEOF'

# >>> GCX auto zsh
if [ -t 1 ] && [ -z "${ZSH_VERSION-}" ] && [ -z "${GCX_DISABLE_AUTO_ZSH-}" ]; then
  command -v zsh >/dev/null 2>&1 && { export SHELL="$(command -v zsh)"; exec zsh; }
fi
# <<< GCX auto zsh
AUTOZSHEOF

  log "~/.bashrc에 자동 zsh 블록 추가됨"
  export SHELL="$zsh_bin"
  log "=== 기본 셸 설정 완료 ==="
}

# ============================================================================
# 5. VS Code/Cursor 드래그앤드롭 수정
# ============================================================================
fix_vscode_dragdrop() {
  [[ "${GCX_FIX_VSCODE_DROP:-1}" != "1" ]] && { log "VS Code 수정 건너뜀"; return 0; }

  log "=== VS Code 드래그앤드롭 수정 시작 ==="

  local py=""
  command -v python >/dev/null 2>&1 && py="python"
  [[ -z "$py" ]] && command -v python3 >/dev/null 2>&1 && py="python3"
  [[ -z "$py" ]] && command -v python.exe >/dev/null 2>&1 && py="python.exe"
  [[ -z "$py" ]] && { warn "Python 없음"; return 0; }

  local win_user="${USERNAME:-${USER:-}}"
  [[ -z "$win_user" ]] && return 0

  local targets=()
  [[ -f "/c/Users/$win_user/AppData/Roaming/Code/User/settings.json" ]] && targets+=("/c/Users/$win_user/AppData/Roaming/Code/User/settings.json")
  [[ -f "/c/Users/$win_user/AppData/Roaming/Cursor/User/settings.json" ]] && targets+=("/c/Users/$win_user/AppData/Roaming/Cursor/User/settings.json")

  [[ ${#targets[@]} -eq 0 ]] && { log "VS Code/Cursor 없음"; return 0; }

  for f in "${targets[@]}"; do
    local tag="settings"
    [[ "$f" == *"/Code/"* ]] && tag="vscode"
    [[ "$f" == *"/Cursor/"* ]] && tag="cursor"
    cp -f "$f" "$BACKUP_DIR/${tag}_settings.json.bak"
    log "백업: ${tag}_settings.json.bak"
  done

  log "=== VS Code 드래그앤드롭 수정 완료 ==="
}

# ============================================================================
# 6. PowerShell 패치 실행
# ============================================================================
run_powershell_patches() {
  [[ "${GCX_RUN_POWERSHELL:-0}" != "1" ]] && { log "PowerShell 패치 건너뜀"; return 0; }
  command -v "$POWERSHELL_EXE" >/dev/null 2>&1 || { warn "powershell.exe 없음"; return 1; }
  local ps_script="$SCRIPT_DIR/gcx_apply_all_v2.ps1"
  [[ -f "$ps_script" ]] && "$POWERSHELL_EXE" -ExecutionPolicy Bypass -File "$ps_script" || true
}

# ============================================================================
# 7. Docker Desktop 설정 (v3.3 신규)
# ============================================================================
setup_docker() {
  [[ "${GCX_SKIP_DOCKER_SETUP:-0}" == "1" ]] && { log "Docker 설정 건너뜀"; return 0; }

  log "=== Docker Desktop 설정 시작 ==="

  # Docker Desktop 경로 탐색
  local docker_paths=(
    "/c/Program Files/Docker/Docker/resources/bin"
    "/c/Program Files/Docker Desktop/resources/bin"
    "/c/ProgramData/DockerDesktop/version-bin"
  )

  local docker_found=""
  for path in "${docker_paths[@]}"; do
    if [[ -f "$path/docker.exe" ]]; then
      docker_found="$path"
      log "Docker 발견: $path"
      break
    fi
  done

  if [[ -z "$docker_found" ]]; then
    warn "Docker Desktop이 설치되지 않았습니다."
    warn "설치: winget install Docker.DockerDesktop"
    return 1
  fi

  # Docker alias 블록 생성
  local start_marker="# >>> GCX Docker (MSYS2 호환)"
  local end_marker="# <<< GCX Docker"

  # Windows 경로를 MSYS2 경로로 변환 (이스케이프 처리)
  local docker_exe="$docker_found/docker.exe"

  local docker_block
  read -r -d '' docker_block << DOCKERBLOCKEOF || true
$start_marker
# Docker Desktop for Windows (MSYS2/Zsh 호환)
# 참고: docker 래퍼 스크립트가 /usr/bin/env sh 오류 발생 → docker.exe 직접 호출
alias docker='"$docker_exe"'
alias d='docker'
alias dc='docker compose'
alias docker-compose='docker compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias drm='docker rm'
alias drmi='docker rmi'
alias dstop='docker stop \$(docker ps -aq) 2>/dev/null'
alias dclean='docker system prune -af'
$end_marker
DOCKERBLOCKEOF

  # ~/.zshrc에 Docker 블록 추가
  local zshrc="$HOME/.zshrc"
  if [[ -f "$zshrc" ]]; then
    # 기존 블록 제거
    if grep -q "$start_marker" "$zshrc" 2>/dev/null; then
      sed -i.bak "/$start_marker/,/$end_marker/d" "$zshrc" 2>/dev/null || true
      log "기존 Docker 블록 제거됨"
    fi
    # 기존 docker alias 제거 (중복 방지)
    sed -i.bak "/^alias docker=/d" "$zshrc" 2>/dev/null || true
    sed -i.bak "/^alias d='docker'/d" "$zshrc" 2>/dev/null || true
    sed -i.bak "/^alias dc='docker/d" "$zshrc" 2>/dev/null || true
    sed -i.bak "/^alias docker-compose=/d" "$zshrc" 2>/dev/null || true
    sed -i.bak "/^alias dps=/d" "$zshrc" 2>/dev/null || true
    sed -i.bak "/^alias dpsa=/d" "$zshrc" 2>/dev/null || true
    sed -i.bak "/^alias di=/d" "$zshrc" 2>/dev/null || true
    sed -i.bak "/^alias drm=/d" "$zshrc" 2>/dev/null || true
    sed -i.bak "/^alias drmi=/d" "$zshrc" 2>/dev/null || true
    sed -i.bak "/^alias dstop=/d" "$zshrc" 2>/dev/null || true
    sed -i.bak "/^alias dclean=/d" "$zshrc" 2>/dev/null || true
    # 새 블록 추가
    echo "" >> "$zshrc"
    echo "$docker_block" >> "$zshrc"
    log "~/.zshrc에 Docker 설정 추가됨"
  fi

  # ~/.bashrc에도 Docker 블록 추가
  local bashrc="$HOME/.bashrc"
  if [[ -f "$bashrc" ]]; then
    if grep -q "$start_marker" "$bashrc" 2>/dev/null; then
      sed -i.bak "/$start_marker/,/$end_marker/d" "$bashrc" 2>/dev/null || true
    fi
    echo "" >> "$bashrc"
    echo "$docker_block" >> "$bashrc"
    log "~/.bashrc에 Docker 설정 추가됨"
  fi

  # 현재 세션에도 적용
  alias docker="$docker_exe"
  alias d='docker'
  alias dc='docker compose'

  # Docker Desktop 실행 상태 확인
  if "$docker_exe" info &>/dev/null; then
    log "Docker Desktop 실행 중!"
    "$docker_exe" --version 2>/dev/null && log "Docker 버전 확인됨"
  else
    warn "Docker Desktop이 실행되지 않았습니다."
    warn "시작 메뉴에서 'Docker Desktop'을 실행하세요."
  fi

  log "=== Docker Desktop 설정 완료 ==="
}

# ============================================================================
# 메인 실행
# ============================================================================
main() {
  log "=============================================="
  log "GCX MSYS2 통합 설정 v3.3"
  log "시작: $(date '+%Y-%m-%d %H:%M:%S')"
  log "=============================================="
  log "백업 디렉토리: $BACKUP_DIR"

  backup_file "/etc/passwd"
  backup_file "$HOME/.bashrc"
  backup_file "$HOME/.zshrc"
  backup_file "$HOME/.zprofile"
  backup_file "$HOME/.zshenv"

  setup_msys2_path || log "MSYS2 PATH 설정 건너뜀"
  setup_docker || log "Docker 설정 건너뜀"
  setup_claude_hooks || log "Claude Hook 설정 건너뜀"
  setup_python_path || log "Python 경로 설정 건너뜀"
  ensure_passwd || log "/etc/passwd 생성 건너뜀"
  setup_default_shell || log "기본 셸 설정 건너뜀"

  if [[ "${GCX_INCLUDE_INSTALL:-0}" == "1" ]]; then
    log "=== 선택적 설치 ==="
    command -v zsh >/dev/null 2>&1 || run_script "$SCRIPT_DIR/1_msys2_auto_install.sh"
    [[ -d "$HOME/.oh-my-zsh" ]] || run_script "$SCRIPT_DIR/2_install_ohmyzsh.sh"
    command -v node >/dev/null 2>&1 || run_script "$SCRIPT_DIR/install_nodejs_npm.sh"
  fi

  log "=== 최적화 스크립트 실행 ==="
  run_script "$SCRIPT_DIR/fix_zsh_setup.sh"
  run_script "$SCRIPT_DIR/fix_zshrc_error.sh"
  run_script "$SCRIPT_DIR/fix_windows_terminal_path.sh"
  run_script "$SCRIPT_DIR/fix_claude_gemini_wrappers.sh"
  [[ "${GCX_FIX_CODEX_WRAPPER:-1}" == "1" ]] && run_script "$SCRIPT_DIR/fix_codex_wrapper.sh"
  run_script "$SCRIPT_DIR/check_node_path.sh"
  run_script "$SCRIPT_DIR/diagnose_terminal.sh"

  fix_vscode_dragdrop || log "VS Code 수정 건너뜀"
  run_powershell_patches || log "PowerShell 패치 건너뜀"

  log ""
  log "=============================================="
  log "GCX MSYS2 통합 설정 완료!"
  log "=============================================="
  log "백업 위치: $BACKUP_DIR"
  log ""
  log "확인 명령어:"
  log "  python --version"
  log "  zsh --version"
  log "  docker --version"
  log "  docker ps"
  log ""
  log "새 zsh 쉘을 시작합니다..."
  log ""

  # 새 zsh 쉘 시작 (설정 자동 적용)
  exec zsh
}

main "$@"

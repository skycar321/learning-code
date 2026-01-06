#!/usr/bin/env bash
# ============================================================================
# GCX MSYS2 통합 설정 스크립트 v3.6
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
# v3.4 수정사항 (핵심 수정):
#   - npm 글로벌 CLI 도구 경로 변환 문제 해결
#   - MSYS2에서 claude, gemini, codex 명령어 실행 시 경로 오류 수정
#   - C:\msys64\Users\... 대신 C:\Users\... 경로 사용하도록 수정
#   - cmd.exe를 통해 .cmd 파일 직접 호출하여 경로 변환 우회
#
# v3.5 수정사항 (Windows fifo 호환성):
#   - Powerlevel10k gitstatus 오류 해결 (Windows에서 fifo 생성 불가)
#   - .zshrc에 POWERLEVEL9K_DISABLE_GITSTATUS=true 자동 추가
#   - .bashrc auto zsh 블록에 BASH_EXECUTION_STRING 조건 추가
#   - exec zsh 전에 환경변수 설정으로 gitstatus 비활성화
#
# v3.6 수정사항 (필수 패키지 자동 설치):
#   - jq, yq, curl, wget 등 필수 CLI 도구 자동 설치
#   - MSYSTEM 환경에 맞는 패키지 자동 선택 (ucrt64/mingw64/msys)
#   - Claude Code 및 Ralph Loop 완벽 지원을 위한 의존성 해결
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
#   GCX_SKIP_NPM_CLI_SETUP=0   npm CLI 도구 설정 건너뛰기 (기본: 0)
#   GCX_RUN_POWERSHELL=0       PowerShell 패치 실행 (기본: 0)
#   GCX_SETUP_HOOKS=1          Claude Code Hook 래퍼 설정 (기본: 1)
#   GCX_SKIP_ESSENTIAL_TOOLS=0 필수 도구 설치 건너뛰기 (기본: 0)
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
# 1. Claude Code Hook 래퍼 설정 (v3.5 수정 - sed 오류 해결)
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

  # Python 동적 탐색 (v3.5 수정: sed 대신 직접 문자열 변환)
  local python_exe=""
  local python_exe_win=""
  local user_python_base="/c/Users/$win_user/AppData/Local/Programs/Python"

  if [[ -d "$user_python_base" ]]; then
    for py_dir in "$user_python_base"/Python*; do
      if [[ -f "$py_dir/python.exe" ]]; then
        python_exe="$py_dir/python.exe"
        # MSYS2 경로를 Windows 경로로 변환 (sed 없이)
        python_exe_win="${python_exe/\/c\//C:\\}"
        python_exe_win="${python_exe_win//\//\\}"
        log "Python 발견: $python_exe_win"
        break
      fi
    done
  fi

  [[ -z "$python_exe_win" ]] && { warn "Windows Python 없음"; return 1; }

  # run_hook.cmd 생성
  local hook_wrapper="$claude_home/run_hook.cmd"

  cat > "$hook_wrapper" << HOOKCMDEOF
@echo off
chcp 65001 >nul 2>&1
set PYTHONIOENCODING=utf-8
set PYTHONUTF8=1
set "PYTHON_EXE=$python_exe_win"
if not exist "%PYTHON_EXE%" (where python >nul 2>&1 && set "PYTHON_EXE=python" || exit /b 0)
"%PYTHON_EXE%" %*
HOOKCMDEOF

  log "Hook 래퍼 생성됨: $hook_wrapper"

  # settings.json 수정은 건너뜀 (사용자가 이미 bash 래퍼 사용 중일 수 있음)
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
# 3. /etc/passwd 생성 (MSYS2 셸 설정에 필요) - v3.5 수정
# ============================================================================
ensure_passwd() {
  log "=== /etc/passwd 확인 ==="

  # /etc/passwd가 이미 존재하면 건너뜀
  if [[ -f /etc/passwd ]] && grep -q "^${USER:-$(whoami)}:" /etc/passwd 2>/dev/null; then
    log "/etc/passwd 이미 존재함"
    return 0
  fi

  if command -v mkpasswd >/dev/null 2>&1; then
    log "/etc/passwd 생성 중"
    # 쓰기 권한 확인
    if [[ -w /etc ]] || [[ -w /etc/passwd ]]; then
      mkpasswd -l -c > /etc/passwd 2>/dev/null && log "/etc/passwd 생성됨" || warn "/etc/passwd 쓰기 실패 (권한 없음)"
    else
      warn "/etc 쓰기 권한 없음 - 관리자 권한으로 MSYS2를 실행하세요"
    fi
  else
    warn "mkpasswd 없음 - pacman -S msys2-runtime 으로 설치"
  fi
}

# ============================================================================
# 4. 기본 셸을 zsh로 설정 (v3.5 수정 - Windows fifo 호환성)
# ============================================================================
setup_default_shell() {
  log "=== 기본 셸 설정 시작 ==="

  command -v zsh >/dev/null 2>&1 || { warn "zsh 미설치. pacman -S zsh"; return 1; }

  local zsh_bin="$(command -v zsh)"
  log "zsh 경로: $zsh_bin"

  local current_user="${USER:-$(whoami)}"
  if [[ -f /etc/passwd ]] && grep -q "^${current_user}:" /etc/passwd; then
    sed -E -i.bak "s|^(${current_user}:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:).*|\\1${zsh_bin}|" /etc/passwd 2>/dev/null && log "/etc/passwd 셸 설정됨"
  fi

  # zsh에서 gitstatus/async 비활성화 (Windows fifo 호환성 문제 해결)
  local zshrc="$HOME/.zshrc"
  local gitstatus_marker="# >>> GCX Windows Compatibility"
  local gitstatus_end="# <<< GCX Windows Compatibility"

  if [[ -f "$zshrc" ]] && ! grep -q "$gitstatus_marker" "$zshrc" 2>/dev/null; then
    # .zshrc 맨 앞에 gitstatus 비활성화 설정 추가
    local temp_zshrc="${zshrc}.gcx_temp"
    cat > "$temp_zshrc" << 'GITSTATUSEOF'
# >>> GCX Windows Compatibility
# Windows/MSYS2에서 Unix fifo 파일을 생성할 수 없어서 gitstatus 오류 발생
# 해결: gitstatus와 비동기 프롬프트 비활성화
export POWERLEVEL9K_DISABLE_GITSTATUS=true
export POWERLEVEL9K_DISABLE_ASYNC=true
# <<< GCX Windows Compatibility

GITSTATUSEOF
    cat "$zshrc" >> "$temp_zshrc"
    mv "$temp_zshrc" "$zshrc"
    log "~/.zshrc에 gitstatus 비활성화 설정 추가됨"
  fi

  local bashrc="$HOME/.bashrc"
  local start="# >>> GCX auto zsh"
  local end="# <<< GCX auto zsh"

  [[ ! -f "$bashrc" ]] && touch "$bashrc"
  grep -q "$start" "$bashrc" 2>/dev/null && sed -i.bak "/$start/,/$end/d" "$bashrc" 2>/dev/null

  # v3.5: BASH_EXECUTION_STRING 조건 추가 - 스크립트 실행 시에는 zsh 전환 안 함
  cat >> "$bashrc" << 'AUTOZSHEOF'

# >>> GCX auto zsh
# 조건: 인터랙티브 터미널 + bash 환경 + 비활성화 안 됨 + 명령 문자열 없음
if [ -t 1 ] && [ -z "${ZSH_VERSION-}" ] && [ -z "${GCX_DISABLE_AUTO_ZSH-}" ] && [ -z "${BASH_EXECUTION_STRING-}" ]; then
  if command -v zsh >/dev/null 2>&1; then
    export SHELL="$(command -v zsh)"
    export POWERLEVEL9K_DISABLE_GITSTATUS=true
    export POWERLEVEL9K_DISABLE_ASYNC=true
    exec zsh
  fi
fi
# <<< GCX auto zsh
AUTOZSHEOF

  log "~/.bashrc에 자동 zsh 블록 추가됨 (Windows 호환 조건 포함)"
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
# 7. npm 글로벌 CLI 도구 경로 수정 (v3.4 신규)
# ============================================================================
# 문제: MSYS2에서 npm 래퍼 스크립트 실행 시 경로가 잘못 변환됨
#   - 잘못된 경로: C:\msys64\Users\Nam\AppData\Roaming\npm\...
#   - 올바른 경로: C:\Users\Nam\AppData\Roaming\npm\...
# 해결: node.exe를 직접 호출하여 Windows 경로로 모듈 실행
# ============================================================================
setup_npm_cli_tools() {
  [[ "${GCX_SKIP_NPM_CLI_SETUP:-0}" == "1" ]] && { log "npm CLI 설정 건너뜀"; return 0; }

  log "=== npm 글로벌 CLI 도구 경로 수정 시작 ==="

  local win_user="${USERNAME:-${USER:-}}"
  [[ -z "$win_user" ]] && { warn "Windows 사용자 이름 확인 불가"; return 1; }

  # npm 글로벌 경로
  local npm_modules="/c/Users/$win_user/AppData/Roaming/npm/node_modules"
  local npm_bin="/c/Users/$win_user/AppData/Roaming/npm"

  if [[ ! -d "$npm_modules" ]]; then
    warn "npm 글로벌 모듈 디렉토리 없음: $npm_modules"
    return 1
  fi

  log "npm 글로벌 경로: $npm_bin"

  # Windows node.exe 경로 찾기
  local node_exe=""
  local node_paths=(
    "/c/Program Files/nodejs/node.exe"
    "/c/Users/$win_user/scoop/apps/nodejs/current/node.exe"
    "/c/nodejs/node.exe"
  )

  for np in "${node_paths[@]}"; do
    if [[ -f "$np" ]]; then
      node_exe="$np"
      log "Node.js 발견: $np"
      break
    fi
  done

  if [[ -z "$node_exe" ]]; then
    warn "Windows Node.js를 찾을 수 없습니다."
    return 1
  fi

  # CLI 도구 목록과 엔트리 포인트
  declare -A cli_entries
  cli_entries["claude"]="@anthropic-ai/claude-code/cli.js"
  cli_entries["gemini"]="@google/gemini-cli/dist/index.js"
  cli_entries["codex"]="@openai/codex/bin/codex.js"

  local found_tools=()

  for tool in "${!cli_entries[@]}"; do
    local entry="${cli_entries[$tool]}"
    if [[ -f "$npm_modules/$entry" ]]; then
      found_tools+=("$tool")
      log "발견: $tool ($entry)"
    fi
  done

  if [[ ${#found_tools[@]} -eq 0 ]]; then
    warn "npm 글로벌 CLI 도구가 설치되지 않았습니다."
    warn "설치 명령어:"
    warn "  npm install -g @anthropic-ai/claude-code"
    warn "  npm install -g @google/gemini-cli"
    warn "  npm install -g @openai/codex"
    return 1
  fi

  # Windows 경로 형식 (C:/ 형식)
  local win_npm_modules="C:/Users/$win_user/AppData/Roaming/npm/node_modules"

  local start_marker="# >>> GCX npm CLI Tools (MSYS2 경로 수정)"
  local end_marker="# <<< GCX npm CLI Tools"

  # 함수 블록 생성 (node.exe를 직접 호출)
  local func_block="$start_marker
# MSYS2에서 npm 글로벌 CLI 도구 경로 변환 문제 해결
# node.exe를 직접 호출하여 Windows 경로로 모듈 실행
export PATH=\"$npm_bin:\$PATH\"
export GCX_NODE_EXE=\"$node_exe\"
export GCX_NPM_MODULES=\"$win_npm_modules\""

  for tool in "${found_tools[@]}"; do
    local entry="${cli_entries[$tool]}"
    func_block="$func_block
$tool() { \"\$GCX_NODE_EXE\" \"\$GCX_NPM_MODULES/$entry\" \"\$@\"; }"
  done

  func_block="$func_block
$end_marker"

  # ~/.zshrc 업데이트
  local zshrc="$HOME/.zshrc"
  if [[ -f "$zshrc" ]]; then
    # 기존 블록 제거
    if grep -q "$start_marker" "$zshrc" 2>/dev/null; then
      sed -i.bak "/$start_marker/,/$end_marker/d" "$zshrc" 2>/dev/null || true
      log "기존 npm CLI 블록 제거됨"
    fi
    # 새 블록 추가
    echo "" >> "$zshrc"
    echo "$func_block" >> "$zshrc"
    log "~/.zshrc에 npm CLI 도구 설정 추가됨"
  fi

  # ~/.bashrc 업데이트
  local bashrc="$HOME/.bashrc"
  if [[ -f "$bashrc" ]]; then
    if grep -q "$start_marker" "$bashrc" 2>/dev/null; then
      sed -i.bak "/$start_marker/,/$end_marker/d" "$bashrc" 2>/dev/null || true
    fi
    echo "" >> "$bashrc"
    echo "$func_block" >> "$bashrc"
    log "~/.bashrc에 npm CLI 도구 설정 추가됨"
  fi

  # 현재 세션에 적용
  export PATH="$npm_bin:$PATH"
  export GCX_NODE_EXE="$node_exe"
  export GCX_NPM_MODULES="$win_npm_modules"

  for tool in "${found_tools[@]}"; do
    local entry="${cli_entries[$tool]}"
    eval "$tool() { \"\$GCX_NODE_EXE\" \"\$GCX_NPM_MODULES/$entry\" \"\$@\"; }"
    log "함수 정의됨: $tool"
  done

  log "=== npm 글로벌 CLI 도구 경로 수정 완료 ==="
}

# ============================================================================
# 8. Docker Desktop 설정 (v3.3 신규)
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
# 9. 필수 CLI 도구 설치 (v3.6 신규)
# ============================================================================
# Claude Code, Ralph Loop, GCX 프레임워크에서 필요한 CLI 도구들을 자동 설치
# - jq: JSON 처리 (Ralph Loop, hooks에서 필수)
# - yq: YAML 처리
# - curl, wget: HTTP 요청
# - tree: 디렉토리 구조 출력
# - ripgrep (rg): 빠른 검색
# ============================================================================
setup_essential_tools() {
  [[ "${GCX_SKIP_ESSENTIAL_TOOLS:-0}" == "1" ]] && { log "필수 도구 설치 건너뜀"; return 0; }

  log "=== 필수 CLI 도구 설치 시작 ==="

  # MSYSTEM 환경 확인 (UCRT64, MINGW64, MSYS 등)
  local msystem="${MSYSTEM:-UCRT64}"
  local pkg_prefix=""

  case "$msystem" in
    UCRT64)
      pkg_prefix="mingw-w64-ucrt-x86_64"
      log "MSYSTEM: UCRT64 (권장)"
      ;;
    MINGW64)
      pkg_prefix="mingw-w64-x86_64"
      log "MSYSTEM: MINGW64"
      ;;
    MINGW32)
      pkg_prefix="mingw-w64-i686"
      log "MSYSTEM: MINGW32"
      ;;
    CLANGARM64)
      pkg_prefix="mingw-w64-clang-aarch64"
      log "MSYSTEM: CLANGARM64"
      ;;
    *)
      # MSYS 환경이거나 알 수 없는 경우
      pkg_prefix=""
      log "MSYSTEM: $msystem (MSYS 패키지 사용)"
      ;;
  esac

  # pacman 확인
  if ! command -v pacman >/dev/null 2>&1; then
    warn "pacman이 없습니다. MSYS2 환경에서 실행하세요."
    return 1
  fi

  # 설치할 도구 목록 (명령어 이름, MSYS2 패키지명)
  declare -A essential_tools
  if [[ -n "$pkg_prefix" ]]; then
    # MinGW 환경 (UCRT64, MINGW64 등)
    essential_tools=(
      ["jq"]="${pkg_prefix}-jq"
      ["yq"]="${pkg_prefix}-yq"
      ["curl"]="${pkg_prefix}-curl"
      ["wget"]="${pkg_prefix}-wget"
      ["tree"]="tree"
      ["rg"]="${pkg_prefix}-ripgrep"
    )
  else
    # MSYS 환경
    essential_tools=(
      ["jq"]="jq"
      ["yq"]="yq"
      ["curl"]="curl"
      ["wget"]="wget"
      ["tree"]="tree"
      ["rg"]="ripgrep"
    )
  fi

  local missing_packages=()
  local installed_count=0
  local skipped_count=0

  # 각 도구 확인 및 설치 목록 수집
  for tool in "${!essential_tools[@]}"; do
    local pkg="${essential_tools[$tool]}"
    if command -v "$tool" >/dev/null 2>&1; then
      log "✓ $tool 이미 설치됨"
      ((skipped_count++)) || true
    else
      log "✗ $tool 미설치 → $pkg 설치 예정"
      missing_packages+=("$pkg")
    fi
  done

  # 누락된 패키지 설치
  if [[ ${#missing_packages[@]} -gt 0 ]]; then
    log "패키지 설치 중: ${missing_packages[*]}"

    # pacman 데이터베이스 업데이트 (조용히)
    pacman -Sy --noconfirm >/dev/null 2>&1 || true

    # 패키지 설치
    for pkg in "${missing_packages[@]}"; do
      log "설치 중: $pkg"
      if pacman -S --noconfirm "$pkg" >/dev/null 2>&1; then
        log "✓ $pkg 설치 완료"
        ((installed_count++)) || true
      else
        warn "✗ $pkg 설치 실패 - 수동 설치 필요: pacman -S $pkg"
      fi
    done

    # 설치 후 PATH 즉시 업데이트 (새로 설치된 도구 사용 가능하게)
    case "$msystem" in
      UCRT64)  export PATH="/c/msys64/ucrt64/bin:$PATH" ;;
      MINGW64) export PATH="/c/msys64/mingw64/bin:$PATH" ;;
      MINGW32) export PATH="/c/msys64/mingw32/bin:$PATH" ;;
      *)       export PATH="/c/msys64/usr/bin:$PATH" ;;
    esac
    log "PATH 업데이트됨 - 새 도구 즉시 사용 가능"
  fi

  # 설치 결과 요약
  log ""
  log "=== 필수 도구 설치 결과 ==="
  log "  새로 설치: $installed_count개"
  log "  이미 설치됨: $skipped_count개"

  # 설치 확인
  local verify_failed=0
  for tool in jq yq curl wget; do
    if command -v "$tool" >/dev/null 2>&1; then
      log "  ✓ $tool: $(command -v "$tool")"
    else
      warn "  ✗ $tool: 설치 확인 실패"
      ((verify_failed++)) || true
    fi
  done

  if [[ $verify_failed -gt 0 ]]; then
    warn "일부 도구 설치 실패. 새 터미널에서 다시 시도하세요."
  fi

  log "=== 필수 CLI 도구 설치 완료 ==="
}

# ============================================================================
# 메인 실행
# ============================================================================
main() {
  log "=============================================="
  log "GCX MSYS2 통합 설정 v3.6"
  log "시작: $(date '+%Y-%m-%d %H:%M:%S')"
  log "=============================================="
  log "백업 디렉토리: $BACKUP_DIR"

  backup_file "/etc/passwd"
  backup_file "$HOME/.bashrc"
  backup_file "$HOME/.zshrc"
  backup_file "$HOME/.zprofile"
  backup_file "$HOME/.zshenv"

  setup_msys2_path || log "MSYS2 PATH 설정 건너뜀"
  setup_essential_tools || log "필수 CLI 도구 설치 건너뜀"  # v3.6: jq, yq, curl 등
  setup_npm_cli_tools || log "npm CLI 도구 설정 건너뜀"
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
  log "  claude --version"
  log "  gemini --version"
  log "  codex --version"
  log "  python --version"
  log "  zsh --version"
  log "  docker --version"
  log "  jq --version       # v3.6 추가"
  log "  yq --version       # v3.6 추가"
  log ""

  # v3.6: 환경변수 설정 후 zsh 시작 (gitstatus 오류 방지)
  if [[ "${GCX_SKIP_ZSH_START:-0}" != "1" ]] && command -v zsh >/dev/null 2>&1; then
    log "새 zsh 쉘을 시작합니다..."
    log "(gitstatus 비활성화됨 - Windows 호환성)"
    log ""
    export POWERLEVEL9K_DISABLE_GITSTATUS=true
    export POWERLEVEL9K_DISABLE_ASYNC=true
    exec zsh
  else
    log "설정 완료! 새 터미널을 열거나 'exec zsh'를 실행하세요."
    log ""
  fi
}

main "$@"

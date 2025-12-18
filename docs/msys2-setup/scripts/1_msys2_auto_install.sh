#!/bin/bash
# MSYS2 완전 자동 설치 스크립트
# 실행: bash msys2_auto_install.sh
#
# 이 스크립트는 다음을 자동으로 설치합니다:
# - 필수 패키지 (zsh, git, curl, vim 등)
# - oh-my-zsh
# - Powerlevel10k 테마
# - zsh 플러그인 (autosuggestions, syntax-highlighting)
# - 완전한 .zshrc 설정
# - .bashrc 자동 zsh 실행 설정

set -e  # 오류 발생 시 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 로그 함수
log_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

log_header() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC} $1"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# 메인 시작
clear
log_header "MSYS2 완전 자동 설치 스크립트"

log_info "시작 시간: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Step 1: 환경 확인
log_header "Step 1: 환경 확인"
log_info "HOME: ${HOME:-'(not set)'}"
log_info "USER: ${USER:-'(not set)'}"
log_info "SHELL: ${SHELL:-'(not set)'}"
log_info "현재 위치: $(pwd)"
echo ""

# Step 2: 시스템 업데이트
log_header "Step 2: MSYS2 시스템 업데이트"
log_info "pacman 데이터베이스 업데이트 중..."

if pacman -Sy --noconfirm > /dev/null 2>&1; then
    log_success "pacman 데이터베이스 업데이트 완료"
else
    log_warning "pacman 업데이트 건너뜀 (이미 최신)"
fi
echo ""

# Step 3: 필수 패키지 설치
log_header "Step 3: 필수 패키지 설치"

PACKAGES=(
    "zsh"
    "git"
    "curl"
    "wget"
    "vim"
    "nano"
    "openssh"
    "rsync"
    "tmux"
    "htop"
    "tree"
    "unzip"
    "zip"
)

for package in "${PACKAGES[@]}"; do
    if pacman -Qi "$package" > /dev/null 2>&1; then
        log_success "$package: 이미 설치됨"
    else
        log_info "$package 설치 중..."
        if pacman -S --noconfirm --needed "$package" > /dev/null 2>&1; then
            log_success "$package 설치 완료"
        else
            log_error "$package 설치 실패"
        fi
    fi
done
echo ""

# Step 4: zsh 버전 확인
log_header "Step 4: zsh 버전 확인"
ZSH_VERSION=$(zsh --version 2>/dev/null | head -1)
log_success "zsh 버전: $ZSH_VERSION"
echo ""

# Step 5: 기존 설정 백업
log_header "Step 5: 기존 설정 백업"

BACKUP_DIR="$HOME/.msys2_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
log_info "백업 디렉토리: $BACKUP_DIR"

if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc"
    log_success ".zshrc 백업 완료"
fi

if [ -f "$HOME/.bashrc" ]; then
    cp "$HOME/.bashrc" "$BACKUP_DIR/.bashrc"
    log_success ".bashrc 백업 완료"
fi

if [ -d "$HOME/.oh-my-zsh" ]; then
    log_warning "기존 oh-my-zsh 발견, 제거 후 재설치합니다"
    rm -rf "$HOME/.oh-my-zsh"
fi
echo ""

# Step 6: oh-my-zsh 설치
log_header "Step 6: oh-my-zsh 설치"

log_info "oh-my-zsh 다운로드 및 설치 중..."
export RUNZSH=no
export KEEP_ZSHRC=no

if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
    log_success "oh-my-zsh 설치 완료"
else
    log_error "oh-my-zsh 설치 실패"
    exit 1
fi

# 설치 확인
if [ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    log_success "oh-my-zsh.sh 파일 확인됨"
else
    log_error "oh-my-zsh.sh 파일을 찾을 수 없습니다"
    exit 1
fi
echo ""

# Step 7: Powerlevel10k 테마 설치
log_header "Step 7: Powerlevel10k 테마 설치"

THEME_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
log_info "설치 경로: $THEME_DIR"

if [ -d "$THEME_DIR" ]; then
    log_warning "기존 Powerlevel10k 제거 중..."
    rm -rf "$THEME_DIR"
fi

log_info "Powerlevel10k 다운로드 중..."
if git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$THEME_DIR" > /dev/null 2>&1; then
    log_success "Powerlevel10k 설치 완료"
else
    log_error "Powerlevel10k 설치 실패"
    exit 1
fi
echo ""

# Step 8: zsh 플러그인 설치
log_header "Step 8: zsh 플러그인 설치"

# zsh-autosuggestions
PLUGIN_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [ -d "$PLUGIN_DIR" ]; then
    rm -rf "$PLUGIN_DIR"
fi
log_info "zsh-autosuggestions 설치 중..."
if git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUGIN_DIR" > /dev/null 2>&1; then
    log_success "zsh-autosuggestions 설치 완료"
else
    log_error "zsh-autosuggestions 설치 실패"
fi

# zsh-syntax-highlighting
PLUGIN_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
if [ -d "$PLUGIN_DIR" ]; then
    rm -rf "$PLUGIN_DIR"
fi
log_info "zsh-syntax-highlighting 설치 중..."
if git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGIN_DIR" > /dev/null 2>&1; then
    log_success "zsh-syntax-highlighting 설치 완료"
else
    log_error "zsh-syntax-highlighting 설치 실패"
fi
echo ""

# Step 9: .zshrc 설정 파일 작성
log_header "Step 9: .zshrc 설정 파일 작성"

log_info "완전한 .zshrc 파일 생성 중..."

cat > "$HOME/.zshrc" << 'ZSHRC_EOF'
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  colored-man-pages
  command-not-found
  extract
  sudo
)

# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh

# ============================================================================
# User Configuration
# ============================================================================

# UTF-8 설정
export LANG=ko_KR.UTF-8
export LC_ALL=ko_KR.UTF-8

# Editor
export EDITOR=vim
export VISUAL=vim

# ============================================================================
# Aliases - 기본
# ============================================================================

# 디렉토리 리스팅
alias ll='ls -alh --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias lt='ls -alht --color=auto'  # 시간순 정렬

# 디렉토리 이동
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# 색상 지원
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias diff='diff --color=auto'

# 안전한 파일 조작
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# 유틸리티
alias cls='clear'
alias h='history'
alias j='jobs -l'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%Y-%m-%d %H:%M:%S"'
alias ports='netstat -tulanp'

# ============================================================================
# Aliases - Git
# ============================================================================

alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -m'
alias gca='git commit --amend'
alias gp='git push'
alias gpl='git pull'
alias gl='git log --oneline --graph --decorate --all'
alias gd='git diff'
alias gdc='git diff --cached'
alias gco='git checkout'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gm='git merge'
alias gr='git remote -v'
alias gf='git fetch'
alias gst='git stash'
alias gstp='git stash pop'

# ============================================================================
# Aliases - MSYS2 패키지 관리
# ============================================================================

alias update='pacman -Syu'
alias install='pacman -S'
alias pkgsearch='pacman -Ss'
alias remove='pacman -R'
alias autoremove='pacman -Rns $(pacman -Qtdq)'
alias list-installed='pacman -Q'
alias clean='pacman -Sc'

# ============================================================================
# Aliases - 디렉토리 단축
# ============================================================================

alias home='cd ~'
alias downloads='cd /c/Users/$USER/Downloads'
alias desktop='cd /c/Users/$USER/Desktop'
alias documents='cd /c/Users/$USER/Documents'
alias proj='cd /c/Users/$USER/Documents/Cursor/Workspace/origin/learning-code'

# ============================================================================
# Aliases - 개발 도구
# ============================================================================

# Python
alias py='python'
alias py3='python3'
alias pip='python -m pip'

# Node.js
alias ni='npm install'
alias nid='npm install --save-dev'
alias nig='npm install -g'
alias nr='npm run'
alias ns='npm start'
alias nt='npm test'

# Docker (설치된 경우)
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias drm='docker rm'
alias drmi='docker rmi'
alias dstop='docker stop $(docker ps -aq)'
alias dclean='docker system prune -af'

# ============================================================================
# Functions
# ============================================================================

# 디렉토리 생성 후 이동
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# 파일 내용 검색 (alias 충돌 방지를 위해 'findtext'로 명명)
findtext() {
    if [ $# -eq 0 ]; then
        echo "Usage: findtext <pattern> [path]"
        return 1
    fi
    grep -r "$1" "${2:-.}"
}

# 압축 해제 (extract 플러그인도 사용 가능)
unpack() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# 프로세스 검색
psgrep() {
    if [ $# -eq 0 ]; then
        echo "Usage: psgrep <process_name>"
        return 1
    fi
    ps aux | grep -i "$1" | grep -v grep
}

# 프로세스 종료
pskill() {
    if [ $# -eq 0 ]; then
        echo "Usage: pskill <process_name>"
        return 1
    fi
    ps aux | grep -i "$1" | grep -v grep | awk '{print $2}' | xargs kill -9
}

# 빠른 백업
backup() {
    if [ $# -eq 0 ]; then
        echo "Usage: backup <file>"
        return 1
    fi
    cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
}

# 파일 크기 확인
filesize() {
    if [ $# -eq 0 ]; then
        du -sh * | sort -h
    else
        du -sh "$@"
    fi
}

# Git 브랜치 정리
git-clean-branches() {
    git branch --merged | grep -v "\*" | grep -v "master" | grep -v "main" | xargs -n 1 git branch -d
}

# 빠른 서버 실행
serve() {
    local port="${1:-8000}"
    python3 -m http.server "$port"
}

# JSON 포맷팅
jsonformat() {
    if [ $# -eq 0 ]; then
        python3 -m json.tool
    else
        python3 -m json.tool "$1"
    fi
}

# 코드 라인 수 계산
countlines() {
    local dir="${1:-.}"
    find "$dir" -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.java" -o -name "*.cpp" -o -name "*.c" -o -name "*.sh" \) -exec wc -l {} + | sort -n
}

# 디렉토리 트리 (tree가 없을 때)
ltr() {
    local depth="${1:-2}"
    find . -maxdepth "$depth" -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'
}

# 빠른 메모
note() {
    local note_file="$HOME/notes.txt"
    if [ $# -eq 0 ]; then
        cat "$note_file" 2>/dev/null || echo "No notes yet"
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" >> "$note_file"
        echo "Note added!"
    fi
}

# 디스크 사용량 TOP 10
diskusage() {
    du -h --max-depth=1 | sort -hr | head -10
}

# 포트 확인
portcheck() {
    local port="${1}"
    if [ -z "$port" ]; then
        echo "Usage: portcheck <port>"
        return 1
    fi
    netstat -ano | findstr ":$port"
}

# 빠른 alias 확인
aliases() {
    alias | grep "$1"
}

# 환경변수 확인
envgrep() {
    env | grep -i "$1"
}

# ============================================================================
# History Configuration
# ============================================================================

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt SHARE_HISTORY              # 세션 간 히스토리 공유
setopt HIST_IGNORE_ALL_DUPS       # 중복 명령어 제거
setopt HIST_FIND_NO_DUPS          # 검색 시 중복 제거
setopt HIST_REDUCE_BLANKS         # 공백 제거
setopt HIST_IGNORE_SPACE          # 공백으로 시작하는 명령어 무시
setopt HIST_VERIFY                # 히스토리 확장 시 실행 전 확인

# ============================================================================
# Completion Configuration
# ============================================================================

autoload -Uz compinit && compinit

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'  # 대소문자 무시
zstyle ':completion:*' list-colors ''                    # 색상 지원
zstyle ':completion:*' menu select                       # 메뉴 선택
zstyle ':completion:*' group-name ''                     # 그룹화
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'

# ============================================================================
# Key Bindings
# ============================================================================

# Ctrl+P/N으로 히스토리 검색
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward

# Home/End 키
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

# Delete 키
bindkey '^[[3~' delete-char

# Ctrl+Left/Right로 단어 이동
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# ============================================================================
# Powerlevel10k Configuration
# ============================================================================

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
ZSHRC_EOF

log_success ".zshrc 파일 생성 완료 ($(wc -l < $HOME/.zshrc) lines)"
echo ""

# Step 10: .bashrc 설정
log_header "Step 10: .bashrc 설정"

if [ -f "$HOME/.bashrc" ]; then
    if grep -q "exec zsh" "$HOME/.bashrc"; then
        log_success ".bashrc 이미 zsh 자동 실행 설정됨"
    else
        log_info ".bashrc에 zsh 자동 실행 추가 중..."
        cat >> "$HOME/.bashrc" << 'BASHRC_EOF'

# Start zsh automatically
if [ -t 1 ] && command -v zsh &> /dev/null; then
  exec zsh
fi
BASHRC_EOF
        log_success ".bashrc 설정 완료"
    fi
else
    log_info ".bashrc 생성 중..."
    cat > "$HOME/.bashrc" << 'BASHRC_EOF'
# Start zsh automatically
if [ -t 1 ] && command -v zsh &> /dev/null; then
  exec zsh
fi
BASHRC_EOF
    log_success ".bashrc 생성 완료"
fi
echo ""

# Step 11: 설치 확인
log_header "Step 11: 설치 확인"

CHECKS=(
    "$HOME/.oh-my-zsh/oh-my-zsh.sh:oh-my-zsh"
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k:Powerlevel10k 테마"
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions:zsh-autosuggestions"
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting:zsh-syntax-highlighting"
    "$HOME/.zshrc:.zshrc 설정 파일"
)

ALL_OK=true
for check in "${CHECKS[@]}"; do
    IFS=':' read -r path name <<< "$check"
    if [ -e "$path" ]; then
        log_success "$name"
    else
        log_error "$name (누락)"
        ALL_OK=false
    fi
done
echo ""

# Step 12: 최종 요약
log_header "완료!"

if [ "$ALL_OK" = true ]; then
    log_success "모든 설치가 성공적으로 완료되었습니다!"
else
    log_warning "일부 항목이 설치되지 않았습니다. 위의 오류를 확인하세요."
fi

echo ""
log_info "종료 시간: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}                  ${GREEN}🎉 설치 완료! 🎉${NC}                         ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}다음 단계:${NC}"
echo ""
echo -e "  1. 터미널을 닫고 다시 열거나, 다음 명령어 실행:"
echo -e "     ${GREEN}exec zsh${NC}"
echo ""
echo -e "  2. Powerlevel10k 설정 마법사가 자동으로 시작됩니다."
echo -e "     ${CYAN}Character Set${NC} 질문에서:"
echo -e "     - 위쪽 예시가 깨지지 않으면 ${GREEN}1 (Unicode)${NC}"
echo -e "     - 깨져보이면 ${YELLOW}2 (ASCII)${NC} 선택 후 Nerd Font 설치"
echo ""
echo -e "  3. 수동으로 설정하려면:"
echo -e "     ${GREEN}p10k configure${NC}"
echo ""
echo -e "${YELLOW}Nerd Font 설치 (아이콘 표시용):${NC}"
echo -e "  https://github.com/romkatv/powerlevel10k#manual-font-installation"
echo -e "  MesloLGS NF 폰트를 다운로드하여 설치하세요."
echo ""
echo -e "${YELLOW}백업 파일 위치:${NC}"
echo -e "  $BACKUP_DIR"
echo ""
echo -e "${YELLOW}문제가 발생한 경우:${NC}"
echo -e "  - 백업 복원: ${GREEN}cp $BACKUP_DIR/.zshrc ~/.zshrc${NC}"
echo -e "  - 재설치: 이 스크립트를 다시 실행하세요"
echo ""

#!/bin/bash
# MSYS2에서 oh-my-zsh 완전 설치 스크립트
# 실행: bash install_ohmyzsh_msys2.sh

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║        MSYS2 oh-my-zsh 완전 설치 스크립트                ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# 1. 환경 확인
echo "📋 환경 확인 중..."
echo "  HOME: $HOME"
echo "  SHELL: $SHELL"
echo "  현재 위치: $(pwd)"
echo ""

# 2. 필수 패키지 확인
echo "📦 필수 패키지 확인 중..."
if ! command -v git &> /dev/null; then
    echo "❌ git이 설치되지 않았습니다!"
    echo "📥 pacman -S git 실행..."
    pacman -S --noconfirm git
fi

if ! command -v curl &> /dev/null; then
    echo "❌ curl이 설치되지 않았습니다!"
    echo "📥 pacman -S curl 실행..."
    pacman -S --noconfirm curl
fi

if ! command -v zsh &> /dev/null; then
    echo "❌ zsh가 설치되지 않았습니다!"
    echo "📥 pacman -S zsh 실행..."
    pacman -S --noconfirm zsh
fi

echo "✅ 필수 패키지 확인 완료"
echo ""

# 3. 기존 oh-my-zsh 제거 (있으면)
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "🗑️  기존 oh-my-zsh 제거 중..."
    rm -rf "$HOME/.oh-my-zsh"
    echo "✅ 제거 완료"
fi

# 4. oh-my-zsh 설치
echo "📥 oh-my-zsh 설치 중..."
export RUNZSH=no
export KEEP_ZSHRC=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

if [ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    echo "✅ oh-my-zsh 설치 완료!"
else
    echo "❌ oh-my-zsh 설치 실패!"
    exit 1
fi
echo ""

# 5. Powerlevel10k 테마 설치
echo "🎨 Powerlevel10k 테마 설치 중..."
THEME_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ -d "$THEME_DIR" ]; then
    echo "🗑️  기존 Powerlevel10k 제거 중..."
    rm -rf "$THEME_DIR"
fi

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$THEME_DIR"
echo "✅ Powerlevel10k 설치 완료"
echo ""

# 6. zsh 플러그인 설치
echo "🔌 zsh 플러그인 설치 중..."

# zsh-autosuggestions
PLUGIN_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [ -d "$PLUGIN_DIR" ]; then
    rm -rf "$PLUGIN_DIR"
fi
git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUGIN_DIR"
echo "  ✅ zsh-autosuggestions 설치 완료"

# zsh-syntax-highlighting
PLUGIN_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
if [ -d "$PLUGIN_DIR" ]; then
    rm -rf "$PLUGIN_DIR"
fi
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGIN_DIR"
echo "  ✅ zsh-syntax-highlighting 설치 완료"
echo ""

# 7. .zshrc 백업
if [ -f "$HOME/.zshrc" ]; then
    BACKUP="$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$HOME/.zshrc" "$BACKUP"
    echo "📦 기존 .zshrc 백업: $BACKUP"
fi

# 8. 완전한 .zshrc 작성
echo "📝 .zshrc 파일 작성 중..."
cat > "$HOME/.zshrc" << 'ZSHRC_EOF'
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  colored-man-pages
  command-not-found
)

# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh

# User configuration

# UTF-8 설정
export LANG=ko_KR.UTF-8
export LC_ALL=ko_KR.UTF-8

# Editor
export EDITOR=vim

# Aliases
alias ll='ls -alh --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --decorate --all'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# MSYS2 패키지 관리
alias update='pacman -Syu'
alias install='pacman -S'
alias search='pacman -Ss'
alias remove='pacman -R'

# Directory shortcuts
alias proj='cd /c/Users/Nam/Documents/Cursor/Workspace/origin/learning-code'
alias downloads='cd /c/Users/Nam/Downloads'
alias desktop='cd /c/Users/Nam/Desktop'

# Utilities
alias cls='clear'
alias h='history'
alias ports='netstat -tulanp'

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS

# Completion configuration
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' menu select

# Key bindings
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
ZSHRC_EOF

echo "✅ .zshrc 작성 완료"
echo ""

# 9. .bashrc 설정
echo "🔄 .bashrc 설정 중..."
if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "exec zsh" "$HOME/.bashrc"; then
        echo "" >> "$HOME/.bashrc"
        echo "# Start zsh automatically" >> "$HOME/.bashrc"
        echo "if [ -t 1 ] && command -v zsh &> /dev/null; then" >> "$HOME/.bashrc"
        echo "  exec zsh" >> "$HOME/.bashrc"
        echo "fi" >> "$HOME/.bashrc"
        echo "✅ .bashrc에 zsh 자동 실행 추가"
    else
        echo "✅ .bashrc 이미 설정됨"
    fi
else
    cat > "$HOME/.bashrc" << 'BASHRC_EOF'
# Start zsh automatically
if [ -t 1 ] && command -v zsh &> /dev/null; then
  exec zsh
fi
BASHRC_EOF
    echo "✅ .bashrc 생성 및 설정 완료"
fi
echo ""

# 10. 설치 확인
echo "🔍 설치 확인 중..."
if [ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    echo "  ✅ oh-my-zsh: $(ls -ld $HOME/.oh-my-zsh | awk '{print $6, $7, $8}')"
fi
if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    echo "  ✅ Powerlevel10k 테마"
fi
if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    echo "  ✅ zsh-autosuggestions 플러그인"
fi
if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    echo "  ✅ zsh-syntax-highlighting 플러그인"
fi
if [ -f "$HOME/.zshrc" ]; then
    echo "  ✅ .zshrc: $(wc -l < $HOME/.zshrc) lines"
fi
echo ""

# 완료 메시지
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                  🎉 설치 완료! 🎉                         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "🚀 다음 명령어를 실행하여 zsh를 시작하세요:"
echo ""
echo "   exec zsh"
echo ""
echo "   또는 터미널을 닫고 다시 열기"
echo ""
echo "🎨 Powerlevel10k 설정 마법사가 자동으로 시작됩니다!"
echo ""
echo "   수동 실행: p10k configure"
echo ""
echo "📂 백업 파일: ~/.zshrc.backup.*"
echo "📖 문서: msys2_setup_guide.md"
echo ""

#!/bin/bash
# MSYS2 zsh + Powerlevel10k 완전 수정 스크립트
# 실행 방법: bash fix_zsh_setup.sh

set -e  # 오류 발생 시 중단

echo "🔧 MSYS2 zsh 설정 수정 시작..."
echo ""

# 1. 기존 .zshrc 백업
if [ -f ~/.zshrc ]; then
    echo "📦 기존 .zshrc 백업 중..."
    cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ 백업 완료: ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
fi

# 2. oh-my-zsh 설치 확인
if [ ! -d ~/.oh-my-zsh ]; then
    echo "❌ oh-my-zsh가 설치되지 않았습니다!"
    echo "📥 자동 설치 중..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "✅ oh-my-zsh 설치 완료"
else
    echo "✅ oh-my-zsh 이미 설치됨"
fi

# 3. Powerlevel10k 테마 설치 확인
THEME_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$THEME_DIR" ]; then
    echo "❌ Powerlevel10k 테마가 없습니다!"
    echo "📥 자동 설치 중..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$THEME_DIR"
    echo "✅ Powerlevel10k 설치 완료"
else
    echo "✅ Powerlevel10k 이미 설치됨"
fi

# 4. 플러그인 설치
echo ""
echo "🔌 zsh 플러그인 설치 중..."

# zsh-autosuggestions
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    echo "  📥 zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    echo "  ✅ zsh-autosuggestions 설치 완료"
else
    echo "  ✅ zsh-autosuggestions 이미 설치됨"
fi

# zsh-syntax-highlighting
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    echo "  📥 zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    echo "  ✅ zsh-syntax-highlighting 설치 완료"
else
    echo "  ✅ zsh-syntax-highlighting 이미 설치됨"
fi

# 5. 완전한 .zshrc 작성
echo ""
echo "📝 완전한 .zshrc 파일 작성 중..."

cat > ~/.zshrc << 'ZSHRC_EOF'
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
)

# oh-my-zsh 초기화 (CRITICAL!)
source $ZSH/oh-my-zsh.sh

# User configuration

# UTF-8 인코딩
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
alias grep='grep --color=auto'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'

# MSYS2 패키지 관리
alias update='pacman -Syu'
alias install='pacman -S'

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY

# Case-insensitive completion
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Powerlevel10k configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
ZSHRC_EOF

echo "✅ .zshrc 작성 완료"

# 6. .bashrc에 zsh 자동 실행 추가 (중복 방지)
echo ""
echo "🔄 .bashrc 설정 중..."
if ! grep -q "exec zsh" ~/.bashrc 2>/dev/null; then
    echo 'exec zsh' >> ~/.bashrc
    echo "✅ .bashrc에 zsh 자동 실행 추가"
else
    echo "✅ .bashrc 이미 설정됨"
fi

# 7. 완료 메시지
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                  🎉 설정 완료! 🎉                         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "다음 명령어를 실행하여 zsh를 시작하세요:"
echo ""
echo "  exec zsh"
echo ""
echo "그러면 Powerlevel10k 설정 마법사가 자동으로 시작됩니다!"
echo ""
echo "수동으로 실행하려면:"
echo ""
echo "  p10k configure"
echo ""
echo "백업 파일 위치: ~/.zshrc.backup.* (문제 발생 시 복원 가능)"
echo ""

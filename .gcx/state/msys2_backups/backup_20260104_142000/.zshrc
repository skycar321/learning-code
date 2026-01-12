# >>> GCX MSYS2 BASE PATH (oh-my-zsh 전에 필수)
# 기본 POSIX 경로 (mkdir, git, mv 등 기본 명령어에 필요)
export PATH="/usr/local/bin:/usr/bin:/bin:/c/Windows/system32:/c/Windows"
# MSYS2 도구 경로 추가
export PATH="/c/msys64/ucrt64/bin:/c/msys64/usr/bin:/c/msys64/mingw64/bin:$PATH"
# <<< GCX MSYS2 BASE PATH

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

# >>> GCX npm CLI Tools (MSYS2 경로 수정)
# MSYS2에서 npm 글로벌 CLI 도구 경로 변환 문제 해결
# node.exe를 직접 호출하여 Windows 경로로 모듈 실행
export PATH="/c/Users/Nam/AppData/Roaming/npm:$PATH"
export GCX_NODE_EXE="/c/Program Files/nodejs/node.exe"
export GCX_NPM_MODULES="C:/Users/Nam/AppData/Roaming/npm/node_modules"
codex() { "$GCX_NODE_EXE" "$GCX_NPM_MODULES/@openai/codex/bin/codex.js" "$@"; }
gemini() { "$GCX_NODE_EXE" "$GCX_NPM_MODULES/@google/gemini-cli/dist/index.js" "$@"; }
claude() { "$GCX_NODE_EXE" "$GCX_NPM_MODULES/@anthropic-ai/claude-code/cli.js" "$@"; }
# <<< GCX npm CLI Tools

# >>> GCX Docker (MSYS2 호환)
# Docker Desktop for Windows (MSYS2/Zsh 호환)
# 참고: docker 래퍼 스크립트가 /usr/bin/env sh 오류 발생 → docker.exe 직접 호출
alias docker='"/c/Program Files/Docker/Docker/resources/bin/docker.exe"'
alias d='docker'
alias dc='docker compose'
alias docker-compose='docker compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias drm='docker rm'
alias drmi='docker rmi'
alias dstop='docker stop $(docker ps -aq) 2>/dev/null'
alias dclean='docker system prune -af'
# <<< GCX Docker

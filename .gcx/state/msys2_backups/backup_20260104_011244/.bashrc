
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
# The copy in your home directory (~/.bashrc) is yours, please
# feel free to customise it to create a shell
# environment to your liking.  If you feel a change
# would be benifitial to all, please feel free to send
# a patch to the msys2 mailing list.

# User dependent .bashrc file

# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

# Shell Options
#
# See man bash for more options...
#
# Don't wait for job termination notification
# set -o notify
#
# Don't use ^D to exit
# set -o ignoreeof
#
# Use case-insensitive filename globbing
# shopt -s nocaseglob
#
# Make bash append rather than overwrite the history on disk
# shopt -s histappend
#
# When changing directory small typos can be ignored by bash
# for example, cd /vr/lgo/apaache would find /var/log/apache
# shopt -s cdspell

# Completion options
#
# These completion tuning parameters change the default behavior of bash_completion:
#
# Define to access remotely checked-out files over passwordless ssh for CVS
# COMP_CVS_REMOTE=1
#
# Define to avoid stripping description in --option=description of './configure --help'
# COMP_CONFIGURE_HINTS=1
#
# Define to avoid flattening internal contents of tar files
# COMP_TAR_INTERNAL_PATHS=1
#
# Uncomment to turn on programmable completion enhancements.
# Any completions you add in ~/.bash_completion are sourced last.
# [[ -f /etc/bash_completion ]] && . /etc/bash_completion

# History Options
#
# Don't put duplicate lines in the history.
# export HISTCONTROL=$HISTCONTROL${HISTCONTROL+:}ignoredups
#
# Ignore some controlling instructions
# HISTIGNORE is a colon-delimited list of patterns which should be excluded.
# The '&' is a special pattern which suppresses duplicate entries.
# export HISTIGNORE=$'[ \t]*:&:[fb]g:exit'
# export HISTIGNORE=$'[ \t]*:&:[fb]g:exit:ls' # Ignore the ls command as well
#
# Whenever displaying the prompt, write the previous line to disk
# export PROMPT_COMMAND="history -a"

# Aliases
#
# Some people use a different file for aliases
# if [ -f "${HOME}/.bash_aliases" ]; then
#   source "${HOME}/.bash_aliases"
# fi
#
# Some example alias instructions
# If these are enabled they will be used instead of any instructions
# they may mask.  For example, alias rm='rm -i' will mask the rm
# application.  To override the alias instruction use a \ before, ie
# \rm will call the real rm not the alias.
#
# Interactive operation...
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'
#
# Default to human readable figures
# alias df='df -h'
# alias du='du -h'
#
# Misc :)
# alias less='less -r'                          # raw control characters
# alias whence='type -a'                        # where, of a sort
# alias grep='grep --color'                     # show differences in colour
# alias egrep='egrep --color=auto'              # show differences in colour
# alias fgrep='fgrep --color=auto'              # show differences in colour
#
# Some shortcuts for different directory listings
# alias ls='ls -hF --color=tty'                 # classify files in colour
# alias dir='ls --color=auto --format=vertical'
# alias vdir='ls --color=auto --format=long'
# alias ll='ls -l'                              # long list
# alias la='ls -A'                              # all but . and ..
# alias l='ls -CF'                              #

# Umask
#
# /etc/profile sets 022, removing write perms to group + others.
# Set a more restrictive umask: i.e. no exec perms for others:
# umask 027
# Paranoid: neither group nor others have any perms:
# umask 077

# Functions
#
# Some people use a different file for functions
# if [ -f "${HOME}/.bash_functions" ]; then
#   source "${HOME}/.bash_functions"
# fi
#
# Some example functions:
#
# a) function settitle
# settitle () 
# { 
#   echo -ne "\e]2;$@\a\e]1;$@\a"; 
# }
# 
# b) function cd_func
# This function defines a 'cd' replacement function capable of keeping, 
# displaying and accessing history of visited directories, up to 10 entries.
# To use it, uncomment it, source this file and try 'cd --'.
# acd_func 1.0.5, 10-nov-2004
# Petar Marinov, http:/geocities.com/h2428, this is public domain
# cd_func ()
# {
#   local x2 the_new_dir adir index
#   local -i cnt
# 
#   if [[ $1 ==  "--" ]]; then
#     dirs -v
#     return 0
#   fi
# 
#   the_new_dir=$1
#   [[ -z $1 ]] && the_new_dir=$HOME
# 
#   if [[ ${the_new_dir:0:1} == '-' ]]; then
#     #
#     # Extract dir N from dirs
#     index=${the_new_dir:1}
#     [[ -z $index ]] && index=1
#     adir=$(dirs +$index)
#     [[ -z $adir ]] && return 1
#     the_new_dir=$adir
#   fi
# 
#   #
#   # '~' has to be substituted by ${HOME}
#   [[ ${the_new_dir:0:1} == '~' ]] && the_new_dir="${HOME}${the_new_dir:1}"
# 
#   #
#   # Now change to the new dir and add to the top of the stack
#   pushd "${the_new_dir}" > /dev/null
#   [[ $? -ne 0 ]] && return 1
#   the_new_dir=$(pwd)
# 
#   #
#   # Trim down everything beyond 11th entry
#   popd -n +11 2>/dev/null 1>/dev/null
# 
#   #
#   # Remove any other occurence of this dir, skipping the top of the stack
#   for ((cnt=1; cnt <= 10; cnt++)); do
#     x2=$(dirs +${cnt} 2>/dev/null)
#     [[ $? -ne 0 ]] && return 0
#     [[ ${x2:0:1} == '~' ]] && x2="${HOME}${x2:1}"
#     if [[ "${x2}" == "${the_new_dir}" ]]; then
#       popd -n +$cnt 2>/dev/null 1>/dev/null
#       cnt=cnt-1
#     fi
#   done
# 
#   return 0
# }
# 
# alias cd=cd_func
exec zsh
exec zsh







# >>> GCX MSYS2 PATH
export PATH="/c/msys64/usr/bin:/c/msys64/ucrt64/bin:$PATH"
# <<< GCX MSYS2 PATH






















# >>> GCX MSYS2 BASE PATH (oh-my-zsh 전에 필수)
# 기본 POSIX 경로 (mkdir, git, mv 등 기본 명령어에 필요)
export PATH="/usr/local/bin:/usr/bin:/bin:/c/Windows/system32:/c/Windows"
# MSYS2 도구 경로 추가
export PATH="/c/msys64/ucrt64/bin:/c/msys64/usr/bin:/c/msys64/mingw64/bin:$PATH"
# <<< GCX MSYS2 BASE PATH

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

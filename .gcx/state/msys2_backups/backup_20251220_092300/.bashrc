# ~/.bashrc - MSYS2 Bash configuration

# ~/.local/bin을 PATH에 추가 (npm 글로벌 도구 wrapper용)
if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Alias 설정 (필요시 추가)
# alias ll='ls -alF'
# alias la='ls -A'
# alias l='ls -CF'

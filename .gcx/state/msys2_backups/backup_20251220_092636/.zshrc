# ~/.zshrc - MSYS2 Zsh configuration

# MSYS2 환경에서 Claude Code와 Gemini CLI를 위한 설정
# npm wrapper의 경로 문제를 우회하기 위해 직접 Node.js로 실행

# Claude Code 함수 (alias보다 우선순위 높음)
claude() {
    node "/c/Users/Nam/AppData/Roaming/npm/node_modules/@anthropic-ai/claude-code/cli.js" "$@"
}

# Gemini CLI 함수
gemini() {
    node "/c/Users/Nam/AppData/Roaming/npm/node_modules/@google/gemini-cli/dist/index.js" "$@"
}

# 추가 alias (필요시)
# alias ll='ls -alF'
# alias la='ls -A'
# alias l='ls -CF'

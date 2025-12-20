#!/bin/bash
# Fix Claude Code and Gemini CLI wrapper scripts for MSYS2
# 동적 경로 감지 - 여러 컴퓨터에서 작동
# Author: Nam
# Updated: 2025-12-20

set -e

# === 동적 Windows 사용자 감지 ===
detect_win_user() {
    # 방법 1: /c/Users 디렉토리에서 npm 폴더 있는 사용자 찾기
    local user_dir
    for dir in /c/Users/*/AppData/Roaming/npm; do
        if [[ -d "$dir" ]]; then
            user_dir=$(echo "$dir" | sed 's|/c/Users/||' | sed 's|/AppData.*||')
            if [[ "$user_dir" != "Default" && "$user_dir" != "Public" ]]; then
                echo "$user_dir"
                return 0
            fi
        fi
    done

    # 방법 2: USERPROFILE에서 추출
    if [[ -n "$USERPROFILE" ]]; then
        echo "$USERPROFILE" | sed 's|.*\||'
        return 0
    fi

    # 방법 3: 기본값
    echo "Nam"
}

WIN_USER=$(detect_win_user)
NPM_DIR="/c/Users/$WIN_USER/AppData/Roaming/npm"
CLAUDE_WRAPPER="$NPM_DIR/claude"
GEMINI_WRAPPER="$NPM_DIR/gemini"

echo "🔧 Fixing Claude Code and Gemini CLI wrappers for MSYS2..."
echo "   감지된 Windows 사용자: $WIN_USER"
echo "   npm 디렉토리: $NPM_DIR"
echo ""

# npm 디렉토리 확인
if [ ! -d "$NPM_DIR" ]; then
    echo "❌ Error: npm directory not found at $NPM_DIR"
    echo "   Node.js와 npm이 설치되어 있는지 확인하세요."
    exit 1
fi

SKIP_CLAUDE=0
SKIP_GEMINI=0

# Claude wrapper 존재 확인
if [ ! -f "$CLAUDE_WRAPPER" ] && [ ! -f "$CLAUDE_WRAPPER.cmd" ]; then
    echo "⚠️  Warning: Claude wrapper not found"
    echo "   npm install -g @anthropic-ai/claude-code"
    SKIP_CLAUDE=1
fi

# Gemini wrapper 존재 확인
if [ ! -f "$GEMINI_WRAPPER" ] && [ ! -f "$GEMINI_WRAPPER.cmd" ]; then
    echo "⚠️  Warning: Gemini wrapper not found"
    echo "   npm install -g @google/gemini-cli"
    SKIP_GEMINI=1
fi

if [[ "$SKIP_CLAUDE" == "1" && "$SKIP_GEMINI" == "1" ]]; then
    echo "❌ Both wrappers missing. Nothing to fix."
    exit 1
fi

# === Claude wrapper 수정 ===
if [[ "$SKIP_CLAUDE" == "0" ]]; then
    cp "$CLAUDE_WRAPPER" "$CLAUDE_WRAPPER.backup" 2>/dev/null || true
    echo "✓ Backed up claude wrapper"

    cat > "$CLAUDE_WRAPPER" << EOF
#!/bin/sh
# Fixed wrapper for @anthropic-ai/claude-code in MSYS2
# cygpath 문제 해결 - MSYS2 스타일 경로 직접 사용

SCRIPT_DIR="/c/Users/$WIN_USER/AppData/Roaming/npm"
CLAUDE_JS="\$SCRIPT_DIR/node_modules/@anthropic-ai/claude-code/cli.js"

if [ -f "\$CLAUDE_JS" ]; then
    exec node "\$CLAUDE_JS" "\$@"
else
    echo "Error: cli.js not found at \$CLAUDE_JS" >&2
    exit 1
fi
EOF

    chmod +x "$CLAUDE_WRAPPER"
    echo "✓ Fixed claude wrapper"
fi

# === Gemini wrapper 수정 ===
if [[ "$SKIP_GEMINI" == "0" ]]; then
    cp "$GEMINI_WRAPPER" "$GEMINI_WRAPPER.backup" 2>/dev/null || true
    echo "✓ Backed up gemini wrapper"

    cat > "$GEMINI_WRAPPER" << EOF
#!/bin/sh
# Fixed wrapper for @google/gemini-cli in MSYS2
# cygpath 문제 해결 - MSYS2 스타일 경로 직접 사용

SCRIPT_DIR="/c/Users/$WIN_USER/AppData/Roaming/npm"
GEMINI_JS="\$SCRIPT_DIR/node_modules/@google/gemini-cli/dist/index.js"

if [ -f "\$GEMINI_JS" ]; then
    exec node "\$GEMINI_JS" "\$@"
else
    echo "Error: index.js not found at \$GEMINI_JS" >&2
    exit 1
fi
EOF

    chmod +x "$GEMINI_WRAPPER"
    echo "✓ Fixed gemini wrapper"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Verification:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Verify claude
if [[ "$SKIP_CLAUDE" == "0" ]]; then
    if CLAUDE_VERSION=$(claude --version 2>&1); then
        echo "✓ claude: $CLAUDE_VERSION"
    else
        echo "✗ claude: Failed"
    fi
fi

# Verify gemini
if [[ "$SKIP_GEMINI" == "0" ]]; then
    if GEMINI_VERSION=$(gemini --version 2>&1); then
        echo "✓ gemini: $GEMINI_VERSION"
    else
        echo "✗ gemini: Failed"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Done! claude/gemini 명령어 사용 가능"
echo ""
echo "Usage:"
echo "  claude --dangerously-skip-permissions"
echo "  gemini --yolo -m=pro"
echo ""
echo "Note: npm 재설치 후 이 스크립트 다시 실행"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

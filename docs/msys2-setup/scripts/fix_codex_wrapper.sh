#!/usr/bin/env bash
set -e

# Fix Codex CLI wrapper for MSYS2 (path conversion issue)
# 동적 경로 감지 - 여러 컴퓨터에서 작동
# Updated: 2025-12-20

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
CODEX_WRAPPER="$NPM_DIR/codex"

echo "[GCX] Fixing Codex CLI wrapper for MSYS2..."
echo "   감지된 Windows 사용자: $WIN_USER"
echo "   npm 디렉토리: $NPM_DIR"

# npm 디렉토리 확인
if [ ! -d "$NPM_DIR" ]; then
    echo "❌ Error: npm directory not found at $NPM_DIR"
    exit 1
fi

# Codex wrapper 존재 확인
if [ ! -f "$CODEX_WRAPPER" ] && [ ! -f "$CODEX_WRAPPER.cmd" ]; then
    echo "❌ Error: Codex wrapper not found"
    echo "   npm install -g @openai/codex"
    exit 1
fi

cp "$CODEX_WRAPPER" "$CODEX_WRAPPER.backup" 2>/dev/null || true
echo "✓ Backed up codex wrapper"

cat > "$CODEX_WRAPPER" << EOF
#!/bin/sh
# Fixed wrapper for @openai/codex in MSYS2
# cygpath 문제 해결 - MSYS2 스타일 경로 직접 사용

SCRIPT_DIR="/c/Users/$WIN_USER/AppData/Roaming/npm"
CODEX_JS="\$SCRIPT_DIR/node_modules/@openai/codex/bin/codex.js"

if [ -f "\$CODEX_JS" ]; then
    exec node "\$CODEX_JS" "\$@"
else
    echo "Error: codex.js not found at \$CODEX_JS" >&2
    exit 1
fi
EOF

chmod +x "$CODEX_WRAPPER"
echo "✓ Fixed codex wrapper"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Verification:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if CODEX_VERSION=$(codex --version 2>&1); then
    echo "✓ codex: $CODEX_VERSION"
else
    echo "✗ codex: Failed"
fi

echo ""
echo "🎉 Done! codex 명령어 사용 가능"
echo ""
echo "Usage: codex --yolo"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

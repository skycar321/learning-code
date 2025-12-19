#!/bin/bash
# Fix Claude Code and Gemini CLI wrapper scripts for MSYS2
# Author: Nam
# Date: 2025-12-19

set -e

NPM_DIR="/c/Users/Nam/AppData/Roaming/npm"
CLAUDE_WRAPPER="$NPM_DIR/claude"
GEMINI_WRAPPER="$NPM_DIR/gemini"

echo "🔧 Fixing Claude Code and Gemini CLI wrappers for MSYS2..."
echo ""

# Check if wrappers exist
if [ ! -f "$CLAUDE_WRAPPER" ]; then
    echo "❌ Error: Claude wrapper not found at $CLAUDE_WRAPPER"
    echo "   Install Claude Code first: npm install -g @anthropic-ai/claude-code"
    exit 1
fi

if [ ! -f "$GEMINI_WRAPPER" ]; then
    echo "❌ Error: Gemini wrapper not found at $GEMINI_WRAPPER"
    echo "   Install Gemini CLI first: npm install -g @google/gemini-cli"
    exit 1
fi

# Backup
if [ -f "$CLAUDE_WRAPPER" ]; then
    cp "$CLAUDE_WRAPPER" "$CLAUDE_WRAPPER.backup"
    echo "✓ Backed up claude wrapper → claude.backup"
fi

if [ -f "$GEMINI_WRAPPER" ]; then
    cp "$GEMINI_WRAPPER" "$GEMINI_WRAPPER.backup"
    echo "✓ Backed up gemini wrapper → gemini.backup"
fi

echo ""

# Fix claude
cat > "$CLAUDE_WRAPPER" << 'EOF'
#!/bin/sh
# Fixed wrapper for @anthropic-ai/claude-code in MSYS2
# Directly use Windows paths to avoid cygpath issues

CLAUDE_JS="/c/Users/Nam/AppData/Roaming/npm/node_modules/@anthropic-ai/claude-code/cli.js"

if [ -f "$CLAUDE_JS" ]; then
    exec node "$CLAUDE_JS" "$@"
else
    echo "Error: cli.js not found at $CLAUDE_JS" >&2
    exit 1
fi
EOF

chmod +x "$CLAUDE_WRAPPER"
echo "✓ Fixed claude wrapper"

# Fix gemini
cat > "$GEMINI_WRAPPER" << 'EOF'
#!/bin/sh
# Fixed wrapper for @google/gemini-cli in MSYS2
# Directly use Windows paths to avoid cygpath issues

GEMINI_JS="/c/Users/Nam/AppData/Roaming/npm/node_modules/@google/gemini-cli/dist/index.js"

if [ -f "$GEMINI_JS" ]; then
    exec node "$GEMINI_JS" "$@"
else
    echo "Error: index.js not found at $GEMINI_JS" >&2
    exit 1
fi
EOF

chmod +x "$GEMINI_WRAPPER"
echo "✓ Fixed gemini wrapper"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Verification:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Verify claude
if CLAUDE_VERSION=$(claude --version 2>&1); then
    echo "✓ claude: $CLAUDE_VERSION"
else
    echo "✗ claude: Failed to execute"
fi

# Verify gemini
if GEMINI_VERSION=$(gemini --version 2>&1); then
    echo "✓ gemini: $GEMINI_VERSION"
else
    echo "✗ gemini: Failed to execute"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Done! You can now use 'claude' and 'gemini' commands."
echo ""
echo "Usage:"
echo "  claude --dangerously-skip-permissions"
echo "  gemini --yolo -m=pro"
echo ""
echo "Note: If you reinstall npm packages, run this script again."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

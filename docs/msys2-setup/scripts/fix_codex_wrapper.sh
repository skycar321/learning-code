#!/usr/bin/env bash
set -e

# Fix Codex CLI wrapper for MSYS2 (path conversion issue)

NPM_DIR="/c/Users/Nam/AppData/Roaming/npm"
CODEX_WRAPPER="$NPM_DIR/codex"
CODEX_JS="/c/Users/Nam/AppData/Roaming/npm/node_modules/@openai/codex/bin/codex.js"

echo "[GCX] Fixing Codex CLI wrapper for MSYS2..."

if [ ! -f "$CODEX_WRAPPER" ]; then
  echo "Error: Codex wrapper not found at $CODEX_WRAPPER"
  echo "Install Codex first: npm install -g @openai/codex"
  exit 1
fi

cp "$CODEX_WRAPPER" "$CODEX_WRAPPER.backup"
echo "Backed up codex wrapper -> $CODEX_WRAPPER.backup"

cat > "$CODEX_WRAPPER" << 'EOF'
#!/bin/sh
# Fixed wrapper for @openai/codex in MSYS2
# Directly use Windows paths to avoid cygpath issues

CODEX_JS="/c/Users/Nam/AppData/Roaming/npm/node_modules/@openai/codex/bin/codex.js"

if [ -f "$CODEX_JS" ]; then
  exec node "$CODEX_JS" "$@"
else
  echo "Error: codex.js not found at $CODEX_JS" >&2
  exit 1
fi
EOF

chmod +x "$CODEX_WRAPPER"
echo "Fixed codex wrapper"

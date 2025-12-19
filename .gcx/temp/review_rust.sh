export NO_COLOR=1
# Read current Rust code
CODE=$(cat platform/src/main.rs)

PROMPT="You are the Lead Architect (Model: Opus).
Gemini (Junior Developer) drafted a Rust JSON API server (\`src/main.rs\`) to replace an HTML server.

**Please Review this Code:**
$CODE

**Checklist**:
1. **API Design**: Does it match \`GET /api/tree\` and \`GET /api/content/*path\`?
2. **Security**: Is Path Traversal protection (\`..\`, \`\\\`)\\`) sufficient?
3. **Rust Idioms**: Are there cloning issues or inefficient string handling?
4. **CORS**: Is \`Allow Any\` safe for dev? (It's acceptable for now).

**Output**: JSON format with \`status\` (PASS/FAIL) and \`issues\` list.
If FAIL, provide specific refactoring instructions."

# Invoke Claude
claude -p "$PROMPT" --model opus > .gcx/review_rust_backend.json


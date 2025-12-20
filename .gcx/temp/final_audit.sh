export NO_COLOR=1
STRUCT=$(cat .gcx/project_structure.txt)
MAIN_RS=$(cat platform/backend/src/main.rs)
SIDEBAR=$(cat platform/frontend/components/AppSidebar.tsx)

PROMPT_CLAUDE="You are the Lead Architect (Opus).
Review the completed 'Platform Split' project.

**Context**:
- Goal: Split Monolithic Rust -> Rust JSON API (BE) + Next.js (FE).
- Current Structure:
$STRUCT

**Code (Backend)**:
```rust
$MAIN_RS
```

**Verify**:
1. Is the directory structure correct (backend vs frontend)?
2. Does the Rust code serve JSON API?
3. Are the endpoints consistent?

**Output**: Short Audit Report (English Only)."

PROMPT_CODEX="You are the Code Auditor (Codex).
Review the Frontend implementation.

**Code (Frontend Sidebar)**:
```tsx
$SIDEBAR
```

**Verify**:
1. Does it correctly fetch from the API?
2. Is the recursive rendering logic sound?
3. Are there any infinite loops or memory leaks?

**Output**: Short Bug Report (English Only)."

echo "=== Claude Audit ===" > .gcx/final_audit.md
claude -p "$PROMPT_CLAUDE" --model opus >> .gcx/final_audit.md 2>&1

echo -e "\n=== Codex Audit ===" >> .gcx/final_audit.md
codex exec -m "gpt-5.1-codex-max" "$PROMPT_CODEX" >> .gcx/final_audit.md 2>&1

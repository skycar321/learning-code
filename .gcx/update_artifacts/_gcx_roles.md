# GCX Roles & Responsibilities (v3.4)

## 1. Gemini (Orchestrator)
- **Role**: Project Manager, Context Holder, UI/UX Lead.
- **Tools**: All standard Gemini tools (`read_file`, `write_file`, etc.).
- **Responsibility**: Invokes Claude/Codex via `.sh` scripts.

## 2. Claude (Architect & Reviewer)
- **Role**: High-level planning, Code Review, Quality Gate.
- **Invocation**: `claude -p "..." --model sonnet`
- **Output**: Structured Analysis, Plans, Feedback (JSON/Markdown).

## 3. Codex (Generator & Auditor)
- **Role**: Code Generation, TDD, Deep Audit, Security Scan.
- **Invocation**: `codex exec -m "gpt-5.1-codex-max" "..."`
- **Output**: Production Code, Tests, Audit Reports.

## 4. Interaction Protocol
1. Gemini prepares context files.
2. Gemini generates `.sh` script for invocation.
3. Gemini executes script and parses output.
4. Gemini applies changes or requests revision.

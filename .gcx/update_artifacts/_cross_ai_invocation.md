# Cross-AI Invocation Guide (v1.9)

## 1. Core Principles
- **No Simulation**: Use actual CLI tools via `run_shell_command`.
- **Windows Safety**: Always use `bash` scripts or `Out-File -Encoding UTF8`.

## 2. Claude Invocation (Architect/Reviewer)
**Command**: `claude`
**Flags**:
- `-p` (Mandatory): Print mode (non-interactive).
- `--model <alias>`: Specify model (e.g., `sonnet`, `opus`).

**Example (Bash Script)**:
```bash
export NO_COLOR=1
PROMPT="Review this code..."
claude -p "$PROMPT" --model sonnet > analysis_result.md
```

## 3. Codex Invocation (Generator/Auditor)
**Command**: `codex`
**Flags**:
- `exec`: Execute non-interactively.
- `-m <model>`: Specify model (e.g., `gpt-5.1-codex-max`).
- **Reasoning**: Do NOT use CLI flags. Specify "Reasoning: High" in prompt.

**Example (Bash Script)**:
```bash
export NO_COLOR=1
PROMPT="Generate tests... Reasoning: High"
codex exec -m "gpt-5.1-codex-max" "$PROMPT" > test_strategy.md
```

## 4. Common Patterns
### The "Handoff" Script
Create `.gcx/run_task.sh`:
```bash
#!/bin/bash
export NO_COLOR=1
# 1. Claude Plan
claude -p "Plan..." --model sonnet > plan.md
# 2. Codex Implement
codex exec -m "gpt-5.1-codex-max" "Implement..." > impl.ts
```
Execute: `run_shell_command("bash .gcx/run_task.sh")`

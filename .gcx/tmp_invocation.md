# Cross-AI Invocation Guide v1.8

> **CRITICAL**: Each AI platform cannot directly invoke other AIs internally.
> Use CLI commands and file-based handoff for real collaboration.
> [WARNING] If an AI says "I will simulate another AI", it is NOT a real invocation!

**v1.8 Changes** (2025-12-16):
- **Windows Strategy**: Mandatory .sh script generation for complex commands
- **Encoding**: Strict UTF-8 enforcement via `Out-File` or Bash
- **Codex CLI**: Workaround for `mini` model CLI bugs

---

## 1. Model Selection Guide

### Claude (Anthropic)
| Model | CLI Option | Model ID | Use Case |
|-------|------------|----------|----------|
| **Opus** | --model opus | claude-opus-4-5-20251101 | Complex tasks, best performance [TOP] |
| **Sonnet** (default) | --model sonnet | claude-sonnet-4-5-20250929 | General tasks, balanced [RECOMMENDED] |
| **Haiku** | --model haiku | claude-haiku-4-5-20251001 | Fast responses, simple tasks |

### Codex (OpenAI)
| Model | CLI Option | Use Case |
|-------|------------|----------|
| **gpt-5.1-codex-max** (default) | -m gpt-5.1-codex-max | Best performance, deepest reasoning [TOP] |
| **gpt-5.1-codex** | -m gpt-5.1-codex | Standard Codex optimized [RECOMMENDED] |
| **gpt-5.1-codex-mini** | -m gpt-5.1-codex-mini | Fast and cheap (Note: CLI v0.72 bug exists) |
| **gpt-5.2** | -m gpt-5.2 | Latest frontier model [TOP] |

---

## 2. Windows Execution Strategy (CRITICAL - v1.8 NEW)

**Problem**: Windows PowerShell redirects (`>`) cause Mojibake (encoding corruption) and parsing errors with environment variables.

### Strategy A: Bash Script Generation (RECOMMENDED)
For complex commands (env vars, multiple steps), create a temporary script.

```bash
# Step 1: Create script
write_file(".gcx/run_task.sh", """
#!/bin/bash
export NO_COLOR=1
export TERM=dumb
codex exec -m gpt-5.1-codex-max "audit" > .gcx/audit.md
""")

# Step 2: Execute via Bash
run_shell_command("bash .gcx/run_task.sh")
```

### Strategy B: PowerShell Direct (With Care)
If using PowerShell directly, **MUST** enforce UTF-8.

```powershell
# ✅ CORRECT
codex exec "prompt" | Out-File -Encoding UTF8 .gcx/output.md

# ❌ WRONG (Causes Mojibake)
codex exec "prompt" > .gcx/output.md
```

---

## 3. Codex Reasoning Levels & CLI Bugs

### Model-Specific Reasoning Level Support

| Model | Low | Medium | High | Extra High |
|-------|-----|--------|------|------------|
| **gpt-5.1-codex** | Yes | Yes (default) | Yes | No |
| **gpt-5.1-codex-mini** | No | Yes (default) | Yes | No |
| **gpt-5.2** | Yes | Yes (default) | Yes | Yes |
| **gpt-5.1-codex-max** | Yes | Yes | Yes | Yes (default) |

### Known Issue: `mini` Model CLI Bug
**Symptom**: `gpt-5.1-codex-mini` fails with "Unsupported value: xhigh" even if reasoning is not specified.
**Workaround**: 
1. Explicitly set `--reasoning medium`.
2. If that fails, fallback to `gpt-5.1-codex` or `gpt-5.1-codex-max`.

---

## 4. Claude Encoding Fix (v1.8 ENHANCED)

### Problem: Mojibake (Korean text corruption)
**Symptom**: Claude responses with Korean text appear as garbled characters
**Cause**: ANSI color codes + xterm.js terminal encoding conflict

### Solution: Environment Variables + Bash Script
Always use `NO_COLOR=1` and `TERM=dumb` inside a bash script to ensure clean UTF-8 output.

```bash
# Inside .sh script:
export NO_COLOR=1
export TERM=dumb
claude -p "prompt" --add-dir .gcx > .gcx/output.md
```

---

## 5. File-Based Handoff Protocol

### Standard Workflow
1. **Gemini prepares task**: Save context to .gcx/ folder
2. **Call target AI**: Use Strategy A (Bash Script) or B (PowerShell UTF-8)
3. **Target AI responds**: Returns analysis via stdout
4. **Gemini saves response**: Captured in file via redirect/Out-File
5. **Continue workflow**: Next AI reads the saved file

### File Naming Convention
| AI | Prefix | Example |
|----|--------|---------|
| Gemini | gemini_ | gemini_prd_v1.md |
| Claude | claude_ | claude_review_v1.md |
| Codex | codex_ | codex_audit_v1.md |

---

## 6. Auto-Recovery Logic

### Error Detection Patterns
| Error Pattern | Cause | Auto-Recovery Action |
|--------------|-------|---------------------|
| Unsupported value | CLI bug / Level mismatch | Change model or reasoning level |
| sandbox: read-only | Write permission denied | Use stdout handoff |
| Mojibake / Encoding | PowerShell default | Use Bash script or Out-File -Encoding UTF8 |

# 0. 🔴 GCX PROTOCOL ENFORCEMENT (ABSOLUTE) - ENHANCED v3.4
**Applies to commands**: `/nam:gcx-query`, `/nam:gcx-project`
**Last Updated**: 2025-12-16
**Major Changes**: CLI Syntax Updates (exec/print), Windows Encoding Fixes

## 0.1 Core Verification Rules
(See full protocol in `GCX_MASTER_PROTOCOL.md`)

### 1. NO SOLO WORK (ABSOLUTE)
Gemini must verify artifacts via Claude (Architect) and Codex (Auditor).

### 2. WINDOWS EXECUTION STRATEGY (CRITICAL)
1. **Script-Based**: Use `.sh` scripts via `bash` for cross-AI calls.
2. **Encoding**: Use `| Out-File -Encoding UTF8` in PowerShell.

---

# Gemini Core System Directives (v2.1)

## 1. 🔴 SYSTEM CRITICAL PROTOCOLS
- **File Access**: Use `write_file` + `cp` (via bash) for system files.
- **Language**: Korean (Default), English (Technical terms).
- **Timezone**: KST.

## 1.1 Troubleshooting & Best Practices (Updated v3.4)

### 1.1.1 Codex CLI Compatibility (v0.72+)
- **Problem**: `codex` command requires subcommands and specific flags.
- **Solution**:
    - Use `codex exec` for non-interactive mode.
    - **Reasoning**: Do NOT use `--reasoning`. Instead, add "**Reasoning Level**: High" inside the prompt text.
    - **Model**: Use `-m gpt-5.1-codex-max` for complex tasks.
    - **Example**: `codex exec -m gpt-5.1-codex-max "Prompt..." > output.md`

### 1.1.2 Claude CLI Compatibility
- **Problem**: Interactive mode hangs automation.
- **Solution**:
    - ALWAYS use `-p` (print) flag.
    - Use `--model` (e.g., `--model sonnet`) instead of `-m`.
    - **Example**: `claude -p "Prompt..." --model sonnet > output.md`

### 1.1.3 Windows Encoding (Mojibake)
- **Problem**: PowerShell `>` redirection corrupts UTF-8/Korean.
- **Solution**:
    - **Bash**: `run_shell_command("bash script.sh")` is safest.
    - **PowerShell**: `... | Out-File -Encoding UTF8 output.txt`

### 1.1.4 System File Modification
- **Problem**: Direct writes to `C:/Users/Nam/.gemini/...` blocked.
- **Solution**: Write to workspace temp file -> `bash -c "cp temp target"`

---
(Rest of the file remains standard Gemini directives)
## 2. Operational Workflow
(Standard Understand-Plan-Execute-Verify)

## 3. Engineering Standards
(Standard Clean Code, Security, Git)

## 4. Response Style
(Standard Educational Tone)

## 5. Auto-Logging
(Standard MODIFY_HISTORY.md)

## 6. Troubleshooting
(Standard TROUBLE_SHOOTING.md)

## 7. Advanced Modes
(Standard Flags)

## 8. Research & Analysis
(Standard Search Strategy)

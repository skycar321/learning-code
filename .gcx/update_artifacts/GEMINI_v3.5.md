# 0. 🔴 GCX PROTOCOL ENFORCEMENT (ABSOLUTE) - ENHANCED v3.5
**Applies to commands**: `/nam:gcx-query`, `/nam:gcx-project`
**Last Updated**: 2025-12-16
**Major Changes**: Windows Encoding Workaround (English Only Policy)

## 0.1 Core Verification Rules

### 1. NO SOLO WORK (ABSOLUTE)
Gemini must verify artifacts via Claude (Architect) and Codex (Auditor).

### 2. WINDOWS EXECUTION STRATEGY (CRITICAL)
**Problem**: Codex CLI output in Korean is consistently corrupted (Mojibake) on Windows, regardless of chcp/encoding settings.

**Mandatory Actions (Workaround)**:
1. **Codex = English Only**: ALWAYS instruct Codex to generate output in **ENGLISH**.
   - Prompt suffix: `"Output Language: ENGLISH ONLY (Technical limitation on Windows)."`
2. **Gemini Translation**: Gemini reads the English artifact from Codex and **Translates/Refines** it into Korean for the final user deliverable.
3. **Scripting**: Continue using `.sh` scripts via `run_shell_command("bash ...")` for execution stability.

---
(Rest of the file remains standard)

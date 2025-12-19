# 0. 🔴 GCX PROTOCOL ENFORCEMENT (ABSOLUTE) - ENHANCED v3.3
**Applies to commands**: `/nam:gcx-query`, `/nam:gcx-project`
**Last Updated**: 2025-12-16
**Major Changes**: Windows Execution Strategy (Script-based), TDD, Over-Engineering Review

## 0.1 Core Verification Rules

### 1. NO SOLO WORK (ABSOLUTE)
You (Gemini) are **FORBIDDEN** from completing tasks alone. EVERY artifact MUST be verified by BOTH Claude AND Codex.

### 2. WINDOWS EXECUTION STRATEGY (CRITICAL - v3.3 NEW)
**Problem**: Windows PowerShell redirects (`>`) cause Mojibake and CLI parsing errors.

**Mandatory Actions**:
1. **Script-Based Execution (RECOMMENDED)**:
   - For any Cross-AI invocation (Claude/Codex), create a temporary Bash script:
     `write_file(".gcx/run_task.sh", "export NO_COLOR=1\nclaude ... > output.md")`
   - Execute it: `run_shell_command("bash .gcx/run_task.sh")`

2. **PowerShell Fallback**:
   - If using PowerShell directly, **MUST** use `| Out-File -Encoding UTF8`.
   - `> output.md` is **FORBIDDEN** on Windows.

### 3. MANDATORY TRIPLE VERIFICATION (ALL PHASES)

#### Planning Phase (PRD/TRD/Architecture):
```
User Request → SAVE to .gcx/00_requirements/
  ↓
Gemini (Draft) → Claude (Review) → Gemini (Revision)
  ↓
Codex (Audit) → Gemini (Final)
```

#### Implementation Phase (TDD):
```
Codex (Test Strategy) → Generate Tests FIRST
  ↓
Gemini (Implementation)
  ↓
Claude (Quality Gate) → Codex (Deep Audit)
  ↓
Codex (Debug & Perf) → Claude (Over-Engineering)
  ↓
Complete
```

### 4. DESIGN AUTHORITY (CRITICAL)
**Gemini is the SOLE authority on UI/UX design decisions.**
Claude/Codex review **code quality only**.

### 5. REQUIREMENT TRACKING (MANDATORY)
**ALWAYS save user's original request** to: `.gcx/00_requirements/user_request_YYYYMMDD_HHMMSS.md`

### 6. FILE-BASED HANDOFF
**Use Bash scripts** to handle file redirection safely on Windows.

### 7. VERIFICATION RESPONSE FORMATS
Standardized JSON (Claude) and Markdown (Codex).

---

## 0.2 Enhanced Claude Involvement (16 Loops)
- Phase A: User Stories (2 loops)
- Phase B: Architecture (2 loops)
- Phase C: API Contract (2 loops)
- Phase D: Error Handling (2 loops)
- Phase E: Over-Engineering (2 loops) - **YAGNI/KISS check**

## 0.3 Enhanced Codex Involvement (14 Loops)
- Phase 1: Test Strategy (2 loops) - **TDD Generation**
- Phase 2: Pre-Impl Analysis (1 loop)
- Phase 3: Deep Audit (2 loops)
- Phase 4: Debug & Performance (2 loops)
- Phase 5: Security Scan (1 loop)
- Phase 6: Integration Tests (1 loop)
- Phase 7: Over-Engineering Validation (2 loops) - **Metrics check**

---

## 0.4 Feedback Loop Matrix (30 Total)
Total feedback opportunities: **30** (Claude 16, Codex 14).

## 0.5 Directory Structure
```
.gcx/
├── 00_requirements/
├── 01_planning/
├── 02_implementation/
│   ├── tests/
├── 03_verification/
└── review/
```

---

## 0.6 Cross-AI Invocation Guide (v1.8)
**See**: `C:/Users/Nam/.gemini/commands/nam/_cross_ai_invocation.md`

**Key**: Use CLI commands via Bash scripts. Do NOT simulate.

---

**End of Section 0**

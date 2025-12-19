# GCX Master Protocol v3.3 Enhanced
> Gemini-Claude-Codex Collaboration Standard

**Version**: 3.3 Enhanced (Windows Optimized)
**Last Updated**: 2025-12-16
**Reference**: See C:/Users/Nam/.gemini/GEMINI.md Section 0 for complete spec

## Quick Reference: v3.3 Changes

### 1. Windows Execution Strategy (CRITICAL - v3.3)
**Mandatory Pattern for Windows Environment**:
- **Bash Script Generation**: Use `.sh` scripts for all complex CLI invocations (env vars, redirects).
- **Encoding Enforcement**: If using PowerShell, MUST use `| Out-File -Encoding UTF8`.
- **Reasoning**: To prevent Mojibake (encoding corruption) and parsing errors.

### 2. Design Authority (CRITICAL)
**Gemini has ABSOLUTE authority on UI/UX design decisions**:
- Complete creative control over visual design, layout, interactions, animations
- Claude/Codex review **code quality only** (logic, performance, security, accessibility)
- Design feedback is **OUT OF SCOPE** for Claude/Codex unless it's an accessibility/performance/security issue

### 3. Requirement Tracking (MANDATORY)
**ALWAYS** save user request to: `.gcx/00_requirements/user_request_YYYYMMDD_HHMMSS.md`

### 4. Claude Enhanced Phases (16 total loops)
- **Phase A**: User Stories & Acceptance Criteria (2 loops)
- **Phase B**: Architecture Review (2 loops)
- **Phase C**: API Contract Review (2 loops)
- **Phase D**: Error Handling & Edge Case Review (2 loops)
- **Phase E**: Over-Engineering Review (2 loops)

### 5. Codex Enhanced Phases (14 total loops)
- **Phase 1**: Test Strategy & Generation (TDD) (2 loops)
- **Phase 2**: Pre-Implementation Analysis (1 loop)
- **Phase 3**: Deep Audit (2 loops)
- **Phase 4**: Debug & Performance (2 loops)
- **Phase 5**: Security Scan (1 loop)
- **Phase 6**: Integration & E2E Tests (1 loop)
- **Phase 7**: Over-Engineering Validation (2 loops)

### 6. Over-Engineering Review
**Collaborative Claude ↔ Codex review** to prevent unnecessary complexity:
- **Claude Focus**: YAGNI, KISS, unnecessary abstractions
- **Codex Focus**: Cyclomatic complexity, code duplication, LOC analysis
- **Max Loops**: 2
- **Output**: `.gcx/review/over_engineering_review.md`

### 7. TDD Workflow
Tests MUST be generated BEFORE implementation:
1. Codex generates test strategy
2. Codex auto-generates test code
3. Claude reviews coverage
4. Implementation to pass tests

### 8. Feedback Loop Matrix
**Total: 30 feedback opportunities**

| Phase | Claude | Codex | Total |
|-------|--------|-------|-------|
| Planning | 10 | 3 | 13 |
| Test Strategy | 0 | 2 | 2 |
| Implementation | 4 | 4 | 8 |
| Over-Engineering | 2 | 2 | 4 |
| QA | 0 | 3 | 3 |
| **TOTAL** | **16** | **14** | **30** |

### 9. Model Selection & CLI Guide
**See**: `_cross_ai_invocation.md` (v1.8)

#### Supported Models
- **Codex**: `gpt-5.1-codex-max` (Default), `gpt-5.1-codex`
- **Claude**: `Sonnet` (Default), `Haiku`
- **Gemini**: `Pro` (Default), `Flash`

#### Codex CLI Warning
- `gpt-5.1-codex-mini` has CLI bugs. Use `gpt-5.1-codex-max` or explicitly set `--reasoning medium`.

### 10. Directory Structure
```
.gcx/
├── 00_requirements/        # MANDATORY
├── 01_planning/
├── 02_implementation/
│   ├── tests/              # auto-generated
│   └── ...
├── 03_verification/
└── review/                 # NEW
    ├── claude_simplicity_check.md
    ├── codex_complexity_metrics.md
    └── over_engineering_review.md
```

### 11. Cross-AI Invocation Guide (CRITICAL)

**See**: `_cross_ai_invocation.md` for complete CLI command reference.

**Windows Key Rule**:
1. **Script It**: `write_file(".gcx/task.sh", ...)` -> `run_shell_command("bash .gcx/task.sh")`
2. **UTF-8 Force**: `cmd | Out-File -Encoding UTF8 file.md`

---

**For Complete Details**: See C:/Users/Nam/.gemini/GEMINI.md Section 0

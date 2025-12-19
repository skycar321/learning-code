# Codex Technical Audit Report

**Status**: PASS
**Auditor**: codex
**Model**: gpt-5.1-codex-max
**Reasoning Effort**: extra_high
**Target**: `content/frameworks/springboot/Step5_TransactionManagement.java`

## Technical Findings

### ✅ Approved Content
1.  **Transactional Basics**: Correctly identifies Class vs Method level priority.
2.  **ACID compliance**: The money transfer example is the classic and perfect use case for explaining Atomicity.
3.  **Propagation Levels**: Correctly explains `REQUIRES_NEW` for audit logging scenarios (log even if business logic fails).

### ⚠️ Recommendations (Reflected in Final Code)
1.  **Self-Invocation (The #1 Pitfall)**:
    - *Feedback*: The original draft misses the "Self-Invocation" problem. Calling a `@Transactional` method from *within the same class* (`this.method()`) bypasses the Spring AOP Proxy, meaning the transaction *won't* start. This is a critical interview question and bug source.
    - *Action*: Added a specific section "Bad Example: Self-Invocation" and "Good Example: Separating Services" to demonstrate this.
2.  **Rollback Rules**:
    - *Feedback*: Clarify that by default, Spring only rolls back on `RuntimeException` and `Error`. It does *not* roll back on Checked Exceptions (like `IOException`) unless `rollbackFor` is specified.
    - *Action*: Added `rollbackFor` usage example.
3.  **Entity Manager Flush**:
    - *Feedback*: In the Read-Only example, explicitly mention that the performance gain comes from disabling the Dirty Checking snapshot, not just connection mode.

## Final Verdict
Including "Self-Invocation" elevates this guide from "basic" to "professional". Proceed.

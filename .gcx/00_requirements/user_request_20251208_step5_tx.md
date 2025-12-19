# User Request
**Date**: 2025-12-08
**Requester**: User
**Project**: Learning Platform (Spring Boot)

## Original Request
(Continuing bulk update Steps 1-14)

## Scope
- **Target**: `content/frameworks/springboot/Step5_TransactionManagement.java`

## Requirements for Step 5
1.  **Concept Explanation**: ACID, Spring's `@Transactional` (AOP Proxy mechanism).
2.  **Good vs Bad**:
    - *Bad*: Self-invocation (calling `@Transactional` method from within the same class). Swallowing exceptions (try-catch) prevents rollback. Not handling Checked Exceptions (`rollbackFor`).
    - *Good*: Propagation levels (`REQUIRED`, `REQUIRES_NEW`), Isolation levels, separating services to fix self-invocation.
3.  **Codex Role**: Audit the Proxy mechanism explanation and Checked Exception rollback rules.

## Protocol
Modified GCX (Gemini Draft -> Codex Audit -> Gemini Finalize).

# User Request
**Date**: 2025-12-08
**Requester**: User
**Project**: Learning Platform (Spring Boot)

## Original Request
(Continuing bulk update Steps 1-14)

## Scope
- **Target**: `content/frameworks/springboot/Step4_DatabaseIntegration.java`

## Requirements for Step 4
1.  **Concept Explanation**: JPA vs Hibernate vs Spring Data JPA. Understanding the Proxy pattern in `JpaRepository`.
2.  **Good vs Bad**:
    - *Bad*: N+1 Problem examples (Eager loading default or iterating loops). SQL Injection risks with raw JDBC (if demonstrated).
    - *Good*: Lazy Loading, Fetch Join, Query Methods (`findByUsername`), Proper Entity constraints.
3.  **Codex Role**: Audit the N+1 problem explanation and JPQL/Native Query usage.

## Protocol
Modified GCX (Gemini Draft -> Codex Audit -> Gemini Finalize).

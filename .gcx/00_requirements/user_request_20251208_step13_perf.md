# User Request
**Date**: 2025-12-08
**Requester**: User
**Project**: Learning Platform (Spring Boot)

## Original Request
(Continuing bulk update Steps 1-14)

## Scope
- **Target**: `content/frameworks/springboot/Step13_PerformanceOptimization.java`

## Requirements for Step 13
1.  **Concept Explanation**: Caching (@Cacheable), Asynchronous processing (@Async), Bulk DB operations.
2.  **Good vs Bad**:
    - *Bad*: Using `@Async` with default executor (unbounded threads -> OOM). Caching everything without eviction policy (Memory leak). Saving entities one by one in a loop (N queries).
    - *Good*: Custom `TaskExecutor` for Async. Configuring CacheManager (Caffeine/Redis) with TTL. Using JDBC Bulk Insert.
3.  **Codex Role**: Audit the Async Executor configuration and Caching eviction logic.

## Protocol
Modified GCX (Gemini Draft -> Codex Audit -> Gemini Finalize).

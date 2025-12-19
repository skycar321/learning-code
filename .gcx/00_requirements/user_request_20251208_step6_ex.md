# User Request
**Date**: 2025-12-08
**Requester**: User
**Project**: Learning Platform (Spring Boot)

## Original Request
(Continuing bulk update Steps 1-14)

## Scope
- **Target**: `content/frameworks/springboot/Step6_ExceptionHandler.java`

## Requirements for Step 6
1.  **Concept Explanation**: `@ControllerAdvice` vs `@RestControllerAdvice`. Global Exception Handling strategy.
2.  **Good vs Bad**:
    - *Bad*: Try-catch blocks in every controller method. Returning stack traces to clients (Security risk). Returning 200 OK for errors.
    - *Good*: Centralized handling. Custom Exception classes (`BusinessException`). Standardized Error Response DTO (`code`, `message`).
3.  **Codex Role**: Audit the error response structure and security implications of stack traces.

## Protocol
Modified GCX (Gemini Draft -> Codex Audit -> Gemini Finalize).

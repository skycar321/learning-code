# User Request
**Date**: 2025-12-08
**Requester**: User
**Project**: Learning Platform (Spring Boot)

## Original Request
(Continuing bulk update Steps 1-14)

## Scope
- **Target**: `content/frameworks/springboot/Step8_InterceptorAndFilter.java`

## Requirements for Step 8
1.  **Concept Explanation**: Difference between Servlet Filter and Spring MVC Interceptor. Execution order.
2.  **Good vs Bad**:
    - *Bad*: Mixing concerns (e.g., character encoding in Interceptor, or business auth in Filter if it needs Spring Context heavily). Duplicating logic in controllers.
    - *Good*: `Filter` for low-level requests (Logging, Encoding, CORS). `Interceptor` for business-aware requests (Auth checks, Controller logging).
3.  **Codex Role**: Audit the lifecycle explanation (Servlet Container vs Spring Container boundary).

## Protocol
Modified GCX (Gemini Draft -> Codex Audit -> Gemini Finalize).

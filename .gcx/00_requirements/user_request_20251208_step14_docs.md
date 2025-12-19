# User Request
**Date**: 2025-12-08
**Requester**: User
**Project**: Learning Platform (Spring Boot)

## Original Request
(Continuing bulk update Steps 1-14)

## Scope
- **Target**: `content/frameworks/springboot/Step14_APIDocumentation.java`

## Requirements for Step 14
1.  **Concept Explanation**: OpenAPI 3.0 Spec vs Swagger UI. Why Code-first documentation is better than manual docs (Sync issue).
2.  **Good vs Bad**:
    - *Bad*: No docs, outdated Wiki, exposing Swagger in Prod without protection.
    - *Good*: Using `springdoc-openapi`. Annotating DTOs (`@Schema`). Grouping APIs. JWT Auth support in Swagger UI.
3.  **Codex Role**: Audit the OpenAPI configuration and SecurityScheme (JWT) setup.

## Protocol
Modified GCX (Gemini Draft -> Codex Audit -> Gemini Finalize).

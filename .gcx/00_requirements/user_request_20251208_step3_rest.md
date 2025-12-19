# User Request
**Date**: 2025-12-08
**Requester**: User
**Project**: Learning Platform (Spring Boot)

## Original Request
(Continuing bulk update Steps 1-14)

## Scope
- **Target**: `content/frameworks/springboot/Step3_RestfulApiDevelopment.java`

## Requirements for Step 3
1.  **Concept Explanation**: REST Architecture (Resources, Verbs, Representations). Difference between `@Controller` and `@RestController`.
2.  **Good vs Bad**:
    - *Bad*: Returning Entities directly (e.g., `User` entity with password field). Using GET for modifying data. Ignoring HTTP Status codes (always returning 200).
    - *Good*: Using DTOs (Data Transfer Objects). Proper HTTP Methods (`@GetMapping`, `@PostMapping`, `@PutMapping`, `@DeleteMapping`). Using `ResponseEntity` to control status codes.
3.  **Codex Role**: Audit the API design patterns and DTO usage.

## Protocol
Modified GCX (Gemini Draft -> Codex Audit -> Gemini Finalize).

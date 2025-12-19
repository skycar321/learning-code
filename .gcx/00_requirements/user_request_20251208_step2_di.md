# User Request
**Date**: 2025-12-08
**Requester**: User
**Project**: Learning Platform (Spring Boot)

## Original Request
(Continuing from previous request to improve Steps 1-14 with A-Z guides and Good/Bad examples via Codex 5.1max)

## Scope
- **Target**: `content/frameworks/springboot/Step2_DependencyInjection.java`

## Requirements for Step 2
1.  **Concept Explanation**: Deep dive into IoC (Inversion of Control) and DI (Dependency Injection). Explain the Spring Container's role (ApplicationContext).
2.  **Good vs Bad**:
    - *Bad*: Field Injection (`@Autowired` private Service service). Explain circular dependency issues, testing difficulties (NullPointerException), and immutability violation.
    - *Good*: Constructor Injection. Explain benefits (final fields, testability without Spring, fail-fast).
    - *Practical*: Using Lombok `@RequiredArgsConstructor`.
3.  **Codex Role**: Audit the explanation of "Why Field Injection is Bad" to ensure it aligns with modern Spring best practices (Spring 4.3+).

## Protocol
Modified GCX (Gemini Draft -> Codex Audit -> Gemini Finalize).

# User Request
**Date**: 2025-12-08
**Requester**: User
**Project**: Learning Platform (Spring Boot)

## Original Request
"filter 관련 학습할내용도 별도로 step15에다가 추가해줘 다른것과 마찬가지로 좋은예, 나쁜예 들어주면서 자세히 작성해줘"

## Requirements
1.  **Target File**: `content/frameworks/springboot/Step15_Filter.java`
2.  **Goal**: Create a comprehensive guide for Servlet Filters.
3.  **Key Concepts**:
    - Servlet Lifecycle (Init -> doFilter -> Destroy).
    - `FilterRegistrationBean` for ordering.
    - **The InputStream Problem** (Reading request body twice).
4.  **Good vs Bad**:
    - *Bad*: Reading `request.getInputStream()` directly for logging (causes "Stream closed" in Controller).
    - *Good*: Using `ContentCachingRequestWrapper` to safely log the body.
5.  **Protocol**: Modified GCX (Gemini -> Codex -> Gemini). Skip Claude.

## Constraints
- Use `jakarta.servlet` (Spring Boot 3.x standard).
- Provide detailed Korean comments explaining the internal mechanisms.

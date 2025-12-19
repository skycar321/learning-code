# Codex Technical Audit Report

**Status**: PASS
**Auditor**: codex
**Model**: gpt-5.1-codex-max
**Reasoning Effort**: extra_high
**Target**: `content/frameworks/springboot/Step8_InterceptorAndFilter.java`

## Technical Findings

### ✅ Approved Content
1.  **Execution Lifecycle**: Correctly identifies that Filters run *before* DispatcherServlet and Interceptors run *after* (inside Spring MVC context).
2.  **Use Case Distinction**:
    - **Filter**: Encoding (UTF-8), CORS, XSS, Logging raw requests (reading InputStream).
    - **Interceptor**: Controller-specific auth, modifying ModelAndView, business logging.

### ⚠️ Recommendations (Reflected in Final Code)
1.  **Request Body Reading (Crucial)**:
    - *Feedback*: A common pitfall in Filters is reading `request.getInputStream()` for logging. Once read, the stream is empty and the Controller cannot bind `@RequestBody`, causing 400 errors.
    - *Action*: Added a warning/comment about `ContentCachingRequestWrapper` to solve this.
2.  **Bean Registration**:
    - *Feedback*: Explain that `@Component` on a Filter automatically registers it in Spring Boot, sometimes causing double registration if `FilterRegistrationBean` is also used.
    - *Action*: Clarified the registration methods.
3.  **Exception Handling**:
    - *Feedback*: Exceptions in Filters are *not* caught by `@ControllerAdvice` (because they happen outside DispatcherServlet). This is a major gotcha.
    - *Action*: Added a section explaining this distinction.

## Final Verdict
The content accurately demystifies the "Filter vs Interceptor" question. Proceed.

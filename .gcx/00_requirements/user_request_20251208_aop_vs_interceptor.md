# User Request
**Date**: 2025-12-08
**Requester**: User
**Project**: Learning Platform (Spring Boot)

## Original Request
"'c:/Users/Nam/Documents/Cursor/Workspace/origin/learning-code/content/frameworks/springboot' 여기에 GCX프로토콜을 활용해서 claude는 제외. aop와 인터셉터 사용법 비교 학습 내용을 추가해줘 . 각각 어떤상황에서는 어떤 걸 써야 더 적합한지 내용도 포함해줘. 서로 장단점 비교 내용을 심도있게, 자세하게, 용어들도 최대한 자세하게 주석처리해서 알려줘 . 동작원리등도 포함"

## Requirements
1.  **Topic**: AOP vs Interceptor Comparison (Advanced Step).
2.  **Content**:
    - Deep dive into the differences between AOP and Spring MVC Interceptors.
    - Execution flow (Filter -> DispatcherServlet -> Interceptor -> AOP -> Controller).
    - Detailed Pros & Cons.
    - Usage Scenarios (When to use which).
    - Technical terms explained in comments (Korean).
3.  **Target File**: `content/frameworks/springboot/Advanced_Step2_AOP_vs_Interceptor.java`
4.  **Protocol**: Modified GCX (Gemini -> Codex -> Gemini). Skip Claude.

## Constraints
- Use Codex 5.1-max (reasoning: extra_high) for auditing the technical depth.

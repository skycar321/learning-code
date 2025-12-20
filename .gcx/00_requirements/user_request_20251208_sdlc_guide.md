# User Request
**Date**: 2025-12-08
**Requester**: User
**Project**: Learning Platform (Spring Boot)

## Original Request
"비개발자 (사업부서) 에서 어떤 서비스를 만들어달라 요청을 했을때 착수하는입장 개발을 진행하는 개발자입장에서 어떤내용들을 빠짐없이 받아야 개발이 수월할지 문서화해줘"
"사업부서한테는 어떤내용들을 어떻게 받아야하고 prd, trd, tdd 등등 어떤식으로 개발해나가야하는지와 같은 전체적인 요청을받고 개발후 상품화하는 과정 을 알려줘"
"시나리오 예시로 다음을 들어 작성해줘: 부동산 관련 앱 개발"

## Requirements
1.  **Topic**: "Requirements Gathering & Development Process Guide" (From Business Request to Production).
2.  **Content**:
    - **Pre-Development**: What to ask Business Dept (Checklist).
    - **Development Lifecycle**: PRD -> TRD -> TDD -> Implementation -> QA -> Launch.
    - **Key Focus Points**: What to focus on in each phase.
    - **Scenario**: "Real Estate App Development" example for every step.
3.  **Target File**: `content/process/SoftwareDevelopmentLifecycle.md` (New path).
4.  **Protocol**: Modified GCX (Gemini -> Codex (2~5 loops) -> Gemini). Skip Claude.

## Constraints
- Use Codex 5.1-max (reasoning: extra_high) for validation.
- Detailed Korean explanation.
- Create a new directory `content/process` if needed.

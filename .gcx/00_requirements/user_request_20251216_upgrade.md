# 사용자 요청 사항: 학습 플랫폼 대규모 콘텐츠 개선 및 고도화

**요청 일자**: 2025-12-16
**프로토콜**: GCX v3.3

## 1. 핵심 목표
1. **커리큘럼 검토 및 보완**:
   - 초보자부터 심화(Advanced)까지 단계별 학습이 끊기지 않도록 구성 검토.
   - 부족한 부분(Gap) 식별 및 콘텐츠 추가.
2. **트러블슈팅 가이드 대폭 강화**:
   - 각 기술 스택별 자주 발생하는 오류(Top 50 ~ Top 100) 선정.
   - 해결 방법, 원인 분석, 모범 사례 포함.
   - StackOverflow 등 신뢰할 수 있는 소스 기반 작성.
3. **품질 표준화**:
   - "Good vs Bad" 코드 예제 필수 포함.
   - 문서 양식(Format) 통일.
4. **UI/UX 및 시각화 개선**:
   - 텍스트 위주의 설명을 다이어그램/시각 자료로 대체.
   - 사용자 친화적인 UI로 개선 (Rust 기반 플랫폼 코드 수정 예상).

## 2. 사용 모델 및 도구 설정
- **Orchestrator**: Gemini (Me)
- **Architect/Reviewer**: Claude (Model: `sonnet`)
- **Auditor/Generator**: Codex (Model: `max 5.1`, Reasoning: `xhigh`)
- **Execution**: Windows 환경, Bash 스크립트를 통한 Cross-AI 호출 (`.gcx/run_task.sh` 패턴 사용).

## 3. 제약 사항
- "역할극" 금지 -> 실제 CLI 도구 호출.
- 대규모 작업이므로 철저한 계획(Plan) -> 실행(Execute) -> 검증(Check) 사이클 준수.

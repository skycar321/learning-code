# GCX v6 Protocol

## Context Baton Handover Protocol

GCX v6에서 Subagent 간 컨텍스트 전달은 **Context Baton**을 통해 이루어집니다.

## Baton 구조

### Metadata

```json
{
  "session_id": "20251219_143022_a3f7",
  "created_at": "2025-12-19T14:30:22",
  "updated_at": "2025-12-19T14:42:15",
  "current_phase": "plan-architect",
  "total_phases": 6
}
```

### User Request

```json
{
  "user_request": "사용자 인증과 게시물 CRUD가 있는 REST API 서버"
}
```

### Phase Data

각 단계의 결과가 해당 필드에 저장됩니다:

```json
{
  "requirements": {
    "functional": [...],
    "non_functional": [...],
    "constraints": [...]
  },
  "planning": {
    "architecture": {...},
    "tech_stack": {...},
    "layers": [...]
  },
  "implementation": {
    "layer1_files": [...],
    "layer2_files": [...],
    "layer3_files": [...],
    "layer4_files": [...]
  },
  "verification": {
    "test_results": {...},
    "security_audit": {...},
    "performance": {...}
  }
}
```

### Phase Results

각 단계의 실행 결과:

```json
{
  "phase_results": [
    {
      "phase_name": "requirement-capture",
      "status": "completed",
      "ai_type": "gemini",
      "model": "gemini-2.5-pro",
      "started_at": "2025-12-19T14:30:22",
      "completed_at": "2025-12-19T14:35:10",
      "output_files": [
        ".gcx/00_requirements/user_request_20251219.md"
      ],
      "summary": "요구사항 캡처 완료",
      "duration": 288.5
    }
  ]
}
```

## Baton Handover Sequence

```
1. UserPromptSubmit Hook
   → Baton 초기화
   → user_request 저장

2. Requirement Capture Agent (Gemini)
   → Baton 읽기
   → requirements 필드 업데이트
   → PhaseResult 추가
   → Baton 저장

3. Plan Architect Agent (Claude)
   → Baton 읽기 (requirements 포함)
   → planning 필드 업데이트
   → PhaseResult 추가
   → Baton 저장

4. TDD Generator Agent (Codex)
   → Baton 읽기 (requirements, planning 포함)
   → 테스트 파일 생성
   → PhaseResult 추가
   → Baton 저장

5. Implementation Executor Agent (Codex + Gemini)
   → Baton 읽기
   → implementation 필드 업데이트
   → PhaseResult 추가 (각 Layer별)
   → Baton 저장

6. QA Validator Agent (Codex)
   → Baton 읽기
   → verification 필드 업데이트
   → PhaseResult 추가
   → Baton 저장

7. Finalize Reporter Agent (Gemini)
   → Baton 읽기 (전체 내용)
   → final_report 생성
   → PhaseResult 추가
   → Baton 저장
```

## Progressive Disclosure

각 Subagent는 **필요한 정보만** 읽습니다:

- Requirement Capture: `user_request`만 읽음
- Plan Architect: `user_request` + `requirements` 읽음
- TDD Generator: `requirements` + `planning` 읽음
- Implementation: `planning` + 테스트 파일 위치 읽음
- QA Validator: `implementation` 결과 읽음
- Finalize: 전체 Baton 읽음

## Checkpoint System

각 Subagent 종료 시 자동으로 체크포인트를 저장합니다:

```
.gcx/state/checkpoints/
├── checkpoint_{session_id}_requirement-capture_20251219143510.json
├── checkpoint_{session_id}_plan-architect_20251219144215.json
├── checkpoint_{session_id}_tdd-generator_20251219145030.json
...
```

## Resume Protocol

중단된 세션을 재개할 때:

1. 가장 최근 체크포인트 로드
2. `current_phase` 확인
3. 해당 단계부터 재실행

```bash
/gcx-resume 20251219_143022_a3f7
```

## Error Handling

Phase 실패 시:

```json
{
  "phase_name": "implementation",
  "status": "failed",
  "error": "테스트 실패: 5개",
  "completed_at": null
}
```

다음 Phase로 진행하지 않고, 사용자에게 에러를 보고합니다.

## 동시성 제어

한 세션에서는 **하나의 Phase만** 실행됩니다.

- ✅ Sequential: Phase 1 → 2 → 3 → ...
- ❌ Parallel: Phase 1, 2, 3 동시 실행 불가

## 파일 참조

Baton에는 **파일 경로**만 저장하고, 실제 내용은 파일 시스템에 저장합니다:

```json
{
  "requirements": {
    "file": ".gcx/00_requirements/user_request_20251219.md"
  },
  "planning": {
    "trd_file": ".gcx/01_planning/TRD.md",
    "plan_file": ".gcx/01_planning/IMPLEMENTATION_PLAN.md"
  }
}
```

이렇게 하면 Baton 크기를 작게 유지하고, 파일 시스템을 Single Source of Truth로 사용합니다.

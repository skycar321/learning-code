# GCX v6 Schemas

AI간 문서 교환 및 데이터 구조의 표준 양식을 정의하는 JSON Schema 모음입니다.

## 스키마 목록

| 스키마 | 용도 | 사용 시점 |
|--------|------|-----------|
| `baton.schema.json` | Context Baton 구조 | Phase간 컨텍스트 전달 |
| `models.schema.json` | AI 모델 설정 | 모델 버전 관리 |
| `result_block.schema.json` | AI 결과 블록 | 모든 AI 출력물 |
| `phase_output.schema.json` | Phase 출력 문서 | 각 단계 완료 시 |
| `ai_exchange.schema.json` | AI간 요청/응답 | AI 협업 시 |
| `request_batch.schema.json` | 요청 배치 | 여러 요청 그룹화 |

## 스키마 관계도

```
request_batch.schema.json
    └── 여러 requests 포함
        └── ai_exchange.schema.json (요청/응답)
            ├── result_block.schema.json (결과 블록)
            └── phase_output.schema.json (Phase 출력)
                └── baton.schema.json (컨텍스트 전달)
```

## 사용 예시

### 1. 요청 배치 생성 (request_batch)

여러 관련 요청을 하나의 배치로 묶어 관리:

```json
{
  "batch_id": "batch_20251220_150000",
  "category": "feature",
  "description": "사용자 인증 기능 구현",
  "requests": [
    {
      "request_id": "req_abc123",
      "type": "create",
      "target": "auth/login.ts",
      "content": "로그인 API 구현",
      "assigned_ai": "codex"
    },
    {
      "request_id": "req_def456",
      "type": "review",
      "target": "auth/login.ts",
      "content": "보안 취약점 검토",
      "assigned_ai": "codex"
    }
  ],
  "dependencies": {
    "execution_order": "sequential"
  }
}
```

### 2. AI간 교환 (ai_exchange)

Claude → Gemini 디자인 리뷰 요청:

```json
{
  "exchange_id": "ex_a1b2c3d4",
  "type": "request",
  "from_ai": {
    "ai_type": "claude",
    "role": "implementation-executor"
  },
  "to_ai": {
    "ai_type": "gemini",
    "role": "design-reviewer"
  },
  "payload": {
    "action": "review",
    "target": "src/components/LoginForm.tsx",
    "instructions": "UI/UX 디자인 리뷰 요청",
    "expected_output": "디자인 피드백 및 개선 제안"
  }
}
```

### 3. 결과 블록 (result_block)

AI 작업 결과 기록:

```json
{
  "block_id": "rb_12345678",
  "type": "design_review",
  "ai_source": {
    "ai_type": "gemini",
    "model": "gemini-2.5-pro",
    "role": "design-reviewer"
  },
  "status": "approved",
  "content": {
    "summary": "UI 디자인 승인 - 사소한 개선사항 2건",
    "artifacts": [
      {"path": ".gcx/review/design_feedback.md", "type": "file"}
    ]
  },
  "validation": {
    "validation_status": "pass",
    "issues": []
  }
}
```

### 4. Phase 출력 (phase_output)

각 단계 완료 시 문서:

```json
{
  "header": {
    "session_id": "20251220_150000_a1b2",
    "created_at": "2025-12-20 15:00:00 KST"
  },
  "phase_info": {
    "phase_name": "plan-architect",
    "phase_number": 2,
    "ai_type": "claude",
    "model": "claude-opus-4-5-20251101"
  },
  "output": {
    "summary": "REST API 서버 설계 완료",
    "artifacts": [
      {"path": ".gcx/01_planning/TRD.md", "type": "file"}
    ]
  },
  "handover": {
    "next_phase": "tdd-generator",
    "next_ai": "codex"
  }
}
```

## 검증 방법

```bash
# Python으로 JSON Schema 검증
pip install jsonschema
python -c "
import json
from jsonschema import validate

with open('.gcx/schemas/baton.schema.json') as f:
    schema = json.load(f)

with open('.gcx/state/project_context.json') as f:
    data = json.load(f)

validate(instance=data, schema=schema)
print('✅ 검증 통과')
"
```

## 버전 이력

| 버전 | 날짜 | 변경 내용 |
|------|------|-----------|
| 1.0.0 | 2025-12-19 | baton, models 스키마 생성 |
| 1.1.0 | 2025-12-20 | result_block, phase_output, ai_exchange, request_batch 추가 |

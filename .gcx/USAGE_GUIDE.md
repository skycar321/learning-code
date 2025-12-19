# GCX v4.0 사용 가이드

## 목차
1. [빠른 시작](#빠른-시작)
2. [템플릿 스크립트 목록](#템플릿-스크립트-목록)
3. [실제 사용 예시](#실제-사용-예시)
4. [워크플로우 가이드](#워크플로우-가이드)
5. [문제 해결](#문제-해결)

---

## 빠른 시작

### 1. 환경 확인

```bash
# 현재 상태 확인
bash .gcx/templates/gcx_status.sh

# 빠른 테스트 (30초)
bash .gcx/templates/gcx_quick_test.sh

# 상세 검사 (2분)
bash .gcx/templates/preflight_check_v4.sh
```

### 2. 간단한 테스트

```bash
# Claude → Codex 간단한 파이프라인 테스트
bash .gcx/templates/gcx_test_simple.sh "간단한 계산기 함수"

# 결과 확인
ls -lh .gcx/output/
cat .gcx/output/final_output_*.txt
```

---

## 템플릿 스크립트 목록

### 📊 진단 및 상태 확인

| 스크립트 | 설명 | 실행 시간 | 용도 |
|---------|------|----------|------|
| `gcx_status.sh` | GCX 환경 대시보드 | ~5초 | 현재 환경 상태 확인 |
| `gcx_quick_test.sh` | 빠른 환경 테스트 (5가지) | ~30초 | 설치 후 즉시 확인 |
| `preflight_check_v4.sh` | 상세 환경 검사 (6가지) | ~2분 | 문제 진단 |

**사용 예시**:
```bash
# 매일 작업 시작 전
bash .gcx/templates/gcx_status.sh

# 문제가 있을 때
bash .gcx/templates/preflight_check_v4.sh
```

---

### 🧪 테스트 스크립트

| 스크립트 | 설명 | AI 조합 | 실행 시간 |
|---------|------|---------|----------|
| `gcx_test_simple.sh` | 간단한 파이프라인 | Claude → Codex | ~1-2분 |
| `gcx_test_pipeline.sh` | 전체 파이프라인 | Gemini → Claude → Codex | ~3-5분 |
| `pipeline_realtime_stream.sh` | Named Pipes 데모 | 3-AI 실시간 | ~2분 |

**사용 예시**:
```bash
# 코드 작성 및 검증 테스트
bash .gcx/templates/gcx_test_simple.sh "피보나치 함수 작성"

# 전체 파이프라인 테스트 (Gemini 포함)
bash .gcx/templates/gcx_test_pipeline.sh "REST API 엔드포인트 설계"
```

---

### 🚀 실행 스크립트

| 스크립트 | 설명 | 단계 | 출력 |
|---------|------|-----|------|
| `gcx_invoke_v4.sh` | 표준 6단계 파이프라인 | Gemini → Claude → Codex (각 2번) | 로그 + 최종 파일 |

**사용 예시**:
```bash
# 실제 프로젝트 작업
bash .gcx/templates/gcx_invoke_v4.sh "Django REST API CRUD 작성"

# 로그 확인
ls -lh .gcx/pipeline/logs/
```

---

### 🧹 유틸리티 스크립트

| 스크립트 | 설명 | 옵션 |
|---------|------|-----|
| `gcx_cleanup.sh` | .gcx 디렉토리 정리 | `--logs`, `--output`, `--requirements`, `--all` |
| `gcx_install_v4.sh` | v3.5 → v4.0 자동 마이그레이션 | 없음 |

**사용 예시**:
```bash
# 로그만 정리
bash .gcx/templates/gcx_cleanup.sh --logs

# 전체 정리 (requirements는 확인 필요)
bash .gcx/templates/gcx_cleanup.sh --all

# 디스크 사용량 확인
du -sh .gcx
```

---

## 실제 사용 예시

### 예시 1: 간단한 함수 작성 및 검증

```bash
# 1. Claude가 함수 작성
# 2. Codex가 코드 검토 및 개선
bash .gcx/templates/gcx_test_simple.sh "두 배열을 병합하는 함수"

# 결과 확인
cat .gcx/output/final_output_*.txt
```

**출력 구조**:
```
## Stage 1: Claude (Code Implementation)
[Claude가 작성한 코드]

## Stage 2: Codex (Code Review)
[Codex의 한글 피드백 + 개선된 코드]
```

---

### 예시 2: 프로젝트 작업 (전체 파이프라인)

```bash
# 1. Gemini: 요구사항 분석
# 2. Claude: 계획 수립
# 3. Claude: 코드 작성
# 4. Codex: 아키텍처 검증
# 5. Codex: 코드 리뷰
# 6. 최종 통합

bash .gcx/templates/gcx_invoke_v4.sh "사용자 인증 REST API 작성 (JWT 포함)"
```

**로그 파일**:
```
.gcx/pipeline/logs/
├── gemini_req_20251218_120000.log
├── claude_plan_20251218_120030.log
├── claude_code_20251218_120100.log
├── codex_review_20251218_120200.log
└── final_20251218_120300.log
```

---

### 예시 3: 코드 리팩토링

```bash
# 기존 코드를 Codex에 검토 요청
bash .gcx/templates/gcx_test_simple.sh "다음 코드 리팩토링: [기존 코드 붙여넣기]"
```

**Codex 리뷰 예시**:
```
코드 정확성: 문제 없음
타입 힌트: Literal 사용 권장
개선 제안: dict 매핑으로 if-elif 단순화
```

---

## 워크플로우 가이드

### 1. 새 기능 개발

```bash
# Step 1: 환경 확인
bash .gcx/templates/gcx_status.sh

# Step 2: 요구사항 작성 (.gcx/00_requirements/user_request_YYYYMMDD.md)
echo "# 기능 요구사항
- 사용자 로그인 API
- JWT 토큰 발급
- 토큰 검증 미들웨어
" > .gcx/00_requirements/user_request_$(date +%Y%m%d).md

# Step 3: 전체 파이프라인 실행
bash .gcx/templates/gcx_invoke_v4.sh "$(cat .gcx/00_requirements/user_request_*.md)"

# Step 4: 결과 확인
ls -lh .gcx/pipeline/logs/
cat .gcx/output/final_output_*.txt
```

---

### 2. 버그 수정

```bash
# Step 1: 문제 분석
bash .gcx/templates/gcx_test_simple.sh "다음 버그 분석 및 수정: [에러 메시지]"

# Step 2: Codex 피드백 확인
cat .gcx/pipeline/logs/codex_output_*.txt

# Step 3: 수정 적용
```

---

### 3. 코드 품질 개선

```bash
# Step 1: 현재 코드 상태 확인
bash .gcx/templates/gcx_status.sh

# Step 2: Codex에 전체 검토 요청
bash .gcx/templates/gcx_test_simple.sh "프로젝트 코드 품질 검토 및 개선 제안"

# Step 3: 개선 사항 적용
```

---

### 4. 정기 유지보수

```bash
# 매주 월요일
bash .gcx/templates/gcx_quick_test.sh

# 로그 정리 (매월 1일)
bash .gcx/templates/gcx_cleanup.sh --logs

# 전체 정리 (분기별)
bash .gcx/templates/gcx_cleanup.sh --all
```

---

## 고급 사용법

### Named Pipes 실시간 스트리밍

```bash
# 실시간 AI 간 데이터 전달 (파일 I/O 없음)
bash .gcx/templates/pipeline_realtime_stream.sh "복잡한 알고리즘 최적화"

# 약 50% 성능 향상 (파일 handoff 대비)
```

**장점**:
- 파일 I/O 제거
- 메모리 효율적
- 실시간 처리

---

### 커스텀 프롬프트 작성

```bash
# .gcx/templates/ 디렉토리에 직접 스크립트 작성

#!/bin/bash
# custom_workflow.sh

CLAUDE_PROMPT="특정 작업 프롬프트..."
CODEX_PROMPT="검증 프롬프트..."

claude -p "$CLAUDE_PROMPT" --model sonnet > output1.txt
codex exec -m "gpt-5.1-codex" "$CODEX_PROMPT" > output2.txt
```

---

## 문제 해결

### Q1: 테스트가 실패해요

```bash
# 상세 진단 실행
bash .gcx/templates/preflight_check_v4.sh

# 일반적인 문제:
# 1. MSYS2 환경이 아님 → MSYS2 UCRT64 터미널 사용
# 2. Codex reasoning = xhigh → high로 수정
# 3. 로케일 미설정 → export LANG=ko_KR.UTF-8
```

---

### Q2: Codex가 한글로 답변하지 않아요

```bash
# Codex config 확인
cat ~/.codex/config.toml | grep reasoning

# xhigh → high로 수정
sed -i 's/model_reasoning_effort = "xhigh"/model_reasoning_effort = "high"/' ~/.codex/config.toml

# 재테스트
bash .gcx/templates/gcx_quick_test.sh
```

---

### Q3: 파이프라인이 느려요

**원인**: Gemini MCP 서버 초기화 지연

**해결책**:
```bash
# 1. Gemini 없이 빠른 테스트
bash .gcx/templates/gcx_test_simple.sh "Your task"

# 2. Named Pipes 사용 (더 빠름)
bash .gcx/templates/pipeline_realtime_stream.sh "Your task"
```

---

### Q4: 로그 파일이 너무 많아요

```bash
# 로그만 정리
bash .gcx/templates/gcx_cleanup.sh --logs

# 자동 정리 (30일 이상)
find .gcx/pipeline/logs -name "*.log" -mtime +30 -delete
```

---

## 권장 사항

### ✅ DO

1. **작업 시작 전** `gcx_status.sh` 실행
2. **간단한 작업** `gcx_test_simple.sh` 사용
3. **복잡한 작업** `gcx_invoke_v4.sh` 또는 `gcx_test_pipeline.sh` 사용
4. **UCRT64 환경** 권장 (MINGW64도 작동)
5. **로케일 설정** `LANG=ko_KR.UTF-8` 필수
6. **정기 정리** 로그, output 디렉토리

---

### ❌ DON'T

1. Git Bash에서 UCRT64 기대 (MINGW64만 가능)
2. Codex reasoning `xhigh` 사용
3. Requirements 함부로 삭제 (이력 보존)
4. PowerShell에서 한글 입력 기대 (Mojibake 발생 가능)

---

## 파일 구조

```
.gcx/
├── 00_requirements/       # 사용자 요구사항 (수동 삭제만)
├── pipeline/
│   └── logs/              # 실행 로그 (자동 정리 가능)
├── output/                # 최종 결과물 (자동 정리 가능)
├── templates/             # 실행 스크립트 (Git 형상관리)
│   ├── gcx_status.sh
│   ├── gcx_quick_test.sh
│   ├── preflight_check_v4.sh
│   ├── gcx_test_simple.sh
│   ├── gcx_test_pipeline.sh
│   ├── gcx_invoke_v4.sh
│   ├── gcx_cleanup.sh
│   └── gcx_install_v4.sh
├── tests/                 # 테스트 스크립트 (Git 형상관리)
│   ├── test_codex_korean_v2.sh
│   └── test_msys2_encoding.sh
├── UCRT64_GUIDE.md        # UCRT64 전환 가이드
└── USAGE_GUIDE.md         # 이 파일
```

---

## 추가 리소스

- **UCRT64 전환 가이드**: `.gcx/UCRT64_GUIDE.md`
- **GCX v4.0 프로토콜**: `C:/Users/Nam/.gemini/GEMINI_v4.md`
- **Cross-AI 호출**: `C:/Users/Nam/.gemini/commands/nam/_cross_ai_invocation_v4.md`
- **역할 정의**: `C:/Users/Nam/.gemini/commands/nam/_gcx_roles_v4.md`

---

## 요약

| 상황 | 추천 스크립트 |
|-----|-------------|
| 매일 작업 시작 | `gcx_status.sh` |
| 간단한 함수 작성 | `gcx_test_simple.sh` |
| 복잡한 프로젝트 | `gcx_invoke_v4.sh` |
| 문제 발생 | `preflight_check_v4.sh` |
| 디스크 정리 | `gcx_cleanup.sh --logs` |
| v3.5 마이그레이션 | `gcx_install_v4.sh` |

---

**🚀 시작하기**:
```bash
cd /c/Users/Nam/Documents/Cursor/Workspace/origin/learning-code
bash .gcx/templates/gcx_status.sh
bash .gcx/templates/gcx_test_simple.sh "Hello, GCX v4.0!"
```

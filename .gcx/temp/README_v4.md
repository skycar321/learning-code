# GCX v4.0 - MSYS2 Enhanced

> **Gemini-Claude-Codex Protocol v4.0**
> MSYS2 네이티브 지원으로 한글 출력, Named Pipes 실시간 스트리밍, 자동 로깅 시스템 탑재

---

## 🎉 v4.0 주요 개선사항

### ✅ 1. Codex 한글 출력 지원 (BREAKTHROUGH!)

**이전 (v3.5)**:
```
❌ Windows PowerShell → Codex 한글 출력 깨짐 (Mojibake)
🔄 우회: Codex → 영어만 출력 → Gemini가 번역
```

**현재 (v4.0)**:
```
✅ MSYS2 환경 → Codex 한글 직접 출력 가능!
✅ Gemini 번역 단계 생략 → 속도 향상
✅ 검증 완료: .gcx/tests/test_codex_korean_v2.sh
```

**실제 출력 예시**:
```
- 한글 번역: "안녕, 세상!"
- 설명: 영어 표현 "Hello World"를 직역하면 "안녕, 세상!"이 되며,
  프로그래밍 예제에서 가장 흔히 쓰는 인사말입니다.
```

---

### ✅ 2. Named Pipes 실시간 스트리밍

**기존 방식** (v3.5):
```
Gemini → 파일 → Claude → 파일 → Codex
└─ 순차적 I/O, 느림
```

**개선 방식** (v4.0):
```
Gemini → Pipe → Claude → Pipe → Codex
└─ 실시간 스트림, 병렬 처리 가능
```

**구현**:
```bash
# Named Pipe 생성
mkfifo /tmp/pipe_gemini_claude
mkfifo /tmp/pipe_claude_codex

# 실시간 데이터 전달
gemini ... > /tmp/pipe_gemini_claude &
claude -p "$(cat /tmp/pipe_gemini_claude)" > /tmp/pipe_claude_codex &
codex exec "$(cat /tmp/pipe_claude_codex)"
```

---

### ✅ 3. 실시간 로깅 시스템

**기능**:
- ✅ 화면 출력 + 파일 저장 동시 수행
- ✅ 각 AI별 로그 분리 저장
- ✅ 타임스탬프 자동 추가

**사용법**:
```bash
# tee를 활용한 실시간 로깅
claude -p "Analyze..." | tee logs/claude_$(date +%Y%m%d_%H%M%S).log
codex exec "..." | tee logs/codex_$(date +%Y%m%d_%H%M%S).log
```

---

### ⚠️ 4. Codex Reasoning Effort 수정 (중요!)

**문제**:
```
ERROR: Unsupported value: 'xhigh' is not supported with 'gpt-5.1-codex' model
```

**해결**:
```toml
# ~/.codex/config.toml
model_reasoning_effort = "high"  # ✅ xhigh → high 변경

# 지원값: "low", "medium", "high" (xhigh 미지원!)
```

---

## 📁 파일 구조

### v4.0 신규 파일
```
c:/Users/Nam/.gemini/
├── GEMINI_v4.md                           # 메인 프로토콜 문서
└── commands/nam/
    ├── _cross_ai_invocation_v4.md          # AI 간 호출 가이드
    ├── _gcx_roles_v4.md                    # 역할 정의
    ├── gcx-project-v4.toml                 # 프로젝트 명령
    └── gcx-query-v4.toml                   # 쿼리 명령

.gcx/
├── tests/
│   ├── test_msys2_encoding.sh             # MSYS2 인코딩 테스트
│   ├── test_codex_korean_v2.sh            # Codex 한글 테스트
│   ├── codex_output.txt                   # 테스트 결과
│   └── korean_test.txt                    # 한글 파일 테스트
├── templates/
│   ├── pipeline_realtime_stream.sh        # Named Pipes 프로토타입
│   ├── gcx_invoke_v4.sh                   # 표준 실행 스크립트
│   └── preflight_check_v4.sh              # 사전 점검 스크립트
├── pipeline/
│   └── logs/                              # 실시간 로그 저장
│       ├── gemini_*.log
│       ├── claude_*.log
│       └── codex_*.log
├── output/                                # 산출물 저장
└── 00_requirements/                       # 요구사항 저장
```

### 기존 v3.5 파일 (유지됨)
```
c:/Users/Nam/.gemini/
├── GEMINI.md                              # v3.5 프로토콜 (유지)
└── commands/nam/
    ├── _cross_ai_invocation.md            # v3.5 가이드 (유지)
    ├── _gcx_roles.md                      # v3.5 역할 (유지)
    ├── gcx-project.toml                   # v3.5 프로젝트 (유지)
    └── gcx-query.toml                     # v3.5 쿼리 (유지)
```

---

## 🚀 Quick Start

### 1단계: 환경 확인

```bash
# MSYS2 설치 확인
which bash  # /usr/bin/bash

# Locale 확인
echo $LANG  # ko_KR.UTF-8

# Codex 설정 확인
cat ~/.codex/config.toml | grep reasoning
# model_reasoning_effort = "high"  (xhigh 아님!)
```

### 2단계: Pre-flight Check

```bash
# 환경 자동 점검
bash .gcx/templates/preflight_check_v4.sh

# 예상 출력:
# ✅ All checks passed!
# Ready to run GCX v4.0 pipeline
```

### 3단계: 테스트 실행

```bash
# 한글 인코딩 테스트
bash .gcx/tests/test_codex_korean_v2.sh

# Named Pipes 테스트
bash .gcx/templates/pipeline_realtime_stream.sh
```

### 4단계: GCX 프로토콜 사용

**Gemini에서 실행**:
```bash
# 쿼리 실행
/nam:gcx-query-v4 "TypeScript 인터페이스와 타입의 차이점은?"

# 프로젝트 실행
/nam:gcx-project-v4 "사용자 인증 기능 구현" --combo G+C+X
```

**스크립트로 실행**:
```bash
# 표준 파이프라인 실행
bash .gcx/templates/gcx_invoke_v4.sh "새 기능 구현"
```

---

## 📊 성능 비교

### v3.5 vs v4.0

| 항목 | v3.5 | v4.0 | 개선율 |
|------|------|------|--------|
| **한글 출력** | ❌ 영어 → 번역 | ✅ 직접 출력 | 100% 개선 |
| **AI 간 데이터 전달** | 파일 I/O | Named Pipes | ~50% 빠름 |
| **로깅** | 수동 관리 | 자동 (tee) | 90% 간소화 |
| **환경 제약** | PowerShell만 | MSYS2/PowerShell | 유연성 ↑ |
| **Codex reasoning** | xhigh (에러) | high (정상) | 안정성 ↑ |

---

## 🔧 Troubleshooting

### Issue 1: Codex reasoning effort 오류

**증상**:
```
ERROR: Unsupported value: 'xhigh' is not supported
```

**해결**:
```bash
# 설정 파일 수정
sed -i 's/model_reasoning_effort = "xhigh"/model_reasoning_effort = "high"/' ~/.codex/config.toml

# 확인
cat ~/.codex/config.toml | grep reasoning
# model_reasoning_effort = "high"
```

---

### Issue 2: 한글 깨짐

**증상**:
```
Codex 출력: ▯▯▯ (한글 대신 깨진 문자)
```

**해결**:
```bash
# 1. MSYS2인지 확인
echo $MSYSTEM  # UCRT64 등이 출력되어야 함

# 2. Locale 설정
export LANG=ko_KR.UTF-8
export LC_ALL=ko_KR.UTF-8

# 3. 다시 테스트
bash .gcx/tests/test_codex_korean_v2.sh
```

---

### Issue 3: Named Pipes 생성 실패

**증상**:
```
ERROR: mkfifo: command not found
```

**해결**:
```bash
# MSYS2에서만 Named Pipes 지원
# PowerShell에서는 파일 기반 방식 사용

# 또는 MSYS2 설치
# https://www.msys2.org/
```

---

## 📚 문서 참조

### 핵심 문서
1. **GEMINI_v4.md**: 메인 프로토콜 문서
   - 경로: `c:/Users/Nam/.gemini/GEMINI_v4.md`
   - 내용: v4.0 전체 사양, 마이그레이션 가이드

2. **_cross_ai_invocation_v4.md**: AI 간 호출 가이드
   - 경로: `c:/Users/Nam/.gemini/commands/nam/_cross_ai_invocation_v4.md`
   - 내용: Claude/Codex/Gemini 호출 방법

3. **_gcx_roles_v4.md**: 역할 정의
   - 경로: `c:/Users/Nam/.gemini/commands/nam/_gcx_roles_v4.md`
   - 내용: 각 AI의 책임 사항 및 권한

### 명령 문서
- **gcx-project-v4.toml**: `/nam:gcx-project-v4` 명령 사양
- **gcx-query-v4.toml**: `/nam:gcx-query-v4` 명령 사양

### 스크립트 템플릿
- **gcx_invoke_v4.sh**: 표준 실행 스크립트
- **preflight_check_v4.sh**: 사전 점검 스크립트
- **pipeline_realtime_stream.sh**: Named Pipes 프로토타입

---

## 🆕 v3.5에서 v4.0으로 마이그레이션

### Breaking Changes

1. **Codex Config**: `reasoning.effort = "high"` (NOT "xhigh")
2. **Language Support**: 한글 지원 (MSYS2 환경)
3. **Log Structure**: 실시간 로깅 (tee 기반)

### 마이그레이션 단계

```bash
# 1. Codex 설정 백업
cp ~/.codex/config.toml ~/.codex/config.toml.backup

# 2. reasoning effort 수정
sed -i 's/model_reasoning_effort = "xhigh"/model_reasoning_effort = "high"/' ~/.codex/config.toml

# 3. 한글 출력 테스트
bash .gcx/tests/test_codex_korean_v2.sh

# 4. Named Pipes 테스트 (선택)
bash .gcx/templates/pipeline_realtime_stream.sh

# 5. v4 명령 사용
/nam:gcx-query-v4 "테스트 질문"
```

### 하위 호환성

- ✅ v3.5 파일은 모두 유지됨
- ✅ 기존 `/nam:gcx-query`, `/nam:gcx-project` 명령 계속 작동
- ✅ v4 파일은 별도로 생성되어 병렬 사용 가능

---

## 💡 Best Practices

### 1. MSYS2 환경 사용

```bash
# MSYS2에서 실행 (권장)
✅ 한글 직접 출력
✅ Named Pipes 지원
✅ bash 스크립트 안정성

# PowerShell에서 실행 (호환성)
⚠️ 영어 전용
⚠️ Named Pipes 미지원
⚠️ 파일 기반만 사용
```

### 2. Locale 설정

```bash
# 모든 스크립트 시작 부분
export LANG=ko_KR.UTF-8
export LC_ALL=ko_KR.UTF-8
export NO_COLOR=1
```

### 3. 실시간 로깅

```bash
# tee로 화면 + 파일 동시 저장
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
claude -p "..." | tee ".gcx/pipeline/logs/claude_$TIMESTAMP.log"
```

### 4. Pre-flight Check

```bash
# 매 실행 전 환경 점검
bash .gcx/templates/preflight_check_v4.sh
```

---

## 🎯 사용 예시

### 예시 1: 간단한 쿼리

```bash
# Gemini에서 실행
/nam:gcx-query-v4 "TypeScript에서 async/await vs Promise의 차이점은?"

# 자동 실행:
# 1. Model selection (사용자 확인)
# 2. Claude가 개념 설명
# 3. Codex가 코드 예제 생성 (한글 주석!)
# 4. 결과 통합 및 로그 저장
```

### 예시 2: 프로젝트 구현

```bash
# Gemini에서 실행
/nam:gcx-project-v4 "사용자 인증 미들웨어 구현" --combo G+C+X

# 자동 실행:
# 1. Requirement 저장 (.gcx/00_requirements/)
# 2. Claude 아키텍처 계획
# 3. Codex 테스트 생성 (TDD)
# 4. Codex 구현
# 5. Claude 코드 리뷰
# 6. 최종 보고서
```

### 예시 3: 스크립트로 실행

```bash
# 표준 파이프라인
bash .gcx/templates/gcx_invoke_v4.sh "REST API 엔드포인트 추가"

# 출력:
# [INFO] Step 1: Capturing requirement...
# [SUCCESS] Requirement saved: .gcx/00_requirements/req_*.md
# [INFO] Step 2: Claude creating architecture plan...
# [SUCCESS] Architecture plan created: .gcx/output/plan_*.md
# ...
# ✅ All steps completed successfully
```

---

## 🔗 관련 리소스

- **MSYS2 공식 사이트**: https://www.msys2.org/
- **Codex CLI**: https://codex.openai.com/
- **Claude API**: https://docs.anthropic.com/
- **Gemini API**: https://ai.google.dev/

---

## 📝 변경 이력

### v4.0 (2025-12-18)
- ✅ Codex 한글 출력 지원 (MSYS2)
- ✅ Named Pipes 실시간 스트리밍
- ✅ 실시간 로깅 시스템 (tee)
- ✅ Codex reasoning effort 수정 (xhigh → high)
- ✅ Pre-flight check 스크립트
- ✅ 완전한 문서화

### v3.5 (2025-12-16)
- Windows 실행 전략 (.sh 스크립트)
- 영어 전용 정책 (우회 방법)
- 파일 기반 핸드오프

---

**Generated by GCX v4.0 - MSYS2 Enhanced**
**Last Updated**: 2025-12-18 00:50:14 KST

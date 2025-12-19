# GCX v4.0 템플릿 스크립트 빠른 참조

## 📋 언제 어떤 스크립트를 사용할까?

| 상황 | 스크립트 | 실행 시점 | 소요 시간 |
|-----|---------|----------|----------|
| 🔧 **처음 설치/업그레이드** | `gcx_install_v4.sh` | v3.5 → v4.0 마이그레이션 | ~1분 |
| ✅ **매일 작업 시작** | `gcx_status.sh` | 하루 작업 시작 시 | ~5초 |
| ⚡ **빠른 환경 확인** | `gcx_quick_test.sh` | 문제 의심될 때 | ~30초 |
| 🔍 **상세 문제 진단** | `preflight_check_v4.sh` | 에러 발생 시 | ~2분 |
| 🧪 **간단한 코드 작성** | `gcx_test_simple.sh` | 함수/클래스 1-2개 | ~1-2분 |
| 🚀 **복잡한 프로젝트** | `gcx_test_pipeline.sh` | 모듈/기능 전체 | ~3-5분 |
| 📊 **로그 분석** | `gcx_analyze.sh` | 주간/월간 리뷰 | ~10초 |
| 🔁 **배치 작업** | `gcx_batch.sh` | 여러 작업 자동화 | 작업당 1-2분 |
| 🧹 **디스크 정리** | `gcx_cleanup.sh --logs` | 디스크 부족 시 | ~5초 |

---

## 🔄 일반적인 워크플로우

### 매일 아침 (5초)
```bash
bash .gcx/templates/gcx_status.sh
```

### 간단한 코드 작성 (1-2분)
```bash
bash .gcx/templates/gcx_test_simple.sh "두 숫자를 더하는 함수"
```

### 복잡한 프로젝트 (3-5분)
```bash
bash .gcx/templates/gcx_test_pipeline.sh "Django REST API CRUD"
```

### 주간 정리 (매주 금요일)
```bash
python3 .gcx/templates/gcx_log_analyzer.py
bash .gcx/templates/gcx_cleanup.sh --logs
```

---

## 🎯 상황별 가이드

### 🆕 처음 시작할 때
1. `gcx_install_v4.sh` - 환경 설정
2. `gcx_quick_test.sh` - 테스트
3. `gcx_status.sh` - 상태 확인

### 🐛 문제가 생겼을 때
1. `gcx_status.sh` - 현재 상태 확인
2. `preflight_check_v4.sh` - 상세 진단
3. `gcx_analyze.sh --errors-only` - 에러 로그 검색

### 💻 코드를 작성할 때
**간단한 작업** (함수 1-2개):
```bash
gcx_test_simple.sh "계산기 함수"
```

**복잡한 작업** (모듈/기능):
```bash
gcx_test_pipeline.sh "사용자 인증 시스템"
```

### 📦 여러 작업을 한번에
1. `example_tasks.txt` 파일 작성
2. `gcx_batch.sh --tasks-file example_tasks.txt`

### 🧹 정리가 필요할 때
```bash
# 로그만 정리
gcx_cleanup.sh --logs

# 전체 정리 (주의!)
gcx_cleanup.sh --all
```

---

## 📈 주기별 권장 사항

| 주기 | 작업 | 스크립트 |
|-----|------|---------|
| **매일** | 상태 확인 | `gcx_status.sh` |
| **매주** | 로그 분석 + 정리 | `gcx_analyze.sh` + `gcx_cleanup.sh --logs` |
| **매월** | 전체 진단 | `preflight_check_v4.sh` |
| **분기별** | 대청소 | `gcx_cleanup.sh --all` |

---

## 🚨 에러별 대응

| 에러 메시지 | 원인 | 해결 스크립트 |
|-----------|------|-------------|
| "MSYS2 not detected" | MSYS2 환경 아님 | UCRT64 터미널로 전환 |
| "reasoning=xhigh" | Codex config 오류 | `gcx_install_v4.sh` (자동 수정) |
| "Korean output failed" | 로케일 미설정 | `gcx_quick_test.sh` (진단) |
| "Codex CLI not found" | Codex 미설치 | Codex CLI 설치 필요 |

---

## 📚 더 자세한 정보

| 문서 | 내용 |
|-----|------|
| `USAGE_GUIDE.md` | 전체 사용 가이드 (50KB) |
| `UCRT64_GUIDE.md` | UCRT64 전환 가이드 |
| `C:/Users/Nam/.gemini/GEMINI_v4.md` | GCX v4.0 프로토콜 |

---

## 🔑 핵심 원칙

1. **매일 시작**: `gcx_status.sh`
2. **간단한 작업**: `gcx_test_simple.sh`
3. **복잡한 작업**: `gcx_test_pipeline.sh`
4. **문제 발생**: `preflight_check_v4.sh`
5. **주기적 정리**: `gcx_cleanup.sh --logs`

---

## 💡 팁

- UCRT64 터미널 사용 권장 (MINGW64도 가능)
- 로케일 설정 필수: `LANG=ko_KR.UTF-8`
- Codex reasoning: `high` (xhigh 아님!)
- 로그는 정기적으로 정리 (`--logs`)
- Requirements는 신중히 정리 (이력 보존)

---

**빠른 시작**:
```bash
cd /c/Users/Nam/Documents/Cursor/Workspace/origin/learning-code
bash .gcx/templates/gcx_status.sh
bash .gcx/templates/gcx_test_simple.sh "Hello, GCX v4.0!"
```

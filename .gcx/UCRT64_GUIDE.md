# UCRT64 환경 전환 가이드

## 왜 UCRT64인가?

| 항목 | MINGW64 | UCRT64 | 권장 |
|------|---------|--------|------|
| **C Runtime** | msvcrt.dll (구형) | ucrt (Windows 10+ 표준) | ✅ UCRT64 |
| **유니코드 지원** | 양호 | 우수 | ✅ UCRT64 |
| **최신 도구 호환성** | 보통 | 우수 | ✅ UCRT64 |
| **표준 준수** | 양호 | 우수 | ✅ UCRT64 |
| **Python/Node.js** | 지원 | 최적화됨 | ✅ UCRT64 |

**결론**: Windows 10 이상 사용자는 **UCRT64 권장**

---

## UCRT64로 전환하는 방법

### 1. MSYS2 UCRT64 터미널 실행

**방법 1: Windows 시작 메뉴**
```
Windows 시작 메뉴 → "MSYS2 UCRT64" 검색 → 실행
```

**방법 2: 직접 실행**
```cmd
C:\msys64\ucrt64.exe
```

### 2. 프로젝트 디렉토리로 이동

```bash
cd /c/Users/Nam/Documents/Cursor/Workspace/origin/learning-code
```

### 3. 환경 확인

```bash
# MSYSTEM 확인
echo $MSYSTEM
# 출력: UCRT64 (정상)

# 로케일 확인
echo $LANG
# 출력: ko_KR.UTF-8 (정상)
```

### 4. GCX v4.0 테스트

```bash
# 빠른 테스트
bash .gcx/templates/gcx_quick_test.sh

# 상세 테스트
bash .gcx/templates/preflight_check_v4.sh

# 상태 확인
bash .gcx/templates/gcx_status.sh
```

---

## MINGW64 vs UCRT64 비교

### 한글 출력 테스트 결과

**MINGW64**:
```bash
$ codex exec -m "gpt-5.1-codex" "한글로 답변해주세요"
✅ 작동 (한글 출력 가능)
```

**UCRT64**:
```bash
$ codex exec -m "gpt-5.1-codex" "한글로 답변해주세요"
✅ 작동 (더 안정적인 유니코드 처리)
```

### Python 패키지 설치 속도

**MINGW64**:
```bash
pip install numpy
# 약간 느림, 가끔 호환성 이슈
```

**UCRT64**:
```bash
pip install numpy
# 빠름, UCRT 최적화 바이너리 사용
```

---

## 터미널 자동 전환 설정

### Windows Terminal에서 UCRT64를 기본으로 설정

**settings.json**:
```json
{
  "profiles": {
    "list": [
      {
        "name": "MSYS2 UCRT64",
        "commandline": "C:\\msys64\\msys2_shell.cmd -defterm -here -no-start -ucrt64",
        "icon": "C:\\msys64\\ucrt64.ico",
        "startingDirectory": "%USERPROFILE%"
      }
    ]
  },
  "defaultProfile": "{guid-of-ucrt64-profile}"
}
```

### VS Code 통합 터미널에서 UCRT64 사용

**settings.json**:
```json
{
  "terminal.integrated.profiles.windows": {
    "MSYS2 UCRT64": {
      "path": "C:\\msys64\\usr\\bin\\bash.exe",
      "args": ["--login", "-i"],
      "env": {
        "MSYSTEM": "UCRT64",
        "CHERE_INVOKING": "1"
      }
    }
  },
  "terminal.integrated.defaultProfile.windows": "MSYS2 UCRT64"
}
```

---

## GCX v4.0 실행 예시 (UCRT64)

### Gemini → Claude → Codex 전체 파이프라인

```bash
# UCRT64 터미널에서 실행
export LANG=ko_KR.UTF-8
export LC_ALL=ko_KR.UTF-8

# 간단한 쿼리
bash .gcx/templates/gcx_invoke_v4.sh "Python으로 피보나치 수열 생성 함수 작성"

# 로그 확인
ls -lh .gcx/pipeline/logs/
```

### 실시간 Named Pipes 테스트

```bash
# Named Pipes 파이프라인 실행
bash .gcx/templates/pipeline_realtime_stream.sh "간단한 계산기 함수 작성"
```

---

## 문제 해결

### Q1: UCRT64 터미널에서 한글이 깨져요

**A**: 로케일 설정 확인
```bash
# 현재 설정 확인
echo $LANG
echo $LC_ALL

# 설정 추가
echo "export LANG=ko_KR.UTF-8" >> ~/.bashrc
echo "export LC_ALL=ko_KR.UTF-8" >> ~/.bashrc
source ~/.bashrc
```

### Q2: Codex가 한글로 답변하지 않아요

**A**: Codex config 확인
```bash
# reasoning.effort 확인
grep "model_reasoning_effort" ~/.codex/config.toml

# "xhigh"면 수정 (gpt-5.1-codex는 "high"까지만 지원)
sed -i 's/model_reasoning_effort = "xhigh"/model_reasoning_effort = "high"/' ~/.codex/config.toml
```

### Q3: UCRT64와 MINGW64를 동시에 사용할 수 있나요?

**A**: 예, 가능합니다
```bash
# 현재 세션 확인
echo $MSYSTEM

# 다른 터미널에서 다른 환경 실행
# MINGW64 터미널: C:\msys64\mingw64.exe
# UCRT64 터미널: C:\msys64\ucrt64.exe
```

### Q4: Git Bash에서는 UCRT64를 사용할 수 없나요?

**A**: Git Bash는 MINGW64입니다
```bash
# Git Bash = MINGW64 (고정)
# UCRT64 사용하려면 MSYS2 터미널 사용 필요
```

---

## 추가 리소스

- **MSYS2 공식 문서**: https://www.msys2.org/docs/environments/
- **UCRT vs MSVCRT**: https://www.msys2.org/wiki/Porting/#runtime-choice
- **GCX v4.0 문서**: `C:/Users/Nam/.gemini/GEMINI_v4.md`

---

## 요약

✅ **권장 사항**:
1. Windows 10 이상 사용자는 UCRT64 사용
2. MSYS2 UCRT64 터미널에서 GCX v4.0 실행
3. 로케일 설정: `LANG=ko_KR.UTF-8`
4. Codex reasoning: `high` (xhigh 아님!)

⚠️ **참고 사항**:
- MINGW64도 정상 작동하지만 UCRT64 권장
- Git Bash = MINGW64 (변경 불가)
- UCRT64 전환은 선택사항이지만 강력 권장

🚀 **시작하기**:
```bash
# 1. MSYS2 UCRT64 터미널 실행
# 2. 프로젝트 디렉토리로 이동
cd /c/Users/Nam/Documents/Cursor/Workspace/origin/learning-code

# 3. 테스트 실행
bash .gcx/templates/gcx_quick_test.sh

# 4. GCX 사용
bash .gcx/templates/gcx_invoke_v4.sh "Your task here"
```

# VS Code에서 MSYS2 터미널 사용하기

> VS Code의 기본 터미널을 MSYS2로 변경하여 zsh + Powerlevel10k 사용하기

## 목차
1. [설정 방법 선택](#설정-방법-선택)
2. [방법 1: JSON 직접 편집 (빠름)](#방법-1-json-직접-편집-빠름)
3. [방법 2: GUI로 설정 (쉬움)](#방법-2-gui로-설정-쉬움)
4. [설정 확인](#설정-확인)
5. [트러블슈팅](#트러블슈팅)
6. [추가 팁](#추가-팁)

---

## 설정 방법 선택

### 🚀 방법 1: JSON 직접 편집
**시간**: 2분
**난이도**: ⭐⭐☆☆☆
**추천 대상**: 빠르게 설정하고 싶은 사용자

### 🖱️ 방법 2: GUI로 설정
**시간**: 5분
**난이도**: ⭐☆☆☆☆
**추천 대상**: JSON 편집이 익숙하지 않은 사용자

---

## 방법 1: JSON 직접 편집 (빠름)

### 1단계: VS Code 설정 파일 열기

**방법 A: 단축키 사용**
```
Ctrl + Shift + P
→ "Preferences: Open User Settings (JSON)" 입력
→ Enter
```

**방법 B: 메뉴 사용**
```
파일 → 기본 설정 → 설정
→ 오른쪽 상단 "설정 열기(JSON)" 아이콘 클릭
```

### 2단계: 설정 추가

`settings.json` 파일에 다음 내용을 추가하세요:

```json
{
  // 기존 설정들...

  // MSYS2를 기본 터미널로 설정
  "terminal.integrated.defaultProfile.windows": "MSYS2 UCRT64",

  // MSYS2 프로필 정의
  "terminal.integrated.profiles.windows": {
    "MSYS2 UCRT64": {
      "path": "C:\\msys64\\usr\\bin\\bash.exe",
      "args": ["--login", "-i"],
      "env": {
        "MSYSTEM": "UCRT64",
        "CHERE_INVOKING": "1",
        "MSYS2_PATH_TYPE": "inherit"
      },
      "icon": "terminal-bash",
      "color": "terminal.ansiBlue"
    }
  },

  // Nerd Font 설정 (선택사항)
  "terminal.integrated.fontFamily": "MesloLGS NF",
  "terminal.integrated.fontSize": 13
}
```

### 3단계: 저장 및 새 터미널 열기

1. `Ctrl + S` (저장)
2. `` Ctrl + ` `` (터미널 열기)
3. zsh + Powerlevel10k가 자동으로 실행됩니다! 🎉

---

## 방법 2: GUI로 설정 (쉬움)

### 1단계: VS Code 설정 열기

```
Ctrl + ,
```

### 2단계: 터미널 프로필 검색

검색창에 입력:
```
terminal profiles windows
```

### 3단계: "Edit in settings.json" 클릭

"Terminal > Integrated > Profiles: Windows" 항목 찾기
→ **"Edit in settings.json"** 클릭

### 4단계: MSYS2 프로필 추가

`terminal.integrated.profiles.windows` 섹션에 추가:

```json
"terminal.integrated.profiles.windows": {
  "MSYS2 UCRT64": {
    "path": "C:\\msys64\\usr\\bin\\bash.exe",
    "args": ["--login", "-i"],
    "env": {
      "MSYSTEM": "UCRT64",
      "CHERE_INVOKING": "1",
      "MSYS2_PATH_TYPE": "inherit"
    },
    "icon": "terminal-bash"
  }
}
```

### 5단계: 기본 프로필 변경

검색창에 입력:
```
terminal default profile windows
```

"Terminal > Integrated > Default Profile: Windows" 항목 찾기
→ 드롭다운에서 **"MSYS2 UCRT64"** 선택

### 6단계: 새 터미널 열기

`` Ctrl + ` `` → zsh 자동 실행! 🎉

---

## 설정 확인

### 1. 터미널 프로필 확인

터미널 탭 옆 `+` 버튼의 `v` 클릭
→ "MSYS2 UCRT64" 옵션이 보이면 성공!

### 2. 기본 셸 확인

터미널에서 실행:
```bash
echo $SHELL
# /usr/bin/zsh 또는 /bin/zsh

echo $MSYSTEM
# UCRT64
```

### 3. Powerlevel10k 확인

터미널에 Powerlevel10k 테마가 표시되면 완벽! ✅

---

## 트러블슈팅

### 문제 1: 터미널이 bash로 시작됨 (zsh 아님)

**원인**: `.bashrc`에 `exec zsh`가 없거나 작동하지 않음

**해결**:

```bash
# MSYS2에서 확인
cat ~/.bashrc | grep "exec zsh"

# 없으면 추가
echo 'if [ -t 1 ] && command -v zsh &> /dev/null; then exec zsh; fi' >> ~/.bashrc
```

VS Code 터미널 재시작: `Ctrl + Shift + P` → "Terminal: Kill All Terminals"

### 문제 2: "bash.exe not found" 오류

**원인**: MSYS2 경로가 다름

**해결**:

1. MSYS2 설치 경로 확인:
   ```bash
   # PowerShell에서 실행
   Get-ChildItem "C:\msys64\usr\bin\bash.exe"
   ```

2. 경로가 다르면 `settings.json` 수정:
   ```json
   "path": "D:\\msys64\\usr\\bin\\bash.exe"  // 실제 경로로 변경
   ```

### 문제 3: Powerlevel10k 아이콘이 깨져보임

**원인**: Nerd Font 미설치 또는 VS Code 폰트 미설정

**해결**:

1. **Nerd Font 설치 확인**:
   - https://github.com/romkatv/powerlevel10k#manual-font-installation
   - MesloLGS NF 다운로드 및 설치

2. **VS Code 폰트 설정**:
   ```json
   "terminal.integrated.fontFamily": "MesloLGS NF"
   ```

3. VS Code 재시작

### 문제 4: 한글 깨짐

**해결**:

```json
"terminal.integrated.env.windows": {
  "LANG": "ko_KR.UTF-8",
  "LC_ALL": "ko_KR.UTF-8"
}
```

### 문제 5: 현재 디렉토리가 홈 디렉토리로 시작됨

**원인**: `CHERE_INVOKING` 환경변수 미설정

**해결**: `settings.json`에 다음이 있는지 확인
```json
"env": {
  "CHERE_INVOKING": "1"  // 이 줄이 있어야 함!
}
```

### 문제 6: Windows 경로가 이상하게 보임

**증상**: `/c/Users/Nam/...` 대신 `/home/Nam/...`으로 시작

**해결**:

```json
"env": {
  "MSYS2_PATH_TYPE": "inherit"  // 이 줄 추가
}
```

### 문제 7: Git 명령어가 느림

**원인**: Windows Git과 MSYS2 Git 충돌

**해결**:

```json
// MSYS2 Git 사용
"git.path": "C:\\msys64\\usr\\bin\\git.exe"
```

---

## 추가 팁

### Tip 1: 여러 터미널 프로필 사용

3가지 MSYS2 환경을 모두 추가:

```json
"terminal.integrated.profiles.windows": {
  "MSYS2 UCRT64": { /* 위 설정 */ },
  "MSYS2 MINGW64": {
    "path": "C:\\msys64\\usr\\bin\\bash.exe",
    "args": ["--login", "-i"],
    "env": {
      "MSYSTEM": "MINGW64",
      "CHERE_INVOKING": "1",
      "MSYS2_PATH_TYPE": "inherit"
    },
    "icon": "terminal-bash",
    "color": "terminal.ansiGreen"
  },
  "PowerShell": {
    "source": "PowerShell",
    "icon": "terminal-powershell"
  }
}
```

터미널 탭에서 `+` 옆 `v` 버튼으로 선택 가능!

### Tip 2: 터미널 분할 단축키

| 단축키 | 기능 |
|--------|------|
| `Ctrl + Shift + 5` | 터미널 분할 (수직) |
| `Alt + 방향키` | 터미널 패널 간 이동 |
| `Ctrl + PageUp/PageDown` | 터미널 탭 전환 |
| `` Ctrl + Shift + ` `` | 새 터미널 |

### Tip 3: 작업 공간별 터미널 설정

**프로젝트별로 다른 터미널 사용하기**:

1. 프로젝트 폴더의 `.vscode/settings.json` 생성
2. 작업 공간 전용 설정 추가:

```json
{
  "terminal.integrated.defaultProfile.windows": "PowerShell"
}
```

### Tip 4: 터미널 시작 명령어 자동 실행

특정 명령어를 자동 실행:

```json
"terminal.integrated.profiles.windows": {
  "MSYS2 Dev": {
    "path": "C:\\msys64\\usr\\bin\\bash.exe",
    "args": [
      "--login",
      "-i",
      "-c",
      "cd /c/projects/myapp && zsh"
    ],
    "env": {
      "MSYSTEM": "UCRT64"
    }
  }
}
```

### Tip 5: 터미널 탭 색상 구분

```json
"terminal.integrated.profiles.windows": {
  "MSYS2 UCRT64": {
    // ...
    "color": "terminal.ansiBlue"  // 파란색
  },
  "PowerShell": {
    // ...
    "color": "terminal.ansiCyan"  // 청록색
  }
}
```

### Tip 6: 터미널 스크롤백 증가

```json
"terminal.integrated.scrollback": 10000  // 기본값: 1000
```

### Tip 7: 터미널에서 선택 시 자동 복사

```json
"terminal.integrated.copyOnSelection": true
```

### Tip 8: 우클릭 메뉴 설정

```json
"terminal.integrated.rightClickBehavior": "default"  // 또는 "paste", "selectWord"
```

---

## 완전한 설정 예시

`vscode_msys2_settings.json` 파일에서 전체 설정을 확인하세요!

**빠른 적용 방법**:

1. `vscode_msys2_settings.json` 파일 내용 복사
2. VS Code에서 `Ctrl + Shift + P`
3. "Preferences: Open User Settings (JSON)"
4. 내용 붙여넣기 (기존 설정과 병합)
5. 저장

---

## VS Code 확장 추가 추천

MSYS2 터미널과 함께 사용하면 좋은 확장:

### 1. **shellcheck** (Shell 스크립트 검사)
```
Ctrl + Shift + X → "shellcheck" 검색 → 설치
```

### 2. **Bash IDE** (자동완성)
```
Ctrl + Shift + X → "Bash IDE" 검색 → 설치
```

### 3. **GitLens** (Git 통합)
```
Ctrl + Shift + X → "GitLens" 검색 → 설치
```

### 4. **Remote - SSH** (원격 개발)
MSYS2의 SSH를 사용한 원격 개발
```
Ctrl + Shift + X → "Remote - SSH" 검색 → 설치
```

---

## 비교: VS Code 터미널 옵션

| 터미널 | 장점 | 단점 |
|--------|------|------|
| **MSYS2** | zsh, Powerlevel10k, 리눅스 명령어 | 초기 설정 필요 |
| **PowerShell** | Windows 네이티브, 빠름 | bash 스크립트 불가 |
| **Git Bash** | 간단, Git 통합 | 제한적 기능 |
| **WSL** | 완벽한 리눅스 | 무거움, Docker 필요 시 유리 |
| **Command Prompt** | 기본 내장 | 기능 제한적 |

---

## FAQ

### Q1. VS Code와 Windows Terminal 설정을 동시에 사용할 수 있나요?

네! 각각 독립적으로 설정됩니다.
- **Windows Terminal**: 시스템 전역 터미널
- **VS Code Terminal**: VS Code 내장 터미널

### Q2. Cursor IDE에서도 사용 가능한가요?

네! Cursor는 VS Code 기반이므로 동일한 설정이 작동합니다.

### Q3. 터미널 테마를 변경하려면?

VS Code 테마가 터미널에도 적용됩니다. Powerlevel10k 스타일은 `p10k configure`로 변경하세요.

### Q4. 기존 PowerShell 터미널도 유지하고 싶어요

`settings.json`에 여러 프로필을 추가하면 됩니다. 터미널 탭에서 선택 가능합니다.

### Q5. 프로젝트 열 때마다 자동으로 특정 명령어 실행하려면?

**방법 1**: `.vscode/tasks.json` 사용
**방법 2**: VS Code 확장 "Run on Save" 사용
**방법 3**: 터미널 프로필의 `args`에 `-c` 옵션 사용

---

## 결론

VS Code에서 MSYS2 터미널 사용하면:
- ✅ zsh + Powerlevel10k 완벽 지원
- ✅ 리눅스 명령어 사용 가능
- ✅ Git 통합 완벽
- ✅ 프로젝트 디렉토리에서 바로 시작
- ✅ Nerd Font 아이콘 표시

**설정 시간**: 2-5분
**효과**: 생산성 2배 증가! 🚀

---

**관련 파일**:
- `vscode_msys2_settings.json` - 전체 설정 파일
- `msys2_setup_guide.md` - MSYS2 설치 가이드
- `windows_terminal_msys2.json` - Windows Terminal 설정

**작성일**: 2025-12-17
**버전**: 1.0

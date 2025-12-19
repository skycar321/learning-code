# MSYS2 + zsh + Powerlevel10k 완전 설치 가이드

> 🎯 **이 디렉토리만 있으면 Windows에서 리눅스 스타일 터미널을 완벽하게 구축할 수 있습니다!**

## 📋 목차

- [빠른 시작 (Quick Start)](#빠른-시작-quick-start)
- [디렉토리 구조](#디렉토리-구조)
- [상세 설치 가이드](#상세-설치-가이드)
- [설정 파일 적용](#설정-파일-적용)
- [문제 해결](#문제-해결)
- [추가 옵션](#추가-옵션)

---

## 🚀 빠른 시작 (Quick Start)

### 필수 조건
- Windows 10 이상
- 인터넷 연결
- 관리자 권한

### 3단계 설치

#### 1단계: MSYS2 설치
```bash
# MSYS2 다운로드 및 설치
# https://www.msys2.org/
# C:\msys64에 설치 (기본값)

# 설치 후 MSYS2 UCRT64 터미널 실행
```

#### 2단계: 자동 설치 스크립트 실행
```bash
# 이 디렉토리로 이동
cd /c/Users/$USER/Documents/Cursor/Workspace/origin/learning-code/msys2-setup

# 자동 설치 스크립트 실행 (모든 것을 자동으로 설치)
bash scripts/1_msys2_auto_install.sh

# zsh 시작
zsh
```

#### 3단계: Powerlevel10k 설정
```bash
# p10k 설정 마법사가 자동으로 실행됩니다
# 질문에 답하면서 테마를 커스터마이징하세요

# 또는 나중에 다시 실행:
p10k configure
```

**🎉 완료! 이제 zsh + Powerlevel10k를 사용할 수 있습니다.**

---

## 📁 디렉토리 구조

```
msys2-setup/
├── README.md                    ← 지금 보고 있는 파일 (시작은 여기서!)
├── scripts/                     ← 설치 및 관리 스크립트
│   ├── 1_msys2_auto_install.sh        → 메인 자동 설치 스크립트 ⭐
│   ├── 2_install_ohmyzsh.sh           → oh-my-zsh 단독 설치 (선택)
│   ├── install_nodejs_npm.sh          → Node.js & npm 자동 설치 🟢
│   ├── fix_windows_terminal_path.sh   → Windows Terminal PATH 자동 수정 🔧
│   ├── check_node_path.sh             → Node.js PATH 진단 도구 🔍
│   ├── diagnose_terminal.sh           → 설치 상태 진단 도구 🔍
│   ├── fix_default_shell.sh           → 기본 셸을 zsh로 변경 🔧
│   ├── fix_zshrc_error.sh             → .zshrc 오류 수정
│   └── fix_zsh_setup.sh               → zsh 설정 전체 재설정
│   └── fix_claude_gemini_wrappers.sh   → Claude/Gemini CLI wrapper 자동 수정 🤖
├── configs/                     ← 설정 파일
│   ├── windows_terminal_msys2.json  → Windows Terminal 설정
│   ├── vscode_settings_final.json   → VS Code 설정
│   └── zshrc_template.sh            → .zshrc 템플릿
└── guides/                      ← 상세 가이드
    ├── msys2_setup_guide.md             → 메인 가이드 (상세 버전)
    ├── nodejs_npm_setup_guide.md        → Node.js & npm 설치 가이드 🟢
    ├── windows_terminal_path_fix.md     → Windows Terminal PATH 수정 가이드 🔧
    ├── vscode_msys2_guide.md            → VS Code 통합 가이드
    ├── powershell_ohmyposh_guide.md     → PowerShell 대안
    └── cygwin_setup_guide.md            → Cygwin 대안
├── claude_gemini_cli_fix.md         → Claude/Gemini CLI 문제 해결 🤖

```

---

## 📖 상세 설치 가이드

### 방법 1: 자동 설치 (권장) ⭐

가장 빠르고 쉬운 방법입니다. 모든 것을 자동으로 설치합니다.

```bash
# MSYS2 UCRT64 터미널에서 실행
cd /c/Users/$USER/Documents/Cursor/Workspace/origin/learning-code/msys2-setup
bash scripts/1_msys2_auto_install.sh
```

**자동으로 설치되는 것들:**
- ✅ 필수 패키지 13개 (zsh, git, vim, curl, wget, nano, openssh, rsync, tmux, htop, tree, unzip, zip)
- ✅ oh-my-zsh 프레임워크
- ✅ Powerlevel10k 테마
- ✅ zsh 플러그인 4개 (zsh-autosuggestions, zsh-syntax-highlighting, colored-man-pages, command-not-found)
- ✅ Git aliases 20+ 개
- ✅ 유틸리티 함수 15+ 개
- ✅ 완전한 .zshrc 설정 (200+ 줄)

**설치 시간:** 약 5~10분 (인터넷 속도에 따라 다름)

### 방법 2: 수동 설치

자세한 내용은 `guides/msys2_setup_guide.md`를 참조하세요.

```bash
# 1. 기본 패키지 업데이트
pacman -Syu

# 2. zsh 설치
pacman -S zsh git curl wget

# 3. oh-my-zsh 설치
bash scripts/2_install_ohmyzsh.sh

# 4. Powerlevel10k 설치
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# 5. 플러그인 설치
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# 6. .zshrc 설정
cp configs/zshrc_template.sh ~/.zshrc

# 7. zsh 시작
zsh
```

---

## ⚙️ 설정 파일 적용

### Windows Terminal 설정

Windows Terminal에서 MSYS2를 사용하려면:

```bash
# 1. Windows Terminal 설정 열기
#    Ctrl+, 또는 설정 > JSON 파일 열기

# 2. configs/windows_terminal_msys2.json 내용 복사

# 3. "profiles" > "list" 배열에 추가
```

**제공되는 프로필:**
- MSYS2 UCRT64 (기본, 권장)
- MSYS2 MINGW64
- MSYS2 MSYS

### VS Code 통합

VS Code에서 MSYS2를 기본 터미널로 사용하려면:

```bash
# 1. VS Code 설정 열기
#    Ctrl+, > 설정 검색: "settings.json"

# 2. configs/vscode_settings_final.json 내용 복사

# 3. 기존 settings.json과 병합
```

**설정 효과:**
- ✅ MSYS2 UCRT64가 기본 터미널
- ✅ 터미널 탭에 "MSYS2 UCRT64" 이름 표시 (bash 아님)
- ✅ Nerd Font 적용
- ✅ Git 경로 자동 설정

**상세 가이드:** `guides/vscode_msys2_guide.md` 참조

---

## 🔧 문제 해결

### 🔍 진단 도구: 설치 상태 확인

설치가 제대로 되었는지 확인하려면:

```bash
bash scripts/diagnose_terminal.sh
```

**이 도구가 확인하는 항목:**
- ✅ 기본 로그인 셸 (`echo $SHELL`)
- ✅ zsh, oh-my-zsh, Powerlevel10k 설치 여부
- ✅ .bashrc 자동 zsh 실행 설정
- ✅ .zshrc 설정 파일
- ✅ VSCode 설정
- ✅ Nerd Font 설치

**출력 예시:**
```
✓ 모든 검사 통과!
축하합니다! MSYS2 + zsh + Powerlevel10k 설정이 완벽합니다.
```

### 🔧 수정 도구: 기본 셸을 zsh로 변경

**증상:**
- VSCode 터미널 탭에 "bash"로 표시됨 (MSYS2 UCRT64 아님)
- `echo $SHELL` 실행 시 `/bin/bash` 또는 `/usr/bin/bash` 출력

**해결:**
```bash
bash scripts/fix_default_shell.sh
```

**이 스크립트가 하는 일:**
1. `/etc/passwd`에서 사용자의 기본 셸을 zsh로 변경
2. `.bashrc`에 자동 zsh 실행 코드 추가
3. 백업 파일 생성 (복구 가능)
4. 변경사항 검증

**실행 후:**
- 터미널 재시작
- `echo $SHELL` → `/usr/bin/zsh` 출력 확인
- VSCode 터미널 탭에 "MSYS2 UCRT64" 표시 확인

---

### 문제 1: `p10k configure` 명령어를 찾을 수 없음

**원인:** oh-my-zsh 또는 Powerlevel10k가 제대로 설치되지 않음

**해결:**
```bash
bash scripts/2_install_ohmyzsh.sh
```

### 문제 2: `.zshrc` 오류 - "defining function based on alias"

**원인:** alias와 function 이름 충돌

**해결:**
```bash
bash scripts/fix_zshrc_error.sh
```

### 문제 3: 한글이 깨져 보임

**원인:** UTF-8 인코딩 설정 누락

**해결:**
```bash
# .zshrc에 추가 (자동 설치 스크립트는 이미 포함)
export LANG=ko_KR.UTF-8
export LC_ALL=ko_KR.UTF-8
```

### 문제 4: 폰트 아이콘이 깨져 보임

**원인:** Nerd Font가 설치되지 않음

**해결:**
1. MesloLGS NF 폰트 다운로드:
   - https://github.com/romkatv/powerlevel10k#fonts
2. 4개 폰트 파일 모두 설치 (Regular, Bold, Italic, Bold Italic)
3. 터미널 설정에서 폰트를 "MesloLGS NF"로 변경

### 문제 5: zsh가 느리게 시작됨

**원인:** 플러그인이 너무 많거나 .zshrc가 비효율적

**해결:**
```bash
# 시작 시간 측정
time zsh -i -c exit

# 플러그인 비활성화 테스트
# .zshrc에서 plugins 배열 축소
plugins=(git)  # 최소한으로
```

### 문제 6: Git Bash와 충돌

**해결:** MSYS2와 Git Bash는 별도로 사용 가능. VS Code에서 드롭다운으로 선택 가능.

### 문제 7: pacman 명령어를 찾을 수 없음

**원인:** MSYS 환경이 아닌 다른 환경에서 실행

**해결:**
```bash
# MSYS2 UCRT64 터미널에서 실행해야 함
# 환경 확인:
echo $MSYSTEM
# 출력: UCRT64
```

### 문제 8: 전체 재설정이 필요한 경우

**해결:**
```bash
bash scripts/fix_zsh_setup.sh
│   └── fix_claude_gemini_wrappers.sh   → Claude/Gemini CLI wrapper 자동 수정 🤖
```

**더 많은 문제 해결:** `guides/msys2_setup_guide.md`의 "문제 해결" 섹션 참조

---

## 🎨 Powerlevel10k 설정 가이드

설치 후 `p10k configure` 명령으로 테마를 커스터마이징할 수 있습니다.

### 추천 설정

| 질문 | 추천 답변 | 이유 |
|------|----------|------|
| Character Set | (1) Unicode | 아이콘이 제대로 보이면 선택 |
| Prompt Style | (3) Rainbow | 가독성 좋음 |
| Character Set | (1) Unicode | 필수 선택 |
| Show current time? | (2) 24-hour format | 시간 표시 유용 |
| Prompt Separators | (1) Angled | 깔끔한 디자인 |
| Prompt Heads | (1) Sharp | 선명한 구분 |
| Prompt Tails | (1) Flat | 공간 절약 |
| Prompt Height | (2) Two lines | 명령어 입력 공간 확보 |
| Prompt Connection | (2) Dotted | 구분선 표시 |
| Prompt Frame | (2) Left | 왼쪽 프레임만 |
| Prompt Spacing | (2) Sparse | 여유 있는 간격 |
| Icons | (2) Many icons | 정보가 풍부 |
| Prompt Flow | (1) Concise | 간결한 흐름 |
| Transient Prompt | (y) Yes | 이전 명령 간결하게 |
| Instant Prompt | (y) Yes | 빠른 시작 |

**재설정:** 언제든지 `p10k configure` 실행

---

## 🌟 추가 옵션

### Node.js & npm 설치 🟢

JavaScript/TypeScript 개발 환경이 필요하다면:

**빠른 설치:**
```bash
# 자동 설치 스크립트 실행
bash scripts/install_nodejs_npm.sh
```

**수동 설치:**
```bash
# UCRT64 환경 (npm 자동 포함)
pacman -S mingw-w64-ucrt-x86_64-nodejs

# 설치 확인
node --version
npm --version
```

**⚠️ Windows Terminal PATH 문제 해결:**

VS Code에서는 작동하지만 Windows Terminal에서 `npm: command not found` 오류가 발생하나요?

```bash
# 빠른 해결: 자동 수정 스크립트
bash scripts/fix_windows_terminal_path.sh

# 또는 수동으로 ~/.zshrc에 추가
echo 'export PATH="/c/Program Files/nodejs:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**진단 도구:**
```bash
# Node.js PATH 상태 확인
bash scripts/check_node_path.sh
```

**상세 가이드:**
- Node.js 설치: `guides/nodejs_npm_setup_guide.md`
- Windows Terminal PATH 문제: `guides/windows_terminal_path_fix.md`

**주요 기능:**
- ✅ Node.js 및 npm 설치
- ✅ 전역 패키지 경로 자동 설정
- ✅ @openai/codex, TypeScript 등 설치 가능
- ✅ Windows Terminal PATH 자동 수정
- ✅ 권한 오류 방지

### Claude Code & Gemini CLI 수정 🤖npm으로 설치한 Claude Code나 Gemini CLI가 MSYS2에서 `MODULE_NOT_FOUND` 오류를 발생시키나요?**증상:**```bash❯ claude --dangerously-skip-permissionsError: Cannot find module 'C:msys64UsersNam...'```**원인:** npm wrapper 스크립트의 `cygpath -w` 경로 변환 오류**빠른 해결:**```bash# 자동 수정 스크립트 실행bash scripts/fix_claude_gemini_wrappers.sh```**수동 해결:**```bash# 1. 백업 생성cp /c/Users/Nam/AppData/Roaming/npm/claude /c/Users/Nam/AppData/Roaming/npm/claude.backupcp /c/Users/Nam/AppData/Roaming/npm/gemini /c/Users/Nam/AppData/Roaming/npm/gemini.backup# 2. wrapper 수정 (guides/claude_gemini_cli_fix.md 참조)# 스크립트가 자동으로 처리합니다```**검증:**```bashclaude --version# 출력: 2.0.73 (Claude Code)gemini --version# 출력: 0.21.2```**상세 가이드:**- 문제 해결: `guides/claude_gemini_cli_fix.md`- codex도 같은 방식으로 해결됨**주요 기능:**- ✅ Claude Code wrapper 자동 수정- ✅ Gemini CLI wrapper 자동 수정- ✅ 기존 파일 백업 (.backup)- ✅ 검증 및 버전 확인- ✅ npm 재설치 후 재실행 가능
### PowerShell 대안

Windows PowerShell을 선호한다면:
- `guides/powershell_ohmyposh_guide.md` 참조
- Oh My Posh + PowerShell 7 조합

### Cygwin 대안

레거시 시스템이나 특수 요구사항:
- `guides/cygwin_setup_guide.md` 참조
├── claude_gemini_cli_fix.md         → Claude/Gemini CLI 문제 해결 🤖
- X11 지원 필요 시 유용

---

## 📚 유용한 명령어

### 기본 Aliases (자동 설치 포함)

#### Git Aliases
```bash
gs       # git status
ga       # git add
gaa      # git add --all
gc       # git commit -m
gp       # git push
gpl      # git pull
gl       # git log --oneline --graph
gd       # git diff
gco      # git checkout
gb       # git branch
```

#### 패키지 관리
```bash
update       # pacman -Syu (시스템 업데이트)
install      # pacman -S (패키지 설치)
pkgsearch    # pacman -Ss (패키지 검색)
remove       # pacman -R (패키지 제거)
clean        # pacman -Sc (캐시 정리)
```

#### 디렉토리 이동
```bash
..           # cd ..
...          # cd ../..
home         # cd ~
downloads    # cd ~/Downloads
desktop      # cd ~/Desktop
proj         # cd 프로젝트 디렉토리
```

### 유용한 Functions (자동 설치 포함)

```bash
mkcd <dir>              # 디렉토리 생성 후 이동
findtext <pattern>      # 파일 내용 검색
backup <file>           # 파일 백업 (타임스탬프 포함)
psgrep <name>           # 프로세스 검색
pskill <name>           # 프로세스 종료
serve [port]            # HTTP 서버 실행 (기본: 8000)
jsonformat [file]       # JSON 포맷팅
git-clean-branches      # 병합된 브랜치 정리
filesize [files]        # 파일 크기 확인
unpack <archive>        # 압축 해제 (자동 감지)
```

---

## 🔗 참고 자료

### 공식 문서
- [MSYS2 공식 사이트](https://www.msys2.org/)
- [oh-my-zsh GitHub](https://github.com/ohmyzsh/ohmyzsh)
- [Powerlevel10k GitHub](https://github.com/romkatv/powerlevel10k)

### 폰트
- [Nerd Fonts](https://www.nerdfonts.com/)
- [MesloLGS NF (권장)](https://github.com/romkatv/powerlevel10k#fonts)

### 플러그인
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)

---

## 💡 팁

### 성능 최적화
```bash
# .zshrc 파일에서 불필요한 플러그인 제거
# 시작 시간 측정: time zsh -i -c exit
```

### 테마 변경
```bash
# 다른 oh-my-zsh 테마 사용
# .zshrc에서 ZSH_THEME 변경
ZSH_THEME="robbyrussell"  # 기본 테마
```

### 플러그인 추가
```bash
# .zshrc의 plugins 배열에 추가
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  docker  # 새 플러그인
)
```

### 업데이트
```bash
# MSYS2 패키지 업데이트
pacman -Syu

# oh-my-zsh 업데이트
omz update

# Powerlevel10k 업데이트
cd ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git pull
```

---

## 📝 라이선스 및 크레딧

이 가이드는 다음 프로젝트를 기반으로 합니다:
- MSYS2 (BSD License)
- oh-my-zsh (MIT License)
- Powerlevel10k (MIT License)

작성자: Nam
작성일: 2025-12-17
최종 수정: 2025-12-19

---

## 🆘 도움말

문제가 있거나 질문이 있으면:
1. `guides/msys2_setup_guide.md`의 문제 해결 섹션 확인
2. 각 가이드의 FAQ 섹션 확인
3. GitHub Issues 확인

**Happy Coding! 🚀**

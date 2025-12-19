# MSYS2 + zsh + Powerlevel10k 완벽 설치 가이드

> WSL 없이 Windows에서 완벽한 리눅스 터미널 환경 구축하기

## 목차
1. [MSYS2란?](#msys2란)
2. [설치 방법 선택](#설치-방법-선택)
3. [자동 설치 (추천)](#자동-설치-추천)
4. [수동 설치](#수동-설치)
5. [Windows Terminal 설정](#windows-terminal-설정)
6. [VS Code 터미널 설정](#vs-code-터미널-설정)
7. [Powerlevel10k 설정 마법사](#powerlevel10k-설정-마법사)
8. [트러블슈팅](#트러블슈팅)
9. [추가 팁](#추가-팁)

---

## MSYS2란?

**MSYS2**는 Windows에서 리눅스 환경을 제공하는 소프트웨어 배포판입니다.

### 주요 특징
- ✅ **Pacman 패키지 관리자** - Arch Linux와 동일한 패키지 관리
- ✅ **리눅스 명령어 90%+ 호환** - bash, zsh, grep, sed, awk 등
- ✅ **zsh + oh-my-zsh 완벽 지원** - Powerlevel10k 테마까지
- ✅ **Windows 네이티브 성능** - WSL보다 가벼움
- ✅ **기업 환경 사용 가능** - WSL 차단 환경에서도 OK

### 비교표

| 기능 | MSYS2 | Git Bash | WSL 2 | PowerShell |
|------|-------|----------|-------|------------|
| 리눅스 호환성 | ✅ 90%+ | ⚠️ 70% | ✅ 100% | ⚠️ 60% |
| 패키지 관리자 | ✅ Pacman | ❌ 없음 | ✅ apt/yum | ⚠️ winget |
| zsh 지원 | ✅ 네이티브 | ⚠️ 복잡 | ✅ 네이티브 | ❌ 불가 |
| bash 스크립트 | ✅ 실행 가능 | ✅ 실행 가능 | ✅ 완벽 | ❌ 불가 |
| 설치 속도 | ⚡ 빠름 | ⚡ 매우 빠름 | ⚠️ 느림 | ✅ 기본 내장 |
| 용량 | ~500MB | ~200MB | ~2GB | 기본 내장 |
| Windows 요구사항 | Windows 7+ | Windows 7+ | Windows 10 1903+ | Windows 10+ |

---

## 설치 방법 선택

### 🚀 자동 설치 (추천)
**시간**: 5-10분
**난이도**: ⭐☆☆☆☆
**추천 대상**: 빠르게 설치하고 싶은 모든 사용자

👉 [자동 설치 바로가기](#자동-설치-추천)

### 🔧 수동 설치
**시간**: 15-20분
**난이도**: ⭐⭐⭐☆☆
**추천 대상**: 각 단계를 이해하고 싶은 사용자

👉 [수동 설치 바로가기](#수동-설치)

---

## 자동 설치 (추천)

### 1단계: MSYS2 설치

1. https://www.msys2.org 에서 설치 프로그램 다운로드
2. `msys2-x86_64-<버전>.exe` 실행
3. 설치 경로: `C:\msys64` (기본값 권장)
4. 설치 완료

### 2단계: MSYS2 터미널 실행

시작 메뉴에서 **"MSYS2 UCRT64"** 실행

### 3단계: 초기 업데이트

```bash
# 첫 번째 업데이트 (터미널이 자동으로 닫힘)
pacman -Syu

# MSYS2 다시 열고 두 번째 업데이트
pacman -Su
```

### 4단계: 자동 설치 스크립트 실행

```bash
# 스크립트 다운로드
curl -fsSL https://raw.githubusercontent.com/<your-repo>/msys2_auto_install.sh -o ~/msys2_auto_install.sh

# 또는 로컬 파일이 있다면
cd /c/Users/<사용자명>/Documents/Cursor/Workspace/origin/learning-code

# 스크립트 실행
bash msys2_auto_install.sh
```

**자동으로 설치되는 항목**:
- ✅ 필수 패키지 (zsh, git, curl, vim, tmux, htop 등)
- ✅ oh-my-zsh
- ✅ Powerlevel10k 테마
- ✅ zsh-autosuggestions 플러그인
- ✅ zsh-syntax-highlighting 플러그인
- ✅ 완전한 .zshrc 설정 (100+ lines)
- ✅ .bashrc 자동 zsh 실행 설정

### 5단계: zsh 시작

```bash
exec zsh
```

**Powerlevel10k 설정 마법사**가 자동으로 시작됩니다!

👉 [설정 마법사 가이드](#powerlevel10k-설정-마법사)로 이동

---

## 수동 설치

### 1단계: MSYS2 설치

1. https://www.msys2.org 에서 설치 프로그램 다운로드
2. 설치 경로: `C:\msys64` (기본값)
3. 설치 완료 후 **"MSYS2 UCRT64"** 실행

### 2단계: 시스템 업데이트

```bash
# 첫 번째 업데이트
pacman -Syu

# 터미널이 닫히면 다시 열고
pacman -Su
```

### 3단계: 필수 패키지 설치

```bash
# 기본 도구
pacman -S --noconfirm zsh git curl wget vim nano openssh rsync

# 유틸리티
pacman -S --noconfirm tmux htop tree unzip zip
```

### 4단계: oh-my-zsh 설치

```bash
# 환경변수 설정 (자동 실행 방지)
export RUNZSH=no
export KEEP_ZSHRC=no

# oh-my-zsh 설치
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
```

**중요**: 설치 후 `$HOME/.oh-my-zsh/oh-my-zsh.sh` 파일이 있는지 확인하세요!

```bash
# 확인
ls -la ~/.oh-my-zsh/oh-my-zsh.sh
```

### 5단계: Powerlevel10k 테마 설치

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

### 6단계: zsh 플러그인 설치

```bash
# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

### 7단계: .zshrc 설정

```bash
# 기존 .zshrc 백업 (있다면)
mv ~/.zshrc ~/.zshrc.backup

# 새 .zshrc 작성
cat > ~/.zshrc << 'EOF'
# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  colored-man-pages
  command-not-found
)

# Load oh-my-zsh (CRITICAL!)
source $ZSH/oh-my-zsh.sh

# UTF-8 설정
export LANG=ko_KR.UTF-8
export LC_ALL=ko_KR.UTF-8

# Editor
export EDITOR=vim

# Aliases
alias ll='ls -alh --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'

# MSYS2 패키지 관리
alias update='pacman -Syu'
alias install='pacman -S'
alias search='pacman -Ss'

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS

# Completion
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF
```

### 8단계: .bashrc 설정 (zsh 자동 실행)

```bash
cat >> ~/.bashrc << 'EOF'

# Start zsh automatically
if [ -t 1 ] && command -v zsh &> /dev/null; then
  exec zsh
fi
EOF
```

### 9단계: zsh 시작

```bash
exec zsh
```

Powerlevel10k 설정 마법사가 시작됩니다!

---

## Windows Terminal 설정

### 방법 1: JSON 파일 직접 적용 (빠름)

1. `windows_terminal_msys2.json` 파일 내용 복사
2. Windows Terminal 실행
3. `Ctrl + ,` (설정 열기)
4. 왼쪽 하단 **"JSON 파일 열기"** 클릭
5. `profiles.list` 배열에 다음 추가:

```json
{
  "guid": "{17da3cac-b318-431e-8a3e-7fcdefe6d114}",
  "name": "MSYS2 UCRT64",
  "commandline": "C:/msys64/msys2_shell.cmd -defterm -here -no-start -ucrt64",
  "icon": "C:/msys64/ucrt64.ico",
  "startingDirectory": "%USERPROFILE%",
  "colorScheme": "One Half Dark",
  "fontFace": "MesloLGS NF",
  "fontSize": 10,
  "fontWeight": "normal",
  "padding": "8, 8, 8, 8",
  "cursorShape": "bar",
  "useAcrylic": false,
  "hidden": false
}
```

6. 저장 후 Windows Terminal 재시작

### 방법 2: GUI로 추가 (쉬움)

1. Windows Terminal 실행
2. `Ctrl + ,` (설정)
3. **"프로필 추가"** → **"새 빈 프로필"**
4. 다음 정보 입력:

| 항목 | 값 |
|------|-----|
| 이름 | MSYS2 UCRT64 |
| 명령줄 | `C:/msys64/msys2_shell.cmd -defterm -here -no-start -ucrt64` |
| 시작 디렉터리 | `%USERPROFILE%` |
| 아이콘 | `C:/msys64/ucrt64.ico` |
| 글꼴 | MesloLGS NF |
| 글꼴 크기 | 10 |
| 색 구성표 | One Half Dark |

5. 저장

### MSYS2 환경 종류

MSYS2는 3가지 환경을 제공합니다:

| 환경 | 용도 | 권장 |
|------|------|------|
| **UCRT64** | 최신 Windows 10+ 개발 | ⭐ 추천 |
| **MINGW64** | 레거시 호환성 | ⚠️ 필요 시 |
| **MSYS** | POSIX 도구만 | ❌ 비추천 |

**결론**: 일반적으로 **UCRT64** 사용을 추천합니다.

---

## VS Code 터미널 설정

VS Code에서도 MSYS2를 기본 터미널로 사용할 수 있습니다!

### 방법 1: JSON 직접 편집 (빠름, 2분)

1. **설정 파일 열기**: `Ctrl + Shift + P` → "Preferences: Open User Settings (JSON)"

2. **설정 추가**:

```json
{
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

3. **저장 및 확인**: `Ctrl + S` → `` Ctrl + ` `` (터미널 열기)

### 방법 2: GUI로 설정 (쉬움, 5분)

1. `Ctrl + ,` (설정 열기)
2. 검색: `terminal profiles windows`
3. "Edit in settings.json" 클릭
4. 위의 JSON 설정 추가
5. 검색: `terminal default profile windows`
6. 드롭다운에서 "MSYS2 UCRT64" 선택

### 추가 설정 (선택사항)

**복사 시 자동 선택**:
```json
"terminal.integrated.copyOnSelection": true
```

**스크롤백 증가**:
```json
"terminal.integrated.scrollback": 10000
```

**Git 경로 설정**:
```json
"git.path": "C:\\msys64\\usr\\bin\\git.exe"
```

### 트러블슈팅

**문제**: 터미널이 bash로 시작 (zsh 아님)

**해결**:
```bash
# ~/.bashrc 확인
echo 'if [ -t 1 ] && command -v zsh &> /dev/null; then exec zsh; fi' >> ~/.bashrc
```

**문제**: 아이콘 깨짐

**해결**: `terminal.integrated.fontFamily`를 `"MesloLGS NF"`로 설정

### 자세한 가이드

전체 설정 및 상세 가이드는 `vscode_msys2_guide.md` 파일을 참고하세요!

**빠른 적용**: `vscode_msys2_settings.json` 파일 내용을 복사하여 VS Code settings.json에 붙여넣기

---

## Powerlevel10k 설정 마법사

### zsh 첫 실행 시

```bash
exec zsh
```

자동으로 설정 마법사가 시작됩니다!

### 질문 1: Character Set

```
(1)  Unicode.
  ╭─ ~/src  master  5s ─╮
  ╰─                    ─╯

(2)  ASCII.
   ~/src  master  5s
  >
```

- **위쪽 예시가 깨지지 않고 예쁘게 보이면**: `1` (Unicode)
- **깨져보이면 (네모, 물음표)**: `2` (ASCII)
  - 나중에 Nerd Font 설치 후 `p10k configure` 재실행

**추천**: `1` (Unicode)

### 질문 2: Prompt Style

```
(1)  Lean.
(2)  Classic.
(3)  Rainbow.
(4)  Pure.
```

**추천**: `3` (Rainbow) - 가장 많은 정보 표시

### 질문 3: Prompt Colors

```
(1)  256 colors.
(2)  True color.
```

**추천**: `1` (256 colors) - 호환성 좋음

### 질문 4: Show current time?

```
(1)  No.
(2)  24-hour format.
(3)  12-hour format.
```

**추천**: `2` (24-hour format)

### 질문 5: Prompt Separators

```
(1)  Angled.
(2)  Vertical.
(3)  Slanted.
(4)  Round.
```

**추천**: `1` (Angled) - 클래식한 스타일

### 질문 6-10: 스타일 선택

나머지 질문들도 화면에 나오는 예시를 보고 선택하면 됩니다.

**빠른 추천 설정**:
```
1 (Unicode)
3 (Rainbow)
1 (256 colors)
2 (24-hour)
1 (Angled)
1 (Sharp)
1 (Flat)
2 (Two lines)
2 (Disconnected)
1 (Left)
1 (Darkest)
2 (Sparse)
2 (Many icons)
1 (Concise)
y (Transient prompt)
1 (Verbose instant prompt)
y (Apply configuration)
```

### 수동 재설정

```bash
p10k configure
```

언제든 다시 실행하여 스타일 변경 가능!

---

## 트러블슈팅

### 문제 1: `p10k configure` 실행 시 "command not found: p10k"

**원인**: oh-my-zsh가 제대로 로드되지 않음

**해결**:

```bash
# 1. oh-my-zsh.sh 파일 확인
ls -la ~/.oh-my-zsh/oh-my-zsh.sh

# 파일이 없으면 oh-my-zsh 재설치
bash msys2_auto_install.sh

# 2. .zshrc에 초기화 코드 확인
grep "source.*oh-my-zsh.sh" ~/.zshrc

# 없으면 추가
echo 'source $ZSH/oh-my-zsh.sh' >> ~/.zshrc

# 3. zsh 재시작
exec zsh
```

### 문제 2: `/home/Nam/.oh-my-zsh/oh-my-zsh.sh: No such file or directory`

**원인**: oh-my-zsh가 설치되지 않았거나 잘못된 경로

**해결**:

```bash
# 1. 현재 HOME 확인
echo $HOME

# 2. oh-my-zsh 디렉토리 확인
ls -la ~/.oh-my-zsh

# 3. 없으면 완전 재설치
bash msys2_auto_install.sh
```

### 문제 3: 한글 깨짐

**해결**:

```bash
# ~/.zshrc에 추가
echo 'export LANG=ko_KR.UTF-8' >> ~/.zshrc
echo 'export LC_ALL=ko_KR.UTF-8' >> ~/.zshrc
source ~/.zshrc
```

### 문제 4: Nerd Font 아이콘이 깨져보임

**원인**: Nerd Font 미설치

**해결**:

1. https://github.com/romkatv/powerlevel10k#manual-font-installation
2. **MesloLGS NF** 폰트 다운로드 (4개 파일)
   - MesloLGS NF Regular.ttf
   - MesloLGS NF Bold.ttf
   - MesloLGS NF Italic.ttf
   - MesloLGS NF Bold Italic.ttf
3. 모두 설치 (더블 클릭 → 설치)
4. Windows Terminal 설정에서 폰트 변경:
   ```json
   "fontFace": "MesloLGS NF"
   ```
5. 터미널 재시작 후 `p10k configure` 재실행

### 문제 5: pacman GPG 키 오류

**오류 메시지**:
```
error: failed to commit transaction (invalid or corrupted package (PGP signature))
```

**해결**:

```bash
# GPG 키 초기화
pacman-key --init
pacman-key --populate msys2
pacman -Sy archlinux-keyring

# 다시 시도
pacman -Syu
```

### 문제 6: Windows 경로 접근 오류

**잘못된 예**:
```bash
cd C:\Users\Nam\Documents  # ❌
```

**올바른 예**:
```bash
cd /c/Users/Nam/Documents  # ✅
```

### 문제 7: Git Bash와 MSYS2 zsh 충돌

**증상**: Git Bash에서 zsh 실행 시 오류

**해결**: 각 터미널을 독립적으로 사용하세요. `.bashrc`의 `exec zsh`는 MSYS2에서만 작동합니다.

### 문제 8: 터미널이 느려짐

**원인**: Powerlevel10k의 Git 상태 체크

**해결**:

```bash
# ~/.zshrc에 추가 (Git 레포지토리가 큰 경우)
POWERLEVEL9K_VCS_MAX_SYNC_LATENCY_SECONDS=0.01
```

---

## 추가 팁

### 유용한 alias 추가

`.zshrc`에 추가:

```bash
# 프로젝트 디렉토리 바로가기
alias proj='cd /c/Users/$USER/Documents/Cursor/Workspace/origin/learning-code'

# 빠른 에디터
alias edit='vim'
alias e='vim'

# 시스템 정보
alias myip='curl ifconfig.me'
alias sysinfo='uname -a && cat /proc/cpuinfo | grep "model name" | head -1'

# Docker (설치된 경우)
alias dps='docker ps'
alias di='docker images'
```

### fzf 설치 (퍼지 파인더)

```bash
# 설치
pacman -S fzf

# ~/.zshrc에 추가
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh
```

**사용법**:
- `Ctrl+T`: 파일 검색
- `Ctrl+R`: 명령어 히스토리 검색
- `Alt+C`: 디렉토리 검색

### tmux 설정

```bash
# 설치
pacman -S tmux

# ~/.tmux.conf 생성
cat > ~/.tmux.conf << 'EOF'
# 마우스 지원
set -g mouse on

# 상태바
set -g status-bg black
set -g status-fg white

# Prefix 키 변경 (Ctrl+B → Ctrl+A)
unbind C-b
set -g prefix C-a
bind C-a send-prefix
EOF
```

### 개발 도구 설치

```bash
# Python
pacman -S mingw-w64-ucrt-x86_64-python
pacman -S mingw-w64-ucrt-x86_64-python-pip

# Node.js
pacman -S mingw-w64-ucrt-x86_64-nodejs
pacman -S mingw-w64-ucrt-x86_64-npm

# GCC
pacman -S mingw-w64-ucrt-x86_64-gcc

# Make
pacman -S make
```

### Windows Terminal 단축키

| 단축키 | 기능 |
|--------|------|
| `Ctrl + Shift + T` | 새 탭 |
| `Ctrl + Shift + W` | 탭 닫기 |
| `Ctrl + Tab` | 다음 탭 |
| `Ctrl + Shift + Tab` | 이전 탭 |
| `Alt + Shift + D` | 분할 (자동) |
| `Alt + Shift + -` | 수평 분할 |
| `Alt + Shift + +` | 수직 분할 |
| `Alt + ←/→/↑/↓` | 패널 간 이동 |
| `Ctrl + Shift + F` | 검색 |

---

## 파일 구조

설치 완료 후 파일 구조:

```
C:\msys64\
├── home\
│   └── <사용자명>\
│       ├── .oh-my-zsh\
│       │   ├── oh-my-zsh.sh          # oh-my-zsh 메인 파일
│       │   ├── custom\
│       │   │   ├── themes\
│       │   │   │   └── powerlevel10k\
│       │   │   └── plugins\
│       │   │       ├── zsh-autosuggestions\
│       │   │       └── zsh-syntax-highlighting\
│       │   └── ...
│       ├── .zshrc                     # zsh 설정 파일
│       ├── .p10k.zsh                  # Powerlevel10k 설정
│       ├── .bashrc                    # bash 설정
│       └── .zsh_history               # 명령어 히스토리
└── ...
```

---

## 관련 파일

이 가이드와 함께 제공되는 파일들:

1. **msys2_auto_install.sh** - 완전 자동 설치 스크립트
2. **windows_terminal_msys2.json** - Windows Terminal 설정
3. **install_ohmyzsh_msys2.sh** - oh-my-zsh 전용 설치 스크립트

---

## FAQ

### Q1. MSYS2와 WSL 중 무엇을 선택해야 하나요?

**MSYS2 추천**:
- Windows 7/8 사용
- 가벼운 환경 선호
- WSL 설치 불가 (회사 정책 등)
- 빠른 설치 원함

**WSL 추천**:
- Windows 10 1903+ 사용
- Docker 사용
- 완벽한 리눅스 호환성 필요
- 개발 서버 구축

### Q2. Git Bash와 MSYS2를 함께 사용할 수 있나요?

네! 독립적으로 사용 가능합니다. 단, `.bashrc`의 `exec zsh`는 MSYS2에서만 작동합니다.

### Q3. Powerlevel10k를 다른 테마로 변경하려면?

```bash
# ~/.zshrc 편집
vim ~/.zshrc

# ZSH_THEME 줄 변경
ZSH_THEME="robbyrussell"  # 또는 다른 테마

# 적용
source ~/.zshrc
```

사용 가능한 테마: https://github.com/ohmyzsh/ohmyzsh/wiki/Themes

### Q4. 설치를 완전히 제거하려면?

```bash
# 1. MSYS2 설정 백업 (원한다면)
cp -r ~/.oh-my-zsh ~/backup_oh-my-zsh
cp ~/.zshrc ~/backup_zshrc

# 2. MSYS2 제거
# Windows 설정 → 앱 → MSYS2 제거

# 3. 수동으로 디렉토리 삭제
# C:\msys64 폴더 삭제
```

### Q5. 다른 PC에 동일한 설정을 적용하려면?

```bash
# 1. 설정 파일 백업
tar czf my-zsh-config.tar.gz ~/.zshrc ~/.p10k.zsh ~/.oh-my-zsh/custom

# 2. 다른 PC로 복사

# 3. 자동 설치 스크립트 실행 후
# 4. 백업 파일 복원
tar xzf my-zsh-config.tar.gz -C ~
```

---

## 결론

MSYS2 + zsh + Powerlevel10k 조합은 WSL 없이도 Windows에서 완벽한 리눅스 터미널 환경을 제공합니다.

**장점**:
- ✅ Pacman으로 쉬운 패키지 관리
- ✅ zsh + oh-my-zsh 완벽 지원
- ✅ Windows 네이티브 성능
- ✅ WSL보다 가벼움 (500MB vs 2GB)
- ✅ 기업 환경에서도 사용 가능
- ✅ 자동 설치 스크립트로 5분 설치

**추천 대상**:
- 리눅스 명령어를 자주 사용하는 개발자
- WSL을 설치할 수 없는 환경
- 가볍고 빠른 터미널 원하는 사용자

**다음 단계**:
1. [자동 설치](#자동-설치-추천) 또는 [수동 설치](#수동-설치) 진행
2. [Windows Terminal 설정](#windows-terminal-설정)
3. [Powerlevel10k 설정](#powerlevel10k-설정-마법사)

---

## 라이센스 및 크레딧

- **MSYS2**: https://www.msys2.org
- **oh-my-zsh**: https://ohmyz.sh
- **Powerlevel10k**: https://github.com/romkatv/powerlevel10k

---

**작성일**: 2025-12-17
**버전**: 2.0
**업데이트**: 실제 설치 경험 반영, 트러블슈팅 강화

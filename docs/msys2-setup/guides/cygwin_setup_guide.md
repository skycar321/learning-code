# Cygwin 설치 및 설정 가이드 (레거시 안정판)

## 개요
**가장 오래되고 안정적인** POSIX 호환 레이어
- ✅ 리눅스 명령어 거의 완벽 호환 (95%+)
- ✅ 20년+ 역사, 검증된 안정성
- ✅ 수천 개의 패키지 사용 가능
- ⚠️ 설치가 복잡하고 느림
- ⚠️ 구식 느낌 (MSYS2가 더 현대적)

---

## 1단계: Cygwin 설치

### 다운로드
https://www.cygwin.com/setup-x86_64.exe

### 설치 과정
1. **setup-x86_64.exe** 실행
2. **Install from Internet** 선택
3. **Root Directory**: `C:\cygwin64` (기본값)
4. **Local Package Directory**: `C:\cygwin_packages` (기본값)
5. **Connection**: Direct Connection
6. **Mirror 선택**: 가까운 서버 (예: ftp.jaist.ac.jp)

### 필수 패키지 선택
검색창에서 다음을 찾아 **설치**로 변경 (Skip → 버전 번호):

**기본 도구**:
```
bash-completion
zsh
git
vim
nano
wget
curl
openssh
rsync
tmux
htop
tree
```

**개발 도구** (선택):
```
gcc-core
gcc-g++
make
python3
python3-pip
```

**X11** (GUI 앱 실행, 선택):
```
xinit
xorg-server
```

7. **Next** → 의존성 자동 설치 → 완료

---

## 2단계: apt-cyg 설치 (패키지 관리자)

Cygwin은 기본적으로 CLI 패키지 관리자가 없습니다. **apt-cyg**를 설치하면 편리합니다.

### 설치 방법
```bash
# Cygwin 터미널 실행 후
curl -O https://raw.githubusercontent.com/transcode-open/apt-cyg/master/apt-cyg
install apt-cyg /bin
```

### 사용법
```bash
# 패키지 검색
apt-cyg search zsh

# 패키지 설치
apt-cyg install zsh git vim

# 패키지 제거
apt-cyg remove package-name

# 업데이트
apt-cyg update
```

---

## 3단계: zsh + oh-my-zsh 설치

### zsh 설치 확인
```bash
which zsh
# /usr/bin/zsh
```

### zsh를 기본 셸로 설정
```bash
# /etc/passwd 편집
vim /etc/passwd

# 본인 계정 줄 찾아서 마지막 부분 수정
# 변경 전: /bin/bash
# 변경 후: /bin/zsh
```

또는 자동으로:
```bash
# 현재 사용자의 셸 변경
chsh -s /bin/zsh
```

### oh-my-zsh 설치
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

---

## 4단계: Powerlevel10k 테마 설치

### 설치
```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

### 테마 적용
```bash
# ~/.zshrc 편집
vim ~/.zshrc

# ZSH_THEME 줄 수정
ZSH_THEME="powerlevel10k/powerlevel10k"
```

### 설정 마법사 실행
```bash
source ~/.zshrc
p10k configure
```

---

## 5단계: zsh 플러그인 설치

### zsh-autosuggestions
```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

### zsh-syntax-highlighting
```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

### 플러그인 활성화
```bash
# ~/.zshrc 편집
vim ~/.zshrc

# plugins 줄 수정
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
```

적용:
```bash
source ~/.zshrc
```

---

## 6단계: Windows Terminal 통합

### settings.json 설정 추가
```json
{
  "profiles": {
    "list": [
      {
        "guid": "{2c4de342-38b7-51cf-b940-2309a097f518}",
        "name": "Cygwin Bash",
        "commandline": "C:\\cygwin64\\bin\\bash.exe --login -i",
        "icon": "C:\\cygwin64\\Cygwin-Terminal.ico",
        "startingDirectory": "%USERPROFILE%",
        "fontFace": "MesloLGS NF",
        "fontSize": 10,
        "colorScheme": "One Half Dark"
      },
      {
        "guid": "{5b2c4de3-38b7-51cf-b940-2309a097f519}",
        "name": "Cygwin Zsh",
        "commandline": "C:\\cygwin64\\bin\\zsh.exe --login -i",
        "icon": "C:\\cygwin64\\Cygwin-Terminal.ico",
        "startingDirectory": "%USERPROFILE%",
        "fontFace": "MesloLGS NF",
        "fontSize": 10,
        "colorScheme": "One Half Dark"
      }
    ]
  }
}
```

**주의**: 각 프로필의 `guid`는 고유해야 합니다. 충돌 시 새로운 GUID 생성:
```powershell
# PowerShell에서 실행
[guid]::NewGuid()
```

---

## 7단계: Nerd Fonts 설치

Powerlevel10k는 Nerd Font가 필요합니다.

### MesloLGS NF 폰트 다운로드
https://github.com/romkatv/powerlevel10k#manual-font-installation

다운로드 후 설치:
- MesloLGS NF Regular.ttf
- MesloLGS NF Bold.ttf
- MesloLGS NF Italic.ttf
- MesloLGS NF Bold Italic.ttf

---

## 8단계: .zshrc 커스터마이징

### 전체 설정 예시

```bash
# ~/.zshrc

# Path to oh-my-zsh installation
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

source $ZSH/oh-my-zsh.sh

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
alias gd='git diff'

# System
alias update='apt-cyg update'
alias install='apt-cyg install'

# Environment
export EDITOR=vim
export LANG=ko_KR.UTF-8

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY

# Case-insensitive completion
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Powerlevel10k configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
```

---

## 9단계: Windows 경로 통합

### Windows 드라이브 접근
Cygwin에서는 Windows 드라이브가 `/cygdrive` 아래에 마운트됩니다:

```bash
# C 드라이브
cd /cygdrive/c/Users/Nam/Documents

# 단축 심볼릭 링크 만들기
ln -s /cygdrive/c ~/c
ln -s /cygdrive/d ~/d

# 이제 간단하게 접근
cd ~/c/Users/Nam
```

### Windows 경로를 Cygwin 경로로 변환
```bash
# cygpath 명령어 사용
cygpath -u "C:\Users\Nam\Documents"
# /cygdrive/c/Users/Nam/Documents

cygpath -w "/home/Nam"
# C:\cygwin64\home\Nam
```

---

## 10단계: 추가 유용한 도구

### fzf (퍼지 파인더)
```bash
apt-cyg install fzf

# ~/.zshrc에 추가
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
```

사용법:
- `Ctrl+T`: 파일 퍼지 검색
- `Ctrl+R`: 명령어 히스토리 검색
- `Alt+C`: 디렉토리 퍼지 검색

### tmux (터미널 멀티플렉서)
```bash
apt-cyg install tmux

# ~/.tmux.conf 설정
cat > ~/.tmux.conf << 'EOF'
# 마우스 지원
set -g mouse on

# 새 창/패널 현재 디렉토리에서 시작
bind c new-window -c "#{pane_current_path}"
bind '"' split-window -c "#{pane_current_path}"
bind % split-window -h -c "#{pane_current_path}"

# 상태바 설정
set -g status-bg black
set -g status-fg white
EOF
```

### htop (시스템 모니터)
```bash
apt-cyg install htop
htop
```

---

## 비교: Cygwin vs MSYS2 vs Git Bash

| 기능 | Cygwin | MSYS2 | Git Bash |
|------|--------|-------|----------|
| 리눅스 호환성 | ✅ 95%+ | ✅ 90%+ | ⚠️ 70% |
| 패키지 관리자 | ⚠️ apt-cyg (서드파티) | ✅ Pacman (공식) | ❌ 없음 |
| 패키지 수 | ✅ 수천 개 | ✅ 수천 개 | ⚠️ 제한적 |
| 설치 속도 | ❌ 느림 | ✅ 빠름 | ✅ 매우 빠름 |
| 업데이트 빈도 | ⚠️ 느림 | ✅ 활발 | ✅ 활발 |
| 안정성 | ✅ 매우 안정 | ✅ 안정 | ✅ 안정 |
| 현대성 | ❌ 구식 | ✅ 현대적 | ⚠️ 중간 |
| 학습 곡선 | ⚠️ 중간 | ⚠️ 중간 | ✅ 쉬움 |
| 용량 | ⚠️ 1GB+ | ⚠️ 500MB+ | ✅ 200MB |

---

## 트러블슈팅

### 1. 한글 깨짐
```bash
# ~/.zshrc에 추가
export LANG=ko_KR.UTF-8
export LC_ALL=ko_KR.UTF-8
```

### 2. Windows 프로그램 실행
```bash
# .exe 확장자 생략 가능
cmd /c start notepad

# 또는 직접 실행
/cygdrive/c/Windows/System32/notepad.exe
```

### 3. 심볼릭 링크 생성 실패
```bash
# 관리자 권한으로 Cygwin 실행 필요
# 또는 Windows 설정 변경:
# "개발자 모드" 활성화 (설정 > 업데이트 및 보안 > 개발자용)
```

### 4. PATH 충돌
```bash
# Cygwin의 명령어가 우선되도록
export PATH="/usr/local/bin:/usr/bin:$PATH"

# Windows 명령어 사용 시
/cygdrive/c/Windows/System32/find.exe  # Windows find
find  # Cygwin find
```

### 5. 패키지 설치 오류
```bash
# setup-x86_64.exe 재실행 필요
# 또는 미러 서버 변경

# apt-cyg 미러 변경
apt-cyg mirror ftp://ftp.jaist.ac.jp/pub/cygwin/
```

### 6. 느린 시작 속도
```bash
# .zshrc에서 불필요한 플러그인 제거
# Powerlevel10k instant prompt 활성화 (기본적으로 활성화됨)

# /etc/fstab 최적화
none /cygdrive cygdrive binary,noacl,posix=0,user 0 0
```

---

## 고급: Cygwin X11 (GUI 앱 실행)

### X11 서버 설치
```bash
apt-cyg install xinit xorg-server
```

### X11 앱 설치 예시
```bash
apt-cyg install xterm xclock firefox
```

### X11 서버 시작
```bash
# 터미널에서 실행
startxwin

# 그러면 X11 앱 실행 가능
xterm &
xclock &
firefox &
```

**주의**: Windows 11에서는 WSLg가 더 좋은 대안입니다.

---

## Cygwin vs WSL 비교

| 기능 | Cygwin | WSL 2 |
|------|--------|-------|
| 리눅스 호환성 | ⚠️ 95% (에뮬레이션) | ✅ 100% (진짜 커널) |
| 성능 | ⚠️ 느림 | ✅ 네이티브 |
| 파일 시스템 | ⚠️ Windows 파일 시스템 | ✅ ext4 (빠름) |
| Windows 통합 | ✅ 완벽 | ✅ 완벽 |
| Docker 지원 | ❌ 제한적 | ✅ 완벽 |
| 시스템 요구사항 | ✅ Windows 7+ | ⚠️ Windows 10 1903+ |
| 용량 | ⚠️ 1GB+ | ⚠️ 2GB+ |

**결론**: WSL이 사용 가능하면 WSL 사용 추천. Cygwin은 레거시 시스템용.

---

## 언제 Cygwin을 선택해야 하나?

### ✅ Cygwin 추천 상황:
1. **Windows 7/8** 사용 (WSL 불가)
2. **회사 보안 정책**으로 WSL 차단
3. **안정성 최우선** (20년+ 검증된 도구)
4. **X11 GUI 앱** 실행 필요 (WSL 1 대안)
5. **특정 레거시 POSIX 앱** 실행 필요

### ❌ Cygwin 비추천 상황:
1. Windows 10+ 사용 가능 → **WSL 2 사용**
2. 현대적인 개발 환경 원함 → **MSYS2 사용**
3. Windows 네이티브 선호 → **PowerShell + Oh My Posh 사용**
4. 빠른 설치 원함 → **Git Bash 사용**

---

## 완성된 최종 상태

설치 완료 후 확인:

```bash
# 버전 확인
uname -a
# CYGWIN_NT-10.0-19045

zsh --version
# zsh 5.9

git --version
# git version 2.43.0

# 테마 확인
echo $ZSH_THEME
# powerlevel10k/powerlevel10k

# 플러그인 확인
echo $plugins
# git zsh-autosuggestions zsh-syntax-highlighting

# 패키지 관리자 확인
apt-cyg --version
```

**축하합니다! Cygwin + zsh 완벽 설정 완료** 🎉

---

## 결론

Cygwin은:
- ✅ **가장 완벽한** POSIX 호환 레이어
- ✅ **20년+ 검증**된 안정성
- ✅ **수천 개 패키지** 사용 가능
- ⚠️ 설치/업데이트가 **느리고 복잡**
- ⚠️ **구식** 느낌 (MSYS2가 더 현대적)

**추천 대상**:
- 레거시 Windows 시스템 (7/8)
- WSL 사용 불가 환경
- 안정성 최우선
- POSIX 완벽 호환 필요

**대안 고려**:
- Windows 10+ → **WSL 2** (최고)
- 현대적 환경 → **MSYS2** (차선)
- Windows 네이티브 → **PowerShell + Oh My Posh**

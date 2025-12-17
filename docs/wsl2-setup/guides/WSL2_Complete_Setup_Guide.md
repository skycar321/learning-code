# WSL2 완벽 설정 가이드 (A-Z)

**작성일:** 2025-12-17
**대상:** 새 컴퓨터에 WSL2 환경을 처음부터 완벽하게 구축
**소요 시간:** 약 40-60분
**최종 상태:** 프로덕션 레디 개발 환경

---

## 📋 목차

1. [시작하기 전에](#1-시작하기-전에)
2. [WSL2 설치](#2-wsl2-설치-windows)
3. [Ubuntu 초기 설정](#3-ubuntu-초기-설정)
4. [개발 도구 설치](#4-개발-도구-설치)
5. [Modern CLI 환경 구축](#5-modern-cli-환경-구축)
6. [Windows Terminal 설정](#6-windows-terminal-설정)
7. [VS Code 통합](#7-vs-code-통합)
8. [최종 확인](#8-최종-확인)
9. [트러블슈팅](#9-트러블슈팅)
10. [성능 최적화](#10-성능-최적화)
11. [추가 커스터마이징](#11-추가-커스터마이징)

---

## 1. 시작하기 전에

### ✅ 필수 요구사항
- **OS:** Windows 10 (버전 2004 이상) 또는 Windows 11
- **RAM:** 최소 8GB (16GB 권장)
- **디스크:** 최소 20GB 여유 공간
- **관리자 권한:** PowerShell 관리자 모드 실행 가능

### 📦 설치될 항목
- WSL2 Ubuntu 24.04
- Node.js v24 LTS
- Python 3.12
- Rust (최신)
- Git, zsh, Oh My Zsh, PowerLevel10k
- Modern CLI 도구 (ripgrep, fd, fzf, bat, eza, zoxide)
- Windows Terminal + MesloLGS NF 폰트
- VS Code WSL 확장

---

## 2. WSL2 설치 (Windows)

### Step 1: PowerShell 관리자 모드로 실행

**Windows 시작 메뉴** → "PowerShell" 검색 → 우클릭 → **"관리자 권한으로 실행"**

### Step 2: WSL2 설치

```powershell
# WSL2 + Ubuntu 한 번에 설치
wsl --install -d Ubuntu-24.04

# 또는 Ubuntu만 (기본)
wsl --install -d Ubuntu
```

### Step 3: 재부팅

```powershell
# 재부팅 (필수!)
Restart-Computer
```

### Step 4: .wslconfig 파일 생성 (메모리/CPU 제한)

**재부팅 후** PowerShell 관리자 모드에서:

```powershell
# .wslconfig 파일 생성
@"
[wsl2]
memory=6GB
processors=4
swap=0
localhostForwarding=true
"@ | Out-File -FilePath "$env:USERPROFILE\.wslconfig" -Encoding utf8

# WSL 종료 (설정 적용)
wsl --shutdown
```

**설정 설명:**
- `memory=6GB`: WSL2 최대 메모리 (시스템 RAM의 50-75% 권장)
- `processors=4`: CPU 코어 수 (시스템 코어의 50-75% 권장)
- `swap=0`: 스왑 비활성화 (SSD 수명 보호, 성능 향상)
- `localhostForwarding=true`: Windows↔WSL 포트 포워딩

---

## 3. Ubuntu 초기 설정

### Step 1: Ubuntu 첫 실행

**Windows 시작 메뉴** → "Ubuntu" 검색 → 실행

처음 실행 시 사용자 계정 생성:
```
Enter new UNIX username: nam (원하는 이름)
New password: **** (기억할 비밀번호)
Retype new password: ****
```

### Step 2: 패키지 업데이트

```bash
sudo apt update && sudo apt upgrade -y
```

**소요 시간:** 3-5분

---

## 4. 개발 도구 설치

### Step 1: 필수 도구 설치

```bash
sudo apt install -y git curl wget build-essential ca-certificates gnupg lsb-release
```

### Step 2: Node.js LTS 설치

```bash
# NodeSource 저장소 추가
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -

# Node.js 설치
sudo apt install -y nodejs

# 확인
node --version  # v24.12.0
npm --version   # 11.6.2
```

### Step 3: Python 설치

```bash
sudo apt install -y python3 python3-pip python3-venv

# 확인
python3 --version  # Python 3.12.3
pip3 --version     # pip 24.0
```

### Step 4: Rust 설치

```bash
# Rust 설치 (기본 설정으로 진행)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# 환경변수 로드
source "$HOME/.cargo/env"

# 확인
rustc --version  # rustc 1.92.0
cargo --version  # cargo 1.92.0
```

### Step 5: Git 설정 (Windows 통합)

```bash
# Windows Git Credential Manager 사용
git config --global credential.helper "/mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe"

# 줄바꿈 설정
git config --global core.autocrlf input
```

**이점:** Windows에서 로그인한 Git 계정을 WSL에서도 사용 가능!

---

## 5. Modern CLI 환경 구축

### Step 1: zsh 설치

```bash
sudo apt install -y zsh

# 기본 셸로 변경 (비밀번호 입력)
chsh -s $(which zsh)
```

### Step 2: Oh My Zsh 설치

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

**주의:** 설치 중 "Do you want to change your default shell to zsh?" → **Yes** 선택

### Step 3: PowerLevel10k 테마 설치

```bash
# PowerLevel10k clone
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# .zshrc 테마 변경
sed -i 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' ~/.zshrc
```

### Step 4: Modern CLI 도구 설치

```bash
# ripgrep, fd, fzf, bat 설치
sudo apt install -y ripgrep fd-find fzf bat

# 심볼릭 링크 생성 (명령어 단축)
sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd
sudo ln -sf /usr/bin/batcat /usr/local/bin/bat
```

### Step 5: eza 설치 (고급 ls)

```bash
# GPG 키 및 저장소 추가
sudo mkdir -p -m 755 /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list

# eza 설치
sudo apt update && sudo apt install -y eza
```

### Step 6: zoxide 설치 (스마트 cd)

```bash
# zoxide 설치
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
```

**중요:** PATH 설정이 필요합니다 (다음 단계에서 진행)

### Step 7: zsh 플러그인 설치

```bash
# autosuggestions (명령어 자동 제안)
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# syntax-highlighting (문법 강조)
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

### Step 8: .zshrc 설정

```bash
# 플러그인 활성화
sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker npm node kubectl)/' ~/.zshrc

# 추가 설정 (alias, PATH, 초기화)
cat >> ~/.zshrc << 'EOF'

# ===== Custom Configuration =====

# Local bin PATH (zoxide 등)
export PATH="$HOME/.local/bin:$PATH"

# Rust 환경변수
source "$HOME/.cargo/env"

# Modern CLI Aliases
alias ls='eza --icons'
alias ll='eza -l --icons'
alias la='eza -la --icons'
alias cat='bat'

# zoxide 초기화 (조건부 - 설치되어 있을 때만)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# PowerLevel10k instant prompt 경고 억제
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

EOF
```

### Step 9: 설정 적용

```bash
# 설정 다시 로드
source ~/.zshrc
```

**완료!** 이제 터미널을 닫고 다시 열면 zsh가 기본 셸로 적용됩니다.

---

## 6. Windows Terminal 설정

### Step 1: Windows Terminal 설치

**Microsoft Store** 열기 → **"Windows Terminal"** 검색 → **설치**

또는 PowerShell에서:
```powershell
winget install Microsoft.WindowsTerminal
```

### Step 2: MesloLGS NF 폰트 다운로드 및 설치

**Ubuntu 터미널**에서 실행:

```bash
# 임시 폴더 생성 및 이동
mkdir -p /tmp/meslo-fonts && cd /tmp/meslo-fonts

# 폰트 다운로드
curl -fLo "MesloLGS NF Regular.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
curl -fLo "MesloLGS NF Bold.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
curl -fLo "MesloLGS NF Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
curl -fLo "MesloLGS NF Bold Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
```

**PowerShell 관리자 모드**에서 폰트 설치:

```powershell
# 폰트 파일 Windows로 복사 및 설치
$fontFiles = Get-ChildItem "C:\Users\$env:USERNAME\AppData\Local\Temp\meslo-fonts\*.ttf"
$FONTS = 0x14
$objShell = New-Object -ComObject Shell.Application
$objFolder = $objShell.Namespace($FONTS)

foreach ($file in $fontFiles) {
    Write-Host "Installing: $($file.Name)"
    $objFolder.CopyHere($file.FullName, 0x10)
}
```

### Step 3: Windows Terminal 폰트 설정

1. **Windows Terminal** 실행
2. 상단 **`∨`** 버튼 클릭 → **"설정"** 선택
3. 왼쪽 메뉴에서 **"Ubuntu"** 프로필 선택
4. **"모양"** 탭 클릭
5. **"글꼴"** 드롭다운에서 **"MesloLGS NF"** 선택
6. **"크기"**: 11 또는 12
7. **"저장"** 버튼 클릭

### Step 4: 테스트

**Windows Terminal**에서 새 Ubuntu 탭 열기:
- `Ctrl + Shift + T` (새 탭)

아이콘이 제대로 표시되는지 확인:
```bash
echo "🚀 ✨ 📁 💻"
ll
```

---

## 7. VS Code 통합

### Step 1: VS Code 확장 설치

**PowerShell**에서:

```powershell
# Remote - WSL 확장 설치
code --install-extension ms-vscode-remote.remote-wsl

# Remote - Containers 확장 설치 (Docker 사용 시)
code --install-extension ms-vscode-remote.remote-containers
```

### Step 2: VS Code 터미널 폰트 설정

**VS Code 실행** → `Ctrl + ,` (설정) → 검색창에 **"terminal font"** 입력

**"Terminal › Integrated: Font Family"** 항목에 입력:
```
MesloLGS NF
```

또는 **settings.json** 직접 편집:

`Ctrl + Shift + P` → **"Preferences: Open User Settings (JSON)"** 선택

다음 추가:
```json
{
    "terminal.integrated.fontFamily": "MesloLGS NF",
    "terminal.integrated.fontSize": 12,
    "terminal.integrated.defaultProfile.windows": "Ubuntu-24.04 (WSL)"
}
```

### Step 3: VS Code에서 WSL 프로젝트 열기

**Ubuntu 터미널**에서:
```bash
# 홈 디렉토리에서 VS Code 실행
cd ~
code .
```

**VS Code 좌측 하단**에 **`WSL: Ubuntu`** 표시 확인!

---

## 8. 최종 확인

### Step 1: 터미널 재시작

```bash
exit
```

**Ubuntu 터미널** 다시 실행

### Step 2: PowerLevel10k 설정

처음 실행 시 **PowerLevel10k 설정 마법사**가 자동 실행됩니다.

질문에 답하며 원하는 스타일 선택:
- Diamond 아이콘 보이나요? → **Yes**
- Prompt Style? → **Rainbow** (또는 선호하는 스타일)
- ...

나중에 다시 설정하려면:
```bash
p10k configure
```

### Step 3: 전체 설치 확인

```bash
echo "=== WSL2 설치 최종 확인 ==="
echo ""
echo "📦 기본 도구:"
echo "  ✅ Git: $(git --version)"
echo "  ✅ curl: $(curl --version 2>/dev/null | head -n1)"
echo "  ✅ wget: $(wget --version 2>/dev/null | head -n1)"
echo ""
echo "🌐 개발 언어/런타임:"
echo "  ✅ Node.js: $(node --version)"
echo "  ✅ npm: $(npm --version)"
echo "  ✅ Python3: $(python3 --version)"
echo "  ✅ pip3: $(pip3 --version | cut -d' ' -f1-2)"
echo "  ✅ Rust: $(rustc --version)"
echo "  ✅ Cargo: $(cargo --version)"
echo ""
echo "🎨 Shell:"
echo "  ✅ 현재 셸: $SHELL"
echo "  ✅ zsh: $(zsh --version)"
echo "  ✅ Oh My Zsh: $([ -d ~/.oh-my-zsh ] && echo '설치됨' || echo '없음')"
echo "  ✅ Powerlevel10k: $([ -d ~/.oh-my-zsh/custom/themes/powerlevel10k ] && echo '설치됨' || echo '없음')"
echo ""
echo "⚡ Modern CLI:"
echo "  ✅ ripgrep: $(rg --version | head -n1)"
echo "  ✅ fd: $(fd --version)"
echo "  ✅ fzf: $(fzf --version)"
echo "  ✅ bat: $(bat --version)"
echo "  ✅ eza: $(eza --version | head -n1)"
echo "  ✅ zoxide: $(zoxide --version)"
echo ""
echo "🔌 zsh 플러그인:"
echo "  ✅ autosuggestions: $([ -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ] && echo '설치됨' || echo '없음')"
echo "  ✅ syntax-highlighting: $([ -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ] && echo '설치됨' || echo '없음')"
echo ""
echo "🎉 모든 설치가 완료되었습니다!"
```

### Step 4: Modern CLI 기능 테스트

```bash
# zoxide 테스트 (처음엔 기록이 없으므로 cd로 방문 후 테스트)
cd ~
cd /tmp
z ~  # 홈으로 바로 이동

# eza (아이콘 표시)
ll

# bat (문법 강조)
cat ~/.zshrc

# fzf (명령어 히스토리 검색)
# Ctrl + R 눌러서 테스트

# ripgrep (고속 검색)
rg "alias" ~/.zshrc
```

---

## 9. 트러블슈팅

### 🔧 zsh가 기본 셸로 안 바뀌는 경우

```bash
# chsh 다시 실행
chsh -s $(which zsh)

# 비밀번호 입력

# 터미널 완전 종료 후 재실행
exit
```

### 🔧 zoxide 명령어가 작동하지 않는 경우

```bash
# PATH 확인
echo $PATH | grep ".local/bin"

# 없다면 .zshrc 확인
grep "PATH.*local/bin" ~/.zshrc

# 없으면 수동 추가
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### 🔧 Rust 환경변수 로드 안되는 경우

```bash
# 현재 세션에서 로드
source "$HOME/.cargo/env"

# .zshrc에 영구 추가 확인
grep "cargo/env" ~/.zshrc

# 없으면 수동 추가
echo 'source "$HOME/.cargo/env"' >> ~/.zshrc
```

### 🔧 Windows Terminal 아이콘 깨짐

1. **MesloLGS NF 폰트 설치 확인**:
   - Windows 설정 → 폰트 → "MesloLGS NF" 검색

2. **Windows Terminal 폰트 설정 확인**:
   - 설정 → Ubuntu 프로필 → 모양 → 글꼴: **"MesloLGS NF"**

3. **다른 Nerd Font 사용** (대안):
   - FiraCode Nerd Font
   - JetBrainsMono Nerd Font
   - Download: https://www.nerdfonts.com/

### 🔧 VS Code 터미널 아이콘 깨짐

VS Code `settings.json` 확인:
```json
{
    "terminal.integrated.fontFamily": "MesloLGS NF"
}
```

### 🔧 WSL 메모리 사용량이 너무 높은 경우

`.wslconfig` 파일 확인 및 수정:

**PowerShell**:
```powershell
notepad $env:USERPROFILE\.wslconfig
```

메모리 값 조정 (예: 6GB → 4GB):
```ini
[wsl2]
memory=4GB
processors=2
swap=0
localhostForwarding=true
```

저장 후:
```powershell
wsl --shutdown
```

### 🔧 PowerLevel10k 설정 다시 하기

```bash
p10k configure
```

### 🔧 Oh My Zsh 플러그인이 작동하지 않는 경우

```bash
# .zshrc plugins 설정 확인
grep "^plugins=" ~/.zshrc

# 플러그인 디렉토리 확인
ls ~/.oh-my-zsh/custom/plugins/

# 설정 다시 로드
source ~/.zshrc
```

---

## 📚 참고 자료

| 항목 | 링크 |
|------|------|
| **WSL 공식 문서** | https://learn.microsoft.com/ko-kr/windows/wsl/ |
| **Oh My Zsh** | https://ohmyz.sh/ |
| **PowerLevel10k** | https://github.com/romkatv/powerlevel10k |
| **Modern Unix Tools** | https://github.com/ibraheemdev/modern-unix |
| **Rust 공식** | https://www.rust-lang.org/ |
| **zoxide** | https://github.com/ajeetdsouza/zoxide |
| **eza** | https://github.com/eza-community/eza |
| **Windows Terminal** | https://github.com/microsoft/terminal |
| **Nerd Fonts** | https://www.nerdfonts.com/ |

---

## 🎓 학습 포인트

★ **인사이트** ─────────────────────────────────────

### 1. WSL2의 강력한 장점
- **네이티브 Linux 커널**: Docker, Kubernetes 등 완벽 호환
- **Windows 통합**: `/mnt/c`로 Windows 파일 접근
- **VS Code Remote**: 완벽한 통합 개발 환경
- **성능**: `~/` (Linux 파일시스템)에서 `/mnt/c`보다 5-10배 빠름

### 2. Modern CLI 도구의 혁신
- **ripgrep**: grep보다 5-10배 빠른 검색
- **fd**: find보다 직관적이고 빠름
- **bat**: cat + 문법 강조 + Git 통합
- **eza**: ls + 아이콘 + Git 상태 표시
- **zoxide**: 학습형 cd (자주 가는 곳으로 한 번에 점프)
- **fzf**: 흐릿한 검색으로 명령어 히스토리 빠르게 찾기

### 3. zsh + Oh My Zsh 생산성
- **autosuggestions**: 과거 명령어 자동 제안 (→ 키로 완성)
- **syntax-highlighting**: 명령어 오류 즉시 확인 (빨간색)
- **Tab 완성**: `git ch<Tab>` → 모든 git ch* 명령어 표시
- **PowerLevel10k**: Git 브랜치, 상태, 실행 시간 한눈에

### 4. .wslconfig 설정의 중요성
- **메모리 제한 없으면**: WSL이 Windows 메모리 100%까지 사용 가능
- **swap=0**: SSD 수명 보호 + 성능 향상
- **processors 제한**: Windows와 WSL 간 균형 유지

### 5. Windows Terminal vs 기본 콘솔
- **GPU 가속**: 부드러운 스크롤, 빠른 렌더링
- **Nerd Font 지원**: 아이콘/이모지 완벽 표시
- **멀티 탭**: PowerShell, CMD, WSL 하나의 앱에서 관리
- **분할 창**: `Alt + Shift + D`로 화면 분할

### 6. PATH 설정 주의사항
- **$HOME/.local/bin**: zoxide, 기타 사용자 도구
- **$HOME/.cargo/bin**: Rust cargo 도구
- **.zshrc 영구 추가**: `export PATH="$PATH:새경로"`

### 7. 프로젝트 위치 전략
- **❌ /mnt/c/**: Windows 파일시스템 (느림)
- **✅ ~/**: Linux 파일시스템 (빠름, 5-10배 차이)
- **권장**: Windows에서 작업 후 WSL 홈으로 복사

─────────────────────────────────────────────────

---

## 🚀 다음 단계

### 프로젝트 개발 환경 구축

```bash
# 1. Windows 프로젝트를 WSL로 복사 (성능 향상)
cd /mnt/c/Users/[사용자명]/Documents/프로젝트
cp -r . ~/프로젝트명

# 2. 프로젝트로 이동
cd ~/프로젝트명

# 3. 의존성 설치
npm install     # Node.js 프로젝트
cargo build     # Rust 프로젝트
pip install -r requirements.txt  # Python 프로젝트

# 4. VS Code로 열기
code .
```

### Docker Desktop 연동 (선택)

1. **Docker Desktop** 설치: https://www.docker.com/products/docker-desktop/
2. 설정 → **General** → `Use the WSL 2 based engine` 체크
3. 설정 → **Resources > WSL Integration** → Ubuntu 활성화
4. Apply & Restart

**확인**:
```bash
docker ps
docker --version
```

### 추가 도구 설치 (필요 시)

```bash
# PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Redis
sudo apt install -y redis-server

# kubectl (Kubernetes)
curl -fsSLO https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
sudo install -m 0755 kubectl /usr/local/bin/kubectl

# k9s (Kubernetes TUI)
curl -sS https://webinstall.dev/k9s | bash

# htop (시스템 모니터)
sudo apt install -y htop

# jq (JSON 처리)
sudo apt install -y jq
```

---

## 10. 성능 최적화

### 🐌 WSL 성능 문제 진단

터미널 반응이 느리다면 다음을 확인하세요:

#### 문제 1: /mnt/c (Windows 파일시스템)에서 작업

**증상:**
- 명령어 실행이 느림
- Git 명령어가 특히 느림
- 빌드/컴파일이 매우 느림

**확인 방법:**
```bash
pwd
# /mnt/c/... 로 시작하면 Windows 파일시스템!
```

**해결 방법: 프로젝트를 WSL 홈으로 이동 (5-10배 빨라짐!)**

```bash
# 현재 프로젝트를 WSL 홈으로 복사
cd /mnt/c/Users/[사용자명]/Documents/프로젝트경로
rsync -av . ~/프로젝트명/

# WSL 홈으로 이동
cd ~/프로젝트명

# VS Code로 열기
code .
```

**성능 비교:**

| 작업 | /mnt/c (Windows) | ~/ (WSL 홈) | 개선도 |
|------|------------------|-------------|--------|
| ls 명령어 | 0.1-0.5초 | 0.01초 | **10-50배** |
| Git 상태 | 1-3초 | 0.1-0.3초 | **10배** |
| npm install | 5-10분 | 1-2분 | **5배** |
| cargo build | 10-20분 | 2-4분 | **5배** |

#### 문제 2: zsh 테마의 Git 상태 확인

**증상:**
- 큰 Git 저장소에서 프롬프트가 느림
- 디렉토리 이동 시 딜레이 발생

**해결 방법: .zshrc 최적화**

```bash
# .zshrc 백업
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)

# Git 상태 확인 비활성화 (매우 빨라짐)
echo 'DISABLE_UNTRACKED_FILES_DIRTY="true"' >> ~/.zshrc

# 설정 적용
source ~/.zshrc
```

### ⚡ 권장 작업 흐름

#### ✅ 개발 작업 (WSL 홈에서)

```bash
# 1. WSL 홈으로 이동
cd ~/프로젝트명

# 2. VS Code 열기 (WSL 모드)
code .

# 3. 개발 작업
npm install   # 빠름!
cargo build   # 빠름!
git status    # 빠름!
```

#### 🔄 백업/공유 (Windows로 복사)

필요할 때만 Windows로 복사:
```bash
# WSL → Windows 백업
rsync -av ~/프로젝트명/ /mnt/c/Users/[사용자명]/Documents/Backup/프로젝트명/
```

---

## 11. 추가 커스터마이징

### 🎨 테마 변경

PowerLevel10k가 너무 화려하거나 색상이 눈부시다면 다른 테마로 변경:

#### agnoster 테마 (세련되고 깔끔)

```bash
# .zshrc 백업
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)

# agnoster 테마로 변경
sed -i 's/ZSH_THEME="powerlevel10k\/powerlevel10k"/ZSH_THEME="agnoster"/' ~/.zshrc

# 적용
exec zsh
```

**agnoster 특징:**
- ✅ 깔끔한 프롬프트
- ✅ Git 통합 (브랜치명, 상태)
- ✅ 화살표로 섹션 구분
- ✅ Nerd Font 필요

#### robbyrussell 테마 (가장 심플)

```bash
# robbyrussell 테마로 변경
sed -i 's/ZSH_THEME=.*/ZSH_THEME="robbyrussell"/' ~/.zshrc

# 적용
exec zsh
```

**robbyrussell 특징:**
- ✅ 초경량, 매우 빠름
- ✅ Git 브랜치 표시
- ✅ Nerd Font 불필요
- ✅ 아이콘 없음 (순수 텍스트)

### 🎨 Windows Terminal 색상 스킴 변경

눈이 편안한 색상으로 변경:

**설정 방법:**
1. Windows Terminal 실행
2. `Ctrl + ,` (설정)
3. Ubuntu 프로필 → **모양** 탭
4. **색 구성표** 선택:

**추천 색 구성표:**
- **Solarized Dark** ⭐ - 차분하고 프로페셔널
- **One Half Dark** - 부드러운 색상
- **Tango Dark** - 따뜻한 색상
- **Campbell** - 기본, 안전한 선택

### 🔧 Git Bash를 Windows Terminal에 추가

Windows Terminal에서 Git Bash도 탭으로 관리:

**JSON 설정 방법:**
1. `Ctrl + Shift + ,` (JSON 파일 열기)
2. Ubuntu 프로필 다음에 추가:

```json
            ,
            {
                "commandline": "C:\\Program Files\\Git\\bin\\bash.exe",
                "guid": "{00000000-0000-0000-0000-000000012345}",
                "hidden": false,
                "name": "Git Bash",
                "icon": "C:\\Program Files\\Git\\mingw64\\share\\git\\git-for-windows.ico",
                "startingDirectory": "%USERPROFILE%",
                "colorScheme": "One Half Dark",
                "font":
                {
                    "face": "MesloLGS NF",
                    "size": 11
                }
            }
```

**GUI 설정 방법:**
1. 설정 → **"프로필 추가"**
2. **"새 빈 프로필"** 선택
3. 정보 입력:
   - **이름:** Git Bash
   - **명령줄:** `C:\Program Files\Git\bin\bash.exe`
   - **시작 디렉터리:** `%USERPROFILE%`
   - **아이콘:** `C:\Program Files\Git\mingw64\share\git\git-for-windows.ico`
4. **저장**

### 📌 단축키로 프로필 열기

특정 프로필을 단축키로 열기:

**settings.json의 keybindings 섹션에 추가:**

```json
{
    "keybindings": [
        {
            "command": { "action": "newTab", "profile": "Ubuntu" },
            "keys": "ctrl+shift+u"
        },
        {
            "command": { "action": "newTab", "profile": "Git Bash" },
            "keys": "ctrl+shift+g"
        },
        {
            "command": { "action": "newTab", "profile": "Windows PowerShell" },
            "keys": "ctrl+shift+p"
        }
    ]
}
```

---

## ✅ 최종 체크리스트

설치 완료 후 확인:

- [ ] `wsl --list --verbose` 결과가 Version 2
- [ ] `.wslconfig` 메모리/CPU 제한 적용됨
- [ ] Ubuntu 터미널에서 `echo $SHELL` 결과가 `/usr/bin/zsh`
- [ ] Windows Terminal에서 아이콘 정상 표시 (`ll` 명령어)
- [ ] VS Code 상태 표시줄에 `WSL: Ubuntu` 표시
- [ ] `z` (zoxide), `ll` (eza), `cat` (bat) 명령어 정상 작동
- [ ] `node --version`, `python3 --version`, `rustc --version` 모두 정상
- [ ] Git 명령어 실행 시 Windows 자격 증명 사용

---

## 🎉 완료!

**축하합니다! WSL2 개발 환경이 완벽하게 구축되었습니다!**

이제 Windows에서 Linux의 강력함을 누리며 개발할 수 있습니다! 🚀

---

**작성:** Claude (Sonnet 4.5)
**최종 업데이트:** 2025-12-17 17:45 KST
**문서 버전:** 4.0 (Complete A-Z + 성능 최적화 & 커스터마이징)
**소요 시간 (실제):** 40-60분

**변경 이력:**
- v4.0 (2025-12-17): 성능 최적화 섹션 추가 (WSL 홈 이동, .zshrc 최적화), 커스터마이징 섹션 추가 (테마 변경, Git Bash 추가)
- v3.0 (2025-12-17): 초기 완성본 (A-Z 가이드)

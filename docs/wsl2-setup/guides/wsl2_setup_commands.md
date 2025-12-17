# WSL2 Ubuntu 설정 명령어 모음

## 실행 방법
Windows에서 **Ubuntu** 터미널을 열고 아래 명령어들을 순서대로 복사-붙여넣기 하세요.

---

## ✅ 완료된 작업

### 기본 설치 및 설정
- [x] WSL2 Ubuntu 설치
- [x] 재부팅
- [x] 사용자 생성 (nam)
- [x] 비밀번호 설정 (1234)
- [x] 패키지 업데이트 및 업그레이드
- [x] 필수 개발 도구 설치 (Git 2.43.0, curl 8.5.0, wget 1.21.4)
- [x] Node.js LTS 설치 (v24.12.0, npm 11.6.2)
- [x] Python3 설치 (Python 3.12.3, pip3 24.0)
- [x] Git 설정 (credential helper, autocrlf)

### Shell 및 도구
- [x] zsh 5.9 설치
- [x] Oh My Zsh 설치
- [x] Powerlevel10k 테마 설치
- [x] Modern CLI 도구 설치
  - [x] ripgrep 14.1.0
  - [x] fd (fdfind) 9.0.0
  - [x] fzf 0.44.1
  - [x] bat 0.24.0
  - [x] eza (최신 버전)
- [x] zsh 플러그인 설치 (autosuggestions, syntax-highlighting)
- [x] .zshrc 설정 완료 (plugins, aliases)

### Windows 설정
- [x] .wslconfig 파일 생성 (메모리 6GB, CPU 4코어)
- [x] VS Code WSL 확장 설치

---

## ⚠️ 보완 필요 항목

### 1. Rust 설치 (미완료)

**설치 명령어:**
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
```

**환경변수 로드:**
```bash
source "$HOME/.cargo/env"
```

**~/.zshrc에 영구 추가:**
```bash
echo 'source "$HOME/.cargo/env"' >> ~/.zshrc
```

**확인:**
```bash
rustc --version
cargo --version
```

---

### 2. zoxide 설치 (미완료)

**설치 명령어:**
```bash
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
```

**확인:**
```bash
zoxide --version
```

**참고:** ~/.zshrc에 이미 `eval "$(zoxide init zsh)"` 설정이 있으므로 설치만 하면 됩니다.

---

### 3. 기본 셸을 zsh로 변경 (미완료)

현재 기본 셸이 `bash`로 되어 있습니다. zsh로 변경하려면:

**방법 1: 터미널 재시작 (권장)**
```bash
# Ubuntu 터미널을 완전히 종료하고 다시 실행
exit
```

**방법 2: 수동으로 zsh 실행**
```bash
# 매번 실행할 때마다
zsh
```

**방법 3: chsh 재실행**
```bash
chsh -s $(which zsh)
# 비밀번호 입력: 1234
# 그 다음 터미널 종료 후 재실행
```

**확인:**
```bash
echo $SHELL
# /usr/bin/zsh 가 출력되어야 함
```

---

## 🎯 보완 작업 일괄 실행

위의 3가지 보완 사항을 한 번에 실행하려면 아래 명령어를 복사-붙여넣기 하세요:

```bash
# 1. Rust 설치
echo "🦀 Rust 설치 중..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"
echo 'source "$HOME/.cargo/env"' >> ~/.zshrc

# 2. zoxide 설치
echo "📁 zoxide 설치 중..."
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# 3. 확인
echo ""
echo "✅ Rust: $(rustc --version 2>/dev/null || echo '❌ 설치 실패')"
echo "✅ Cargo: $(cargo --version 2>/dev/null || echo '❌ 설치 실패')"
echo "✅ zoxide: $(zoxide --version 2>/dev/null || echo '❌ 설치 실패')"
echo ""
echo "🎉 보완 작업 완료!"
echo "⚠️  터미널을 재시작하면 zsh가 기본 셸로 적용됩니다."
```

---

## 📊 현재 설치 상태 확인

```bash
echo "=== WSL2 설치 상태 ==="
echo ""
echo "📦 기본 도구:"
echo "  Git: $(git --version 2>/dev/null || echo '❌')"
echo "  curl: $(curl --version 2>/dev/null | head -n1 || echo '❌')"
echo "  wget: $(wget --version 2>/dev/null | head -n1 || echo '❌')"
echo ""
echo "🌐 개발 언어/런타임:"
echo "  Node.js: $(node --version 2>/dev/null || echo '❌')"
echo "  npm: $(npm --version 2>/dev/null || echo '❌')"
echo "  Python3: $(python3 --version 2>/dev/null || echo '❌')"
echo "  pip3: $(pip3 --version 2>/dev/null | head -n1 || echo '❌')"
echo "  Rust: $(rustc --version 2>/dev/null || echo '❌ 설치 필요')"
echo "  Cargo: $(cargo --version 2>/dev/null || echo '❌ 설치 필요')"
echo ""
echo "🎨 Shell:"
echo "  현재 셸: $SHELL"
echo "  zsh: $(zsh --version 2>/dev/null || echo '❌')"
echo "  Oh My Zsh: $([ -d ~/.oh-my-zsh ] && echo '✅' || echo '❌')"
echo "  Powerlevel10k: $([ -d ~/.oh-my-zsh/custom/themes/powerlevel10k ] && echo '✅' || echo '❌')"
echo ""
echo "⚡ Modern CLI:"
echo "  ripgrep: $(rg --version 2>/dev/null | head -n1 || echo '❌')"
echo "  fd: $(fd --version 2>/dev/null || echo '❌')"
echo "  fzf: $(fzf --version 2>/dev/null || echo '❌')"
echo "  bat: $(bat --version 2>/dev/null || echo '❌')"
echo "  eza: $(eza --version 2>/dev/null | head -n1 || echo '❌')"
echo "  zoxide: $(zoxide --version 2>/dev/null || echo '❌ 설치 필요')"
echo ""
echo "🔌 zsh 플러그인:"
echo "  autosuggestions: $([ -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ] && echo '✅' || echo '❌')"
echo "  syntax-highlighting: $([ -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ] && echo '✅' || echo '❌')"
```

---

## 📊 설치 완료 후 다음 단계

### 1. 프로젝트 복사 (WSL로 이동)

```bash
# Windows 경로 접근
cd /mnt/c/Users/Nam/Documents/Cursor/Workspace/origin/learning-code

# WSL 홈으로 복사 (성능 향상)
cp -r . ~/learning-code

# 프로젝트 이동
cd ~/learning-code
```

### 2. 의존성 설치

```bash
# Frontend
cd ~/learning-code/platform/frontend
npm install

# Backend (Rust 설치 후)
cd ~/learning-code/platform/backend
cargo build
```

### 3. 개발 스크립트 생성

```bash
cd ~/learning-code
cat > run_dev.sh << 'SCRIPT_EOF'
#!/bin/bash

echo "🚀 Starting Learning Code Platform..."

# Backend 실행
cd platform/backend
cargo run &
BACKEND_PID=$!

sleep 2

# Frontend 실행
cd ../frontend
npm run dev &
FRONTEND_PID=$!

trap "echo '⛔ Stopping...'; kill $BACKEND_PID $FRONTEND_PID; exit" INT

echo "✅ Servers running!"
echo "   Backend: http://localhost:8080"
echo "   Frontend: http://localhost:3000"

wait
SCRIPT_EOF

chmod +x run_dev.sh
```

**실행:**
```bash
./run_dev.sh
```

---

## 🎨 선택사항: Nerd Fonts 설치 (아이콘 표시)

1. [Nerd Fonts Releases](https://github.com/ryanoasis/nerd-fonts/releases) 접속
2. `FiraCode Nerd Font` 다운로드
3. 압축 해제 후 모든 `.ttf` 파일 설치
4. Windows Terminal 설정 → Ubuntu 프로필 → 글꼴 → "FiraCode Nerd Font" 선택

---

## 🔧 문제 해결

### zsh가 기본 셸로 안 바뀌는 경우
```bash
chsh -s $(which zsh)
# 비밀번호: 1234
# 터미널 완전 종료 후 재실행
```

### Powerlevel10k 설정 다시 하기
```bash
p10k configure
```

### Rust 환경변수가 로드 안되는 경우
```bash
# 현재 세션에서
source "$HOME/.cargo/env"

# ~/.zshrc에 추가
echo 'source "$HOME/.cargo/env"' >> ~/.zshrc
```

### zoxide가 동작하지 않는 경우
```bash
# zoxide 재설치
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# ~/.zshrc에 초기화 코드 확인
grep "zoxide init" ~/.zshrc

# 설정 다시 로드
source ~/.zshrc
```

---

## 📋 전체 설정 명령어 (참고용)

<details>
<summary>전체 설치 명령어 펼치기 (초기 설치 시)</summary>

### 1단계: 패키지 업데이트 및 업그레이드
```bash
sudo apt update && sudo apt upgrade -y
```

### 2단계: 필수 개발 도구 설치
```bash
sudo apt install -y git curl wget build-essential ca-certificates gnupg lsb-release
```

### 3단계: Node.js LTS 설치
```bash
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs
```

### 4단계: Python3 및 pip 설치
```bash
sudo apt install -y python3 python3-pip python3-venv
```

### 5단계: Rust 설치
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"
echo 'source "$HOME/.cargo/env"' >> ~/.zshrc
```

### 6단계: Git 설정
```bash
git config --global credential.helper "/mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe"
git config --global core.autocrlf input
```

### 7단계: zsh 설치
```bash
sudo apt install -y zsh
chsh -s $(which zsh)
```

### 8단계: Oh My Zsh 설치
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### 9단계: Powerlevel10k 테마 설치
```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
sed -i 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' ~/.zshrc
source ~/.zshrc
```

### 10단계: Modern CLI 도구 설치
```bash
# ripgrep, fd, fzf, bat
sudo apt install -y ripgrep fd-find fzf bat
sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd
sudo ln -sf /usr/bin/batcat /usr/local/bin/bat

# eza
sudo mkdir -p -m 755 /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo apt update
sudo apt install -y eza

# zoxide
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
```

### 11단계: zsh 플러그인 설치
```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

### 12단계: .zshrc 설정 파일 구성
```bash
sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker npm node kubectl)/' ~/.zshrc

cat >> ~/.zshrc << 'EOF'

# Modern CLI Aliases
alias ls='eza --icons'
alias ll='eza -l --icons'
alias la='eza -la --icons'
alias cat='bat'

# zoxide 초기화
eval "$(zoxide init zsh)"
EOF

source ~/.zshrc
```

### 13단계: .wslconfig 파일 생성 (Windows PowerShell)
```powershell
@"
[wsl2]
memory=6GB
processors=4
swap=0
localhostForwarding=true
"@ | Out-File -FilePath "$env:USERPROFILE\.wslconfig" -Encoding utf8

wsl --shutdown
```

### 14단계: VS Code WSL 확장 설치 (Windows PowerShell)
```powershell
code --install-extension ms-vscode-remote.remote-wsl
code --install-extension ms-vscode-remote.remote-containers
```

</details>

---

**보완 작업을 완료하면 설치 보고서를 작성해드리겠습니다!**

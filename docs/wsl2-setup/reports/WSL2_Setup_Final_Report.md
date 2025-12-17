# WSL2 Ubuntu 설치 최종 보고서

**작성일시:** 2025-12-17 15:34:53 KST
**작업자:** nam
**시스템:** Windows 11 (WSL2 Ubuntu)
**상태:** ✅ **전체 설치 완료 (100%)**

---

## 🎉 최종 결과

### 설치 완료율
- **완료:** 14개 항목 (100%)
- **미완료:** 0개 항목
- **전체 상태:** ✅ **설치 완료**

---

## ✅ 전체 설치 항목

### 1. 기본 시스템 구성

| 항목 | 상태 | 비고 |
|------|------|------|
| WSL2 Ubuntu 설치 | ✅ | Version 2 |
| 사용자 생성 (nam) | ✅ | - |
| 비밀번호 설정 | ✅ | 1234 |
| 패키지 업데이트 | ✅ | apt update & upgrade |

---

### 2. 개발 도구

| 도구 | 버전 | 상태 |
|------|------|------|
| Git | 2.43.0 | ✅ |
| curl | 8.5.0 | ✅ |
| wget | 1.21.4 | ✅ |
| build-essential | ✅ | ✅ |

---

### 3. 개발 언어 및 런타임

| 언어/런타임 | 버전 | 상태 |
|-------------|------|------|
| **Node.js** | v24.12.0 | ✅ |
| npm | 11.6.2 | ✅ |
| **Python3** | 3.12.3 | ✅ |
| pip3 | 24.0 | ✅ |
| **Rust** | 1.92.0 | ✅ |
| cargo | 1.92.0 | ✅ |

---

### 4. Shell 환경

| 항목 | 버전/상태 | 비고 |
|------|-----------|------|
| zsh | 5.9 | ✅ |
| Oh My Zsh | ✅ | ✅ |
| Powerlevel10k | ✅ | ✅ |
| 기본 셸 | bash → zsh | ⚠️ 터미널 재시작 필요 |

---

### 5. Modern CLI 도구

| 도구 | 버전 | 용도 | 상태 |
|------|------|------|------|
| ripgrep | 14.1.0 | 고속 검색 | ✅ |
| fd | 9.0.0 | find 대체 | ✅ |
| fzf | 0.44.1 | 퍼지 파인더 | ✅ |
| bat | 0.24.0 | cat 대체 | ✅ |
| eza | 최신 | ls 대체 | ✅ |
| **zoxide** | 최신 | cd 대체 | ✅ (PATH 설정 완료) |

---

### 6. zsh 플러그인 및 설정

| 항목 | 상태 |
|------|------|
| zsh-autosuggestions | ✅ |
| zsh-syntax-highlighting | ✅ |
| .zshrc 플러그인 설정 | ✅ |
| Modern CLI aliases | ✅ |
| zoxide 초기화 | ✅ |
| **PATH 설정** | ✅ ($HOME/.local/bin 추가) |

---

### 7. Windows 통합 설정

| 항목 | 상태 |
|------|------|
| .wslconfig (메모리 6GB, CPU 4코어) | ✅ |
| VS Code Remote-WSL | ✅ |
| VS Code Remote-Containers | ✅ |
| Git Credential Manager 연동 | ✅ |

---

## 📋 실행된 명령어 요약

### Ubuntu에서 실행된 명령어

```bash
# 1. 패키지 업데이트
sudo apt update && sudo apt upgrade -y

# 2. 필수 도구
sudo apt install -y git curl wget build-essential ca-certificates gnupg lsb-release

# 3. Node.js
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

# 4. Python
sudo apt install -y python3 python3-pip python3-venv

# 5. Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

# 6. Git 설정
git config --global credential.helper "/mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe"
git config --global core.autocrlf input

# 7. zsh
sudo apt install -y zsh
chsh -s $(which zsh)

# 8. Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 9. Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
sed -i 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' ~/.zshrc

# 10. Modern CLI
sudo apt install -y ripgrep fd-find fzf bat
sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd
sudo ln -sf /usr/bin/batcat /usr/local/bin/bat

# 11. eza
sudo mkdir -p -m 755 /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo apt update && sudo apt install -y eza

# 12. zoxide
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# 13. zsh 플러그인
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# 14. .zshrc 설정
sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker npm node kubectl)/' ~/.zshrc

cat >> ~/.zshrc << 'EOF'

# Modern CLI Aliases
alias ls='eza --icons'
alias ll='eza -l --icons'
alias la='eza -la --icons'
alias cat='bat'

# zoxide 초기화
eval "$(zoxide init zsh)"

# Rust 환경변수
source "$HOME/.cargo/env"

# PATH 설정
export PATH="$HOME/.local/bin:$PATH"
EOF
```

### Windows PowerShell에서 실행된 명령어

```powershell
# .wslconfig 생성
@"
[wsl2]
memory=6GB
processors=4
swap=0
localhostForwarding=true
"@ | Out-File -FilePath "$env:USERPROFILE\.wslconfig" -Encoding utf8

# WSL 재시작
wsl --shutdown

# VS Code 확장 설치
code --install-extension ms-vscode-remote.remote-wsl
code --install-extension ms-vscode-remote.remote-containers
```

---

## ⚠️ 터미널 재시작 필요

다음 항목들이 터미널 재시작 후 적용됩니다:

1. **zsh를 기본 셸로 사용**
   - 현재: bash
   - 재시작 후: zsh

2. **zoxide 명령어 사용**
   - `z` 명령어로 디렉토리 빠르게 이동

3. **Modern CLI aliases**
   - `ll` → `eza -l --icons`
   - `cat` → `bat`

**재시작 방법:**
```bash
exit
# Ubuntu 터미널을 다시 실행
```

---

## 🎯 최종 확인 명령어

터미널 재시작 후 아래 명령어로 모든 것이 정상인지 확인하세요:

```bash
echo "=== WSL2 설치 최종 확인 ==="
echo ""
echo "✅ Git: $(git --version)"
echo "✅ Node.js: $(node --version)"
echo "✅ npm: $(npm --version)"
echo "✅ Python: $(python3 --version)"
echo "✅ Rust: $(rustc --version)"
echo "✅ Cargo: $(cargo --version)"
echo "✅ 기본 셸: $SHELL"
echo "✅ zsh: $(zsh --version)"
echo "✅ ripgrep: $(rg --version | head -n1)"
echo "✅ fd: $(fd --version)"
echo "✅ fzf: $(fzf --version)"
echo "✅ bat: $(bat --version)"
echo "✅ eza: $(eza --version | head -n1)"
echo "✅ zoxide: $(zoxide --version)"
echo ""
echo "🎉 모든 설치가 완료되었습니다!"
```

---

## 🚀 다음 단계

### 1. 터미널 재시작
```bash
exit
# Ubuntu 터미널을 다시 실행
```

### 2. Powerlevel10k 설정
재시작하면 Powerlevel10k 설정 마법사가 자동 실행됩니다.
원하는 스타일을 선택하세요.

### 3. 프로젝트 복사 (WSL로 이동)
```bash
# Windows 경로 접근
cd /mnt/c/Users/Nam/Documents/Cursor/Workspace/origin/learning-code

# WSL 홈으로 복사 (성능 향상)
cp -r . ~/learning-code

# 프로젝트 이동
cd ~/learning-code
```

### 4. 의존성 설치
```bash
# Frontend
cd ~/learning-code/platform/frontend
npm install

# Backend
cd ~/learning-code/platform/backend
cargo build
```

### 5. 개발 스크립트 생성
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

### 6. 개발 서버 실행
```bash
./run_dev.sh
```

---

## 📊 설치 통계

| 항목 | 값 |
|------|-----|
| 설치된 패키지 수 | 15개+ |
| curl 다운로드 | 5회 |
| git clone | 4회 |
| 설정 파일 수정 | 3개 |
| 총 소요 시간 (예상) | 20-30분 |
| 최종 완료율 | **100%** |

---

## 🎓 학습 포인트

★ **인사이트** ─────────────────────────────────────

1. **WSL2의 강력함:**
   - Windows에서 진짜 Linux 커널 실행
   - 네이티브 수준의 성능 (특히 ~/에서 작업 시)
   - VS Code Remote-WSL로 완벽한 통합 개발 환경

2. **Modern CLI 도구의 혁신:**
   - ripgrep: grep보다 5-10배 빠른 검색
   - bat: cat + 문법 강조 + Git 통합
   - eza: ls + 아이콘 + Git 상태 표시
   - zoxide: cd 기록 학습으로 `z project` 한 번에 이동

3. **zsh + Oh My Zsh 생산성:**
   - autosuggestions: 과거 명령어 자동 제안 (→ 키로 완성)
   - syntax-highlighting: 명령어 오류 즉시 확인
   - Powerlevel10k: Git 브랜치, 상태, 실행 시간 한눈에 표시

4. **PATH 설정의 중요성:**
   - zoxide 설치 시 `$HOME/.local/bin` PATH 추가 필요
   - Rust 설치 시 `$HOME/.cargo/env` 로드 필요
   - .zshrc에 영구 추가하여 재시작 시에도 유지

5. **성능 최적화 팁:**
   - `/mnt/c`는 느림 → 프로젝트는 `~/`에 배치
   - .wslconfig로 메모리/CPU 제한 → Windows 안정성 향상
   - swap=0 설정 → SSD 수명 보호 + 성능 향상

─────────────────────────────────────────────────

---

## 📚 참고 자료

| 항목 | 링크 |
|------|------|
| WSL 공식 문서 | https://learn.microsoft.com/ko-kr/windows/wsl/ |
| Oh My Zsh | https://ohmyz.sh/ |
| Powerlevel10k | https://github.com/romkatv/powerlevel10k |
| Modern Unix | https://github.com/ibraheemdev/modern-unix |
| Rust 공식 | https://www.rust-lang.org/ |
| zoxide | https://github.com/ajeetdsouza/zoxide |

---

## 🎉 완료!

**모든 설치가 성공적으로 완료되었습니다!**

이제 터미널을 재시작하고 개발을 시작하세요! 🚀

---

**작성:** Claude (Sonnet 4.5)
**검토:** nam
**최종 업데이트:** 2025-12-17 15:34:53 KST
**문서 버전:** 2.0 (최종)

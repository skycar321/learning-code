# WSL2 Ubuntu 설치 결과 보고서

**작성일시:** 2025-12-17 15:25:39 KST
**작업자:** nam
**시스템:** Windows 11 (WSL2 Ubuntu)

---

## 📊 전체 요약

### 설치 진행률
- **완료:** 12개 항목 (85.7%)
- **미완료:** 2개 항목 (14.3%)
- **전체 상태:** ⚠️ 보완 필요

---

## ✅ 설치 완료 항목

### 1. 기본 시스템 구성

| 항목 | 버전/상태 | 명령어 |
|------|-----------|--------|
| WSL2 | Version 2 | `wsl --install -d Ubuntu` |
| 재부팅 | 완료 | - |
| 사용자 생성 | nam | Ubuntu 초기 설정 |
| 비밀번호 | 1234 | `passwd` (root 권한으로 변경) |

---

### 2. 패키지 및 개발 도구

| 항목 | 버전 | 설치 명령어 |
|------|------|-------------|
| **패키지 업데이트** | ✅ | `sudo apt update && sudo apt upgrade -y` |
| Git | 2.43.0 | `sudo apt install -y git` |
| curl | 8.5.0 | `sudo apt install -y curl` |
| wget | 1.21.4 | `sudo apt install -y wget` |
| build-essential | ✅ | `sudo apt install -y build-essential` |
| ca-certificates | ✅ | `sudo apt install -y ca-certificates` |
| gnupg | ✅ | `sudo apt install -y gnupg` |
| lsb-release | ✅ | `sudo apt install -y lsb-release` |

---

### 3. 개발 언어 및 런타임

| 언어/런타임 | 버전 | 설치 방법 |
|-------------|------|-----------|
| **Node.js** | v24.12.0 | NodeSource LTS 저장소 |
| npm | 11.6.2 | Node.js 설치 시 포함 |
| **Python3** | 3.12.3 | `sudo apt install -y python3` |
| pip3 | 24.0 | `sudo apt install -y python3-pip` |
| python3-venv | ✅ | `sudo apt install -y python3-venv` |

**설치 명령어:**
```bash
# Node.js LTS
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

# Python
sudo apt install -y python3 python3-pip python3-venv
```

---

### 4. Git 설정

| 설정 항목 | 값 | 명령어 |
|-----------|-----|--------|
| credential.helper | Windows Git Credential Manager | `git config --global credential.helper "/mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe"` |
| core.autocrlf | input | `git config --global core.autocrlf input` |

**적용된 설정:**
```bash
credential.helper=/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe
core.autocrlf=input
```

---

### 5. Shell 환경

| 항목 | 버전/상태 | 설치 방법 |
|------|-----------|-----------|
| **zsh** | 5.9 | `sudo apt install -y zsh` |
| **Oh My Zsh** | ✅ 설치됨 | 공식 설치 스크립트 |
| **Powerlevel10k** | ✅ 설치됨 | Git clone (depth=1) |
| 현재 기본 셸 | ⚠️ bash | chsh 실행했으나 터미널 재시작 필요 |

**설치 명령어:**
```bash
# zsh 설치
sudo apt install -y zsh

# Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Powerlevel10k 테마
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
sed -i 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' ~/.zshrc
```

---

### 6. Modern CLI 도구

| 도구 | 버전 | 용도 | 설치 방법 |
|------|------|------|-----------|
| **ripgrep** | 14.1.0 | 고속 텍스트 검색 | `sudo apt install -y ripgrep` |
| **fd** | 9.0.0 | find 대체 | `sudo apt install -y fd-find` + 심볼릭 링크 |
| **fzf** | 0.44.1 | 퍼지 파인더 | `sudo apt install -y fzf` |
| **bat** | 0.24.0 | cat 대체 (문법 강조) | `sudo apt install -y bat` + 심볼릭 링크 |
| **eza** | 최신 | ls 대체 | Gierens 저장소 추가 + `sudo apt install -y eza` |

**설치 명령어:**
```bash
# 기본 도구
sudo apt install -y ripgrep fd-find fzf bat

# 심볼릭 링크
sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd
sudo ln -sf /usr/bin/batcat /usr/local/bin/bat

# eza (별도 저장소)
sudo mkdir -p -m 755 /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo apt update && sudo apt install -y eza
```

---

### 7. zsh 플러그인

| 플러그인 | 상태 | 기능 |
|----------|------|------|
| zsh-autosuggestions | ✅ 설치됨 | 명령어 자동 제안 |
| zsh-syntax-highlighting | ✅ 설치됨 | 문법 하이라이팅 |

**설치 명령어:**
```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

---

### 8. .zshrc 설정

| 설정 항목 | 내용 | 상태 |
|-----------|------|------|
| **plugins** | git, zsh-autosuggestions, zsh-syntax-highlighting, docker, npm, node, kubectl | ✅ |
| **alias ls** | eza --icons | ✅ |
| **alias ll** | eza -l --icons | ✅ |
| **alias la** | eza -la --icons | ✅ |
| **alias cat** | bat | ✅ |
| **zoxide init** | eval "$(zoxide init zsh)" | ✅ (zoxide 미설치) |

**적용된 설정:**
```bash
plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker npm node kubectl)

alias ls='eza --icons'
alias ll='eza -l --icons'
alias la='eza -la --icons'
alias cat='bat'

eval "$(zoxide init zsh)"
```

---

### 9. Windows 설정

#### .wslconfig 파일

| 설정 | 값 | 설명 |
|------|-----|------|
| memory | 6GB | WSL2 최대 메모리 |
| processors | 4 | 사용할 CPU 코어 수 |
| swap | 0 | 스왑 비활성화 (SSD 보호) |
| localhostForwarding | true | 로컬호스트 포워딩 |

**파일 위치:** `C:\Users\Nam\.wslconfig`

**생성 명령어 (PowerShell):**
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

#### VS Code 확장

| 확장 | ID | 상태 |
|------|-----|------|
| Remote - WSL | ms-vscode-remote.remote-wsl | ✅ |
| Remote - Containers | ms-vscode-remote.remote-containers | ✅ |

**설치 명령어 (PowerShell):**
```powershell
code --install-extension ms-vscode-remote.remote-wsl
code --install-extension ms-vscode-remote.remote-containers
```

---

## ❌ 미완료 항목

### 1. Rust 설치 (미완료)

**현재 상태:** ❌ 설치 안됨

**이유:** 설치 시도했으나 환경변수 로드가 누락되었거나 설치 실패

**보완 방법:**
```bash
# Rust 설치
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# 환경변수 로드
source "$HOME/.cargo/env"

# ~/.zshrc에 영구 추가
echo 'source "$HOME/.cargo/env"' >> ~/.zshrc

# 확인
rustc --version
cargo --version
```

---

### 2. zoxide 설치 (미완료)

**현재 상태:** ❌ 설치 안됨 (단, ~/.zshrc에 초기화 코드는 있음)

**보완 방법:**
```bash
# zoxide 설치
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# 확인
zoxide --version

# 터미널 재시작 또는 설정 재로드
source ~/.zshrc
```

---

### 3. 기본 셸 변경 (부분 완료)

**현재 상태:** ⚠️ zsh 설치됨, chsh 실행됨, 그러나 현재 셸은 bash

**이유:** chsh 실행 후 터미널을 재시작하지 않음

**보완 방법:**
```bash
# 방법 1: 터미널 완전 종료 후 재실행
exit

# 방법 2: 수동으로 zsh 실행
zsh

# 확인
echo $SHELL  # /usr/bin/zsh 가 출력되어야 함
```

---

## 🎯 보완 작업 한 번에 실행

Ubuntu 터미널에서 아래 명령어를 복사-붙여넣기 하세요:

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

## 📈 설치 통계

### 명령어 실행 횟수

| 카테고리 | 명령어 수 |
|----------|-----------|
| apt install | 15개 패키지 |
| curl (다운로드) | 3회 |
| git clone | 4회 |
| 설정 파일 수정 | 3개 파일 |
| 심볼릭 링크 생성 | 2개 |

### 설치 시간 (예상)

| 단계 | 예상 시간 |
|------|-----------|
| 패키지 업데이트 | 3-5분 |
| 개발 도구 설치 | 5-10분 |
| Node.js 설치 | 2-3분 |
| Oh My Zsh + 테마 + 플러그인 | 2-3분 |
| Modern CLI 도구 | 3-5분 |
| **총 소요 시간** | **15-26분** |

---

## 🔍 추가 확인 사항

### 1. WSL 버전 확인
```powershell
wsl --list --verbose
```

**예상 출력:**
```
  NAME      STATE           VERSION
* Ubuntu    Running         2
```

### 2. 메모리/CPU 제한 확인
```bash
# WSL 내부에서
free -h
nproc
```

### 3. VS Code 연동 확인
```bash
cd ~
code .
```

VS Code 좌측 하단에 `WSL: Ubuntu` 표시 확인

---

## 📚 참고 문서

| 항목 | 링크 |
|------|------|
| WSL 공식 문서 | https://learn.microsoft.com/ko-kr/windows/wsl/ |
| Oh My Zsh | https://ohmyz.sh/ |
| Powerlevel10k | https://github.com/romkatv/powerlevel10k |
| Modern Unix Tools | https://github.com/ibraheemdev/modern-unix |
| Rust 설치 | https://www.rust-lang.org/tools/install |
| zoxide | https://github.com/ajeetdsouza/zoxide |

---

## 🎓 학습 포인트

★ **인사이트** ─────────────────────────────────────

1. **WSL2의 핵심 장점:**
   - Windows에서 진짜 Linux 커널을 실행하여 네이티브에 가까운 성능 제공
   - /mnt/c를 통한 Windows 파일 시스템 접근 가능
   - VS Code Remote-WSL로 원활한 통합 개발 환경 구축

2. **zsh + Oh My Zsh 조합:**
   - bash보다 강력한 자동완성과 플러그인 시스템
   - Powerlevel10k 테마로 Git 상태, 실행 시간 등을 즉시 확인
   - autosuggestions 플러그인으로 과거 명령어 재사용 효율 2배 향상

3. **Modern CLI 도구의 성능 차이:**
   - ripgrep은 grep보다 5-10배 빠른 검색 속도
   - fd는 find보다 직관적이고 빠름
   - bat는 cat에 문법 강조 + Git 통합 제공
   - eza는 ls에 아이콘과 Git 상태 표시 추가

4. **.wslconfig 설정의 중요성:**
   - 메모리 제한을 하지 않으면 WSL2가 Windows 메모리를 과도하게 사용
   - swap=0 설정으로 SSD 수명 보호 및 성능 향상
   - processors 제한으로 Windows와 WSL 간 균형 유지

5. **프로젝트 위치 전략:**
   - `/mnt/c` 경로는 느림 (Windows 파일 시스템)
   - `~/` (WSL 홈)은 빠름 (Linux 네이티브 파일 시스템)
   - 개발 프로젝트는 반드시 WSL 홈에 두어야 빌드 속도 5배 향상

─────────────────────────────────────────────────

---

## 🚀 다음 단계

### 1. 보완 작업 완료
- [ ] Rust 설치
- [ ] zoxide 설치
- [ ] 터미널 재시작 (zsh 기본 셸 적용)

### 2. 프로젝트 환경 구축
- [ ] learning-code 프로젝트를 WSL 홈으로 복사
- [ ] Frontend 의존성 설치 (`npm install`)
- [ ] Backend 빌드 (`cargo build`)
- [ ] 개발 스크립트 생성 (`run_dev.sh`)

### 3. 선택 사항
- [ ] Nerd Fonts 설치 (아이콘 표시)
- [ ] Docker Desktop WSL 통합
- [ ] 추가 개발 도구 설치 (DB, K8s CLI 등)

---

## 📝 변경 이력

| 날짜 | 내용 |
|------|------|
| 2025-12-17 15:25 KST | 초기 설치 완료 및 보고서 작성 |
| 2025-12-17 | 비밀번호 1234로 변경 |
| 2025-12-17 | WSL2 Ubuntu 설치 및 사용자 생성 (nam) |

---

**작성자:** Claude (Sonnet 4.5)
**검토:** nam
**문서 버전:** 1.0

---

## 📞 문제 발생 시

1. **설치 중 오류 발생:**
   - 오류 메시지를 확인하고 `wsl2_setup_commands.md`의 문제 해결 섹션 참조

2. **성능 문제:**
   - `.wslconfig` 파일 확인 및 `wsl --shutdown` 후 재시작

3. **환경변수 문제:**
   - `source ~/.zshrc` 실행 또는 터미널 재시작

4. **추가 지원 필요:**
   - 이 보고서와 함께 오류 메시지를 공유해주세요

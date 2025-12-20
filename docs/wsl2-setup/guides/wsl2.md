# WSL2 환경 구축 가이드 (Updated 2025-12-16)

실무에서 바로 쓸 수 있는 WSL2 셋업을 정리했습니다. 관리자 PowerShell에서 시작해 Ubuntu까지 순서대로 따라가면 됩니다.

**핵심 한 줄 요약**
- `.wslconfig`로 메모리·CPU 상한을 먼저 잡는다.
- 기본 툴(Git/Node/Rust/Python) + Modern CLI(zsh, fzf, zoxide, eza, bat, rg)를 한 번에 설치한다.
- Docker Desktop·VS Code는 WSL 통합 옵션을 반드시 켠다.
- 자주 쓰는 추가 스택(DB, K8s CLI, 클라우드 CLI, 버전 관리 도구)을 상황에 맞게 더한다.

---

## 1단계: WSL2 설치 및 자원 제한 (PowerShell 관리자)

1. PowerShell을 **관리자**로 실행한 뒤 WSL2 설치:
   ```powershell
   wsl --install -d Ubuntu
   ```
2. (선택) 설치 후 PC를 한 번 재부팅.
3. 메모리/CPU를 제한하려면 사용자 홈(`%UserProfile%`)에 `.wslconfig` 파일을 만들고 아래 예시를 저장:
   ```ini
   [wsl2]
   memory=6GB        # WSL2가 사용할 최대 RAM
   processors=4      # 사용할 CPU 코어 수
   swap=0            # 스왑 비활성 (SSD 수명 보호, 성능 향상)
   localhostForwarding=true
   ```
   변경 후 `wsl --shutdown`을 실행해야 재적용된다.

---

## 2단계: Ubuntu 초기 설정

1. 처음 실행 시 사용자명/비밀번호를 설정한다. (예: `nam`)
2. 기본 패키지 업데이트:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

---

## 3단계: 필수 개발 도구 설치

```bash
# 기본 유틸
sudo apt install -y git curl wget build-essential ca-certificates gnupg lsb-release

# Node.js (LTS)
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

# Python
sudo apt install -y python3 python3-pip python3-venv

# Rust (rustup)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"

# Go (옵션)
sudo apt install -y golang

# .NET SDK (옵션)
sudo apt install -y dotnet-sdk-8.0
```

### Git 자격 증명 연동 (Windows Git Credential Manager)
Windows에 설치된 Git Credential Manager를 그대로 쓰면 매번 비밀번호를 넣지 않아도 된다.
```bash
git config --global credential.helper "/mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe"
git config --global core.autocrlf input
```

---

## 4단계: zsh + Modern CLI 세트

```bash
# zsh 및 기본 쉘 변경
sudo apt install -y zsh
chsh -s "$(which zsh)"

# Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 테마: Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
sed -i 's|^ZSH_THEME=.*|ZSH_THEME=\"powerlevel10k/powerlevel10k\"|' ~/.zshrc

# Modern CLI (고성능 도구)
sudo apt install -y ripgrep fd-find fzf
sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd
sudo apt install -y bat && sudo ln -sf /usr/bin/batcat /usr/local/bin/bat
sudo apt install -y gpg
mkdir -p -m 755 /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo apt update && sudo apt install -y eza

# zsh 플러그인
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# .zshrc 플러그인/별칭 추가
cat <<'EOF' >> ~/.zshrc
plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker npm)
alias ls='eza --icons'
alias ll='eza -l --icons'
alias la='eza -la --icons'
alias cat='bat'
eval "$(zoxide init zsh 2>/dev/null)"
EOF

source ~/.zshrc
```

---

## 5단계: Docker Desktop 연동 (Windows)

1. [Docker Desktop](https://www.docker.com/products/docker-desktop/) 설치.
2. 설정 → **General**에서 `Use the WSL 2 based engine` 체크.
3. 설정 → **Resources > WSL Integration**에서 `Enable integration with my default WSL distro` 체크 후 Ubuntu를 ON → `Apply & Restart`.
4. Ubuntu 터미널에서 `docker ps`가 동작하면 성공.

---

## 6단계: VS Code 연동

```powershell
code --install-extension ms-vscode-remote.remote-wsl
code --install-extension ms-vscode-remote.remote-containers
```
Ubuntu에서 프로젝트 폴더로 이동 후 `code .` 실행 → 좌측 하단에 `WSL: Ubuntu`가 보이면 정상.

---

## 7단계: 개발자들이 자주 설치하는 추가 스택

- **DB/캐시**
  - PostgreSQL: `sudo apt install -y postgresql postgresql-contrib`
  - MySQL/MariaDB: `sudo apt install -y mysql-server` 또는 `mariadb-server`
  - Redis: `sudo apt install -y redis-server` (필요 시 `sudo systemctl enable --now redis-server`)
  - MongoDB Community: 공식 repo 필요 → [공식 문서](https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu/) 참고
- **검색/메시징**
  - Elasticsearch/OpenSearch는 메모리 요구사항이 커서 `.wslconfig` 조정 후 설치 권장
  - RabbitMQ: `sudo apt install -y rabbitmq-server`
- **툴링**
  - `htop`, `ncdu`, `jq`, `yq` : 모니터링·JSON/YAML 처리
  - `tmux`, `neovim` : 터미널 멀티플렉서·에디터

---

## 8단계: Kubernetes · 클라우드 CLI

- **kubectl**:
  ```bash
  curl -fsSLO https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
  sudo install -m 0755 kubectl /usr/local/bin/kubectl
  ```
- **helm**: `curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash`
- **k9s**: `curl -sS https://webinstall.dev/k9s | bash`
- **kind/minikube**(로컬 클러스터): 필요 시 선택 설치.
- **클라우드 CLI**
  - AWS: `curl \"https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip\" -o awscliv2.zip && unzip awscliv2.zip && sudo ./aws/install`
  - Azure: `curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash`
  - GCP: `sudo apt install -y google-cloud-cli`

---

## 9단계: 언어/런타임 버전 관리자 (필요할 때만)

- Node 다중 버전: `nvm` 설치 → `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash`
- Python 다중 버전: `pyenv` → `curl https://pyenv.run | bash`
- Java: `sdkman` → `curl -s \"https://get.sdkman.io\" | bash`
- Terraform/인프라: `tfenv` → `git clone https://github.com/tfutils/tfenv ~/.tfenv && echo 'export PATH=\"$HOME/.tfenv/bin:$PATH\"' >> ~/.zshrc`

---

## 10단계: 프로젝트 가져오기 & 실행 예시

```bash
# Windows 경로를 직접 쓰면 성능이 느려질 수 있으니 WSL 홈으로 복사 권장
cd /mnt/c/Users/Nam/Documents/Cursor/Workspace/origin/learning-code
cp -r . ~/learning-code

cd ~/learning-code
npm install       # 프론트엔드
cargo build       # 백엔드
```

예시 실행 스크립트(`~/learning-code/run_dev.sh`):
```bash
#!/bin/bash
echo \"🚀 Starting Learning Code Platform...\"

cd platform/backend
cargo run &
BACKEND_PID=$!

sleep 2

cd ../frontend
npm run dev &
FRONTEND_PID=$!

trap \"kill $BACKEND_PID $FRONTEND_PID; exit\" INT
wait
```
실행 권한 부여: `chmod +x run_dev.sh`, 실행: `./run_dev.sh`

---

## 최종 체크리스트
- [ ] `wsl --list --verbose` 결과가 Version 2인지 확인
- [ ] `.wslconfig`가 의도한 메모리/CPU로 적용됨 (`wsl --shutdown` 후 재시작)
- [ ] `docker ps`가 Ubuntu에서 정상 실행
- [ ] VS Code 상태 표시줄에 `WSL: Ubuntu` 표시
- [ ] `ll`(eza), `z`(zoxide), `rg`(ripgrep) 등이 동작
- [ ] 필요한 추가 스택(DB, K8s, 클라우드 CLI)이 설치되어 있음

필요한 패키지가 더 있다면 요청해 주세요. 최신 버전 기준으로 계속 보완하겠습니다.\n*** End Patch"}​

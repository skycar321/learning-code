다음과 같이 claude가 wsl2 설치과정을 나열해줬어 이것 외에 개발자들이 많이설치하는것을 웹조사해서 내용추가해줘 

 WSL2 전환 완벽 가이드

  ★ 인사이트 ─────────────────────────────────────
  • WSL2는 Windows 안에 진짜 Linux 커널을 실행하여 네이티브에 가까운 성능을 제공합니다
  • zsh + Oh My Zsh + Powerlevel10k 조합은 생산성을 2배 이상 높여줍니다
  • VS Code의 Remote-WSL 확장으로 Windows와 Linux를 완벽히 통합할 수 있습니다
  ─────────────────────────────────────────────────

  📋 전체 과정 개요

  1단계: WSL2 설치 (Windows)
  2단계: Ubuntu 초기 설정
  3단계: 개발 도구 설치
  4단계: zsh + Oh My Zsh 설치
  5단계: VS Code 연동
  6단계: 프로젝트 마이그레이션

  ---
  1단계: WSL2 설치 (PowerShell 관리자 권한)

  1-1. PowerShell 관리자로 실행

  # Windows 검색 → "PowerShell" → 우클릭 → "관리자 권한으로 실행"

  1-2. WSL2 설치

  # WSL2 및 Ubuntu 설치 (한 번에)
  wsl --install -d Ubuntu

  # 설치 후 재부팅 필수!

  1-3. 설치 확인

  # 재부팅 후 다시 PowerShell 관리자로 실행
  wsl --list --verbose

  # 출력 예시:
  #   NAME      STATE           VERSION
  # * Ubuntu    Running         2

  ---
  2단계: Ubuntu 초기 설정

  2-1. Ubuntu 터미널 실행

  # Windows 검색 → "Ubuntu" 실행
  # 또는 PowerShell에서: wsl

  2-2. 사용자 계정 생성

  # 처음 실행 시 사용자명과 비밀번호 입력
  # 예: 사용자명 = nam, 비밀번호 = ****

  2-3. 패키지 업데이트

  sudo apt update && sudo apt upgrade -y

  ---
  3단계: 개발 도구 설치

  3-1. 필수 도구

  # Git, curl, wget, build-essential
  sudo apt install -y git curl wget build-essential

  # Node.js (최신 LTS)
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
  sudo apt install -y nodejs

  # Rust
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  source "$HOME/.cargo/env"

  # Python (보통 기본 설치되어 있음)
  sudo apt install -y python3 python3-pip

  3-2. 도구 버전 확인

  git --version
  node --version
  npm --version
  cargo --version
  python3 --version

  ---
  4단계: zsh + Oh My Zsh 설치 (핵심!)

  4-1. zsh 설치

  sudo apt install -y zsh

  # zsh을 기본 셸로 설정
  chsh -s $(which zsh)

  # 로그아웃 후 다시 로그인 (터미널 종료 후 재실행)
  exit
  # Ubuntu 터미널 다시 실행

  4-2. Oh My Zsh 설치

  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

  4-3. Powerlevel10k 테마 설치 (강력 추천!)

  # Powerlevel10k 다운로드
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

  # ~/.zshrc 파일 수정
  sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

  # 설정 적용
  source ~/.zshrc

  # Powerlevel10k 설정 마법사 실행 (자동 실행됨)
  # 화면 안내에 따라 원하는 스타일 선택

  4-4. 유용한 zsh 플러그인 설치

  # zsh-autosuggestions (명령어 자동완성)
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

  # zsh-syntax-highlighting (문법 하이라이팅)
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

  # ~/.zshrc 플러그인 활성화
  sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker kubectl npm node)/' ~/.zshrc

  # 설정 적용
  source ~/.zshrc

  ---
  5단계: VS Code 연동

  5-1. VS Code 확장 설치 (Windows에서)

  # PowerShell에서 실행
  code --install-extension ms-vscode-remote.remote-wsl
  code --install-extension ms-vscode-remote.remote-containers

  5-2. WSL에서 VS Code 실행

  # Ubuntu 터미널에서
  cd ~
  code .

  # VS Code가 자동으로 WSL 모드로 전환됩니다

  5-3. 추천 VS Code 확장 (WSL 내부에서 설치)

  # VS Code 터미널(Ctrl+`)에서 실행
  code --install-extension dbaeumer.vscode-eslint
  code --install-extension esbenp.prettier-vscode
  code --install-extension bradlc.vscode-tailwindcss
  code --install-extension rust-lang.rust-analyzer
  code --install-extension ms-python.python
  code --install-extension eamodio.gitlens

  ---
  6단계: 프로젝트 마이그레이션

  6-1. Windows 파일 시스템 접근

  # Windows C 드라이브는 /mnt/c 로 접근
  cd /mnt/c/Users/Nam/Documents/Cursor/Workspace/origin/learning-code
  ls -la

  6-2. 프로젝트를 WSL 홈으로 복사 (권장)

  # WSL 홈 디렉토리로 복사 (성능 향상)
  cp -r /mnt/c/Users/Nam/Documents/Cursor/Workspace/origin/learning-code ~/learning-code

  # 프로젝트 디렉토리 이동
  cd ~/learning-code

  6-3. 의존성 재설치

  # Frontend (Next.js)
  cd ~/learning-code/platform/frontend
  npm install

  # Backend (Rust)
  cd ~/learning-code/platform/backend
  cargo build

  # 테스트 실행
  cd ~/learning-code
  ./run_dev.sh  # Windows .bat 대신 .sh 스크립트 생성 필요

  ---
  7단계: 개발 스크립트 생성 (Linux용)

  7-1. run_dev.sh 생성

  cat > ~/learning-code/run_dev.sh << 'EOF'
  #!/bin/bash

  echo "🚀 Starting Learning Code Platform..."

  # Backend 실행
  echo "📦 Starting Rust Backend..."
  cd platform/backend
  cargo run &
  BACKEND_PID=$!

  # 2초 대기
  sleep 2

  # Frontend 실행
  echo "🎨 Starting Next.js Frontend..."
  cd ../frontend
  npm run dev &
  FRONTEND_PID=$!

  # Trap Ctrl+C
  trap "echo '⛔ Stopping servers...'; kill $BACKEND_PID $FRONTEND_PID; exit" INT

  echo "✅ Servers running!"
  echo "   - Backend: http://localhost:8080"
  echo "   - Frontend: http://localhost:3000"
  echo "Press Ctrl+C to stop."

  # 대기
  wait
  EOF

  chmod +x ~/learning-code/run_dev.sh

  7-2. 실행

  cd ~/learning-code
  ./run_dev.sh

  ---
  🎨 추가 설정 (선택사항)

  Nerd Fonts 설치 (아이콘 표시용)

  # Windows PowerShell에서 실행
  # 1. https://github.com/ryanoasis/nerd-fonts/releases 접속
  # 2. "FiraCode Nerd Font" 다운로드
  # 3. 압축 해제 후 모든 .ttf 파일 설치 (우클릭 → 설치)
  # 4. Windows Terminal 설정 → Ubuntu 프로필 → 글꼴 → "FiraCode Nerd Font"

  Windows Terminal 테마 설정

  // settings.json (Ctrl+Shift+,)
  {
    "profiles": {
      "defaults": {
        "fontFace": "FiraCode Nerd Font",
        "fontSize": 11,
        "colorScheme": "One Half Dark"
      }
    }
  }

  ---
  🚀 최종 확인 체크리스트

  # WSL2 버전 확인
  wsl --list --verbose

  # zsh 설정 확인
  echo $SHELL  # /usr/bin/zsh 출력되어야 함

  # 개발 도구 확인
  git --version
  node --version
  cargo --version

  # 프로젝트 실행 확인
  cd ~/learning-code
  ./run_dev.sh

  ---
  ★ 인사이트 ─────────────────────────────────────
  • /mnt/c는 느립니다! 프로젝트는 반드시 ~/ (WSL 홈)에 두세요
  • VS Code의 Remote-WSL은 파일 감시, 빌드 속도가 Windows보다 5배 빠릅니다
  • zsh-autosuggestions는 과거 명령어를 기억하여 → 키만 누르면 자동완성됩니다
  ─────────────────────────────────────────────────

  📚 추가 참고자료

  - Oh My Zsh 플러그인: https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins
  - Powerlevel10k 문서: https://github.com/romkatv/powerlevel10k
  - WSL2 공식 문서: https://learn.microsoft.com/ko-kr/windows/wsl/

  ---
  이 가이드를 따라 진행하시면 Windows CLI 인코딩 문제가 완전히 해결되고, 생산성이 크게 향상됩니다! 🎉

  추가 질문이나 특정 단계에서 문제가 발생하면 말씀해 주세요!
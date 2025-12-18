#!/bin/bash
# ============================================================================
# MSYS2 Node.js & npm 자동 설치 스크립트
# ============================================================================
# 목적: MSYS2 UCRT64 환경에서 Node.js와 npm을 자동으로 설치하고 설정
# 사용법: ./install_nodejs_npm.sh
# ============================================================================

set -e  # 오류 발생 시 스크립트 종료

echo "======================================"
echo "MSYS2 Node.js & npm 설치 스크립트"
echo "======================================"
echo ""

# ============================================================================
# 1. 현재 환경 확인
# ============================================================================
echo "[1/6] 현재 환경 확인..."

if [[ "$MSYSTEM" == "UCRT64" ]]; then
    NODE_PACKAGE="mingw-w64-ucrt-x86_64-nodejs"
    echo "✓ UCRT64 환경 감지"
elif [[ "$MSYSTEM" == "MINGW64" ]]; then
    NODE_PACKAGE="mingw-w64-x86_64-nodejs"
    echo "✓ MINGW64 환경 감지"
else
    echo "⚠️  경고: UCRT64 또는 MINGW64 환경이 아닙니다."
    echo "현재 환경: $MSYSTEM"
    echo "UCRT64로 기본 설정합니다."
    NODE_PACKAGE="mingw-w64-ucrt-x86_64-nodejs"
fi

echo "📦 설치 패키지: $NODE_PACKAGE (npm 포함)"

echo ""

# ============================================================================
# 2. 기존 Node.js 확인
# ============================================================================
echo "[2/6] 기존 Node.js 설치 확인..."

if command -v node &> /dev/null; then
    echo "기존 Node.js 발견:"
    echo "  버전: $(node --version)"
    echo "  경로: $(which node)"
    echo ""
    read -p "기존 설치를 유지하고 계속하시겠습니까? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "설치를 취소합니다."
        exit 0
    fi
else
    echo "✓ 기존 Node.js 없음 (새로 설치 진행)"
fi

echo ""

# ============================================================================
# 3. 패키지 데이터베이스 업데이트
# ============================================================================
echo "[3/6] 패키지 데이터베이스 업데이트..."
pacman -Sy --noconfirm
echo "✓ 업데이트 완료"
echo ""

# ============================================================================
# 4. Node.js 및 npm 설치
# ============================================================================
echo "[4/6] Node.js 및 npm 설치 중..."
echo "  설치 패키지: $NODE_PACKAGE (npm 자동 포함)"

# Node.js 패키지만 설치 (npm이 번들로 포함됨)
pacman -S --noconfirm --needed $NODE_PACKAGE

echo "✓ 설치 완료"
echo ""

# ============================================================================
# 5. npm 전역 패키지 경로 설정
# ============================================================================
echo "[5/6] npm 전역 패키지 경로 설정..."

NPM_GLOBAL_DIR="$HOME/.npm-global"

# 디렉토리 생성
if [ ! -d "$NPM_GLOBAL_DIR" ]; then
    mkdir -p "$NPM_GLOBAL_DIR"
    echo "✓ 전역 디렉토리 생성: $NPM_GLOBAL_DIR"
else
    echo "✓ 전역 디렉토리 이미 존재: $NPM_GLOBAL_DIR"
fi

# npm config 설정
npm config set prefix "$NPM_GLOBAL_DIR"
echo "✓ npm prefix 설정 완료"

# PATH 설정
SHELL_RC="$HOME/.zshrc"
if [ ! -f "$SHELL_RC" ]; then
    SHELL_RC="$HOME/.bashrc"
fi

if ! grep -q "\.npm-global/bin" "$SHELL_RC"; then
    echo "" >> "$SHELL_RC"
    echo "# npm 전역 패키지 PATH" >> "$SHELL_RC"
    echo "export PATH=\"\$HOME/.npm-global/bin:\$PATH\"" >> "$SHELL_RC"
    echo "✓ PATH 설정 추가: $SHELL_RC"
else
    echo "✓ PATH 설정 이미 존재"
fi

# 현재 세션에 PATH 적용
export PATH="$HOME/.npm-global/bin:$PATH"

echo ""

# ============================================================================
# 6. 설치 확인
# ============================================================================
echo "[6/6] 설치 확인..."

# 터미널 재로드 (현재 세션)
if [ -f "$SHELL_RC" ]; then
    source "$SHELL_RC"
fi

echo "Node.js 버전: $(node --version)"
echo "npm 버전: $(npm --version)"
echo "npm prefix: $(npm config get prefix)"
echo ""

# ============================================================================
# 완료 메시지
# ============================================================================
echo "======================================"
echo "✅ Node.js 및 npm 설치 완료!"
echo "======================================"
echo ""
echo "다음 단계:"
echo "1. 터미널을 재시작하거나 다음 명령어 실행:"
echo "   source ~/.zshrc  (또는 source ~/.bashrc)"
echo ""
echo "2. 전역 패키지 설치 예시:"
echo "   npm install -g @openai/codex"
echo "   npm install -g typescript"
echo "   npm install -g prettier"
echo ""
echo "3. 설치 확인:"
echo "   which npm"
echo "   npm list -g --depth=0"
echo ""

# ============================================================================
# 선택적: 추천 패키지 설치 제안
# ============================================================================
echo "======================================"
echo "추천 전역 패키지를 설치하시겠습니까?"
echo "======================================"
echo "다음 패키지가 설치됩니다:"
echo "  - @openai/codex (AI 코딩 도구)"
echo "  - typescript (TypeScript 컴파일러)"
echo "  - prettier (코드 포맷터)"
echo "  - eslint (JavaScript 린터)"
echo ""

read -p "설치하시겠습니까? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "추천 패키지 설치 중..."
    npm install -g @openai/codex typescript prettier eslint
    echo "✓ 추천 패키지 설치 완료"
    echo ""
    echo "설치된 전역 패키지 목록:"
    npm list -g --depth=0
fi

echo ""
echo "스크립트 실행 완료! 🎉"

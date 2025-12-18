#!/bin/bash
# ============================================================================
# Node.js PATH 진단 스크립트
# ============================================================================
# 목적: 현재 환경의 Node.js/npm PATH 설정 상태를 진단
# 사용법: ./check_node_path.sh
# ============================================================================

echo "=========================================="
echo "Node.js PATH 진단"
echo "=========================================="
echo ""

# ============================================================================
# 1. 기본 정보
# ============================================================================
echo "1. 현재 셸:"
echo "   $SHELL"
echo ""

echo "2. 환경:"
echo "   MSYSTEM: ${MSYSTEM:-없음}"
echo "   MSYS2_PATH_TYPE: ${MSYS2_PATH_TYPE:-기본값}"
echo ""

# ============================================================================
# 2. Node.js 및 npm 확인
# ============================================================================
echo "3. Node.js 경로:"
if command -v node &> /dev/null; then
    echo "   ✓ 발견: $(which node)"
    echo "   버전: $(node --version)"

    # 실제 실행 파일 경로 확인
    NODE_REAL=$(readlink -f "$(which node)" 2>/dev/null || which node)
    echo "   실제: $NODE_REAL"
else
    echo "   ✗ Node.js를 찾을 수 없습니다"
fi
echo ""

echo "4. npm 경로:"
if command -v npm &> /dev/null; then
    echo "   ✓ 발견: $(which npm)"
    echo "   버전: $(npm --version)"
    echo "   prefix: $(npm config get prefix)"
else
    echo "   ✗ npm을 찾을 수 없습니다"
fi
echo ""

# ============================================================================
# 3. PATH 분석
# ============================================================================
echo "5. 전체 PATH:"
echo "$PATH" | tr ':' '\n' | nl
echo ""

echo "6. Windows Node.js 경로 포함 여부:"
if echo "$PATH" | grep -q "Program Files/nodejs"; then
    echo "   ✓ Windows Node.js 경로가 PATH에 포함되어 있습니다"
    echo "   → /c/Program Files/nodejs"
else
    echo "   ✗ Windows Node.js 경로가 PATH에 없습니다"

    # Windows Node.js 설치 확인
    if [ -d "/c/Program Files/nodejs" ]; then
        echo ""
        echo "   📌 해결 방법:"
        echo "   Windows Node.js가 설치되어 있지만 PATH에 없습니다."
        echo ""
        echo "   옵션 1: 자동 수정 스크립트 실행"
        echo "   bash docs/msys2-setup/scripts/fix_windows_terminal_path.sh"
        echo ""
        echo "   옵션 2: 수동으로 ~/.zshrc에 추가"
        echo "   export PATH=\"/c/Program Files/nodejs:\$PATH\""
    else
        echo ""
        echo "   📌 해결 방법:"
        echo "   Windows Node.js가 설치되어 있지 않습니다."
        echo ""
        echo "   옵션 1: Windows Node.js 설치"
        echo "   https://nodejs.org/ 에서 다운로드"
        echo ""
        echo "   옵션 2: MSYS2 Node.js 설치"
        echo "   pacman -S mingw-w64-ucrt-x86_64-nodejs"
    fi
fi
echo ""

echo "7. MSYS2 Node.js 설치 여부:"
if [ -f "/ucrt64/bin/node" ] || [ -f "/mingw64/bin/node" ]; then
    echo "   ✓ MSYS2 Node.js가 설치되어 있습니다"

    if [ -f "/ucrt64/bin/node" ]; then
        echo "   경로: /ucrt64/bin/node"
        echo "   버전: $(/ucrt64/bin/node --version)"
    fi

    if [ -f "/mingw64/bin/node" ]; then
        echo "   경로: /mingw64/bin/node"
        echo "   버전: $(/mingw64/bin/node --version)"
    fi
else
    echo "   ✗ MSYS2 Node.js가 설치되지 않았습니다"
    echo ""
    echo "   📌 설치 방법:"
    echo "   pacman -S mingw-w64-ucrt-x86_64-nodejs"
fi
echo ""

# ============================================================================
# 4. 설정 파일 확인
# ============================================================================
echo "8. 셸 설정 파일 확인:"

ZSHRC="$HOME/.zshrc"
BASHRC="$HOME/.bashrc"

if [ -f "$ZSHRC" ]; then
    echo "   ✓ .zshrc 존재: $ZSHRC"

    if grep -q "Program Files/nodejs" "$ZSHRC"; then
        echo "     ✓ Windows Node.js PATH 설정 발견"
        echo "     라인:"
        grep -n "Program Files/nodejs" "$ZSHRC"
    else
        echo "     ✗ Windows Node.js PATH 설정 없음"
    fi
else
    echo "   ✗ .zshrc 없음"
fi

if [ -f "$BASHRC" ]; then
    echo "   ✓ .bashrc 존재: $BASHRC"

    if grep -q "Program Files/nodejs" "$BASHRC"; then
        echo "     ✓ Windows Node.js PATH 설정 발견"
        echo "     라인:"
        grep -n "Program Files/nodejs" "$BASHRC"
    else
        echo "     ✗ Windows Node.js PATH 설정 없음"
    fi
else
    echo "   ✗ .bashrc 없음"
fi
echo ""

# ============================================================================
# 5. 환경별 비교
# ============================================================================
echo "9. VS Code vs Windows Terminal 차이:"
echo ""

# Windows Terminal 여부 확인
if [ -n "$WT_SESSION" ]; then
    echo "   ✓ 현재 Windows Terminal에서 실행 중"
else
    echo "   ⚠️  Windows Terminal이 아닌 환경에서 실행 중"
    echo "   (VS Code 터미널 또는 다른 터미널)"
fi
echo ""

# ============================================================================
# 6. 요약 및 권장사항
# ============================================================================
echo "=========================================="
echo "진단 요약"
echo "=========================================="
echo ""

HAS_NODE=false
HAS_WINDOWS_NODE=false
HAS_MSYS2_NODE=false
HAS_PATH_CONFIG=false

# 상태 확인
if command -v node &> /dev/null; then
    HAS_NODE=true
fi

if [ -d "/c/Program Files/nodejs" ]; then
    HAS_WINDOWS_NODE=true
fi

if [ -f "/ucrt64/bin/node" ] || [ -f "/mingw64/bin/node" ]; then
    HAS_MSYS2_NODE=true
fi

if [ -f "$ZSHRC" ] && grep -q "Program Files/nodejs" "$ZSHRC"; then
    HAS_PATH_CONFIG=true
elif [ -f "$BASHRC" ] && grep -q "Program Files/nodejs" "$BASHRC"; then
    HAS_PATH_CONFIG=true
fi

# 상태별 권장사항
if [ "$HAS_NODE" = true ]; then
    echo "✅ 상태: 정상"
    echo "   Node.js와 npm이 정상적으로 작동합니다."
    echo ""
    echo "📌 다음 단계:"
    echo "   npm install -g @openai/codex"
else
    echo "❌ 상태: 문제 발견"
    echo ""

    if [ "$HAS_WINDOWS_NODE" = true ] && [ "$HAS_PATH_CONFIG" = false ]; then
        echo "🔧 권장 조치:"
        echo "   Windows Node.js가 설치되어 있지만 PATH 설정이 없습니다."
        echo ""
        echo "   자동 수정:"
        echo "   bash docs/msys2-setup/scripts/fix_windows_terminal_path.sh"
        echo ""
    elif [ "$HAS_WINDOWS_NODE" = false ] && [ "$HAS_MSYS2_NODE" = false ]; then
        echo "🔧 권장 조치:"
        echo "   Node.js가 설치되어 있지 않습니다."
        echo ""
        echo "   옵션 1: Windows Node.js 설치 (권장)"
        echo "   https://nodejs.org/"
        echo ""
        echo "   옵션 2: MSYS2 Node.js 설치"
        echo "   bash docs/msys2-setup/scripts/install_nodejs_npm.sh"
        echo ""
    elif [ "$HAS_PATH_CONFIG" = true ]; then
        echo "🔧 권장 조치:"
        echo "   PATH 설정은 있지만 적용되지 않았습니다."
        echo ""
        echo "   1. 설정 다시 로드:"
        echo "   source ~/.zshrc"
        echo ""
        echo "   2. 또는 터미널 재시작"
        echo ""
    fi
fi

echo "=========================================="
echo "진단 완료"
echo "=========================================="
echo ""
echo "상세 가이드: docs/msys2-setup/guides/windows_terminal_path_fix.md"

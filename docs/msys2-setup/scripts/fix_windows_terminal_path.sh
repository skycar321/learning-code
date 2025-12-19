#!/bin/bash
# ============================================================================
# Windows Terminal MSYS2 PATH 자동 수정 스크립트
# ============================================================================
# 목적: Windows Terminal의 MSYS2에서 Windows Node.js를 사용할 수 있도록 PATH 설정
# 사용법: ./fix_windows_terminal_path.sh
# ============================================================================

set -e

echo "======================================"
echo "Windows Terminal PATH 자동 설정"
echo "======================================"
echo ""

# ============================================================================
# 1. 환경 확인
# ============================================================================
echo "[1/5] 환경 확인..."

SHELL_RC="$HOME/.zshrc"
if [ ! -f "$SHELL_RC" ]; then
    SHELL_RC="$HOME/.bashrc"
    echo "✓ 사용 중인 셸: bash"
else
    echo "✓ 사용 중인 셸: zsh"
fi

echo "✓ 설정 파일: $SHELL_RC"
echo ""

# ============================================================================
# 2. 현재 PATH 진단
# ============================================================================
echo "[2/5] 현재 PATH 진단..."

echo "현재 Node.js 상태:"
if command -v node &> /dev/null; then
    echo "  ✓ Node.js 발견: $(which node)"
    echo "  버전: $(node --version)"
    HAS_NODE=true
else
    echo "  ✗ Node.js를 찾을 수 없습니다"
    HAS_NODE=false
fi

echo ""
echo "현재 npm 상태:"
if command -v npm &> /dev/null; then
    echo "  ✓ npm 발견: $(which npm)"
    echo "  버전: $(npm --version)"
    HAS_NPM=true
else
    echo "  ✗ npm을 찾을 수 없습니다"
    HAS_NPM=false
fi

echo ""

# Windows Node.js 경로 확인
WIN_NODE_PATH="/c/Program Files/nodejs"
if [ -d "$WIN_NODE_PATH" ]; then
    echo "✓ Windows Node.js가 설치되어 있습니다: $WIN_NODE_PATH"
    HAS_WIN_NODE=true
else
    echo "✗ Windows Node.js를 찾을 수 없습니다: $WIN_NODE_PATH"
    HAS_WIN_NODE=false
fi

echo ""

# ============================================================================
# 3. PATH 설정 필요 여부 확인
# ============================================================================
echo "[3/5] PATH 설정 확인..."

NEEDS_FIX=false

# Windows Node.js 경로가 PATH에 있는지 확인
if echo "$PATH" | grep -q "Program Files/nodejs"; then
    echo "✓ Windows Node.js 경로가 이미 PATH에 있습니다"
else
    echo "✗ Windows Node.js 경로가 PATH에 없습니다"
    NEEDS_FIX=true
fi

# .zshrc에 이미 설정이 있는지 확인
if grep -q "Program Files/nodejs" "$SHELL_RC"; then
    echo "✓ $SHELL_RC에 Windows Node.js 설정이 있습니다"

    # 하지만 현재 PATH에 없다면 설정 적용이 안 된 것
    if [ "$NEEDS_FIX" = true ]; then
        echo "⚠️  설정은 있지만 PATH에 적용되지 않았습니다"
        echo "   → source $SHELL_RC를 실행하거나 터미널을 재시작하세요"
    fi
else
    echo "✗ $SHELL_RC에 Windows Node.js 설정이 없습니다"
    NEEDS_FIX=true
fi

echo ""

# ============================================================================
# 4. PATH 설정 추가
# ============================================================================
if [ "$NEEDS_FIX" = true ] && [ "$HAS_WIN_NODE" = true ]; then
    echo "[4/5] PATH 설정 추가 중..."

    # 백업 생성
    BACKUP_FILE="$SHELL_RC.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$SHELL_RC" "$BACKUP_FILE"
    echo "✓ 백업 생성: $BACKUP_FILE"

    # Windows PATH 추가
    cat >> "$SHELL_RC" << 'EOF'

# ============================================
# Windows PATH 통합 (Windows Terminal용)
# ============================================

# Windows Node.js 경로
export PATH="/c/Program Files/nodejs:$PATH"

# npm 전역 패키지 경로
export PATH="$APPDATA/npm:$PATH"

# 선택사항: 기타 Windows 도구
# export PATH="/c/Program Files/Git/cmd:$PATH"

EOF

    echo "✓ Windows PATH 설정을 $SHELL_RC에 추가했습니다"
    echo ""

    # 현재 세션에 적용
    export PATH="/c/Program Files/nodejs:$PATH"
    export PATH="$APPDATA/npm:$PATH"

    echo "✓ 현재 세션에 PATH 적용 완료"
    echo ""
else
    echo "[4/5] PATH 설정 추가 건너뛰기..."

    if [ "$HAS_WIN_NODE" = false ]; then
        echo "⚠️  Windows Node.js가 설치되어 있지 않습니다"
        echo "   다음 중 하나를 선택하세요:"
        echo "   1. Windows Node.js 설치: https://nodejs.org/"
        echo "   2. MSYS2 Node.js 설치: pacman -S mingw-w64-ucrt-x86_64-nodejs"
    else
        echo "✓ 이미 PATH 설정이 완료되어 있습니다"
    fi

    echo ""
fi

# ============================================================================
# 5. 설치 확인
# ============================================================================
echo "[5/5] 설치 확인..."

# 설정 다시 로드
if [ -f "$SHELL_RC" ]; then
    source "$SHELL_RC" 2>/dev/null || true
fi

echo ""
echo "최종 상태:"

if command -v node &> /dev/null; then
    echo "  ✓ Node.js: $(node --version)"
    echo "  경로: $(which node)"
else
    echo "  ✗ Node.js를 찾을 수 없습니다"
fi

if command -v npm &> /dev/null; then
    echo "  ✓ npm: $(npm --version)"
    echo "  경로: $(which npm)"
else
    echo "  ✗ npm을 찾을 수 없습니다"
fi

echo ""

# ============================================================================
# 완료 메시지
# ============================================================================
echo "======================================"
echo "✅ 설정 완료!"
echo "======================================"
echo ""

if [ "$NEEDS_FIX" = true ] && [ "$HAS_WIN_NODE" = true ]; then
    echo "⚠️  중요: 다음 단계를 수행하세요"
    echo ""
    echo "1. 현재 터미널에서 즉시 사용:"
    echo "   source $SHELL_RC"
    echo ""
    echo "2. Windows Terminal 재시작 (권장)"
    echo "   - Windows Terminal을 완전히 종료"
    echo "   - 다시 시작하여 MSYS2 탭 열기"
    echo ""
    echo "3. 설치 확인:"
    echo "   node --version"
    echo "   npm --version"
    echo "   npm install -g @openai/codex"
    echo ""
elif command -v npm &> /dev/null; then
    echo "✓ Windows Terminal에서 npm을 사용할 수 있습니다!"
    echo ""
    echo "다음 명령어로 Codex 설치 가능:"
    echo "   npm install -g @openai/codex"
    echo ""
fi

# ============================================================================
# 추가 정보
# ============================================================================
echo "======================================"
echo "추가 정보"
echo "======================================"
echo ""
echo "상세 가이드: docs/msys2-setup/guides/windows_terminal_path_fix.md"
echo ""
echo "문제가 계속되면:"
echo "1. 진단 스크립트 실행:"
echo "   bash ~/check-node-path.sh"
echo ""
echo "2. Windows Terminal 프로필 설정:"
echo "   Ctrl+, > 설정 > JSON 파일 열기"
echo "   MSYS2 프로필에 추가:"
echo '   "environment": { "MSYS2_PATH_TYPE": "inherit" }'
echo ""

echo "스크립트 실행 완료! 🎉"

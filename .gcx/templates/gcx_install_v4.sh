#!/bin/bash
# GCX v4.0 Installation/Upgrade Script
# v3.5 → v4.0 자동 마이그레이션
#
# WHEN TO USE:
#   - 처음 GCX v4.0 설치할 때
#   - v3.5에서 v4.0으로 업그레이드
#   - Codex reasoning=xhigh 문제 자동 수정
#   - 디렉토리 구조 재생성
#
# WHAT IT DOES:
#   1. 환경 확인 (MSYS2, Locale)
#   2. Codex config 백업
#   3. reasoning=xhigh → high 자동 수정
#   4. .gcx 디렉토리 구조 생성
#   5. 템플릿 스크립트 확인
#   6. 실행 권한 부여
#   7. 빠른 테스트 실행
#   8. 최종 확인
#
# USAGE:
#   bash .gcx/templates/gcx_install_v4.sh
#
# DURATION: ~1-2분 (테스트 포함)
# BACKUP: ~/.codex/config.toml 자동 백업

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

echo -e "${MAGENTA}╔═══════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║   GCX v4.0 Installation & Upgrade         ║${NC}"
echo -e "${MAGENTA}╚═══════════════════════════════════════════╝${NC}"
echo ""

STEP=1
TOTAL_STEPS=8

# ==========================================
# Step 1: 환경 확인
# ==========================================
echo -e "${CYAN}[$STEP/$TOTAL_STEPS] Checking environment...${NC}"
STEP=$((STEP + 1))

# MSYS2 확인
if [ -n "${MSYS:-}" ] || [ -n "${MSYSTEM:-}" ]; then
    if [ "${MSYSTEM:-}" = "UCRT64" ]; then
        echo -e "  ${GREEN}✅ MSYS2 UCRT64 detected (Recommended!)${NC}"
        MSYS2_AVAILABLE=true
    elif [ "${MSYSTEM:-}" = "MINGW64" ]; then
        echo -e "  ${GREEN}✅ MSYS2 MINGW64 detected${NC}"
        echo -e "     ${CYAN}💡 Tip: UCRT64 is recommended for better Unicode support${NC}"
        MSYS2_AVAILABLE=true
    else
        echo -e "  ${GREEN}✅ MSYS2 detected ($MSYSTEM)${NC}"
        MSYS2_AVAILABLE=true
    fi
else
    echo -e "  ${YELLOW}⚠️  MSYS2 not detected${NC}"
    echo -e "     v4.0 features may not work without MSYS2"
    echo -e "     Download: https://www.msys2.org/"
    MSYS2_AVAILABLE=false
fi

# Locale 확인
if [ "${LANG:-}" != "ko_KR.UTF-8" ]; then
    echo -e "  ${YELLOW}⚠️  Setting LANG=ko_KR.UTF-8${NC}"
    export LANG=ko_KR.UTF-8
    export LC_ALL=ko_KR.UTF-8
fi

echo ""

# ==========================================
# Step 2: Codex Config 백업
# ==========================================
echo -e "${CYAN}[$STEP/$TOTAL_STEPS] Backing up Codex config...${NC}"
STEP=$((STEP + 1))

if [ -f ~/.codex/config.toml ]; then
    BACKUP_FILE=~/.codex/config.toml.backup_$(date +%Y%m%d_%H%M%S)
    cp ~/.codex/config.toml "$BACKUP_FILE"
    echo -e "  ${GREEN}✅ Backup created: $BACKUP_FILE${NC}"
else
    echo -e "  ${YELLOW}⚠️  No Codex config found${NC}"
fi

echo ""

# ==========================================
# Step 3: Codex Reasoning Effort 수정
# ==========================================
echo -e "${CYAN}[$STEP/$TOTAL_STEPS] Fixing Codex reasoning effort...${NC}"
STEP=$((STEP + 1))

if [ -f ~/.codex/config.toml ]; then
    REASONING=$(grep "model_reasoning_effort" ~/.codex/config.toml | cut -d'"' -f2 2>/dev/null || echo "")

    if [ "$REASONING" = "xhigh" ]; then
        echo -e "  ${YELLOW}⚠️  Found reasoning=xhigh (NOT SUPPORTED!)${NC}"
        sed -i 's/model_reasoning_effort = "xhigh"/model_reasoning_effort = "high"/' ~/.codex/config.toml
        echo -e "  ${GREEN}✅ Fixed: xhigh → high${NC}"
    elif [ "$REASONING" = "high" ] || [ "$REASONING" = "medium" ] || [ "$REASONING" = "low" ]; then
        echo -e "  ${GREEN}✅ Already correct: reasoning=$REASONING${NC}"
    else
        echo -e "  ${YELLOW}⚠️  Unknown reasoning value: $REASONING${NC}"
    fi
else
    echo -e "  ${YELLOW}⚠️  Codex config not found - skipping${NC}"
fi

echo ""

# ==========================================
# Step 4: 디렉토리 구조 생성
# ==========================================
echo -e "${CYAN}[$STEP/$TOTAL_STEPS] Creating GCX v4.0 directory structure...${NC}"
STEP=$((STEP + 1))

DIRS=(
    ".gcx"
    ".gcx/00_requirements"
    ".gcx/01_planning"
    ".gcx/02_implementation"
    ".gcx/03_verification"
    ".gcx/pipeline"
    ".gcx/pipeline/logs"
    ".gcx/output"
    ".gcx/review"
    ".gcx/templates"
    ".gcx/tests"
)

for dir in "${DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo -e "  ${GREEN}✅ Created: $dir${NC}"
    else
        echo -e "  ${BLUE}ℹ️  Already exists: $dir${NC}"
    fi
done

echo ""

# ==========================================
# Step 5: 템플릿 스크립트 확인
# ==========================================
echo -e "${CYAN}[$STEP/$TOTAL_STEPS] Checking template scripts...${NC}"
STEP=$((STEP + 1))

REQUIRED_TEMPLATES=(
    "gcx_invoke_v4.sh"
    "preflight_check_v4.sh"
    "pipeline_realtime_stream.sh"
    "gcx_quick_test.sh"
    "gcx_cleanup.sh"
    "gcx_status.sh"
    "gcx_install_v4.sh"
)

MISSING_COUNT=0
for template in "${REQUIRED_TEMPLATES[@]}"; do
    if [ ! -f ".gcx/templates/$template" ]; then
        echo -e "  ${YELLOW}⚠️  Missing: $template${NC}"
        MISSING_COUNT=$((MISSING_COUNT + 1))
    fi
done

if [ $MISSING_COUNT -eq 0 ]; then
    echo -e "  ${GREEN}✅ All template scripts present${NC}"
else
    echo -e "  ${YELLOW}⚠️  $MISSING_COUNT template(s) missing${NC}"
    echo -e "     Please ensure all v4.0 templates are in .gcx/templates/"
fi

echo ""

# ==========================================
# Step 6: 실행 권한 부여
# ==========================================
echo -e "${CYAN}[$STEP/$TOTAL_STEPS] Setting execute permissions...${NC}"
STEP=$((STEP + 1))

chmod +x .gcx/templates/*.sh 2>/dev/null || true
chmod +x .gcx/tests/*.sh 2>/dev/null || true

echo -e "  ${GREEN}✅ Execute permissions set${NC}"
echo ""

# ==========================================
# Step 7: 테스트 실행
# ==========================================
echo -e "${CYAN}[$STEP/$TOTAL_STEPS] Running tests...${NC}"
STEP=$((STEP + 1))

if [ -f ".gcx/templates/gcx_quick_test.sh" ]; then
    echo -e "  ${BLUE}ℹ️  Running quick test...${NC}"
    echo ""
    if bash .gcx/templates/gcx_quick_test.sh; then
        echo ""
        echo -e "  ${GREEN}✅ Quick test passed${NC}"
    else
        echo ""
        echo -e "  ${YELLOW}⚠️  Some tests failed (check output above)${NC}"
    fi
else
    echo -e "  ${YELLOW}⚠️  Quick test script not found - skipping${NC}"
fi

echo ""

# ==========================================
# Step 8: 최종 확인
# ==========================================
echo -e "${CYAN}[$STEP/$TOTAL_STEPS] Final verification...${NC}"
STEP=$((STEP + 1))

# Codex config 최종 확인
if [ -f ~/.codex/config.toml ]; then
    FINAL_REASONING=$(grep "model_reasoning_effort" ~/.codex/config.toml | cut -d'"' -f2 2>/dev/null || echo "unknown")
    if [ "$FINAL_REASONING" = "high" ] || [ "$FINAL_REASONING" = "medium" ] || [ "$FINAL_REASONING" = "low" ]; then
        echo -e "  ${GREEN}✅ Codex config: reasoning=$FINAL_REASONING${NC}"
    else
        echo -e "  ${YELLOW}⚠️  Codex config: reasoning=$FINAL_REASONING${NC}"
    fi
fi

# 디렉토리 구조 확인
if [ -d ".gcx/templates" ] && [ -d ".gcx/tests" ] && [ -d ".gcx/pipeline/logs" ]; then
    echo -e "  ${GREEN}✅ Directory structure complete${NC}"
else
    echo -e "  ${YELLOW}⚠️  Some directories missing${NC}"
fi

echo ""

# ==========================================
# Summary
# ==========================================
echo -e "${MAGENTA}╔═══════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║   Installation Complete!                  ║${NC}"
echo -e "${MAGENTA}╚═══════════════════════════════════════════╝${NC}"
echo ""

echo -e "${GREEN}✅ GCX v4.0 is ready to use!${NC}"
echo ""
echo -e "${BLUE}What changed from v3.5:${NC}"
echo -e "  1. ✅ Codex Korean output support (MSYS2)"
echo -e "  2. ✅ Named Pipes real-time streaming"
echo -e "  3. ✅ Real-time logging with tee"
echo -e "  4. ✅ Codex reasoning effort fixed (high)"
echo -e "  5. ✅ New utility scripts"
echo ""

echo -e "${CYAN}Next Steps:${NC}"
echo -e "  1. Check status:     ${YELLOW}bash .gcx/templates/gcx_status.sh${NC}"
echo -e "  2. Run quick test:   ${YELLOW}bash .gcx/templates/gcx_quick_test.sh${NC}"
echo -e "  3. Start using:      ${YELLOW}/nam:gcx-query-v4 \"Your question\"${NC}"
echo ""

echo -e "${BLUE}📚 Documentation:${NC}"
echo -e "  - Quick Guide:  .gcx/README_v4.md"
echo -e "  - Full Spec:    C:/Users/Nam/.gemini/GEMINI_v4.md"
echo ""

if ! $MSYS2_AVAILABLE; then
    echo -e "${YELLOW}⚠️  Recommendation:${NC}"
    echo -e "   Install MSYS2 for full v4.0 features (Korean output, Named Pipes)"
    echo -e "   Download: https://www.msys2.org/"
    echo ""
fi

echo -e "${GREEN}Happy coding with GCX v4.0! 🚀${NC}"

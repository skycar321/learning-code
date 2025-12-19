#!/bin/bash
# GCX v4.0 Status Script
# 현재 GCX 환경 상태 및 통계 표시
#
# WHEN TO USE:
#   - 매일 작업 시작 시 (하루 1회)
#   - 환경 변경 후 확인
#   - 다른 스크립트 실행 전 사전 점검
#
# WHAT IT DOES:
#   1. 환경 정보 (OS, Shell, MSYS2, Locale)
#   2. CLI 도구 설치 상태 (Claude, Codex, Gemini)
#   3. .gcx 디렉토리 구조 및 파일 통계
#   4. 최근 로그 활동
#   5. Requirements 현황
#   6. 테스트 결과
#   7. 시스템 권장사항
#
# USAGE:
#   bash .gcx/templates/gcx_status.sh
#
# DURATION: ~5초

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

echo -e "${MAGENTA}╔════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║     GCX v4.0 Status Dashboard          ║${NC}"
echo -e "${MAGENTA}╚════════════════════════════════════════╝${NC}"
echo ""

# ==========================================
# 1. 환경 정보
# ==========================================
echo -e "${BLUE}━━━ 1. Environment ━━━${NC}"
echo -e "  ${CYAN}OS:${NC}       $(uname -s)"
echo -e "  ${CYAN}Shell:${NC}    $SHELL"
if [ -n "${MSYS:-}" ] || [ -n "${MSYSTEM:-}" ]; then
    if [ "${MSYSTEM:-}" = "UCRT64" ]; then
        echo -e "  ${CYAN}MSYS2:${NC}    ${GREEN}✅ $MSYSTEM (Recommended!)${NC}"
    elif [ "${MSYSTEM:-}" = "MINGW64" ]; then
        echo -e "  ${CYAN}MSYS2:${NC}    ${GREEN}✅ $MSYSTEM${NC}"
        echo -e "            ${CYAN}💡 Consider using UCRT64${NC}"
    else
        echo -e "  ${CYAN}MSYS2:${NC}    ${GREEN}✅ $MSYSTEM${NC}"
    fi
else
    echo -e "  ${CYAN}MSYS2:${NC}    ${YELLOW}⚠️  Not detected${NC}"
fi
echo -e "  ${CYAN}LANG:${NC}     ${LANG:-'Not set'}"
echo -e "  ${CYAN}LC_ALL:${NC}   ${LC_ALL:-'Not set'}"
echo ""

# ==========================================
# 2. CLI 도구
# ==========================================
echo -e "${BLUE}━━━ 2. CLI Tools ━━━${NC}"

if command -v claude >/dev/null 2>&1; then
    CLAUDE_VERSION=$(claude --version 2>&1 | head -1 || echo "Unknown")
    echo -e "  ${CYAN}Claude:${NC}   ${GREEN}✅ Installed${NC}"
    echo -e "            $CLAUDE_VERSION"
else
    echo -e "  ${CYAN}Claude:${NC}   ${RED}❌ Not found${NC}"
fi

if command -v codex >/dev/null 2>&1; then
    CODEX_VERSION=$(codex --version 2>&1 | head -1 || echo "Unknown")
    echo -e "  ${CYAN}Codex:${NC}    ${GREEN}✅ Installed${NC}"
    echo -e "            $CODEX_VERSION"

    # Codex config 확인
    if [ -f ~/.codex/config.toml ]; then
        REASONING=$(grep "model_reasoning_effort" ~/.codex/config.toml | cut -d'"' -f2 2>/dev/null || echo "unknown")
        if [ "$REASONING" = "xhigh" ]; then
            echo -e "            ${RED}⚠️  reasoning=$REASONING (NOT SUPPORTED!)${NC}"
        else
            echo -e "            ${GREEN}reasoning=$REASONING${NC}"
        fi
    fi
else
    echo -e "  ${CYAN}Codex:${NC}    ${RED}❌ Not found${NC}"
fi

if command -v gemini >/dev/null 2>&1; then
    GEMINI_VERSION=$(gemini --version 2>&1 | head -1 || echo "Unknown")
    echo -e "  ${CYAN}Gemini:${NC}   ${GREEN}✅ Installed${NC}"
    echo -e "            $GEMINI_VERSION"
else
    echo -e "  ${CYAN}Gemini:${NC}   ${YELLOW}ℹ️  Not found (optional)${NC}"
fi
echo ""

# ==========================================
# 3. GCX 디렉토리 구조
# ==========================================
echo -e "${BLUE}━━━ 3. GCX Directory Structure ━━━${NC}"

if [ -d ".gcx" ]; then
    TOTAL_SIZE=$(du -sh .gcx 2>/dev/null | cut -f1)
    echo -e "  ${CYAN}Total Size:${NC} $TOTAL_SIZE"
    echo ""

    # 각 디렉토리별 통계
    for dir in 00_requirements pipeline/logs output templates tests; do
        if [ -d ".gcx/$dir" ]; then
            FILE_COUNT=$(find ".gcx/$dir" -type f 2>/dev/null | wc -l)
            DIR_SIZE=$(du -sh ".gcx/$dir" 2>/dev/null | cut -f1)
            echo -e "  ${CYAN}$dir${NC}"
            echo -e "    Files: $FILE_COUNT, Size: $DIR_SIZE"
        fi
    done
else
    echo -e "  ${RED}❌ .gcx directory not found${NC}"
    echo -e "     Run: mkdir -p .gcx/{00_requirements,pipeline/logs,output,templates,tests}"
fi
echo ""

# ==========================================
# 4. 최근 작업 (logs)
# ==========================================
echo -e "${BLUE}━━━ 4. Recent Activities ━━━${NC}"

if [ -d ".gcx/pipeline/logs" ]; then
    LOG_COUNT=$(find .gcx/pipeline/logs -type f -name "*.log" 2>/dev/null | wc -l)
    if [ "$LOG_COUNT" -gt 0 ]; then
        echo -e "  ${CYAN}Total log files:${NC} $LOG_COUNT"
        echo ""
        echo -e "  ${CYAN}Recent logs (last 5):${NC}"
        ls -1t .gcx/pipeline/logs/*.log 2>/dev/null | head -5 | while read log; do
            BASENAME=$(basename "$log")
            SIZE=$(du -h "$log" | cut -f1)
            echo -e "    • $BASENAME ($SIZE)"
        done
    else
        echo -e "  ${YELLOW}ℹ️  No log files yet${NC}"
    fi
else
    echo -e "  ${YELLOW}ℹ️  Log directory not found${NC}"
fi
echo ""

# ==========================================
# 5. Requirements (요구사항)
# ==========================================
echo -e "${BLUE}━━━ 5. Requirements ━━━${NC}"

if [ -d ".gcx/00_requirements" ]; then
    REQ_COUNT=$(find .gcx/00_requirements -type f -name "*.md" 2>/dev/null | wc -l)
    if [ "$REQ_COUNT" -gt 0 ]; then
        echo -e "  ${CYAN}Total requirements:${NC} $REQ_COUNT"
        echo ""
        echo -e "  ${CYAN}Recent requirements (last 3):${NC}"
        ls -1t .gcx/00_requirements/*.md 2>/dev/null | head -3 | while read req; do
            BASENAME=$(basename "$req")
            echo -e "    • $BASENAME"
        done
    else
        echo -e "  ${YELLOW}ℹ️  No requirements saved yet${NC}"
    fi
else
    echo -e "  ${YELLOW}ℹ️  Requirements directory not found${NC}"
fi
echo ""

# ==========================================
# 6. 테스트 결과
# ==========================================
echo -e "${BLUE}━━━ 6. Test Results ━━━${NC}"

# Codex 한글 출력 테스트 결과 확인
if [ -f ".gcx/tests/codex_output.txt" ]; then
    if grep -qE '[가-힣]' .gcx/tests/codex_output.txt 2>/dev/null; then
        echo -e "  ${CYAN}Codex Korean Output:${NC} ${GREEN}✅ Working${NC}"
    else
        echo -e "  ${CYAN}Codex Korean Output:${NC} ${YELLOW}⚠️  Not tested or failed${NC}"
    fi
else
    echo -e "  ${CYAN}Codex Korean Output:${NC} ${YELLOW}ℹ️  Not tested yet${NC}"
    echo -e "     Run: bash .gcx/tests/test_codex_korean_v2.sh"
fi

# MSYS2 인코딩 테스트 결과
if [ -f ".gcx/tests/korean_test.txt" ]; then
    if grep -qE '[가-힣]' .gcx/tests/korean_test.txt 2>/dev/null; then
        echo -e "  ${CYAN}MSYS2 Encoding:${NC}      ${GREEN}✅ Working${NC}"
    else
        echo -e "  ${CYAN}MSYS2 Encoding:${NC}      ${YELLOW}⚠️  Failed${NC}"
    fi
else
    echo -e "  ${CYAN}MSYS2 Encoding:${NC}      ${YELLOW}ℹ️  Not tested yet${NC}"
    echo -e "     Run: bash .gcx/tests/test_msys2_encoding.sh"
fi
echo ""

# ==========================================
# 7. 빠른 액션
# ==========================================
echo -e "${BLUE}━━━ 7. Quick Actions ━━━${NC}"
echo -e "  ${CYAN}Test:${NC}     bash .gcx/templates/gcx_quick_test.sh"
echo -e "  ${CYAN}Cleanup:${NC}  bash .gcx/templates/gcx_cleanup.sh --all"
echo -e "  ${CYAN}Check:${NC}    bash .gcx/templates/preflight_check_v4.sh"
echo -e "  ${CYAN}Invoke:${NC}   bash .gcx/templates/gcx_invoke_v4.sh \"Task\""
echo ""

# ==========================================
# 8. 시스템 권장사항
# ==========================================
echo -e "${BLUE}━━━ 8. Recommendations ━━━${NC}"

RECOMMENDATIONS=()

if [ -z "${MSYS:-}" ] && [ -z "${MSYSTEM:-}" ]; then
    RECOMMENDATIONS+=("🔧 Use MSYS2 for Korean output support")
fi

if [ "${LANG:-}" != "ko_KR.UTF-8" ]; then
    RECOMMENDATIONS+=("🔧 Set LANG=ko_KR.UTF-8 for proper encoding")
fi

if [ -f ~/.codex/config.toml ]; then
    REASONING=$(grep "model_reasoning_effort" ~/.codex/config.toml | cut -d'"' -f2 2>/dev/null || echo "")
    if [ "$REASONING" = "xhigh" ]; then
        RECOMMENDATIONS+=("🔧 Fix Codex reasoning: sed -i 's/xhigh/high/' ~/.codex/config.toml")
    fi
fi

if [ ${#RECOMMENDATIONS[@]} -eq 0 ]; then
    echo -e "  ${GREEN}✅ No recommendations - system looks good!${NC}"
else
    for rec in "${RECOMMENDATIONS[@]}"; do
        echo -e "  $rec"
    done
fi

echo ""
echo -e "${MAGENTA}╚════════════════════════════════════════╝${NC}"

#!/bin/bash
# GCX v4.0 Quick Test Script
# 빠른 환경 테스트 및 검증
#
# WHEN TO USE:
#   - 설치 직후 환경 확인
#   - 문제가 의심될 때 빠른 진단
#   - 매주 월요일 환경 체크
#
# WHAT IT DOES:
#   1. MSYS2 환경 확인 (UCRT64/MINGW64)
#   2. Locale 설정 검증
#   3. Codex reasoning 설정 확인
#   4. CLI 도구 설치 확인
#   5. Codex 한글 출력 간단 테스트
#
# USAGE:
#   bash .gcx/templates/gcx_quick_test.sh
#
# DURATION: ~30초 (Codex 테스트 포함)
# PASS/FAIL: 5개 항목 자동 평가

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  GCX v4.0 Quick Test${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

PASS=0
FAIL=0

# Test 1: MSYS2 환경
echo -e "${CYAN}[Test 1/5] MSYS2 Environment${NC}"
if [ -n "${MSYS:-}" ] || [ -n "${MSYSTEM:-}" ]; then
    if [ "${MSYSTEM:-}" = "UCRT64" ]; then
        echo -e "  ${GREEN}✅ PASS${NC} - MSYS2 UCRT64 detected (Recommended!)"
        PASS=$((PASS + 1))
    elif [ "${MSYSTEM:-}" = "MINGW64" ]; then
        echo -e "  ${GREEN}✅ PASS${NC} - MSYS2 MINGW64 detected"
        echo -e "      ${CYAN}💡 Tip: UCRT64 is recommended for better Unicode support${NC}"
        PASS=$((PASS + 1))
    else
        echo -e "  ${GREEN}✅ PASS${NC} - MSYS2 detected ($MSYSTEM)"
        PASS=$((PASS + 1))
    fi
else
    echo -e "  ${YELLOW}⚠️  WARN${NC} - Not in MSYS2 (Korean output may not work)"
    FAIL=$((FAIL + 1))
fi
echo ""

# Test 2: Locale
echo -e "${CYAN}[Test 2/5] Locale Configuration${NC}"
if [ "${LANG:-}" = "ko_KR.UTF-8" ] && [ "${LC_ALL:-}" = "ko_KR.UTF-8" ]; then
    echo -e "  ${GREEN}✅ PASS${NC} - Locale properly configured"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}❌ FAIL${NC} - LANG=$LANG, LC_ALL=$LC_ALL"
    echo -e "      Fix: export LANG=ko_KR.UTF-8 && export LC_ALL=ko_KR.UTF-8"
    FAIL=$((FAIL + 1))
fi
echo ""

# Test 3: Codex Config
echo -e "${CYAN}[Test 3/5] Codex Configuration${NC}"
if [ -f ~/.codex/config.toml ]; then
    REASONING=$(grep "model_reasoning_effort" ~/.codex/config.toml | cut -d'"' -f2)
    if [ "$REASONING" = "xhigh" ]; then
        echo -e "  ${RED}❌ FAIL${NC} - reasoning=$REASONING (NOT SUPPORTED!)"
        echo -e "      Fix: sed -i 's/xhigh/high/' ~/.codex/config.toml"
        FAIL=$((FAIL + 1))
    elif [ "$REASONING" = "high" ] || [ "$REASONING" = "medium" ] || [ "$REASONING" = "low" ]; then
        echo -e "  ${GREEN}✅ PASS${NC} - reasoning=$REASONING"
        PASS=$((PASS + 1))
    else
        echo -e "  ${YELLOW}⚠️  WARN${NC} - reasoning=$REASONING (unusual value)"
        FAIL=$((FAIL + 1))
    fi
else
    echo -e "  ${YELLOW}⚠️  WARN${NC} - ~/.codex/config.toml not found"
    FAIL=$((FAIL + 1))
fi
echo ""

# Test 4: CLI Tools
echo -e "${CYAN}[Test 4/5] CLI Tools${NC}"
CLI_OK=true
if command -v claude >/dev/null 2>&1; then
    echo -e "  ${GREEN}✅${NC} Claude CLI found"
else
    echo -e "  ${RED}❌${NC} Claude CLI not found"
    CLI_OK=false
fi

if command -v codex >/dev/null 2>&1; then
    echo -e "  ${GREEN}✅${NC} Codex CLI found"
else
    echo -e "  ${RED}❌${NC} Codex CLI not found"
    CLI_OK=false
fi

if $CLI_OK; then
    PASS=$((PASS + 1))
else
    FAIL=$((FAIL + 1))
fi
echo ""

# Test 5: Codex Korean Output (간단한 테스트)
echo -e "${CYAN}[Test 5/5] Codex Korean Output (Quick)${NC}"
if command -v codex >/dev/null 2>&1 && [ -n "${MSYS:-}" ] || [ -n "${MSYSTEM:-}" ]; then
    echo -e "  ${BLUE}ℹ️${NC}  Testing Codex Korean output..."

    export NO_COLOR=1
    TEST_PROMPT="간단히 '안녕하세요'라고 한글로 답변해주세요. (한 줄만)"

    if timeout 30s codex exec -m "gpt-5.1-codex" "$TEST_PROMPT" > /tmp/gcx_quick_test_output.txt 2>&1; then
        if grep -qE '[가-힣]' /tmp/gcx_quick_test_output.txt 2>/dev/null; then
            echo -e "  ${GREEN}✅ PASS${NC} - Codex Korean output working!"
            echo -e "      Sample: $(grep -oE '[가-힣]+' /tmp/gcx_quick_test_output.txt | head -1)"
            PASS=$((PASS + 1))
        else
            echo -e "  ${YELLOW}⚠️  WARN${NC} - No Korean detected in output"
            FAIL=$((FAIL + 1))
        fi
    else
        echo -e "  ${RED}❌ FAIL${NC} - Codex execution failed or timed out"
        FAIL=$((FAIL + 1))
    fi

    rm -f /tmp/gcx_quick_test_output.txt
else
    echo -e "  ${YELLOW}⚠️  SKIP${NC} - Codex not available or not in MSYS2"
    FAIL=$((FAIL + 1))
fi
echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Test Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "  ${GREEN}Passed:${NC} $PASS / 5"
echo -e "  ${RED}Failed:${NC} $FAIL / 5"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed! GCX v4.0 ready to use.${NC}"
    EXIT_CODE=0
elif [ $FAIL -le 2 ]; then
    echo -e "${YELLOW}⚠️  Some tests failed, but GCX may still work.${NC}"
    EXIT_CODE=0
else
    echo -e "${RED}❌ Multiple tests failed. Please fix issues before using GCX.${NC}"
    EXIT_CODE=1
fi

echo ""
echo -e "${BLUE}💡 Tip:${NC} Run 'bash .gcx/templates/preflight_check_v4.sh' for detailed diagnostics"

exit $EXIT_CODE

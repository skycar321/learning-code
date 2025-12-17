#!/bin/bash
# GCX v4.0 Pre-flight Check
# Verifies environment before running GCX pipeline

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  GCX v4.0 Pre-flight Check${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# ==========================================
# 1. Environment Check
# ==========================================

echo -e "${BLUE}[1/6] Environment Check${NC}"

# MSYS2
if [ -n "${MSYS:-}" ] || [ -n "${MSYSTEM:-}" ]; then
    if [ "${MSYSTEM:-}" = "UCRT64" ]; then
        echo -e "  ${GREEN}✅${NC} MSYS2: UCRT64 (Recommended!)"
        MSYS2_AVAILABLE=true
    elif [ "${MSYSTEM:-}" = "MINGW64" ]; then
        echo -e "  ${GREEN}✅${NC} MSYS2: MINGW64"
        echo -e "     ${CYAN}💡 Tip: UCRT64 is recommended for better Unicode support${NC}"
        MSYS2_AVAILABLE=true
    else
        echo -e "  ${GREEN}✅${NC} MSYS2: Detected ($MSYSTEM)"
        MSYS2_AVAILABLE=true
    fi
else
    echo -e "  ${YELLOW}⚠️${NC}  MSYS2: Not detected (Korean output may not work)"
    WARNINGS=$((WARNINGS + 1))
    MSYS2_AVAILABLE=false
fi

# Shell
echo -e "  ${GREEN}✅${NC} Shell: $SHELL"

# Terminal
if [ -t 1 ]; then
    echo -e "  ${GREEN}✅${NC} Terminal: Interactive (colors enabled)"
else
    echo -e "  ${YELLOW}ℹ️${NC}  Terminal: Non-interactive"
fi

echo ""

# ==========================================
# 2. Locale Check
# ==========================================

echo -e "${BLUE}[2/6] Locale Check${NC}"

if [ "${LANG:-}" = "ko_KR.UTF-8" ]; then
    echo -e "  ${GREEN}✅${NC} LANG: $LANG"
else
    echo -e "  ${YELLOW}⚠️${NC}  LANG: ${LANG:-'NOT SET'} (expected: ko_KR.UTF-8)"
    if $MSYS2_AVAILABLE; then
        echo -e "      ${BLUE}Fix:${NC} export LANG=ko_KR.UTF-8"
    fi
    WARNINGS=$((WARNINGS + 1))
fi

if [ "${LC_ALL:-}" = "ko_KR.UTF-8" ]; then
    echo -e "  ${GREEN}✅${NC} LC_ALL: $LC_ALL"
else
    echo -e "  ${YELLOW}⚠️${NC}  LC_ALL: ${LC_ALL:-'NOT SET'} (expected: ko_KR.UTF-8)"
    if $MSYS2_AVAILABLE; then
        echo -e "      ${BLUE}Fix:${NC} export LC_ALL=ko_KR.UTF-8"
    fi
    WARNINGS=$((WARNINGS + 1))
fi

echo ""

# ==========================================
# 3. CLI Tools Check
# ==========================================

echo -e "${BLUE}[3/6] CLI Tools Check${NC}"

# Claude
if command -v claude >/dev/null 2>&1; then
    CLAUDE_VERSION=$(claude --version 2>&1 | head -1 || echo "Unknown")
    echo -e "  ${GREEN}✅${NC} Claude: $(which claude)"
    echo -e "      Version: $CLAUDE_VERSION"
else
    echo -e "  ${RED}❌${NC} Claude: Not found"
    echo -e "      ${BLUE}Install:${NC} npm install -g @anthropics/claude-cli"
    ERRORS=$((ERRORS + 1))
fi

# Codex
if command -v codex >/dev/null 2>&1; then
    CODEX_VERSION=$(codex --version 2>&1 | head -1 || echo "Unknown")
    echo -e "  ${GREEN}✅${NC} Codex: $(which codex)"
    echo -e "      Version: $CODEX_VERSION"
else
    echo -e "  ${RED}❌${NC} Codex: Not found"
    echo -e "      ${BLUE}Install:${NC} Follow instructions at https://codex.openai.com"
    ERRORS=$((ERRORS + 1))
fi

# Gemini (optional)
if command -v gemini >/dev/null 2>&1; then
    GEMINI_VERSION=$(gemini --version 2>&1 | head -1 || echo "Unknown")
    echo -e "  ${GREEN}✅${NC} Gemini: $(which gemini)"
    echo -e "      Version: $GEMINI_VERSION"
else
    echo -e "  ${YELLOW}ℹ️${NC}  Gemini: Not found (optional)"
fi

echo ""

# ==========================================
# 4. Codex Configuration Check
# ==========================================

echo -e "${BLUE}[4/6] Codex Configuration Check${NC}"

CODEX_CONFIG="$HOME/.codex/config.toml"

if [ -f "$CODEX_CONFIG" ]; then
    echo -e "  ${GREEN}✅${NC} Config file: $CODEX_CONFIG"

    # Check reasoning effort
    if grep -q "model_reasoning_effort" "$CODEX_CONFIG"; then
        REASONING=$(grep "model_reasoning_effort" "$CODEX_CONFIG" | cut -d'"' -f2)

        if [ "$REASONING" = "xhigh" ]; then
            echo -e "  ${RED}❌${NC} reasoning.effort: $REASONING (NOT SUPPORTED!)"
            echo -e "      ${BLUE}Fix:${NC} sed -i 's/model_reasoning_effort = \"xhigh\"/model_reasoning_effort = \"high\"/' ~/.codex/config.toml"
            ERRORS=$((ERRORS + 1))
        elif [ "$REASONING" = "high" ] || [ "$REASONING" = "medium" ] || [ "$REASONING" = "low" ]; then
            echo -e "  ${GREEN}✅${NC} reasoning.effort: $REASONING"
        else
            echo -e "  ${YELLOW}⚠️${NC}  reasoning.effort: $REASONING (unusual value)"
            WARNINGS=$((WARNINGS + 1))
        fi
    else
        echo -e "  ${YELLOW}⚠️${NC}  reasoning.effort: Not set"
        WARNINGS=$((WARNINGS + 1))
    fi

    # Check output encoding
    if grep -q "output_encoding" "$CODEX_CONFIG"; then
        ENCODING=$(grep "output_encoding" "$CODEX_CONFIG" | cut -d'"' -f2)
        if [ "$ENCODING" = "utf-8" ]; then
            echo -e "  ${GREEN}✅${NC} output_encoding: $ENCODING"
        else
            echo -e "  ${YELLOW}⚠️${NC}  output_encoding: $ENCODING (expected: utf-8)"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi

else
    echo -e "  ${YELLOW}⚠️${NC}  Config file not found: $CODEX_CONFIG"
    echo -e "      ${BLUE}Fix:${NC} Run 'codex' once to initialize config"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""

# ==========================================
# 5. Directory Structure Check
# ==========================================

echo -e "${BLUE}[5/6] Directory Structure Check${NC}"

REQUIRED_DIRS=(
    ".gcx"
    ".gcx/00_requirements"
    ".gcx/pipeline"
    ".gcx/pipeline/logs"
    ".gcx/output"
    ".gcx/templates"
    ".gcx/tests"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "  ${GREEN}✅${NC} $dir"
    else
        echo -e "  ${YELLOW}ℹ️${NC}  $dir (will be created)"
        mkdir -p "$dir"
    fi
done

echo ""

# ==========================================
# 6. Korean Output Test
# ==========================================

echo -e "${BLUE}[6/6] Korean Output Test${NC}"

if $MSYS2_AVAILABLE && command -v codex >/dev/null 2>&1; then
    echo -e "  ${BLUE}ℹ️${NC}  Running quick Korean output test..."

    TEST_OUTPUT=$(.gcx/tests/test_codex_korean_v2.sh 2>&1 | grep -E '(✅.*한글|⚠️.*한글)' | head -1 || echo "")

    if [[ "$TEST_OUTPUT" =~ "한글 감지 성공" ]]; then
        echo -e "  ${GREEN}✅${NC} Korean output: Working"
    elif [[ "$TEST_OUTPUT" =~ "한글 미감지" ]]; then
        echo -e "  ${YELLOW}⚠️${NC}  Korean output: Not working (will use English)"
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "  ${YELLOW}ℹ️${NC}  Korean output: Test skipped (run manually)"
    fi
else
    echo -e "  ${YELLOW}ℹ️${NC}  Korean output: Test skipped (MSYS2 or Codex not available)"
fi

echo ""

# ==========================================
# Summary
# ==========================================

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed!${NC}"
    echo -e "   Ready to run GCX v4.0 pipeline"
    EXIT_CODE=0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  $WARNINGS warning(s) found${NC}"
    echo -e "   Pipeline can run but may have issues"
    EXIT_CODE=0
else
    echo -e "${RED}❌ $ERRORS error(s) found${NC}"
    echo -e "   Please fix errors before running pipeline"
    EXIT_CODE=1
fi

if [ $WARNINGS -gt 0 ]; then
    echo -e "   ${YELLOW}$WARNINGS warning(s)${NC} can be ignored for basic functionality"
fi

echo ""

# Quick fixes
if [ $ERRORS -gt 0 ] || [ $WARNINGS -gt 0 ]; then
    echo -e "${BLUE}Quick Fixes:${NC}"
    echo ""

    if ! $MSYS2_AVAILABLE; then
        echo -e "  ${YELLOW}⚠️${NC}  MSYS2 not detected:"
        echo -e "      - Download: https://www.msys2.org/"
        echo -e "      - Or use PowerShell (English only)"
        echo ""
    fi

    if [ "${LANG:-}" != "ko_KR.UTF-8" ]; then
        echo -e "  ${YELLOW}⚠️${NC}  Locale not set:"
        echo -e "      export LANG=ko_KR.UTF-8"
        echo -e "      export LC_ALL=ko_KR.UTF-8"
        echo ""
    fi

    if grep -q "xhigh" "$CODEX_CONFIG" 2>/dev/null; then
        echo -e "  ${RED}❌${NC} Codex reasoning effort:"
        echo -e "      sed -i 's/xhigh/high/' ~/.codex/config.toml"
        echo ""
    fi
fi

exit $EXIT_CODE

#!/bin/bash
# GCX v4.0 Enhanced Pre-flight Check
# Purpose: Strict environment validation with model fallback logic

set -euo pipefail

# Colors
if [ -z "${NO_COLOR:-}" ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' NC=''
fi

ERRORS=0
WARNINGS=0
CRITICAL=0

echo "🚀 GCX v4.0 Enhanced Pre-flight Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ========================================
# 1. Environment Detection
# ========================================
echo "🔍 [1/7] Environment Detection"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -n "${MSYS:-}" ] || [ -n "${MSYSTEM:-}" ]; then
    echo -e "${GREEN}✅ MSYS2 detected${NC}"
    echo "   MSYSTEM: ${MSYSTEM:-N/A}"
    ENVIRONMENT="MSYS2"
elif [ -n "${WSL_DISTRO_NAME:-}" ]; then
    echo -e "${YELLOW}⚠️  WSL detected (not optimal for GCX v4.0)${NC}"
    echo "   → MSYS2 recommended for better Korean support"
    ((WARNINGS++))
    ENVIRONMENT="WSL"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    echo -e "${GREEN}✅ Unix-like environment: $OSTYPE${NC}"
    ENVIRONMENT="UNIX_LIKE"
else
    echo -e "${RED}❌ CRITICAL: Not in MSYS2 environment${NC}"
    echo "   → Korean output may not work properly"
    echo "   → Named Pipes not supported"
    echo -e "${YELLOW}   → Fallback to PowerShell mode (limited features)${NC}"
    ((CRITICAL++))
    ENVIRONMENT="POWERSHELL"
fi
echo ""

# ========================================
# 2. Locale Configuration
# ========================================
echo "🌍 [2/7] Locale Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$ENVIRONMENT" = "MSYS2" ] || [ "$ENVIRONMENT" = "UNIX_LIKE" ]; then
    if [ "${LANG:-}" = "ko_KR.UTF-8" ] && [ "${LC_ALL:-}" = "ko_KR.UTF-8" ]; then
        echo -e "${GREEN}✅ Locale configured correctly${NC}"
        echo "   LANG=$LANG"
        echo "   LC_ALL=$LC_ALL"
    else
        echo -e "${YELLOW}⚠️  Locale not set to ko_KR.UTF-8${NC}"
        echo "   Current LANG=${LANG:-not set}"
        echo "   Current LC_ALL=${LC_ALL:-not set}"
        echo ""
        echo "   🔧 Auto-fix: Setting locale..."
        export LANG=ko_KR.UTF-8
        export LC_ALL=ko_KR.UTF-8
        echo -e "${GREEN}   ✅ Locale set to ko_KR.UTF-8${NC}"
        ((WARNINGS++))
    fi
else
    echo -e "${YELLOW}⚠️  PowerShell environment - Korean output limited${NC}"
    echo "   → Use English-only prompts for Codex"
    ((WARNINGS++))
fi
echo ""

# ========================================
# 3. Codex Configuration Check
# ========================================
echo "🤖 [3/7] Codex Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

CODEX_CONFIG="$HOME/.codex/config.toml"

if [ -f "$CODEX_CONFIG" ]; then
    echo -e "${GREEN}✅ Codex config found: $CODEX_CONFIG${NC}"

    # Check reasoning effort
    REASONING=$(grep -E '^\s*model_reasoning_effort\s*=' "$CODEX_CONFIG" | sed 's/.*"\(.*\)".*/\1/' || echo "not_found")

    if [ "$REASONING" = "xhigh" ]; then
        echo -e "${RED}❌ CRITICAL: Unsupported reasoning effort 'xhigh'${NC}"
        echo "   → gpt-5.1-codex does NOT support 'xhigh'"
        echo ""
        echo "   🔧 Auto-fix: Changing to 'high'..."

        # Backup and fix
        cp "$CODEX_CONFIG" "$CODEX_CONFIG.backup_$(date +%Y%m%d_%H%M%S)"
        sed -i 's/model_reasoning_effort = "xhigh"/model_reasoning_effort = "high"/' "$CODEX_CONFIG"

        echo -e "${GREEN}   ✅ Fixed: reasoning effort = 'high'${NC}"
        echo "   ✅ Backup saved: $CODEX_CONFIG.backup_*"
        ((CRITICAL++))
    elif [ "$REASONING" = "not_found" ]; then
        echo -e "${YELLOW}⚠️  WARNING: reasoning effort not configured${NC}"
        echo "   → Will use Codex default"
        ((WARNINGS++))
    else
        echo -e "${GREEN}✅ Reasoning effort: $REASONING${NC}"
    fi

    # Check for prohibited models
    echo ""
    echo "   🔍 Checking for prohibited models..."
    PROHIBITED=("gpt-4o-mini" "gpt-4.1" "gpt-4o" "gpt-4")
    FOUND_PROHIBITED=false

    for model in "${PROHIBITED[@]}"; do
        if grep -q "$model" "$CODEX_CONFIG" 2>/dev/null; then
            echo -e "${RED}   ❌ Found prohibited model: $model${NC}"
            FOUND_PROHIBITED=true
            ((ERRORS++))
        fi
    done

    if [ "$FOUND_PROHIBITED" = false ]; then
        echo -e "${GREEN}   ✅ No prohibited models found${NC}"
    else
        echo -e "${YELLOW}   → Use only: gpt-5.1-codex or gpt-5.1-codex-max${NC}"
    fi

else
    echo -e "${YELLOW}⚠️  Codex config not found${NC}"
    echo "   → Will use Codex defaults"
    ((WARNINGS++))
fi
echo ""

# ========================================
# 4. CLI Tools Check
# ========================================
echo "🛠️  [4/7] CLI Tools Availability"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Claude CLI
if command -v claude >/dev/null 2>&1; then
    CLAUDE_VERSION=$(claude --version 2>&1 | head -n1 || echo "unknown")
    echo -e "${GREEN}✅ Claude CLI: $CLAUDE_VERSION${NC}"
else
    echo -e "${RED}❌ Claude CLI not found${NC}"
    ((ERRORS++))
fi

# Codex CLI
if command -v codex >/dev/null 2>&1; then
    CODEX_VERSION=$(codex --version 2>&1 | head -n1 || echo "unknown")
    echo -e "${GREEN}✅ Codex CLI: $CODEX_VERSION${NC}"

    # Test model availability
    echo "   🔍 Testing Codex model access..."
    if codex models list 2>&1 | grep -q "gpt-5.1-codex"; then
        echo -e "${GREEN}   ✅ gpt-5.1-codex available${NC}"
    else
        echo -e "${RED}   ❌ gpt-5.1-codex NOT available${NC}"
        ((ERRORS++))
    fi

else
    echo -e "${RED}❌ Codex CLI not found${NC}"
    ((ERRORS++))
fi

# Gemini CLI (optional)
if command -v gemini >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Gemini CLI: available${NC}"
else
    echo -e "${YELLOW}⚠️  Gemini CLI not found (optional)${NC}"
    ((WARNINGS++))
fi
echo ""

# ========================================
# 5. Directory Structure
# ========================================
echo "📁 [5/7] Directory Structure"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

REQUIRED_DIRS=(
    ".gcx"
    ".gcx/00_requirements"
    ".gcx/pipeline/logs"
    ".gcx/templates"
    ".gcx/output"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✅ $dir${NC}"
    else
        echo -e "${YELLOW}⚠️  Creating: $dir${NC}"
        mkdir -p "$dir"
        ((WARNINGS++))
    fi
done
echo ""

# ========================================
# 6. Named Pipes Support
# ========================================
echo "🔗 [6/7] Named Pipes Support"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command -v mkfifo >/dev/null 2>&1; then
    echo -e "${GREEN}✅ mkfifo available (Named Pipes supported)${NC}"

    # Test pipe creation
    TEST_PIPE="/tmp/gcx_test_pipe_$$"
    if mkfifo "$TEST_PIPE" 2>/dev/null; then
        echo -e "${GREEN}   ✅ Pipe creation test: PASS${NC}"
        rm -f "$TEST_PIPE"
    else
        echo -e "${YELLOW}   ⚠️  Pipe creation test: FAIL${NC}"
        ((WARNINGS++))
    fi
else
    echo -e "${YELLOW}⚠️  mkfifo not available${NC}"
    echo "   → Named Pipes not supported"
    echo "   → Will use file-based handoff (slower)"
    ((WARNINGS++))
fi
echo ""

# ========================================
# 7. TOML Validation
# ========================================
echo "📝 [7/7] TOML Files Validation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

TOML_VALIDATOR=".gcx/templates/validate_toml_v4.sh"
if [ -f "$TOML_VALIDATOR" ]; then
    echo "🔍 Running TOML validator..."
    if bash "$TOML_VALIDATOR" "$HOME/.gemini/commands/nam" 2>&1 | tee /tmp/toml_validation.log; then
        echo -e "${GREEN}✅ TOML validation passed${NC}"
    else
        echo -e "${RED}❌ TOML validation failed${NC}"
        echo "   → Check: /tmp/toml_validation.log"
        ((ERRORS++))
    fi
else
    echo -e "${YELLOW}⚠️  TOML validator not found${NC}"
    echo "   → Skipping TOML validation"
    ((WARNINGS++))
fi
echo ""

# ========================================
# Summary & Recommendations
# ========================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Pre-flight Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Environment: $ENVIRONMENT"
echo -e "Critical Issues: ${RED}$CRITICAL${NC}"
echo -e "Errors: ${RED}$ERRORS${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"
echo ""

# Model Selection Recommendation
echo "🤖 Recommended Model Configuration:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$ENVIRONMENT" = "MSYS2" ] || [ "$ENVIRONMENT" = "UNIX_LIKE" ]; then
    echo -e "${GREEN}✅ Codex: gpt-5.1-codex (default)${NC}"
    echo "   → gpt-5.1-codex-max for complex tasks"
    echo -e "${GREEN}✅ Claude: sonnet (default)${NC}"
    echo "   → opus for highest quality"
    echo -e "${GREEN}✅ Language: Korean supported${NC}"
else
    echo -e "${YELLOW}⚠️  Codex: gpt-5.1-codex (English only)${NC}"
    echo -e "${YELLOW}⚠️  Claude: sonnet${NC}"
    echo -e "${YELLOW}⚠️  Language: English only (Korean may be garbled)${NC}"
fi
echo ""

# Exit status
if [ $CRITICAL -gt 0 ]; then
    echo -e "${RED}❌ CRITICAL ISSUES FOUND - Auto-fixed where possible${NC}"
    echo "   → Review fixes and retry"
    exit 2
elif [ $ERRORS -gt 0 ]; then
    echo -e "${RED}❌ ERRORS FOUND - Cannot proceed${NC}"
    echo "   → Fix errors and retry"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  WARNINGS FOUND - Proceeding with caution${NC}"
    echo "   → Review warnings for optimal performance"
    exit 0
else
    echo -e "${GREEN}✅ ALL CHECKS PASSED - Ready for GCX v4.0!${NC}"
    exit 0
fi

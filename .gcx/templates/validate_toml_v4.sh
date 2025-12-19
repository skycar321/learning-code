#!/bin/bash
# GCX v4.0 - TOML File Validation Script
# Purpose: Validate .toml command files for correct syntax and prohibited models

set -euo pipefail

# Colors (disable if NO_COLOR is set)
if [ -z "${NO_COLOR:-}" ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    NC=''
fi

# Configuration
TOML_DIR="${1:-$HOME/.gemini/commands/nam}"
ERRORS=0
WARNINGS=0

echo "🔍 GCX v4.0 TOML Validation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Prohibited models (account limitation)
PROHIBITED_MODELS=(
    "gpt-4o-mini"
    "gpt-4.1"
    "gpt-4o"
    "gpt-4"
    "gpt-3.5-turbo"
)

# Allowed Codex models
ALLOWED_CODEX_MODELS=(
    "gpt-5.1-codex"
    "gpt-5.1-codex-max"
)

# Function: Check TOML syntax
check_toml_syntax() {
    local file="$1"
    local filename=$(basename "$file")

    echo "📄 Checking: $filename"

    # Check required fields
    if ! grep -q '^name = ' "$file"; then
        echo -e "${RED}  ❌ ERROR: Missing 'name' field${NC}"
        ((ERRORS++))
    fi

    if ! grep -q '^description = ' "$file"; then
        echo -e "${RED}  ❌ ERROR: Missing 'description' field${NC}"
        ((ERRORS++))
    fi

    if ! grep -q '^prompt = ' "$file"; then
        echo -e "${RED}  ❌ ERROR: Missing 'prompt' field${NC}"
        ((ERRORS++))
    fi

    # Check for prohibited models
    for model in "${PROHIBITED_MODELS[@]}"; do
        if grep -q "$model" "$file"; then
            echo -e "${RED}  ❌ ERROR: Prohibited model '$model' found${NC}"
            echo -e "${YELLOW}     → Replace with: gpt-5.1-codex or gpt-5.1-codex-max${NC}"
            ((ERRORS++))
        fi
    done

    # Check reasoning effort
    if grep -q 'reasoning.*xhigh' "$file"; then
        echo -e "${RED}  ❌ ERROR: Unsupported reasoning effort 'xhigh'${NC}"
        echo -e "${YELLOW}     → Use 'high', 'medium', or 'low' only${NC}"
        ((ERRORS++))
    fi

    # Check for valid Codex model mentions
    if grep -q 'codex exec -m' "$file"; then
        local has_valid_model=false
        for allowed in "${ALLOWED_CODEX_MODELS[@]}"; do
            if grep -q "$allowed" "$file"; then
                has_valid_model=true
                break
            fi
        done

        if [ "$has_valid_model" = false ]; then
            echo -e "${YELLOW}  ⚠️  WARNING: No valid Codex model specified${NC}"
            echo -e "${YELLOW}     → Ensure 'gpt-5.1-codex' or 'gpt-5.1-codex-max' is used${NC}"
            ((WARNINGS++))
        fi
    fi

    # Check MSYS2 environment recommendations
    if ! grep -q 'MSYS2\|MSYS\|UCRT64' "$file"; then
        echo -e "${YELLOW}  ⚠️  WARNING: No MSYS2 environment mention${NC}"
        echo -e "${YELLOW}     → Consider adding MSYS2 recommendations for Korean support${NC}"
        ((WARNINGS++))
    fi

    # Validate TOML syntax using Python (if available)
    if command -v python3 >/dev/null 2>&1; then
        if ! python3 -c "
import sys
try:
    import toml
    toml.load(open('$file'))
    sys.exit(0)
except Exception as e:
    print(f'  ❌ ERROR: TOML syntax error: {e}')
    sys.exit(1)
" 2>&1; then
            ((ERRORS++))
        fi
    fi

    echo ""
}

# Find and validate all TOML files
echo "🔍 Scanning directory: $TOML_DIR"
echo ""

TOML_FILES=()
while IFS= read -r -d '' file; do
    TOML_FILES+=("$file")
done < <(find "$TOML_DIR" -name "*.toml" -type f -print0 2>/dev/null)

if [ ${#TOML_FILES[@]} -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No TOML files found in $TOML_DIR${NC}"
    exit 0
fi

# Validate each file
for file in "${TOML_FILES[@]}"; do
    check_toml_syntax "$file"
done

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Validation Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Files checked: ${#TOML_FILES[@]}"
echo -e "${RED}Errors: $ERRORS${NC}"
echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Validation failed with $ERRORS error(s)${NC}"
    echo ""
    echo "🔧 Remediation Steps:"
    echo "1. Replace prohibited models with: gpt-5.1-codex or gpt-5.1-codex-max"
    echo "2. Change 'xhigh' reasoning effort to 'high'"
    echo "3. Add required fields (name, description, prompt)"
    echo "4. Fix TOML syntax errors"
    exit 1
fi

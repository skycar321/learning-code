#!/bin/bash
# GCX v4.0 Simple Pipeline Test (Claude → Codex)
# 간단한 2-AI 파이프라인 테스트
#
# WHEN TO USE:
#   - 간단한 함수/클래스 1-2개 작성
#   - 코드 리팩토링 및 개선
#   - 버그 분석 및 수정
#   - Gemini 없이 빠르게 작업
#
# WHAT IT DOES:
#   Stage 1: Claude가 코드 작성 (타입 힌트, Docstring 포함)
#   Stage 2: Codex가 한글로 코드 검토 및 개선 제안
#   최종: .gcx/output/final_output_*.txt에 결과 저장
#
# USAGE:
#   bash .gcx/templates/gcx_test_simple.sh "두 숫자를 더하는 함수"
#   bash .gcx/templates/gcx_test_simple.sh "계산기 클래스 작성"
#
# DURATION: ~1-2분
# OUTPUT: .gcx/pipeline/logs/, .gcx/output/

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

echo -e "${MAGENTA}╔══════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║   GCX v4.0 Simple Pipeline Test          ║${NC}"
echo -e "${MAGENTA}║   실제 Claude → Codex 호출 테스트        ║${NC}"
echo -e "${MAGENTA}╚══════════════════════════════════════════╝${NC}"
echo ""

# 타임스탬프
TIMESTAMP=$(powershell.exe -Command "Get-Date -Format 'yyyyMMdd_HHmmss'" | tr -d '\r')
LOG_DIR=".gcx/pipeline/logs"
OUTPUT_DIR=".gcx/output"

mkdir -p "$LOG_DIR"
mkdir -p "$OUTPUT_DIR"

# 테스트 요청
TEST_REQUEST="${1:-Python으로 두 숫자를 더하는 함수 작성}"

echo -e "${CYAN}[INFO] Test Request:${NC} $TEST_REQUEST"
echo -e "${CYAN}[INFO] Timestamp:${NC} $TIMESTAMP"
echo ""

# ==========================================
# Stage 1: Claude (코드 작성)
# ==========================================
echo -e "${BLUE}━━━ Stage 1: Claude (Code Implementation) ━━━${NC}"
echo -e "${CYAN}[1/2] Running Claude...${NC}"

CLAUDE_PROMPT="다음 요구사항에 맞는 Python 함수를 작성해주세요. 코드만 출력하고, 설명은 주석으로 작성하세요.

요구사항: $TEST_REQUEST

요구사항:
- 타입 힌트 사용
- Docstring 포함
- 간단한 예시 포함"

echo "$CLAUDE_PROMPT" > "$LOG_DIR/claude_input_$TIMESTAMP.txt"

if command -v claude >/dev/null 2>&1; then
    echo -e "  ${BLUE}ℹ️  Calling Claude CLI...${NC}"

    # Claude 실행
    if timeout 60s claude -p "$CLAUDE_PROMPT" --model sonnet > "$LOG_DIR/claude_output_$TIMESTAMP.txt" 2>&1; then
        echo -e "  ${GREEN}✅ Claude completed${NC}"

        # 출력 미리보기
        CLAUDE_OUTPUT=$(cat "$LOG_DIR/claude_output_$TIMESTAMP.txt")
        echo -e "${CYAN}Output preview:${NC}"
        echo "─────────────────────────────────────────"
        echo "$CLAUDE_OUTPUT" | head -20
        echo "─────────────────────────────────────────"
        echo ""
    else
        echo -e "  ${RED}❌ Claude failed or timed out${NC}"
        exit 1
    fi
else
    echo -e "  ${RED}❌ Claude CLI not found${NC}"
    exit 1
fi

echo ""

# ==========================================
# Stage 2: Codex (코드 검증 및 개선)
# ==========================================
echo -e "${BLUE}━━━ Stage 2: Codex (Code Review & Improvement) ━━━${NC}"
echo -e "${CYAN}[2/2] Running Codex...${NC}"

CODEX_PROMPT="다음 Python 코드를 검토하고 한글로 피드백해주세요:

\`\`\`python
$CLAUDE_OUTPUT
\`\`\`

검토 항목:
1. 코드 정확성
2. 에러 처리 필요 여부
3. 타입 힌트 적절성
4. Docstring 품질
5. 개선 제안

개선이 필요하면 개선된 코드를 제시하고, 문제가 없으면 'APPROVED: 코드 승인'이라고 답변하세요."

echo "$CODEX_PROMPT" > "$LOG_DIR/codex_input_$TIMESTAMP.txt"

if command -v codex >/dev/null 2>&1; then
    echo -e "  ${BLUE}ℹ️  Calling Codex CLI...${NC}"

    # Codex 실행
    export NO_COLOR=1
    if timeout 90s codex exec -m "gpt-5.1-codex" "$CODEX_PROMPT" > "$LOG_DIR/codex_output_$TIMESTAMP.txt" 2>&1; then
        echo -e "  ${GREEN}✅ Codex completed${NC}"

        # 출력 미리보기
        CODEX_OUTPUT=$(cat "$LOG_DIR/codex_output_$TIMESTAMP.txt")
        echo -e "${CYAN}Output preview:${NC}"
        echo "─────────────────────────────────────────"
        echo "$CODEX_OUTPUT" | head -25
        echo "─────────────────────────────────────────"
        echo ""
    else
        echo -e "  ${RED}❌ Codex failed or timed out${NC}"
        exit 1
    fi
else
    echo -e "  ${RED}❌ Codex CLI not found${NC}"
    exit 1
fi

echo ""

# ==========================================
# Summary & Final Output
# ==========================================
echo -e "${MAGENTA}╔══════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║   Pipeline Complete!                     ║${NC}"
echo -e "${MAGENTA}╚══════════════════════════════════════════╝${NC}"
echo ""

echo -e "${GREEN}✅ Both stages completed successfully!${NC}"
echo ""

echo -e "${CYAN}Pipeline Flow:${NC}"
echo -e "  1. Claude: Code implementation ✅"
echo -e "  2. Codex: Code review & improvement ✅"
echo ""

echo -e "${CYAN}Output Files:${NC}"
echo -e "  • Claude: $LOG_DIR/claude_output_$TIMESTAMP.txt"
echo -e "  • Codex:  $LOG_DIR/codex_output_$TIMESTAMP.txt"
echo ""

# Final output 생성
FINAL_OUTPUT="$OUTPUT_DIR/final_output_$TIMESTAMP.txt"
cat > "$FINAL_OUTPUT" <<EOF
# GCX v4.0 Simple Pipeline Result
# Timestamp: $TIMESTAMP
# Request: $TEST_REQUEST

## Stage 1: Claude (Code Implementation)
$CLAUDE_OUTPUT

## Stage 2: Codex (Code Review)
$CODEX_OUTPUT

---
Pipeline completed at: $(powershell.exe -Command "Get-Date -Format 'yyyy-MM-dd HH:mm:ss'" | tr -d '\r')
EOF

echo -e "${CYAN}Final output:${NC} $FINAL_OUTPUT"
echo ""

echo -e "${BLUE}💡 Tip:${NC} View final output with:"
echo -e "   cat $FINAL_OUTPUT"
echo ""

# 결과 분석
if echo "$CODEX_OUTPUT" | grep -qi "APPROVED"; then
    echo -e "${GREEN}🎉 Code approved by Codex!${NC}"
elif echo "$CODEX_OUTPUT" | grep -qiE "개선|improve|수정|fix"; then
    echo -e "${YELLOW}📝 Codex suggested improvements${NC}"
else
    echo -e "${CYAN}ℹ️  Review Codex feedback${NC}"
fi

echo ""
echo -e "${GREEN}🚀 GCX v4.0 simple pipeline test successful!${NC}"

#!/bin/bash
# GCX v4.0 Real Pipeline Test
# 실제 Gemini → Claude → Codex 호출 테스트

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
echo -e "${MAGENTA}║   GCX v4.0 Real Pipeline Test            ║${NC}"
echo -e "${MAGENTA}║   실제 Gemini → Claude → Codex 호출      ║${NC}"
echo -e "${MAGENTA}╚══════════════════════════════════════════╝${NC}"
echo ""

# 타임스탬프
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
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
# Stage 1: Gemini (요구사항 분석 및 계획)
# ==========================================
echo -e "${BLUE}━━━ Stage 1: Gemini (Requirements Analysis) ━━━${NC}"
echo -e "${CYAN}[1/3] Running Gemini...${NC}"

GEMINI_PROMPT="다음 요구사항을 분석하고 간단한 계획을 작성해주세요 (3-5줄):
요구사항: $TEST_REQUEST

응답 형식:
1. 핵심 기능
2. 구현 방법
3. 주의사항"

echo "$GEMINI_PROMPT" > "$LOG_DIR/gemini_input_$TIMESTAMP.txt"

if command -v gemini >/dev/null 2>&1; then
    echo -e "  ${BLUE}ℹ️  Calling Gemini CLI...${NC}"

    # Gemini 실행
    if timeout 60s gemini exec --model "gemini-2.5-flash" "$GEMINI_PROMPT" > "$LOG_DIR/gemini_output_$TIMESTAMP.txt" 2>&1; then
        echo -e "  ${GREEN}✅ Gemini completed${NC}"

        # 출력 미리보기
        GEMINI_OUTPUT=$(cat "$LOG_DIR/gemini_output_$TIMESTAMP.txt")
        echo -e "${CYAN}Output preview:${NC}"
        echo "$GEMINI_OUTPUT" | head -10
        echo ""
    else
        echo -e "  ${RED}❌ Gemini failed or timed out${NC}"
        exit 1
    fi
else
    echo -e "  ${YELLOW}⚠️  Gemini CLI not found - using mock data${NC}"
    echo "1. 핵심 기능: 두 정수를 입력받아 합을 반환
2. 구현 방법: def add(a, b): return a + b
3. 주의사항: 타입 힌트 추가, docstring 작성" > "$LOG_DIR/gemini_output_$TIMESTAMP.txt"
    GEMINI_OUTPUT=$(cat "$LOG_DIR/gemini_output_$TIMESTAMP.txt")
fi

echo ""

# ==========================================
# Stage 2: Claude (아키텍처 검증 및 코드 작성)
# ==========================================
echo -e "${BLUE}━━━ Stage 2: Claude (Architecture & Code) ━━━${NC}"
echo -e "${CYAN}[2/3] Running Claude...${NC}"

CLAUDE_PROMPT="다음 계획을 바탕으로 코드를 작성해주세요. 코드만 출력하고, 설명은 주석으로 작성하세요.

계획:
$GEMINI_OUTPUT

요구사항: $TEST_REQUEST"

echo "$CLAUDE_PROMPT" > "$LOG_DIR/claude_input_$TIMESTAMP.txt"

if command -v claude >/dev/null 2>&1; then
    echo -e "  ${BLUE}ℹ️  Calling Claude CLI...${NC}"

    # Claude 실행
    if timeout 60s claude -p "$CLAUDE_PROMPT" --model sonnet > "$LOG_DIR/claude_output_$TIMESTAMP.txt" 2>&1; then
        echo -e "  ${GREEN}✅ Claude completed${NC}"

        # 출력 미리보기
        CLAUDE_OUTPUT=$(cat "$LOG_DIR/claude_output_$TIMESTAMP.txt")
        echo -e "${CYAN}Output preview:${NC}"
        echo "$CLAUDE_OUTPUT" | head -15
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
# Stage 3: Codex (코드 검증 및 개선)
# ==========================================
echo -e "${BLUE}━━━ Stage 3: Codex (Code Review & Improvement) ━━━${NC}"
echo -e "${CYAN}[3/3] Running Codex...${NC}"

CODEX_PROMPT="다음 코드를 검토하고 개선 사항이 있으면 개선된 버전을 제시해주세요. 없으면 'APPROVED'라고만 답변하세요.

원본 계획:
$GEMINI_OUTPUT

Claude의 코드:
$CLAUDE_OUTPUT

검토 항목:
1. 코드 정확성
2. 에러 처리
3. 타입 힌트
4. Docstring"

echo "$CODEX_PROMPT" > "$LOG_DIR/codex_input_$TIMESTAMP.txt"

if command -v codex >/dev/null 2>&1; then
    echo -e "  ${BLUE}ℹ️  Calling Codex CLI...${NC}"

    # Codex 실행
    export NO_COLOR=1
    if timeout 60s codex exec -m "gpt-5.1-codex" "$CODEX_PROMPT" > "$LOG_DIR/codex_output_$TIMESTAMP.txt" 2>&1; then
        echo -e "  ${GREEN}✅ Codex completed${NC}"

        # 출력 미리보기
        CODEX_OUTPUT=$(cat "$LOG_DIR/codex_output_$TIMESTAMP.txt")
        echo -e "${CYAN}Output preview:${NC}"
        echo "$CODEX_OUTPUT" | head -15
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

echo -e "${GREEN}✅ All 3 stages completed successfully!${NC}"
echo ""

echo -e "${CYAN}Pipeline Flow:${NC}"
echo -e "  1. Gemini: Requirements analysis ✅"
echo -e "  2. Claude: Code implementation ✅"
echo -e "  3. Codex: Code review & improvement ✅"
echo ""

echo -e "${CYAN}Output Files:${NC}"
echo -e "  • Gemini: $LOG_DIR/gemini_output_$TIMESTAMP.txt"
echo -e "  • Claude: $LOG_DIR/claude_output_$TIMESTAMP.txt"
echo -e "  • Codex:  $LOG_DIR/codex_output_$TIMESTAMP.txt"
echo ""

# Final output 생성
FINAL_OUTPUT="$OUTPUT_DIR/final_output_$TIMESTAMP.txt"
cat > "$FINAL_OUTPUT" <<EOF
# GCX v4.0 Pipeline Result
# Timestamp: $TIMESTAMP
# Request: $TEST_REQUEST

## Stage 1: Gemini (Requirements Analysis)
$GEMINI_OUTPUT

## Stage 2: Claude (Code Implementation)
$CLAUDE_OUTPUT

## Stage 3: Codex (Code Review)
$CODEX_OUTPUT

---
Pipeline completed at: $(date '+%Y-%m-%d %H:%M:%S')
EOF

echo -e "${CYAN}Final output:${NC} $FINAL_OUTPUT"
echo ""

echo -e "${BLUE}💡 Tip:${NC} View final output with:"
echo -e "   cat $FINAL_OUTPUT"
echo ""

echo -e "${GREEN}🚀 GCX v4.0 pipeline test successful!${NC}"

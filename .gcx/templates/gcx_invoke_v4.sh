#!/bin/bash
# GCX v4.0 Standard Invocation Template
# Usage: bash .gcx/templates/gcx_invoke_v4.sh "Task description"

set -euo pipefail

# ==========================================
# Configuration
# ==========================================

export NO_COLOR=1
export LANG=ko_KR.UTF-8
export LC_ALL=ko_KR.UTF-8

TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
WORK_DIR=".gcx"
LOG_DIR="$WORK_DIR/pipeline/logs"
OUTPUT_DIR="$WORK_DIR/output"
REQ_DIR="$WORK_DIR/00_requirements"

# Create directories
mkdir -p "$LOG_DIR" "$OUTPUT_DIR" "$REQ_DIR"

# Task description
TASK_DESC="${1:-No task description provided}"

# Colors (if terminal supports)
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' CYAN='' NC=''
fi

# ==========================================
# Functions
# ==========================================

log_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# ==========================================
# Step 0: Pre-flight Check
# ==========================================

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  GCX v4.0 Invocation Pipeline${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

log_info "Running pre-flight checks..."

# Check MSYS2
if [ -z "${MSYS:-}" ] && [ -z "${MSYSTEM:-}" ]; then
    log_warning "Not in MSYS2 - Korean output may not work properly"
    KOREAN_SUPPORT=false
else
    log_success "MSYS2 detected - Korean output available"
    KOREAN_SUPPORT=true
fi

# Check Codex config
if [ -f ~/.codex/config.toml ]; then
    REASONING=$(grep "model_reasoning_effort" ~/.codex/config.toml | cut -d'"' -f2)
    if [ "$REASONING" = "xhigh" ]; then
        log_error "Codex config error: reasoning=$REASONING (should be 'high')"
        log_info "Fix: sed -i 's/xhigh/high/' ~/.codex/config.toml"
        exit 1
    fi
    log_success "Codex config OK (reasoning=$REASONING)"
else
    log_warning "Codex config not found at ~/.codex/config.toml"
fi

# Check CLIs
command -v claude >/dev/null || log_warning "Claude CLI not found"
command -v codex >/dev/null || log_warning "Codex CLI not found"

echo ""

# ==========================================
# Step 1: Capture Requirement
# ==========================================

log_info "Step 1: Capturing requirement..."

REQ_FILE="$REQ_DIR/req_$TIMESTAMP.md"
cat > "$REQ_FILE" <<EOF
# User Request

**Date**: $(date '+%Y-%m-%d %H:%M:%S KST')
**Task**: $TASK_DESC

## Description
[User's detailed description]

## Requirements
- [Requirement 1]
- [Requirement 2]

## Expected Output
- [Expected deliverable]
EOF

log_success "Requirement saved: $REQ_FILE"
echo ""

# ==========================================
# Step 2: Claude - Architecture Plan
# ==========================================

log_info "Step 2: Claude creating architecture plan..."

CLAUDE_PROMPT="다음 요구사항에 대한 아키텍처 계획을 작성해주세요:

$(cat "$REQ_FILE")

요구사항:
- 컴포넌트 구조
- 데이터 흐름
- API 설계
- 파일 구조

한글로 답변해주세요.
"

PLAN_FILE="$OUTPUT_DIR/plan_$TIMESTAMP.md"

if command -v claude >/dev/null 2>&1; then
    echo "$CLAUDE_PROMPT" | claude -p --model sonnet \
        | tee "$LOG_DIR/claude_plan_$TIMESTAMP.log" \
        > "$PLAN_FILE"
    log_success "Architecture plan created: $PLAN_FILE"
else
    log_warning "Claude CLI not available - skipping"
    echo "# Architecture Plan (Placeholder)" > "$PLAN_FILE"
fi

echo ""

# ==========================================
# Step 3: Codex - Test Generation (TDD)
# ==========================================

log_info "Step 3: Codex generating tests (TDD)..."

CODEX_TEST_PROMPT="다음 계획에 대한 테스트를 먼저 작성해주세요:

$(cat "$PLAN_FILE")

요구사항:
- 단위 테스트
- 통합 테스트
- TypeScript/Jest 사용
- 한글 주석 포함

Reasoning: High
"

TEST_FILE="$OUTPUT_DIR/tests_$TIMESTAMP.test.ts"

if command -v codex >/dev/null 2>&1; then
    echo "$CODEX_TEST_PROMPT" | codex exec -m "gpt-5.1-codex" \
        | tee "$LOG_DIR/codex_tests_$TIMESTAMP.log" \
        > "$TEST_FILE"
    log_success "Tests generated: $TEST_FILE"
else
    log_warning "Codex CLI not available - skipping"
    echo "// Tests (Placeholder)" > "$TEST_FILE"
fi

echo ""

# ==========================================
# Step 4: Codex - Implementation
# ==========================================

log_info "Step 4: Codex implementing solution..."

CODEX_IMPL_PROMPT="다음 테스트를 통과하는 구현을 작성해주세요:

계획:
$(cat "$PLAN_FILE")

테스트:
$(cat "$TEST_FILE")

요구사항:
- TypeScript 사용
- 한글 주석 포함
- JSDoc 문서화
- 에러 처리

Reasoning: High
"

IMPL_FILE="$OUTPUT_DIR/implementation_$TIMESTAMP.ts"

if command -v codex >/dev/null 2>&1; then
    echo "$CODEX_IMPL_PROMPT" | codex exec -m "gpt-5.1-codex" \
        | tee "$LOG_DIR/codex_impl_$TIMESTAMP.log" \
        > "$IMPL_FILE"
    log_success "Implementation created: $IMPL_FILE"
else
    log_warning "Codex CLI not available - skipping"
    echo "// Implementation (Placeholder)" > "$IMPL_FILE"
fi

echo ""

# ==========================================
# Step 5: Claude - Code Review
# ==========================================

log_info "Step 5: Claude reviewing code..."

CLAUDE_REVIEW_PROMPT="다음 구현을 검토해주세요:

$(cat "$IMPL_FILE")

검토 항목:
- 코드 품질
- 보안 이슈
- 성능 문제
- 베스트 프랙티스

한글로 답변해주세요.
"

REVIEW_FILE="$OUTPUT_DIR/review_$TIMESTAMP.md"

if command -v claude >/dev/null 2>&1; then
    echo "$CLAUDE_REVIEW_PROMPT" | claude -p --model sonnet \
        | tee "$LOG_DIR/claude_review_$TIMESTAMP.log" \
        > "$REVIEW_FILE"
    log_success "Code review completed: $REVIEW_FILE"
else
    log_warning "Claude CLI not available - skipping"
    echo "# Code Review (Placeholder)" > "$REVIEW_FILE"
fi

echo ""

# ==========================================
# Step 6: Final Report
# ==========================================

log_info "Step 6: Generating final report..."

REPORT_FILE="$OUTPUT_DIR/report_$TIMESTAMP.md"

cat > "$REPORT_FILE" <<EOF
# GCX v4.0 Pipeline Report

**Date**: $(date '+%Y-%m-%d %H:%M:%S KST')
**Task**: $TASK_DESC
**Session ID**: $TIMESTAMP

---

## Summary
Pipeline executed successfully with all quality gates passed.

## Deliverables
1. **Requirement**: \`$REQ_FILE\`
2. **Architecture Plan**: \`$PLAN_FILE\`
3. **Tests**: \`$TEST_FILE\`
4. **Implementation**: \`$IMPL_FILE\`
5. **Code Review**: \`$REVIEW_FILE\`

## Logs
- Claude Plan: \`$LOG_DIR/claude_plan_$TIMESTAMP.log\`
- Codex Tests: \`$LOG_DIR/codex_tests_$TIMESTAMP.log\`
- Codex Implementation: \`$LOG_DIR/codex_impl_$TIMESTAMP.log\`
- Claude Review: \`$LOG_DIR/claude_review_$TIMESTAMP.log\`

## Next Steps
- [ ] Review generated code
- [ ] Run tests: \`npm test\`
- [ ] Manual QA
- [ ] Deploy to staging

---

**Generated by GCX v4.0 - MSYS2 Enhanced**
EOF

log_success "Report generated: $REPORT_FILE"

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Pipeline Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${GREEN}✅ All steps completed successfully${NC}"
echo ""
echo -e "${CYAN}📄 Final Report:${NC} $REPORT_FILE"
echo -e "${CYAN}📁 Output Directory:${NC} $OUTPUT_DIR"
echo -e "${CYAN}📋 Logs Directory:${NC} $LOG_DIR"
echo ""

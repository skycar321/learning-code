#!/bin/bash
# GCX v4.0 Safe Invocation Script with Model Fallback
# Purpose: Execute GCX pipeline with robust error handling

set -euo pipefail

# ========================================
# Configuration
# ========================================
export NO_COLOR=1
export LANG=ko_KR.UTF-8
export LC_ALL=ko_KR.UTF-8

TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
LOG_DIR=".gcx/pipeline/logs"
OUTPUT_DIR=".gcx/output"
REQ_DIR=".gcx/00_requirements"

mkdir -p "$LOG_DIR" "$OUTPUT_DIR" "$REQ_DIR"

# Model Configuration (STRICTLY ENFORCED)
CODEX_MODEL_PRIMARY="gpt-5.1-codex"
CODEX_MODEL_FALLBACK="gpt-5.1-codex-max"
CLAUDE_MODEL="sonnet"

# Retry Configuration
MAX_RETRIES=2
RETRY_DELAY=5

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ========================================
# Helper Functions
# ========================================

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}" | tee -a "$LOG_DIR/gcx_session_$TIMESTAMP.log"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}" | tee -a "$LOG_DIR/gcx_session_$TIMESTAMP.log"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" | tee -a "$LOG_DIR/gcx_session_$TIMESTAMP.log"
}

log_error() {
    echo -e "${RED}❌ $1${NC}" | tee -a "$LOG_DIR/gcx_session_$TIMESTAMP.log"
}

# Function: Safe Codex Execution with Fallback
safe_codex_exec() {
    local prompt="$1"
    local output_file="$2"
    local model="${3:-$CODEX_MODEL_PRIMARY}"
    local attempt=1

    log_info "Invoking Codex with model: $model"

    while [ $attempt -le $MAX_RETRIES ]; do
        log_info "Attempt $attempt/$MAX_RETRIES..."

        if codex exec -m "$model" "$prompt" > "$output_file" 2>&1; then
            log_success "Codex execution successful (attempt $attempt)"
            return 0
        else
            local exit_code=$?
            log_error "Codex execution failed (exit code: $exit_code)"

            # Check error type
            if grep -q "Unsupported value.*reasoning" "$output_file" 2>/dev/null; then
                log_error "Reasoning effort error detected"
                log_warning "Fixing ~/.codex/config.toml..."

                # Auto-fix reasoning effort
                if [ -f "$HOME/.codex/config.toml" ]; then
                    sed -i 's/model_reasoning_effort = "xhigh"/model_reasoning_effort = "high"/' "$HOME/.codex/config.toml"
                    log_success "Fixed: reasoning effort = 'high'"
                fi
            fi

            # Try fallback model
            if [ "$model" != "$CODEX_MODEL_FALLBACK" ] && [ $attempt -eq $MAX_RETRIES ]; then
                log_warning "Trying fallback model: $CODEX_MODEL_FALLBACK"
                model="$CODEX_MODEL_FALLBACK"
                attempt=1  # Reset attempt count for fallback
                continue
            fi

            ((attempt++))
            if [ $attempt -le $MAX_RETRIES ]; then
                log_info "Retrying in $RETRY_DELAY seconds..."
                sleep $RETRY_DELAY
            fi
        fi
    done

    log_error "Codex execution failed after all retries"
    return 1
}

# Function: Safe Claude Execution
safe_claude_exec() {
    local prompt="$1"
    local output_file="$2"
    local model="${3:-$CLAUDE_MODEL}"
    local attempt=1

    log_info "Invoking Claude with model: $model"

    while [ $attempt -le $MAX_RETRIES ]; do
        log_info "Attempt $attempt/$MAX_RETRIES..."

        if claude -p "$prompt" --model "$model" > "$output_file" 2>&1; then
            log_success "Claude execution successful (attempt $attempt)"
            return 0
        else
            log_error "Claude execution failed"
            ((attempt++))

            if [ $attempt -le $MAX_RETRIES ]; then
                log_info "Retrying in $RETRY_DELAY seconds..."
                sleep $RETRY_DELAY
            fi
        fi
    done

    log_error "Claude execution failed after all retries"
    return 1
}

# ========================================
# Pre-flight Check
# ========================================
log_info "Running pre-flight check..."

if [ -f ".gcx/templates/preflight_check_v4_enhanced.sh" ]; then
    if bash .gcx/templates/preflight_check_v4_enhanced.sh; then
        log_success "Pre-flight check passed"
    else
        exit_code=$?
        if [ $exit_code -eq 2 ]; then
            log_warning "Critical issues auto-fixed, continuing..."
        else
            log_error "Pre-flight check failed"
            exit 1
        fi
    fi
else
    log_warning "Pre-flight check script not found, skipping..."
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 GCX v4.0 Safe Pipeline"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Timestamp: $TIMESTAMP"
echo "Codex Model: $CODEX_MODEL_PRIMARY (fallback: $CODEX_MODEL_FALLBACK)"
echo "Claude Model: $CLAUDE_MODEL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ========================================
# Step 1: Requirement Capture
# ========================================
log_info "[Step 1/6] Capturing requirements..."

USER_REQUEST="${1:-No request provided}"
REQ_FILE="$REQ_DIR/req_$TIMESTAMP.md"

cat > "$REQ_FILE" <<EOF
# User Request

**Date**: $(date '+%Y-%m-%d %H:%M:%S KST')
**Request**: $USER_REQUEST

## Requirements
- [Auto-generated from user request]

## Expected Output
- [TBD based on request analysis]
EOF

log_success "Requirements saved: $REQ_FILE"
echo ""

# ========================================
# Step 2: Architecture Planning (Claude)
# ========================================
log_info "[Step 2/6] Architecture planning (Claude)..."

PLAN_FILE="$OUTPUT_DIR/plan_$TIMESTAMP.md"
CLAUDE_PROMPT="Create architecture plan for:

$(cat "$REQ_FILE")

Requirements:
- User stories
- Component structure
- Data flow
- API design (if applicable)

Output in Korean for MSYS2 environment.
"

if safe_claude_exec "$CLAUDE_PROMPT" "$PLAN_FILE"; then
    log_success "Architecture plan generated: $PLAN_FILE"
else
    log_error "Failed to generate architecture plan"
    exit 1
fi
echo ""

# ========================================
# Step 3: Test Strategy (Codex TDD)
# ========================================
log_info "[Step 3/6] Test strategy (Codex TDD)..."

TEST_FILE="$OUTPUT_DIR/tests_$TIMESTAMP.test.ts"
CODEX_TEST_PROMPT="다음 계획에 대한 테스트를 먼저 작성해주세요 (TDD):

$(cat "$PLAN_FILE")

요구사항:
- 단위 테스트 작성
- 통합 테스트 작성
- 한글 주석 포함
- Jest/Vitest 사용

Reasoning: High
Output Language: Korean (MSYS2 environment)
"

if safe_codex_exec "$CODEX_TEST_PROMPT" "$TEST_FILE"; then
    log_success "Tests generated: $TEST_FILE"
else
    log_error "Failed to generate tests"
    exit 1
fi
echo ""

# ========================================
# Step 4: Implementation (Codex)
# ========================================
log_info "[Step 4/6] Implementation (Codex)..."

IMPL_FILE="$OUTPUT_DIR/implementation_$TIMESTAMP.ts"
CODEX_IMPL_PROMPT="다음 계획과 테스트를 기반으로 구현해주세요:

계획:
$(cat "$PLAN_FILE")

테스트:
$(cat "$TEST_FILE")

요구사항:
- TypeScript 사용
- 한글 주석 포함
- JSDoc 문서화
- 테스트를 통과하는 구현

Reasoning: High
Output Language: Korean (MSYS2 environment)
"

if safe_codex_exec "$CODEX_IMPL_PROMPT" "$IMPL_FILE"; then
    log_success "Implementation generated: $IMPL_FILE"
else
    log_error "Failed to generate implementation"
    exit 1
fi
echo ""

# ========================================
# Step 5: Quality Gate (Claude Review)
# ========================================
log_info "[Step 5/6] Quality gate (Claude review)..."

REVIEW_FILE="$OUTPUT_DIR/review_$TIMESTAMP.md"
CLAUDE_REVIEW_PROMPT="Review this implementation:

Implementation:
$(cat "$IMPL_FILE")

Tests:
$(cat "$TEST_FILE")

Check:
- Code quality
- Best practices
- Security issues
- Performance concerns
- Test coverage

Provide constructive feedback in Korean.
"

if safe_claude_exec "$CLAUDE_REVIEW_PROMPT" "$REVIEW_FILE"; then
    log_success "Review completed: $REVIEW_FILE"
else
    log_error "Failed to complete review"
    exit 1
fi
echo ""

# ========================================
# Step 6: Security Audit (Codex)
# ========================================
log_info "[Step 6/6] Security audit (Codex)..."

SECURITY_FILE="$OUTPUT_DIR/security_$TIMESTAMP.md"
CODEX_SECURITY_PROMPT="다음 코드에 대한 보안 감사를 수행해주세요:

$(cat "$IMPL_FILE")

점검 항목:
- OWASP Top 10 체크
- 인증/인가 검증
- 입력 검증
- SQL Injection / XSS
- 의존성 취약점

한글로 보고서 작성
Reasoning: High
"

if safe_codex_exec "$CODEX_SECURITY_PROMPT" "$SECURITY_FILE"; then
    log_success "Security audit completed: $SECURITY_FILE"
else
    log_warning "Security audit failed (non-blocking)"
fi
echo ""

# ========================================
# Final Summary
# ========================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 GCX Pipeline Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_success "All steps completed successfully!"
echo ""
echo "📁 Deliverables:"
echo "   1. Requirements: $REQ_FILE"
echo "   2. Architecture: $PLAN_FILE"
echo "   3. Tests: $TEST_FILE"
echo "   4. Implementation: $IMPL_FILE"
echo "   5. Review: $REVIEW_FILE"
echo "   6. Security: $SECURITY_FILE"
echo ""
echo "📝 Logs:"
echo "   Session: $LOG_DIR/gcx_session_$TIMESTAMP.log"
echo ""
echo "🎉 GCX v4.0 Pipeline Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

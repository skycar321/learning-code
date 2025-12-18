#!/bin/bash
# .gcx/tests/gcx_verification_v4_sample.sh
# GCX v4.0 Verification Script (Haiku + Codex Mini)

export LANG=ko_KR.UTF-8
export LC_ALL=ko_KR.UTF-8
LOG_DIR=".gcx/pipeline/logs"
OUT_DIR=".gcx/output"
mkdir -p "$LOG_DIR" "$OUT_DIR"

TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
echo "🚀 GCX v4.0 Verification Start: $TIMESTAMP" | tee "$LOG_DIR/gemini_start_$TIMESTAMP.log"

# 1. Pre-flight Check (Codex Config)
echo "🔍 Checking Codex Configuration..."
if [ -f ~/.codex/config.toml ]; then
    grep "model_reasoning_effort" ~/.codex/config.toml
else
    echo "⚠️  ~/.codex/config.toml not found (Skipping config check)"
fi

# 2. Architect: Claude Haiku
echo "🏗️  [1/2] Claude (Haiku) Planning..."
PLAN_FILE="$OUT_DIR/plan_fibonacci_$TIMESTAMP.md"

# Simulate Claude call if CLI not present, otherwise run it
if command -v claude &> /dev/null; then
    claude -p "Create a simple architecture for a Python Fibonacci calculator. Keep it brief." --model haiku | tee "$PLAN_FILE"
    if [ ${PIPESTATUS[0]} -eq 0 ]; then echo "✅ Claude Plan Created"; else echo "❌ Claude Failed"; exit 1; fi
else
    echo "⚠️  'claude' CLI not found. creating dummy plan for test."
    echo "# Fibonacci Plan (Mock)" > "$PLAN_FILE"
    echo "- Function: fib(n)" >> "$PLAN_FILE"
    echo "- Returns: list of n numbers" >> "$PLAN_FILE"
fi

# 3. Implementation: Codex Mini
echo "💻 [2/2] Codex (Mini) Implementing..."
CODE_FILE="$OUT_DIR/fibonacci_$TIMESTAMP.py"

if command -v codex &> /dev/null; then
    codex exec -m "gpt-5.1-codex-mini" "
    다음 계획에 따라 파이썬 코드를 작성해주세요:
    $(cat $PLAN_FILE)
    
    요구사항:
    - 한글 주석 필수
    - 에러 처리 포함
    " | tee "$CODE_FILE"
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then echo "✅ Codex Implementation Complete"; else echo "❌ Codex Failed"; exit 1; fi
else
    echo "⚠️  'codex' CLI not found. creating dummy code for test."
    echo "def fib(n): # 피보나치 함수" > "$CODE_FILE"
    echo "    pass" >> "$CODE_FILE"
fi

echo "🏁 Verification Finished."

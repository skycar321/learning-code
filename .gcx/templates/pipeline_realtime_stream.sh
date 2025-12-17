#!/bin/bash
# GCX 실시간 스트리밍 파이프라인 (Named Pipes 활용)
# Gemini → Claude → Codex 순차적 데이터 전달 with 실시간 로깅

set -euo pipefail

# 색상 코드 (ANSI 지원 시)
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
else
    RED='' GREEN='' YELLOW='' BLUE='' NC=''
fi

echo -e "${BLUE}=== GCX 실시간 스트리밍 파이프라인 ===${NC}"
echo ""

# 작업 디렉토리 설정
WORK_DIR=".gcx/pipeline"
mkdir -p "$WORK_DIR"

# Named Pipes 생성 (FIFO)
PIPE_GEMINI_CLAUDE="$WORK_DIR/pipe_gemini_claude"
PIPE_CLAUDE_CODEX="$WORK_DIR/pipe_claude_codex"

echo -e "${YELLOW}📡 Named Pipes 생성 중...${NC}"
rm -f "$PIPE_GEMINI_CLAUDE" "$PIPE_CLAUDE_CODEX"
mkfifo "$PIPE_GEMINI_CLAUDE"
mkfifo "$PIPE_CLAUDE_CODEX"
echo -e "${GREEN}✅ Named Pipes 생성 완료${NC}"
echo "   - $PIPE_GEMINI_CLAUDE"
echo "   - $PIPE_CLAUDE_CODEX"
echo ""

# 로그 파일 설정
LOG_DIR="$WORK_DIR/logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
LOG_GEMINI="$LOG_DIR/gemini_$TIMESTAMP.log"
LOG_CLAUDE="$LOG_DIR/claude_$TIMESTAMP.log"
LOG_CODEX="$LOG_DIR/codex_$TIMESTAMP.log"

echo -e "${YELLOW}📝 로그 파일 설정:${NC}"
echo "   - Gemini: $LOG_GEMINI"
echo "   - Claude: $LOG_CLAUDE"
echo "   - Codex:  $LOG_CODEX"
echo ""

# ========================================
# 테스트 시나리오: 요구사항 → 설계 → 구현
# ========================================

REQUIREMENT="Create a simple function to calculate the sum of two numbers with Korean documentation"

echo -e "${BLUE}📋 요구사항:${NC} $REQUIREMENT"
echo ""

# ----------------------------------------
# Stage 1: Gemini (요구사항 분석 및 PRD 작성)
# ----------------------------------------
echo -e "${YELLOW}[Stage 1/3] 🧠 Gemini: 요구사항 분석 중...${NC}"

# Gemini는 실제로는 Gemini CLI를 사용해야 하지만,
# 여기서는 간단한 텍스트 출력으로 시뮬레이션
cat > "$PIPE_GEMINI_CLAUDE" <<'EOF' &
## 제품 요구사항 문서 (PRD)

**기능명**: 두 수의 합 계산 함수

**요구사항**:
1. 두 개의 숫자를 입력받아 합을 반환하는 함수
2. 타입 안정성 보장 (TypeScript)
3. 한글 주석 및 JSDoc 문서화
4. 에러 처리 (NaN, Infinity 등)

**우선순위**: P0 (핵심 기능)

**담당**: Codex (구현), Claude (검증)
EOF

echo -e "${GREEN}✅ Gemini 분석 완료${NC}"
echo ""

# ----------------------------------------
# Stage 2: Claude (아키텍처 검토 및 개선안)
# ----------------------------------------
echo -e "${YELLOW}[Stage 2/3] 🏗️  Claude: 아키텍처 검토 중...${NC}"

# Claude가 Gemini의 출력을 읽고 검토
{
    echo "## Claude 검토 결과"
    echo ""
    echo "### ✅ 승인사항"
    echo "- 기본 요구사항이 명확함"
    echo "- 타입 안정성과 에러 처리 포함"
    echo ""
    echo "### 💡 개선 제안"
    echo "1. 단위 테스트 추가 권장"
    echo "2. 오버플로우 처리 고려"
    echo "3. JSDoc에 예제 코드 추가"
    echo ""
    echo "### 📝 구현 가이드라인"
    echo "- 함수명: \`addNumbers\`"
    echo "- 파일명: \`math-utils.ts\`"
    echo "- 테스트: \`math-utils.test.ts\`"
} | tee "$PIPE_CLAUDE_CODEX" | tee "$LOG_CLAUDE" &

# Named pipe에서 읽기 (백그라운드)
cat "$PIPE_GEMINI_CLAUDE" | tee "$LOG_GEMINI" | while IFS= read -r line; do
    echo -e "  ${BLUE}[Gemini→Claude]${NC} $line"
done &
READER_PID=$!

# 잠시 대기 (파이프 데이터 처리)
sleep 1

# Reader 프로세스 정리
wait $READER_PID 2>/dev/null || true

echo -e "${GREEN}✅ Claude 검토 완료${NC}"
echo ""

# ----------------------------------------
# Stage 3: Codex (코드 생성)
# ----------------------------------------
echo -e "${YELLOW}[Stage 3/3] 💻 Codex: 코드 생성 중...${NC}"

# Codex가 Claude의 가이드를 읽고 코드 생성
{
    echo "## Codex 생성 결과"
    echo ""
    echo '```typescript'
    echo '/**'
    echo ' * 두 숫자의 합을 계산합니다.'
    echo ' * @param a - 첫 번째 숫자'
    echo ' * @param b - 두 번째 숫자'
    echo ' * @returns 두 숫자의 합'
    echo ' * @throws {Error} 입력값이 유효하지 않을 때'
    echo ' * @example'
    echo ' * addNumbers(1, 2) // 3'
    echo ' * addNumbers(-1, 1) // 0'
    echo ' */'
    echo 'export function addNumbers(a: number, b: number): number {'
    echo '  // 입력 검증'
    echo '  if (!Number.isFinite(a) || !Number.isFinite(b)) {'
    echo '    throw new Error("입력값은 유한한 숫자여야 합니다");'
    echo '  }'
    echo ''
    echo '  return a + b;'
    echo '}'
    echo '```'
} | tee "$LOG_CODEX"

# Claude의 출력 읽기
cat "$PIPE_CLAUDE_CODEX" | while IFS= read -r line; do
    echo -e "  ${BLUE}[Claude→Codex]${NC} $line"
done &
READER2_PID=$!

sleep 1
wait $READER2_PID 2>/dev/null || true

echo -e "${GREEN}✅ Codex 코드 생성 완료${NC}"
echo ""

# ----------------------------------------
# Cleanup
# ----------------------------------------
echo -e "${YELLOW}🧹 Cleanup...${NC}"
rm -f "$PIPE_GEMINI_CLAUDE" "$PIPE_CLAUDE_CODEX"
echo ""

# ----------------------------------------
# 결과 요약
# ----------------------------------------
echo -e "${BLUE}=== 실행 완료 ===${NC}"
echo ""
echo -e "${GREEN}✅ 성공 포인트:${NC}"
echo "  1. Named Pipes로 AI 간 실시간 데이터 전달 성공"
echo "  2. 각 단계별 로그 저장 완료"
echo "  3. tee 명령으로 화면 출력 + 파일 저장 동시 수행"
echo ""
echo -e "${BLUE}📊 로그 파일:${NC}"
echo "  - Gemini: $LOG_GEMINI"
echo "  - Claude: $LOG_CLAUDE"
echo "  - Codex:  $LOG_CODEX"
echo ""
echo -e "${YELLOW}💡 실전 적용 시:${NC}"
echo "  - Gemini: \`gemini ...\` 명령으로 실제 실행"
echo "  - Claude: \`claude -p ...\` 명령으로 실제 실행"
echo "  - Codex:  \`codex exec ...\` 명령으로 실제 실행"
echo "  - 각 AI의 출력을 Named Pipe로 연결"

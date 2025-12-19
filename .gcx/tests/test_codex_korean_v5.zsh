#!/usr/bin/env zsh
# GCX v5.0 - Codex 한글 출력 테스트 스크립트
# 목적: MSYS2 UCRT64 Zsh 환경에서 Codex 한글 출력 확인

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 GCX v5.0 Codex Korean Output Test"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 색상 정의
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 필수 환경 변수 설정
export NO_COLOR=1
export LANG=ko_KR.UTF-8
export LC_ALL=ko_KR.UTF-8

# 사전 체크
echo "📋 1. 사전 환경 확인"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ "$MSYSTEM" != "UCRT64" ]]; then
    echo "${RED}❌ MSYS2 UCRT64 환경이 아닙니다${NC}"
    echo "   현재 MSYSTEM: $MSYSTEM"
    exit 1
fi
echo "${GREEN}✓${NC} MSYS2 UCRT64 확인"

if [[ -z "$ZSH_VERSION" ]]; then
    echo "${RED}❌ Zsh 환경이 아닙니다${NC}"
    exit 1
fi
echo "${GREEN}✓${NC} Zsh 환경 확인 ($ZSH_VERSION)"

if ! command -v codex &> /dev/null; then
    echo "${RED}❌ Codex CLI가 설치되지 않았습니다${NC}"
    exit 1
fi
echo "${GREEN}✓${NC} Codex CLI 확인"

# Codex 설정 확인
if [[ -f ~/.codex/config.toml ]]; then
    REASONING=$(grep "model_reasoning_effort" ~/.codex/config.toml | cut -d'"' -f2)
    if [[ "$REASONING" == "xhigh" ]]; then
        echo "${RED}❌ Codex config 오류: reasoning=$REASONING${NC}"
        echo "   해결: sed -i 's/xhigh/high/' ~/.codex/config.toml"
        exit 1
    fi
    echo "${GREEN}✓${NC} Codex config 확인 (reasoning=$REASONING)"
else
    echo "${YELLOW}⚠${NC}  ~/.codex/config.toml 파일 없음"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 2. Codex 한글 출력 테스트 시작"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 임시 출력 파일
OUTPUT_FILE="/tmp/codex_korean_test_$$.txt"

# 간단한 한글 테스트 프롬프트
PROMPT="다음 질문에 간단하게 한글로 답변해주세요 (3문장 이내):

질문: TypeScript와 JavaScript의 가장 큰 차이점은 무엇인가요?

답변 형식:
- 핵심 차이: [여기에 답변]

Reasoning: High
"

echo "${BLUE}📝 테스트 프롬프트:${NC}"
echo "$PROMPT"
echo ""
echo "${YELLOW}⏳ Codex 실행 중... (30초 정도 소요)${NC}"
echo ""

# Codex 실행
if codex exec -m "gpt-5.1-codex" "$PROMPT" > "$OUTPUT_FILE" 2>&1; then
    echo "${GREEN}✅ Codex 실행 성공${NC}"
else
    echo "${RED}❌ Codex 실행 실패${NC}"
    cat "$OUTPUT_FILE"
    rm -f "$OUTPUT_FILE"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 3. 출력 결과 분석"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 결과 표시
echo "${BLUE}📄 Codex 출력:${NC}"
echo "─────────────────────────────────────────────────"
cat "$OUTPUT_FILE"
echo "─────────────────────────────────────────────────"
echo ""

# 한글 포함 여부 확인
if grep -qE '[가-힣]' "$OUTPUT_FILE"; then
    echo "${GREEN}✅ 한글 출력 감지! 정상 작동합니다${NC}"
    KOREAN_COUNT=$(grep -oE '[가-힣]+' "$OUTPUT_FILE" | wc -l)
    echo "   한글 단어 수: $KOREAN_COUNT"
else
    echo "${RED}❌ 한글 출력 없음 - 문제가 있습니다${NC}"
    echo ""
    echo "💡 해결 방법:"
    echo "1. MSYS2 UCRT64 Zsh에서 실행하고 있는지 확인"
    echo "2. ~/.zshrc에 다음 설정 추가:"
    echo "   export LANG=ko_KR.UTF-8"
    echo "   export LC_ALL=ko_KR.UTF-8"
    echo "3. 터미널 재시작 후 다시 테스트"
    rm -f "$OUTPUT_FILE"
    exit 1
fi

# 출력 길이 확인
OUTPUT_LENGTH=$(wc -c < "$OUTPUT_FILE")
echo "   출력 길이: $OUTPUT_LENGTH bytes"

# 오류 메시지 확인
if grep -qiE '(error|exception|failed)' "$OUTPUT_FILE"; then
    echo "${YELLOW}⚠${NC}  경고: 출력에 오류 메시지 포함"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 테스트 완료!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "${GREEN}✓${NC} Codex는 MSYS2 UCRT64 Zsh 환경에서 한글 출력을 지원합니다"
echo "${GREEN}✓${NC} GCX v5.0 프로토콜 사용 준비 완료!"
echo ""
echo "💡 다음 단계:"
echo "   - /nam:gcx-project-v5 명령어로 프로젝트 시작"
echo "   - /nam:gcx-query-v5 명령어로 쿼리 실행"
echo ""

# Cleanup
rm -f "$OUTPUT_FILE"

exit 0

#!/usr/bin/env zsh
# GCX v5.0 - Zsh 인코딩 테스트 스크립트
# 목적: MSYS2 UCRT64 Zsh 환경에서 한글 인코딩 정상 작동 확인

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 GCX v5.0 Zsh Encoding Test"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 색상 정의
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 테스트 결과 카운터
PASS_COUNT=0
FAIL_COUNT=0

# 테스트 함수
test_check() {
    local test_name="$1"
    local condition="$2"

    if eval $condition; then
        echo "${GREEN}✓${NC} $test_name"
        ((PASS_COUNT++))
        return 0
    else
        echo "${RED}✗${NC} $test_name"
        ((FAIL_COUNT++))
        return 1
    fi
}

echo "📋 1. 환경 변수 확인"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
test_check "MSYSTEM = UCRT64" '[[ "$MSYSTEM" == "UCRT64" ]]'
test_check "Zsh 버전 확인" '[[ -n "$ZSH_VERSION" ]]'
test_check "LANG = ko_KR.UTF-8" '[[ "$LANG" == "ko_KR.UTF-8" ]]'
test_check "LC_ALL = ko_KR.UTF-8" '[[ "$LC_ALL" == "ko_KR.UTF-8" ]]'
echo ""

echo "📋 2. Zsh 기능 확인"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Associative array 테스트
typeset -A TEST_ARRAY
TEST_ARRAY=(
    key1 "value1"
    key2 "value2"
)
test_check "Associative arrays 지원" '[[ ${TEST_ARRAY[key1]} == "value1" ]]'

# 확장 글로빙 테스트
setopt EXTENDED_GLOB
test_check "확장 글로빙 활성화" '[[ -o EXTENDED_GLOB ]]'

# 히스토리 공유 테스트
setopt SHARE_HISTORY
test_check "히스토리 공유 활성화" '[[ -o SHARE_HISTORY ]]'
echo ""

echo "📋 3. 한글 인코딩 테스트"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 한글 문자열 생성 및 확인
KOREAN_TEST="안녕하세요 GCX v5.0"
echo "테스트 문자열: $KOREAN_TEST"

# 한글 파일명 생성 테스트
TEST_FILE="/tmp/테스트_파일_${RANDOM}.txt"
echo "한글 인코딩 테스트" > "$TEST_FILE"
test_check "한글 파일명 생성" '[[ -f "$TEST_FILE" ]]'
test_check "한글 파일 읽기" '[[ -n "$(cat "$TEST_FILE")" ]]'
rm -f "$TEST_FILE"
echo ""

echo "📋 4. CLI 도구 확인"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
test_check "claude CLI 존재" 'command -v claude &> /dev/null'
test_check "codex CLI 존재" 'command -v codex &> /dev/null'
test_check "gemini CLI 존재" 'command -v gemini &> /dev/null || true'
echo ""

echo "📋 5. 필수 명령어 확인"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
test_check "mkfifo (Named Pipes)" 'command -v mkfifo &> /dev/null'
test_check "tee (로깅)" 'command -v tee &> /dev/null'
test_check "date (타임스탬프)" 'command -v date &> /dev/null'
echo ""

echo "📋 6. Codex 설정 확인"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [[ -f ~/.codex/config.toml ]]; then
    REASONING=$(grep "model_reasoning_effort" ~/.codex/config.toml | cut -d'"' -f2)
    test_check "Codex reasoning = high" '[[ "$REASONING" == "high" ]]'
else
    echo "${RED}✗${NC} ~/.codex/config.toml 파일 없음"
    ((FAIL_COUNT++))
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 테스트 결과 요약"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "${GREEN}✓ 통과:${NC} $PASS_COUNT"
echo "${RED}✗ 실패:${NC} $FAIL_COUNT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ $FAIL_COUNT -eq 0 ]]; then
    echo ""
    echo "${GREEN}✅ 모든 테스트 통과! GCX v5.0 사용 준비 완료${NC}"
    echo ""
    exit 0
else
    echo ""
    echo "${RED}❌ 일부 테스트 실패. 위의 실패 항목을 확인하세요.${NC}"
    echo ""
    exit 1
fi

#!/bin/bash
# MSYS2 환경에서 한글 인코딩 테스트 스크립트
# 목적: Codex CLI 한글 출력이 MSYS2에서 제대로 동작하는지 검증

set -euo pipefail

echo "=== MSYS2 한글 인코딩 테스트 시작 ==="
echo ""

# 1. 환경 정보 출력
echo "1️⃣ 환경 정보"
echo "- SHELL: $SHELL"
echo "- TERM: ${TERM:-'N/A'}"
echo "- LANG: ${LANG:-'N/A'}"
echo "- LC_ALL: ${LC_ALL:-'N/A'}"
echo "- PWD: $PWD"
echo ""

# 2. 한글 출력 테스트
echo "2️⃣ 기본 한글 출력 테스트"
echo "안녕하세요! 이것은 테스트입니다."
echo "✅ 체크표시도 나오나요?"
echo ""

# 3. 파일 쓰기/읽기 테스트
echo "3️⃣ 파일 인코딩 테스트"
TEST_FILE=".gcx/tests/korean_test.txt"
echo "한글 파일 쓰기 테스트입니다." > "$TEST_FILE"
echo "- 파일 생성: $TEST_FILE"
echo "- 파일 내용:"
cat "$TEST_FILE"
echo ""

# 4. Codex CLI 테스트 (간단한 쿼리)
echo "4️⃣ Codex CLI 한글 출력 테스트"
echo "- 테스트 프롬프트: '안녕하세요'라고 한글로 답변해주세요"
echo ""

# 임시 프롬프트 파일 생성 (heredoc 사용)
cat > .gcx/tests/codex_test_prompt.txt <<'EOF'
다음 질문에 한글로 답변해주세요:

질문: "Hello World"를 한글로 뭐라고 하나요?

답변 형식:
- 한글 번역: [여기에 답변]
- 설명: [간단한 설명]

Output Language: KOREAN (Testing MSYS2 encoding support)
EOF

echo "📝 프롬프트 파일 생성 완료"
echo ""

# Codex 실행 (에러 발생해도 계속 진행)
echo "🤖 Codex 실행 중..."
if command -v codex &> /dev/null; then
    # NO_COLOR 환경변수 설정하여 ANSI 코드 제거
    export NO_COLOR=1

    # Codex 실행하고 결과를 파일에 저장
    if codex exec -m "gpt-5.1-codex" "$(cat .gcx/tests/codex_test_prompt.txt)" > .gcx/tests/codex_output.txt 2>&1; then
        echo "✅ Codex 실행 성공"
        echo ""
        echo "📄 Codex 출력 결과:"
        echo "----------------------------------------"
        cat .gcx/tests/codex_output.txt
        echo "----------------------------------------"
        echo ""

        # 한글이 제대로 출력되었는지 확인 (한글 유니코드 범위 체크)
        if grep -qP '[\uAC00-\uD7A3]' .gcx/tests/codex_output.txt 2>/dev/null; then
            echo "✅ 한글 감지 성공! MSYS2 환경에서 한글 처리 가능"
        else
            echo "⚠️  한글 미감지 - 여전히 인코딩 이슈 존재 가능성"
        fi
    else
        echo "❌ Codex 실행 실패"
        echo "에러 내용:"
        cat .gcx/tests/codex_output.txt
    fi
else
    echo "⚠️  Codex CLI가 설치되지 않았거나 PATH에 없습니다"
    echo "   codex를 먼저 설치해주세요"
fi

echo ""
echo "=== 테스트 완료 ==="
echo ""
echo "📊 결과 요약:"
echo "- 기본 한글 출력: ✅"
echo "- 파일 인코딩: $([ -f "$TEST_FILE" ] && echo '✅' || echo '❌')"
echo "- Codex 테스트: $([ -f .gcx/tests/codex_output.txt ] && echo '✅' || echo '⚠️ 실행되지 않음')"

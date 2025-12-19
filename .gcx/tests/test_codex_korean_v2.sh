#!/bin/bash
# Codex 한글 출력 테스트 (reasoning effort CLI 오버라이드)

set -euo pipefail

echo "=== Codex 한글 출력 테스트 v2 (CLI 오버라이드) ==="
echo ""

# NO_COLOR 환경변수 설정
export NO_COLOR=1

# 테스트 1: reasoning effort를 명시적으로 high로 설정
echo "📝 테스트 1: reasoning.effort=high로 강제 설정"
cat > .gcx/tests/prompt_korean.txt <<'EOF'
다음 질문에 한글로 답변해주세요:

질문: "Hello World"를 한글로 뭐라고 하나요?

답변 형식:
- 한글 번역: [여기에 답변]
- 설명: [간단한 설명]

CRITICAL: You MUST respond in KOREAN language, not English.
EOF

echo "🤖 Codex 실행 중..."
echo "   Model: gpt-5.1-codex"
echo "   Config override: reasoning.effort=high"
echo ""

if codex exec -m "gpt-5.1-codex" -c 'reasoning.effort="high"' "$(cat .gcx/tests/prompt_korean.txt)" > .gcx/tests/output_korean.txt 2>&1; then
    echo "✅ Codex 실행 성공!"
    echo ""
    echo "📄 출력 결과:"
    echo "========================================"
    cat .gcx/tests/output_korean.txt
    echo "========================================"
    echo ""

    # 한글 유니코드 범위 체크 (더 정확한 검사)
    if grep -qE '[가-힣]' .gcx/tests/output_korean.txt 2>/dev/null; then
        echo ""
        echo "🎉🎉🎉 대성공! 한글 출력 감지!"
        echo ""
        echo "✅ MSYS2 환경에서 Codex → 한글 직접 출력 가능 확인"
        echo "✅ 더 이상 영어만 강제할 필요 없음"
        echo "✅ Gemini 번역 단계 생략 가능"
        echo ""

        # 출력에서 실제 한글 내용 추출
        echo "🔍 감지된 한글 내용:"
        grep -oE '[가-힣]+' .gcx/tests/output_korean.txt | head -10
        echo ""
    else
        echo ""
        echo "⚠️  한글 미감지"
        echo "   → Codex가 여전히 영어로 응답했을 가능성"
        echo "   → 기존 영어 전용 정책 유지 필요"
        echo ""
    fi
else
    echo "❌ Codex 실행 실패"
    echo ""
    echo "에러 로그:"
    cat .gcx/tests/output_korean.txt
    echo ""
fi

echo "=== 테스트 완료 ==="
echo ""

# 결과 파일 보존
echo "📁 결과 파일 저장됨:"
echo "   - .gcx/tests/prompt_korean.txt"
echo "   - .gcx/tests/output_korean.txt"

#!/bin/bash
# Codex 한글 출력 테스트 (reasoning effort 수정 버전)

set -euo pipefail

echo "=== Codex 한글 출력 테스트 (고정 버전) ==="
echo ""

# NO_COLOR 환경변수 설정
export NO_COLOR=1

# 테스트 1: 간단한 한글 질문
echo "📝 테스트 1: 간단한 한글 답변"
cat > .gcx/tests/prompt1.txt <<'EOF'
다음 질문에 한글로 간단하게 답변해주세요:

질문: "Hello World"를 한글로 뭐라고 하나요?

답변 형식:
- 한글 번역: [여기에 답변]
- 설명: [한 줄 설명]

IMPORTANT: Output Language must be KOREAN.
EOF

echo "🤖 Codex 실행 중 (gpt-5.1-codex, reasoning: high)..."
if codex exec -m "gpt-5.1-codex" "$(cat .gcx/tests/prompt1.txt)" > .gcx/tests/output1.txt 2>&1; then
    echo "✅ 실행 성공"
    echo ""
    echo "📄 출력 결과:"
    echo "----------------------------------------"
    cat .gcx/tests/output1.txt
    echo "----------------------------------------"
    echo ""

    # 한글 감지
    if grep -qE '[가-힣]' .gcx/tests/output1.txt 2>/dev/null; then
        echo "✅✅✅ 한글 감지 성공! MSYS2에서 Codex 한글 출력 가능!"
        echo ""
        echo "🎉 의미: 더 이상 영어만 강제할 필요 없음!"
        echo "   → Codex가 직접 한글로 출력 가능"
        echo "   → Gemini의 번역 단계 생략 가능"
    else
        echo "⚠️  한글 미감지 - 여전히 영어 출력 필요"
    fi
else
    echo "❌ 실행 실패"
    cat .gcx/tests/output1.txt
fi

echo ""
echo "=== 테스트 완료 ==="

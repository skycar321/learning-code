#!/usr/bin/env zsh
# GCX v6 Preflight Check
# 환경 검증 스크립트

set -e

echo "==================================================="
echo "GCX v6 Preflight Check"
echo "==================================================="
echo ""

# 색상 정의
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 체크마크
CHECK="${GREEN}✓${NC}"
WARN="${YELLOW}⚠${NC}"
CROSS="${RED}✗${NC}"

# 에러 카운터
ERRORS=0
WARNINGS=0

# 1. 셸 확인
echo "[1/8] 셸 환경 확인"
if [[ -n "$ZSH_VERSION" ]]; then
    echo "  ${CHECK} Zsh 감지: $ZSH_VERSION"
elif [[ -n "$BASH_VERSION" ]]; then
    echo "  ${WARN} Bash 감지: $BASH_VERSION (Zsh 권장)"
    ((WARNINGS++))
else
    echo "  ${CROSS} 알 수 없는 셸"
    ((ERRORS++))
fi
echo ""

# 2. 운영체제 확인
echo "[2/8] 운영체제 확인"
if [[ "$OSTYPE" == "msys"* ]] || [[ "$OSTYPE" == "cygwin"* ]]; then
    echo "  ${CHECK} MSYS2/Cygwin 환경 감지"

    if [[ -n "$MSYSTEM" ]]; then
        if [[ "$MSYSTEM" == "UCRT64" ]]; then
            echo "  ${CHECK} MSYSTEM: UCRT64 (권장)"
        else
            echo "  ${WARN} MSYSTEM: $MSYSTEM (UCRT64 권장)"
            ((WARNINGS++))
        fi
    else
        echo "  ${WARN} MSYSTEM 환경 변수가 설정되지 않았습니다"
        ((WARNINGS++))
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "  ${CHECK} Linux 환경"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "  ${CHECK} macOS 환경"
else
    echo "  ${WARN} 알 수 없는 OS: $OSTYPE"
    ((WARNINGS++))
fi
echo ""

# 3. 로케일 확인
echo "[3/8] 로케일 확인"
if [[ "$LANG" == *"UTF-8"* ]]; then
    echo "  ${CHECK} LANG: $LANG"
else
    echo "  ${WARN} LANG: $LANG (UTF-8 권장)"
    echo "      권장: export LANG=ko_KR.UTF-8"
    ((WARNINGS++))
fi

if [[ "$LANG" == *"ko_KR"* ]]; then
    echo "  ${CHECK} 한글 로케일 설정됨"
else
    echo "  ${WARN} 한글 로케일 미설정 (선택사항)"
fi
echo ""

# 4. Python 확인
echo "[4/8] Python 확인"
if command -v python3 &> /dev/null; then
    PYTHON_VER=$(python3 --version 2>&1 | awk '{print $2}')
    echo "  ${CHECK} Python 3: $PYTHON_VER"
else
    echo "  ${CROSS} Python 3가 설치되어 있지 않습니다"
    ((ERRORS++))
fi
echo ""

# 5. Cygpath 확인 (Windows 전용)
echo "[5/8] Cygpath 확인 (Windows)"
if [[ "$OSTYPE" == "msys"* ]] || [[ "$OSTYPE" == "cygwin"* ]]; then
    if command -v cygpath &> /dev/null; then
        echo "  ${CHECK} cygpath 사용 가능"
    else
        echo "  ${CROSS} cygpath가 설치되어 있지 않습니다"
        echo "      MSYS2 UCRT64 환경을 설치하세요"
        ((ERRORS++))
    fi
else
    echo "  - Windows가 아니므로 스킵"
fi
echo ""

# 6. 디렉토리 구조 확인
echo "[6/8] 디렉토리 구조 확인"
REQUIRED_DIRS=(
    ".claude/lib"
    ".claude/hooks"
    ".claude/agents"
    ".claude/skills"
    ".claude/config"
    ".gcx/state"
    ".gcx/schemas"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        echo "  ${CHECK} $dir"
    else
        echo "  ${CROSS} $dir (없음)"
        ((ERRORS++))
    fi
done
echo ""

# 7. 필수 파일 확인
echo "[7/8] 필수 파일 확인"
REQUIRED_FILES=(
    ".claude/config/models.json"
    ".claude/settings.json"
    ".claude/lib/gcx_core.py"
    ".claude/lib/context_manager.py"
    ".claude/lib/model_config.py"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        echo "  ${CHECK} $file"
    else
        echo "  ${CROSS} $file (없음)"
        ((ERRORS++))
    fi
done
echo ""

# 8. Hook 실행 권한 확인
echo "[8/8] Hook 실행 권한 확인"
HOOK_FILES=(
    ".claude/hooks/user_prompt.py"
    ".claude/hooks/pre_bash.py"
    ".claude/hooks/post_bash.py"
    ".claude/hooks/subagent_stop.py"
)

for hook in "${HOOK_FILES[@]}"; do
    if [[ -f "$hook" ]]; then
        if [[ -x "$hook" ]]; then
            echo "  ${CHECK} $hook (실행 가능)"
        else
            echo "  ${WARN} $hook (실행 권한 없음)"
            echo "      권장: chmod +x $hook"
            ((WARNINGS++))
        fi
    else
        echo "  ${CROSS} $hook (없음)"
        ((ERRORS++))
    fi
done
echo ""

# 최종 결과
echo "==================================================="
echo "결과"
echo "==================================================="

if [[ $ERRORS -eq 0 ]] && [[ $WARNINGS -eq 0 ]]; then
    echo "${GREEN}✅ 모든 검사 통과!${NC}"
    echo ""
    echo "GCX v6를 사용할 준비가 되었습니다."
    echo ""
    echo "사용 방법:"
    echo "  /gcx-project \"프로젝트 설명\""
    exit 0
elif [[ $ERRORS -eq 0 ]]; then
    echo "${YELLOW}⚠️  경고 ${WARNINGS}개${NC}"
    echo ""
    echo "GCX v6를 사용할 수 있지만, 일부 경고가 있습니다."
    echo "위의 권장 사항을 확인하세요."
    exit 0
else
    echo "${RED}❌ 에러 ${ERRORS}개, 경고 ${WARNINGS}개${NC}"
    echo ""
    echo "GCX v6를 사용하기 전에 에러를 수정해야 합니다."
    exit 1
fi

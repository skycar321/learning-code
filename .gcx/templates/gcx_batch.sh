#!/bin/bash
# GCX v4.0 Batch Runner Wrapper
# Python 배치 실행 도구를 쉽게 실행

set -euo pipefail

# Colors
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ $# -eq 0 ]; then
    echo -e "${YELLOW}사용법:${NC}"
    echo "  bash gcx_batch.sh --tasks-file example_tasks.txt"
    echo "  bash gcx_batch.sh --tasks \"작업1\" \"작업2\" \"작업3\""
    echo ""
    echo "예시:"
    echo "  bash gcx_batch.sh --tasks-file .gcx/templates/example_tasks.txt"
    exit 1
fi

echo -e "${CYAN}GCX v4.0 배치 실행 시작...${NC}"
echo ""

# Python 스크립트 실행
python3 .gcx/templates/gcx_batch_runner.py "$@"

exit $?

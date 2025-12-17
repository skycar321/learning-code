#!/bin/bash
# GCX v4.0 Log Analyzer Wrapper
# Python 로그 분석 도구를 쉽게 실행

set -euo pipefail

# Colors
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}GCX v4.0 로그 분석 시작...${NC}"
echo ""

# Python 스크립트 실행
python3 .gcx/templates/gcx_log_analyzer.py "$@"

exit $?

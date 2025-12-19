#!/bin/bash
# GCX v4.0 Cleanup Script
# .gcx 작업 디렉토리 정리
#
# WHEN TO USE:
#   - 디스크 공간 부족할 때
#   - 매주 금요일 로그 정리
#   - 분기별 전체 대청소
#   - 테스트 후 임시 파일 정리
#
# WHAT IT DOES:
#   --logs: pipeline/logs/*.log 삭제
#   --output: output/* 삭제
#   --requirements: 00_requirements/*.md 삭제 (확인 필요!)
#   --all: 위 3가지 모두 (requirements는 확인 후 삭제)
#
# USAGE:
#   bash .gcx/templates/gcx_cleanup.sh --logs
#   bash .gcx/templates/gcx_cleanup.sh --logs --output
#   bash .gcx/templates/gcx_cleanup.sh --all
#
# WARNING: requirements 삭제 시 작업 이력이 사라집니다!
# DURATION: ~5초

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  GCX v4.0 Cleanup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Cleanup 옵션
CLEANUP_LOGS=false
CLEANUP_OUTPUT=false
CLEANUP_REQUIREMENTS=false
CLEANUP_ALL=false

# 파라미터 파싱
while [[ $# -gt 0 ]]; do
    case $1 in
        --logs)
            CLEANUP_LOGS=true
            shift
            ;;
        --output)
            CLEANUP_OUTPUT=true
            shift
            ;;
        --requirements)
            CLEANUP_REQUIREMENTS=true
            shift
            ;;
        --all)
            CLEANUP_ALL=true
            shift
            ;;
        --help|-h)
            echo "Usage: bash gcx_cleanup.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --logs            Clean pipeline logs (.gcx/pipeline/logs/)"
            echo "  --output          Clean output files (.gcx/output/)"
            echo "  --requirements    Clean requirements (.gcx/00_requirements/)"
            echo "  --all             Clean everything (logs + output + requirements)"
            echo "  --help, -h        Show this help"
            echo ""
            echo "Examples:"
            echo "  bash gcx_cleanup.sh --logs"
            echo "  bash gcx_cleanup.sh --logs --output"
            echo "  bash gcx_cleanup.sh --all"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# 옵션이 하나도 없으면 도움말 표시
if ! $CLEANUP_LOGS && ! $CLEANUP_OUTPUT && ! $CLEANUP_REQUIREMENTS && ! $CLEANUP_ALL; then
    echo -e "${YELLOW}No cleanup option specified. Use --help for usage.${NC}"
    echo ""
    echo "Quick examples:"
    echo "  bash gcx_cleanup.sh --logs      # Clean logs only"
    echo "  bash gcx_cleanup.sh --all       # Clean everything"
    exit 0
fi

CLEANED_COUNT=0

# --all 옵션이면 모두 활성화
if $CLEANUP_ALL; then
    CLEANUP_LOGS=true
    CLEANUP_OUTPUT=true
    CLEANUP_REQUIREMENTS=true
fi

# 1. Logs 정리
if $CLEANUP_LOGS; then
    echo -e "${CYAN}[1/3] Cleaning pipeline logs...${NC}"
    if [ -d ".gcx/pipeline/logs" ]; then
        LOG_COUNT=$(find .gcx/pipeline/logs -type f -name "*.log" | wc -l)
        if [ "$LOG_COUNT" -gt 0 ]; then
            rm -f .gcx/pipeline/logs/*.log
            echo -e "  ${GREEN}✅ Removed $LOG_COUNT log file(s)${NC}"
            CLEANED_COUNT=$((CLEANED_COUNT + LOG_COUNT))
        else
            echo -e "  ${BLUE}ℹ️  No log files to clean${NC}"
        fi
    else
        echo -e "  ${BLUE}ℹ️  Log directory doesn't exist${NC}"
    fi
    echo ""
fi

# 2. Output 정리
if $CLEANUP_OUTPUT; then
    echo -e "${CYAN}[2/3] Cleaning output files...${NC}"
    if [ -d ".gcx/output" ]; then
        OUTPUT_COUNT=$(find .gcx/output -type f | wc -l)
        if [ "$OUTPUT_COUNT" -gt 0 ]; then
            rm -rf .gcx/output/*
            echo -e "  ${GREEN}✅ Removed $OUTPUT_COUNT output file(s)${NC}"
            CLEANED_COUNT=$((CLEANED_COUNT + OUTPUT_COUNT))
        else
            echo -e "  ${BLUE}ℹ️  No output files to clean${NC}"
        fi
    else
        echo -e "  ${BLUE}ℹ️  Output directory doesn't exist${NC}"
    fi
    echo ""
fi

# 3. Requirements 정리
if $CLEANUP_REQUIREMENTS; then
    echo -e "${CYAN}[3/3] Cleaning requirements...${NC}"
    echo -e "${YELLOW}⚠️  Warning: This will delete user request history!${NC}"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ -d ".gcx/00_requirements" ]; then
            REQ_COUNT=$(find .gcx/00_requirements -type f -name "*.md" | wc -l)
            if [ "$REQ_COUNT" -gt 0 ]; then
                rm -f .gcx/00_requirements/*.md
                echo -e "  ${GREEN}✅ Removed $REQ_COUNT requirement file(s)${NC}"
                CLEANED_COUNT=$((CLEANED_COUNT + REQ_COUNT))
            else
                echo -e "  ${BLUE}ℹ️  No requirement files to clean${NC}"
            fi
        else
            echo -e "  ${BLUE}ℹ️  Requirements directory doesn't exist${NC}"
        fi
    else
        echo -e "  ${YELLOW}⏭️  Skipped requirements cleanup${NC}"
    fi
    echo ""
fi

# Named Pipes 정리 (있으면)
if [ -p ".gcx/pipeline/pipe_gemini_claude" ] || [ -p ".gcx/pipeline/pipe_claude_codex" ]; then
    echo -e "${CYAN}[Bonus] Cleaning Named Pipes...${NC}"
    rm -f .gcx/pipeline/pipe_*
    echo -e "  ${GREEN}✅ Removed Named Pipes${NC}"
    echo ""
fi

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Cleanup Complete${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "  ${GREEN}Total files cleaned:${NC} $CLEANED_COUNT"
echo ""

# Disk usage 정보
if [ -d ".gcx" ]; then
    DISK_USAGE=$(du -sh .gcx | cut -f1)
    echo -e "  ${BLUE}Current .gcx disk usage:${NC} $DISK_USAGE"
fi

echo ""
echo -e "${GREEN}✅ Cleanup finished!${NC}"

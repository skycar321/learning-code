#!/bin/bash
# MSYS2 기본 셸을 zsh로 변경하는 스크립트
# 실행: bash fix_default_shell.sh
#
# 이 스크립트는 다음을 수행합니다:
# 1. /etc/passwd 파일에서 사용자의 기본 셸을 zsh로 변경
# 2. .bashrc에 자동 zsh 실행 코드 추가
# 3. VSCode 터미널에서 "MSYS2 UCRT64"로 표시되도록 설정

set -e  # 오류 발생 시 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 로그 함수
log_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

log_header() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC} $1"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

clear
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}    MSYS2 기본 셸 변경 도구 (bash → zsh)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

log_info "시작 시간: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Step 0: zsh 설치 확인
log_header "Step 0: zsh 설치 확인"
if ! command -v zsh &> /dev/null; then
    log_error "zsh가 설치되지 않았습니다!"
    echo ""
    log_info "다음 명령어로 zsh를 설치하세요:"
    echo "  pacman -S zsh"
    echo ""
    log_info "또는 전체 자동 설치 스크립트를 실행하세요:"
    echo "  bash scripts/1_msys2_auto_install.sh"
    echo ""
    exit 1
else
    ZSH_PATH=$(command -v zsh)
    log_success "zsh 설치 확인됨: $ZSH_PATH"
fi
echo ""

# Step 1: 백업 생성
log_header "Step 1: 백업 생성"
BACKUP_DIR="$HOME/.msys2_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
log_success "백업 디렉토리 생성: $BACKUP_DIR"

if [ -f /etc/passwd ]; then
    cp /etc/passwd "$BACKUP_DIR/passwd.backup"
    log_success "/etc/passwd 백업 완료"
fi

if [ -f "$HOME/.bashrc" ]; then
    cp "$HOME/.bashrc" "$BACKUP_DIR/.bashrc.backup"
    log_success ".bashrc 백업 완료"
fi
echo ""

# Step 2: /etc/passwd 수정 (기본 로그인 셸 변경)
log_header "Step 2: /etc/passwd 수정 (기본 로그인 셸 변경)"

# 현재 설정 확인
CURRENT_SHELL=$(grep "^${USER}:" /etc/passwd | awk -F: '{print $NF}')
log_info "현재 로그인 셸: $CURRENT_SHELL"

# zsh 경로 확인
if [ -f "/usr/bin/zsh" ]; then
    ZSH_BIN="/usr/bin/zsh"
elif [ -f "/bin/zsh" ]; then
    ZSH_BIN="/bin/zsh"
else
    log_error "zsh 실행 파일을 찾을 수 없습니다!"
    exit 1
fi

log_info "사용할 zsh 경로: $ZSH_BIN"

# /etc/passwd 수정
if grep -q "^${USER}:" /etc/passwd; then
    # 백업 후 수정
    sudo sed -i.bak "s|^\(${USER}:.*:\).*$|\1${ZSH_BIN}|" /etc/passwd 2>/dev/null || \
    sed -i.bak "s|^\(${USER}:.*:\).*$|\1${ZSH_BIN}|" /etc/passwd

    # 수정 확인
    NEW_SHELL=$(grep "^${USER}:" /etc/passwd | awk -F: '{print $NF}')
    if [ "$NEW_SHELL" = "$ZSH_BIN" ]; then
        log_success "/etc/passwd 수정 완료: $NEW_SHELL"
    else
        log_warning "/etc/passwd 수정 실패 (권한 문제일 수 있음)"
        log_info "수동으로 수정하려면:"
        echo "  1. 관리자 권한으로 MSYS2 실행"
        echo "  2. nano /etc/passwd"
        echo "  3. 사용자 줄의 마지막 필드를 $ZSH_BIN으로 변경"
    fi
else
    log_warning "사용자 정보를 /etc/passwd에서 찾을 수 없습니다"
fi
echo ""

# Step 3: .bashrc에 자동 zsh 실행 추가
log_header "Step 3: .bashrc에 자동 zsh 실행 추가"

# .bashrc 파일이 없으면 생성
if [ ! -f "$HOME/.bashrc" ]; then
    touch "$HOME/.bashrc"
    log_info ".bashrc 파일 생성"
fi

# exec zsh 코드가 이미 있는지 확인
if grep -q "exec zsh" "$HOME/.bashrc"; then
    log_success ".bashrc에 이미 'exec zsh' 설정이 있습니다"
else
    # .bashrc 끝에 자동 zsh 실행 코드 추가
    cat >> "$HOME/.bashrc" << 'EOF'

# ============================================================================
# MSYS2: 자동으로 zsh로 전환
# ============================================================================
# bash가 실행되면 자동으로 zsh로 전환합니다.
# VSCode나 다른 터미널에서 bash.exe를 실행해도 zsh가 시작됩니다.

if [ -t 1 ] && command -v zsh &> /dev/null; then
    # 터미널이고 zsh가 설치되어 있으면
    export SHELL=$(command -v zsh)
    exec zsh
fi
EOF

    log_success ".bashrc에 자동 zsh 실행 코드 추가 완료"
    log_info "다음 로그인부터 자동으로 zsh가 실행됩니다"
fi
echo ""

# Step 4: 현재 셸 환경변수 업데이트
log_header "Step 4: 현재 셸 환경변수 업데이트"

# SHELL 환경변수 업데이트
export SHELL=$ZSH_BIN
log_success "현재 세션의 \$SHELL 변수 업데이트: $SHELL"
echo ""

# Step 5: 검증
log_header "Step 5: 변경사항 검증"

echo -e "${CYAN}=== 검증 결과 ===${NC}"
echo ""

# /etc/passwd 확인
FINAL_SHELL=$(grep "^${USER}:" /etc/passwd | awk -F: '{print $NF}')
echo -e "  /etc/passwd 로그인 셸: ${GREEN}$FINAL_SHELL${NC}"

# .bashrc 확인
if grep -q "exec zsh" "$HOME/.bashrc"; then
    echo -e "  .bashrc 자동 zsh 실행: ${GREEN}설정됨${NC}"
else
    echo -e "  .bashrc 자동 zsh 실행: ${YELLOW}설정 안 됨${NC}"
fi

# 현재 SHELL 변수
echo -e "  현재 \$SHELL 변수: ${GREEN}$SHELL${NC}"

echo ""

# Step 6: VSCode 설정 확인 및 안내
log_header "Step 6: VSCode 설정 확인"

VSCODE_SETTINGS="$HOME/AppData/Roaming/Code/User/settings.json"
VSCODE_SETTINGS_ALT="C:/Users/$USER/AppData/Roaming/Code/User/settings.json"

if [ -f "$VSCODE_SETTINGS" ] || [ -f "$VSCODE_SETTINGS_ALT" ]; then
    log_success "VSCode 설정 파일 확인됨"

    echo ""
    echo -e "${CYAN}VSCode 설정 확인 사항:${NC}"
    echo ""
    echo "1. VSCode를 재시작하세요"
    echo "2. 새 터미널을 열어보세요 (Ctrl + \`)"
    echo "3. 터미널 탭을 확인하세요:"
    echo "   - 이름이 'MSYS2 UCRT64'로 표시되어야 함"
    echo "   - 'bash'로 표시되면 configs/vscode_settings_final.json 참조"
    echo ""
    echo -e "${YELLOW}VSCode 설정 파일 위치:${NC}"
    if [ -f "$VSCODE_SETTINGS" ]; then
        echo "  $VSCODE_SETTINGS"
    elif [ -f "$VSCODE_SETTINGS_ALT" ]; then
        echo "  $VSCODE_SETTINGS_ALT"
    fi
    echo ""
    echo -e "${CYAN}올바른 VSCode 설정:${NC}"
    echo '  {
    "terminal.integrated.defaultProfile.windows": "MSYS2 UCRT64",
    "terminal.integrated.profiles.windows": {
      "MSYS2 UCRT64": {
        "path": "C:\\msys64\\usr\\bin\\bash.exe",
        "args": ["--login", "-i"],
        "env": {
          "MSYSTEM": "UCRT64",
          "CHERE_INVOKING": "1",
          "MSYS2_PATH_TYPE": "inherit"
        },
        "icon": "terminal-bash",
        "overrideName": true
      }
    }
  }'
else
    log_warning "VSCode 설정 파일을 찾을 수 없습니다"
    log_info "VSCode가 설치되어 있습니까?"
fi
echo ""

# Step 7: 완료 및 다음 단계
log_header "Step 7: 완료 및 다음 단계"

echo -e "${GREEN}✓ 기본 셸 변경 작업 완료!${NC}"
echo ""
echo -e "${CYAN}=== 다음 단계 ===${NC}"
echo ""
echo "1. ${YELLOW}현재 터미널을 종료하고 새로 열기${NC}"
echo "   - MSYS2 터미널을 완전히 닫고 다시 실행하세요"
echo "   - 또는 'exec zsh' 명령을 직접 실행하세요"
echo ""
echo "2. ${YELLOW}확인 명령어 실행${NC}"
echo "   echo \$SHELL"
echo "   → 출력: /usr/bin/zsh 또는 /bin/zsh"
echo ""
echo "3. ${YELLOW}VSCode에서 확인${NC}"
echo "   - VSCode 재시작"
echo "   - 새 터미널 열기 (Ctrl + \`)"
echo "   - 터미널 탭 이름 확인: 'MSYS2 UCRT64'로 표시되어야 함"
echo ""
echo "4. ${YELLOW}진단 스크립트 실행 (선택사항)${NC}"
echo "   bash scripts/diagnose_terminal.sh"
echo ""
echo -e "${CYAN}=== 백업 파일 ===${NC}"
echo ""
echo "  백업 위치: $BACKUP_DIR"
echo "  - passwd.backup (원본 /etc/passwd)"
echo "  - .bashrc.backup (원본 .bashrc)"
echo ""
echo -e "${YELLOW}문제가 생기면 백업 파일로 복구할 수 있습니다:${NC}"
echo "  cp $BACKUP_DIR/passwd.backup /etc/passwd"
echo "  cp $BACKUP_DIR/.bashrc.backup ~/.bashrc"
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}    작업 완료 - $(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# zsh 실행 제안
echo -e "${CYAN}지금 바로 zsh를 시작하시겠습니까? (y/N)${NC} "
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    log_info "zsh를 시작합니다..."
    exec zsh
else
    log_info "터미널을 재시작하면 zsh가 자동으로 실행됩니다"
fi

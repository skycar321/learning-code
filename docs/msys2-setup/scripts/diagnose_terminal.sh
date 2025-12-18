#!/bin/bash
# MSYS2 터미널 설정 진단 스크립트
# 실행: bash diagnose_terminal.sh

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
echo -e "${BLUE}    MSYS2 터미널 설정 진단 도구${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# 1. 기본 환경 정보
log_header "1. 기본 환경 정보"
log_info "현재 사용자: ${USER:-'(not set)'}"
log_info "홈 디렉토리: ${HOME:-'(not set)'}"
log_info "현재 셸: $0"
log_info "MSYSTEM: ${MSYSTEM:-'(not set)'}"
log_info "PATH: ${PATH:0:100}..."
echo ""

# 2. 기본 로그인 셸 확인
log_header "2. 기본 로그인 셸 확인"
echo -n "echo \$SHELL: "
echo $SHELL

if [ "$SHELL" = "/usr/bin/zsh" ] || [ "$SHELL" = "/bin/zsh" ]; then
    log_success "기본 셸이 zsh로 설정되어 있습니다"
else
    log_warning "기본 셸이 bash입니다: $SHELL"
    log_info "해결: 수정 스크립트를 실행하세요"
fi
echo ""

# 3. /etc/passwd 파일 확인
log_header "3. /etc/passwd 설정 확인"
if [ -f /etc/passwd ]; th2013
en
    USER_LINE=$(grep "^${USER}:" /etc/passwd)
    if [ -n "$USER_LINE" ]; then
        log_info "현재 설정: $USER_LINE"

        LOGIN_SHELL=$(echo $USER_LINE | awk -F: '{print $NF}')
        log_info "로그인 셸: $LOGIN_SHELL"

        if [ "$LOGIN_SHELL" = "/usr/bin/zsh" ] || [ "$LOGIN_SHELL" = "/bin/zsh" ]; then
            log_success "/etc/passwd에 zsh로 설정됨"
        else
            log_warning "/etc/passwd에 bash로 설정됨"
        fi
    else
        log_warning "사용자 정보를 /etc/passwd에서 찾을 수 없습니다"
    fi
else
    log_error "/etc/passwd 파일이 없습니다"
fi
echo ""

# 4. zsh 설치 확인
log_header "4. zsh 설치 확인"
if command -v zsh &> /dev/null; then
    ZSH_PATH=$(command -v zsh)
    ZSH_VERSION=$(zsh --version | head -n1)
    log_success "zsh 설치됨: $ZSH_PATH"
    log_info "버전: $ZSH_VERSION"
else
    log_error "zsh가 설치되지 않았습니다!"
    log_info "해결: pacman -S zsh"
fi
echo ""

# 5. oh-my-zsh 설치 확인
log_header "5. oh-my-zsh 설치 확인"
if [ -d "$HOME/.oh-my-zsh" ]; then
    log_success "oh-my-zsh 설치됨: $HOME/.oh-my-zsh"

    # Powerlevel10k 확인
    if [ -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
        log_success "Powerlevel10k 테마 설치됨"
    else
        log_warning "Powerlevel10k 테마가 설치되지 않았습니다"
    fi

    # 플러그인 확인
    if [ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
        log_success "zsh-autosuggestions 플러그인 설치됨"
    else
        log_warning "zsh-autosuggestions 플러그인이 설치되지 않았습니다"
    fi

    if [ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
        log_success "zsh-syntax-highlighting 플러그인 설치됨"
    else
        log_warning "zsh-syntax-highlighting 플러그인이 설치되지 않았습니다"
    fi
else
    log_error "oh-my-zsh가 설치되지 않았습니다!"
    log_info "해결: bash scripts/1_msys2_auto_install.sh"
fi
echo ""

# 6. .zshrc 파일 확인
log_header "6. .zshrc 설정 확인"
if [ -f "$HOME/.zshrc" ]; then
    log_success ".zshrc 파일 존재: $HOME/.zshrc"

    # 파일 크기
    FILE_SIZE=$(wc -c < "$HOME/.zshrc")
    log_info "파일 크기: $FILE_SIZE bytes"

    # oh-my-zsh 경로 확인
    if grep -q 'ZSH="$HOME/.oh-my-zsh"' "$HOME/.zshrc"; then
        log_success "oh-my-zsh 경로 설정 확인됨"
    else
        log_warning "oh-my-zsh 경로 설정이 없습니다"
    fi

    # Powerlevel10k 테마 확인
    if grep -q 'ZSH_THEME="powerlevel10k/powerlevel10k"' "$HOME/.zshrc"; then
        log_success "Powerlevel10k 테마 설정 확인됨"
    else
        log_warning "Powerlevel10k 테마 설정이 없습니다"
    fi

    # 플러그인 확인
    if grep -q "zsh-autosuggestions" "$HOME/.zshrc"; then
        log_success "zsh-autosuggestions 플러그인 활성화됨"
    else
        log_warning "zsh-autosuggestions 플러그인이 활성화되지 않았습니다"
    fi
else
    log_error ".zshrc 파일이 없습니다!"
    log_info "해결: cp configs/zshrc_template.sh ~/.zshrc"
fi
echo ""

# 7. .bashrc 자동 zsh 실행 확인
log_header "7. .bashrc 자동 zsh 실행 설정 확인"
if [ -f "$HOME/.bashrc" ]; then
    log_success ".bashrc 파일 존재: $HOME/.bashrc"

    # exec zsh 확인
    if grep -q "exec zsh" "$HOME/.bashrc"; then
        log_success ".bashrc에 'exec zsh' 설정 확인됨"
    else
        log_warning ".bashrc에 'exec zsh' 설정이 없습니다"
        log_info "해결: 수정 스크립트를 실행하세요"
    fi
else
    log_warning ".bashrc 파일이 없습니다"
    log_info "해결: 수정 스크립트를 실행하세요"
fi
echo ""

# 8. VSCode 설정 확인
log_header "8. VSCode 설정 확인"
VSCODE_SETTINGS="$HOME/AppData/Roaming/Code/User/settings.json"
VSCODE_SETTINGS_ALT="C:/Users/$USER/AppData/Roaming/Code/User/settings.json"

if [ -f "$VSCODE_SETTINGS" ] || [ -f "$VSCODE_SETTINGS_ALT" ]; then
    log_success "VSCode 설정 파일 존재함"

    # MSYS2 프로필 확인
    if [ -f "$VSCODE_SETTINGS" ]; then
        SETTINGS_FILE="$VSCODE_SETTINGS"
    else
        SETTINGS_FILE="$VSCODE_SETTINGS_ALT"
    fi

    if grep -q "MSYS2 UCRT64" "$SETTINGS_FILE" 2>/dev/null; then
        log_success "VSCode에 MSYS2 UCRT64 프로필 설정 확인됨"
    else
        log_warning "VSCode에 MSYS2 UCRT64 프로필 설정이 없습니다"
        log_info "해결: configs/vscode_settings_final.json 참조"
    fi
else
    log_warning "VSCode 설정 파일을 찾을 수 없습니다"
    log_info "VSCode가 설치되어 있습니까?"
fi
echo ""

# 9. 폰트 확인
log_header "9. Nerd Font 설치 확인"
FONT_DIR_1="C:/Windows/Fonts"
FONT_DIR_2="/c/Windows/Fonts"

if [ -d "$FONT_DIR_2" ]; then
    FONT_COUNT=$(find "$FONT_DIR_2" -iname "*MesloLGS*" 2>/dev/null | wc -l)
    if [ "$FONT_COUNT" -gt 0 ]; then
        log_success "MesloLGS NF 폰트 설치됨 (파일 $FONT_COUNT개)"
    else
        log_warning "MesloLGS NF 폰트가 설치되지 않았습니다"
        log_info "다운로드: https://github.com/romkatv/powerlevel10k#fonts"
    fi
else
    log_warning "폰트 디렉토리 확인 실패"
fi
echo ""

# 10. 요약 및 권장 사항
log_header "10. 진단 요약 및 권장 사항"

echo -e "${CYAN}=== 진단 결과 ===${NC}"
echo ""

# 문제점 체크
ISSUES=0

if [ "$SHELL" != "/usr/bin/zsh" ] && [ "$SHELL" != "/bin/zsh" ]; then
    echo -e "${YELLOW}⚠ 문제 발견:${NC} 기본 셸이 bash입니다"
    echo -e "   ${CYAN}해결:${NC} fix_default_shell.sh 실행"
    ISSUES=$((ISSUES + 1))
fi

if [ ! -f "$HOME/.bashrc" ] || ! grep -q "exec zsh" "$HOME/.bashrc" 2>/dev/null; then
    echo -e "${YELLOW}⚠ 문제 발견:${NC} .bashrc에 자동 zsh 실행 설정이 없습니다"
    echo -e "   ${CYAN}해결:${NC} fix_default_shell.sh 실행"
    ISSUES=$((ISSUES + 1))
fi

if ! command -v zsh &> /dev/null; then
    echo -e "${RED}✗ 문제 발견:${NC} zsh가 설치되지 않았습니다"
    echo -e "   ${CYAN}해결:${NC} pacman -S zsh"
    ISSUES=$((ISSUES + 1))
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${RED}✗ 문제 발견:${NC} oh-my-zsh가 설치되지 않았습니다"
    echo -e "   ${CYAN}해결:${NC} bash scripts/1_msys2_auto_install.sh"
    ISSUES=$((ISSUES + 1))
fi

if [ $ISSUES -eq 0 ]; then
    echo -e "${GREEN}✓ 모든 검사 통과!${NC}"
    echo ""
    echo -e "${GREEN}축하합니다! MSYS2 + zsh + Powerlevel10k 설정이 완벽합니다.${NC}"
    echo ""
    echo -e "${CYAN}다음 단계:${NC}"
    echo "  1. VSCode를 재시작하세요"
    echo "  2. 새 터미널을 열어보세요"
    echo "  3. 터미널 탭에 'MSYS2 UCRT64'가 표시되는지 확인하세요"
    echo "  4. echo \$SHELL을 실행하여 /usr/bin/zsh 또는 /bin/zsh가 출력되는지 확인하세요"
else
    echo ""
    echo -e "${YELLOW}총 $ISSUES개의 문제가 발견되었습니다.${NC}"
    echo ""
    echo -e "${CYAN}권장 조치:${NC}"
    echo "  1. 수정 스크립트 실행: bash scripts/fix_default_shell.sh"
    echo "  2. 터미널 재시작"
    echo "  3. 진단 스크립트 재실행: bash scripts/diagnose_terminal.sh"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}    진단 완료 - $(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

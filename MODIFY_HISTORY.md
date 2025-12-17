## [2025-12-18 00:17:53 KST] 최상위 디렉토리 파일 정리 및 WSL2 디렉토리 생성

**Type**: 정리 및 생성

**Affected Files**:
- 최상위 디렉토리 정리 (*.md, *.sh, *.json)
- `wsl2-setup/` (신규 디렉토리) - WSL2 관련 파일 통합
- `wsl2-setup/README.md` (신규) - WSL2 설정 가이드 모음
- `wsl2-setup/guides/` - 가이드 6개
- `wsl2-setup/reports/` - 보고서 2개
- MSYS2 관련 중복 파일 삭제 (11개)

**Changes**:
- **최상위 디렉토리 정리**
  - MSYS2 관련 파일 → `msys2-setup/`으로 이미 이동됨, 중복 삭제
  - WSL2 관련 파일 → `wsl2-setup/` 신규 생성 후 이동
  - 프로젝트 관리 파일만 유지 (CLAUDE.md, GEMINI.md, MODIFY_HISTORY.md)

- **MSYS2 중복 파일 삭제 (11개)**
  - `cygwin_setup_guide.md` (msys2-setup/guides/에 있음)
  - `fix_zsh_setup.sh` (msys2-setup/scripts/에 있음)
  - `fix_zshrc_error.sh` (msys2-setup/scripts/에 있음)
  - `install_ohmyzsh_msys2.sh` (msys2-setup/scripts/에 있음)
  - `msys2_auto_install.sh` (msys2-setup/scripts/에 있음)
  - `msys2_setup_guide.md` (msys2-setup/guides/에 있음)
  - `msys2_setup_guide_v1_old.md` (구버전, 불필요)
  - `msys2_zshrc_template.sh` (msys2-setup/configs/에 있음)
  - `powershell_ohmyposh_guide.md` (msys2-setup/guides/에 있음)
  - `vscode_msys2_guide.md` (msys2-setup/guides/에 있음)
  - `vscode_msys2_settings.json` (중간 버전, 불필요)
  - `vscode_settings_merged.json` (중간 버전, 불필요)
  - `windows_terminal_msys2.json` (msys2-setup/configs/에 있음)

- **wsl2-setup 디렉토리 생성**
  - 3개 하위 디렉토리: guides, reports, README.md
  - 총 9개 파일 (README 포함)

- **wsl2-setup/README.md 작성**
  - WSL2 설정 가이드 모음 소개
  - 빠른 시작 3가지 옵션
  - 각 가이드 상세 설명 (5개)
  - 보고서 설명 (2개)
  - WSL2 vs MSYS2 비교표
  - 자주 사용하는 WSL 명령어
  - Windows와 WSL2 파일 공유 방법
  - 트러블슈팅 및 추가 리소스

- **wsl2-setup/guides/ 디렉토리 (6개 파일)**
  - `WSL2_Complete_Setup_Guide.md` - 메인 완전 가이드 (A-Z)
  - `wsl2.md` - WSL2 기본 개념
  - `wsl2 copy.md` - WSL2 복사본 (백업)
  - `wsl2_setup_commands.md` - 설치 명령어 모음
  - `wsl2_setup_commands_gitbash.md` - Git Bash용 명령어
  - `wsl2_tools_guide.md` - Modern CLI 도구 가이드

- **wsl2-setup/reports/ 디렉토리 (2개 파일)**
  - `WSL2_Setup_Final_Report.md` - 최종 설치 보고서
  - `WSL2_Setup_Report.md` - 설치 과정 기록

**Reason**:
사용자 요청: "현재 경로 최상위에 있는 *.md, *.sh 중에 불필요한내용은 삭제하고 필요한내용들은 취합해서 디렉토리에 보관해줘"

최상위 디렉토리가 너무 많은 파일로 복잡해져서:
1. MSYS2 관련 파일 중복 제거 (msys2-setup에 이미 있음)
2. WSL2 관련 파일 통합 관리 (wsl2-setup 신규 생성)
3. 프로젝트 관리 파일만 최상위에 유지
4. 카테고리별 디렉토리 구조화 (msys2-setup, wsl2-setup)
5. 각 디렉토리에 README.md 제공하여 독립적 사용 가능

**최종 디렉토리 구조:**
```
learning-code/
├── CLAUDE.md                  (프로젝트 설정)
├── GEMINI.md                  (프로젝트 설정)
├── MODIFY_HISTORY.md          (변경 이력)
├── msys2-setup/               (12개 파일)
│   ├── README.md
│   ├── scripts/               (4개)
│   ├── configs/               (3개)
│   └── guides/                (4개)
└── wsl2-setup/                (9개 파일)
    ├── README.md
    ├── guides/                (6개)
    └── reports/               (2개)
```

**AI Collaborator**:
- 없음 (Claude 단독 작업)

**Related Issue/Request**:
"현재 경로 최상위에 있는 *.md, *.sh 중에 불필요한내용은 삭제하고 필요한내용들은 취합해서 디렉토리에 보관해줘"

---

## [2025-12-18 00:05:10 KST] MSYS2 설치 파일 통합 디렉토리 생성

**Type**: 생성 및 정리

**Affected Files**:
- `msys2-setup/` (신규 디렉토리) - 모든 MSYS2 관련 파일 통합
- `msys2-setup/README.md` (신규) - 빠른 시작 가이드 (한글)
- `msys2-setup/scripts/` - 설치 스크립트 4개
- `msys2-setup/configs/` - 설정 파일 3개
- `msys2-setup/guides/` - 상세 가이드 4개

**Changes**:
- **msys2-setup 통합 디렉토리 생성**
  - 3개 하위 디렉토리: scripts, configs, guides
  - 총 12개 파일 (README 포함)
  - 디렉토리만 보면 전체 설치 가능한 구조

- **README.md 작성 (핵심 파일)**
  - 빠른 시작 (Quick Start) 3단계 가이드
  - 자동/수동 설치 방법 모두 포함
  - 디렉토리 구조 상세 설명
  - 문제 해결 8가지 케이스
  - Powerlevel10k 설정 가이드 (추천 답변 포함)
  - 유용한 명령어 및 함수 목록 (20+ Git aliases, 15+ functions)
  - 설정 파일 적용 방법 (Windows Terminal, VS Code)
  - 참고 자료 및 공식 문서 링크
  - 팁, 업데이트 방법 등

- **scripts/ 디렉토리 (4개 파일)**
  - `1_msys2_auto_install.sh` - 메인 자동 설치 스크립트
  - `2_install_ohmyzsh.sh` - oh-my-zsh 단독 설치
  - `fix_zshrc_error.sh` - .zshrc 오류 수정
  - `fix_zsh_setup.sh` - zsh 설정 전체 재설정

- **configs/ 디렉토리 (3개 파일)**
  - `windows_terminal_msys2.json` - Windows Terminal 설정
  - `vscode_settings_final.json` - VS Code 완전한 설정
  - `zshrc_template.sh` - .zshrc 템플릿

- **guides/ 디렉토리 (4개 파일)**
  - `msys2_setup_guide.md` - 메인 상세 가이드
  - `vscode_msys2_guide.md` - VS Code 통합 가이드
  - `powershell_ohmyposh_guide.md` - PowerShell 대안
  - `cygwin_setup_guide.md` - Cygwin 대안

**Reason**:
사용자 요청: "msys2_setup_guide 파일 취합및 쉘파일 가이드에 추가해주고 관련파일 디렉토리하나 생성해서 거기에 몰아놔줘 그 디렉토리에 파일만 보면 전체 설치 가능하도록"

흩어진 MSYS2 관련 파일들을 하나의 디렉토리로 통합하여:
1. 파일 관리 용이성 향상
2. 신규 사용자가 쉽게 찾을 수 있음
3. README.md 하나만 보면 전체 설치 가능
4. 배포 및 공유 편리함
5. 체계적인 디렉토리 구조 (scripts, configs, guides)

**AI Collaborator**:
- 없음 (Claude 단독 작업)

**Related Issue/Request**:
"msys2_setup_guide 파일 취합및 쉘파일 가이드에 추가해주고 관련파일 디렉토리하나 생성해서 거기에 몰아놔줘 그 디렉토리에 파일만 보면 전체 설치 가능하도록"

---

## [2025-12-17 22:31:25 KST] VS Code 터미널 탭 이름 표시 수정

**Type**: 수정

**Affected Files**:
- `vscode_settings_final.json` (신규) - 터미널 탭 이름 표시 수정된 완전한 설정
- `vscode_settings_merged.json` (신규) - Git Bash 병합된 설정

**Changes**:
- **VS Code 터미널 탭 이름 표시 문제 해결**
  - 핵심 설정 추가:
    - `overrideName: true` - 각 프로필에 추가 (bash 대신 프로필 이름 표시)
    - `terminal.integrated.tabs.title: "${process}"` - 프로필 이름을 탭 제목으로
    - `terminal.integrated.tabs.description: "${cwdFolder}"` - 폴더 이름을 설명으로
  - 3가지 탭 제목 옵션 제공:
    1. 깔끔한 스타일: 프로필 이름 + 폴더명
    2. 상세 정보: 프로필 + 셸 + 폴더명
    3. 아이콘 추가: 이모지 + 프로필 + 정보
  - 터미널 탭 변수 목록 문서화 (${process}, ${cwdFolder} 등)
  - 탭 동작 최적화 (항상 표시, 액션 버튼 등)

- **Git Bash와 MSYS2 병합 설정 (vscode_settings_merged.json)**
  - JSON 구조 오류 수정 (두 개의 객체 → 하나의 객체)
  - 모든 터미널 프로필 통합 (MSYS2, Git Bash, PowerShell, CMD)
  - 기존 설정 유지 (claudeCode, geminicodeassist 등)
  - 터미널 전환 방법 안내

**Reason**:
VS Code 터미널 탭에 "bash"만 표시되고 "MSYS2 UCRT64" 프로필 이름이 표시되지 않는 문제
기본 설정으로는 셸 실행 파일 이름(bash.exe)만 표시됨
`overrideName: true` 설정으로 프로필 이름을 강제 표시

Git Bash 삭제 여부 질문에 대한 답변:
- 삭제 불필요, 여러 프로필을 병합하여 선택 가능하게 구성
- JSON 구조 오류 수정 필요 (두 객체를 하나로 병합)

**AI Collaborator**:
- 없음 (Claude 단독 작업)

**Related Issue/Request**:
"MSYS2 UCRT64 이터미널 선택하면 vscode에서 오른쪽에 터미널이름? 표시되는데 거기에는 msys2가 표시가안되고 bash가보여 이것도 해결필요해"
"기존에있던 gitbash내용은 아예 삭제해야하는거야?"

---

## [2025-12-17 22:17:12 KST] .zshrc 오류 수정 및 VS Code 설정 추가

**Type**: 수정 및 생성

**Affected Files**:
- `fix_zshrc_error.sh` (신규) - .zshrc 오류 수정 스크립트
- `msys2_auto_install.sh` (업데이트) - alias/함수 충돌 수정 및 기능 추가
- `vscode_msys2_settings.json` (신규) - VS Code 설정 파일
- `vscode_msys2_guide.md` (신규) - VS Code 설정 가이드
- `msys2_setup_guide.md` (업데이트) - VS Code 섹션 추가

**Changes**:
- **.zshrc 오류 수정 스크립트 (fix_zshrc_error.sh)** 작성
  - alias 'search'와 function 'search()' 충돌 해결
  - 'search' alias → 'pkgsearch'로 변경
  - 'search()' 함수 → 'findtext()' 함수로 변경
  - 추가 유용한 함수들 포함
  - 자동 백업 기능

- **자동 설치 스크립트 (msys2_auto_install.sh)** 업데이트
  - alias/함수 충돌 방지:
    - `search` alias → `pkgsearch` (pacman -Ss)
    - `search()` 함수 → `findtext()` 함수
    - `extract()` 함수 → `unpack()` 함수 (extract 플러그인 충돌 방지)
  - 추가된 유용한 함수 11개:
    - `psgrep()` - 프로세스 검색
    - `git-clean-branches()` - 병합된 브랜치 정리
    - `serve()` - 간단한 HTTP 서버 (Python)
    - `jsonformat()` - JSON 포맷팅
    - `countlines()` - 코드 라인 수 계산
    - `ltr()` - 디렉토리 트리 (tree 대체)
    - `note()` - 빠른 메모 시스템
    - `diskusage()` - 디스크 사용량 TOP 10
    - `portcheck()` - 포트 사용 확인
    - `aliases()` - alias 검색
    - `envgrep()` - 환경변수 검색

- **VS Code 설정 파일 (vscode_msys2_settings.json)** 작성
  - MSYS2 UCRT64, MINGW64, MSYS 프로필
  - PowerShell, Git Bash, CMD 프로필 (백업용)
  - Nerd Font 설정
  - 터미널 최적화 설정 (복사, 스크롤백, 커서 등)
  - Git 경로 설정
  - Shell 파일 연결 설정

- **VS Code 설정 가이드 (vscode_msys2_guide.md)** 작성
  - JSON 직접 편집 방법 (2분)
  - GUI 설정 방법 (5분)
  - 트러블슈팅 7가지
  - 추가 팁 8가지
  - 단축키 표
  - VS Code 확장 추천 (shellcheck, Bash IDE 등)
  - FAQ 5가지

- **MSYS2 설치 가이드 (msys2_setup_guide.md)** 업데이트
  - VS Code 터미널 설정 섹션 추가 (목차 6번)
  - 2가지 설정 방법 안내
  - 트러블슈팅 섹션
  - 자세한 가이드 링크

**Reason**:
실제 사용 중 발생한 .zshrc 오류 해결:
- `/home/Nam/.zshrc:157: defining function based on alias 'search'` 오류
- Powerlevel10k 설정 파일 로드 실패

사용자 요청 사항 반영:
1. VS Code 기본 터미널을 MSYS2로 변경
2. 자동화 스크립트에 유용한 기능 추가

**AI Collaborator**:
- 없음 (Claude 단독 작업)

**Related Issue/Request**:
"vs code에서 default 터미널도 변경하고싶어 msys2 이걸로"
"이것도 해결되게 해줘 자동화 쉘에 내용추가할수있는건 더 추가해줘"
오류: "/home/Nam/.zshrc:157: defining function based on alias `search'"

---

## [2025-12-17 21:54:12 KST] MSYS2 완벽 설치 가이드 v2 작성 및 자동화 스크립트 추가

**Type**: 생성 및 업데이트

**Affected Files**:
- `msys2_auto_install.sh` (신규) - 완전 자동 설치 스크립트
- `windows_terminal_msys2.json` (신규) - Windows Terminal 설정
- `msys2_setup_guide.md` (업데이트) - 완전히 새로 작성
- `msys2_setup_guide_v1_old.md` (백업) - 기존 버전 백업

**Changes**:
- **완전 자동 설치 스크립트 (msys2_auto_install.sh)** 작성
  - 컬러 로그 출력 (info, success, warning, error)
  - 11단계 자동 설치 프로세스
  - 필수 패키지 13개 자동 설치 (zsh, git, curl, vim, tmux, htop 등)
  - oh-my-zsh 완전 자동 설치 (RUNZSH=no, KEEP_ZSHRC=no)
  - Powerlevel10k 테마 자동 설치
  - zsh 플러그인 2개 자동 설치
  - 완전한 .zshrc 생성 (200+ lines)
    - Git aliases 20+ 개
    - MSYS2 패키지 관리 aliases
    - 디렉토리 단축 aliases
    - 개발 도구 aliases (Python, Node.js, Docker)
    - 유용한 functions (mkcd, search, extract, pskill, backup 등)
    - 고급 히스토리 설정
    - Completion 설정
    - Key bindings (Ctrl+P/N, Home/End, Ctrl+Left/Right)
  - 설치 확인 및 최종 요약
  - 컬러풀한 완료 메시지

- **Windows Terminal JSON 설정 (windows_terminal_msys2.json)** 작성
  - MSYS2 UCRT64 프로필
  - MSYS2 MINGW64 프로필
  - MSYS2 MSYS 프로필
  - 3가지 색상 테마 (One Half Dark, Tokyo Night, Dracula)
  - Nerd Font 설정 (MesloLGS NF)
  - 최적화된 설정 (padding, cursor, acrylic 등)

- **MSYS2 설치 가이드 v2 (msys2_setup_guide.md)** 완전 재작성
  - 목차 및 네비게이션 강화
  - MSYS2 vs Git Bash vs WSL vs PowerShell 상세 비교표
  - 자동 설치 / 수동 설치 선택 가이드
  - 단계별 스크린샷 설명 (텍스트)
  - Powerlevel10k 설정 마법사 완벽 가이드
    - 각 질문별 추천 답변
    - 빠른 설정 (전체 답변 시퀀스)
  - 트러블슈팅 섹션 대폭 강화
    - 실제 겪은 8가지 문제와 해결책
    - oh-my-zsh 경로 문제
    - p10k configure 오류
    - 한글 깨짐
    - Nerd Font 설치
    - pacman GPG 키 오류
    - Windows 경로 문제
    - Git Bash 충돌
    - 터미널 속도 문제
  - Windows Terminal 설정 2가지 방법 (JSON / GUI)
  - MSYS2 환경 종류 설명 (UCRT64, MINGW64, MSYS)
  - 추가 팁 (fzf, tmux, 개발 도구 설치)
  - Windows Terminal 단축키 표
  - 파일 구조 다이어그램
  - FAQ 5가지
  - 설치 파일 목록

**Reason**:
실제 설치 과정에서 겪은 모든 문제와 해결책을 반영하여 완벽한 가이드 작성
- oh-my-zsh 경로 문제 (실제 발생)
- p10k configure 오류 (실제 발생)
- Powerlevel10k 설정 마법사 질문들 (실제 경험)
자동화 스크립트로 5분 안에 완벽한 환경 구축 가능
Windows Terminal JSON 설정으로 복붙만으로 프로필 추가

**AI Collaborator**:
- 없음 (Claude 단독 작업)

**Related Issue/Request**:
"추가로 설치과정 자동화할수있는 부분은 sh로만들어서 가이드에추가해줘"
"추가로 windows terminal에 추가할수있는 json도 만들어줘 가이드에 추가"
"현재내용도 반영해서 설치가이드 업데이트해줘"

---

## [2025-12-17 21:33:09 KST] MSYS2 oh-my-zsh 완전 설치 스크립트 작성

**Type**: 생성

**Affected Files**:
- `install_ohmyzsh_msys2.sh` (신규)

**Changes**:
- **완전 자동화된 oh-my-zsh 설치 스크립트** 작성
  - 환경 확인 (HOME, SHELL, 현재 위치)
  - 필수 패키지 자동 설치 (git, curl, zsh)
  - 기존 oh-my-zsh 완전 제거 후 재설치
  - Powerlevel10k 테마 자동 설치
  - zsh 플러그인 자동 설치 (autosuggestions, syntax-highlighting)
  - 완전한 .zshrc 작성 (instant prompt 포함)
  - .bashrc 자동 설정 (zsh 자동 실행)
  - 설치 확인 및 상세 로깅
  - 디렉토리 단축 alias (proj, downloads, desktop)
  - 고급 히스토리 설정 (중복 제거, 검색)
  - 키 바인딩 (Ctrl+P/N으로 히스토리 검색)

**Reason**:
이전 스크립트(fix_zsh_setup.sh)에서 oh-my-zsh 설치 체크 로직이 잘못되어
"✅ 이미 설치됨"이라고 표시했지만 실제로는 설치되지 않은 문제 발생
`/home/Nam/.zshrc:source:17: no such file or directory: /home/Nam/.oh-my-zsh/oh-my-zsh.sh` 오류
완전히 새로 설치하는 안전한 스크립트로 대체

**AI Collaborator**:
- 없음 (Claude 단독 작업)

**Related Issue/Request**:
"exec zsh 실행 시 '/home/Nam/.zshrc:source:17: no such file or directory: /home/Nam/.oh-my-zsh/oh-my-zsh.sh' 오류"

---

## [2025-12-17 21:23:39 KST] MSYS2 zsh 설정 수정 스크립트 작성

**Type**: 생성

**Affected Files**:
- `msys2_zshrc_template.sh` (신규)
- `fix_zsh_setup.sh` (신규)

**Changes**:
- **MSYS2용 완전한 .zshrc 템플릿** 작성
  - oh-my-zsh 초기화 코드 포함 (source $ZSH/oh-my-zsh.sh)
  - Powerlevel10k 테마 설정
  - zsh-autosuggestions, zsh-syntax-highlighting 플러그인
  - UTF-8 인코딩, 히스토리, 자동완성 설정
  - Git alias, MSYS2 패키지 관리 alias

- **자동 수정 스크립트 (fix_zsh_setup.sh)** 작성
  - 기존 .zshrc 자동 백업 (타임스탬프 포함)
  - oh-my-zsh 자동 설치 (미설치 시)
  - Powerlevel10k 테마 자동 설치 (미설치 시)
  - zsh 플러그인 자동 설치 (autosuggestions, syntax-highlighting)
  - 완전한 .zshrc 자동 생성
  - .bashrc에 zsh 자동 실행 추가 (중복 방지)
  - 단계별 진행 상황 표시

**Reason**:
사용자가 `echo 'ZSH_THEME="..."' >> ~/.zshrc`로 테마만 추가하여
oh-my-zsh 초기화 코드가 없어 `p10k` 명령어를 찾지 못하는 문제 발생
원클릭 수정 스크립트로 완전한 설정을 자동화

**AI Collaborator**:
- 없음 (Claude 단독 작업)

**Related Issue/Request**:
"p10k configure 실행 시 'zsh: command not found: p10k' 오류 발생"

---

## [2025-12-17 21:09:58 KST] PowerShell + Oh My Posh 및 Cygwin 가이드 작성

**Type**: 생성

**Affected Files**:
- `powershell_ohmyposh_guide.md` (신규)
- `cygwin_setup_guide.md` (신규)

**Changes**:
- **PowerShell + Oh My Posh 완벽 가이드** 작성
  - PowerShell 7 설치 방법
  - Oh My Posh 설치 및 테마 설정
  - Nerd Fonts 설치 가이드
  - 프로필 설정 및 커스터마이징
  - PSReadLine, Terminal-Icons, PSFzf, z 모듈 설치
  - Windows Terminal 통합 설정
  - 리눅스 alias 추가 (touch, which, head, tail 등)
  - 트러블슈팅 섹션
  - 커스텀 테마 만들기 고급 가이드
  - 완성된 프로필 전체 예시

- **Cygwin 설치 및 설정 가이드** 작성
  - Cygwin 설치 및 패키지 선택 방법
  - apt-cyg 패키지 관리자 설치
  - zsh + oh-my-zsh + Powerlevel10k 설치
  - Windows Terminal 통합
  - Windows 경로 통합 (cygpath 사용법)
  - fzf, tmux, htop 추가 도구
  - X11 GUI 앱 실행 가이드
  - Cygwin vs MSYS2 vs Git Bash vs WSL 상세 비교
  - 트러블슈팅 섹션

**Reason**:
Windows 환경에서 사용 가능한 모든 터미널 옵션 제공:
1. PowerShell - Windows 네이티브, .NET 통합 완벽
2. Cygwin - 레거시 안정판, POSIX 95% 호환
3. MSYS2 (이전 작성) - 현대적, Pacman 패키지 관리자

각 옵션의 장단점과 사용 상황을 명확히 제시

**AI Collaborator**:
- 없음 (Claude 단독 작업)

**Related Issue/Request**:
"혹시 다른 옵션(PowerShell + Oh My Posh, Cygwin 등) 이것도 가이드 작성해줘"

---

## [2025-12-17 19:11:06 KST] MSYS2 설치 및 zsh 설정 가이드 작성

**Type**: 생성

**Affected Files**:
- `msys2_setup_guide.md` (신규)

**Changes**:
- Windows용 MSYS2 + zsh 완벽 설정 가이드 작성
  - MSYS2 설치 및 초기 설정 방법
  - zsh + oh-my-zsh + Powerlevel10k 테마 설치
  - zsh 플러그인 (autosuggestions, syntax-highlighting) 설정
  - Windows Terminal 통합 방법
  - Nerd Fonts 설치 가이드
  - 유용한 alias 및 환경변수 설정
  - MSYS2 vs Git Bash 상세 비교표
  - 트러블슈팅 섹션 (한글 깨짐, GPG 키 오류, 경로 문제 등)

**Reason**:
WSL 설치가 불가능한 환경에서도 리눅스 명령어와 zsh를 사용할 수 있는 완벽한 대안 제공
Git Bash보다 강력한 Pacman 패키지 관리자와 90%+ 리눅스 명령어 호환성 제공

**AI Collaborator**:
- 없음 (Claude 단독 작업)

**Related Issue/Request**:
"윈도우용 terminal 중에 리눅스명령어 완벽호환가능한거 없어? wsl 설치불가한 환경도있어서 git bash 말고도 zsh처럼 뭔가 이쁘게 구성되어있는 뭔가가 없을까"

---

## [2025-12-17 19:03:36 KST] Git Bash 설정 가이드 문서 작성

**Type**: 생성

**Affected Files**:
- `wsl2_setup_commands_gitbash.md` (신규)

**Changes**:
- Git Bash 전용 설정 가이드 작성
  - 문제 1: 한글 파일명 깨짐 현상 해결 방법
    - Git `core.quotepath` 설정
    - Bash UTF-8 locale 설정
  - 문제 2: 백스페이스 깜박임 문제 해결 방법
    - `.inputrc` 파일 생성 및 벨 비활성화
    - Windows Terminal 벨 알림 설정
  - 전체 설정 일괄 실행 스크립트
  - 추가 팁: MesloLGS NF 폰트 적용, 프롬프트 커스터마이징

**Reason**:
Windows Terminal + Git Bash 사용자들을 위한 통합 설정 가이드 필요
한글 표시와 백스페이스 깜박임 문제를 한 번에 해결할 수 있는 문서 제공

**Related Issue/Request**:
"그리고 gitbash 창에서 백스페이스를 누르면 화면이 깜박여 이증상도 수정필요해"

---

## [2025-12-17 19:03:36 KST] Git Bash 백스페이스 깜박임 문제 해결

**Type**: 설정변경

**Affected Files**:
- `~/.inputrc` (신규 생성)

**Changes**:
- `.inputrc` 파일 생성 및 시스템 벨 비활성화:
  ```bash
  set bell-style none
  ```
- `bind -f ~/.inputrc` 명령으로 즉시 적용

**Reason**:
Git Bash에서 백스페이스 키를 누를 때 화면이 깜박이는 문제 해결
Readline의 시스템 벨(Bell)이 Windows Terminal에서 시각적 피드백으로 표시되는 것을 차단

**Related Issue/Request**:
"그리고 gitbash 창에서 백스페이스를 누르면 화면이 깜박여 이증상도 수정필요해"

---

## [2025-12-17 19:00:52 KST] Git Bash 한글 표시 문제 해결

**Type**: 설정변경

**Affected Files**:
- `~/.bashrc` (UTF-8 locale 설정 추가)
- Git global config (core.quotepath 비활성화)

**Changes**:
- Git 설정 변경: `core.quotepath = false`
  - 비ASCII 문자(한글 등)를 이스케이프하지 않고 원본 그대로 표시
- `~/.bashrc`에 UTF-8 locale 설정 추가:
  ```bash
  export LANG=ko_KR.UTF-8
  export LC_ALL=ko_KR.UTF-8
  ```
- 결과: 파일명 "화면 캡처"가 정상 표시됨 (이전: □□□)

**Reason**:
Windows Terminal의 Git Bash에서 한글 파일명이 깨져 보이는 문제 해결
Git의 기본 quotepath 설정과 locale 미설정으로 인한 인코딩 문제 수정

**Related Issue/Request**:
"windows terminal에서 gitbash 열었는데 이렇게 한글이 잘안보여 해결해줘"

---

## [2025-12-17 18:12:27 KST] WSL2 설정 가이드 업데이트 (v4.0)

**Type**: 수정

**Affected Files**:
- `WSL2_Complete_Setup_Guide.md` (v3.0 → v4.0)

**Changes**:
- **섹션 10: 성능 최적화** 추가
  - WSL 성능 문제 진단 및 해결
  - /mnt/c vs WSL 홈 성능 비교 (5-10배 차이)
  - 프로젝트를 WSL 홈으로 이동하는 방법 (rsync)
  - .zshrc 최적화 (Git 상태 확인 비활성화)
  - 권장 작업 흐름 (개발/백업)

- **섹션 11: 추가 커스터마이징** 추가
  - zsh 테마 변경 (agnoster, robbyrussell)
  - Windows Terminal 색상 스킴 변경 (Solarized Dark 등)
  - Git Bash를 Windows Terminal 프로필에 추가 (JSON/GUI)
  - 단축키로 프로필 열기 설정

- 목차 업데이트 (섹션 10, 11 추가)
- 문서 버전 및 변경 이력 추가

**Reason**:
오늘 실제로 진행한 성능 최적화 및 커스터마이징 작업을 가이드에 반영하여,
다른 컴퓨터에서도 동일한 최적화를 적용할 수 있도록 함

**Related Issue/Request**:
"지금 작업한 내용도 WSL2_Complete_Setup_Guide.md에 추가해줘"

---

## [2025-12-17 17:37:22 KST] WSL2 완벽 설정 가이드 (A-Z) 작성

**Type**: 생성

**Affected Files**:
- `WSL2_Complete_Setup_Guide.md` (신규)

**Changes**:
- 다른 컴퓨터에서 처음부터 끝까지 재현 가능한 WSL2 설정 가이드 작성
- 기존 5개 문서 통합 및 보완:
  - wsl2.md (기본 설치 가이드)
  - wsl2_tools_guide.md (도구 사용법)
  - wsl2_setup_commands.md (명령어 모음)
  - WSL2_Setup_Report.md (설치 결과 보고서)
  - WSL2_Setup_Final_Report.md (최종 보고서)
- 오늘 진행한 추가 작업 포함:
  1. Windows Terminal 설치 및 설정
  2. MesloLGS NF 폰트 다운로드 및 설치
  3. PowerLevel10k 테마 재활성화
  4. zoxide PATH 문제 해결 ($HOME/.local/bin 추가)
  5. VS Code 터미널 폰트 설정 (MesloLGS NF)
  6. .zshrc 최적화 (조건부 zoxide 초기화, instant prompt 경고 억제)

**Reason**:
사용자가 다른 컴퓨터에도 동일한 WSL2 환경을 구축하기 위해 완벽한 A-Z 가이드 요청

**Related Issue/Request**:
"오늘 WSL 설치 및 그 이후 작업한 내용들을 다른 컴퓨터에도 적용해야 해. A-Z를 작성해줘."

---


## [2025-12-12 11:35:00 KST] Airflow 학습 콘텐츠 추가
**Type**: 생성
**Affected Files**:
- `content/devops/airflow/*` (총 6개 Step)
- `.gcx/00_requirements/*`
- `.gcx/01_planning/*`
**Changes**:
- Apache Airflow 학습을 위한 커리큘럼 및 가이드 작성
- Step 1: 개념, Step 2: Docker 환경, Step 3~4: DAG 예제, Step 5: 테스트, Step 6: 운영
**Reason**: 사용자 요청에 따라 DevOps 카테고리에 Airflow 모듈 추가
**AI Collaborator**:
- Planning: Claude-3 Opus
- Audit: GPT-5.1 Codex Max
---

# WSL2 설정 가이드 모음

> 🎯 **Windows에서 Linux 개발 환경을 완벽하게 구축하기 위한 WSL2 설정 가이드**

## 📋 목차

- [개요](#개요)
- [디렉토리 구조](#디렉토리-구조)
- [빠른 시작](#빠른-시작)
- [가이드 설명](#가이드-설명)
- [보고서 설명](#보고서-설명)
- [참고 사항](#참고-사항)

---

## 📖 개요

이 디렉토리는 Windows에서 WSL2(Windows Subsystem for Linux 2)를 설치하고 설정하는 과정을 문서화한 가이드 모음입니다.

**다루는 내용:**
- WSL2 설치 (Windows 10/11)
- Ubuntu 24.04 초기 설정
- 개발 도구 설치 (Node.js, Python, Rust)
- Modern CLI 환경 (zsh, Oh My Zsh, Powerlevel10k)
- Modern CLI 도구 (ripgrep, fd, fzf, bat, eza, zoxide)
- Windows Terminal 설정
- VS Code WSL 통합
- 트러블슈팅 및 성능 최적화

---

## 📁 디렉토리 구조

```
wsl2-setup/
├── README.md                           ← 지금 보고 있는 파일
├── guides/                             ← 설정 가이드 (5개)
│   ├── WSL2_Complete_Setup_Guide.md      → ⭐ 메인 가이드 (A-Z 완전 가이드)
│   ├── wsl2.md                           → WSL2 기본 개념 및 간단 가이드
│   ├── wsl2_setup_commands.md            → 설치 명령어 모음 (복사-붙여넣기용)
│   ├── wsl2_setup_commands_gitbash.md    → Git Bash용 명령어
│   └── wsl2_tools_guide.md               → Modern CLI 도구 상세 가이드
└── reports/                            ← 설치 보고서 (2개)
    ├── WSL2_Setup_Final_Report.md        → 최종 설치 보고서
    └── WSL2_Setup_Report.md              → 설치 과정 기록
```

---

## 🚀 빠른 시작

### 옵션 1: 완전 가이드 따라하기 (권장) ⭐

새 컴퓨터에 처음부터 완벽하게 설치하려면:

```bash
# 1. 메인 가이드 열기
cat guides/WSL2_Complete_Setup_Guide.md
# 또는 VS Code에서: code guides/WSL2_Complete_Setup_Guide.md

# 2. 단계별로 따라하기 (소요 시간: 40-60분)
#    - WSL2 설치
#    - Ubuntu 초기 설정
#    - 개발 도구 설치
#    - Modern CLI 환경 구축
#    - Windows Terminal 설정
#    - VS Code 통합
```

### 옵션 2: 명령어만 빠르게 실행

명령어만 빠르게 복사해서 실행하려면:

```bash
# PowerShell (Windows에서)
# guides/wsl2_setup_commands.md 참조

# 또는 Git Bash (Windows에서)
# guides/wsl2_setup_commands_gitbash.md 참조

# Ubuntu (WSL2에서)
# guides/wsl2_setup_commands.md의 Ubuntu 섹션 참조
```

### 옵션 3: Modern CLI 도구만 설치

WSL2는 이미 설치되어 있고 CLI 도구만 추가하려면:

```bash
# 1. Modern CLI 도구 가이드 참조
cat guides/wsl2_tools_guide.md

# 2. 원하는 도구만 선택 설치
#    - ripgrep (rg): 빠른 검색
#    - fd: 빠른 파일 찾기
#    - fzf: 퍼지 파인더
#    - bat: cat 개선 버전
#    - eza: ls 개선 버전
#    - zoxide: cd 개선 버전
```

---

## 📚 가이드 설명

### 1. WSL2_Complete_Setup_Guide.md ⭐
**가장 중요한 메인 가이드**

**내용:**
- 시작하기 전 필수 요구사항
- WSL2 설치 (Step-by-Step)
- Ubuntu 초기 설정 (사용자 생성, 패키지 업데이트)
- 개발 도구 설치
  - Node.js v24 LTS (nvm 사용)
  - Python 3.12
  - Rust (rustup 사용)
  - Git 설정
- Modern CLI 환경 구축
  - zsh 설치 및 기본 셸 변경
  - Oh My Zsh 설치
  - Powerlevel10k 테마
  - 유용한 플러그인 (zsh-autosuggestions, zsh-syntax-highlighting 등)
- Modern CLI 도구 설치 (ripgrep, fd, fzf, bat, eza, zoxide)
- Windows Terminal 설정 (프로필, 폰트, 테마)
- VS Code WSL 통합
- 트러블슈팅 (13가지 일반적인 문제와 해결책)
- 성능 최적화 (메모리, 디스크, 네트워크)
- 추가 커스터마이징

**추천 대상:**
- WSL2를 처음 설치하는 사람
- 완벽한 개발 환경을 구축하고 싶은 사람
- 단계별 상세 설명이 필요한 사람

**소요 시간:** 40-60분

---

### 2. wsl2.md
**WSL2 기본 개념 및 간단 가이드**

**내용:**
- WSL2란 무엇인가
- WSL1 vs WSL2 비교
- 주요 특징 및 장점
- 기본 설치 명령어
- 자주 사용하는 명령어

**추천 대상:**
- WSL2가 무엇인지 알고 싶은 사람
- 간단한 설치만 필요한 사람
- 빠른 참조가 필요한 사람

---

### 3. wsl2_setup_commands.md
**설치 명령어 모음 (복사-붙여넣기용)**

**내용:**
- PowerShell 명령어 (WSL2 설치)
- Ubuntu 초기 설정 명령어
- 개발 도구 설치 스크립트
- Modern CLI 환경 구축 명령어
- 한 번에 복사해서 실행 가능

**추천 대상:**
- 설명 없이 명령어만 필요한 사람
- 빠르게 설치하고 싶은 사람
- 자동화 스크립트를 만들고 싶은 사람

---

### 4. wsl2_setup_commands_gitbash.md
**Git Bash용 명령어**

**내용:**
- Git Bash에서 WSL2 설치 명령어
- Windows와 WSL2 간 상호작용
- Git Bash 특화 명령어

**추천 대상:**
- PowerShell 대신 Git Bash를 사용하는 사람
- Git Bash 환경에서 WSL2를 관리하고 싶은 사람

---

### 5. wsl2_tools_guide.md
**Modern CLI 도구 상세 가이드**

**내용:**
- 각 도구의 상세 설명 및 설치 방법
- ripgrep (rg): 초고속 grep 대체
- fd: find 명령어 개선 버전
- fzf: 퍼지 파인더 (명령어 히스토리 검색 등)
- bat: syntax highlighting이 있는 cat
- eza: 색상과 아이콘이 있는 ls
- zoxide: 스마트한 cd (자주 가는 디렉토리 기억)
- 각 도구의 사용 예제
- .zshrc 설정 (aliases, 환경변수)

**추천 대상:**
- CLI 도구를 더 효율적으로 사용하고 싶은 사람
- Modern CLI 환경을 구축하고 싶은 사람
- 각 도구의 자세한 사용법을 알고 싶은 사람

---

## 📝 보고서 설명

### 1. WSL2_Setup_Final_Report.md
**최종 설치 보고서**

**내용:**
- 설치 완료 후 최종 상태 정리
- 설치된 도구 목록 및 버전
- 주요 설정 요약
- 확인 사항 체크리스트
- 다음 단계 제안

**용도:**
- 설치가 제대로 되었는지 확인
- 설치된 내용 정리 및 기록
- 팀원에게 공유할 설치 내역

---

### 2. WSL2_Setup_Report.md
**설치 과정 기록**

**내용:**
- 설치 과정 중 발생한 문제
- 해결 방법 및 트러블슈팅
- 주의사항 및 팁
- 시간별 진행 상황

**용도:**
- 설치 과정 중 겪은 문제 기록
- 나중에 재설치 시 참고
- 트러블슈팅 케이스 스터디

---

## 🔧 참고 사항

### WSL2 vs MSYS2 비교

이 프로젝트에는 두 가지 Windows 터미널 솔루션이 있습니다:

| 항목 | WSL2 | MSYS2 |
|------|------|-------|
| **위치** | `wsl2-setup/` | `msys2-setup/` |
| **개념** | 진짜 Linux (가상화) | Windows 네이티브 POSIX |
| **성능** | 우수 (커널 레벨) | 매우 빠름 (네이티브) |
| **호환성** | Linux 100% 호환 | POSIX 도구 호환 |
| **파일 시스템** | 별도 (ext4) | Windows NTFS |
| **설치 크기** | 크다 (~2GB) | 작다 (~500MB) |
| **추천 대상** | 서버 개발, Docker | 일반 CLI, Windows 개발 |

**언제 WSL2를 사용할까?**
- 실제 Linux 환경이 필요할 때
- Docker, Kubernetes 개발
- 서버 사이드 개발 (Node.js, Python, Rust)
- Linux 전용 도구 사용

**언제 MSYS2를 사용할까?**
- Windows 파일 시스템과 긴밀하게 작업
- 빠른 CLI 도구만 필요
- 가벼운 환경 선호
- Git Bash 업그레이드 버전

---

## 💡 추가 팁

### 자주 사용하는 WSL 명령어 (Windows에서)

```powershell
# WSL2 시작
wsl

# 특정 배포판 실행
wsl -d Ubuntu-24.04

# WSL2 종료
wsl --shutdown

# 배포판 목록 확인
wsl --list --verbose

# 기본 배포판 설정
wsl --set-default Ubuntu-24.04

# WSL 버전 업데이트
wsl --update
```

### Windows와 WSL2 파일 공유

```bash
# WSL에서 Windows 파일 접근
cd /mnt/c/Users/$USER/Documents

# Windows에서 WSL 파일 접근
\\wsl$\Ubuntu-24.04\home\username
```

### VS Code에서 WSL 열기

```bash
# WSL 터미널에서
code .

# Windows에서 (WSL 확장 필요)
code --remote wsl+Ubuntu-24.04 /home/username/project
```

---

## 🆘 문제 해결

자주 발생하는 문제들:

### 1. WSL2 설치 실패
→ `guides/WSL2_Complete_Setup_Guide.md`의 트러블슈팅 섹션 참조

### 2. Windows Terminal 폰트 깨짐
→ MesloLGS NF 폰트 설치 필요 (가이드 참조)

### 3. VS Code WSL 연결 실패
→ "WSL" 확장 설치 확인

### 4. 성능 느림
→ `.wslconfig` 파일 설정 (가이드의 성능 최적화 섹션)

---

## 📚 추가 리소스

### 공식 문서
- [WSL 공식 문서](https://docs.microsoft.com/windows/wsl/)
- [Ubuntu WSL](https://ubuntu.com/wsl)
- [Windows Terminal 문서](https://docs.microsoft.com/windows/terminal/)

### 관련 도구
- [Oh My Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Modern Unix Tools](https://github.com/ibraheemdev/modern-unix)

---

## 📝 변경 이력

- **2025-12-18**: WSL2 관련 파일 정리 및 디렉토리 구조화
- **2025-12-17**: 완전 설치 가이드 작성
- **2025-12-17**: 설치 보고서 작성
- **2025-12-17**: Modern CLI 도구 가이드 추가

---

**작성자:** Nam
**프로젝트:** learning-code
**관련 디렉토리:** `msys2-setup/` (MSYS2 대안)

**Happy Linux on Windows! 🐧🪟**

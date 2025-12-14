# Linux 명령어 학습 계획

## 개요 (Overview)
Linux 명령줄 인터페이스(CLI)는 서버 관리, 개발 환경 설정 및 자동화에 필수적인 기술입니다. 이 학습 계획은 Linux CLI의 기본부터 실무에 유용한 고급 명령어까지 다루어 시스템을 효율적으로 제어하고 작업을 자동화하는 능력을 키우는 것을 목표로 합니다.

## 학습 목표 (Learning Objectives)
*   Linux 파일 시스템 및 기본 명령어 이해
*   파일 및 디렉토리 관리 능력 향상
*   프로세스 관리 및 시스템 모니터링
*   쉘 스크립트의 기초 및 활용
*   네트워크 관련 명령어 활용 능력 습득

## 학습 내용 (Learning Content)

### 1단계: Linux 기본 개념 및 파일 시스템 (Linux Basics & File System)
*   Linux 운영체제 개요 (Introduction to Linux OS)
*   쉘(Shell)의 이해 (Understanding Shell) - Bash
*   파일 시스템 계층 구조 (File System Hierarchy Standard, FHS)
*   기본 명령어 (Basic Commands)
    *   `pwd`, `ls`, `cd`, `mkdir`, `rmdir`
    *   `touch`, `cat`, `less`, `more`
    *   `cp`, `mv`, `rm`
    *   `man`, `help` (명령어 도움말)

| 명령 | 예상 출력/효과 (초보용) |
| --- | --- |
| `pwd` | 현재 작업 디렉터리 경로 표시 (예: `/home/user`) |
| `ls -l` | 파일 목록을 권한/크기/날짜와 함께 표 형태로 출력 |
| `cd ~` | 홈 디렉터리로 이동 |
| `mkdir demo && cd demo` | `demo` 폴더 생성 후 이동 |
| `touch hello.txt && ls` | 빈 파일 생성 후 목록에 `hello.txt` 보임 |
| `cat /etc/os-release` | 사용 중인 리눅스 배포판 정보 출력 |

> 연습 팁: 각 명령 뒤에 `&& pwd`를 붙여 이동 결과를 바로 확인하면 헷갈림을 줄일 수 있습니다.

### 3단계: 프로세스/시스템 모니터링 빠른 표
| 명령 | 기대 출력/효과 | 흔한 실수 |
| --- | --- | --- |
| `ps aux | head` | 실행 중인 프로세스 목록 확인 | 파이프/grep 없이 전체에서 찾으려다 스크롤 폭주 |
| `top` / `htop` | 실시간 CPU/메모리 사용 확인 | root 권한 없다고 종료; `q`로 종료 모름 |
| `kill <pid>` | 지정 PID 프로세스 종료 | 잘못된 PID 종료 → 서비스 중단 |
| `kill -9 <pid>` | 강제 종료 | 먼저 `kill` 신호 보내지 않고 바로 -9 남발 |
| `free -h` | 메모리 사용량 표시 | 캐시/버퍼를 모두 사용량으로 오해 |
| `df -h` | 디스크 사용량 표시 | 마운트 포인트 혼동, 루트 디스크 아닌 다른 파티션 확인 누락 |


### 2단계: 파일 및 디렉토리 관리 (File & Directory Management)
*   파일 권한 (File Permissions)
    *   `chmod`, `chown`, `chgrp`
*   파일 검색 (File Searching)
    *   `find`, `grep` (텍스트 검색)
*   아카이브 및 압축 (Archiving & Compression)
    *   `tar`, `gzip`, `unzip`
*   심볼릭 링크 (Symbolic Links)
    *   `ln -s`

### 3단계: 프로세스 관리 및 시스템 모니터링 (Process Management & System Monitoring)
*   프로세스 이해 (Understanding Processes)
*   프로세스 제어 (Process Control)
    *   `ps`, `top`, `htop` (프로세스 모니터링)
    *   `kill`, `killall` (프로세스 종료)
*   백그라운드 작업 (Background Jobs)
    *   `&`, `jobs`, `fg`, `bg`, `nohup`
*   시스템 자원 확인 (System Resource Monitoring)
    *   `df`, `du`, `free`, `uptime`

### 4단계: 입출력 리다이렉션 및 파이프 (I/O Redirection & Pipes)
*   표준 입출력 (Standard I/O) - stdin, stdout, stderr
*   입출력 리다이렉션 (I/O Redirection)
    *   `>`, `>>`, `<`, `2>`, `&>`
*   파이프 (Pipes)
    *   `|` (명령어 연결)

### 5단계: 쉘 스크립트 기초 (Basic Shell Scripting)
*   스크립트 작성 및 실행 (Writing & Executing Scripts)
*   변수 및 환경 변수 (Variables & Environment Variables)
*   조건문 (`if`, `case`)
*   반복문 (`for`, `while`)
*   함수 (Functions)

### 6단계: 네트워크 명령어 및 기타 유틸리티 (Network Commands & Other Utilities)
*   네트워크 설정 및 진단 (Network Configuration & Diagnostics)
    *   `ip`, `ping`, `netstat`, `ss`, `curl`, `wget`
*   원격 접속 (Remote Access)
    *   `ssh`, `scp` (기본 사용법)
    *   SSH 키 기반 인증 (SSH Key-based Authentication) - `ssh-keygen`, `ssh-copy-id`
    *   SSH Agent 활용 (Using SSH Agent) - `ssh-add`
    *   포트 포워딩 (Port Forwarding) - 로컬(Local), 원격(Remote), 동적(Dynamic)
    *   SSH 설정 파일 (`~/.ssh/config`) 관리
*   패키지 관리자 (Package Managers)
    *   `apt` (Debian/Ubuntu), `yum` (CentOS/RHEL)
*   텍스트 에디터 (Text Editors)
    *   `vi`, `nano` (기본 사용법)

## 예상 학습 시간 (Estimated Learning Time)
*   각 단계별 2-5시간 (총 12-30시간)

## 실습 과제 (Practical Exercises)
*   가상 머신에 Linux 설치 및 기본 환경 설정 (Install Linux in a VM & basic setup)
*   간단한 쉘 스크립트 작성 및 자동화 (Write simple shell scripts & automate tasks)
*   로그 파일 분석 및 시스템 문제 진단 (Analyze log files & diagnose system issues)

## 참고 자료 (References)
*   The Linux Command Line: A Complete Introduction by William E. Shotts, Jr.
*   각종 Linux 배포판 공식 문서 (Official documentation for various Linux distributions)
*   온라인 Linux 튜토리얼 및 강의 (Online Linux tutorials and courses)

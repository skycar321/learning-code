#!/bin/bash

# Linux 명령어 학습 계획 - 6단계: 네트워크 명령어 및 기타 유틸리티
# 이 스크립트는 Linux 시스템에서 네트워크 설정 및 진단, 원격 접속 (SSH),
# 패키지 관리, 그리고 기본적인 텍스트 편집기 사용법을 학습하기 위한 예시들을 포함하고 있습니다.
#
# 네트워크 관리는 서버 운영의 핵심이며, 효율적인 패키지 관리와 텍스트 편집기 사용은
# Linux 환경에서의 작업 생산성을 크게 향상시킵니다.

echo "--- 6단계: 네트워크 명령어 및 기타 유틸리티 ---"

# -----------------------------------------------------------------------------
# 1. 네트워크 설정 및 진단 (Network Configuration & Diagnostics)
# -----------------------------------------------------------------------------
echo "1.1. `ip` - 네트워크 인터페이스 정보 확인 및 설정:"
# `ifconfig`는 레거시 명령어로, `ip`가 더 최신입니다.
echo "  `ip addr show` (또는 `ip a`): 모든 네트워크 인터페이스의 IP 주소 및 상태 확인"
ip addr show | grep -E "inet |link/" | head -n 5 # IP 주소 및 MAC 주소만 간단히 출력
echo "  `ip route show` (또는 `ip r`): 라우팅 테이블 확인"
ip route show | head -n 5
echo ""

echo "1.2. `ping` - 네트워크 연결 확인:"
ping -c 4 google.com # google.com으로 4번 ping 전송
echo "  `ping`은 특정 호스트와의 네트워크 연결 상태를 확인하고 지연 시간(latency)을 측정합니다."
echo ""

echo "1.3. `netstat` / `ss` - 네트워크 연결 및 포트 상태 확인:"
# `netstat`은 레거시 명령어로, `ss`가 더 빠르고 최신입니다.
echo "  `ss -tulnp` (또는 `netstat -tulnp`): 현재 열려 있는 TCP/UDP 포트 및 관련 프로세스 확인"
ss -tulnp | head -n 5 # `-t`: TCP, `-u`: UDP, `-l`: Listening, `-n`: 숫자 포트, `-p`: 프로세스명
echo ""

echo "1.4. `curl` / `wget` - 웹 데이터 다운로드 및 요청:"
# `curl`: 다양한 프로토콜(HTTP, HTTPS, FTP 등)을 지원하는 데이터 전송 도구.
# `wget`: 웹 서버에서 파일을 다운로드하는 데 특화된 도구.
echo "  `curl -s https://example.com | head -n 5`: `example.com` 웹 페이지의 상위 5줄 출력"
curl -s https://example.com | head -n 5
echo "  `wget -q -O /dev/null https://example.com`: `example.com` 페이지를 다운로드하지만 내용 출력 없이 조용히 처리"
# wget -q -O /dev/null https://example.com
echo ""

# -----------------------------------------------------------------------------
# 2. 원격 접속 (Remote Access)
# -----------------------------------------------------------------------------
echo "2.1. `ssh` - Secure Shell을 이용한 원격 서버 접속:"
echo "  `ssh user@hostname`: 사용자 이름과 호스트 이름을 지정하여 접속 (예: `ssh ubuntu@192.168.1.100`)"
echo "  `ssh -p 2222 user@hostname`: 특정 포트(2222)를 사용하여 접속"
echo "  `exit` 명령으로 SSH 세션 종료"
echo ""

echo "2.2. `scp` - Secure Copy를 이용한 파일 전송:"
echo "  `scp local_file.txt user@hostname:/remote/path`: 로컬 파일을 원격으로 전송"
echo "  `scp user@hostname:/remote/file.txt local_path`: 원격 파일을 로컬로 가져오기"
echo ""

echo "2.3. SSH 키 기반 인증 (SSH Key-based Authentication):"
echo "  `ssh-keygen`: SSH 공개/개인 키 쌍 생성 (일반적으로 `~/.ssh/id_rsa`, `~/.ssh/id_rsa.pub`)"
echo "  `ssh-copy-id user@hostname`: 로컬 공개 키를 원격 서버에 복사하여 비밀번호 없이 접속 가능하게 설정"
echo "  - 이 방식이 비밀번호 기반 인증보다 안전하고 편리합니다."
echo ""

echo "2.4. SSH Agent 활용:"
echo "  `ssh-agent bash` 또는 `eval \"$(ssh-agent -s)\"`: SSH 에이전트 시작"
echo "  `ssh-add ~/.ssh/id_rsa`: 개인 키를 SSH 에이전트에 추가 (비밀번호 한 번만 입력)"
echo "  - 에이전트에 키가 추가되면 터미널을 다시 열거나 SSH 접속 시 비밀번호를 다시 입력할 필요가 없습니다."
echo ""

echo "2.5. 포트 포워딩 (Port Forwarding):"
echo "  - `ssh -L 8080:localhost:80 user@hostname`: 로컬 포트 8080을 원격 서버의 80 포트로 포워딩 (로컬 포트 포워딩)"
echo "  - `ssh -R 8080:localhost:80 user@hostname`: 원격 포트 8080을 로컬 서버의 80 포트로 포워딩 (원격 포트 포워딩)"
echo ""

echo "2.6. SSH 설정 파일 (`~/.ssh/config`) 관리:"
echo "  SSH 접속 정보를 미리 설정하여 간편하게 접속할 수 있습니다."
echo "  예시 (`~/.ssh/config` 파일 내용):"
echo "    Host myserver"
echo "      Hostname 192.168.1.100"
echo "      User ubuntu"
echo "      Port 22"
echo "      IdentityFile ~/.ssh/id_rsa"
echo "  위와 같이 설정하면 `ssh myserver` 명령만으로 접속 가능합니다."
echo ""

# -----------------------------------------------------------------------------
# 3. 패키지 관리자 (Package Managers)
# - 소프트웨어 패키지(애플리케이션, 라이브러리)를 설치, 업데이트, 제거하는 도구.
# -----------------------------------------------------------------------------
echo "3.1. `apt` (Debian/Ubuntu 계열):"
echo "  `sudo apt update`: 패키지 목록 업데이트"
echo "  `sudo apt install package_name`: 패키지 설치"
echo "  `sudo apt upgrade`: 설치된 모든 패키지 업데이트"
echo "  `sudo apt remove package_name`: 패키지 제거"
echo ""

echo "3.2. `yum` (CentOS/RHEL 계열):"
echo "  `sudo yum check-update`: 패키지 목록 업데이트"
echo "  `sudo yum install package_name`: 패키지 설치"
echo "  `sudo yum update`: 설치된 모든 패키지 업데이트"
echo "  `sudo yum remove package_name`: 패키지 제거"
echo "나쁜 예시: 패키지 관리자 없이 소프트웨어를 수동으로 설치하거나,
  의존성을 직접 해결하려 하는 것."
echo "  - 의존성 충돌, 버전 관리 문제, 보안 취약점 등의 문제가 발생할 수 있습니다."
echo ""

# -----------------------------------------------------------------------------
# 4. 텍스트 에디터 (Text Editors)
# - 명령줄에서 파일을 편집하는 데 사용되는 도구.
# -----------------------------------------------------------------------------
echo "4.1. `vi` (또는 `vim`): 강력하지만 배우기 어려운 에디터"
echo "  `vi filename.txt`: 파일 열기"
echo "  - `i`: 삽입 모드 (편집)
  - `Esc`: 명령 모드
  - `:w`: 저장
  - `:q`: 종료
  - `:wq`: 저장 후 종료
  - `:q!`: 저장하지 않고 종료"
echo ""

echo "4.2. `nano`: 사용하기 쉬운 초보자용 에디터"
echo "  `nano filename.txt`: 파일 열기"
echo "  - 화면 하단에 단축키(`^X`는 `Ctrl+X` 의미)가 표시되어 쉽게 사용 가능"
echo "  - `Ctrl+X`: 종료"
echo ""
echo "나쁜 예시: 중요한 서버 설정 파일을 `vi`나 `nano` 사용법을 제대로 모르고
  수정하려다가 파일을 손상시키거나 저장하지 못하는 것."
echo "  - 기본적인 사용법은 반드시 익혀두어야 합니다."
echo ""

echo "--- 6단계 학습 완료 ---"
echo ""

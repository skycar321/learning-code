#!/bin/bash

# Linux 명령어 학습 계획 - 2단계: 파일 및 디렉토리 관리
# 이 스크립트는 Linux 파일 및 디렉토리의 권한 관리, 검색, 압축/아카이브,
# 그리고 심볼릭 링크 생성과 같은 고급 관리 명령어를 학습하기 위한 예시들을 포함하고 있습니다.
#
# 파일을 효과적으로 관리하고, 필요한 정보를 빠르게 찾으며, 저장 공간을 효율적으로 사용하는 능력은
# Linux 시스템 관리의 핵심입니다.

echo "--- 2단계: 파일 및 디렉토리 관리 ---"

# 학습을 위한 임시 파일 및 디렉토리 생성
mkdir -p my_files/subdir1 my_files/subdir2 > /dev/null 2>&1
echo "File A content." > my_files/file_a.txt
echo "File B content." > my_files/subdir1/file_b.log
echo "Secret info." > my_files/secret_file.conf
echo "More info in File A." >> my_files/file_a.txt
echo "another log entry" >> my_files/subdir1/file_b.log
touch my_files/empty.txt
echo "임시 파일 및 디렉토리 생성 완료."
echo ""

# -----------------------------------------------------------------------------
# 1. 파일 권한 (File Permissions)
# - Linux 파일 시스템은 각 파일 및 디렉토리에 대한 접근 권한을 관리합니다.
# - 권한: 읽기(r), 쓰기(w), 실행(x)
# - 사용자 유형: 소유자(u), 그룹(g), 기타(o), 모든 사용자(a)
# -----------------------------------------------------------------------------
echo "1.1. `ls -l` - 현재 권한 확인:"
ls -l my_files/file_a.txt
echo "  (예: -rw-r--r-- 는 소유자는 읽기/쓰기, 그룹/기타 사용자는 읽기만 가능)"
echo ""

echo "1.2. `chmod` - 파일 권한 변경:"
# 기호 모드 (Symbolic Mode): `u+x`, `g-w`, `o=r`
chmod u+x my_files/file_a.txt # 소유자에게 실행 권한 추가
ls -l my_files/file_a.txt
echo "  (소유자에게 실행 권한 부여)"

# 8진수 모드 (Octal Mode): `rwx`는 4+2+1=7, `rw-`는 4+2+0=6, `r--`는 4+0+0=4
chmod 744 my_files/secret_file.conf # 소유자 rwx, 그룹 r--, 기타 r--
ls -l my_files/secret_file.conf
echo "  (secret_file.conf 권한을 744로 변경: 소유자만 읽기/쓰기/실행, 그룹/기타 읽기만 가능)"
echo "나쁜 예시: `chmod 777`과 같이 모든 사용자에게 모든 권한을 부여하는 것."
echo "  - 보안에 매우 취약하며, 프로덕션 환경에서는 절대 피해야 합니다."
echo ""

echo "1.3. `chown` - 파일 소유자 변경 (root 권한 필요):"
# sudo chown user1 my_files/file_a.txt # user1으로 소유자 변경 (예시)
# ls -l my_files/file_a.txt
echo "  `chown`은 파일의 소유자를 변경합니다. 일반적으로 `root` 권한이 필요합니다."
echo ""

echo "1.4. `chgrp` - 파일 그룹 변경 (root 권한 필요):"
# sudo chgrp group1 my_files/file_a.txt # group1으로 그룹 변경 (예시)
# ls -l my_files/file_a.txt
echo "  `chgrp`은 파일의 그룹을 변경합니다. 일반적으로 `root` 권한이 필요합니다."
echo ""

# -----------------------------------------------------------------------------
# 2. 파일 검색 (File Searching)
# -----------------------------------------------------------------------------
echo "2.1. `find` - 파일 및 디렉토리 검색:"
# `find [경로] [조건]`
echo "  `my_files` 디렉토리에서 '.txt' 확장자를 가진 파일 찾기:"
find my_files -name "*.txt"
echo "  `my_files` 디렉토리에서 크기가 0인 파일 찾기:"
find my_files -size 0
echo "  `my_files` 디렉토리에서 '.log' 파일을 찾고 삭제하기 (주의!):"
# find my_files -name "*.log" -delete
echo "나쁜 예시: `find` 명령어로 `-delete` 옵션 사용 시, `--force`와 같이
        신중하게 확인하지 않고 사용하거나, `find . -exec rm -rf {} \;`와 같이
        매우 위험한 명령어를 무심코 실행하는 것. 항상 `find` 명령의 영향을 먼저 확인해야 합니다."
echo ""

echo "2.2. `grep` - 텍스트 검색:"
# `grep [옵션] [패턴] [파일]`
echo "  `my_files/file_a.txt`에서 'content' 문자열 검색:"
grep "content" my_files/file_a.txt
echo "  `my_files` 디렉토리의 모든 파일에서 'info' 문자열 검색 (`-r` 재귀, `-i` 대소문자 무시, `-n` 줄 번호):"
grep -rin "info" my_files
echo ""

# -----------------------------------------------------------------------------
# 3. 아카이브 및 압축 (Archiving & Compression)
# -----------------------------------------------------------------------------
echo "3.1. `tar` - 아카이브(묶기) 및 압축 (gzip과 함께 사용):"
# `tar -cvf archive.tar files` (묶기), `tar -xvf archive.tar` (풀기)
# `tar -cvzf archive.tar.gz files` (묶고 gzip 압축), `tar -xvzf archive.tar.gz` (풀고 gzip 해제)
tar -cvf my_files.tar my_files > /dev/null # my_files 디렉토리를 my_files.tar로 묶기
tar -cvzf my_files.tar.gz my_files > /dev/null # my_files를 my_files.tar.gz로 묶고 gzip 압축
echo "  `my_files.tar`와 `my_files.tar.gz` 생성 완료."
ls -l my_files.tar my_files.tar.gz
echo ""

echo "3.2. `gzip` / `gunzip` - 파일 압축/해제:"
cp my_files/file_a.txt file_a_copy.txt
gzip file_a_copy.txt # file_a_copy.txt를 file_a_copy.txt.gz로 압축
ls -l file_a_copy.txt.gz
gunzip file_a_copy.txt.gz # file_a_copy.txt.gz를 file_a_copy.txt로 해제
ls -l file_a_copy.txt
echo ""

echo "3.3. `zip` / `unzip` - ZIP 형식 압축/해제:"
zip -r my_files.zip my_files > /dev/null # my_files 디렉토리를 my_files.zip으로 압축
unzip -q my_files.zip -d extracted_files > /dev/null # extracted_files 디렉토리에 압축 해제
echo "  `my_files.zip` 생성 및 `extracted_files` 디렉토리에 압축 해제 완료."
ls -l my_files.zip extracted_files
echo ""

# -----------------------------------------------------------------------------
# 4. 심볼릭 링크 (Symbolic Links)
# - 원본 파일/디렉토리를 가리키는 포인터(바로가기) 역할을 합니다.
# - 원본 파일이 삭제되면 심볼릭 링크는 깨집니다.
# -----------------------------------------------------------------------------
echo "4. `ln -s` - 심볼릭 링크 생성:"
ln -s my_files/file_a.txt my_link_to_file_a.txt
ln -s my_files/subdir1 my_link_to_subdir1
echo "  `my_link_to_file_a.txt`와 `my_link_to_subdir1` 심볼릭 링크 생성 완료."
ls -l my_link_to_file_a.txt my_link_to_subdir1
cat my_link_to_file_a.txt # 링크를 통해 원본 파일 내용 확인
echo ""
# 나쁜 예시: 심볼릭 링크와 하드 링크(ln 명령)의 차이를 이해하지 못하고 사용하는 것.
# - 하드 링크는 원본 파일과 inode를 공유하여 원본 파일이 삭제되어도 데이터가 유지됩니다.
# - 심볼릭 링크는 원본 파일이 삭제되면 '깨진 링크'가 됩니다.

# 생성했던 임시 파일 및 디렉토리 정리
rm -rf my_files my_files.tar my_files.tar.gz my_files.zip extracted_files my_link_to_file_a.txt my_link_to_subdir1 file_a_copy.txt > /dev/null 2>&1
echo "생성된 임시 파일 및 디렉토리가 정리되었습니다."
echo "--- 2단계 학습 완료 ---"
echo ""

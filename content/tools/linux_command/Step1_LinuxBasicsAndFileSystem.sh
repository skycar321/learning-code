#!/bin/bash

# Linux 명령어 학습 계획 - 1단계: Linux 기본 개념 및 파일 시스템
# 이 스크립트는 Linux 파일 시스템의 기본 개념과 파일 및 디렉토리를 조작하는
# 가장 기본적인 명령어를 학습하기 위한 예시들을 포함하고 있습니다.
#
# Linux 명령줄 인터페이스(CLI)는 시스템 관리, 자동화, 개발 환경 설정에 필수적인 도구입니다.

echo "--- 1단계: Linux 기본 개념 및 파일 시스템 ---"

# -----------------------------------------------------------------------------
# 1. Linux 운영체제 개요 및 쉘(Shell)의 이해
# -----------------------------------------------------------------------------
echo "1.1. Linux는 Unix 기반의 오픈소스 운영체제입니다."
echo "1.2. 쉘(Shell)은 사용자와 운영체제 커널 사이의 인터페이스입니다. Bash가 가장 널리 사용됩니다."
echo "    - 쉘은 사용자의 명령을 해석하여 커널에 전달하고, 커널의 응답을 사용자에게 보여줍니다."
echo ""

# -----------------------------------------------------------------------------
# 2. 파일 시스템 계층 구조 (File System Hierarchy Standard, FHS)
# -----------------------------------------------------------------------------
echo "2.1. Linux 파일 시스템은 단일 루트 디렉토리(/)를 중심으로 계층적인 구조를 가집니다."
echo "    - `/bin`: 기본 실행 파일 (binary)
    - `/etc`: 시스템 설정 파일 (editable text configuration)
    - `/home`: 사용자 홈 디렉토리
    - `/var`: 가변 데이터 (로그 파일, 스풀 파일 등)
    - `/usr`: 사용자 프로그램 (Unix System Resources)
    - `/tmp`: 임시 파일 (temporary)"
echo ""

# -----------------------------------------------------------------------------
# 3. 기본 명령어 (Basic Commands) - 파일 및 디렉토리 조작
# -----------------------------------------------------------------------------

# 3.1. `pwd`: 현재 작업 디렉토리(Present Working Directory) 출력
echo "3.1. `pwd` - 현재 디렉토리 확인:"
pwd
echo ""

# 3.2. `ls`: 디렉토리 내용 목록 출력 (list)
echo "3.2. `ls` - 디렉토리 내용 확인:"
ls
echo "  `ls -l`: 파일 및 디렉토리의 상세 정보 출력 (권한, 소유자, 그룹, 크기, 수정 시간 등)"
echo "  `ls -a`: 숨김 파일(.)을 포함한 모든 파일 출력"
echo "  `ls -lh`: 상세 정보를 읽기 쉬운 형식으로 출력 (파일 크기 등)"
echo ""

# 3.3. `cd`: 디렉토리 변경 (change directory)
echo "3.3. `cd` - 디렉토리 변경:"
mkdir temp_dir > /dev/null 2>&1 # 임시 디렉토리 생성 (에러 출력 억제)
cd temp_dir
pwd
echo "  `cd ..`: 상위 디렉토리로 이동"
echo "  `cd ~` 또는 `cd`: 홈 디렉토리로 이동"
echo "  `cd -`: 이전 작업 디렉토리로 이동"
cd .. # 다시 상위 디렉토리로
pwd
echo ""

# 3.4. `mkdir`: 디렉토리 생성 (make directory)
echo "3.4. `mkdir` - 디렉토리 생성:"
mkdir new_directory
echo "  `mkdir -p a/b/c`: 존재하지 않는 상위 디렉토리까지 한 번에 생성"
echo ""

# 3.5. `rmdir`: 빈 디렉토리 삭제 (remove directory)
echo "3.5. `rmdir` - 빈 디렉토리 삭제:"
rmdir new_directory
echo ""
# 나쁜 예시: `rmdir` 명령으로 비어있지 않은 디렉토리를 삭제하려 하는 것.
# - 오류가 발생합니다. 비어있지 않은 디렉토리는 `rm -r`을 사용해야 합니다.

# 3.6. `touch`: 파일 생성 또는 파일의 접근/수정 시간 변경
echo "3.6. `touch` - 파일 생성:"
touch empty_file.txt
echo ""

# 3.7. `cat`: 파일 내용 출력 (concatenate)
echo "3.7. `cat` - 파일 내용 출력:"
echo "Line 1" > file_for_cat.txt
echo "Line 2" >> file_for_cat.txt
cat file_for_cat.txt
echo ""

# 3.8. `less` / `more`: 파일 내용을 페이지 단위로 출력
echo "3.8. `less` / `more` - 파일 내용 페이지 단위 출력 (개념적):"
echo "  `less large_file.log`: 파일을 페이지 단위로 탐색 (앞으로/뒤로 이동 가능, q로 종료)"
echo "  `more large_file.log`: 파일을 페이지 단위로 탐색 (앞으로만 이동, q로 종료)"
echo "  `cat`은 파일 내용이 많을 경우 터미널을 빠르게 지나가 버리므로, 큰 파일은 `less`나 `more`를 사용합니다."
echo ""

# 3.9. `cp`: 파일/디렉토리 복사 (copy)
echo "3.9. `cp` - 파일 복사:"
cp empty_file.txt copied_file.txt
echo "  `cp -r source_dir target_dir`: 디렉토리를 하위 내용까지 복사"
echo ""

# 3.10. `mv`: 파일/디렉토리 이동 또는 이름 변경 (move)
echo "3.10. `mv` - 파일 이동/이름 변경:"
mv copied_file.txt renamed_file.txt
echo "  `mv renamed_file.txt temp_dir/`: 파일을 다른 디렉토리로 이동"
echo ""

# 3.11. `rm`: 파일/디렉토리 삭제 (remove)
echo "3.11. `rm` - 파일 삭제:"
rm empty_file.txt
rm file_for_cat.txt
echo "  `rm -r new_directory`: 비어있지 않은 디렉토리 삭제 (주의! 복구 어려움)"
echo "  `rm -rf force_delete_dir`: 강제로 하위 내용까지 삭제 (매우 위험!)"
echo ""
# 나쁜 예시: `rm -rf /` 와 같이 실수로 시스템의 모든 파일을 삭제할 수 있는 위험한 명령어를
# - 제대로 이해하지 못하고 사용하는 것. `rm` 명령어 사용 시에는 항상 주의해야 합니다.

# 3.12. `man` / `help`: 명령어 도움말 확인
echo "3.12. `man` / `help` - 명령어 도움말:"
echo "  `man ls`: `ls` 명령어의 상세 매뉴얼 페이지 출력 (q로 종료)"
echo "  `ls --help`: `ls` 명령어의 간단한 도움말 출력"
echo ""

# 생성했던 임시 디렉토리 및 파일 정리
cd ..
rm -rf temp_dir new_directory_to_delete > /dev/null 2>&1
rm -f empty_file.txt copied_file.txt renamed_file.txt file_for_cat.txt > /dev/null 2>&1

echo "--- 1단계 학습 완료 ---"
echo "생성된 임시 파일 및 디렉토리가 정리되었습니다."
echo ""

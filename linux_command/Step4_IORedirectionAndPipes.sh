#!/bin/bash

# Linux 명령어 학습 계획 - 4단계: 입출력 리다이렉션 및 파이프
# 이 스크립트는 Linux 쉘에서 명령어가 생성하는 출력(표준 출력, 표준 에러)과
# 입력(표준 입력)을 파일이나 다른 명령어의 입력으로 연결하는 방법인
# 입출력 리다이렉션과 파이프를 학습하기 위한 예시들을 포함하고 있습니다.
#
# 이 기술들은 여러 명령어를 조합하여 복잡한 작업을 자동화하는 데 매우 중요합니다.

echo "--- 4단계: 입출력 리다이렉션 및 파이프 ---"

# -----------------------------------------------------------------------------
# 1. 표준 입출력 (Standard I/O)
# - 모든 명령어는 기본적으로 3가지 표준 스트림을 가집니다.
#   - `0` (stdin): 표준 입력 (키보드 또는 파일로부터 입력)
#   - `1` (stdout): 표준 출력 (화면으로 출력)
#   - `2` (stderr): 표준 에러 (화면으로 에러 메시지 출력)
# -----------------------------------------------------------------------------
echo "1. 표준 입출력 (개념적 설명)"
echo "  명령어는 stdin으로부터 입력을 받고, stdout과 stderr로 결과를 내보냅니다."
echo ""

# -----------------------------------------------------------------------------
# 2. 입출력 리다이렉션 (I/O Redirection)
# - 표준 출력, 표준 에러를 파일로 보내거나, 파일의 내용을 표준 입력으로 사용합니다.
# -----------------------------------------------------------------------------

echo "2.1. `>` - 표준 출력 (stdout)을 파일로 리다이렉션 (파일 덮어쓰기):"
echo "  `ls -l`의 결과를 `ls_output.txt`에 저장 (덮어쓰기):"
ls -l > ls_output.txt
cat ls_output.txt
echo ""

echo "2.2. `>>` - 표준 출력 (stdout)을 파일에 추가 (append):"
echo "  `echo '새로운 라인'`을 `ls_output.txt`에 추가:"
echo "새로운 라인" >> ls_output.txt
cat ls_output.txt
echo ""

echo "2.3. `<` - 파일 내용을 표준 입력 (stdin)으로 사용:"
echo "  `cat` 명령에 `input.txt` 파일 내용을 입력으로 전달:"
echo "Line A" > input.txt
echo "Line B" >> input.txt
cat < input.txt
echo ""

echo "2.4. `2>` - 표준 에러 (stderr)를 파일로 리다이렉션:"
# 존재하지 않는 파일에 `cat` 명령을 실행하면 에러가 발생합니다.
echo "  존재하지 않는 파일에 `cat` 명령 실행 시 에러를 `error.log`에 저장:"
cat non_existent_file.txt 2> error.log
cat error.log
echo ""

echo "2.5. `&>` - 표준 출력과 표준 에러를 모두 파일로 리다이렉션:"
echo "  `ls -l non_existent_dir > output_and_error.log 2>&1` 와 동일"
ls -l non_existent_dir &> output_and_error.log
cat output_and_error.log
echo ""
# 나쁜 예시: 에러 메시지를 `error.log` 파일에만 저장하고,
# - 에러 발생 여부를 확인하지 않거나, 적절히 처리하지 않아 문제가 발생해도 인지하지 못하는 것.
# - 중요한 에러는 로그로 기록하고 알림을 설정하는 것이 좋습니다.

# -----------------------------------------------------------------------------
# 3. 파이프 (Pipes)
# - `|` (파이프) 연산자를 사용하여 한 명령어의 표준 출력을 다른 명령어의 표준 입력으로 연결합니다.
# - 여러 명령어를 조합하여 복잡한 작업을 효율적으로 수행할 수 있습니다.
# -----------------------------------------------------------------------------

echo "3.1. `|` - 파이프를 이용한 명령어 연결:"
echo "  `ls -l` 결과를 `grep`으로 필터링:"
ls -l | grep ".txt"
echo ""

echo "  `ps aux` 결과를 `grep`으로 필터링하여 특정 프로세스 찾기:"
# 현재 실행 중인 모든 프로세스 중 'bash'가 포함된 프로세스 찾기
ps aux | grep "bash" | grep -v "grep" # grep -v "grep"은 grep 명령어 자체를 결과에서 제외
echo ""

echo "  `cat` 결과의 줄 수 세기 (`wc -l`):"
echo "Line 1
Line 2
Line 3" > temp_lines.txt
cat temp_lines.txt | wc -l
echo ""

echo "  복잡한 파이프라인 예시:"
# 현재 디렉토리의 .txt 파일 중 "Line"을 포함하는 파일들을 찾아서 그 내용을 출력
find . -name "*.txt" | xargs cat | grep "Line"
echo ""
# 나쁜 예시: `find . -exec grep "pattern" {} \;` 와 같이 `find -exec`를 사용하는 것.
# - `find -exec`는 각 파일마다 새로운 프로세스를 생성하여 비효율적일 수 있습니다.
# - `find ... | xargs grep "pattern"`과 같이 `xargs`와 파이프를 사용하면 `grep` 프로세스를 한 번만 실행하여 더 효율적입니다.

# 생성했던 임시 파일 정리
rm -f ls_output.txt input.txt error.log output_and_error.log non_existent_file.txt temp_lines.txt > /dev/null 2>&1

echo "--- 4단계 학습 완료 ---"
echo ""

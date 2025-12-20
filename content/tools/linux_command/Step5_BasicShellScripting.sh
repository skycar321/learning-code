#!/bin/bash

# Linux 명령어 학습 계획 - 5단계: 쉘 스크립트 기초
# 이 스크립트는 쉘 스크립트 작성의 기본 개념과 변수, 환경 변수, 조건문, 반복문, 함수 등
# 쉘 스크립트의 핵심 요소들을 학습하기 위한 예시들을 포함하고 있습니다.
#
# 쉘 스크립트는 반복적인 작업을 자동화하고, 여러 명령어를 조합하여 복잡한 로직을 수행하는 데
# 매우 강력하고 유용한 도구입니다.

echo "--- 5단계: 쉘 스크립트 기초 ---"

# -----------------------------------------------------------------------------
# 1. 스크립트 작성 및 실행
# - 첫 줄은 `#!/bin/bash`와 같은 셔뱅(shebang)으로 시작하여 스크립트를 실행할 인터프리터를 지정합니다.
# - 실행 권한 부여: `chmod +x script.sh`
# - 실행: `./script.sh` 또는 `bash script.sh`
# -----------------------------------------------------------------------------
echo "1. 스크립트 작성 및 실행 (개념적 설명)"
echo "  이 파일 자체가 쉘 스크립트의 예시이며, `bash Step5_BasicShellScripting.sh` 명령으로 실행됩니다."
echo ""

# -----------------------------------------------------------------------------
# 2. 변수 및 환경 변수
# - 변수 선언: `VAR_NAME="value"` (등호 양쪽에 공백 없어야 함)
# - 변수 사용: `$VAR_NAME` 또는 `${VAR_NAME}`
# - 환경 변수: `export VAR_NAME="value"` (자식 프로세스에도 전달)
# -----------------------------------------------------------------------------
echo "2.1. 지역 변수 (Local Variables)"
my_variable="Hello Shell Script!"
echo "my_variable의 값: $my_variable"

number_a=10
number_b=20
sum=$((number_a + number_b)) # $((...)) 산술 연산
echo "두 숫자의 합: $sum"

# 나쁜 예시: 변수 사용 시 `$((...))`나 `${}` 없이 사용하는 것 (`echo sum` -> 문자열 "sum" 출력)
# - 또는 `=` 양쪽에 공백을 넣어 변수 선언이 아닌 다른 명령어로 인식하게 하는 것. (`VAR = value`는 오류)

echo "2.2. 환경 변수 (Environment Variables)"
echo "현재 PATH 환경 변수: $PATH"
export MY_ENV_VAR="This is an environment variable."
echo "MY_ENV_VAR: $MY_ENV_VAR"
echo ""

# -----------------------------------------------------------------------------
# 3. 조건문 (`if`, `case`)
# - `if` 문: 조건식의 참/거짓에 따라 다른 코드 블록 실행. `[ ]` 또는 `[[ ]]` 사용.
#   - `[ ]`는 `test` 명령어와 유사하며, `[[ ]]`는 더 유연하고 확장된 기능을 제공합니다.
# - `case` 문: 여러 값 중 하나와 일치하는지 비교할 때 유용.
# -----------------------------------------------------------------------------
echo "3.1. `if` 문"
read -p "나이를 입력하세요: " user_age # 사용자 입력 받기 (테스트 시에는 직접 값 할당)

# read 명령어를 사용하여 터미널에서 사용자 입력을 받습니다.
# 스크립트 자동 실행 시에는 `user_age=25`와 같이 직접 값을 할당하거나
# 스크립트 인자로 받는 방법을 사용해야 합니다.
if [ "$user_age" -ge 18 ]; then # -ge (Greater than or Equal to)
    echo "성인입니다."
elif [ "$user_age" -gt 0 ]; then # -gt (Greater than)
    echo "미성년자입니다."
else
    echo "유효하지 않은 나이입니다."
fi

# 문자열 비교
string1="apple"
string2="banana"
if [ "$string1" == "$string2" ]; then # == (문자열 같음)
    echo "두 문자열은 같습니다."
else
    echo "두 문자열은 다릅니다."
fi

# 파일 존재 여부 확인
file_to_check="file_for_if.txt"
touch "$file_to_check"
if [ -f "$file_to_check" ]; then # -f (파일이 존재하고 일반 파일인지)
    echo "'$file_to_check' 파일이 존재합니다."
fi
rm "$file_to_check"
echo ""

echo "3.2. `case` 문"
read -p "좋아하는 과일 (apple, banana, orange)을 입력하세요: " fruit
case "$fruit" in
    "apple")
        echo "사과를 좋아하시는군요!"
        ;; # 각 케이스 끝에는 `;;`
    "banana"|"orange") # 여러 패턴을 | 로 연결 가능
        echo "바나나 또는 오렌지를 좋아하시는군요!"
        ;;
    *) # 기본값 (Default)
        echo "다른 과일을 좋아하시는군요!"
        ;;
esac
echo ""

# -----------------------------------------------------------------------------
# 4. 반복문 (`for`, `while`)
# -----------------------------------------------------------------------------
echo "4.1. `for` 루프"
echo "  리스트 순회:"
for item in apple banana cherry; do
    echo "과일: $item"
done

echo "  범위 순회:"
for i in {1..3}; do # 1부터 3까지 (Bash 3.0 이상)
    echo "숫자: $i"
done

echo "  C 스타일 for 루프:"
for ((j=0; j<3; j++)); do
    echo "C 스타일 숫자: $j"
done
echo ""

echo "4.2. `while` 루프"
count=0
while [ $count -lt 3 ]; do # -lt (Less than)
    echo "while 루프: $count"
    count=$((count + 1))
done
echo ""
# 나쁜 예시: `while true`와 같이 무한 루프를 사용하면서 종료 조건이 없는 것.
# - 스크립트가 예상치 못하게 계속 실행되어 시스템 자원을 낭비할 수 있습니다.
# - 항상 명확한 종료 조건이나 `break` 문을 포함해야 합니다.

# -----------------------------------------------------------------------------
# 5. 함수 (Functions)
# - 스크립트 내에서 반복되는 코드 블록을 함수로 정의하여 재사용성을 높입니다.
# -----------------------------------------------------------------------------
echo "5. 함수"

# 함수 정의 (두 가지 스타일)
function say_hello {
    echo "함수: 안녕하세요, $1!" # $1은 첫 번째 인자
}

greet_user() { # function 키워드 없이도 정의 가능
    local username=$1 # `local` 키워드로 지역 변수 선언 (함수 외부와 이름 충돌 방지)
    echo "함수: ${username}님, 환영합니다!"
}

# 함수 호출
say_hello "앨리스"
greet_user "밥"

# 나쁜 예시: `local` 키워드 없이 함수 내에서 변수를 선언하여 전역 변수와 이름 충돌을 일으키는 것.
# - 스크립트의 다른 부분에 예상치 못한 영향을 주어 디버깅을 어렵게 합니다.
# - 함수 내에서 선언하는 변수는 항상 `local`로 정의하는 것이 좋습니다.

echo "--- 5단계 학습 완료 ---"
echo ""

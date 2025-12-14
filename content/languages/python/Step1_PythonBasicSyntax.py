# Python 기본 문법
# 변수, 자료형, 연산자, 조건문, 반복문 등 기본 문법 이해

# 나쁜 예시 (bad): 한 줄에 여러 문장을 세미콜론으로 이어 쓰고, 변수명을 모호하게 사용해 읽기 어렵습니다.
#   bad = 1; bad2=2;result=bad+bad2;print(result)
# 좋은 예시 (good): 한 줄에 한 문장, 의미 있는 변수명, PEP8 공백 규칙을 지켜 읽기 쉽게 작성합니다.
#   first = 1
#   second = 2
#   total = first + second
#   print(total)

# 변수와 자료형 (초보자가 바로 따라할 수 있게 간단한 예제)
name = "Alice"                  # 문자열 (string)
age = 30                        # 정수 (int)
height = 1.75                   # 실수 (float)
is_student = True               # 불리언 (bool)
fruits = ["apple", "banana"]    # 리스트 (list)
person = {"name": "Bob", "age": 25}  # 딕셔너리 (dictionary)

print(f"이름: {name}, 나이: {age}, 키: {height}, 학생 여부: {is_student}")

# 연산자
a = 10
b = 3
print(f"덧셈: {a + b}")
print(f"뺄셈: {a - b}")
print(f"곱셈: {a * b}")
print(f"나눗셈: {a / b}")
print(f"몫: {a // b}")
print(f"나머지: {a % b}")
print(f"거듭제곱: {a ** b}")

# 조건문
if age >= 20:
    print("성인입니다.")
elif age >= 14:
    print("청소년입니다.")
else:
    print("어린이입니다.")

# 반복문 (for 루프)
for fruit in fruits:
    print(f"과일: {fruit}")

# 반복문 (while 루프)
count = 0
while count < 3:
    print(f"카운트: {count}")
    count += 1

# 함수 정의 (PEP 8 권장 사항 준수)
def calculate_area(width, height):
    """직사각형의 넓이를 계산하는 함수.

    Args:
        width (int): 가로 길이
        height (int): 세로 길이

    Returns:
        int: 직사각형의 넓이
    """
    return width * height

# 함수 호출
area = calculate_area(5, 4)
print(f"계산된 넓이: {area}")

# 주석 예시 (비전공자도 이해할 수 있게 배경 설명)
# - 아래 로직은 "사용자 입력을 받아 검증 → DB 조회" 흐름을 흉내낸 것이라고 가정합니다.
# - 실제 DB는 사용하지 않지만, 어떤 단계가 추가되어야 하는지 TODO로 남겨 둡니다.
# TODO: 추후에 데이터 검증 로직 추가 필요 (예: 길이, 금지어 필터 등)

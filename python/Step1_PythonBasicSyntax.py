# Python 기본 문법
# 변수, 자료형, 연산자, 조건문, 반복문 등 기본 문법 이해

# 나쁜 예시: 한 줄에 여러 문장을 세미콜론으로 구분하여 작성하거나, 불필요한 괄호를 사용하여 가독성을 떨어뜨립니다.
# 좋은 예시: PEP 8 코딩 스타일 가이드를 준수하여 들여쓰기, 공백 등을 적절히 사용하여 가독성 높은 코드를 작성합니다.

# 변수와 자료형
name = "Alice"  # 문자열 (string)
age = 30        # 정수 (int)
height = 1.75   # 실수 (float)
is_student = True # 불리언 (bool)
fruits = ["apple", "banana", "cherry"] # 리스트 (list)
person = {"name": "Bob", "age": 25} # 딕셔너리 (dictionary)

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

# 주석 예시 (한글)
# 이 부분은 사용자 입력 처리 로직입니다.
# 다음 줄은 데이터베이스에서 정보를 가져오는 함수를 호출합니다.

# TODO: 추후에 데이터 검증 로직 추가 필요

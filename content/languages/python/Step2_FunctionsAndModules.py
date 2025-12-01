# Python 함수와 모듈
# 함수 정의 및 호출, 모듈 생성 및 임포트, 패키지 관리 학습

# 나쁜 예시: 너무 길고 복잡한 단일 함수, 전역 변수에 과도하게 의존하는 함수.
# 좋은 예시: 단일 책임 원칙을 따르는 짧고 명확한 함수, 모듈을 사용하여 코드 구성.

# 함수 정의 및 호출
def greet(name):
    """주어진 이름으로 인사를 건네는 함수."""
    return f"안녕하세요, {name}님!"

message = greet("김철수")
print(message)

# 기본 매개변수
def introduce(name, age=30):
    """이름과 나이를 소개하는 함수 (나이 기본값 30)."""
    print(f"제 이름은 {name}이고, 나이는 {age}세입니다.")

introduce("이영희")
introduce("박민준", 25)

# 가변 인자 (*args, **kwargs)
def calculate_sum(*numbers):
    """여러 숫자의 합계를 계산하는 함수."""
    return sum(numbers)

print(f"합계: {calculate_sum(1, 2, 3, 4, 5)}")

def show_info(**kwargs):
    """키워드 인자를 사용하여 정보를 출력하는 함수."""
    for key, value in kwargs.items():
        print(f"{key}: {value}")

show_info(name="홍길동", city="서울")

# 람다 함수 (익명 함수)
add = lambda x, y: x + y
print(f"람다 합계: {add(10, 20)}")

# 모듈 생성 및 사용 예시 (이 파일 자체를 모듈로 간주)
# 예를 들어, 이 파일을 'my_module.py'로 저장하면 다른 파일에서 import 가능

# 다른 파일에서 이 모듈을 임포트하는 예시:
# import my_module
# print(my_module.greet("최수진"))

# 특정 함수만 임포트하는 예시:
# from my_module import calculate_sum
# print(calculate_sum(10, 20, 30))

# 패키지 관리 (예시: 외부 라이브러리 설치)
# 터미널에서 'pip install requests' 명령어로 requests 라이브러리 설치

# import requests
# response = requests.get("https://api.github.com")
# print(f"GitHub API 응답 상태 코드: {response.status_code}")

# 가상 환경 사용 (PEP 8 권장 사항 준수)
# 개발 시에는 가상 환경을 활성화하여 프로젝트별 의존성을 관리하는 것이 좋습니다.
# 예시: python -m venv venv (가상 환경 생성)
#      .\venv\Scripts\activate (Windows 활성화)
#      source venv/bin/activate (Linux/macOS 활성화)

# Python 제너레이터와 데코레이터
# 제너레이터를 이용한 효율적인 반복 처리 및 데코레이터 활용

# 나쁜 예시: 대량의 데이터를 리스트에 한꺼번에 로드하여 메모리 낭비를 초래하거나, 함수의 기능을 확장하기 위해 코드를 직접 수정하여 재사용성을 낮춥니다.
# 좋은 예시: 제너레이터를 사용하여 필요할 때마다 데이터를 생성하여 메모리 효율성을 높이고, 데코레이터를 사용하여 함수의 코드를 변경하지 않고 기능을 추가합니다.

# --- 제너레이터 (Generators) ---
# 제너레이터 함수: yield 키워드를 사용하여 이터레이터를 반환하는 함수
def fibonacci_generator(n):
    """피보나치 수열을 n개까지 생성하는 제너레이터."""
    a, b = 0, 1
    for _ in range(n):
        yield a # 값을 반환하고, 다음 호출 시 이어서 실행
        a, b = b, a + b

# 제너레이터 사용
print("--- 피보나치 제너레이터 ---")
fib_gen = fibonacci_generator(10)
for num in fib_gen:
    print(num)

# 무한 제너레이터 예시
def infinite_sequence():
    """무한히 증가하는 숫자를 생성하는 제너레이터."""
    num = 0
    while True:
        yield num
        num += 1

# print("--- 무한 시퀀스 제너레이터 (일부만 출력) ---")
# # 무한 루프이므로 특정 조건에서 멈춰야 합니다.
# inf_gen = infinite_sequence()
# for _ in range(5):
#     print(next(inf_gen))


# --- 데코레이터 (Decorators) ---
# 데코레이터 함수: 다른 함수를 인자로 받아 기능을 추가하고 새로운 함수를 반환하는 함수
def timer_decorator(func):
    """함수 실행 시간을 측정하는 데코레이터."""
    import time

    def wrapper(*args, **kwargs):
        start_time = time.time()
        result = func(*args, **kwargs)
        end_time = time.time()
        print(f"{func.__name__} 함수 실행 시간: {end_time - start_time:.4f}초")
        return result
    return wrapper

def logger_decorator(func):
    """함수 호출 및 반환 값을 로깅하는 데코레이터."""
    def wrapper(*args, **kwargs):
        print(f"함수 {func.__name__} 호출. 인자: {args}, 키워드 인자: {kwargs}")
        result = func(*args, **kwargs)
        print(f"함수 {func.__name__} 반환: {result}")
        return result
    return wrapper

# 데코레이터 적용
@timer_decorator
@logger_decorator # 여러 데코레이터를 중첩하여 사용 가능 (아래부터 위로 적용)
def long_running_function(limit):
    """오랜 시간 실행되는 함수 예시."""
    sum_val = 0
    for i in range(limit):
        sum_val += i
    return sum_val

@logger_decorator
def greet(name):
    """인사를 건네는 간단한 함수."""
    return f"Hello, {name}!"

print("\n--- 데코레이터 사용 예시 ---")
long_running_function(1000000)
print(greet("Alice"))

# 데코레이터의 활용:
# - 로깅, 타이밍 측정, 권한 확인, 캐싱, 입력 유효성 검사 등 함수의 전후에 추가적인 로직을 적용할 때 유용.


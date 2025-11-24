# Python 예외 처리
# `try-except` 구문을 이용한 예외 처리 및 사용자 정의 예외

# 나쁜 예시: 모든 예외를 `except Exception:`으로 처리하여 특정 오류의 원인을 파악하기 어렵게 만들거나, 예외를 무시하고 진행하여 예상치 못한 동작을 유발.
# 좋은 예시: 구체적인 예외 타입을 명시하여 처리하고, 필요한 경우 사용자 정의 예외를 정의하여 가독성과 유지보수성을 높임.

def divide_numbers(a, b):
    """두 숫자를 나누는 함수. 0으로 나누는 경우 예외 처리."""
    try:
        result = a / b
    except ZeroDivisionError:
        print("오류: 0으로 나눌 수 없습니다.")
        return None
    except TypeError:
        print("오류: 숫자 타입만 입력 가능합니다.")
        return None
    except Exception as e: # 모든 예상치 못한 예외 처리 (최후의 보루)
        print(f"예상치 못한 오류 발생: {e}")
        return None
    else: # 예외가 발생하지 않았을 때 실행
        print("나눗셈 성공!")
        return result
    finally: # 예외 발생 여부와 상관없이 항상 실행
        print("나눗셈 시도 완료.")

print(divide_numbers(10, 2))
print(divide_numbers(10, 0))
print(divide_numbers(10, "a"))

# 사용자 정의 예외 (Custom Exception)
class InsufficientFundsError(Exception):
    """잔액 부족 시 발생하는 사용자 정의 예외."""
    def __init__(self, message="잔액이 부족합니다."):
        self.message = message
        super().__init__(self.message)

class BankAccount:
    def __init__(self, owner, balance=0):
        self.owner = owner
        self.balance = balance

    def withdraw(self, amount):
        if amount <= 0:
            raise ValueError("출금액은 양수여야 합니다.")
        if amount > self.balance:
            raise InsufficientFundsError(f"잔액 부족: {self.balance}원, 요청액: {amount}원")
        
        self.balance -= amount
        print(f"{self.owner} 계정에서 {amount}원 출금. 현재 잔액: {self.balance}원")

# 사용자 정의 예외 사용 예시
my_account = BankAccount("김코딩", 10000)

try:
    my_account.withdraw(5000)
    my_account.withdraw(8000) # InsufficientFundsError 발생
except InsufficientFundsError as e:
    print(f"출금 오류: {e.message}")
except ValueError as e:
    print(f"입력 오류: {e}")
except Exception as e:
    print(f"다른 오류 발생: {e}")
finally:
    print("출금 시도 완료.")
    print(f"최종 잔액: {my_account.balance}원")

# 오류를 발생시키는 것이 나쁜 코드가 아님. 오류가 발생할 수 있는 상황을 명확히 하고, 이를 적절히 처리하는 것이 중요.
# 예상치 못한 오류는 프로그램을 강제 종료시키는 것보다 적절한 메시지를 남기고 종료하는 것이 좋음.

# Python 객체 지향 프로그래밍 (OOP)
# 클래스, 객체, 상속, 다형성 등 OOP 개념 및 구현 학습

# 나쁜 예시: 모든 코드를 함수로만 작성하거나, 클래스를 사용하더라도 객체 지향의 이점을 살리지 못하고 절차 지향적으로 코드를 작성.
# 좋은 예시: 현실 세계의 객체를 클래스로 모델링하고, 상속과 다형성을 활용하여 유연하고 확장 가능한 코드를 작성.

# 클래스 정의
class Dog:
    # 클래스 변수 (모든 인스턴스가 공유)
    species = "Canis familiaris"

    def __init__(self, name, age):
        # 인스턴스 변수 (각 인스턴스마다 고유)
        self.name = name
        self.age = age

    def bark(self):
        """개가 짖는 행위."""
        return f"{self.name}가 멍멍 짖습니다!"

    def get_age_in_dog_years(self):
        """개의 나이를 사람 나이로 환산 (간단한 예시)."""
        return self.age * 7

# 객체 생성 (인스턴스화)
my_dog = Dog("바둑이", 3)
your_dog = Dog("흰둥이", 5)

print(f"내 강아지 이름: {my_dog.name}, 나이: {my_dog.age}")
print(f"네 강아지 이름: {your_dog.name}, 나이: {your_dog.age}")

print(f"내 강아지 종: {my_dog.species}")
print(f"네 강아지 종: {your_dog.species}")

print(my_dog.bark())
print(f"{my_dog.name}의 사람 나이 환산: {my_dog.get_age_in_dog_years()}살")

# 상속
class GoldenRetriever(Dog):
    def __init__(self, name, age, color):
        super().__init__(name, age) # 부모 클래스의 생성자 호출
        self.color = color

    def retrieve(self, item):
        """골든 리트리버가 물건을 가져오는 행위."""
        return f"{self.name}가 {item}을 가져옵니다."

# 자식 클래스 객체 생성
golden = GoldenRetriever("골디", 2, "황금색")
print(f"골든 리트리버 이름: {golden.name}, 나이: {golden.age}, 색깔: {golden.color}")
print(golden.bark())
print(golden.retrieve("공"))

# 다형성 (Polymorphism)
def make_animal_bark(animal):
    """어떤 동물 객체든 짖게 하는 함수."""
    print(animal.bark())

make_animal_bark(my_dog)
make_animal_bark(golden)

# 캡슐화 (Encapsulation) - Python에서는 강력한 private 접근 제어자가 없지만, 컨벤션을 사용
class BankAccount:
    def __init__(self, owner, balance=0):
        self._owner = owner # _로 시작하는 변수는 내부적으로 사용되는 변수라는 컨벤션
        self.__balance = balance # __로 시작하는 변수는 Name Mangling 되어 외부에서 접근하기 어려움

    def deposit(self, amount):
        if amount > 0:
            self.__balance += amount
            print(f"{self._owner} 계정에 {amount}원 입금. 현재 잔액: {self.__balance}")
        else:
            print("입금액은 양수여야 합니다.")

    def withdraw(self, amount):
        if 0 < amount <= self.__balance:
            self.__balance -= amount
            print(f"{self._owner} 계정에서 {amount}원 출금. 현재 잔액: {self.__balance}")
        else:
            print("잔액이 부족하거나 유효하지 않은 금액입니다.")

    def get_balance(self):
        return self.__balance

account = BankAccount("김코딩", 10000)
account.deposit(5000)
account.withdraw(3000)
# print(account.__balance) # AttributeError: 'BankAccount' object has no attribute '__balance' (Name Mangling 때문에)
print(f"현재 잔액: {account.get_balance()}원")

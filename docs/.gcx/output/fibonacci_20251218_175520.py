**피보나치 계산기 아키텍처**

- 입력 검증 및 예외 처리를 `validate_input()`로 분리해 재사용성과 안정성 강화 (허용된 정수만 처리, 음수는 `ValueError`).
- `FibonacciCalculator` 클래스는 재귀+메모이제이션으로 계산(Cached), `reset()`으로 상태 초기화 가능.
- 반복 구현 `fibonacci_iterative()`는 O(1) 공간, 순환 `fibonacci_bad()`는 비교용이지만 실제로는 사용 X.
- CLI-like `run_examples()` 함수에서 계산기 인스턴스를 만들고 각각의 구현을 호출해 결과 출력하며, 예외 발생 시 사용자에게 안내.

```python
# fibonacci_calculator.py
"""
피보나치 계산기 - 다양한 구현 방식 비교
"""

from typing import Dict


def validate_input(n: int) -> None:
    """입력 값 검증: 음수는 허용하지 않음"""
    if not isinstance(n, int):
        raise TypeError("정수만 입력할 수 있습니다.")
    if n < 0:
        raise ValueError("음수에 대해서는 피보나치 수를 계산할 수 없습니다.")


def fibonacci_bad(n: int) -> int:
    """중복 계산이 많아 매우 비효율적인 순환 재귀"""
    validate_input(n)
    if n <= 1:
        return n
    return fibonacci_bad(n - 1) + fibonacci_bad(n - 2)


class FibonacciCalculator:
    """메모이제이션 기반 피보나치 계산기"""

    def __init__(self) -> None:
        self.memo: Dict[int, int] = {}

    def calculate(self, n: int) -> int:
        """재귀 + 캐시로 효율적으로 계산"""
        validate_input(n)
        if n in self.memo:
            return self.memo[n]

        if n <= 1:
            result = n
        else:
            result = self.calculate(n - 1) + self.calculate(n - 2)

        self.memo[n] = result
        return result

    def reset(self) -> None:
        """캐시 초기화"""
        self.memo.clear()


def fibonacci_iterative(n: int) -> int:
    """반복문 버전은 공간 O(1)"""
    validate_input(n)
    if n <= 1:
        return n

    prev, curr = 0, 1
    for _ in range(2, n + 1):
        prev, curr = curr, prev + curr
    return curr


def run_examples(n: int) -> None:
    """각 방식의 출력 및 캐시 상태를 보여주는 간단한 UI/IO 분리 함수"""
    try:
        calculator = FibonacciCalculator()
        print("=== 피보나치 계산 비교 ===")
        print(f"입력: {n}")

        memo_result = calculator.calculate(n)
        print(f"메모이제이션: F({n}) = {memo_result}")

        iterative_result = fibonacci_iterative(n)
        print(f"반복문: F({n}) = {iterative_result}")

        try:
            bad_result = fibonacci_bad(n)
            print(f"순환 재귀(비효율): F({n}) = {bad_result}")
        except RecursionError:
            print("순환 재귀: n이 커서 스택 오버플로우가 발생할 수 있습니다.")

        print(f"캐시된 값 개수: {len(calculator.memo)}")

    except (TypeError, ValueError) as exc:
        print(f"입력 오류: {exc}")


if __name__ == "__main__":
    run_examples(30)
```

- `validate_input`으로 호출 전 단계에서 타입/범위를 먼저 검사하여 계산기 내부에서의 예외를 줄이고, `run_examples`에서 `TypeError`/`ValueError`를 잡아 사용자에게 명확히 알림.
- 아키텍처는 입력 → `FibonacciCalculator`/함수 → 출력 흐름으로 모듈을 분리했고, `run_examples`를 통해 간단한 UI 역할을 담당 (IO와 계산 로직 분리).

**다음 단계 제안**
1. `FibonacciCalculator`를 테스트 가능한 모듈로 만들어 `pytest` 기반 단위 테스트 추가.
2. CLI 입력을 받는 `argparse` 래퍼를 붙여 다양한 n을 입력 가능하게 확장.

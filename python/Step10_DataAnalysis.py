# Python 데이터 분석 (Pandas, NumPy)
# Pandas와 NumPy를 이용한 데이터 처리 및 분석 기초

# 나쁜 예시: 대용량 데이터를 처리할 때 파이썬 기본 리스트와 반복문만 사용하여 비효율적인 코드 작성.
# 좋은 예시: NumPy의 배열 연산과 Pandas의 DataFrame을 활용하여 빠르고 효율적인 데이터 처리 및 분석.

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt # 시각화를 위한 라이브러리 (선택 사항)

# --- NumPy ---
# NumPy는 고성능 과학 계산을 위한 파이썬 라이브러리로, 특히 다차원 배열 객체를 지원합니다.
print("--- NumPy 기초 ---")

# 1. 배열 생성
# 파이썬 리스트로부터 배열 생성
data = [1, 2, 3, 4, 5]
np_array = np.array(data)
print(f"NumPy 배열: {np_array}")
print(f"배열 타입: {type(np_array)}")
print(f"배열 형태 (shape): {np_array.shape}") # (5,) 1차원 배열

# 0으로 채워진 배열
zeros_array = np.zeros((2, 3)) # 2행 3열의 0으로 채워진 배열
print(f"\n0으로 채워진 배열:\n{zeros_array}")

# 1로 채워진 배열
ones_array = np.ones((3, 2)) # 3행 2열의 1로 채워진 배열
print(f"\n1로 채워진 배열:\n{ones_array}")

# 특정 범위의 배열
range_array = np.arange(0, 10, 2) # 0부터 10 미만까지 2씩 증가
print(f"\n범위 배열: {range_array}")

# 랜덤 배열
random_array = np.random.rand(2, 2) # 0과 1 사이의 랜덤 실수 2x2 배열
print(f"\n랜덤 배열:\n{random_array}")

# 2. 배열 연산 (Element-wise operation)
arr1 = np.array([1, 2, 3])
arr2 = np.array([4, 5, 6])

print(f"\n배열 덧셈: {arr1 + arr2}") # [5 7 9]
print(f"배열 곱셈: {arr1 * arr2}") # [ 4 10 18]

# 3. 브로드캐스팅 (Broadcasting)
# 형태가 다른 배열 간의 연산을 가능하게 하는 NumPy의 기능
arr_a = np.array([[1, 2, 3], [4, 5, 6]])
arr_b = np.array([10, 20, 30])
print(f"\n브로드캐스팅 덧셈:\n{arr_a + arr_b}") # arr_b가 각 행에 맞춰 확장되어 연산됨

# 4. 인덱싱 및 슬라이싱
print(f"\n두 번째 요소: {np_array[1]}") # 2
print(f"슬라이싱: {np_array[1:4]}") # [2 3 4]


# --- Pandas ---
# Pandas는 데이터 조작 및 분석을 위한 라이브러리로, DataFrame이라는 강력한 데이터 구조를 제공합니다.
print("\n--- Pandas 기초 ---")

# 1. Series 생성 (1차원 데이터)
s = pd.Series([1, 3, 5, np.nan, 6, 8])
print(f"\nPandas Series:\n{s}")

# 2. DataFrame 생성 (2차원 데이터, 테이블 형태)
# 딕셔너리로부터 DataFrame 생성
data = {
    '이름': ['Alice', 'Bob', 'Charlie', 'David'],
    '나이': [25, 30, 35, 40],
    '도시': ['서울', '부산', '제주', '서울']
}
df = pd.DataFrame(data)
print(f"\nPandas DataFrame:\n{df}")

# CSV 파일로부터 DataFrame 읽기 (예시)
# df_csv = pd.read_csv('your_data.csv')

# 3. DataFrame 기본 정보 확인
print(f"\nDataFrame 상위 2행:\n{df.head(2)}")
print(f"\nDataFrame 정보:\n")
df.info() # 각 컬럼의 데이터 타입, Non-null 개수 등

print(f"\nDataFrame 통계 요약:\n{df.describe()}") # 숫자형 컬럼에 대한 통계 요약

# 4. 데이터 선택 (인덱싱 및 슬라이싱)
print(f"\n'이름' 컬럼 선택:\n{df['이름']}")
print(f"\n첫 번째 행 선택:\n{df.loc[0]}") # 라벨 기반 인덱싱
print(f"\n나이가 30 이상인 데이터:\n{df[df['나이'] >= 30]}") # 조건 필터링

# 5. 데이터 조작
# 새로운 컬럼 추가
df['성별'] = ['여', '남', '남', '남']
print(f"\n'성별' 컬럼 추가 후:\n{df}")

# '나이' 컬럼을 10 더하기
df['나이'] = df['나이'] + 10
print(f"\n'나이' 컬럼 업데이트 후:\n{df}")

# 그룹화 및 집계
print(f"\n도시별 평균 나이:\n{df.groupby('도시')['나이'].mean()}")

# 6. 결측치 (Missing Data) 처리
df_missing = pd.DataFrame({
    'A': [1, 2, np.nan],
    'B': [4, np.nan, 6],
    'C': [7, 8, 9]
})
print(f"\n결측치 포함 DataFrame:\n{df_missing}")
print(f"\n결측치 제거 후:\n{df_missing.dropna()}") # 결측치가 있는 행 제거
print(f"\n결측치를 0으로 채운 후:\n{df_missing.fillna(0)}") # 결측치 채우기

# 7. 데이터 시각화 (matplotlib 연동 예시)
# df['나이'].plot(kind='hist')
# plt.title("나이 분포")
# plt.show()

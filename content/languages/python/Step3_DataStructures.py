# Python 자료구조 (List, Tuple, Dictionary, Set)
# 각 자료구조의 특징 이해 및 적절한 사용법 학습

# 나쁜 예시: 모든 데이터를 리스트에만 저장하거나, 잘못된 자료구조를 사용하여 성능 저하 또는 코드 복잡성을 유발.
# 좋은 예시: 각 자료구조의 특성을 이해하고 상황에 맞는 최적의 자료구조를 선택하여 효율적인 코드를 작성.

# 리스트 (List): 순서가 있고 변경 가능한(mutable) 컬렉션, 중복 허용
my_list = [1, 2, 3, "apple", True, 3]
print(f"리스트: {my_list}")
print(f"리스트 길이: {len(my_list)}")
print(f"세 번째 요소: {my_list[2]}") # 인덱싱
my_list.append("banana") # 요소 추가
print(f"요소 추가 후 리스트: {my_list}")
my_list.remove(3) # 요소 제거 (첫 번째 3 제거)
print(f"요소 제거 후 리스트: {my_list}")

# 튜플 (Tuple): 순서가 있고 변경 불가능한(immutable) 컬렉션, 중복 허용
my_tuple = (1, 2, 3, "apple", True, 3)
print(f"튜플: {my_tuple}")
print(f"튜플 길이: {len(my_tuple)}")
print(f"두 번째 요소: {my_tuple[1]}")
# my_tuple.append("banana") # 오류 발생: 튜플은 변경 불가능

# 딕셔너리 (Dictionary): 키-값 쌍으로 이루어진 변경 가능한(mutable) 컬렉션, 순서 없음 (Python 3.7+부터 삽입 순서 유지), 키는 중복 불가
my_dict = {"name": "홍길동", "age": 30, "city": "서울"}
print(f"딕셔너리: {my_dict}")
print(f"이름: {my_dict['name']}")
my_dict["age"] = 31 # 값 변경
my_dict["occupation"] = "개발자" # 새로운 키-값 추가
print(f"변경 후 딕셔너리: {my_dict}")
del my_dict["city"] # 요소 제거
print(f"요소 제거 후 딕셔너리: {my_dict}")

# 셋 (Set): 순서가 없고 변경 가능한(mutable) 컬렉션, 중복 불가능
my_set = {1, 2, 3, 3, 4, 5, "apple"}
print(f"셋 (중복 제거됨): {my_set}")
my_set.add(6) # 요소 추가
print(f"요소 추가 후 셋: {my_set}")
my_set.remove(1) # 요소 제거
print(f"요소 제거 후 셋: {my_set}")

# 셋 연산 (합집합, 교집합, 차집합)
set1 = {1, 2, 3, 4}
set2 = {3, 4, 5, 6}
print(f"합집합: {set1.union(set2)}") # {1, 2, 3, 4, 5, 6}
print(f"교집합: {set1.intersection(set2)}") # {3, 4}
print(f"차집합 (set1 - set2): {set1.difference(set2)}") # {1, 2}

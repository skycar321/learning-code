# Python 파일 입출력
# 파일 읽기/쓰기, CSV, JSON 파일 처리 등 입출력 작업

# 나쁜 예시: 파일을 열고 닫는 것을 잊어 리소스 누수를 발생시키거나, 큰 파일을 한 번에 메모리에 로드하여 시스템 자원 소모.
# 좋은 예시: `with` 구문을 사용하여 파일을 안전하게 관리하고, CSV/JSON 모듈을 활용하여 구조화된 데이터를 효율적으로 처리.

import csv
import json
import os

# 텍스트 파일 쓰기
def write_text_file(filename, content):
    """텍스트 파일에 내용을 쓰는 함수."""
    try:
        with open(filename, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"'{filename}' 파일에 성공적으로 작성했습니다.")
    except IOError as e:
        print(f"파일 쓰기 오류: {e}")

# 텍스트 파일 읽기
def read_text_file(filename):
    """텍스트 파일 내용을 읽는 함수."""
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            content = f.read()
        print(f"'{filename}' 파일 내용:\n{content}")
        return content
    except FileNotFoundError:
        print(f"오류: '{filename}' 파일을 찾을 수 없습니다.")
        return None
    except IOError as e:
        print(f"파일 읽기 오류: {e}")
        return None

# CSV 파일 쓰기
def write_csv_file(filename, data, header):
    """CSV 파일에 데이터를 쓰는 함수."""
    try:
        with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
            csv_writer = csv.writer(csvfile)
            csv_writer.writerow(header) # 헤더 쓰기
            csv_writer.writerows(data) # 데이터 쓰기
        print(f"'{filename}' 파일에 CSV 데이터를 성공적으로 작성했습니다.")
    except IOError as e:
        print(f"CSV 파일 쓰기 오류: {e}")

# CSV 파일 읽기
def read_csv_file(filename):
    """CSV 파일 내용을 읽는 함수."""
    try:
        with open(filename, 'r', newline='', encoding='utf-8') as csvfile:
            csv_reader = csv.reader(csvfile)
            header = next(csv_reader) # 헤더 읽기
            data = [row for row in csv_reader] # 데이터 읽기
        print(f"'{filename}' 파일 헤더: {header}")
        print(f"'{filename}' 파일 데이터: {data}")
        return header, data
    except FileNotFoundError:
        print(f"오류: '{filename}' 파일을 찾을 수 없습니다.")
        return None, None
    except IOError as e:
        print(f"CSV 파일 읽기 오류: {e}")
        return None, None

# JSON 파일 쓰기
def write_json_file(filename, data):
    """JSON 파일에 데이터를 쓰는 함수."""
    try:
        with open(filename, 'w', encoding='utf-8') as jsonfile:
            json.dump(data, jsonfile, indent=4, ensure_ascii=False) # indent로 가독성 높임, ensure_ascii=False로 한글 인코딩 유지
        print(f"'{filename}' 파일에 JSON 데이터를 성공적으로 작성했습니다.")
    except IOError as e:
        print(f"JSON 파일 쓰기 오류: {e}")

# JSON 파일 읽기
def read_json_file(filename):
    """JSON 파일 내용을 읽는 함수."""
    try:
        with open(filename, 'r', encoding='utf-8') as jsonfile:
            data = json.load(jsonfile)
        print(f"'{filename}' 파일 JSON 데이터: {data}")
        return data
    except FileNotFoundError:
        print(f"오류: '{filename}' 파일을 찾을 수 없습니다.")
        return None
    except json.JSONDecodeError as e:
        print(f"JSON 디코딩 오류: {e}")
        return None
    except IOError as e:
        print(f"JSON 파일 읽기 오류: {e}")
        return None

# --- 실행 예시 ---
# 작업 디렉토리 생성 (예시)
output_dir = "file_io_examples"
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

text_filename = os.path.join(output_dir, "my_document.txt")
csv_filename = os.path.join(output_dir, "users.csv")
json_filename = os.path.join(output_dir, "config.json")

# 텍스트 파일
write_text_file(text_filename, "안녕하세요, 파일 입출력 테스트입니다.\n두 번째 줄입니다.")
read_text_file(text_filename)

# CSV 파일
csv_header = ["이름", "나이", "도시"]
csv_data = [
    ["김철수", 25, "서울"],
    ["이영희", 30, "부산"],
    ["박민준", 28, "대구"]
]
write_csv_file(csv_filename, csv_data, csv_header)
read_csv_file(csv_filename)

# JSON 파일
json_data = {
    "app_name": "MyPythonApp",
    "version": "1.0.0",
    "settings": {
        "debug_mode": True,
        "language": "ko-KR"
    },
    "users": [
        {"id": 1, "name": "Alice"},
        {"id": 2, "name": "Bob"}
    ]
}
write_json_file(json_filename, json_data)
read_json_file(json_filename)

print("\n모든 파일 입출력 예시 완료.")
# 생성된 파일 확인
# print(os.listdir(output_dir))
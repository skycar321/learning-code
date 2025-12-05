# JQ (Command-line JSON Processor)

> 터미널에서 JSON 데이터를 파싱, 필터링, 변환하는 강력한 도구입니다.

## 1. 기본 사용법
```bash
# JSON 예쁘게 출력하기 (Pretty Print)
echo '{"foo": "bar"}' | jq .

# 파일에서 읽기
jq . data.json
```

## 2. 필터링 및 선택
```bash
# 특정 키 값 추출
echo '{"foo": "bar", "baz": 42}' | jq '.foo'
# 결과: "bar"

# 배열의 첫 번째 요소 추출
echo '[1, 2, 3]' | jq '.[0]'

# 배열의 모든 요소 반복
echo '[{"id":1}, {"id":2}]' | jq '.[] .id'
```

## 3. 객체 생성 및 변환
```bash
# 새로운 객체 생성
echo '{"user": "Nam", "age": 30}' | jq '{name: .user, years: .age}'
# 결과: {"name": "Nam", "years": 30}
```

## 4. 실전 예제: API 응답 처리
```bash
# curl로 받은 JSON 응답에서 특정 필드만 추출
curl -s https://api.github.com/repos/rust-lang/rust | jq '.stargazers_count'
```
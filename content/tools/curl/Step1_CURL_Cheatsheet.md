# cURL (Client URL)

> 서버와 데이터를 송수신하는 명령줄 도구입니다. API 테스트 및 파일 다운로드에 필수적입니다.

## 1. 기본 요청 (GET)
```bash
# 웹페이지 내용 출력
curl https://example.com

# 헤더 정보만 확인 (-I)
curl -I https://example.com

# 자세한 통신 과정 확인 (-v)
curl -v https://example.com
```

## 2. 데이터 전송 (POST/PUT)
```bash
# JSON 데이터 POST 요청
curl -X POST https://api.example.com/users \
     -H "Content-Type: application/json" \
     -d '{"name": "Nam", "role": "admin"}'

# 폼 데이터 전송
curl -X POST https://example.com/login -d "user=nam&pass=1234"
```

## 3. 파일 다운로드
```bash
# 원본 파일명으로 저장 (-O)
curl -O https://example.com/file.zip

# 다른 이름으로 저장 (-o)
curl -o my_file.zip https://example.com/file.zip

# 이어받기 (-C -)
curl -C - -O https://example.com/large-file.iso
```

## 4. 인증
```bash
# Basic Auth (사용자:비밀번호)
curl -u username:password https://api.example.com
```
# Step 2: Airflow 로컬 환경 구축

## 1. 소개
이 단계에서는 Docker Compose를 사용하여 로컬 PC에 Airflow 환경을 구축합니다.
복잡한 설정을 피하기 위해 **LocalExecutor** 모드를 사용합니다. (Celery, Redis 불필요)

## 2. 사전 준비 (Prerequisites)
- Docker Desktop이 설치되어 있고 실행 중이어야 합니다.
- `docker-compose` 명령어를 사용할 수 있어야 합니다.

## 3. 설치 및 실행 순서

### 3.1 환경 변수 설정
`Step2_Setup` 폴더 내에 `.env` 파일을 생성해야 합니다. (Linux/Mac 사용자의 권한 문제를 해결하기 위함)
Windows 사용자는 기본값을 그대로 사용해도 무방합니다.

```bash
# 터미널에서 실행 (Step2_Setup 폴더 안에서)
# Windows Powershell
Copy-Item .env.example .env

# Mac/Linux
cp .env.example .env
```

### 3.2 디렉토리 생성
DAG 파일과 로그가 저장될 폴더를 생성합니다.
```bash
# Windows Powershell
mkdir dags, logs, plugins
```

### 3.3 컨테이너 실행
```bash
docker-compose up -d
```
- 이미지를 다운로드하고 초기화(`airflow-init`)하는 데 몇 분 정도 걸릴 수 있습니다.
- `postgres`, `webserver`, `scheduler` 컨테이너가 실행됩니다.

### 3.4 접속 확인
브라우저를 열고 `http://localhost:8080` 에 접속합니다.
- **ID**: `admin`
- **PW**: `admin`

## 4. 디렉토리 구조 설명
`docker-compose.yaml`에서 볼륨 마운트 설정을 확인해보세요.
- `./dags`: 여기에 Python DAG 파일을 넣으면 Airflow가 자동으로 인식합니다.
- `./logs`: 실행 로그가 여기에 쌓입니다. 디버깅 시 유용합니다.
- `./plugins`: 커스텀 플러그인을 넣는 곳입니다.

## 5. 트러블슈팅
**Q. `airflow-webserver` 컨테이너가 자꾸 죽어요 (Unhealthy).**
- A. 메모리 부족일 수 있습니다. Docker Desktop 설정에서 메모리를 4GB 이상으로 늘려주세요.

**Q. DAG를 넣었는데 화면에 안 나와요.**
- A. `airflow-scheduler`가 파일을 파싱하는 데 시간이 조금 걸립니다 (기본 30초~1분).
- A. 코드에 문법 에러가 있으면 화면 상단에 "Broken DAG" 에러가 뜹니다.

## 6. 종료 방법
```bash
docker-compose down
# 데이터까지 싹 지우고 싶다면:
docker-compose down -v
```

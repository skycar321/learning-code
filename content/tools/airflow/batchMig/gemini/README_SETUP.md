# Airflow 로컬 실습 환경 가이드 (batchMig/gemini 버전)

이 디렉토리는 `batchMig/gemini` 경로에서 Airflow를 실행하고 테스트할 수 있도록 구성되었습니다.

## 1. 실행 방법

### 1.1 폴더 이동
```bash
cd content/tools/airflow/batchMig/gemini
```

### 1.2 DAG 복사
```bash
cp dag_integrated_pipeline.py dags/
```

### 1.3 Docker 실행
```bash
docker-compose up -d
```

## 2. 접속 정보
- **URL**: http://localhost:8080
- **ID/PW**: airflow / airflow

## 3. 테스트 팁
- `scripts/` 폴더에 있는 mock 스크립트들이 컨테이너 내부의 `/app/scripts` 경로에 마운트됩니다.
- 실제 Java가 없는 환경이므로, DAG 테스트 시 `java -jar` 명령 대신 `/app/scripts/mock_java_runner.sh`를 호출하도록 수정하여 테스트해 보세요.

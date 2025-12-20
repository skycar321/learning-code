# Step 6: Airflow 운영 및 모범 사례

## 1. 유용한 CLI 명령어
UI도 좋지만, 개발/디버깅 시에는 CLI가 훨씬 빠르고 강력합니다.
컨테이너 내부(`docker-compose exec airflow-scheduler bash`)에서 실행하세요.

```bash
# DAG 목록 확인
airflow dags list

# 문법 에러 확인 (매우 중요)
airflow dags list --import-errors

# 특정 Task 테스트 (DB에 기록 안 남김 - 디버깅용)
# 사용법: airflow tasks test [DAG_ID] [TASK_ID] [EXECUTION_DATE]
airflow tasks test 01_bash_demo print_date 2025-01-01

# DAG 강제 실행
airflow dags trigger 01_bash_demo -e 2025-01-01
```

## 2. Backfill (과거 데이터 처리)
Airflow의 강력한 기능 중 하나입니다. 과거의 특정 기간을 한꺼번에 재실행할 수 있습니다.
```bash
# 2024년 1월 1일부터 1월 7일까지 실행
airflow dags backfill -s 2024-01-01 -e 2024-01-07 01_bash_demo
```
**주의**: `catchup=True` 설정이 되어 있거나, 수동으로 돌릴 때 유용합니다. 운영 DB에 부하를 줄 수 있으니 주의하세요.

## 3. Idempotency (멱등성)
**"같은 코드를 여러 번 실행해도 결과가 같아야 한다"**는 원칙입니다.
데이터 파이프라인에서 가장 중요한 철학입니다.

- **Bad**: `INSERT INTO table VALUES (...)` (실행할 때마다 데이터 중복됨)
- **Good**: `DELETE FROM table WHERE date='...'; INSERT INTO ...` (지우고 다시 쓰므로 안전함)
- **Good (Upsert)**: `INSERT ... ON CONFLICT UPDATE ...`

Airflow Task를 짤 때는 항상 **"이 Task가 실패해서 재실행되거나, 실수로 두 번 실행되면 어떻게 되지?"**를 고민해야 합니다.

## 4. Connection & Variable 관리 (보안)
UI에서 Admin -> Connections에 비밀번호를 입력하면 DB에 평문(또는 암호화)으로 저장됩니다.
하지만 **Infrastructure as Code** 관점에서는 환경 변수(Environment Variable)로 관리하는 것이 좋습니다.

### Docker Compose에서 설정 예시
```yaml
environment:
  AIRFLOW_VAR_MY_VAR: "some_value"
  AIRFLOW_CONN_MY_DB: "postgresql://user:pass@host:5432/db"
```
이렇게 하면 UI에서 수정할 수 없게 되지만, 배포 관리가 훨씬 깔끔해집니다.

## 5. 마무리
축하합니다! 이제 Airflow의 기본부터 운영 팁까지 모두 살펴보았습니다.
`content/devops/airflow/` 폴더의 자료들을 참고하여 자신만의 데이터 파이프라인을 구축해 보세요.

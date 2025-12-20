# Step 5: DAG 테스트 및 검증

## 1. 개요
운영 환경에 배포하기 전에 DAG 파일에 문법 오류나 논리적 오류(순환 참조 등)가 없는지 검증하는 것은 필수적입니다.
**Pytest**와 Airflow의 `DagBag` 클래스를 사용하여 이를 자동화할 수 있습니다.

## 2. 테스트 스크립트 설명 (`test_dag_integrity.py`)
- **DagBag**: 지정된 폴더의 모든 DAG 파일을 로드하는 Airflow 클래스입니다.
- **test_dag_import_errors**: `dagbag.import_errors`가 비어 있는지 확인합니다. (가장 중요)
- **test_dag_cycles**: `dag.test_cycle()`을 호출하여 무한 루프가 없는지 확인합니다.

## 3. 실행 방법 (Docker 환경 내에서)

DAG 파일들이 있는 컨테이너 내부에서 테스트를 돌려야 정확합니다.

1. **테스트 파일 복사**:
   먼저 `test_dag_integrity.py` 파일을 `dags/` 폴더로 복사합니다. (편의상)
   ```bash
   copy content/devops/airflow/Step5_Testing/test_dag_integrity.py content/devops/airflow/Step2_Setup/dags/
   ```

2. **Pytest 실행**:
   `airflow-scheduler` 또는 `airflow-webserver` 컨테이너 내부에서 pytest를 실행합니다.
   ```bash
   # 컨테이너에 접속하여 실행
   docker-compose exec airflow-scheduler bash -c "pytest /opt/airflow/dags/test_dag_integrity.py"
   ```

3. **결과 확인**:
   - `passed`가 뜨면 모든 DAG가 정상적으로 로드된 것입니다.
   - 만약 일부러 `01_bash_operator.py`에 오타를 내고 다시 돌려보면 `failed`가 뜨는 것을 볼 수 있습니다.

## 4. CI/CD 파이프라인 적용
Github Actions나 Jenkins 같은 CI 도구에서 이 스크립트를 실행하여, **테스트를 통과한 DAG만 운영 서버로 배포**되도록 구성하는 것이 정석입니다.

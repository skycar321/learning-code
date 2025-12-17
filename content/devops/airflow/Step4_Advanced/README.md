# Step 4: 심화 패턴 (XCom & Branching)

## 1. XCom (Cross-Communication)
Airflow의 Task들은 서로 독립된 프로세스(또는 컨테이너/서버)에서 실행되므로 메모리를 공유하지 않습니다.
Task 간에 작은 데이터를 주고받기 위해 **XCom**이라는 메타데이터 테이블을 사용합니다.

### 1.1 `03_xcom_example.py`
- `ti.xcom_push(key, value)`: 데이터를 저장 (PythonOperator의 리턴값은 자동 저장).
- `ti.xcom_pull(task_ids, key)`: 데이터를 조회.
- **주의**: XCom은 DB에 저장되므로 **대용량 데이터(Pandas DataFrame 등)를 직접 넘기면 안 됩니다.** 파일 경로만 넘기는 것이 정석입니다.

## 2. 분기 (Branching)
특정 조건에 따라 실행할 Task를 다르게 가져가고 싶을 때 사용합니다.

### 2.1 `04_branching.py`
- **BranchPythonOperator**: Python 함수가 리턴하는 `task_id`를 찾아 다음 실행 흐름을 결정합니다.
- **Trigger Rule**:
  - 분기 후 다시 합쳐지는(Join) Task가 있다면 `trigger_rule` 설정이 중요합니다.
  - 기본값(`all_success`)이면 선택받지 못한 브랜치가 Skip 상태가 되므로, Join Task도 덩달아 Skip 됩니다.
  - `none_failed_min_one_success`: "실패한 놈은 없고, 적어도 하나는 성공했다면 실행해라" -> 가장 많이 쓰이는 Join 규칙입니다.

## 3. 실행 실습
마찬가지로 Python 파일들을 `dags/` 폴더로 복사하고 실행해 보세요.
- `04_branching` DAG를 실행한 후 **Graph View**를 보면 선택된 경로는 초록색, 선택받지 못한 경로는 분홍색(Skipped)으로 표시됩니다.

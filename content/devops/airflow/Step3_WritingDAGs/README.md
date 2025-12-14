# Step 3: 첫 번째 DAG 작성하기

## 1. 개요
이 단계에서는 Airflow의 가장 기본적인 Operator인 `BashOperator`와 최신 방식인 `TaskFlow API`(`@task`)를 사용하여 DAG를 작성해 봅니다.

## 2. 예제 코드 설명

### 2.1 `01_bash_operator.py` (전통적인 방식)
- **BashOperator**: 리눅스 쉘 명령어를 실행합니다.
- **Dependencies (`>>`)**: `t1 >> t2 >> t3`는 순서대로 실행하라는 의미입니다.
- **default_args**: 모든 태스크에 공통으로 적용될 속성(재시도 횟수 등)을 정의합니다.

### 2.2 `02_python_context.py` (Modern Airflow)
- **TaskFlow API**: Python 함수 위에 `@task` 데코레이터를 붙이면 Airflow Task가 됩니다.
- **데이터 전달**: `name_data = get_name()` 처럼 함수의 리턴값을 다음 Task의 인자로 바로 넘길 수 있습니다. (내부적으로 XCom 사용)
- **Context**: `**context`를 인자로 받으면 Airflow 실행 정보(`ds`: 날짜 등)를 사용할 수 있습니다.

## 3. 실행 방법 (실습)

1. **파일 복사**:
   작성된 `.py` 파일들을 `Step2_Setup` 단계에서 만든 `dags/` 폴더로 복사합니다.
   ```bash
   # (프로젝트 루트에서 실행)
   # Windows
   copy content/devops/airflow/Step3_WritingDAGs/*.py content/devops/airflow/Step2_Setup/dags/
   
   # Mac/Linux
   cp content/devops/airflow/Step3_WritingDAGs/*.py content/devops/airflow/Step2_Setup/dags/
   ```

2. **UI 확인**:
   - `localhost:8080` 접속 -> DAG 목록 새로고침.
   - `01_bash_demo`와 `02_python_taskflow`가 보여야 합니다.
   - 혹시 에러가 뜬다면 화면 상단의 빨간색 배너를 확인하세요.

3. **실행 (Trigger)**:
   - DAG 오른쪽의 `▶` (재생) 버튼을 누르고 `Trigger DAG`를 클릭합니다.
   - DAG ID를 클릭 -> **Grid** 탭으로 이동하여 녹색 사각형(성공)이 뜨는지 확인합니다.
   - 사각형 클릭 -> **Logs** 탭에서 출력 결과를 확인해 보세요.

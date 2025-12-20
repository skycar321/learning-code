from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta

# 1. 기본 인자 설정 (모든 Task에 공통 적용)
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# 2. DAG 정의 (Context Manager 사용)
with DAG(
    dag_id='01_bash_demo',
    default_args=default_args,
    description='A simple tutorial DAG',
    schedule_interval=timedelta(days=1),  # 하루에 한 번 실행
    start_date=datetime(2025, 1, 1),      # 과거 날짜로 설정 (실습용)
    catchup=False,                        # 과거 실행분(Backfill) 무시
    tags=['example', 'bash'],
) as dag:

    # 3. Task 정의 (BashOperator)
    t1 = BashOperator(
        task_id='print_date',
        bash_command='date',
    )

    t2 = BashOperator(
        task_id='sleep',
        depends_on_past=False,
        bash_command='sleep 5',
        retries=3,
    )

    t3 = BashOperator(
        task_id='print_hello',
        bash_command='echo "Hello World from Airflow"',
    )

    # 4. 의존성 설정 (Dependency)
    # t1이 성공해야 t2가 돌고, t2가 성공해야 t3가 돕니다.
    t1 >> t2 >> t3

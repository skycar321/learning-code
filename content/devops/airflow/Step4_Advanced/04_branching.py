from airflow import DAG
from airflow.operators.python import BranchPythonOperator
from airflow.operators.dummy import DummyOperator
from datetime import datetime

def choose_branch(**kwargs):
    """실행 날짜의 요일을 확인하여 분기"""
    # kwargs['ds']는 YYYY-MM-DD 문자열
    execution_date = datetime.strptime(kwargs['ds'], '%Y-%m-%d')
    
    # 월(0) ~ 일(6)
    if execution_date.weekday() < 5:
        return 'weekday_task'
    else:
        return 'weekend_task'

with DAG(
    dag_id='04_branching',
    start_date=datetime(2025, 1, 1),
    schedule_interval='@daily',
    catchup=False,
    tags=['example', 'branching'],
) as dag:

    # 1. 분기 결정 Task
    branching = BranchPythonOperator(
        task_id='branch_check',
        python_callable=choose_branch,
    )

    # 2. 선택지 Tasks
    weekday_task = DummyOperator(task_id='weekday_task')
    weekend_task = DummyOperator(task_id='weekend_task')

    # 3. 합류 Task (Join)
    # trigger_rule='none_failed_min_one_success' (또는 'one_success')를 써야 함
    # 기본값인 'all_success'를 쓰면, 선택받지 못한 브랜치가 skip되므로 join task도 skip됨.
    final_task = DummyOperator(
        task_id='final_task',
        trigger_rule='none_failed_min_one_success',
    )

    # 4. 의존성 연결
    branching >> [weekday_task, weekend_task]
    weekday_task >> final_task
    weekend_task >> final_task

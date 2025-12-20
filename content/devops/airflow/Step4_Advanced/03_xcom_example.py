from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime
import random

def generate_random_number(ti):
    """1부터 100 사이의 숫자를 생성하여 XCom에 Push"""
    number = random.randint(1, 100)
    # 리턴값은 자동으로 'return_value'라는 키로 XCom에 저장됩니다.
    return number

def pull_and_check(ti):
    """이전 Task의 XCom 값을 Pull"""
    # task_ids에 이전 태스크 ID를 지정해야 합니다.
    received_number = ti.xcom_pull(task_ids='generate_number')
    print(f"Received number: {received_number}")
    
    if received_number > 50:
        print("High number!")
    else:
        print("Low number!")

with DAG(
    dag_id='03_xcom_explicit',
    start_date=datetime(2025, 1, 1),
    schedule_interval=None, # 수동 실행
    catchup=False,
    tags=['example', 'xcom'],
) as dag:

    t1 = PythonOperator(
        task_id='generate_number',
        python_callable=generate_random_number,
    )

    t2 = PythonOperator(
        task_id='check_number',
        python_callable=pull_and_check,
    )

    t1 >> t2

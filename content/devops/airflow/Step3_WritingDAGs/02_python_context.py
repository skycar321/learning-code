from airflow import DAG
from airflow.decorators import task
from datetime import datetime
import logging

# 로깅 설정
logger = logging.getLogger("airflow.task")

@task
def get_name():
    """이름을 리턴하는 Python 함수 Task"""
    return "Airflow Learner"

@task
def greet(name: str):
    """이름을 받아서 인사를 출력하는 Python 함수 Task"""
    logger.info(f"Hello, {name}!")
    print(f"Standard Output: Hello, {name}!")

@task
def print_context(**context):
    """Airflow가 주입해주는 Context 변수 확인"""
    # context 딕셔너리에는 실행 날짜(ds), Task 인스턴스(ti) 등 유용한 정보가 들어있습니다.
    logical_date = context['ds']
    task_instance = context['ti']
    
    logger.info(f"Logical Date: {logical_date}")
    logger.info(f"Task ID: {task_instance.task_id}")

with DAG(
    dag_id='02_python_taskflow',
    start_date=datetime(2025, 1, 1),
    schedule_interval='@daily',
    catchup=False,
    tags=['example', 'python'],
) as dag:

    # TaskFlow API를 사용하면 함수 호출처럼 의존성을 연결할 수 있습니다.
    name_data = get_name()
    greet(name_data)

    # 일반적인 의존성 설정도 가능합니다.
    print_context()

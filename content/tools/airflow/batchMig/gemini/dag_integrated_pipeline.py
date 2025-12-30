from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.sensors.external_task import ExternalTaskSensor
from airflow.utils.trigger_rule import TriggerRule

# =============================================================================
# [시나리오 설명]
# 1. StreamSets가 데이터를 적재함 (외부 연동 가정)
# 2. Task A (Python): 적재된 데이터를 1차 가공 (기존 Crontab 대체)
# 3. Task B (Spring Batch 1): Task A 완료 후 외부 API 호출 (기존 DB 스케줄 대체)
# 4. Task C (Spring Batch 2): Task A와 Task B가 모두 완료된 후, 결과 종합 (UI용 데이터)
# =============================================================================

# DAG 기본 설정
default_args = {
    'owner': 'data_team',
    'depends_on_past': False,
    'email': ['admin@example.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    'integrated_batch_pipeline',
    default_args=default_args,
    description='StreamSets -> Python -> SpringBatch1 -> SpringBatch2 통합 파이프라인',
    schedule_interval='0 2 * * *',  # 매일 새벽 2시 실행 (KST 기준은 설정 필요)
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=['migration', 'spring-batch', 'python'],
) as dag:

    # -------------------------------------------------------------------------
    # 0. StreamSets 완료 감지 (선택 사항)
    # 실제 환경에서는 StreamSets가 끝난 후 특정 파일(.done)을 생성하거나
    # Airflow API를 호출하여 이 DAG를 Trigger하는 방식을 권장합니다.
    # 여기서는 예시로 "특정 파일이 생겼는지 확인"하는 센서를 둡니다.
    # -------------------------------------------------------------------------
    wait_for_streamsets = BashOperator(
        task_id='wait_for_streamsets_data',
        bash_command='echo "Checking data availability..." && sleep 5',
        # 실제 사용 시: bash_command='ls /data/incoming/today_done.flag'
    )

    # -------------------------------------------------------------------------
    # 1. Task A: Python 1차 가공 (기존 Crontab 대체)
    # -------------------------------------------------------------------------
    task_a_python_process = BashOperator(
        task_id='task_a_python_preprocessing',
        bash_command='echo "Running Python Pre-processing..." && python3 /app/scripts/process_data.py',
        # 가상환경 사용 시: /app/venv/bin/python3 /app/scripts/process_data.py
    )

    # -------------------------------------------------------------------------
    # 2. Task B: Spring Batch 1 (외부 API 호출)
    # 기존 DB 스케줄러를 제거하고 Airflow가 직접 Jar를 실행
    # -------------------------------------------------------------------------
    task_b_spring_batch_api = BashOperator(
        task_id='task_b_spring_batch_api_call',
        bash_command='''
            echo "Starting Spring Batch Job 1..."
            java -jar /app/batch/spring-batch-app.jar \
            --job.name=apiCallJob \
            date={{ ds_nodash }} \
            version=1.0
        ''',
    )

    # -------------------------------------------------------------------------
    # 3. Task C: Spring Batch 2 (결과 종합)
    # Task A와 Task B가 모두 성공해야 실행됨
    # -------------------------------------------------------------------------
    task_c_spring_batch_ui_aggregation = BashOperator(
        task_id='task_c_spring_batch_ui_aggregation',
        bash_command='''
            echo "Starting Spring Batch Job 2 (Aggregation)..."
            java -jar /app/batch/spring-batch-app.jar \
            --job.name=uiAggregationJob \
            date={{ ds_nodash }}
        ''',
        trigger_rule=TriggerRule.ALL_SUCCESS, # 기본값이지만 명시적으로 표현 (A, B 모두 성공 시)
    )

    # -------------------------------------------------------------------------
    # 의존성 설정 (Dependency Definition)
    # -------------------------------------------------------------------------
    
    # StreamSets 데이터가 준비되면 -> Python 가공 시작
    wait_for_streamsets >> task_a_python_process

    # Python 가공이 끝나면 -> Spring Batch 1 실행
    task_a_python_process >> task_b_spring_batch_api

    # Python 가공(A)과 Spring Batch 1(B)이 모두 끝나면 -> Spring Batch 2(C) 실행
    # A -> C, B -> C 구조이므로, 아래와 같이 표현 가능합니다.
    [task_a_python_process, task_b_spring_batch_api] >> task_c_spring_batch_ui_aggregation

    # 설명:
    # task_c는 task_a와 task_b가 모두 upstream으로 설정되어 있으므로,
    # 두 작업이 모두 완료되어야 실행됩니다.


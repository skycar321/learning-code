from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime
import csv
import os

DAGS_FOLDER = os.path.dirname(__file__)
REGISTRY = os.path.join(DAGS_FOLDER, "batch_registry.csv")


def load_registry():
    with open(REGISTRY, newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def make_dag(job):
    dag_id = f"auto_{job['job_id']}"
    schedule = job["schedule"]

    default_args = {
        "owner": "airflow",
        "retries": 1,
    }

    with DAG(
        dag_id=dag_id,
        start_date=datetime(2025, 1, 1),
        schedule_interval=schedule,
        catchup=False,
        default_args=default_args,
        tags=["auto"],
    ) as dag:

        task = BashOperator(
            task_id=job["job_id"],
            bash_command=job["command"],
        )

    return dag


registry = load_registry()

for job in registry:
    if job.get("enabled", "Y") != "Y":
        continue
    globals()[f"auto_{job['job_id']}"] = make_dag(job)

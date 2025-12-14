import pytest
from airflow.models import DagBag
import logging

# Airflow 설정에 따라 DAG 폴더 경로가 다를 수 있음
# Docker 컨테이너 내부 경로: /opt/airflow/dags
DAG_FOLDER = '/opt/airflow/dags'

@pytest.fixture(scope="session")
def dagbag():
    return DagBag(dag_folder=DAG_FOLDER, include_examples=False)

def test_dag_import_errors(dagbag):
    """DAG Import 과정에서 에러가 없는지 검증"""
    import_errors = dagbag.import_errors
    if import_errors:
        error_messages = []
        for filename, exception in import_errors.items():
            error_messages.append(f"File: {filename} - Error: {exception}")
        
        pytest.fail(f"DAG Import Failures ({len(import_errors)}):\n" + "\n".join(error_messages))

def test_dag_cycles(dagbag):
    """DAG 내부에 순환 참조(Cycle)가 없는지 검증"""
    for dag_id, dag in dagbag.dags.items():
        try:
            dag.test_cycle()
        except Exception as e:
            pytest.fail(f"Cycle detected in DAG '{dag_id}': {e}")

def test_dag_owner_exists(dagbag):
    """모든 DAG에 'owner' 태그가 있는지 검증 (Best Practice)"""
    for dag_id, dag in dagbag.dags.items():
        owner = dag.default_args.get('owner')
        assert owner is not None, f"DAG '{dag_id}' must have an 'owner' in default_args"

# Codex Test Strategy: Airflow Learning Module

**Date**: 2025-12-12
**Author**: Codex (GPT-5.1 Max)
**Phase**: 1 (Test Strategy)

## 1. Verification Approach
Since this is educational content, "Tests" are defined as **Validation Exercises** that the learner must perform to confirm understanding. We will provide scripts where possible to automate this.

## 2. Test Cases / Exercises

### Phase 1: Environment (Step 2)
- **TC01_ContainerHealth**:
    - **Action**: Run `docker-compose up -d`
    - **Verification**: `docker ps` shows webserver and scheduler as `healthy`.
    - **Automated Check**: `curl -f http://localhost:8080/health` returns 200.

### Phase 2: Basic DAGs (Step 3)
- **TC02_DagLoad**:
    - **Action**: Place `01_bash_operator.py` in `dags/`.
    - **Verification**: Run `airflow dags list` inside container. DAG ID `bash_demo` appears without import errors.
- **TC03_TaskExecution**:
    - **Action**: Trigger DAG.
    - **Verification**: Task state becomes `success` in Grid View.

### Phase 3: Advanced Logic (Step 4)
- **TC04_XComValue**:
    - **Action**: Run `03_xcom_example.py`.
    - **Verification**: Check Task Instance logs for "Received value: 42".

### Phase 4: CI/CD (Step 5)
- **TC05_IntegrityTest**:
    - **Action**: Run `pytest tests/test_dag_integrity.py`.
    - **Verification**: All tests pass (0 failures).

## 3. Test Artifacts to Generate
1.  `tests/test_dag_integrity.py`: A generic test script that loads the `DagBag` and checks for:
    - Import errors.
    - Cycles.
    - Missing `owner` tag.

## 4. Coverage Target
- All provided example code must pass the `test_dag_integrity.py` check.
- All code examples must be runnable on Airflow 2.9.

# Learning Objectives (User Stories) - Airflow Module

**Date**: 2025-12-12
**Author**: Claude (Opus)
**Phase**: A (Planning)

## Target Audience
- DevOps Engineers
- Data Engineers
- Backend Developers wanting to understand workflow orchestration.

## User Stories

### 1. Conceptual Understanding
- **As a** learner, **I want** to understand the core architecture of Airflow (Scheduler, Webserver, Workers, Database), **so that** I can troubleshoot connection and execution issues.
- **As a** learner, **I want** to understand what a DAG (Directed Acyclic Graph) is, **so that** I can design logical workflow dependencies.

### 2. Environment Setup
- **As a** developer, **I want** to set up a local Airflow environment using Docker Compose, **so that** I can experiment safely without polluting my host OS.
- **As a** developer, **I want** to understand the folder structure (dags/, plugins/, logs/), **so that** I know where to place my files.

### 3. Basic Implementation
- **As a** data engineer, **I want** to write a simple DAG using Python, **so that** I can schedule a periodic task.
- **As a** data engineer, **I want** to use the `BashOperator` and `PythonOperator`, **so that** I can execute shell commands and Python functions.
- **As a** data engineer, **I want** to define dependencies using `>>` and `<<` operators, **so that** tasks run in the correct order.

### 4. Advanced Features
- **As a** engineer, **I want** to pass data between tasks using XComs, **so that** downstream tasks can use results from upstream tasks.
- **As a** engineer, **I want** to handle failures using retries and alerts, **so that** my pipelines are robust.
- **As a** engineer, **I want** to use templating (Jinja) in my operators, **so that** I can make my DAGs dynamic and reusable.

### 5. Best Practices
- **As a** practitioner, **I want** to learn about idempotency, **so that** re-running a DAG doesn't corrupt data.
- **As a** practitioner, **I want** to learn how to test my DAGs, **so that** I don't break production.

## Acceptance Criteria (Learning Outcomes)
1.  **Environment**: Learner can start Airflow via `docker-compose up` and access the UI at `localhost:8080`.
2.  **Hello World**: Learner can create a DAG that prints "Hello World" and see it run successfully in the UI.
3.  **Data Flow**: Learner can create a DAG where Task A passes a value to Task B via XCom.
4.  **Error Handling**: Learner can configure a task to retry 3 times upon failure.
5.  **Scheduling**: Learner understands the difference between `start_date`, `schedule_interval`, and `execution_date`.

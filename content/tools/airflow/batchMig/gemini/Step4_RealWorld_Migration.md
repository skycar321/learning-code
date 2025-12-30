# Airflow Step 4: 실전 마이그레이션 (복합 의존성 파이프라인)

이 문서는 기존에 분산되어 실행되던 Python 배치와 Spring Batch 작업들을 Airflow로 통합 마이그레이션하는 방법을 다룹니다.

## 1. 시나리오 분석

### 기존 아키텍처 (AS-IS)
- **데이터 연동**: StreamSets (독립 실행)
- **1차 가공**: Python 스크립트 (Crontab으로 시간 기반 실행)
- **2차 가공**: Spring Batch 1 (DB 테이블 스케줄러로 시간 기반 실행)
- **3차 가공**: Spring Batch 2 (Spring Batch 1이 끝날 것으로 **예상되는 시간**에 스케줄링)

### 문제점
- **의존성 파악 불가**: Python 배치가 늦게 끝나면 Spring Batch 1이 실패하거나 잘못된 데이터를 처리할 위험이 있음.
- **실패 감지 어려움**: 각 단계가 독립적이어서, 앞 단계가 실패해도 뒷 단계가 돌아감.
- **관리 포인트 분산**: Crontab, DB 테이블, StreamSets 등 설정이 흩어져 있음.

### 목표 아키텍처 (TO-BE)
- **중앙 제어**: Airflow DAG 하나에서 전체 흐름 제어.
- **강력한 의존성**: 앞 단계가 성공해야만 뒷 단계가 실행됨 (`All Success`).
- **재처리 용이**: 실패 시 해당 지점부터 다시 실행(Retry) 가능.

## 2. DAG 구조 설계

```mermaid
graph TD
    S[StreamSets 완료 감지] --> A[Task A: Python 1차 가공]
    A --> B[Task B: Spring Batch 1 (API 호출)]
    A --> C[Task C: Spring Batch 2 (UI 데이터셋)]
    B --> C
```

- **Task A**는 **StreamSets**가 완료된 후 실행.
- **Task B**는 **Task A**가 성공한 후 실행.
- **Task C**는 **Task A**와 **Task B**가 **모두 성공**해야 실행.

## 3. 구현 상세 가이드

### 3.1 Python 배치 마이그레이션 (`BashOperator`)
기존 Crontab 명령어를 그대로 `bash_command`로 옮기는 것이 가장 빠르고 안전한 첫 단계입니다.

```python
# AS-IS (Crontab)
# 0 2 * * * /usr/bin/python3 /app/scripts/process_data.py

# TO-BE (Airflow)
task_a = BashOperator(
    task_id='python_processing',
    bash_command='/usr/bin/python3 /app/scripts/process_data.py'
)
```

### 3.2 Spring Batch 마이그레이션 (`BashOperator`)
Spring Batch를 Airflow에서 실행하는 가장 일반적인 방법은 `java -jar` 명령어를 사용하는 것입니다.
이때, **Job Parameter**를 Airflow의 매크로(`{{ ds }}`, `{{ execution_date }}`)로 넘겨주면, 재실행 시에도 해당 날짜 기준으로 배치가 돌아가게 할 수 있어 매우 강력합니다.

```python
# Spring Batch 실행
task_b = BashOperator(
    task_id='spring_batch_job',
    bash_command='java -jar /app/batch.jar --job.name=myJob date={{ ds_nodash }}'
)
```

### 3.3 의존성 설정 (핵심)
Task C가 Task A와 B의 결과를 모두 필요로 할 때의 설정입니다.

```python
# Task A가 끝나면 B 실행
task_a >> task_b

# Task C는 A와 B가 모두 끝나야 실행
[task_a, task_b] >> task_c
```

## 4. 사내망(Internal Network) 고려사항

### 4.1 오프라인 설치
사내망은 인터넷이 안 되므로, 외부에서 Docker Image를 빌드해서 반입하거나(Tar export), pip 패키지를 미리 다운로드(`pip download`) 받아야 합니다.
- **추천**: 인터넷이 되는 망에서 `Docker Image`를 완벽하게 빌드(모든 pip 패키지 포함)한 후, `.tar` 파일로 저장하여 사내망으로 반입.

### 4.2 시간대 (Timezone)
Airflow는 기본적으로 UTC를 사용합니다. 한국 시간(KST)으로 스케줄링하려면 DAG 설정이나 `airflow.cfg`에서 Timezone 설정을 반드시 확인해야 합니다.
```python
# DAG 설정 예시
dag = DAG(..., schedule_interval='0 2 * * *', start_date=pendulum.datetime(2024, 1, 1, tz="Asia/Seoul"))
```

## 5. 결론
이 구성을 통해, **"Python 배치가 아직 안 끝났는데 Spring Batch가 돌아서 에러가 나는 상황"**을 원천적으로 차단할 수 있습니다. 또한, UI 데이터셋(Task C)은 모든 데이터 준비가 완벽하게 끝난 시점에만 생성되므로 데이터 무결성이 보장됩니다.

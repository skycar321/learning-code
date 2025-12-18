# Apache Airflow 학습 계획 (Learning Plan)

## 🎯 학습 목표
이 과정은 워크플로우 오케스트레이션 도구인 **Apache Airflow**의 핵심 개념부터 운영 환경 수준의 DAG 작성 및 테스트까지 마스터하는 것을 목표로 합니다.
학습을 마치면 **Python을 사용하여 복잡한 데이터 파이프라인을 구축, 스케줄링 및 모니터링**할 수 있게 됩니다.

## 🛠 선수 지식 (Prerequisites)
- **Python (중급)**: 함수, 클래스, 데코레이터 이해 필수.
- **Docker**: 기본 컨테이너 개념 및 `docker-compose` 사용법.
- **SQL**: 기본적인 쿼리 작성 능력.

## 📚 커리큘럼 (Curriculum)

### 1단계: 개념 이해 (Step1_Concepts)
- [ ] Airflow가 필요한 이유 (Cron vs Orchestrator)
- [ ] 핵심 아키텍처: Scheduler, Webserver, Executor, Metadata DB
- [ ] 주요 용어: DAG, Operator, Task, Run, XCom

### 2단계: 환경 구축 (Step2_Setup)
- [ ] Docker Compose를 이용한 로컬 환경 구축
- [ ] 디렉토리 구조 이해 (`dags/`, `logs/`, `plugins/`)
- [ ] Airflow UI 접속 및 기능 탐색

### 3단계: DAG 작성 기초 (Step3_WritingDAGs)
- [ ] `BashOperator`와 `PythonOperator` 사용법
- [ ] TaskFlow API (`@task`) 활용 (Modern Airflow)
- [ ] Task 의존성 설정 (`>>`, `<<`)
- [ ] 스케줄링 설정 (`cron` 표현식, `timedelta`)

### 4단계: 심화 패턴 (Step4_Advanced)
- [ ] **XCom**: Task 간 데이터 공유 (Push/Pull)
- [ ] **Branching**: 조건에 따른 흐름 제어 (`BranchPythonOperator`)
- [ ] **Templating**: Jinja 템플릿을 이용한 동적 파라미터 전달

### 5단계: 테스트 및 검증 (Step5_Testing)
- [ ] CI/CD를 위한 DAG 무결성 테스트
- [ ] `DagBag`을 이용한 로드 에러 감지
- [ ] Pytest 기반의 단위 테스트 기초

### 6단계: 운영 및 모범 사례 (Step6_Operations)
- [ ] CLI 명령어 활용 (`test`, `backfill`)
- [ ] **Idempotency** (멱등성) 보장 방법
- [ ] Connection 및 Variable 관리 (보안)

## 🚀 학습 방법
각 단계의 폴더(`StepX_...`)에 있는 `README.md`를 읽고 제공된 예제 코드를 직접 실행해 보세요.
모든 예제는 `Step2_Setup`에서 구축한 Docker 환경에서 실행 가능합니다.

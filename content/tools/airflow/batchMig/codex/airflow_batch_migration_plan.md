# Airflow 배치 이관 계획서 (초안)

## 1. 목적
- 크론탭/Quartz 기반 수백 개 배치를 Airflow로 통합
- 스케줄을 중앙에서 관리하고 실패/재시도/로그를 표준화
- 수작업 스케줄 작성 없이 자동 생성 방식 도입

## 2. 범위
- 스트림셋 배치(쉘 + curl)
- 파이썬 배치(쉘 + python)
- 스프링배치1(Quartz, chunk)
- 스프링배치2(Quartz, tasklet)

## 3. 전제 및 제약
- 배치 수: 수백 개
- 동시 실행: 최대 5개
- 스프링배치 스케줄러: Quartz
- 실행 방식: jar 실행
- 데이터 저장: DB
- 환경: Azure / Rocky 8.1 / 사내망 전용

## 4. 현행 구조 요약
- 스트림셋: 크론탭 → 쉘 → curl → 타 시스템 연동
- 파이썬: 크론탭 → 쉘 → python → 1차 가공
- 스프링배치1: Quartz 스케줄러 + DB 크론 테이블 기반 실행
- 스프링배치2: Quartz 스케줄러 + DB 크론 테이블 기반 실행

## 5. 목표 아키텍처
- Airflow 단일 서버 + LocalExecutor
- Airflow가 스케줄 단일 관리
- 기존 실행 스크립트/명령 최대한 재사용
- Quartz/크론 스케줄 자동 수집 → Airflow DAG 자동 생성

## 6. 스케줄 자동 수집
### 6.1 크론탭(스트림셋/파이썬)
- 서버/계정별 크론 덤프
  - 예: `crontab -l > /tmp/cron_<user>.txt`
- 수집 파일을 중앙 서버로 집계

### 6.2 Quartz(스프링배치)
- QRTZ_TRIGGERS, QRTZ_CRON_TRIGGERS에서 크론 추출
- SQL 결과를 CSV로 저장
- JOB_NAME, CRON_EXPRESSION이 핵심

## 7. 배치 레지스트리(중앙 목록표) 설계
- 스케줄/명령/의존성을 한 파일에서 관리
- Airflow는 레지스트리만 읽어 DAG 자동 생성

권장 컬럼:
- job_id, job_type, schedule, command, timezone, depends_on, enabled

## 8. DAG 자동 생성 방식
- dags/ 아래에 DAG Factory 파일 생성
- 레지스트리 CSV/DB를 읽어 DAG를 자동 생성
- 레지스트리 수정 → DAG 자동 반영

## 9. 배치 유형별 이관 규칙
### 9.1 스트림셋 배치
- 기존 쉘 그대로 호출
- Airflow는 BashOperator로 쉘만 실행

### 9.2 파이썬 배치
- 기존 쉘 그대로 호출
- Airflow는 BashOperator로 쉘만 실행

### 9.3 스프링배치1 (Quartz → Airflow)
- Quartz 스케줄러 비활성화
- Airflow에서 jar 실행
- 예: `java -jar batch.jar --spring.batch.job.names=JOB1`

### 9.4 스프링배치2
- 스프링배치1과 동일 규칙 적용

## 10. 스케줄 변환 규칙(Quartz → Airflow)
- Quartz 크론은 6 또는 7 필드(초 포함)
- Airflow 크론은 5 필드
- 초 필드가 0이면 제거해서 사용
- 초가 0이 아니면 분 단위로 재조정 필요

## 11. 동시성(최대 5개) 반영
- Airflow 설정:
  - parallelism = 5
  - dag_concurrency = 5
- 필요시 Pool을 사용해 추가 제한

## 12. 테스트 및 전환
### 12.1 테스트
- Airflow 수동 실행
- 기존 스케줄러와 병행 운영
- 결과 비교

### 12.2 컷오버
- 크론탭 중지
- Quartz 스케줄러 중지
- Airflow 스케줄 활성화

## 13. 운영 정책
- 실패 재시도 1~3회
- 로그 보관 기간 설정
- 알림(메일/사내 메신저)
- 권한 분리(운영자/개발자)

## 14. 산출물
- 배치 레지스트리 CSV
- DAG Factory 코드
- Quartz 크론 추출 SQL
- 컷오버/운영 매뉴얼

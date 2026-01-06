# Airflow 학습 계획 (Airflow Learning Plan)

이 계획은 사내망 환경에서의 Airflow 도입, 배치 마이그레이션, 그리고 운영을 위한 단계별 학습 가이드를 제공합니다.

## 🎯 학습 목표
- **기초**: Airflow 아키텍처 이해 및 Docker 기반 로컬 환경 구축.
- **마이그레이션**: 기존 Crontab, DB 스케줄러, Spring Batch 작업을 Airflow DAG로 전환.
- **심화**: 데이터 의존성 관리(Sensor, TriggerRule), 사내망(Offline) 환경 구축 전략.
- **운영**: 모니터링, 로그 관리, 실패 시 알림 설정.

## 📚 커리큘럼

| 단계 | 주제 | 설명 | 상태 |
| :--- | :--- | :--- | :--- |
| **Step 1** | **Airflow 소개 및 아키텍처** | Scheduler, Webserver, Worker, DAG 개념 이해 | ⏳ 예정 |
| **Step 2** | **설치 및 환경 설정** | Docker Compose를 이용한 로컬 개발 환경 구축 (Postgres, Redis 포함) | ⏳ 예정 |
| **Step 3** | **DAG 작성 기초** | PythonOperator, BashOperator 사용법 및 Crontab 표현식 | ⏳ 예정 |
| **Step 4** | **실전 마이그레이션 (Current)** | **Python 배치 + Spring Batch 복합 의존성 파이프라인 구현** | ✅ 진행 중 |
| **Step 5** | **사내망(Offline) 배포 전략** | 인터넷 단절 환경에서의 pip 패키지 관리 및 Docker 이미지 배포 | ⏳ 예정 |
| **Step 6** | **운영 및 모니터링** | 실패 재시도(Retry), 알림(Alert), Backfill 개념 | ⏳ 예정 |

## 🛠 실습 환경
- **OS**: Windows (Docker Desktop / WSL2 권장) 또는 Linux
- **Language**: Python 3.8+
- **Database**: PostgreSQL (메타데이터용)

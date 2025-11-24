# 실무 PostgreSQL 성능 최적화 학습 계획 (제약 반영)

안녕하세요! 미래의 멋진 PostgreSQL 성능 튜닝 전문가 여러분!

이 학습 계획은 **제한된 서버 접근**이라는 제약을 반영하여 **PostgreSQL 핵심 기능과 SQL 기반의 최적화**에 초점을 맞춥니다. 제약 사항으로 인해 **운영 프로그램 설치, DB 서버의 `postgresql.conf` 파일 직접 접근, OS 레벨 튜닝, 하드웨어 교체 등 요구 사항을 고려할 수 없는 환경**을 가정하며, 여러분이 기존 권한 내에서 데이터베이스의 성능 병목 현상을 진단하고 최적화하는 데 필요한 핵심 역량을 길러주기 위해 기획되었습니다. 각 단계에서 제시하는 '나쁜 예시'를 통해 흔히 저지르는 실수를 파악하고, '좋은 예시'를 통해 모범 사례와 그 배경에 있는 원칙을 깊이 있게 이해하는 것이 중요합니다.

각 학습 주제는 상세한 설명과 SQL 예시, 실제 튜닝 기법을 포함하며, '왜', '어떤 상황에서', '이 해당 최적화 기법을 사용해야 하는지'를 깊이 있게 이해하는 학습이 되도록 합니다. 주도적인 학습을 위해 직접 학습 환경을 구축하고, 예시 쿼리를 실행하여 실행 계획의 변화를 분석해보는 것을 강력히 추천합니다! 모든 학습 과정을 성공적으로 마치고 나면, 여러분은 효율적이고 안정적인 데이터베이스를 운영하는 자신감을 얻을 것입니다. 자, 그럼 시작해볼까요!

---

### **학습 로드맵**

| 단계 | 주제 | 학습 목표 | 상태 |
| :-- | :--- | :--- | :--- |
| **Step 1** | **PostgreSQL 성능 모니터링 (SQL 기반)** | `pg_stat_activity`, `pg_stat_user_tables/indexes` 등 SQL 뷰를 통한 성능 지표 파악 및 비효율적 쿼리 식별 | 완료 |
| **Step 2** | **실행 계획 분석의 기초 (`EXPLAIN` & `EXPLAIN ANALYZE`)** | `EXPLAIN` 및 `EXPLAIN ANALYZE` 명령어를 이용한 쿼리 실행 계획 분석 방법 학습 (가장 중요하고 기본적인 내용) | 완료 |
| **Step 3** | **인덱스(Indexes) 최적화** | 인덱스 종류 (B-tree, GIN, BRIN 등) 이해 및 대용량 테이블에 적합한 인덱스 설계 및 적용 | 완료 |
| **Step 4** | **쿼리 튜닝 (Query Tuning)** | 비효율적 쿼리 패턴 식별 및 `JOIN`, 서브쿼리, `WHERE` 절 최적화 기법 (SQL 작성 중심) | 완료 |
| **Step 5** | **데이터베이스 설정 튜닝 (SQL 기반)** | `ALTER SYSTEM`을 통한 주요 파라미터 (`shared_buffers`, `work_mem` 등) 조정 및 영향 이해 | 완료 |
| **Step 6** | **VACUUM 및 ANALYZE 이해와 활용** | MVCC와 `VACUUM`의 필요성, 자동 VACUUM 모니터링 및 `ALTER TABLE`을 통한 테이블별 튜닝 | 완료 |
| **Step 7** | **대용량 테이블 설계 최적화** | 정규화/비정규화 전략, 데이터 타입 선택, 파티셔닝(Partitioning) 활용 | 완료 |
| **Step 8** | **쓰기 성능 최적화 (SQL 및 설정 기반)** | 배치 인서트, `UNLOGGED TABLE`, `synchronous_commit` 조정 등 쓰기 처리량 증대 기법 | 완료 |
| **Step 9** | **고급 SQL 튜닝 및 확장 기능 활용** | 쿼리 플랜 강제 지정 (SET), PL/pgSQL 최적화, 병렬 쿼리 활용 등 확장 기능 중심의 고급 기법 | 완료 |
| **Step 10** | **하드웨어 및 OS 레벨 최적화 (개념 이해)** | (직접 제어 불가능한 환경 가정) 디스크 I/O, CPU, 메모리 등 하드웨어 리소스 및 OS 최적화의 중요성 이해 | 완료 |

---

### **각 단계별 상세 내용 (예시)**

#### **Step 1: PostgreSQL 성능 모니터링 (SQL 기반)**
- **나쁜 예시**: 데이터베이스 성능 문제를 추측에 의존하여 해결하려 하거나, 단순히 서버 리소스만 보고 판단.
- **좋은 예시**: `pg_stat_activity`를 통해 현재 실행 중인 쿼리 및 대기 이벤트를 확인하고, `pg_stat_user_tables`, `pg_stat_user_indexes` 뷰를 통해 테이블/인덱스 사용량을 파악하여 병목 현상 식별.
- **학습 포인트**: 직접적인 서버 접근이 어려운 환경에서도 SQL 기반의 뷰를 적극 활용하여 문제를 진단하는 것이 중요합니다.

---

### **생성될 PostgreSQL 파일 목록**

`c:/Users/Nam/Documents/Cursor/Workspace/origin/learning-code/postgresql` 경로에 다음 파일들이 생성될 예정입니다. 이 파일들은 나쁜 예시와 좋은 예시 코드를 포함하며, 상세한 주석을 통해 각 패턴을 심층적으로 학습할 수 있도록 구성될 것입니다.

```
learning-code/postgresql/
├── Step1_PerformanceMonitoringBasics.md
├── Step2_ExecutionPlanAnalysis.sql
├── Step3_IndexOptimization.sql
├── Step4_QueryTuning.sql
├── Step5_ConfigurationTuning.md
├── Step6_VACUUMAndANALYZE.md
├── Step7_TableDesignOptimization.sql
├── Step8_WriteOptimization.md
├── Step9_AdvancedTuningTechniques.md
├── Step10_HardwareAndOSTuning.md
```

---

### **추가 학습 권장 사항**

| 주제 | 설명 | 난이도 |
|:-----|:-----|:------:|
| **pg_stat_statements 심화** | 실행된 모든 SQL 문의 통계를 추적하여 슬로우 쿼리 식별 및 최적화 우선순위 결정 | 중급 |
| **Connection Pooling (PgBouncer)** | 대규모 트래픽 환경에서 데이터베이스 연결 관리 및 성능 최적화 | 중급 |
| **논리적 복제 (Logical Replication)** | 테이블 단위 복제를 통한 무중단 마이그레이션 및 데이터 동기화 전략 | 고급 |
| **PostgreSQL 확장 기능 (Extensions)** | pg_trgm(유사도 검색), PostGIS(공간 데이터), TimescaleDB(시계열) 등 확장 활용 | 고급 |
| **Window Functions 심화** | PARTITION BY, ROW_NUMBER, LAG/LEAD 등 분석 함수를 활용한 복잡한 데이터 분석 | 중급 |
| **CTE 및 Recursive Query** | WITH 절을 활용한 복잡한 쿼리 구조화 및 계층형 데이터 처리 | 중급 |
| **JSON/JSONB 최적화** | JSONB 인덱싱 전략, GIN 인덱스 활용, JSON 쿼리 성능 최적화 | 중급 |
| **데이터베이스 보안 강화** | Row Level Security(RLS), Column-level 암호화, 감사 로깅 구현 | 고급 |
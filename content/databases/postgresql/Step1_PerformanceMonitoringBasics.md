# PostgreSQL Step 1: PostgreSQL 성능 모니터링 (SQL 기반)
# `pg_stat_activity`, `pg_stat_user_tables/indexes` 등 SQL 뷰를 통한 성능 지표 파악 및 비효율적인 쿼리 식별

# 나쁜 예시: 데이터베이스 성능 문제를 추측에 의존하여 해결하려 하거나, 단순히 서버 리소스만 보고 판단.
# 좋은 예시: `pg_stat_activity`를 통해 현재 실행 중인 쿼리 및 대기 이벤트를 확인하고, `pg_stat_user_tables`, `pg_stat_user_indexes` 뷰를 통해 테이블/인덱스 사용량을 파악하여 병목 현상을 식별.

# 학습 포인트: 직접적인 서버 접근이나 확장 프로그램 설치가 어려운 환경에서도, SQL 기반의 뷰와 통계 정보를 적극 활용하여 문제를 진단하는 것이 중요합니다.

---

## 1. PostgreSQL 성능 측정의 중요성
데이터베이스 성능 튜닝은 '측정 없이는 개선도 없다'는 원칙에 기반합니다. 어떤 쿼리가 느린지, 어떤 리소스에서 병목이 발생하는지 정확히 알아야 올바른 튜닝 전략을 세울 수 있습니다. 인프라 제약이 있는 환경에서는 사용 가능한 도구를 최대한 활용하는 지혜가 필요합니다.

## 2. PostgreSQL 내장 SQL 뷰를 통한 성능 지표
### 2.1. `pg_stat_activity` (현재 활동 세션 모니터링)
- **개요**: 현재 데이터베이스 서버에서 실행 중인 모든 프로세스(세션)의 상세 정보를 조회합니다. 어떤 쿼리가 오래 실행되고 있는지, 어떤 상태인지, 어떤 이벤트 때문에 대기 중인지 등을 파악할 수 있습니다.
- **주요 지표**:
    - `pid`: 프로세스 ID.
    - `state`: 현재 세션의 상태 (`idle`, `active`, `idle in transaction` 등). `active` 상태인 쿼리 중 `query_start`가 오래된 쿼리가 주요 모니터링 대상.
    - `query`: 현재 실행 중인 쿼리.
    - `query_start`: 쿼리 시작 시간.
    - `backend_start`: 백엔드 프로세스 시작 시간 (클라이언트의 연결 시작 시간).
    - `wait_event_type`, `wait_event`: 대기 이벤트 정보 (예: I/O, CPU 등). `Lock`, `IO` 관련 이벤트는 병목의 중요한 단서.
- **활용 예시**:
```sql
-- 현재 실행 중인 쿼리 및 소요 시간 확인
SELECT
    pid,
    application_name,
    datname,
    usename,
    client_addr,
    backend_start,
    query_start,
    state,
    (now() - query_start) AS query_duration, -- 쿼리 실행 시간
    wait_event_type,
    wait_event,
    query
FROM pg_stat_activity
WHERE state = 'active' -- 'active' 상태인 세션만 조회
ORDER BY query_duration DESC; -- 오래 실행 중인 쿼리 순으로 정렬

-- 특정 테이블에 락을 걸고 있는 세션 찾기 (예시)
SELECT
    activity.pid,
    activity.query,
    age(now(), activity.query_start) AS "query_duration"
FROM pg_stat_activity AS activity
JOIN pg_locks AS locks ON locks.pid = activity.pid
WHERE locks.relation = 'your_table_name'::regclass;
```

### 2.2. `pg_stat_user_tables` (테이블 통계 모니터링)
- **개요**: 사용자의 테이블에 대한 접근 및 변경 통계를 제공합니다. 히트 비율, 스캔 방식 등을 통해 테이블의 건강 상태를 파악할 수 있습니다.
- **주요 지표**:
    - `relname`: 테이블 이름.
    - `seq_scan`, `idx_scan`: 순차 스캔 횟수, 인덱스 스캔 횟수. (Seq Scan이 너무 많으면 인덱스 부족/비활성 의심)
    - `n_live_tup`, `n_dead_tup`: 살아있는 튜플 수, 죽은 튜플 수 (n_dead_tup이 높으면 VACUUM 필요)
    - `last_autovacuum`, `last_autoanalyze`: 자동 VACUUM/ANALYZE 마지막 실행 시각.
- **활용 예시**:
```sql
-- 테이블 스캔 및 VACUUM 관련 통계 조회
SELECT
    relname AS table_name,
    seq_scan,
    idx_scan,
    n_live_tup,
    n_dead_tup,
    last_autovacuum,
    last_autoanalyze
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC, seq_scan DESC;
```

### 2.3. `pg_stat_user_indexes` (인덱스 통계 모니터링)
- **개요**: 사용자의 인덱스에 대한 사용 통계를 제공합니다. 사용되지 않거나 비효율적인 인덱스를 식별하는 데 도움을 줍니다.
- **주요 지표**:
    - `relname`: 인덱스가 속한 테이블 이름.
    - `indexrelname`: 인덱스 이름.
    - `idx_scan`: 인덱스를 사용한 횟수.
    - `idx_tup_read`, `idx_tup_fetch`: 인덱스를 통해 읽은 튜플 수, 테이블에서 가져온 튜플 수.
- **활용 예시**:
```sql
-- 사용되지 않는 인덱스나 비효율적인 인덱스 식별
SELECT
    relname AS table_name,
    indexrelname AS index_name,
    idx_scan,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
WHERE idx_scan = 0 AND pg_relation_size(indexrelid) > 1024*1024 -- 사용되지 않고 크기가 1MB 이상인 인덱스
ORDER BY pg_relation_size(indexrelid) DESC; -- 크기가 큰 순서로 정렬하여 제거 우선순위 파악
```

## 3. 리소스 모니터링 (OS 레벨 - 인프라 담당 영역)

PostgreSQL 서버가 실행되는 OS 레벨에서의 리소스 모니터링 (CPU, 메모리, 디스크 I/O, 네트워크)은 데이터베이스 성능 문제의 원인을 파악하는 데 중요합니다.
- **CPU**: `top`, `htop`, `vmstat`
- **메모리**: `free -h`, `vmstat`
- **디스크 I/O**: `iostat`, `iotop`
- **네트워크**: `netstat`, `ss`
**이러한 OS 레벨 도구들은 일반적으로 인프라팀에서 관리하며 직접 접근이 어렵지만, 성능 문제 발생 시 인프라팀에 요청하여 해당 지표를 확인하는 것이 중요합니다.**

---

**다음 단계**: 이러한 SQL 기반 모니터링 도구들을 통해 느린 쿼리를 식별했다면, 다음은 해당 쿼리의 "실행 계획"을 분석하여 왜 느린지 근본적인 원인을 파악하는 방법을 학습합니다.

```sql
-- 이 파일은 SQL 기반 성능 모니터링 뷰의 사용법을 설명합니다.
-- 실제 학습 시 PostgreSQL 서버에 접속하여 각 SQL들을 실행해보세요.
-- `pg_stat_statements`와 같은 확장 기능은 인프라 제약으로 인해 사용하지 못한다고 가정합니다.
```
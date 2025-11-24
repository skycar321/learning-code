# PostgreSQL Step 5: 데이터베이스 설정 (Configuration) 튜닝
# `ALTER SYSTEM`을 통한 주요 파라미터 (`shared_buffers`, `work_mem` 등) 조정 및 영향 이해

# 나쁜 예시: 기본 데이터베이스 설정을 그대로 사용하거나, 서버 하드웨어 사양을 고려하지 않고 임의로 파라미터를 변경하여 성능 저하 또는 불안정성 유발.
# 좋은 예시: 서버의 CPU, RAM, 디스크 I/O 특성을 분석하고, 워크로드(OLTP/OLAP)에 맞춰 `ALTER SYSTEM` 명령어를 통해 핵심 파라미터들을 체계적으로 조정하여 최적의 성능을 달성.

# 학습 포인트: `postgresql.conf` 파일은 PostgreSQL 서버의 동작 방식을 제어하는 핵심 설정 파일입니다. 직접 파일 접근이 어려운 환경에서는 `ALTER SYSTEM` 명령어를 사용하여 설정 변경의 효과를 이해하고 적용하는 것이 중요합니다.

---

## 1. PostgreSQL 설정 변경의 제약사항

인프라 제약으로 `postgresql.conf` 파일을 직접 수정하거나 PostgreSQL 서버를 재시작하는 것이 어려울 수 있습니다. 이런 환경에서는 주로 `ALTER SYSTEM SET` 명령어를 사용하여 데이터베이스 설정을 변경해야 합니다.

## 2. `ALTER SYSTEM SET` 명령어
- **개요**: `postgresql.conf` 파일을 직접 수정하는 대신 SQL 명령어를 통해 데이터베이스 서버의 전역 설정을 변경합니다. 변경된 내용은 `postgresql.auto.conf` 파일에 기록됩니다.
- **적용**: 대부분의 파라미터는 `SELECT pg_reload_conf();`를 실행하면 서버 재시작 없이 즉시 적용됩니다. 하지만 일부 핵심 파라미터(예: `shared_buffers`, `max_connections`)는 **데이터베이스 서버의 전체 재시작이 필요**합니다. 이러한 파라미터는 인프라팀에 요청해야 합니다.

## 3. 주요 설정 파라미터와 튜닝 가이드라인

### 3.1. 메모리 관련 파라미터

#### `shared_buffers`
- **역할**: PostgreSQL이 공유 메모리 영역으로 사용하는 버퍼 크기. 디스크에서 읽은 데이터를 캐싱하여 자주 접근하는 데이터에 대한 디스크 I/O를 줄입니다.
- **가이드라인**: 총 RAM의 25% 정도로 설정하는 것이 일반적입니다. (예: 16GB RAM 서버라면 4GB) 너무 높으면 OS의 파일 시스템 캐시와 경합할 수 있습니다.
- **적용**: **서버 재시작이 필요**합니다. 인프라팀과 협의하여 변경해야 합니다.
- **나쁜 예시**: `128MB` (기본값)를 그대로 사용하거나, 서버 RAM의 50% 이상으로 설정.

#### `work_mem`
- **역할**: 쿼리 실행 중 정렬(sort), 해시 조인 생성 등 임시 작업에 대해 각 세션이 사용할 수 있는 메모리 크기. 이 메모리를 초과하면 디스크에 임시 파일을 생성하여 처리합니다(디스크 I/O 발생).
- **가이드라인**: 쿼리 복잡도와 동시 접속자 수에 따라 조정. `EXPLAIN ANALYZE` 결과에서 `Sort Method: external merge  Disk: ...`과 같은 디스크 스필 징후가 보인다면 `work_mem`을 늘려 디스크 스필(spill)을 줄일 수 있습니다.
- **적용**: `pg_reload_conf()`로 즉시 적용 가능.
- **나쁜 예시**: `4MB` (기본값)를 그대로 사용하여 복잡한 쿼리가 디스크에 과도하게 스필하게 되거나, 동시 접속자가 많을 경우 OOM(Out Of Memory)을 유발할 수 있습니다.
- **주의**: `work_mem`은 세션별로 할당되므로, 동시 접속자 수가 많을 경우 `(work_mem * 동시_접속자수)`를 고려하여 전체 서버 메모리를 초과하지 않도록 합니다.

#### `maintenance_work_mem`
- **역할**: `VACUUM`, `ANALYZE`, `CREATE INDEX`, `ALTER TABLE` 등 유지보수 작업에 사용하는 최대 메모리 크기.
- **가이드라인**: `shared_buffers`의 25% 또는 총 RAM의 10~15% 정도로 설정. `shared_buffers`보다 크게 설정하는 것이 일반적입니다. (예: 16GB RAM 서버라면 1GB~2GB)
- **적용**: `pg_reload_conf()`로 즉시 적용 가능.
- **나쁜 예시**: `64MB` (기본값)를 그대로 사용하여 `VACUUM`이나 인덱스 생성 시 비효율 발생.

### 3.2. WAL (Write-Ahead Log) 관련 파라미터 (쓰기 성능 및 복구)

#### `wal_buffers`
- **역할**: WAL 데이터를 캐싱하는 공유 메모리 크기.
- **가이드라인**: `16MB` 또는 `shared_buffers`의 1/32 정도. 너무 작으면 디스크 쓰기가 너무 자주 발생하고, 너무 크면 비효율적일 수 있습니다.
- **적용**: **서버 재시작이 필요**합니다.

#### `checkpoint_timeout` / `max_wal_size`
- **역할**: WAL 파일을 디스크에 강제로 쓰는 체크포인트의 빈도를 제어. 체크포인트는 데이터베이스의 안정성을 보장하고 복구 시간을 줄이는 데 중요.
- **가이드라인**: `checkpoint_timeout = 10min`, `max_wal_size = 4GB` 이상으로 설정하여 체크포인트의 빈도를 줄여 쓰기 성능을 높일 수 있습니다. 너무 길면 복구 시간이 길어집니다.
- **적용**: `pg_reload_conf()`로 즉시 적용 가능.
- **나쁜 예시**: 너무 짧은 `checkpoint_timeout`으로 디스크 쓰기 부하를 증가시킴.

### 3.3. 접속 및 연결 관련 파라미터

#### `max_connections`
- **역할**: 데이터베이스가 허용하는 최대 동시 연결 수.
- **가이드라인**: 애플리케이션의 최대 동시 접속자 수 + 관리자 접속 수. 너무 높으면 메모리 부족 또는 서버 부하.
- **적용**: **서버 재시작이 필요**합니다.
- **나쁜 예시**: `100` (기본값)을 그대로 사용하여 동시 접속자가 많은 웹 애플리케이션에서 연결 부족 오류 발생. 또는 너무 높게 설정하여 서버 자원 고갈.

### 3.4. 자동 VACUUM 관련 파라미터

#### `autovacuum`
- **역할**: 백그라운드에서 `VACUUM` 및 `ANALYZE` 작업을 자동으로 실행하는 기능. **반드시 `on`으로 설정해야 합니다.**
- **가이드라인**: `on`으로 설정하고, 세부 파라미터 (`autovacuum_vacuum_scale_factor`, `autovacuum_vacuum_cost_delay` 등)를 튜닝.
- **적용**: 대부분 `pg_reload_conf()`로 즉시 적용 가능.
- **나쁜 예시**: `autovacuum = off`로 설정하여 테이블이 비대해지고 쿼리 성능 저하 (다음 Step에서 상세히 다룸).

### 3.5. 로깅 관련 파라미터

#### `log_min_duration_statement`
- **역할**: 지정된 시간(밀리초)보다 오래 걸리는 쿼리를 로그에 기록합니다. 느린 쿼리를 식별하는 데 매우 유용합니다.
- **가이드라인**: `100ms` 또는 `1s` 등으로 설정하여 느린 쿼리를 쉽게 찾을 수 있도록 합니다. `0`으로 설정하면 모든 쿼리를 기록.
- **적용**: `pg_reload_conf()`로 즉시 적용 가능.
- **나쁜 예시**: `log_min_duration_statement = -1` (기본값)으로 설정하여 느린 쿼리가 로그에 기록되지 않게 됨.

## 4. 튜닝 시 고려사항

- **하드웨어 사양**: 서버의 CPU, RAM, 디스크(SSD/HDD) 종류에 따라 파라미터 값을 조정해야 합니다. 이러한 정보는 인프라팀을 통해 파악해야 합니다.
- **워크로드 특성**: OLTP (온라인 트랜잭션 처리)와 OLAP (온라인 분석 처리) 워크로드는 요구하는 설정이 다릅니다.
    - OLTP: 짧은 지연 시간, 다수 동시 사용자. `shared_buffers`, `max_connections` 중요.
    - OLAP: 대규모 데이터 처리. `work_mem`, `maintenance_work_mem` 중요.
- **측정 및 반복**: 변경 후에는 반드시 성능을 측정하고, 점진적으로 변경하며 최적의 값을 찾아야 합니다. 한 번에 여러 파라미터를 변경하면 어떤 변경이 효과를 주었는지 알기 어렵습니다.

---

```sql
-- 이 파일은 PostgreSQL 설정 튜닝의 개념을 설명합니다.
-- `ALTER SYSTEM` 명령어를 사용하여 실습하고, 재시작이 필요한 파라미터는 인프라팀과 협의해야 합니다.

-- 현재 설정값 확인
SHOW shared_buffers;
SHOW work_mem;
SHOW maintenance_work_mem;
SHOW max_connections;
SHOW log_min_duration_statement;

-- 설정 변경 예시 (pg_reload_conf() 로 즉시 적용)
ALTER SYSTEM SET work_mem = '64MB';
ALTER SYSTEM SET log_min_duration_statement = '1000'; -- 1초 이상 걸리는 쿼리 로깅

-- 설정 변경 후 서버에 적용
SELECT pg_reload_conf();

-- 서버 재시작이 필요한 파라미터 변경 예시 (인프라팀 요청 필요)
-- ALTER SYSTEM SET shared_buffers = '4GB';
-- ALTER SYSTEM SET max_connections = '200';
```
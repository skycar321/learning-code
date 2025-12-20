# PostgreSQL Step 8: 쓰기 성능 최적화 (SQL 및 설정 기반)
# 배치 삽입, `UNLOGGED TABLE` 기법 및 `fsync`, `synchronous_commit` 등 쓰기 관련 파라미터 튜닝

# 나쁜 예시: 기본 데이터베이스 설정을 그대로 사용하거나, 트랜잭션을 너무 자주 커밋하여 불필요한 WAL 쓰기 오버헤드 발생.
# 좋은 예시: 쓰기 성능 관련 파라미터를 `ALTER SYSTEM`을 통해 워크로드에 맞춰 조정하고, 배치 삽입, `UNLOGGED TABLE` 등 SQL 레벨의 쓰기 최적화 기법을 사용하여 처리량 증대.

# 학습 포인트: PostgreSQL의 쓰기 성능은 WAL(Write-Ahead Log) 메커니즘과 깊은 관련이 있습니다. 데이터의 영구성(durability)과 쓰기 성능 사이의 균형을 이해하고 SQL 명령어를 통해 튜닝하는 것이 중요합니다.

---

## 1. WAL (Write-Ahead Log)과 쓰기 성능

- PostgreSQL은 모든 데이터 변경사항을 디스크에 기록하기 전에 WAL 파일에 먼저 기록합니다.
- 이는 충돌 시 복구(crash recovery) 시 데이터의 안정성을 보장하는 중요한 메커니즘입니다.
- WAL 쓰기가 너무 잦거나 비효율적이면 전체 쓰기 성능이 저하됩니다.

## 2. 주요 쓰기 성능 관련 파라미터 (`ALTER SYSTEM` 사용)

### 2.1. `fsync`
- **역할**: WAL 기록이 물리적으로 디스크에 성공적으로 기록되었는지 강제로 동기화할지 여부.
- **가이드라인**: **반드시 `on`으로 설정해야 합니다.** `off`로 설정하면 충돌 발생 시 데이터 유실 위험이 매우 높습니다. 테스트 환경에서만 사용 고려.
- **적용**: **서버 재시작이 필요**한 경우가 많으므로 인프라팀과 협의가 필요합니다.
- **나쁜 예시**: 프로덕션 환경에서 `fsync = off`로 설정하여 성능을 높이다 데이터 유실 위험 초래.

### 2.2. `synchronous_commit`
- **역할**: 트랜잭션을 커밋할 때 WAL 레코드가 디스크에 쓰여질(fsync) 때까지 기다릴지 여부.
- **가이드라인**:
    - `on` (기본값): 가장 안전. 각 커밋마다 WAL이 디스크에 기록됨.
    - `local`: WAL이 로컬 디스크에 기록되었지만 OS의 캐시에 있을 수 있음. 충돌 시 데이터 유실 가능성 낮음.
    - `off`: WAL이 즉시 디스크에 기록되지 않고 OS가 결정. 가장 빠르지만 **데이터 유실 위험이 가장 높습니다.**
- **적용**: `pg_reload_conf()`로 즉시 적용 가능.
- **튜닝**: 지연 시간(latency)보다 전체 쓰기 처리량(throughput)이 중요한 워크로드(예: 배치 처리)에서는 `off`를 고려해볼 수 있지만, **데이터 유실 위험을 명확히 인지하고 신중하게 결정해야 합니다.** (일반적으로 `on` 유지 권장)
- **나쁜 예시**: `on`을 `off`로 변경하여 성능이 높아지지만, 서버 충돌 시 최근 커밋된 데이터가 유실될 수 있음을 간과.

### 2.3. `wal_buffers`
- **역할**: WAL 데이터를 디스크에 기록하기 전에 메모리에서 버퍼링되는 공간.
- **가이드라인**: `16MB` 또는 `shared_buffers`의 1/32 정도. 너무 작으면 WAL 쓰기 빈번, 너무 크면 비효율적.
- **적용**: **서버 재시작이 필요**하므로 인프라팀과 협의가 필요합니다.

### 2.4. `commit_delay` / `commit_siblings`
- **역할**: `commit_delay`는 트랜잭션 커밋 시 다른 세션들이 커밋할 때까지 특정 시간(마이크로초) 대기합니다. `commit_siblings`는 대기할 때 필요한 최소 동시 커밋 세션 수.
- **가이드라인**: 짧은 트랜잭션이 많은 OLTP 환경에서 `commit_delay`를 `1000` (1ms) 등으로 설정하면 여러 트랜잭션의 WAL 쓰기를 한 번에 처리하여 쓰기 처리량을 높일 수 있습니다.
- **적용**: `pg_reload_conf()`로 즉시 적용 가능.
- **주의**: `commit_delay`가 너무 높으면 트랜잭션 지연 시간(latency)이 증가할 수 있습니다.

## 3. 쓰기 성능 최적화 기법 (SQL 레벨)

### 3.1. 배치 삽입 (Batch Inserts)
- 여러 `INSERT` 문을 한 번의 트랜잭션으로 묶거나, `COPY` 명령어를 사용하여 대량의 데이터를 삽입합니다.
- 각 `INSERT` 문마다 발생하는 트랜잭션 오버헤드와 WAL 쓰기를 줄일 수 있습니다.

```sql
-- 나쁜 예시: 1000개의 INSERT를 1000번 커밋
BEGIN;
INSERT INTO my_table (col1, col2) VALUES (1, 'a');
COMMIT;
BEGIN;
INSERT INTO my_table (col1, col2) VALUES (2, 'b');
COMMIT;
-- ... 반복

-- 좋은 예시: 한 번의 트랜잭션으로 여러 INSERT
BEGIN;
INSERT INTO my_table (col1, col2) VALUES (1, 'a'), (2, 'b'), (3, 'c');
INSERT INTO my_table (col1, col2) VALUES (4, 'd'), (5, 'e');
COMMIT;

-- 최적의 대량 삽입: COPY 명령어
-- \COPY는 psql 클라이언트 명령어이므로 애플리케이션에서는 언어별 라이브러리의 COPY API를 사용해야 합니다.
-- \COPY my_table FROM '/path/to/data.csv' WITH (FORMAT CSV);
```

### 3.2. `UNLOGGED TABLE` (비로깅 테이블)
- **역할**: WAL에 기록되지 않는 테이블.
- **장점**: 쓰기 작업이 매우 빠릅니다.
- **단점**: 충돌 발생 시 데이터가 유실됩니다. 복제본으로 동기화되지 않습니다.
- **용도**: 임시 데이터, 캐싱 데이터 등 복구가 불필요한 데이터에 사용합니다.

```sql
-- UNLOGGED TABLE 생성
CREATE UNLOGGED TABLE temp_session_data (
    session_id UUID PRIMARY KEY,
    user_id INTEGER,
    data JSONB
);
```

### 3.3. 인덱스 최적화 (쓰기 관점)
- 인덱스는 `INSERT`, `UPDATE`, `DELETE` 시 함께 갱신되어야 하므로 쓰기 성능에 영향을 미칩니다.
- 불필요한 인덱스는 생성하지 않고, 사용되지 않는 인덱스는 제거합니다. (Step 3 참고)
- `CREATE INDEX CONCURRENTLY`: 인덱스 생성 시 테이블을 잠그지 않아 서비스 중단 없이 인덱스를 생성합니다. (일반 `CREATE INDEX`보다 더 오래 걸림)

### 3.4. `TRUNCATE` 사용
- `DELETE`는 행을 하나씩 삭제하고 WAL에 기록하지만, `TRUNCATE`는 테이블의 모든 데이터를 빠르게 제거하고 WAL 기록이 훨씬 적습니다.
- **주의**: `TRUNCATE`는 `WHERE` 절을 사용할 수 없습니다.

## 4. 모니터링 뷰
- `pg_stat_wal`: WAL 활동에 대한 통계 정보.
- `pg_stat_bgwriter`: 백그라운드 쓰기 프로세스 통계.
- `pg_stat_database`: 데이터베이스별 WAL 쓰기 양.

이러한 뷰를 모니터링하여 WAL 관련 병목을 식별할 수 있습니다.

---

```sql
-- 이 파일은 PostgreSQL 쓰기 성능 최적화의 개념을 설명하고 SQL 명령어를 통한 튜닝 방법을 제시합니다.
-- `ALTER SYSTEM` 명령어를 사용하여 설정을 조정하고 `pg_reload_conf()`를 사용합니다.
-- 서버 재시작이 필요한 파라미터는 인프라팀과 협의가 필요합니다.

-- 현재 설정값 확인
SHOW fsync;
SHOW synchronous_commit;
SHOW wal_buffers;
SHOW commit_delay;
SHOW commit_siblings;

-- 설정 변경 예시 (`pg_reload_conf()` 로 즉시 적용)
-- ALTER SYSTEM SET synchronous_commit = 'off'; -- 데이터 유실 위험 감수 시 사용
-- ALTER SYSTEM SET commit_delay = '1000'; -- 1ms 지연
-- 설정 변경 후 서버에 적용: SELECT pg_reload_conf();

-- 서버 재시작이 필요한 파라미터 변경 예시 (인프라팀 요청 필요)
-- ALTER SYSTEM SET wal_buffers = '32MB';
```
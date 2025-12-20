# PostgreSQL Step 6: VACUUM 및 ANALYZE 이해와 활용
# MVCC(Multi-Version Concurrency Control)와 `VACUUM`의 필요성, 자동 VACUUM 모니터링 및 `ALTER TABLE`을 통한 테이블별 튜닝

# 나쁜 예시: `VACUUM`의 중요성을 간과하여 테이블이 비대해지고 쿼리 성능이 저하되며, 인덱스가 비효율적으로 사용되도록 방치합니다.
# 좋은 예시: MVCC의 작동 방식을 이해하고, `VACUUM`과 `ANALYZE` 명령어를 적절히 사용하여 테이블을 최적화하며, 자동 VACUUM 설정을 `ALTER SYSTEM` 또는 `ALTER TABLE`을 통해 워크로드에 맞춰 튜닝하여 데이터베이스의 건강한 상태를 유지.

# 학습 포인트: PostgreSQL의 MVCC 아키텍처는 동시성을 제어하는 데 강력하지만, 그 대가로 주기적인 `VACUUM` 작업이 필수적입니다. 직접적인 `postgresql.conf` 수정이 어려운 환경에서는 SQL 명령어를 통한 설정 조정이 중요합니다.

---

## 1. MVCC (Multi-Version Concurrency Control)와 `VACUUM`의 필요성
### 1.1. MVCC
- PostgreSQL은 MVCC(다중 버전 동시성 제어) 모델을 사용합니다.
- `UPDATE` 또는 `DELETE` 작업이 발생하면, 실제 행을 즉시 덮어쓰거나 삭제하지 않고 새로운 버전의 행을 생성합니다.
- `UPDATE`는 `INSERT`와 `DELETE`의 조합으로 작동합니다. (기존 행 삭제 표시, 새 버전 삽입)
- 이로써 읽기 작업(SELECT)이 쓰기 작업(UPDATE/DELETE)에 의해 블록되지 않고, 각 트랜잭션은 시작 시점의 일관된 스냅샷을 볼 수 있습니다.

### 1.2. 데드 튜플 (Dead Tuples)
- MVCC로 인해 `UPDATE` 또는 `DELETE`된 이전 버전의 행은 "데드 튜플"로 남게 됩니다.
- 데드 튜플은 디스크 공간을 차지하며, 테이블 스캔 시 불필요하게 읽히므로 쿼리 성능을 저하시킵니다.
- 데드 튜플이 많아지면 인덱스도 비대해져 비효율적으로 됩니다.

### 1.3. `VACUUM`의 역할
- `VACUUM` 명령어는 데드 튜플이 차지하는 디스크 공간을 "재활용 가능"하게 표시합니다.
- **`VACUUM`**: 데드 튜플이 차지하는 공간을 재활용 가능하게 표시할 뿐, 파일 크기를 줄이지는 않습니다.
- **`VACUUM FULL`**: 테이블 전체를 재작성하여 데드 튜플을 완전히 제거하고 디스크 공간을 운영체제에 반환합니다. **매우 느리고 테이블 락을 유발하므로 프로덕션에서는 거의 사용하지 않습니다.**
- **`VACUUM (FREEZE)`**: 트랜잭션 ID 롤오버(Transaction ID Wraparound) 문제를 방지합니다. 오래된 트랜잭션 ID가 모두 제거되면 새로 생성하는 트랜잭션 ID가 다시 시작하여 무한히 증가하는 것을 방지합니다.

## 2. `ANALYZE`의 역할

- **역할**: 테이블의 내용(데이터 분포)에 대한 통계 정보를 수집하고 갱신합니다.
- 이 통계 정보는 쿼리 옵티마이저가 최적의 실행 계획을 생성하는 데 사용됩니다.
- `ANALYZE`가 실행되지 않으면 옵티마이저가 오래된 통계를 기반으로 비효율적인 실행 계획을 선택할 수 있습니다.
- `VACUUM`은 데드 튜플을 처리하고, `ANALYZE`는 통계 정보를 갱신합니다. 둘은 서로 다른 목적을 가집니다.

## 3. `autovacuum` (자동 VACUUM)

- PostgreSQL은 백그라운드에서 `autovacuum` 데몬을 실행하여 `VACUUM` 및 `ANALYZE` 작업을 자동으로 실행합니다.
- **`autovacuum = on`은 필수입니다.** (기본값)
- **튜닝 파라미터**: `ALTER SYSTEM` 또는 `ALTER TABLE` 명령어를 사용하여 `autovacuum` 관련 파라미터들을 조정하여 워크로드에 맞게 자동 VACUUM의 동작을 최적화할 수 있습니다.

### 3.1. 주요 자동 VACUUM 튜닝 파라미터

#### `autovacuum_vacuum_scale_factor` / `autovacuum_vacuum_threshold`
- **역할**: 테이블의 `VACUUM`을 트리거하는 조건. (데드 튜플의 비율 또는 개수)
- **가이드라인**:
    - `autovacuum_vacuum_scale_factor` (기본값 0.2): 데드 튜플 비율 (테이블 크기의 20%).
    - `autovacuum_vacuum_threshold` (기본값 50): 데드 튜플 최소 개수.
    - `VACUUM`은 `(데드_튜플_개수 > autovacuum_vacuum_threshold + autovacuum_vacuum_scale_factor * 총_튜플_개수)`일 때 실행됩니다.
- **튜닝**: `INSERT/UPDATE/DELETE`가 많은 테이블은 `scale_factor`를 낮추거나 `threshold`를 높여 `VACUUM`이 더 자주 실행되도록 조정할 수 있습니다. (테이블별 설정 권장)

#### `autovacuum_analyze_scale_factor` / `autovacuum_analyze_threshold`
- **역할**: 테이블의 `ANALYZE`를 트리거하는 조건. (변경된 행의 비율 또는 개수)
- **가이드라인**: `autovacuum_analyze_scale_factor` (기본값 0.1), `autovacuum_analyze_threshold` (기본값 50).
- **튜닝**: 데이터 분포가 자주 변경되는 테이블은 `scale_factor`를 낮춰 `ANALYZE`를 더 자주 실행하도록 조정할 수 있습니다. (테이블별 설정 권장)

#### `autovacuum_vacuum_cost_delay`
- **역할**: 자동 VACUUM 작업이 일시 중지하는 시간 (밀리초).
- **가이드라인**: `2ms` (기본값). 너무 작으면 VACUUM이 너무 공격적으로 실행되어 디스크 자원을 많이 사용하고, 너무 크면 VACUUM이 느려집니다. I/O 부하가 적은 시스템에서는 크게 설정하여 VACUUM이 백그라운드에서 조용히 실행되도록 할 수 있습니다.

#### `autovacuum_max_workers`
- **역할**: 동시에 실행될 수 있는 최대 자동 VACUUM 워커 프로세스 수.
- **가이드라인**: `3` (기본값). CPU 코어 수, 디스크 I/O 성능을 고려하여 조정.

### 3.2. 자동 VACUUM 설정 변경 방법

- **전역 설정 (DB 서버 전체)**: `ALTER SYSTEM SET autovacuum_vacuum_cost_delay = '10ms';`
  - 변경 후 `SELECT pg_reload_conf();`를 실행하면 재시작 없이 적용됩니다.
- **테이블별 설정**: `ALTER TABLE <table_name> SET (autovacuum_vacuum_scale_factor = 0.05, autovacuum_vacuum_threshold = 100);`
  - 테이블별 설정은 전역 설정보다 우선합니다. `INSERT/UPDATE/DELETE` 패턴이 매우 다른 테이블에 적용합니다.

## 4. 수동 VACUUM 및 ANALYZE

- `VACUUM <table_name>;`
- `ANALYZE <table_name>;`
- `VACUUM (VERBOSE, ANALYZE) <table_name>;` (상세 정보 포함)
- `REINDEX TABLE <table_name>;` 또는 `REINDEX INDEX <index_name>;` (인덱스 재구성)

## 5. 트랜잭션 ID 롤오버 (Transaction ID Wraparound)

- PostgreSQL의 트랜잭션 ID는 32비트 정수이며, 약 20억개를 사용하면 다시 0으로 돌아갑니다.
- 데드 튜플이 너무 오래 남아있어 트랜잭션 ID가 롤오버되면 데이터 유실을 방지하기 위해 데이터베이스가 셧다운될 수 있습니다.
- `VACUUM (FREEZE)`가 이 문제를 방지합니다. 자동 VACUUM이 이 작업을 자동으로 실행합니다.
- `autovacuum_freeze_max_age` (기본값 2억) 파라미터가 `FREEZE`를 트리거하는 트랜잭션 ID의 최대 개수를 설정합니다. (전역 설정은 `ALTER SYSTEM`, 테이블별 설정은 `ALTER TABLE`로 가능)

---

```
-- 이 파일은 VACUUM 및 ANALYZE의 개념을 설명하고 SQL 명령어를 통한 튜닝 방법을 제시합니다.
-- `ALTER SYSTEM` 또는 `ALTER TABLE` 명령어를 사용하여 자동 VACUUM 설정을 조정할 수 있습니다.

-- 데드 튜플 및 ANALYZE 정보 확인 (SQL 뷰 활용)
SELECT
    relname,
    n_live_tup, -- 살아있는 튜플 수
    n_dead_tup, -- 데드 튜플 수
    last_autovacuum,
    last_autoanalyze
FROM pg_stat_all_tables
WHERE schemaname = 'public'
ORDER BY n_dead_tup DESC;

-- 테이블의 자동 VACUUM 설정 확인
SELECT relname, reloptions FROM pg_class WHERE relname = 'your_table_name';

-- 특정 테이블에 대한 자동 VACUUM 설정 변경 (예시)
-- ALTER TABLE your_table SET (autovacuum_vacuum_scale_factor = 0.05);
-- ALTER TABLE your_table SET (autovacuum_vacuum_threshold = 100);
-- ALTER TABLE your_table SET (autovacuum_analyze_scale_factor = 0.02);
```
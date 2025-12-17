# Step 11: PostgreSQL 트러블슈팅 가이드 (Troubleshooting Guide)

PostgreSQL 운영 및 개발 중 자주 마주치는 오류 Top 50을 정리했습니다. 오류 메시지의 핵심 키워드로 검색(`Ctrl+F`)하여 원인과 해결책을 빠르게 찾으세요.

## 1. Connection Errors (연결 오류)

### 1-1. `password authentication failed for user "..."`
- **원인**: 비밀번호 불일치 또는 `pg_hba.conf` 인증 방식(md5, scram-sha-256) 설정 오류.
- **해결**: 비밀번호 재확인. `pg_hba.conf`에서 `ident` 방식을 `md5`나 `scram-sha-256`으로 변경 후 리로드.

### 1-2. `FATAL: sorry, too many clients already`
- **원인**: `max_connections` 한도 초과.
- **해결**: `postgresql.conf`의 `max_connections` 증가 (재시작 필요) 또는 PgBouncer 같은 Connection Pooler 도입.

### 1-3. `connection refused` (Is the server running on host "..."?)
- **원인**: 포트(5432)가 막혀있거나, `postgresql.conf`의 `listen_addresses`가 `localhost`로만 되어 있음.
- **해결**: `listen_addresses = '*'` 설정 및 방화벽(UFW/Security Group) 확인.

### 1-4. `no pg_hba.conf entry for host "...", user "...", database "..."`
- **원인**: 클라이언트 IP가 `pg_hba.conf`의 허용 목록에 없음.
- **해결**: `host all all <client-ip>/32 md5` 라인 추가 후 `pg_ctl reload`.

### 1-5. `database "..." does not exist`
- **원인**: 접속하려는 DB명이 실제 존재하지 않음.
- **해결**: `\l`로 DB 목록 확인. 대소문자 구분 주의.

### 1-6. `role "..." does not exist`
- **원인**: 해당 유저(Role)가 생성되지 않음.
- **해결**: `CREATE USER <name> WITH PASSWORD ...` 수행.

### 1-7. `SSL connection has been closed unexpectedly`
- **원인**: 네트워크 불안정 또는 SSL 인증서 만료/불일치.
- **해결**: 서버 로그 확인. 클라이언트 SSL 모드(`sslmode=disable` 등) 조정 테스트.

### 1-8. `remaining connection slots are reserved for non-replication superuser connections`
- **원인**: `max_connections`에 도달했으나, `superuser_reserved_connections` 만큼의 여유분만 남음.
- **해결**: 일반 유저 접속 불가 상태. 슈퍼유저로 접속하여 `pg_terminate_backend()`로 유휴 세션 정리.

### 1-9. `could not connect to server: No such file or directory` (Socket)
- **원인**: Unix Socket 파일(`/tmp/.s.PGSQL.5432`)을 찾을 수 없음. 로컬 접속 시 발생.
- **해결**: `postgresql.conf`의 `unix_socket_directories` 확인.

### 1-10. `IPv6 connection failed`
- **원인**: `localhost`가 `::1`로 리졸브되는데, PG는 IPv4만 리슨 중.
- **해결**: 명시적으로 `127.0.0.1`로 접속하거나 서버 설정을 IPv6도 리슨하도록 변경.

---

## 2. SQL Syntax & Usage (쿼리 및 문법)

### 2-1. `syntax error at or near "..."`
- **원인**: SQL 문법 오류 (오타, 콤마 누락, 예약어 사용).
- **해결**: 해당 위치 전후 확인. 예약어는 쌍따옴표(`"`)로 감싸야 함.

### 2-2. `relation "..." does not exist`
- **원인**: 테이블이 없거나, **대소문자 문제**. (생성 시 쌍따옴표로 `"MyTable"`이라 만들고 `SELECT * FROM MyTable`로 조회하면 에러).
- **해결**: `\dt`로 테이블명 확인. 대소문자 정확히 일치(`"MyTable"`)시키거나, 소문자로만 테이블 생성 권장.

### 2-3. `column "..." does not exist`
- **원인**: 컬럼명 오타 또는 대소문자 문제.
- **해결**: 테이블 스키마 확인.

### 2-4. `ambiguous column name "..."`
- **원인**: 조인(Join) 시 두 테이블에 같은 이름의 컬럼이 존재.
- **해결**: `table_alias.column_name` 형식으로 명시.

### 2-5. `operator does not exist: integer = text` (Type Mismatch)
- **원인**: 서로 다른 타입끼리 비교/연산 시도. PG는 엄격한 타입 체크를 함.
- **해결**: 명시적 캐스팅(`::int`, `::text`) 사용.

### 2-6. `division by zero`
- **원인**: 0으로 나누기 시도.
- **해결**: `NULLIF(column, 0)` 사용하여 0을 NULL로 변환 처리.

### 2-7. `value too long for type character varying(n)`
- **원인**: 선언된 VARCHAR 길이보다 긴 문자열 입력.
- **해결**: 컬럼 타입 변경(`TEXT` 권장) 또는 입력값 검증.

### 2-8. `null value in column "..." violates not-null constraint`
- **원인**: NOT NULL 컬럼에 NULL 입력.
- **해결**: Default 값 설정 또는 입력 데이터 확인.

### 2-9. `duplicate key value violates unique constraint`
- **원인**: 이미 존재하는 PK 또는 Unique 값을 입력.
- **해결**: `INSERT ... ON CONFLICT DO UPDATE` (Upsert) 사용 또는 데이터 정제.

### 2-10. `update or delete on table "..." violates foreign key constraint`
- **원인**: 자식 테이블에서 참조 중인 부모 테이블 데이터를 삭제/수정하려 함.
- **해결**: 자식 데이터 먼저 삭제 또는 `CASCADE` 옵션 확인.

---

## 3. Performance & Locks (성능 및 락)

### 3-1. `lock wait timeout exceeded`
- **원인**: 다른 트랜잭션이 락을 잡고 안 놔줌. `lock_timeout` 설정 시간 초과.
- **해결**: `pg_blocking_pids()`로 블로킹 세션 찾아 `pg_terminate_backend()` 수행.

### 3-2. `deadlock detected`
- **원인**: 서로가 서로의 자원을 기다리는 교착 상태.
- **해결**: 애플리케이션 로직에서 테이블 접근 순서 통일. 트랜잭션 범위 최소화.

### 3-3. `idle in transaction`
- **원인**: 트랜잭션을 시작(`BEGIN`)하고 커밋/롤백 없이 방치된 세션. 락을 계속 잡고 있어 매우 위험.
- **해결**: 애플리케이션 버그 수정. `idle_in_transaction_session_timeout` 설정.

### 3-4. `temporary file size exceeds temp_file_limit`
- **원인**: 정렬(Sort)이나 해시 조인 시 `work_mem`이 부족해 디스크(Temp file)를 쓰는데, 그 크기가 제한을 넘음.
- **해결**: 쿼리 튜닝(인덱스 사용), `work_mem` 일시 증량, 또는 `temp_file_limit` 상향.

### 3-5. `out of shared memory` (You might need to increase max_locks_per_transaction)
- **원인**: 한 트랜잭션이 너무 많은 테이블/행에 락을 검.
- **해결**: `max_locks_per_transaction` 증가 (재시작 필요).

### 3-6. `PANIC: could not write to file "pg_wal/..." : No space left on device`
- **원인**: 디스크 꽉 참 (주로 WAL 폭증).
- **해결**: 디스크 증설이 최선.
- **경고**: 공간 확보를 위해 **`pg_wal` 디렉토리의 파일을 수동으로 절대 삭제하지 마십시오.** 데이터베이스 복구가 불가능해질 수 있습니다. `archive_cleanup` 명령어를 사용하거나, 다른 불필요한 로그 파일(`pg_log`)을 먼저 지우세요.

### 3-7. `checkpoint request failed` / Checkpoint Warning
- **원인**: Checkpoint가 너무 자주 발생 (`max_wal_size` 작음).
- **해결**: `max_wal_size` 증가.

### 3-8. Slow Query (Index Scan 안 함)
- **원인**: 통계 정보가 낡았거나(`ANALYZE` 필요), 인덱스가 비효율적.
- **해결**: `EXPLAIN ANALYZE`로 실행 계획 확인. `VACUUM ANALYZE` 수행.

### 3-9. Autovacuum Freeze Storm
- **원인**: Transaction ID Wraparound 방지를 위해 강제로 전체 테이블 Vacuum 실행됨. 성능 저하.
- **해결**: 평소에 Autovacuum이 잘 돌도록 튜닝. 발생 시 기다리는 수밖에 없음.

### 3-10. High CPU Usage
- **원인**: 복잡한 연산, 시퀀셜 스캔(Sequential Scan), 또는 과도한 연결 생성/종료.
- **해결**: `pg_stat_statements`로 CPU 많이 쓰는 쿼리 식별.

---

## 4. Replication (복제)

### 4-1. `requested WAL segment ... has already been removed`
- **원인**: Standby가 필요로 하는 WAL을 Primary가 이미 지워버림. (Lag이 너무 길거나 `max_wal_size`가 작음).
- **해결**: Replication Slot 사용 권장. Standby 재구축(`pg_basebackup`) 필요할 수 있음.

### 4-2. `standby conflict` (User query canceled)
- **원인**: Primary에서 삭제된 데이터(Vacuum)를 Standby에서 조회 중일 때 충돌.
- **해결**: `hot_standby_feedback = on` 설정, 또는 `max_standby_streaming_delay` 증가.

### 4-3. Replication Lag Increasing
- **원인**: 네트워크 느림, 또는 Standby의 디스크 I/O가 WAL 적용 속도를 못 따라감.
- **해결**: 모니터링(`pg_stat_replication`). Standby 하드웨어 스펙 업그레이드.

### 4-4. `replication slot "..." is active`
- **원인**: 슬롯을 삭제하려는데 사용 중임.
- **해결**: 해당 슬롯을 쓰는 복제 연결을 먼저 끊어야 함.

### 4-5. `cannot execute INSERT in a read-only transaction`
- **원인**: Standby(읽기 전용) 서버에 쓰기 시도.
- **해결**: 접속한 DB가 Primary인지 확인. 로드밸런서 설정 확인.

### 4-6. `archive command failed`
- **원인**: WAL 아카이빙 스크립트 에러 (디스크 풀, 권한 문제).
- **해결**: `archive_command` 로그 확인 및 수정.

### 4-7. Timeline Divergence
- **원인**: Failover 후 이전 Primary가 다시 붙으려 할 때 타임라인이 갈라짐.
- **해결**: `pg_rewind`를 사용하여 타임라인 동기화.

### 4-8. Logical Replication Target Missing
- **원인**: 논리적 복제 시 대상 테이블이 없거나 스키마가 다름.
- **해결**: 스키마 수동 동기화.

### 4-9. `subscriber disabled`
- **원인**: 에러로 인해 논리적 복제 구독(Subscription)이 비활성화됨.
- **해결**: 로그 확인 후 에러 해결하고 `ALTER SUBSCRIPTION ... ENABLE`.

### 4-10. WAL Files Accumulating
- **원인**: Replication Slot이 있는데 Standby가 접속 안 함 (Zombie Slot).
- **해결**: `pg_replication_slots` 조회 후 안 쓰는 슬롯 삭제 `pg_drop_replication_slot()`.

---

## 5. Operational & Corruption (운영 및 손상)

### 5-1. `the database system is starting up`
- **원인**: 아직 복구(Recovery) 모드 진행 중. 접속 불가.
- **해결**: 완료될 때까지 대기. 로그(`tail -f postgresql.log`) 모니터링.

### 5-2. `database system is shutting down`
- **원인**: 종료 시그널 받음.
- **해결**: 종료 완료 후 재시작.

### 5-3. `invalid page in block ...` / `checksum mismatch`
- **원인**: **데이터 손상(Corruption)**. 디스크 배드섹터 또는 하드웨어 오류.
- **해결**: 즉시 하드웨어 점검. 백업본 복구(`PITR`) 권장. `ignore_checksum_failure`는 최후의 수단.

### 5-4. `transaction ID wraparound` warning
- **원인**: Vacuum이 오랫동안 안 돌아서 Transaction ID 고갈 위기.
- **해결**: 즉시 `VACUUM FREEZE` 수행. (방치하면 DB 셧다운됨).

### 5-5. `could not open file "..." Permission denied`
- **원인**: 데이터 디렉토리 파일 권한이 `postgres` 유저 소유가 아님.
- **해결**: `chown -R postgres:postgres <datadir>`.

### 5-6. `postmaster is the old server`
- **원인**: 데이터 디렉토리 버전과 실행 바이너리 버전 불일치.
- **해결**: 올바른 버전의 PG 바이너리로 실행.

### 5-7. `lock file "postmaster.pid" already exists`
- **원인**: 비정상 종료 후 PID 파일이 남았거나, 이미 실행 중.
- **해결**: 프로세스 확인(`ps aux | grep postgres`). 진짜 안 떠있으면 파일 삭제 후 시작.

### 5-8. `system identifier mismatch`
- **원인**: 다른 클러스터의 WAL 파일이나 백업본을 섞어 씀.
- **해결**: 파일 섞어 쓰기 금지. 백업 다시 복구.

### 5-9. `too many open files`
- **원인**: OS의 `ulimit` (Open Files) 초과.
- **해결**: `/etc/security/limits.conf`에서 `nofile` 증가.

### 5-10. `database system was interrupted; last known up at ...`
- **원인**: `kill -9` 또는 전원 차단으로 인한 비정상 종료.
- **해결**: 자동 복구(Crash Recovery) 진행됨. 기다리면 됨.

---

## 🔍 Good vs Bad Troubleshooting Habits

### ❌ Bad Practice
- **로그 무시**: 에러 나면 로그도 안 보고 바로 재시작한다.
- **강제 종료**: 멈춘 것 같다고 `kill -9`를 날린다. (데이터 손상 지름길).
- **설정 남발**: 인터넷에 있는 튜닝값(`shared_buffers`, `work_mem`)을 무작정 적용한다.
- **백업 없이 작업**: `DELETE`, `UPDATE`를 트랜잭션(`BEGIN`) 없이 날린다.

### ✅ Good Practice
- **실행 계획 확인**: 쿼리가 느리면 무조건 `EXPLAIN ANALYZE`부터 본다.
- **모니터링**: `pg_stat_activity`, `pg_stat_bgwriter` 등을 주기적으로 본다.
- **Safe Update**: 대량 변경 시 `LIMIT`을 걸거나 배치로 나눠서 수행한다.
- **설정 검증**: `postgresql.conf` 변경 전 테스트 서버에서 부하 테스트를 한다.

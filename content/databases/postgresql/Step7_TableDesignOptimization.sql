-- PostgreSQL Step 7: 테이블 설계 최적화
-- 정규화/비정규화 전략, 데이터 타입 선택, 파티셔닝(Partitioning) 활용

-- 나쁜 예시: 무조건적인 정규화 또는 비정규화, 부적절한 데이터 타입 사용, 대용량 테이블을 단일 테이블로 관리하여 성능 저하 및 관리 어려움.
-- 좋은 예시: 애플리케이션의 워크로드에 맞춰 정규화/비정규화 수준을 조절하고, 데이터 특성에 맞는 최적의 데이터 타입을 선택하며,
-- 대용량 테이블에 파티셔닝을 적용하여 관리 효율성 및 쿼리 성능 향상.

-- 학습 포인트: 테이블 설계는 데이터베이스 성능의 기초입니다. 초기 설계 단계에서부터 성능을 고려해야 합니다.

---

-- 데이터베이스 생성 (예시)
CREATE DATABASE table_design_db;
\c table_design_db;

---

## 1. 정규화 (Normalization) vs 비정규화 (Denormalization)

### 1.1. 정규화
- **목표**: 데이터 중복을 최소화하고, 데이터 무결성을 보장하며, 이상 현상(삽입/갱신/삭제 이상)을 방지.
- **장점**: 데이터 일관성 유지, 저장 공간 절약, 쉬운 데이터 유지보수.
- **단점**: `JOIN` 작업 증가로 인해 복잡한 쿼리가 많아지면 읽기 성능 저하 가능성.

-- 예시: 정규화된 설계 (users, user_addresses 테이블 분리)
CREATE TABLE normalized_users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE normalized_user_addresses (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES normalized_users(id),
    address_line1 VARCHAR(255),
    city VARCHAR(100),
    zip_code VARCHAR(20),
    is_primary BOOLEAN DEFAULT FALSE
);

### 1.2. 비정규화
- **목표**: 중복을 허용하여 `JOIN` 횟수를 줄이고 읽기 성능을 향상.
- **장점**: 읽기 쿼리 성능 향상, 쿼리 단순화.
- **단점**: 데이터 중복으로 인한 일관성 문제 발생 가능성, 쓰기 성능 저하, 저장 공간 증가.

-- 예시: 비정규화된 설계 (user_addresses 테이블에 username과 email 중복 저장)
CREATE TABLE denormalized_users_with_address (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL,
    address_line1 VARCHAR(255),
    city VARCHAR(100),
    zip_code VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

### 1.3. 전략
- 일반적인 OLTP 시스템에서는 정규화된 설계를 기본으로 하고, 성능 병목이 발생하는 특정 쿼리에 한해 비정규화를 고려합니다.
- 비정규화 시에는 데이터 일관성 유지를 위한 트리거, 뷰, 애플리케이션 로직 등의 추가적인 노력이 필요합니다.

## 2. 데이터 타입 선택

- **역할**: 각 컬럼에 저장될 데이터의 특성과 범위를 고려하여 가장 적절한 데이터 타입을 선택합니다.
- **장점**: 저장 공간 절약, 디스크 I/O 감소, 쿼리 처리 속도 향상.
- **나쁜 예시**: 모든 문자열을 `TEXT` 또는 `VARCHAR(255)`로 선언, 모든 정수를 `BIGINT`로 선언.

-- 예시: 데이터 타입 선택
CREATE TABLE data_type_example (
    id SERIAL PRIMARY KEY,
    -- 문자열: 최대 길이가 고정되어 있고 짧으면 CHAR, 가변 길이면 VARCHAR
    fixed_code CHAR(5) NOT NULL, -- 'ABCDE'
    short_text VARCHAR(50),      -- 'Hello World'
    long_text TEXT,               -- 긴 설명 (길이 제한 없음)

    -- 숫자: 범위에 따라 SMALLINT, INTEGER, BIGINT 선택. 소수점은 NUMERIC/DECIMAL 사용.
    small_id SMALLINT,            -- -32768 ~ 32767
    user_count INTEGER,           -- 일반적인 정수
    total_amount NUMERIC(15, 2),  -- 총 15자리, 소수점 이하 2자리
    price DECIMAL(10, 2),         -- NUMERIC과 유사, 돈 계산에 적합

    -- 날짜/시간: 타임존 정보 필요 여부에 따라 선택
    event_timestamp TIMESTAMP WITH TIME ZONE, -- 타임존 포함
    log_time TIMESTAMP WITHOUT TIME ZONE,   -- 타임존 없음
    event_date DATE,                      -- 날짜만
    event_hour TIME                       -- 시간만

    -- 불리언
    is_active BOOLEAN DEFAULT TRUE,

    -- JSON 데이터
    metadata JSONB, -- JSON 데이터 저장, 인덱싱 및 빠른 검색에 유리
    tags TEXT[]    -- 배열 데이터
);

---

## 3. 파티셔닝 (Partitioning)

- **역할**: 매우 큰 테이블을 논리적으로 작은 여러 개의 테이블(파티션)로 분할합니다.
- **장점**:
    - **쿼리 성능 향상**: `WHERE` 절 조건에 따라 관련된 파티션만 스캔하여 쿼리 속도 향상.
    - **유지보수 용이**: 특정 파티션에 대한 `VACUUM`, `ANALYZE`, `TRUNCATE` 등 유지보수 작업이 전체 테이블에 영향을 주지 않음.
    - **저장 관리**: 오래된 파티션을 쉽게 보관하거나 삭제 가능.
- **종류**:
    - **Range Partitioning**: 특정 컬럼(예: 날짜, ID 범위)의 값 범위를 기준으로 분할.
    - **List Partitioning**: 특정 컬럼의 불연속적인 값(예: 지역 코드)을 기준으로 분할.
    - **Hash Partitioning**: 해시 함수를 사용하여 데이터를 균등하게 분할.

-- 예시: Range Partitioning (날짜 기준)
CREATE TABLE sensor_data (
    id SERIAL NOT NULL,
    device_id INTEGER NOT NULL,
    reading_time TIMESTAMP NOT NULL,
    temperature DECIMAL(5, 2),
    humidity DECIMAL(5, 2)
) PARTITION BY RANGE (reading_time); -- reading_time 컬럼을 기준으로 Range 파티셔닝

-- 파티션 생성
CREATE TABLE sensor_data_2023_q1 PARTITION OF sensor_data
FOR VALUES FROM ('2023-01-01 00:00:00') TO ('2023-04-01 00:00:00');

CREATE TABLE sensor_data_2023_q2 PARTITION OF sensor_data
FOR VALUES FROM ('2023-04-01 00:00:00') TO ('2023-07-01 00:00:00');

CREATE TABLE sensor_data_default PARTITION OF sensor_data
DEFAULT; -- 범위에 해당하지 않는 데이터 저장

-- 데이터 삽입
INSERT INTO sensor_data (device_id, reading_time, temperature, humidity) VALUES
(1, '2023-02-15 10:00:00', 25.5, 60.2),
(2, '2023-05-20 15:30:00', 28.1, 70.5),
(3, '2023-09-01 08:00:00', 20.0, 55.0); -- default 파티션으로 들어감

-- 파티셔닝의 효과:
-- EXPLAIN ANALYZE SELECT * FROM sensor_data WHERE reading_time >= '2023-02-01' AND reading_time < '2023-03-01';
-- 위 쿼리 실행 시, 옵티마이저는 `sensor_data_2023_q1` 파티션만 스캔합니다.

---

## 4. `TOAST` 테이블 (The Oversized-Attribute Storage Technique)

- **역할**: PostgreSQL은 큰 컬럼 값 (예: `TEXT`, `BYTEA`, `JSONB` 등)을 메인 테이블 저장 공간과 분리하여 `TOAST` 테이블에 저장합니다.
- **장점**: 메인 테이블의 행 크기를 작게 유지하여 인덱스 스캔 및 일반 쿼리 성능 향상.
- **고려사항**: `TOAST` 데이터에 자주 접근하는 쿼리는 추가적인 디스크 I/O를 유발할 수 있습니다.

---

```sql
-- 이 파일은 테이블 설계 최적화의 개념을 설명하고 SQL 예시를 제공합니다.
-- PostgreSQL 서버에 접속하여 쿼리를 실행하고 `EXPLAIN ANALYZE`로 결과를 직접 분석해보세요.

-- 실습 후 데이터 및 테이블 정리 (선택 사항)
-- DROP TABLE denormalized_users_with_address;
-- DROP TABLE normalized_user_addresses;
-- DROP TABLE normalized_users;
-- DROP TABLE sensor_data; -- 파티션 테이블도 함께 삭제됩니다.
-- DROP TABLE data_type_example;
-- DROP DATABASE table_design_db;
```

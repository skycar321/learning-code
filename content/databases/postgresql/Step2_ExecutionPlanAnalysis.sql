-- PostgreSQL Step 2: 실행 계획 분석의 기초 (`EXPLAIN` & `EXPLAIN ANALYZE`)
-- `EXPLAIN` 및 `EXPLAIN ANALYZE` 명령어 사용법 및 결과 해석 방법 학습

-- 나쁜 예시: 쿼리가 느릴 때 무작정 인덱스를 추가하거나 쿼리를 수정하여 개선 효과를 보지 못하거나 오히려 성능을 저하시킵니다.
-- 좋은 예시: `EXPLAIN`과 `EXPLAIN ANALYZE`를 사용하여 쿼리가 데이터에 어떻게 접근하고 처리하는지 정확히 이해하고, 병목 지점을 식별하여 효율적인 튜닝 전략을 수립.

-- 학습 포인트: 쿼리 실행 계획은 PostgreSQL 옵티마이저가 쿼리를 실행하기 위해 선택한 단계를 보여주는 핵심 정보입니다. 이를 해석하는 능력은 성능 튜닝의 필수 요소입니다.

---

-- 데이터베이스 및 테이블 생성 (예시)
CREATE DATABASE performance_db;
\c performance_db;

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    product_name VARCHAR(255),
    amount DECIMAL(10, 2),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 더미 데이터 삽입
INSERT INTO users (username, email)
SELECT
    'user_' || generate_series,
    'user_' || generate_series || '@example.com'
FROM generate_series(1, 10000); -- 10,000명 사용자

INSERT INTO orders (user_id, product_name, amount)
SELECT
    (random() * 9999 + 1)::INTEGER,
    'product_' || (random() * 100 + 1)::INTEGER,
    (random() * 1000 + 10)::DECIMAL(10, 2)
FROM generate_series(1, 500000); -- 500,000개 주문

-- 데이터 통계 정보 갱신 (옵티마이저가 최적의 계획을 세우는 데 필요)
ANALYZE users;
ANALYZE orders;

---

## 1. `EXPLAIN` 명령어

- **역할**: 쿼리가 어떻게 실행될 것인지에 대한 계획을 보여줍니다. 실제로 쿼리를 실행하지 않고, 옵티마이저가 예측한 비용(cost)을 기반으로 계획을 수립합니다.
- **결과 해석**:
    - **`cost`**: `(시작 비용..총 비용)` 형태. 시작 비용은 첫 행을 가져오는 데 드는 예측 비용, 총 비용은 모든 행을 가져오는 데 드는 예측 비용. 단위는 임의의 디스크 페이지 가져오기 비용을 1로 기준.
    - **`rows`**: 쿼리가 반환할 것으로 예측되는 행 수.
    - **`width`**: 각 행의 예상 바이트 크기.
    - **`Plan Node`**: 쿼리 플래너가 선택한 각 작업 (예: `Seq Scan`, `Index Scan`, `Hash Join` 등).
- **주의**: `EXPLAIN`은 예측 기반이므로 실제 실행과 차이가 있을 수 있습니다.

-- 예시 1: 간단한 전체 테이블 스캔
EXPLAIN SELECT * FROM users WHERE username = 'user_5000';

-- 예시 2: 조인 (인덱스 없음)
EXPLAIN SELECT u.username, o.product_name
FROM users u
JOIN orders o ON u.id = o.user_id
WHERE u.id = 100;

---

## 2. `EXPLAIN ANALYZE` 명령어

- **역할**: 쿼리를 실제로 실행하고, 실행된 각 단계의 실제 통계 (시간, 행 수)를 보여줍니다.
- **결과 해석**:
    - **`time`**: `(실제 시작 시간..실제 총 시간)` 형태. (밀리초)
    - **`rows`**: 실제로 반환된 행 수.
    - **`loops`**: 해당 노드가 실행된 횟수.
    - **`actual time`**: 실제 측정된 시간.
- `EXPLAIN`의 예측과 `EXPLAIN ANALYZE`의 실제 값을 비교하여 옵티마이저의 예측이 정확했는지, 또는 통계 정보가 오래되지는 않았는지 등을 파악할 수 있습니다.
- **주의**: `EXPLAIN ANALYZE`는 쿼리를 실제로 실행하므로, 데이터 변경 쿼리(`INSERT`, `UPDATE`, `DELETE`)에는 주의해야 합니다. 트랜잭션 내에서 실행하여 `ROLLBACK`하는 것을 고려할 수 있습니다.

-- 예시 1: 간단한 전체 테이블 스캔 (실제 실행)
EXPLAIN ANALYZE SELECT * FROM users WHERE username = 'user_5000';

-- 예시 2: 조인 (실제 실행, 인덱스 없음)
EXPLAIN ANALYZE SELECT u.username, o.product_name
FROM users u
JOIN orders o ON u.id = o.user_id
WHERE u.id = 100;

---

## 3. 실행 계획 노드 종류 및 의미

주요 노드 타입과 일반적인 의미:

- **`Seq Scan` (Sequential Scan)**: 테이블의 모든 행을 순차적으로 읽습니다. 대용량 테이블에서 인덱스 없이 `WHERE` 절 조건이 적거나, 대부분의 행을 스캔해야 할 때 발생합니다. 일반적으로 느립니다.
- **`Index Scan`**: 인덱스를 사용하여 테이블의 특정 행을 효율적으로 찾습니다. 매우 빠르며, `WHERE` 절에 인덱스 컬럼이 사용될 때 나타납니다.
- **`Index Only Scan`**: 테이블 데이터 파일에 접근하지 않고 인덱스만으로 필요한 모든 정보를 얻을 수 있을 때 발생합니다. `COVERING INDEX`와 관련됩니다.
- **`Bitmap Heap Scan`**: 비트맵 인덱스 스캔과 힙 스캔의 조합입니다. 인덱스를 통해 조건을 만족하는 행들의 위치(TID)를 비트맵으로 얻은 후, 해당 TID를 사용하여 테이블 힙에서 실제 행 데이터를 가져옵니다. 여러 인덱스를 조합할 때 유용할 수 있습니다.
- **`Hash Join`**: 두 테이블을 조인할 때, 더 작은 테이블을 메모리에 해시 테이블로 만들어 다른 테이블을 스캔하며 조인합니다. 일반적으로 큰 테이블 간의 조인에 효율적입니다.
- **`Merge Join`**: 조인하려는 두 테이블이 조인 키를 기준으로 정렬되어 있을 때 효율적입니다. 정렬되어 있지 않다면 먼저 정렬하는 과정이 추가됩니다.
- **`Nested Loop Join`**: 중첩 루프 조인. 한 테이블의 각 행에 대해 다른 테이블을 스캔하여 조인합니다. 보통 한 테이블이 매우 작거나, 인덱스 스캔을 효율적으로 사용할 수 있을 때 유리합니다.
- **`Sort`**: 데이터를 정렬합니다. `ORDER BY`나 `GROUP BY`, `DISTINCT`, `Merge Join` 등에서 발생할 수 있습니다. 비용이 많이 들 수 있습니다.
- **`Aggregate`**: `GROUP BY` 또는 집계 함수 (`SUM`, `COUNT` 등)를 처리합니다.
- **`Limit`**: 쿼리 결과의 행 수를 제한합니다.

---

## 4. `EXPLAIN (ANALYZE, BUFFERS, FORMAT YAML)` (고급 옵션)

- `ANALYZE`: 실제 실행 정보 포함.
- `BUFFERS`: 버퍼 사용량 통계 포함 (Shared Hit/Read, Local Hit/Read, Temp Read/Written 등). 캐싱 효율을 파악하는 데 중요합니다.
- `FORMAT YAML` 또는 `FORMAT JSON`: 결과를 YAML 또는 JSON 형식으로 출력하여 파싱하기 용이하게 합니다.
- `VERBOSE`: 더 많은 상세 정보 포함.

-- 예시: 버퍼 사용량까지 상세히 분석
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT u.username, o.product_name
FROM users u
JOIN orders o ON u.id = o.user_id
WHERE u.id = 100;

---

## 5. 실행 계획 해석의 실제 적용

1. **가장 비싼 노드 찾기**: `cost`가 가장 높거나 `actual time`이 가장 긴 노드를 먼저 확인합니다.
2. **`Seq Scan`이 대량으로 발생하는지 확인**: 대용량 테이블에서 `Seq Scan`이 불필요하게 발생하면 인덱스 추가를 고려합니다.
3. **`Sort` 노드 확인**: `Sort` 노드의 비용이 높으면 인덱스로 정렬을 대체할 수 있는지 확인합니다.
4. **조인 방식 확인**: 사용된 조인 방식이 테이블 크기 및 인덱스 유무에 적절한지 확인합니다.
5. **`rows` vs `actual rows`**: `EXPLAIN`의 `rows` 예측치와 `EXPLAIN ANALYZE`의 `actual rows`를 비교하여 옵티마이저의 예측 정확도를 평가합니다. 차이가 크다면 `ANALYZE` 명령어를 통해 통계 정보를 갱신하거나, `WHERE` 절 조건에 대한 예측이 잘못되었는지 확인합니다.
6. **`blks_read` vs `blks_hit`**: `BUFFERS` 옵션을 사용하여 `blks_read`가 높으면 디스크 I/O가 많이 발생하고 있음을 의미하므로, 캐싱 효율을 높일 방법을 고려합니다.

---

```sql
-- 이 파일은 실행 계획 분석의 개념을 설명하고 예시 쿼리를 제공합니다.
-- PostgreSQL 서버에 접속하여 쿼리를 실행하고 결과를 직접 분석해보세요.

-- 실습 후 데이터 정리 (선택 사항)
-- DROP TABLE orders;
-- DROP TABLE users;
-- DROP DATABASE performance_db;
```

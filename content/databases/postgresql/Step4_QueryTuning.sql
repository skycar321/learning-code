-- PostgreSQL Step 4: 쿼리 튜닝 (Query Tuning)
-- 비효율적인 쿼리 패턴 식별 및 `JOIN`, 서브쿼리, `WHERE` 절 최적화 기법

-- 나쁜 예시: `SELECT *`을 남용하거나, 상관 서브쿼리, `LIKE '%keyword'`와 같이 인덱스를 활용하기 어려운 쿼리를 작성하여 성능 저하.
-- 좋은 예시: 필요한 컬럼만 선택하고, `JOIN` 방식을 고려하며, `WHERE` 절 조건을 최적화하고, `UNION ALL` 대신 `UNION`을 적절히 사용하는 등 효율적인 쿼리 패턴을 적용.

-- 학습 포인트: 쿼리 튜닝은 실행 계획 분석을 통해 병목을 식별하고, 해당 쿼리를 효율적인 형태로 재작성하는 과정입니다.

---

-- 데이터베이스 및 테이블 생성 (Step 2에서 생성된 users, orders 테이블을 재사용하거나 새로 생성)
CREATE DATABASE query_tuning_db;
\c query_tuning_db;

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(100),
    age INTEGER,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    product_name VARCHAR(255),
    amount DECIMAL(10, 2),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    category VARCHAR(100),
    price DECIMAL(10, 2)
);

-- 더미 데이터 삽입
INSERT INTO users (username, email, age, status)
SELECT
    'user_' || generate_series,
    'user_' || generate_series || '@example.com',
    (random() * 50 + 20)::INTEGER, -- 20세~70세
    CASE WHEN random() < 0.1 THEN 'inactive' ELSE 'active' END
FROM generate_series(1, 10000); -- 10,000명 사용자

INSERT INTO products (name, category, price)
SELECT
    'Product_' || generate_series,
    'Category_' || (generate_series % 5), -- 5가지 카테고리
    (random() * 100 + 10)::DECIMAL(10, 2)
FROM generate_series(1, 1000); -- 1,000개 제품

INSERT INTO orders (user_id, product_name, amount)
SELECT
    (random() * 9999 + 1)::INTEGER,
    p.name,
    p.price
FROM generate_series(1, 500000) AS gs, products p
WHERE p.id = (random() * 999 + 1)::INTEGER; -- 500,000개 주문

-- 인덱스 추가 (쿼리 튜닝에 사용될 예정)
CREATE INDEX idx_users_username ON users (username);
CREATE INDEX idx_users_status_age ON users (status, age);
CREATE INDEX idx_orders_user_id ON orders (user_id);
CREATE INDEX idx_products_name ON products (name);
CREATE INDEX idx_products_category ON products (category);

ANALYZE users;
ANALYZE orders;
ANALYZE products;

---

## 1. `SELECT` 절 최적화: `SELECT *` 피하기

- **나쁜 예시**: `SELECT *`은 필요 없는 컬럼까지 가져와 네트워크 트래픽, 메모리 사용량, 디스크 I/O를 증가시킵니다. `Index Only Scan`을 방해할 수도 있습니다.
- **좋은 예시**: 필요한 컬럼만 명시적으로 선택합니다.

-- 나쁜 예시
EXPLAIN ANALYZE SELECT * FROM users WHERE id = 100;

-- 좋은 예시
EXPLAIN ANALYZE SELECT username, email FROM users WHERE id = 100;

---

## 2. `WHERE` 절 최적화

- **인덱스 활용**: `WHERE` 절에 인덱스가 있는 컬럼을 사용하고, 인덱스를 활용할 수 있는 형태로 조건을 작성합니다.
- **`LIKE '%keyword'` 피하기**: 앞쪽에 `'%'`가 오는 `LIKE` 패턴은 인덱스를 거의 사용하지 못하고 `Seq Scan`을 유발합니다. 이 패턴을 최적화하려면 `to_tsvector`와 GIN 인덱스를 활용한 PostgreSQL의 내장 전문 검색 기능을 사용하거나, 애플리케이션 레벨에서 검색 로직을 변경하는 것을 고려해야 합니다.

-- 나쁜 예시 (LIKE '%keyword' 사용)
EXPLAIN ANALYZE SELECT * FROM products WHERE name LIKE '%Product_123%'; -- Seq Scan 예상

-- 좋은 예시 (LIKE 'keyword%' 또는 내장 전문 검색)
-- `to_tsvector` 함수는 PostgreSQL 내장 기능이며 GIN 인덱스와 함께 전문 검색에 활용될 수 있습니다.
-- (Step 3의 GIN 인덱스 예시를 참고하여 `products` 테이블의 `name` 컬럼에 전문 검색 GIN 인덱스를 생성할 수 있습니다.)
-- CREATE INDEX idx_products_name_gin ON products USING GIN (to_tsvector('english', name));
-- EXPLAIN ANALYZE SELECT * FROM products WHERE to_tsvector('english', name) @@ plainto_tsquery('english', 'Product_123'); -- GIN Index Scan 예상
-- 또는 인덱스를 활용할 수 있는 `LIKE 'keyword%'` 패턴 사용
EXPLAIN ANALYZE SELECT * FROM products WHERE name LIKE 'Product_123%'; -- 이 경우 인덱스가 'name'에 있다면 Index Scan 가능 (오른쪽 %는 인덱스 사용 가능)

-- 나쁜 예시 (인덱스 컬럼에 함수 사용)
EXPLAIN ANALYZE SELECT * FROM users WHERE age + 1 = 30; -- age 컬럼에 인덱스가 있어도 사용 불가

-- 좋은 예시 (함수를 다른 쪽에 적용 또는 인덱스에 맞춰 조건 변경)
EXPLAIN ANALYZE SELECT * FROM users WHERE age = 29; -- 인덱스 활용 가능

---

## 3. `JOIN` 최적화

- **적절한 조인 조건**: `ON` 절에 인덱스가 있는 컬럼을 사용합니다.
- **조인 순서**: 옵티마이저가 최적의 조인 순서를 결정하지만, 때로는 힌트나 쿼리 재작성을 통해 수동으로 조인 순서를 조정할 수 있습니다. 작은 테이블을 먼저 조인하는 것이 유리할 때가 많습니다.
- **`INNER JOIN` vs `LEFT JOIN`**: 필요한 조인 타입만 사용합니다.
- **서브쿼리 vs 조인**: 상황에 따라 서브쿼리를 조인으로 바꾸거나, 조인을 서브쿼리로 바꾸는 것이 성능 개선에 도움이 될 수 있습니다.

-- 나쁜 예시 (비효율적인 조인)
-- 500,000개의 주문을 모든 사용자와 조인 후 필터링
EXPLAIN ANALYZE
SELECT u.username, COUNT(o.id)
FROM users u
JOIN orders o ON u.id = o.user_id
WHERE u.status = 'inactive'
GROUP BY u.username;

-- 좋은 예시 (먼저 필터링 후 조인)
-- user_id에 인덱스, status에 인덱스가 있다고 가정
EXPLAIN ANALYZE
SELECT u.username, COUNT(o.id)
FROM users u
JOIN orders o ON u.id = o.user_id
WHERE u.status = 'inactive'
GROUP BY u.username;
-- 위 쿼리 자체는 문제가 없어 보이지만, users 테이블의 인덱스 활용 여부에 따라 달라집니다.
-- idx_users_status_age 인덱스를 사용하여 status='inactive'인 사용자를 먼저 찾고 조인하는 것이 효율적입니다.

-- `EXISTS` 대신 `IN` 또는 `JOIN` 사용
-- 나쁜 예시 (상관 서브쿼리): 외부 쿼리의 행마다 서브쿼리가 다시 실행될 가능성 높음
EXPLAIN ANALYZE
SELECT u.username
FROM users u
WHERE EXISTS (
    SELECT 1 FROM orders o WHERE o.user_id = u.id AND o.amount > 1000
);

-- 좋은 예시 (JOIN으로 변경)
EXPLAIN ANALYZE
SELECT DISTINCT u.username
FROM users u
JOIN orders o ON u.id = o.user_id
WHERE o.amount > 1000;

---

## 4. `GROUP BY` 및 `ORDER BY` 최적화

- **인덱스 활용**: `GROUP BY` 및 `ORDER BY` 절에 사용되는 컬럼에 인덱스를 생성하면 `Sort` 노드를 줄이거나 제거할 수 있습니다. 복합 인덱스의 순서가 중요합니다.

-- 인덱스 추가
CREATE INDEX idx_orders_order_date ON orders (order_date DESC);

-- `ORDER BY` 최적화
EXPLAIN ANALYZE SELECT * FROM orders ORDER BY order_date DESC LIMIT 10;
-- idx_orders_order_date 인덱스를 활용하여 Sort 없이 Index Scan (Backward) 가능

-- `GROUP BY` 최적화
EXPLAIN ANALYZE
SELECT user_id, COUNT(id)
FROM orders
GROUP BY user_id
ORDER BY COUNT(id) DESC
LIMIT 10;
-- user_id에 인덱스가 있으면 HashAggregate 또는 GroupAggregate가 효율적일 수 있습니다.
-- 정렬은 여전히 필요할 수 있습니다.

---

## 5. `DISTINCT` 최적화

- **`DISTINCT` 대신 `GROUP BY` 또는 `EXISTS`**: 경우에 따라 `GROUP BY`나 `EXISTS`를 사용하는 것이 `DISTINCT`보다 효율적일 수 있습니다.

-- 나쁜 예시
EXPLAIN ANALYZE SELECT DISTINCT user_id FROM orders WHERE amount > 500;

-- 좋은 예시 (INDEX SCAN만으로 해결)
-- CREATE UNIQUE INDEX idx_orders_user_id_amount ON orders (user_id, amount) WHERE amount > 500;
-- EXPLAIN ANALYZE SELECT user_id FROM orders WHERE amount > 500 GROUP BY user_id;

---

```sql
-- 이 파일은 쿼리 튜닝의 개념을 설명하고 SQL 예시를 제공합니다.
-- PostgreSQL 서버에 접속하여 쿼리를 실행하고 `EXPLAIN ANALYZE`로 결과를 직접 분석해보세요.

-- 실습 후 데이터 및 인덱스 정리 (선택 사항)
-- DROP INDEX idx_users_username;
-- DROP INDEX idx_users_status_age;
-- DROP INDEX idx_orders_user_id;
-- DROP INDEX idx_products_name;
-- DROP INDEX idx_products_category;
-- DROP INDEX idx_orders_order_date;

-- DROP TABLE orders;
-- DROP TABLE users;
-- DROP TABLE products;
-- DROP DATABASE query_tuning_db;
```

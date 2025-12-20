-- PostgreSQL Step 3: 인덱스 (Indexes) 최적화
-- 인덱스 종류 (B-tree, Hash, GIN, BRIN 등) 이해 및 올바른 인덱스 설계와 활용

-- 나쁜 예시: 무작정 많은 인덱스를 생성하여 데이터 쓰기 성능을 저하시키고 저장 공간을 낭비합니다. 또는 인덱스를 생성했지만 쿼리에서 제대로 활용하지 못합니다.
-- 좋은 예시: 쿼리 패턴과 데이터 특성을 분석하여 적절한 종류의 인덱스를 필요한 컬럼에만 생성하고, 인덱스를 최대한 활용하도록 쿼리를 최적화.

-- 학습 포인트: 인덱스는 데이터베이스 성능 튜닝에서 가장 강력한 도구 중 하나입니다. 하지만 잘못 사용하면 오히려 독이 될 수 있으므로, 신중한 설계와 분석이 필요합니다.

---

-- 데이터베이스 및 테이블 생성 (예시)
CREATE DATABASE index_optimization_db;
\c index_optimization_db;

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INTEGER NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 더미 데이터 삽입 (100,000개)
INSERT INTO products (name, category, price, stock_quantity, description)
SELECT
    'Product_' || generate_series,
    'Category_' || (generate_series % 10), -- 10가지 카테고리
    (random() * 1000 + 1)::DECIMAL(10, 2),
    (random() * 100 + 1)::INTEGER,
    'Description for Product_' || generate_series
FROM generate_series(1, 100000);

ANALYZE products;

---

## 1. 인덱스의 기본 개념

- **역할**: 테이블의 특정 컬럼에 대한 빠른 데이터 검색을 돕는 데이터 구조입니다. 책의 색인과 유사합니다.
- **장점**: `SELECT` 쿼리 (특히 `WHERE`, `ORDER BY`, `GROUP BY` 절)의 성능을 크게 향상시킬 수 있습니다.
- **단점**: `INSERT`, `UPDATE`, `DELETE`와 같은 쓰기 작업 시 인덱스도 함께 갱신해야 하므로 성능 저하가 발생할 수 있습니다. 추가적인 저장 공간을 필요로 합니다.

## 2. `EXPLAIN`을 통한 인덱스 사용 확인

인덱스가 쿼리에 사용되고 있는지 확인하는 가장 좋은 방법은 `EXPLAIN` (또는 `EXPLAIN ANALYZE`)을 사용하는 것입니다. `Seq Scan` 대신 `Index Scan`이나 `Bitmap Heap Scan`이 보이면 인덱스가 활용되고 있는 것입니다.

-- 현재 인덱스가 없는 상태에서 쿼리 실행 계획
EXPLAIN ANALYZE SELECT * FROM products WHERE category = 'Category_5';
-- 예상: Seq Scan on products

EXPLAIN ANALYZE SELECT * FROM products WHERE name LIKE 'Product_123%';
-- 예상: Seq Scan on products

EXPLAIN ANALYZE SELECT * FROM products ORDER BY created_at DESC LIMIT 10;
-- 예상: Sort 노드와 Seq Scan

---

## 3. PostgreSQL의 인덱스 종류

### 3.1. B-tree 인덱스 (기본값)
- **가장 일반적인 인덱스**: 대부분의 데이터 타입에 대해 `WHERE` 절 조건 (`=`, `<`, `>`, `<=`, `>=`, `BETWEEN`, `IN` 등), `ORDER BY`, `GROUP BY`에 효율적입니다.
- **`UNIQUE` 제약 조건**: B-tree 인덱스를 자동으로 생성합니다.
- **`PRIMARY KEY`**: `UNIQUE` 및 `NOT NULL` 제약 조건이 있는 B-tree 인덱스를 자동으로 생성합니다.

-- category 컬럼에 B-tree 인덱스 생성
CREATE INDEX idx_products_category ON products (category);

-- category와 price 컬럼에 복합 B-tree 인덱스 생성
CREATE INDEX idx_products_category_price ON products (category, price DESC);

-- 인덱스 생성 후 다시 쿼리 실행 계획 확인
EXPLAIN ANALYZE SELECT * FROM products WHERE category = 'Category_5';
-- 예상: Index Scan 또는 Bitmap Heap Scan on products

EXPLAIN ANALYZE SELECT * FROM products ORDER BY created_at DESC LIMIT 10;
-- 이 쿼리에는 아직 인덱스가 없으므로 Seq Scan + Sort가 나올 것입니다.
-- created_at에 인덱스 추가 (B-tree)
CREATE INDEX idx_products_created_at ON products (created_at DESC);
EXPLAIN ANALYZE SELECT * FROM products ORDER BY created_at DESC LIMIT 10;
-- 예상: Index Only Scan 또는 Index Scan on idx_products_created_at

### 3.2. Hash 인덱스 (드물게 사용)
- **역할**: 등호(`=`) 연산에만 사용됩니다.
- **제한적**: 트랜잭션 로깅이 되지 않아 충돌 발생 시 복구되지 않을 수 있으며, B-tree보다 활용도가 낮습니다.

### 3.3. GIN (Generalized Inverted Index) 인덱스
- **역할**: 다중 값 컬럼 (JSONB, 배열) 또는 전문 검색(Full-Text Search)에 사용됩니다.
- **예시**: `jsonb` 타입의 특정 키-값 쌍 검색, 배열에 특정 요소가 포함되어 있는지 검색.

-- description 컬럼에 GIN 인덱스 생성 (전문 검색을 위해)
-- PostgreSQL은 `to_tsvector` 함수를 내장하고 있어 전문 검색을 위한 GIN 인덱스를 확장 기능 없이 생성할 수 있습니다.
CREATE INDEX idx_products_description_gin ON products USING GIN (to_tsvector('english', description));

-- JSONB 컬럼 예시 (테이블에 jsonb 컬럼 추가)
ALTER TABLE products ADD COLUMN IF NOT EXISTS tags JSONB; -- IF NOT EXISTS 추가하여 재실행 시 오류 방지
UPDATE products SET tags = ('{"colors": ["red", "blue"], "sizes": ["M", "L"]}') WHERE id % 2 = 0;
CREATE INDEX idx_products_tags_gin ON products USING GIN (tags);
EXPLAIN ANALYZE SELECT * FROM products WHERE tags @> '{"colors": ["red"]}';

### 3.4. BRIN (Block Range Index) 인덱스
- **역할**: 대용량 테이블에서 물리적으로 정렬된 데이터 (예: 로그 테이블의 `created_at` 컬럼)에 효과적입니다.
- **장점**: B-tree보다 훨씬 작고 빠릅니다.
- **단점**: 데이터가 물리적으로 거의 정렬되어 있어야 합니다.

-- created_at 컬럼에 BRIN 인덱스 생성 (데이터가 시간 순서대로 쌓이는 경우)
CREATE INDEX idx_products_created_at_brin ON products USING BRIN (created_at);

---

## 4. 인덱스 설계 가이드라인

- **`WHERE` 절, `ORDER BY`, `GROUP BY`에 자주 사용되는 컬럼**: 인덱스 후보 1순위.
- **카디널리티 (Cardinality)**: 컬럼의 고유한 값의 개수가 많을수록 인덱스의 효과가 좋습니다. (예: `gender` 같은 카디널리티가 낮은 컬럼은 인덱스 효과가 미미할 수 있음)
- **복합 인덱스 (Composite Index)**: 여러 컬럼을 함께 인덱싱합니다. `idx_products_category_price`와 같이 순서가 중요합니다. `WHERE category = 'X' AND price > 100` 쿼리에는 효과적이지만, `WHERE price > 100` 쿼리에는 `category` 인덱스만 사용되거나 전혀 사용되지 않을 수 있습니다.
- **`COVERING INDEX` (인덱스 온리 스캔)**: 쿼리가 필요로 하는 모든 컬럼이 인덱스 내에 포함되어 있어, 테이블 힙에 접근할 필요 없이 인덱스만으로 모든 데이터를 가져올 수 있을 때 사용됩니다. 매우 빠릅니다.
- **인덱스 추가는 신중하게**: 너무 많은 인덱스는 쓰기 성능을 저하시키고, 데이터베이스 크기를 증가시키며, 옵티마이저가 잘못된 인덱스를 선택할 가능성을 높입니다. `pg_stat_user_indexes` 뷰를 통해 사용되지 않는 인덱스를 주기적으로 확인하고 제거해야 합니다.

-- 사용되지 않는 인덱스 조회 (활성화된 `pg_stat_user_indexes` 뷰 필요)
-- SELECT relid::regclass, indexrelid::regclass, idx_scan, idx_tup_read, idx_tup_fetch
-- FROM pg_stat_user_indexes
-- WHERE idx_scan = 0; -- 스캔되지 않은 인덱스

---

```sql
-- 이 파일은 인덱스 최적화의 개념을 설명하고 SQL 예시를 제공합니다.
-- PostgreSQL 서버에 접속하여 쿼리를 실행하고 결과를 직접 분석해보세요.

-- 실습 후 인덱스 및 데이터 정리 (선택 사항)
-- DROP INDEX idx_products_category;
-- DROP INDEX idx_products_category_price;
-- DROP INDEX idx_products_created_at;
-- DROP INDEX idx_products_created_at_brin;
-- DROP TABLE products;
-- DROP DATABASE index_optimization_db;
```

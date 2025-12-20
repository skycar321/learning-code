# PostgreSQL Step 10: 고급 SQL 튜닝 및 확장 기능 활용
# 쿼리 플래너 동작 제어 (SET), PL/pgSQL 최적화, 병렬 쿼리 활용 등 확장 기능 중심의 고급 기법

# 나쁜 예시: 복잡한 성능 문제를 해결하기 위해 기본적인 인덱스 추가나 설정 변경만으로 해결하려 하거나, PostgreSQL이 제공하는 강력한 확장 기능을 활용하지 못합니다.
# 좋은 예시: `SET` 명령어를 통해 쿼리 플래너의 동작을 전략적으로 제어하고, PL/pgSQL 함수를 최적화하며, PostgreSQL의 병렬 쿼리 기능을 활용하여 대용량 데이터 환경에서의 성능을 극대화합니다.

# 학습 포인트: 인프라 제약으로 인해 외부 확장 기능이나 도구를 사용하지 못하는 상황에서, PostgreSQL의 내장 기능을 깊이 이해하고 활용하는 것은 데이터베이스 성능 전문가가 되기 위한 필수적인 지식입니다.

---

## 1. 쿼리 플래너 동작 제어 (`SET` 명령어 활용)

- **개요**: PostgreSQL 옵티마이저는 기본적으로 최적의 실행 계획을 생성하려 하지만, 때로는 데이터 분포나 특정 상황에서 잘못된 계획을 선택할 수 있습니다. 이때 `SET` 명령어를 사용하여 세션 레벨에서 옵티마이저의 동작을 "조언"하거나 특정 계획 모드의 비용을 조정할 수 있습니다.
- **주의**: `SET` 명령어를 통한 옵티마이저 파라미터 조정은 쿼리의 자연스러움을 깨뜨리고, 데이터 분포가 변경되면 오히려 성능 저하를 유발할 수 있으므로 신중하게 사용해야 합니다. 쿼리의 병목을 정확히 파악한 후에, 제한된 범위 내에서 테스트용으로 사용하며 테스트하는 것이 좋습니다.

```sql
-- SET 명령어를 통한 옵티마이저 파라미터 조정 (세션 레벨)
SET enable_seqscan = off; -- Seq Scan을 비활성화하여 Index Scan을 강제 (주의: 너무 강제하면 다른 쿼리에 영향)
SET enable_hashjoin = off; -- Hash Join을 비활성화 (다른 조인 방식 사용 유도)

-- 변경된 설정 하에서 실행 계획 확인
EXPLAIN ANALYZE SELECT * FROM a_large_table WHERE indexed_column = 'value';

RESET ALL; -- 변경된 모든 세션 설정 되돌리기 (가장 안전)
-- 또는 RESET enable_seqscan; -- 특정 설정만 되돌리기
```

## 2. PL/pgSQL 함수 최적화
- **PL/pgSQL**: PostgreSQL에서 제공하는 절차적 언어입니다. 복잡한 로직을 데이터베이스 안에서 실행할 때 유용합니다.
- **최적화 기법**:
    - **`SET search_path`**: 함수 시작 시 `search_path`를 명시적으로 설정하여 불필요한 스키마 검사를 줄입니다.
    - **동적 SQL (`EXECUTE`)**: 복잡하거나 동적으로 변하는 쿼리를 생성할 때 `EXECUTE format(...)`을 활용합니다. 이는 SQL 인젝션 공격에 대비함과 동시에 더 유연한 쿼리 생성을 가능하게 합니다.
    - **레코드 타입 대신 구체적인 타입 사용**: 변수 선언 시 `RECORD` 타입보다는 테이블의 `ROWTYPE`이나 명시적인 타입을 사용하면 성능 향상에 도움이 됩니다.
    - **`RETURN QUERY`**: `SELECT`의 결과를 직접 반환할 때 사용. 불필요한 변수 할당 및 루프를 줄일 수 있습니다.
    - **루프 내 쿼리 최소화**: 루프 안에서 반복적으로 쿼리를 실행하는 대신, 하나의 쿼리로 데이터를 가공해 처리하는 것이 효율적입니다.

```sql
-- 나쁜 예시: 비효율적인 루프를 사용하는 PL/pgSQL 함수
CREATE OR REPLACE FUNCTION get_total_sales_bad(p_user_id INTEGER)
RETURNS NUMERIC AS $$
DECLARE
    total_sales NUMERIC := 0;
    r RECORD;
BEGIN
    FOR r IN SELECT amount FROM sales WHERE employee_id = p_user_id LOOP
        total_sales := total_sales + r.amount;
    END LOOP;
    RETURN total_sales;
END;
$$ LANGUAGE plpgsql;

-- 좋은 예시: 효율적인 단일 쿼리를 사용하는 PL/pgSQL 함수
CREATE OR REPLACE FUNCTION get_total_sales_good(p_user_id INTEGER)
RETURNS NUMERIC AS $$
DECLARE
    total_sales NUMERIC;
BEGIN
    SELECT SUM(amount) INTO total_sales FROM sales WHERE employee_id = p_user_id;
    RETURN total_sales;
END;
$$ LANGUAGE plpgsql;
```

## 3. PostgreSQL의 병렬 쿼리 (Parallel Query) 활용

- **개요**: PostgreSQL 9.6부터 도입된 기능으로, 대규모 쿼리 작업(Seq Scan, Hash Join, Aggregate 등)을 여러 CPU 코어에서 병렬로 실행하여 대규모 데이터 처리 성능을 향상시킵니다.
- **설정**:
    - `max_parallel_workers_per_gather`: 하나의 `Gather` 노드에서 사용할 수 있는 최대 병렬 워커 수.
    - `max_parallel_workers`: 전체 시스템에서 사용 가능한 최대 병렬 워커 수 (서버 재시작 필요).
    - `min_parallel_table_scan_size`: 병렬 스캔을 고려하기 위한 최소 테이블 크기.
- **주의**: 병렬 쿼리가 항상 빠르지는 않습니다. 소규모 쿼리나 네트워크/I/O 병목이 있는 쿼리에서는 오버헤드가 발생할 수 있습니다. `EXPLAIN ANALYZE` 결과에 `Parallel` 노드가 나타나는지 확인해야 합니다.

```sql
-- 병렬 쿼리 관련 설정 확인
SHOW max_parallel_workers_per_gather;
SHOW max_parallel_workers;
SHOW min_parallel_table_scan_size;

-- 세션 레벨에서 병렬 쿼리 워커 수 조정 (테스트용)
SET max_parallel_workers_per_gather = 4;
EXPLAIN ANALYZE SELECT count(*) FROM a_large_table WHERE created_date > '2023-01-01';
RESET max_parallel_workers_per_gather;
```

## 4. 캐싱 전략 (Application Level)

데이터베이스 부하 분산에서 애플리케이션 레벨 캐시는 매우 중요합니다. 자주 접근하는 데이터를 캐싱하면 데이터베이스 부하를 줄이고 응답 시간을 단축시키는 효과적인 전략입니다. 이 부분은 데이터베이스 자체 튜닝보다는 애플리케이션 설계 영역에 해당하지만, 전체 시스템 성능 관점에서 고려해야 합니다.

---

```
-- 이 파일은 PostgreSQL 내장 기능을 활용한 고급 튜닝 기법의 개념을 설명합니다.
-- 외부 도구나 확장 기능 없이, SQL 명령어를 통해 가능한 최적화에 집중합니다.
-- `ALTER SYSTEM` 명령어를 통한 전역 설정 변경은 인프라팀과 협의하여 진행해야 합니다.
```
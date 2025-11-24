-- ============================================================
-- Advanced Step 1: PostgreSQL Window Functions 심화
-- ============================================================
-- 이 파일은 PostgreSQL의 Window Functions(윈도우 함수)를 심층적으로 학습합니다.
-- 복잡한 분석 쿼리를 효율적으로 작성하는 방법을 배웁니다.
--
-- 학습 목표:
-- 1. PARTITION BY와 ORDER BY 활용
-- 2. ROW_NUMBER, RANK, DENSE_RANK 차이점 이해
-- 3. LAG/LEAD로 이전/다음 행 참조
-- 4. FIRST_VALUE, LAST_VALUE, NTH_VALUE 활용
-- 5. 누적 합계와 이동 평균 계산
-- ============================================================

-- 테스트용 테이블 생성
DROP TABLE IF EXISTS sales CASCADE;
DROP TABLE IF EXISTS employees CASCADE;

CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    department VARCHAR(50) NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    hire_date DATE NOT NULL
);

CREATE TABLE sales (
    id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(id),
    sale_date DATE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    region VARCHAR(50) NOT NULL
);

-- 샘플 데이터 삽입
INSERT INTO employees (name, department, salary, hire_date) VALUES
    ('김철수', '영업', 5000000, '2020-01-15'),
    ('이영희', '영업', 5500000, '2019-03-20'),
    ('박민수', '영업', 4800000, '2021-06-10'),
    ('정수진', '개발', 6000000, '2018-08-01'),
    ('최동욱', '개발', 6500000, '2017-02-14'),
    ('한미영', '개발', 5800000, '2020-11-30'),
    ('오승호', '마케팅', 4500000, '2022-01-05'),
    ('윤지혜', '마케팅', 4700000, '2021-09-15');

INSERT INTO sales (employee_id, sale_date, amount, region) VALUES
    (1, '2024-01-15', 1500000, '서울'),
    (1, '2024-01-22', 2300000, '서울'),
    (1, '2024-02-10', 1800000, '경기'),
    (2, '2024-01-18', 3200000, '서울'),
    (2, '2024-02-05', 2800000, '부산'),
    (2, '2024-02-20', 1900000, '서울'),
    (3, '2024-01-25', 1200000, '대전'),
    (3, '2024-02-15', 2100000, '경기');

-- ============================================================
-- 1. 기본 Window Function 문법
-- ============================================================

-- [나쁜 예시] 서브쿼리로 부서별 순위 계산 (비효율적)
SELECT
    e1.name,
    e1.department,
    e1.salary,
    (SELECT COUNT(*) + 1
     FROM employees e2
     WHERE e2.department = e1.department
       AND e2.salary > e1.salary) AS salary_rank
FROM employees e1
ORDER BY department, salary_rank;

-- 문제점:
-- 1. 각 행마다 서브쿼리가 실행되어 성능 저하
-- 2. 코드가 복잡하고 가독성이 낮음
-- 3. 동일 급여 처리가 불완전

-- [좋은 예시] Window Function으로 부서별 순위 계산
SELECT
    name,
    department,
    salary,
    -- 부서 내에서 급여 기준 순위 (동점 시 같은 순위, 다음 순위 건너뜀)
    RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS salary_rank,
    -- 부서 내에서 급여 기준 순위 (동점 시 같은 순위, 다음 순위 연속)
    DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS salary_dense_rank,
    -- 부서 내에서 행 번호 (고유 번호)
    ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS row_num
FROM employees
ORDER BY department, salary DESC;

-- 학습 포인트:
-- RANK(): 동점 시 같은 순위, 다음 순위는 동점 수만큼 건너뜀 (1, 2, 2, 4)
-- DENSE_RANK(): 동점 시 같은 순위, 다음 순위는 연속 (1, 2, 2, 3)
-- ROW_NUMBER(): 항상 고유한 순차 번호 (1, 2, 3, 4)

-- ============================================================
-- 2. LAG / LEAD - 이전/다음 행 참조
-- ============================================================

-- [나쁜 예시] 자기 조인으로 이전 매출 비교
SELECT
    s1.sale_date,
    s1.amount AS current_amount,
    s2.amount AS previous_amount,
    s1.amount - COALESCE(s2.amount, 0) AS difference
FROM sales s1
LEFT JOIN sales s2 ON s1.employee_id = s2.employee_id
    AND s2.sale_date = (
        SELECT MAX(sale_date)
        FROM sales
        WHERE employee_id = s1.employee_id
          AND sale_date < s1.sale_date
    )
WHERE s1.employee_id = 1
ORDER BY s1.sale_date;

-- 문제점:
-- 1. 복잡한 서브쿼리와 자기 조인
-- 2. 성능 저하 (인덱스 활용 어려움)
-- 3. 유지보수 어려움

-- [좋은 예시] LAG/LEAD로 이전/다음 행 참조
SELECT
    sale_date,
    amount AS current_amount,
    -- 이전 행의 매출액 (없으면 0)
    LAG(amount, 1, 0) OVER (ORDER BY sale_date) AS previous_amount,
    -- 다음 행의 매출액
    LEAD(amount, 1) OVER (ORDER BY sale_date) AS next_amount,
    -- 이전 매출 대비 변화량
    amount - LAG(amount, 1, 0) OVER (ORDER BY sale_date) AS difference,
    -- 이전 매출 대비 변화율 (%)
    ROUND(
        (amount - LAG(amount, 1, amount) OVER (ORDER BY sale_date)) * 100.0
        / NULLIF(LAG(amount, 1, amount) OVER (ORDER BY sale_date), 0),
        2
    ) AS change_percent
FROM sales
WHERE employee_id = 1
ORDER BY sale_date;

-- LAG/LEAD 문법:
-- LAG(column, offset, default) - offset개 이전 행의 값 (기본 offset=1)
-- LEAD(column, offset, default) - offset개 다음 행의 값

-- ============================================================
-- 3. FIRST_VALUE / LAST_VALUE / NTH_VALUE
-- ============================================================

-- [좋은 예시] 부서 내 최고/최저 급여자 정보 표시
SELECT
    name,
    department,
    salary,
    -- 부서 내 최고 급여자 이름
    FIRST_VALUE(name) OVER (
        PARTITION BY department
        ORDER BY salary DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS highest_paid,
    -- 부서 내 최저 급여자 이름
    LAST_VALUE(name) OVER (
        PARTITION BY department
        ORDER BY salary DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS lowest_paid,
    -- 부서 내 2번째 높은 급여자 이름
    NTH_VALUE(name, 2) OVER (
        PARTITION BY department
        ORDER BY salary DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS second_highest_paid,
    -- 최고 급여 대비 본인 급여 비율
    ROUND(salary * 100.0 / FIRST_VALUE(salary) OVER (
        PARTITION BY department ORDER BY salary DESC
    ), 2) AS salary_ratio_percent
FROM employees
ORDER BY department, salary DESC;

-- 주의사항:
-- LAST_VALUE는 기본적으로 현재 행까지만 봄
-- 전체 파티션을 보려면 ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING 필요

-- ============================================================
-- 4. 누적 합계와 이동 평균
-- ============================================================

-- [나쁜 예시] 서브쿼리로 누적 합계 계산
SELECT
    s1.sale_date,
    s1.amount,
    (SELECT SUM(s2.amount)
     FROM sales s2
     WHERE s2.sale_date <= s1.sale_date) AS running_total
FROM sales s1
ORDER BY s1.sale_date;

-- [좋은 예시] Window Function으로 누적 합계 및 이동 평균 계산
SELECT
    sale_date,
    amount,
    -- 누적 합계 (처음부터 현재 행까지)
    SUM(amount) OVER (ORDER BY sale_date) AS running_total,
    -- 누적 평균
    ROUND(AVG(amount) OVER (ORDER BY sale_date), 2) AS running_avg,
    -- 최근 3건의 이동 평균
    ROUND(AVG(amount) OVER (
        ORDER BY sale_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS moving_avg_3,
    -- 지역별 누적 합계
    SUM(amount) OVER (PARTITION BY region ORDER BY sale_date) AS region_running_total,
    -- 전체 대비 비율
    ROUND(amount * 100.0 / SUM(amount) OVER (), 2) AS total_percent
FROM sales
ORDER BY sale_date;

-- Frame 절 (ROWS/RANGE) 옵션:
-- ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW (기본값)
-- ROWS BETWEEN 2 PRECEDING AND CURRENT ROW (최근 3건)
-- ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING (현재 + 다음 2건)
-- ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING (전체)

-- ============================================================
-- 5. 실무 활용 예시: 복합 분석 쿼리
-- ============================================================

-- [실무 예시] 종합 판매 분석 리포트
WITH sales_analysis AS (
    SELECT
        e.name AS employee_name,
        e.department,
        s.sale_date,
        s.amount,
        s.region,
        -- 개인별 월간 매출 합계
        SUM(s.amount) OVER (
            PARTITION BY s.employee_id, DATE_TRUNC('month', s.sale_date)
        ) AS monthly_total,
        -- 개인별 누적 매출
        SUM(s.amount) OVER (
            PARTITION BY s.employee_id
            ORDER BY s.sale_date
        ) AS personal_running_total,
        -- 부서 내 매출 순위
        RANK() OVER (
            PARTITION BY e.department
            ORDER BY s.amount DESC
        ) AS dept_sales_rank,
        -- 이전 거래 대비 성장률
        ROUND(
            (s.amount - LAG(s.amount) OVER (PARTITION BY s.employee_id ORDER BY s.sale_date)) * 100.0
            / NULLIF(LAG(s.amount) OVER (PARTITION BY s.employee_id ORDER BY s.sale_date), 0),
            2
        ) AS growth_rate,
        -- 부서 평균 대비 비율
        ROUND(
            s.amount * 100.0 / AVG(s.amount) OVER (PARTITION BY e.department),
            2
        ) AS dept_avg_ratio
    FROM sales s
    JOIN employees e ON s.employee_id = e.id
)
SELECT * FROM sales_analysis
ORDER BY sale_date, employee_name;

-- ============================================================
-- 6. 성능 최적화 팁
-- ============================================================

-- 인덱스 생성 (Window Function 성능 향상)
CREATE INDEX idx_sales_employee_date ON sales(employee_id, sale_date);
CREATE INDEX idx_sales_date_amount ON sales(sale_date, amount);
CREATE INDEX idx_employees_dept_salary ON employees(department, salary DESC);

-- [성능 분석] EXPLAIN ANALYZE로 실행 계획 확인
EXPLAIN ANALYZE
SELECT
    name,
    department,
    salary,
    RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS salary_rank
FROM employees;

-- ============================================================
-- 학습 포인트 요약
-- ============================================================
/*
1. Window Function 기본 구조:
   함수명() OVER (PARTITION BY ... ORDER BY ... ROWS/RANGE ...)

2. 순위 함수:
   - ROW_NUMBER(): 고유 순번
   - RANK(): 동점 시 같은 순위, 건너뜀
   - DENSE_RANK(): 동점 시 같은 순위, 연속

3. 행 참조 함수:
   - LAG(col, n, default): n개 이전 행
   - LEAD(col, n, default): n개 다음 행
   - FIRST_VALUE(), LAST_VALUE(), NTH_VALUE()

4. 집계 함수의 Window 버전:
   - SUM(), AVG(), COUNT(), MIN(), MAX() 등

5. Frame 절:
   - ROWS BETWEEN ... AND ...
   - UNBOUNDED PRECEDING, CURRENT ROW, UNBOUNDED FOLLOWING, n PRECEDING/FOLLOWING

6. 성능 최적화:
   - PARTITION BY, ORDER BY 컬럼에 인덱스 생성
   - 불필요한 Window Function 중복 피하기
   - EXPLAIN ANALYZE로 실행 계획 확인
*/

# Learning Code Project

## 프로젝트 개요
다양한 프로그래밍 언어와 기술의 **좋은 예시(Good Practice)**와 **나쁜 예시(Bad Practice)**를 비교하여 학습할 수 있는 종합 학습 프로젝트입니다.

## 프로젝트 구조
```
learning-code/
├── java/           # Java 기본부터 고급까지 (12 Steps)
├── python/         # Python 기본부터 데이터분석까지 (10 Steps)
├── rust/           # Rust 소유권부터 동시성까지 (10 Steps)
├── javascript/     # JavaScript ES6+ 학습 (10 Steps)
├── typescript/     # TypeScript 타입 시스템 (10 Steps)
├── springboot/     # Spring Boot 실무 패턴 (13 Steps)
├── springbatch/    # Spring Batch 대용량 처리 (10 Steps)
├── react/          # React Hooks & 상태관리 (10 Steps)
├── vue2/           # Vue 2 Options API (10 Steps)
├── vue3/           # Vue 3 Composition API (10 Steps)
├── golang/         # Go 동시성 프로그래밍 (5 Steps)
├── kotlin/         # Kotlin 현대적 문법 (5 Steps)
├── docker/         # Docker 컨테이너화 (10 Steps)
├── kubernetes/     # Kubernetes 오케스트레이션 (5 Steps)
├── postgresql/     # PostgreSQL 성능 최적화 (10 Steps)
├── comparisons/    # 언어간 비교 분석
└── LEARNING_PROGRESS.md  # 진행 상황 추적
```

## 코딩 규칙
- **모든 주석은 한글로 작성**
- 각 파일에 **나쁜 예시 (Bad Example)**와 **좋은 예시 (Good Example)** 포함
- **학습 포인트** 설명 포함
- 파일명 규칙: `Step{번호}_{주제명}.{확장자}`

## 학습 계획 파일 규칙
- 각 기술 디렉토리에 `{기술명}_learning_plan.md` 파일 포함
- 학습 로드맵 테이블에 **상태** 컬럼 포함 (완료/미완료)
- "마무리하며" 섹션 대신 **추가 학습 권장 사항** 테이블 사용

## 주요 명령어
```bash
# Java 파일 컴파일 및 실행
javac Step1_VariablesAndConstants.java && java Step1_VariablesAndConstants

# Python 파일 실행
python Step1_PythonBasicSyntax.py

# Rust 파일 컴파일 및 실행
rustc Step1_BasicSyntaxAndCargo.rs && ./Step1_BasicSyntaxAndCargo
```

## 기여 가이드
1. 새로운 기술 추가 시 `{기술명}_learning_plan.md` 먼저 작성
2. Step별 파일 생성 (나쁜 예시 → 좋은 예시 → 학습 포인트)
3. 학습 로드맵 상태 업데이트
4. LEARNING_PROGRESS.md 업데이트

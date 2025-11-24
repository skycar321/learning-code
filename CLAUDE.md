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

---

## Claude Code Skills 참조

> 작성자가 보유한 Claude Code Skills입니다. 필요시 해당 스킬을 참고하여 작업을 수행할 수 있습니다.
>
> **위치**: `C:/Users/Nam/.claude/skills/`

### 개발 프로세스 스킬
| 스킬명 | 설명 |
|:-------|:-----|
| **ai-senior-developer** | PERE 프레임워크 기반 시니어 개발자 역할 (코드 생성, 디버깅, 리팩토링, 보안 분석) |
| **step-by-step** | 3단계(분석-계획-구현) 구조화된 개발 워크플로우 |
| **clean-code** | 클린 코드 원칙 및 SOLID 패턴 |
| **testing-strategy** | 테스트 전략 수립 |
| **git-commit** | Conventional Commits 표준 커밋 메시지 규칙 |

### 프로젝트 초기화 스킬
| 스킬명 | 설명 |
|:-------|:-----|
| **nextjs15-init** | Next.js 15 프로젝트 자동 생성 (App Router, ShadCN, Zustand) |
| **flutter-init** | Flutter 프로젝트 자동 생성 (Clean Architecture, Riverpod 3.0, Drift) |
| **landing-page-guide-v2** | 고품질 랜딩페이지 가이드 (11가지 필수 요소) |
| **frontend-design** | 프론트엔드 디자인 가이드 |

### 언어/프레임워크 스킬
| 스킬명 | 설명 |
|:-------|:-----|
| **java-spring** | Java + Spring 개발 가이드 |
| **spring-batch** | Spring Batch 대용량 처리 |
| **javascript** | JavaScript 개발 가이드 |
| **typescript** | TypeScript 타입 시스템 |
| **react-typescript** | React + TypeScript 개발 |
| **vue2** | Vue 2 Options API |
| **vue3** | Vue 3 Composition API |
| **python** | Python 개발 가이드 |
| **rust** | Rust 개발 가이드 |

### DevOps & 인프라 스킬
| 스킬명 | 설명 |
|:-------|:-----|
| **devops-cicd** | CI/CD 파이프라인 구축 |
| **database-optimization** | 데이터베이스 성능 최적화 |
| **security** | 보안 분석 및 취약점 점검 |
| **legacy-migration** | 레거시 시스템 마이그레이션 |

### 문서화 & 콘텐츠 스킬
| 스킬명 | 설명 |
|:-------|:-----|
| **workthrough** / **workthrough-v2** | 개발 작업 문서화 자동 생성 |
| **code-changelog** | 코드 변경 이력 문서화 |
| **web-to-markdown** | 웹페이지 → 마크다운 변환 |
| **card-news-generator-v2** | 인스타그램 카드뉴스 생성 |

### AI/프롬프트 스킬
| 스킬명 | 설명 |
|:-------|:-----|
| **code-prompt-coach** | Claude Code 세션 로그 분석 (프롬프트 품질, 토큰 사용량) |
| **prompt-enhancer** | 프롬프트 개선 도우미 |
| **meta-prompt-generator** | 메타 프롬프트 생성기 |
| **codex** / **codex-claude-loop** | Codex 연동 워크플로우 |

### 스킬 참조 방법
```bash
# 특정 스킬 내용 확인
cat ~/.claude/skills/{스킬명}.md
```

### 활용 지침
- 복잡한 개발 작업 → `step-by-step` 3단계 프로세스 적용
- 코드 품질 검토 → `ai-senior-developer`의 PERE 프레임워크 활용
- 커밋 작성 → `git-commit`의 Conventional Commits 규칙 적용
- 새 프로젝트 생성 → `nextjs15-init` 또는 `flutter-init` 참조
- 언어별 개발 → 해당 언어 스킬 참조 (java-spring, vue3, react-typescript 등)

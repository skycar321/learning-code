# IRD: Learning Code 웹 학습 플랫폼

> **프로젝트**: Learning Code Interactive Web Platform
> **작성일**: 2025-11-30
> **목적**: 로컬 학습 자료를 웹 기반 인터랙티브 플랫폼으로 전환

---

## 1. 프로젝트 개요

### 1.1 목적
기존 파일 기반 학습 자료(`.java`, `.js`, `.md` 등)를 웹 브라우저에서 체계적으로 학습할 수 있는 **인터랙티브 웹 플랫폼** 구축

### 1.2 핵심 가치
- **구조화된 학습**: 카테고리별 분류 및 순차적 학습 경로 제공
- **즉시 실행**: 웹 기반 코드 실행 환경 제공
- **진행률 추적**: 학습 진행 상황 시각화
- **비교 학습**: Good/Bad Practice 코드 비교

---

## 2. 기능 요구사항

### 2.1 네비게이션 시스템
**왼쪽 사이드바 (카테고리 트리)**
- 기술별 분류 (Java, Python, Vue3, Spring Boot 등)
- 각 기술 내 Step 목록 표시
- 진행 상태 표시 (미학습/진행중/완료)
- 검색 기능

**메인 컨텐츠 영역**
- 선택된 Step의 학습 내용 렌더링
- 코드 블록 문법 하이라이팅
- Bad Example / Good Example 탭 전환
- 학습 포인트 하이라이트 표시

### 2.2 코드 실행 환경
**지원 언어**
- JavaScript/TypeScript: 브라우저 내 실행 (Web Worker 사용)
- Python: Pyodide 또는 별도 백엔드 API
- Java: 백엔드 컴파일 서비스 필요 (선택사항)

**기능**
- 코드 편집기 (Monaco Editor 또는 CodeMirror)
- 실행 버튼 + 결과 출력 패널
- 에러 메시지 표시
- 코드 리셋 기능

### 2.3 학습 진행 관리
- LocalStorage 기반 진행률 저장
- 각 Step별 완료 체크박스
- 전체 진행률 % 표시
- 학습 이력 타임라인 (선택사항)

### 2.4 반응형 디자인
- 모바일/태블릿 지원
- 사이드바 토글 (모바일 시 햄버거 메뉴)
- 다크모드 지원

---

## 3. 기술 요구사항

### 3.1 프론트엔드 스택
**프레임워크**: Next.js 15 (App Router)
**이유**:
- SSG로 학습 자료 파일 빌드타임 파싱
- 파일시스템 라우팅
- SEO 최적화

**UI 라이브러리**: ShadCN UI + Tailwind CSS
**상태관리**: Zustand (학습 진행 상태)
**코드 에디터**: Monaco Editor
**마크다운 파싱**: `remark` + `rehype`
**코드 실행**:
- JavaScript: Web Worker
- Python: Pyodide (WASM)

### 3.2 백엔드 (선택사항)
Java 실행을 위한 간단한 컴파일 API
- **옵션 1**: Judge0 API 사용 (외부 서비스)
- **옵션 2**: Docker 기반 자체 샌드박스 환경

### 3.3 배포
- **개발**: localhost:3000
- **프로덕션**: Vercel 또는 GitHub Pages (정적 사이트)

---

## 4. 데이터 구조

### 4.1 파일 파싱
학습 자료 파일 구조 예시:
```
learning-code/
├── java/
│   ├── java_learning_plan.md      # Step 목록 메타데이터
│   ├── Step1_Variables.java       # 코드 + 주석
│   ├── Step2_NullHandling.java
│   └── ...
├── vue3/
│   ├── vue3_learning_plan.md
│   ├── Step1_CompositionAPI.js
│   └── ...
└── comparisons/
    ├── ErrorHandling_Comparison.md
    └── ...
```

### 4.2 메타데이터 추출
각 `{tech}_learning_plan.md`에서 추출:
```typescript
interface LearningPlan {
  category: string;           // "Java"
  steps: Step[];
}

interface Step {
  stepNumber: number;         // 1
  title: string;              // "변수와 상수"
  goal: string;               // "매직 넘버 지양..."
  status: "완료" | "진행중" | "미학습";
  filePath: string;           // "java/Step1_Variables.java"
}
```

### 4.3 코드 블록 파싱
Java/JS 파일에서 주석 기반 섹션 분리:
```java
// === BAD EXAMPLE ===
// 나쁜 코드...

// === GOOD EXAMPLE ===
// 좋은 코드...

// === 학습 포인트 ===
// 설명...
```

---

## 5. UI/UX 와이어프레임

```
┌─────────────────────────────────────────────────────────┐
│  [Logo] Learning Code             [Search] [Dark Mode]  │
├──────────┬──────────────────────────────────────────────┤
│          │  # Step 1: 변수와 상수                        │
│ Java  ▼  │  **학습 목표**: 매직 넘버 지양...            │
│  Step1 ✓ │                                               │
│  Step2 ◯ │  [Tab: Bad Example] [Tab: Good Example]      │
│  Step3 ◯ │  ┌──────────────────────────────────────┐   │
│          │  │ Code Editor                          │   │
│ Vue3  ▼  │  │ public static final int SECONDS...   │   │
│  Step1 ◯ │  │                                      │   │
│  Step2 ◯ │  └──────────────────────────────────────┘   │
│          │  [Run Code]  [Reset]                         │
│ Spring ▼ │  ┌──────────────────────────────────────┐   │
│  Step1 ◯ │  │ Output:                              │   │
│          │  │ 86400                                │   │
│ Progress │  └──────────────────────────────────────┘   │
│ ████░ 65%│                                               │
│          │  **학습 포인트**                             │
│          │  - 매직 넘버는 가독성을 해침...             │
│          │                                               │
│          │  [Previous] [Mark Complete] [Next]           │
└──────────┴──────────────────────────────────────────────┘
```

---

## 6. 개발 우선순위

### Phase 1: MVP (1주)
- [ ] Next.js 프로젝트 초기화
- [ ] 파일시스템에서 마크다운 파싱
- [ ] 사이드바 카테고리 트리 구현
- [ ] 메인 컨텐츠 렌더링 (코드 하이라이팅)
- [ ] LocalStorage 진행률 저장

### Phase 2: 코드 실행 (1주)
- [ ] Monaco Editor 통합
- [ ] JavaScript 코드 실행 (Web Worker)
- [ ] Python 실행 (Pyodide)
- [ ] 에러 핸들링

### Phase 3: 개선 (1주)
- [ ] 다크모드
- [ ] 검색 기능
- [ ] 반응형 디자인
- [ ] 학습 이력 시각화

---

## 7. 성공 지표
- ✅ 모든 학습 자료 파일 파싱 성공률 100%
- ✅ JavaScript/TypeScript 코드 실행 정확도 100%
- ✅ 모바일 반응형 지원
- ✅ 페이지 로드 시간 < 2초

---

## 8. 리스크 및 제약사항
| 리스크 | 완화 방안 |
|--------|-----------|
| Java 코드 실행 복잡도 | Phase 1에서는 코드 보기만 지원, 실행은 Phase 3 |
| 대량 파일 파싱 성능 | 빌드타임 정적 생성 (SSG) |
| 브라우저 호환성 | Pyodide는 최신 브라우저만 지원 (폴백 메시지) |

---

## 9. 참고 자료
- Next.js 15 Docs: https://nextjs.org/docs
- Monaco Editor: https://microsoft.github.io/monaco-editor/
- Pyodide: https://pyodide.org/
- ShadCN UI: https://ui.shadcn.com/

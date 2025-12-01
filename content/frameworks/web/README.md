# Learning Code - 인터랙티브 학습 플랫폼

> 프로그래밍 언어와 프레임워크를 Bad vs Good Practice 비교를 통해 학습하는 웹 플랫폼

![Next.js](https://img.shields.io/badge/Next.js-15.5-black)
![TypeScript](https://img.shields.io/badge/TypeScript-5.7-blue)
![Tailwind CSS](https://img.shields.io/badge/Tailwind-3.4-38bdf8)

## 🎯 주요 기능

- **📚 구조화된 학습 경로**: 카테고리별, Step별로 체계적으로 구성된 학습 자료
- **🔄 코드 비교**: Bad Example과 Good Example을 탭으로 전환하며 비교 학습
- **✅ 진행률 추적**: LocalStorage 기반 학습 진행 상황 자동 저장
- **💡 학습 포인트**: 각 Step마다 핵심 개념 설명
- **🌙 다크 모드**: 눈에 편안한 다크/라이트 테마 지원

## 🚀 빠른 시작

### 필수 요구사항

- Node.js 18.x 이상
- npm 9.x 이상

### 설치 및 실행

```bash
# 의존성 설치
npm install

# 개발 서버 실행 (Turbopack)
npm run dev

# 브라우저에서 http://localhost:3000 열기
```

### 프로덕션 빌드

```bash
# 프로덕션 빌드
npm run build

# 프로덕션 서버 실행
npm start
```

## 📁 프로젝트 구조

```
web/
├── app/                          # Next.js App Router
│   ├── page.tsx                  # 메인 페이지 (카테고리 목록)
│   ├── learn/[category]/         # 카테고리별 Step 목록
│   └── learn/[category]/step/[stepNumber]/  # Step 상세 페이지
├── components/                   # React 컴포넌트
│   ├── CategoryCard.tsx          # 카테고리 카드 (진행률 포함)
│   ├── CodeTabs.tsx              # Bad/Good 코드 탭 컴포넌트
│   └── CompleteButton.tsx        # Step 완료 버튼
├── lib/                          # 유틸리티 및 데이터
│   ├── sampleData.ts             # 샘플 학습 데이터
│   └── utils.ts                  # 헬퍼 함수
├── stores/                       # Zustand 상태 관리
│   └── progressStore.ts          # 진행률 스토어
└── types/                        # TypeScript 타입 정의
    └── learning.ts               # 학습 데이터 타입
```

## 🛠️ 기술 스택

| 분류 | 기술 |
|------|------|
| **프레임워크** | Next.js 15 (App Router, Turbopack) |
| **언어** | TypeScript 5.7 |
| **스타일링** | Tailwind CSS 3.4 |
| **상태 관리** | Zustand (LocalStorage persist) |
| **코드 하이라이팅** | react-syntax-highlighter |
| **아이콘** | Lucide React |

## 📚 지원 카테고리

현재 다음 카테고리의 학습 자료를 제공합니다:

- ☕ **Java**: 실무 Java 코드 Best Practices
- 💚 **Vue 3**: Composition API 및 현대적 Vue 패턴
- 🐍 **Python**: Pythonic 코드 작성법
- 🍃 **Spring Boot**: Spring Boot 핵심 개념

## 🎨 주요 화면

### 메인 페이지
- 카테고리별 학습 진행률 표시
- 완료한 Step 수 / 전체 Step 수 표시
- 진행률 바 시각화

### Step 상세 페이지
- Bad Example / Good Example 탭 전환
- 문법 하이라이팅된 코드 블록
- 학습 포인트 하이라이트 박스
- 이전/다음 Step 네비게이션
- 학습 완료 버튼

## 🔧 개발 스크립트

```bash
# 개발 서버 (Turbopack)
npm run dev

# 프로덕션 빌드
npm run build

# 프로덕션 서버
npm start

# Lint 검사
npm run lint
```

## 📝 데이터 추가 방법

새로운 학습 자료를 추가하려면 `lib/sampleData.ts` 파일을 수정하세요:

```typescript
// 새 카테고리 추가
{
  id: "rust",
  name: "rust",
  displayName: "Rust",
  description: "Rust 언어 학습",
  steps: [
    {
      id: "rust-step1",
      stepNumber: 1,
      title: "소유권(Ownership)",
      goal: "Rust의 소유권 개념을 이해합니다.",
      status: "미학습",
      filePath: "rust/Step1_Ownership.rs",
      fileName: "Step1_Ownership.rs",
      category: "rust",
      code: [
        {
          type: "bad",
          language: "rust",
          content: `// Bad code here`
        },
        {
          type: "good",
          language: "rust",
          content: `// Good code here`
        }
      ],
      learningPoints: [
        "포인트 1",
        "포인트 2"
      ]
    }
  ]
}
```

## 🚧 향후 개발 계획

- [ ] 실제 파일 시스템에서 학습 자료 파싱
- [ ] JavaScript/Python 코드 브라우저 내 실행
- [ ] Monaco Editor 통합 (코드 편집 기능)
- [ ] 검색 기능
- [ ] 학습 이력 타임라인
- [ ] 공유 기능

## 📄 라이선스

MIT License

## 👨‍💻 개발자

Learning Code Platform - 2025-11-30

---

**Made with ❤️ using Next.js 15 and Turbopack**

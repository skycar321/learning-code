# Step4: Next.js 스타일링 및 최적화

이 디렉토리는 Next.js 애플리케이션에서 스타일링 기법(CSS Modules)과 이미지 최적화(`next/image`)를 학습하기 위한 예제 코드입니다.

## 학습 목표

-   CSS Modules를 이용한 컴포넌트 스코프 스타일링
-   `next/image` 컴포넌트를 이용한 이미지 최적화
-   Next.js의 내장 최적화 기능 이해 및 활용
-   웹 성능 향상을 위한 스타일링 및 최적화 모범 사례 파악

## 프로젝트 구조

```
nextjs/Step4_StylingAndOptimization/
├── pages/
│   ├── _app.tsx              # 전역 CSS 임포트
│   └── index.tsx             # CSS Modules 및 OptimizedImage 컴포넌트 사용 예제
├── components/
│   ├── Layout.tsx            # 공통 레이아웃 컴포넌트
│   └── OptimizedImage.tsx    # next/image 컴포넌트 사용 예제
├── styles/
│   ├── globals.css           # 전역 CSS
│   └── Home.module.css       # CSS Modules 예제
├── public/
│   └── nextjs-logo.png       # next/image에 사용될 이미지 파일 (더미)
└── README.md
```

## 파일 설명

-   **`pages/index.tsx`**:
    -   `import styles from '../styles/Home.module.css'`를 통해 CSS Modules를 임포트하고 `className={styles.title}`과 같이 사용하여 컴포넌트 스코프 스타일을 적용합니다.
    -   `OptimizedImage` 컴포넌트를 임포트하여 `next/image`의 최적화된 이미지 로딩을 시연합니다.

-   **`styles/Home.module.css`**:
    -   CSS Modules 파일입니다. 이 파일에 정의된 `.title`, `.description` 등의 클래스 이름은 빌드 시 고유한 해싱된 이름으로 변경되어 전역 스타일과의 충돌을 방지합니다.

-   **`components/OptimizedImage.tsx`**:
    -   `next/image` 컴포넌트를 래핑(wrap)하여 이미지 최적화 기능을 보여줍니다.
    -   `width`, `height`를 명시하고 `layout="responsive"`를 사용하여 이미지 크기 최적화, 지연 로딩, CLS 방지 등의 기능을 활용합니다.

-   **`pages/_app.tsx`**:
    -   `import '../styles/globals.css'`를 통해 전역 CSS(`globals.css`)를 임포트합니다. Next.js에서 전역 CSS는 이 파일에서만 임포트할 수 있습니다.

-   **`styles/globals.css`**:
    -   전역적으로 적용되는 기본 CSS 스타일을 포함합니다. (Reset CSS, 기본 폰트 설정 등)

-   **`public/nextjs-logo.png`**:
    -   `next/image` 컴포넌트에서 사용될 예시 이미지 파일입니다. (실제 이미지가 아니어도 예제 실행에는 지장 없음)

## 설정 및 실행 방법

이 예제를 실행하려면 기존 Next.js 프로젝트(`Step1`에서 생성한 프로젝트)를 기반으로 합니다.

1.  **Next.js 프로젝트 생성 및 Step1 파일 설정**:
    -   `npx create-next-app nextjs-styling-app --typescript`
    -   `cd nestjs-styling-app`
    -   `Step1`의 `pages/about.tsx`, `pages/_app.tsx`, `styles/globals.css` 파일을 적절한 경로에 복사합니다. (`Layout.tsx`도 `components` 디렉토리에 복사)

2.  **파일 복사**:
    -   `pages/index.tsx` 파일을 `pages/` 디렉토리로 복사합니다.
    -   `styles/Home.module.css` 파일을 `styles/` 디렉토리로 복사합니다.
    -   `components/OptimizedImage.tsx` 파일을 `components/` 디렉토리로 복사합니다.
    -   `public/nextjs-logo.png` 파일을 `public/` 디렉토리로 복사합니다. (더미 파일도 괜찮음)

3.  **애플리케이션 실행**:
    ```bash
    npm run dev
    # 또는 yarn dev
    ```

4.  **페이지 확인**:
    -   웹 브라우저로 `http://localhost:3000/` 경로에 접근하여 페이지를 확인합니다.
    -   `h1` 태그와 `p` 태그에 CSS Modules가 올바르게 적용되었는지 확인합니다.
    -   `nextjs-logo.png` 이미지가 로드되는 것을 확인합니다.
    -   개발자 도구(F12)의 네트워크 탭에서 이미지가 최적화된 형태로 로드되는지, 지연 로딩이 적용되는지 확인해볼 수 있습니다.

## 나쁜 예시와 좋은 예시 (개념)

`index.tsx`, `Home.module.css`, `OptimizedImage.tsx`, `globals.css` 파일 내의 주석을 참조하여, Next.js 스타일링 및 최적화 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 웹 성능은 사용자 경험과 SEO에 직접적인 영향을 미치므로, 이러한 최적화 기법을 적극적으로 활용하는 것이 중요합니다.

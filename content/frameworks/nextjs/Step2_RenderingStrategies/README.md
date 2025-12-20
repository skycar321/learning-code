# Step2: Next.js 렌더링 전략

이 디렉토리는 Next.js의 다양한 렌더링 전략(SSR, SSG)을 학습하기 위한 예제 코드입니다.

## 학습 목표

-   클라이언트 사이드 렌더링(CSR), 서버 사이드 렌더링(SSR), 정적 사이트 생성(SSG)의 개념 이해
-   `getServerSideProps`를 이용한 SSR 구현
-   `getStaticProps` 및 `getStaticPaths`를 이용한 SSG 구현
-   각 렌더링 전략의 사용 시나리오 및 장단점 파악

## 프로젝트 구조

```
nextjs/Step2_RenderingStrategies/
├── pages/
│   ├── ssr.tsx               # SSR 예제 페이지 (`getServerSideProps` 사용)
│   └── ssg/
│       └── [id].tsx          # SSG 예제 페이지 (`getStaticProps`, `getStaticPaths` 사용)
└── README.md
```

## 파일 설명

-   **`pages/ssr.tsx`**:
    -   `getServerSideProps`: 이 함수는 페이지 요청 시마다 서버에서 실행됩니다. 데이터를 가져와 `props`로 페이지에 전달합니다.
    -   SSR은 동적인 데이터가 필요하거나 사용자별로 다른 콘텐츠를 보여주어야 할 때 적합합니다. 페이지를 새로고침할 때마다 데이터 가져온 시간이 현재 시간으로 업데이트되는 것을 통해 SSR의 동작을 확인할 수 있습니다.

-   **`pages/ssg/[id].tsx`**:
    -   `getStaticPaths`: 이 함수는 SSG를 위해 필요한 동적 경로(Dynamic Routes)의 모든 가능한 경로(`id`)를 정의합니다. 빌드 시점에 실행되며, Next.js가 어떤 페이지를 미리 생성할지 알려줍니다. `fallback: false`로 설정하여 미리 생성되지 않은 경로에 접근 시 404를 반환합니다.
    -   `getStaticProps`: 이 함수는 각 페이지 컴포넌트(`SsgPage`)가 렌더링되기 전에 빌드 시점에 실행됩니다. `context.params`를 통해 `getStaticPaths`에서 정의된 경로 파라미터(`id`)에 접근하여 데이터를 가져와 `props`로 페이지에 전달합니다.
    -   SSG는 데이터가 빌드 시점에 결정되고 자주 변경되지 않는 페이지(블로그 게시물, 제품 상세 페이지 등)에 적합합니다. 페이지를 새로고침해도 데이터 가져온 시간이 변경되지 않는 것을 통해 SSG의 동작을 확인할 수 있습니다.

## 설정 및 실행 방법

이 예제를 실행하려면 기존 Next.js 프로젝트(`Step1`에서 생성한 프로젝트)를 기반으로 합니다. `Layout` 컴포넌트와 `globals.css` 파일은 `Step1`에서 미리 준비되어 있어야 합니다.

1.  **Next.js 프로젝트 생성 및 Step1 파일 설정**:
    -   `npx create-next-app nextjs-rendering-app --typescript`
    -   `cd nextjs-rendering-app`
    -   `Step1`의 `pages/index.tsx`, `pages/about.tsx`, `components/Layout.tsx`, `pages/_app.tsx`, `styles/globals.css` 파일을 적절한 경로에 복사합니다.

2.  **파일 복사**:
    -   `ssr.tsx` 파일을 `pages/` 디렉토리로 복사합니다.
    -   `ssg/[id].tsx` 파일을 `pages/ssg/` 디렉토리로 복사합니다. (pages 아래에 `ssg` 디렉토리 생성)

3.  **애플리케이션 실행**:
    ```bash
    npm run dev
    # 또는 yarn dev
    ```

4.  **API 테스트 (예시)**:
    -   웹 브라우저로 다음 경로에 접근하여 SSR 및 SSG의 동작을 확인합니다.

    -   **SSR 페이지**:
        -   `http://localhost:3000/ssr`
        -   페이지를 새로고침할 때마다 "서버에서 데이터 가져온 시간"이 현재 시간으로 업데이트되는 것을 확인합니다.
        -   뷰 소스 보기(`Ctrl+U`)를 통해 페이지 소스에 데이터가 포함되어 있는지 확인합니다.

    -   **SSG 페이지**:
        -   `http://localhost:3000/ssg/1`
        -   `http://localhost:3000/ssg/2`
        -   페이지를 새로고침해도 "빌드된 시간"이 변경되지 않는 것을 확인합니다.
        -   `npm run build` 후 `npm run start`로 빌드된 애플리케이션을 실행하면 더 명확하게 SSG의 동작을 확인할 수 있습니다. `out` 디렉토리에 정적 HTML 파일이 생성됩니다.

## 나쁜 예시와 좋은 예시 (개념)

`ssr.tsx` 및 `ssg/[id].tsx` 파일 내의 주석을 참조하여, Next.js 렌더링 전략 사용 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 각 렌더링 전략은 특정 시나리오에 적합하므로, 애플리케이션의 요구 사항에 맞춰 적절한 전략을 선택하는 것이 중요합니다.

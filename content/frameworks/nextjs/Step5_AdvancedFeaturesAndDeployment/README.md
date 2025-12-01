# Step5: Next.js 고급 기능 및 배포

이 디렉토리는 Next.js의 고급 기능(미들웨어, 환경 변수) 및 배포 전략을 학습하기 위한 예제 코드입니다.

## 학습 목표

-   Next.js 미들웨어를 이용한 요청 처리 전/후 로직 추가
-   환경 변수 관리 (`.env` 파일, `next.config.js`)
-   절대 경로 임포트 설정
-   TypeScript와 함께 Next.js 사용
-   배포 전략 (`Vercel`, `Netlify`, 커스텀 서버) 이해
-   테스트 전략 (`Jest`, `React Testing Library`) 이해

## 프로젝트 구조

```
nextjs/Step5_AdvancedFeaturesAndDeployment/
├── middleware.ts             # Next.js 미들웨어 예제
├── next-env.d.ts             # TypeScript 전역 타입 정의
├── pages/
│   ├── _app.tsx              # (공통)
│   ├── index.tsx             # (공통)
│   ├── admin.tsx             # 미들웨어 테스트를 위한 페이지 (새로 생성)
│   └── login.tsx             # 미들웨어 리다이렉트 테스트를 위한 페이지 (새로 생성)
├── components/
│   └── Layout.tsx            # (공통)
├── styles/
│   └── globals.css           # (공통)
├── public/                   # (공통)
└── README.md
```

## 파일 설명

-   **`middleware.ts`**:
    -   Next.js 12부터 도입된 미들웨어 기능입니다. `NextRequest` 객체를 받아 `NextResponse` 객체를 반환하는 함수로, 요청이 페이지 핸들러에 도달하기 전에 코드를 실행합니다.
    -   `config` 객체의 `matcher` 속성을 사용하여 미들웨어가 적용될 경로를 정의합니다.
    -   `/admin` 경로에 대한 인증 로직(쿠키 확인)과 `/old-page`에 대한 리다이렉션 예시를 포함합니다.

-   **`next-env.d.ts`**:
    -   Next.js 환경을 위한 TypeScript 전역 타입 정의 파일입니다. 일반적으로 `create-next-app`으로 프로젝트 생성 시 자동으로 포함됩니다.

-   **환경 변수 관리 (개념)**:
    -   `dotenv` 라이브러리를 사용하거나, 프로젝트 루트에 `.env`, `.env.local`, `.env.production` 등의 파일을 생성하여 환경 변수를 관리합니다.
    -   Next.js는 `.env.local` 파일을 자동으로 로드합니다.
    -   `NEXT_PUBLIC_` 접두사가 붙은 환경 변수는 클라이언트 사이드 코드에서도 접근 가능합니다.
    -   `next.config.js` 파일에서 `env` 속성을 통해 환경 변수를 설정할 수도 있습니다.

-   **절대 경로 임포트 설정 (개념)**:
    -   `jsconfig.json` 또는 `tsconfig.json` 파일에 `baseUrl`과 `paths`를 설정하여 상대 경로 대신 `@/components`와 같은 절대 경로로 컴포넌트나 모듈을 임포트할 수 있습니다.
    -   이는 코드의 가독성을 높이고 리팩토링을 용이하게 합니다.

-   **TypeScript와 함께 Next.js 사용 (개념)**:
    -   Next.js는 TypeScript를 기본적으로 지원합니다. `create-next-app` 시 `--typescript` 플래그를 사용하면 `tsconfig.json` 파일이 자동으로 생성됩니다.
    -   정적 타입 검사를 통해 개발 과정에서 오류를 줄이고 코드의 안정성을 높입니다.

## 설정 및 실행 방법

이 예제를 실행하려면 기존 Next.js 프로젝트를 기반으로 합니다. `Layout` 컴포넌트와 `globals.css` 파일은 `Step1`에서 미리 준비되어 있어야 합니다.

1.  **Next.js 프로젝트 생성**:
    -   `npx create-next-app nextjs-advanced-app --typescript`
    -   `cd nextjs-advanced-app`

2.  **파일 복사**:
    -   `middleware.ts` 파일을 프로젝트 루트 디렉토리로 복사합니다.
    -   `next-env.d.ts` 파일을 프로젝트 루트 디렉토리로 복사합니다. (기존 파일 덮어쓰기)
    -   `pages/admin.tsx` 파일을 `pages/` 디렉토리로 복사합니다. (새로 생성)
    -   `pages/login.tsx` 파일을 `pages/` 디렉토리로 복사합니다. (새로 생성, 간단한 텍스트 파일이어도 됨)
    -   `components/Layout.tsx`, `pages/_app.tsx`, `styles/globals.css` 등을 `Step1`에서 가져와 적절히 배치합니다.

3.  **`admin.tsx` 파일 내용**:
    ```typescript
    // pages/admin.tsx
    import Layout from '../components/Layout';

    export default function AdminPage() {
      return (
        <Layout title="관리자 페이지">
          <h1>관리자 페이지입니다.</h1>
          <p>미들웨어에 의해 보호됩니다.</p>
        </Layout>
      );
    }
    ```

4.  **`login.tsx` 파일 내용**:
    ```typescript
    // pages/login.tsx
    import Layout from '../components/Layout';

    export default function LoginPage() {
      return (
        <Layout title="로그인">
          <h1>로그인 페이지</h1>
          <p>미들웨어가 인증되지 않은 사용자를 리다이렉트합니다.</p>
          <button onClick={() => document.cookie = 'token=my-secret-token; path=/'}>토큰 설정 (로그인 시뮬레이션)</button>
        </Layout>
      );
    }
    ```

5.  **애플리케이션 실행**:
    ```bash
    npm run dev
    # 또는 yarn dev
    ```

6.  **미들웨어 테스트**:
    -   웹 브라우저로 `http://localhost:3000/admin` 경로에 접근합니다.
    -   쿠키에 `token`이 없으면 `/login` 페이지로 리다이렉트되는 것을 확인합니다.
    -   `/login` 페이지에서 "토큰 설정" 버튼을 클릭하여 쿠키에 `token`을 설정합니다.
    -   다시 `http://localhost:3000/admin`으로 접근하면 `admin.tsx` 페이지가 로드되는 것을 확인합니다.

## 배포 전략 (개념)

-   **Vercel**: Next.js 공식 개발사에서 제공하는 배포 플랫폼으로, Next.js 애플리케이션에 가장 최적화된 배포를 제공합니다. `git push`만으로 자동 배포 및 CI/CD를 구성할 수 있습니다.
-   **Netlify**: Vercel과 유사하게 Git 통합을 통해 정적 사이트 및 서버리스 함수 배포를 지원합니다.
-   **커스텀 서버**: `next start` 명령을 사용하여 Node.js 서버를 직접 실행하거나, Docker 이미지로 빌드하여 Kubernetes와 같은 컨테이너 오케스트레이션 플랫폼에 배포할 수 있습니다. 이는 더 많은 제어와 커스터마이징이 필요할 때 사용됩니다.

## 테스트 전략 (개념)

-   **Jest**: JavaScript 프로젝트를 위한 인기 있는 테스트 프레임워크.
-   **React Testing Library**: React 컴포넌트를 테스트하는 데 사용되며, 사용자가 컴포넌트와 상호작용하는 방식에 초점을 맞춥니다.
-   **Cypress / Playwright**: 엔드-투-엔드(E2E) 테스트 도구로, 실제 브라우저 환경에서 사용자 시나리오를 테스트합니다.

## 나쁜 예시와 좋은 예시 (개념)

`middleware.ts` 파일 내의 주석을 참조하여, Next.js 미들웨어 사용 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 미들웨어는 강력한 기능이지만, 성능과 보안을 고려하여 신중하게 설계하고 구현해야 합니다.

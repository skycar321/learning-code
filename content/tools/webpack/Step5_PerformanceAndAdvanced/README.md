# Step5: Webpack 성능 최적화 및 고급 기능

이 디렉토리는 Webpack의 코드 스플리팅, 캐싱 전략, 지연 로딩(`Lazy Loading`) 등
성능 최적화 기능과 고급 기능을 학습하기 위한 예제 코드입니다.

## 학습 목표

-   `optimization.splitChunks`를 이용한 코드 스플리팅 구현
-   `import()` 동적 임포트를 이용한 지연 로딩(Lazy Loading) 구현
-   `[contenthash]`를 이용한 캐싱 전략
-   Webpack 5의 새로운 기능 (`Asset Modules`, `Module Federation` 등) 개념 이해
-   Webpack 설정 디버깅 및 문제 해결 방법 파악

## 프로젝트 구조

```
webpack/Step5_PerformanceAndAdvanced/
├── package.json              # 프로젝트 메타데이터 및 의존성 정의
├── webpack.config.js         # Webpack 설정 파일
└── src/
    ├── index.js              # 메인 엔트리 포인트 JavaScript 파일 (지연 로딩 예제)
    ├── utils.js              # 지연 로딩될 유틸리티 모듈
    ├── index.html            # HtmlWebpackPlugin을 위한 템플릿 HTML 파일
    └── style.css             # 번들링될 CSS 파일
└── README.md
```

## 파일 설명

-   **`package.json`**:
    -   `devDependencies`: `webpack`, `webpack-cli`, `webpack-dev-server`, `html-webpack-plugin`, `mini-css-extract-plugin`, `css-loader`, `style-loader`, `clean-webpack-plugin` 등 Webpack 관련 필수 패키지를 정의합니다.

-   **`webpack.config.js`**:
    -   **`output.filename`**: `[name].[contenthash].js`를 사용하여 캐싱 효율을 높입니다. 파일 내용이 변경될 때만 해시 값이 변경되어 브라우저 캐싱에 유리합니다.
    -   **`optimization.splitChunks`**:
        -   `chunks: 'all'`: 모든 청크에 대해 코드 스플리팅을 적용합니다.
        -   `cacheGroups.vendor`: `node_modules`에서 가져온 서드파티 라이브러리를 `vendors`라는 별도의 청크로 분리합니다. 이는 벤더 라이브러리의 변경 가능성이 낮으므로 장기 캐싱에 매우 효과적입니다.
    -   **`plugins`**: `HtmlWebpackPlugin`, `MiniCssExtractPlugin`, `CleanWebpackPlugin` 등이 설정되어 있습니다.

-   **`src/index.js`**:
    -   `import('./utils')`와 같이 `import()` 동적 임포트 구문을 사용하여 `utils.js` 모듈을 지연 로딩합니다.
    -   `Load Utilities` 버튼을 클릭하면 `utils.js` 모듈이 동적으로 로드되고, 그 안에 정의된 `greet` 함수가 실행되는 것을 확인할 수 있습니다.

-   **`src/utils.js`**:
    -   `index.js`에서 동적으로 임포트되는 간단한 유틸리티 모듈입니다.

-   **`src/index.html`**:
    -   `HtmlWebpackPlugin`이 사용할 템플릿 HTML 파일입니다.

-   **`src/style.css`**:
    -   `index.js`에서 임포트되는 간단한 CSS 파일입니다.

## 설정 및 실행 방법

`webpack/Step5_PerformanceAndAdvanced` 디렉토리에서 터미널을 열고 다음 명령어를 실행합니다.

1.  **프로젝트 준비**:
    -   `webpack.config.js` 파일을 위 내용으로 생성합니다.
    -   `src` 디렉토리를 생성하고 `index.js`, `utils.js`, `index.html`, `style.css` 파일을 위 내용으로 생성합니다.

2.  **의존성 설치**:
    ```bash
    npm install
    ```
    -   `package.json`에 정의된 모든 개발 의존성을 설치합니다.

3.  **개발 서버 시작**:
    ```bash
    npm start
    ```
    -   Webpack 개발 서버가 시작되고 브라우저가 자동으로 열립니다.
    -   개발자 도구(F12)의 Network 탭에서 초기 로드 시 `utils.js` 모듈이 로드되지 않는 것을 확인합니다.
    -   'Load Utilities' 버튼을 클릭하면 `utils.js` 모듈이 동적으로 로드되는 것을 Network 탭에서 확인할 수 있습니다.

4.  **프로덕션 빌드**:
    ```bash
    npm run build
    ```
    -   `dist` 디렉토리에 번들 파일들이 생성됩니다.
    -   `dist` 디렉토리를 보면 `main.[contenthash].js`, `vendors.[contenthash].js`, `[chunk-id].[contenthash].js` (`utils.js`에 대한 청크) 등 여러 개의 JavaScript 파일이 생성된 것을 확인할 수 있습니다.
    -   이것은 코드 스플리팅이 성공적으로 적용되었음을 의미합니다.

## 나쁜 예시와 좋은 예시 (개념)

`webpack.config.js`, `src/index.js`, `src/utils.js` 파일 내의 주석을 참조하여, Webpack 성능 최적화 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 코드 스플리팅, 지연 로딩, 캐싱은 현대 웹 애플리케이션의 초기 로딩 속도와 사용자 경험을 크게 향상시키는 데 필수적인 기술입니다.

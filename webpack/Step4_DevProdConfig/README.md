# Step4: Webpack 개발 및 프로덕션 환경 설정

이 디렉토리는 Webpack 설정을 개발(development) 및 프로덕션(production) 환경에 맞게 분리하고, `webpack-merge`를 사용하여 공통 설정을 효율적으로 관리하는 방법을 학습하기 위한 예제 코드입니다.

## 학습 목표

-   `webpack-merge`를 이용한 Webpack 설정 파일 분리 (`webpack.common.js`, `webpack.dev.js`, `webpack.prod.js`)
-   개발 환경에 맞는 설정 (`devtool`, `devServer`, `HotModuleReplacementPlugin`)
-   프로덕션 환경에 맞는 최적화 설정 (`mode: 'production'`, `optimization`, `TerserPlugin`, `CssMinimizerPlugin`)
-   스크립트를 이용한 환경별 빌드 실행

## 프로젝트 구조

```
webpack/Step4_DevProdConfig/
├── package.json              # 프로젝트 메타데이터 및 의존성 정의
├── webpack.common.js         # 공통 Webpack 설정
├── webpack.dev.js            # 개발 환경 전용 Webpack 설정
├── webpack.prod.js           # 프로덕션 환경 전용 Webpack 설정
└── src/
    ├── index.js              # 엔트리 포인트 JavaScript 파일
    ├── index.html            # HtmlWebpackPlugin을 위한 템플릿 HTML 파일
    └── style.css             # 번들링될 CSS 파일
└── README.md
```

## 파일 설명

-   **`package.json`**:
    -   `devDependencies`: `webpack`, `webpack-cli`, `webpack-dev-server`, `html-webpack-plugin`, `mini-css-extract-plugin`, `css-loader`, `style-loader`, `clean-webpack-plugin` 외에 `webpack-merge`, `terser-webpack-plugin`, `css-minimizer-webpack-plugin` 등 `webpack.prod.js`에서 사용할 패키지가 추가됩니다.
    -   `scripts`:
        -   `start`: `webpack.dev.js` 설정을 사용하여 개발 서버를 시작합니다.
        -   `build`: `webpack.prod.js` 설정을 사용하여 프로덕션 빌드를 수행합니다.

-   **`webpack.common.js`**:
    -   `entry`, `output`, `module.rules` (CSS 로더), `plugins` (`CleanWebpackPlugin`, `HtmlWebpackPlugin`, `MiniCssExtractPlugin`) 등 개발 및 프로덕션 환경에서 공통으로 사용되는 Webpack 설정을 정의합니다.
    -   `output.filename`에 `[name].[contenthash].js`를 사용하여 캐싱을 위한 파일 해시를 포함합니다.

-   **`webpack.dev.js`**:
    -   `webpack-merge`를 사용하여 `webpack.common.js`를 병합합니다.
    -   `mode: 'development'`: 개발 모드로 설정합니다.
    -   `devtool: 'inline-source-map'`: 개발 중 디버깅을 용이하게 하기 위해 소스 맵을 생성합니다.
    -   `devServer`: 개발 서버 설정을 포함합니다. `hot: true`로 HMR (Hot Module Replacement)을 활성화합니다.
    -   `plugins`: `webpack.HotModuleReplacementPlugin`을 추가하여 HMR을 활성화합니다.

-   **`webpack.prod.js`**:
    -   `webpack-merge`를 사용하여 `webpack.common.js`를 병합합니다.
    -   `mode: 'production'`: 프로덕션 모드로 설정합니다.
    -   `devtool: 'source-map'`: 프로덕션에서도 소스 맵을 생성하지만, 별도의 파일로 생성하여 배포 시점에 관리할 수 있습니다.
    -   `optimization`:
        -   `minimize: true`: 번들 파일 압축을 활성화합니다.
        -   `minimizer`: `TerserPlugin` (JavaScript 압축)과 `CssMinimizerPlugin` (CSS 압축)을 사용하여 번들 크기를 최소화합니다.
    -   `plugins`: `webpack.DefinePlugin`을 사용하여 `process.env.NODE_ENV`를 `production`으로 설정하여 코드 내의 개발 관련 코드가 트리 쉐이킹되도록 합니다.

-   **`src/index.js`**:
    -   `process.env.NODE_ENV` 값을 기반으로 다른 메시지를 표시하여 개발/프로덕션 빌드의 차이를 시연합니다.

-   **`src/index.html`**:
    -   `HtmlWebpackPlugin`이 사용할 템플릿 HTML 파일입니다.

-   **`src/style.css`**:
    -   `index.js`에서 임포트되는 간단한 CSS 파일입니다.

## 설정 및 실행 방법

`webpack/Step4_DevProdConfig` 디렉토리에서 터미널을 열고 다음 명령어를 실행합니다.

1.  **프로젝트 준비**:
    -   `webpack.common.js`, `webpack.dev.js`, `webpack.prod.js` 파일을 위 내용으로 생성합니다.
    -   `src` 디렉토리를 생성하고 `index.js`, `index.html`, `style.css` 파일을 위 내용으로 생성합니다.

2.  **의존성 설치**:
    ```bash
    npm install
    ```
    -   `package.json`에 정의된 모든 개발 의존성을 설치합니다.

3.  **개발 서버 시작**:
    ```bash
    npm start
    ```
    -   `webpack.dev.js` 설정이 적용되어 개발 서버가 시작됩니다. 브라우저에서 "Environment: development" 메시지가 표시되고, 개발자 도구에서 `inline-source-map`이 적용된 것을 확인할 수 있습니다.

4.  **프로덕션 빌드**:
    ```bash
    npm run build
    ```
    -   `webpack.prod.js` 설정이 적용되어 프로덕션 빌드가 수행됩니다.
    -   `dist` 디렉토리에 생성된 번들 파일(JS, CSS)은 압축되고 최적화된 상태로 생성됩니다.
    -   `dist/index.html` 파일을 웹 브라우저로 열면 "Environment: production" 메시지가 표시되는 것을 확인할 수 있습니다.

## 나쁜 예시와 좋은 예시 (개념)

`webpack.common.js`, `webpack.dev.js`, `webpack.prod.js` 파일 내의 주석을 참조하여, Webpack 개발/프로덕션 환경 설정 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 설정을 환경별로 분리하고 `webpack-merge`를 사용하는 것은 대규모 프로젝트의 빌드 관리 효율성과 유지보수성을 크게 향상시킵니다.

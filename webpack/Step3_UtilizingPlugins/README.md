# Step3: Webpack 플러그인 (Plugins) 활용

이 디렉토리는 Webpack의 플러그인을 활용하여 빌드 프로세스의 다양한 측면을 제어하고 최적화하는 방법을 학습하기 위한 예제 코드입니다.

## 학습 목표

-   `HtmlWebpackPlugin`을 이용한 HTML 파일 자동 생성 및 번들 삽입
-   `MiniCssExtractPlugin`을 이용한 CSS 파일 별도 추출
-   `CleanWebpackPlugin`을 이용한 빌드 디렉토리 정리
-   `DefinePlugin`을 이용한 환경 변수 주입 및 전역 상수 정의
-   플러그인과 로더의 역할 차이 이해

## 프로젝트 구조

```
webpack/Step3_UtilizingPlugins/
├── package.json              # 프로젝트 메타데이터 및 의존성 정의
├── webpack.config.js         # Webpack 설정 파일
└── src/
    ├── index.js              # 엔트리 포인트 JavaScript 파일
    ├── index.html            # HtmlWebpackPlugin을 위한 템플릿 HTML 파일
    └── style.css             # 번들링될 CSS 파일
└── README.md
```

## 파일 설명

-   **`package.json`**:
    -   `devDependencies`: `webpack`, `webpack-cli`, `webpack-dev-server` 외에 `html-webpack-plugin`, `mini-css-extract-plugin`, `css-loader`, `clean-webpack-plugin` 등 다양한 플러그인 및 관련 로더가 추가됩니다.

-   **`webpack.config.js`**:
    -   **`module.rules`**:
        -   `{ test: /\.css$/i, use: [MiniCssExtractPlugin.loader, 'css-loader'] }`: CSS 파일을 처리합니다. `style-loader` 대신 `MiniCssExtractPlugin.loader`를 사용하여 CSS를 JavaScript 번들 내에 포함하는 대신 별도의 `.css` 파일로 추출합니다.
    -   **`plugins`**:
        -   `CleanWebpackPlugin`: 빌드 전 `dist` 디렉토리의 모든 내용을 정리하여 이전 빌드 결과물로 인한 문제를 방지합니다. (Webpack 5부터는 `output.clean: true` 옵션으로 대체 가능)
        -   `HtmlWebpackPlugin`: `src/index.html` 파일을 템플릿으로 사용하여 `dist` 폴더에 `index.html` 파일을 생성하고, 번들된 JavaScript 및 CSS 파일을 `<script>` 태그와 `<link>` 태그로 자동으로 삽입합니다.
        -   `MiniCssExtractPlugin`: JavaScript 번들 내에 포함된 CSS를 별도의 `.css` 파일로 추출합니다. 이 플러그인은 `module.rules`에서 `MiniCssExtractPlugin.loader`와 함께 사용되어야 합니다.
        -   `webpack.DefinePlugin`: 컴파일 시점에 전역 상수를 정의하고, 코드에서 이 상수를 사용할 수 있도록 합니다. `process.env.NODE_ENV`, `process.env.API_BASE_URL`, `APP_VERSION`과 같은 값들을 주입합니다.

-   **`src/index.js`**:
    -   `import './style.css';`: `style.css` 파일을 임포트합니다.
    -   `DefinePlugin`으로 주입된 전역 상수 (`APP_VERSION`, `process.env.NODE_ENV`, `process.env.API_BASE_URL`)를 사용하여 동적인 콘텐츠를 생성합니다.

-   **`src/index.html`**:
    -   `HtmlWebpackPlugin`이 사용할 템플릿 HTML 파일입니다.

-   **`src/style.css`**:
    -   `index.js`에서 임포트되는 간단한 CSS 파일입니다.

## 설정 및 실행 방법

`webpack/Step3_UtilizingPlugins` 디렉토리에서 터미널을 열고 다음 명령어를 실행합니다.

1.  **프로젝트 준비**:
    -   `webpack.config.js` 파일을 위 내용으로 생성합니다.
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
    -   Webpack 개발 서버가 시작되고 브라우저가 자동으로 열립니다. `DefinePlugin`에 의해 주입된 정보와 `MiniCssExtractPlugin`에 의해 별도 파일로 추출된 CSS가 적용된 페이지를 확인할 수 있습니다.
    -   개발자 도구(F12)의 Sources 탭에서 번들된 CSS가 별도의 `.css` 파일로 존재하는 것을 확인합니다.

4.  **프로덕션 빌드**:
    ```bash
    npm run build
    ```
    -   `dist` 디렉토리가 정리된 후 (`CleanWebpackPlugin` 또는 `output.clean: true`에 의해), 번들된 JavaScript 파일 (`bundle.js`)과 CSS 파일 (`[name].[contenthash].css`), 그리고 이들을 포함하는 `index.html` 파일이 생성됩니다.
    -   `dist/index.html` 파일을 웹 브라우저로 열어 번들된 애플리케이션이 올바르게 동작하는지 확인할 수 있습니다.

## 나쁜 예시와 좋은 예시 (개념)

`webpack.config.js` 파일 내의 주석을 참조하여, Webpack 플러그인 활용 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 플러그인은 Webpack 빌드 프로세스의 전반적인 흐름과 결과물에 큰 영향을 미치므로, 각 플러그인의 역할을 명확히 이해하고 적절히 활용하는 것이 중요합니다.

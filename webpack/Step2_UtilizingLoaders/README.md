# Step2: Webpack 로더 (Loaders) 활용

이 디렉토리는 Webpack의 로더를 활용하여 JavaScript (ES6+), CSS, SCSS, 이미지, 폰트 파일과 같은 다양한 유형의 리소스를 처리하는 방법을 학습하기 위한 예제 코드입니다.

## 학습 목표

-   `babel-loader`를 이용한 ES6+ JavaScript 트랜스파일링
-   `css-loader`와 `style-loader`를 이용한 CSS 번들링
-   `sass-loader`를 이용한 SCSS/Sass 컴파일 및 번들링
-   Webpack 5의 `Asset Modules`를 이용한 이미지 및 폰트 파일 처리

## 프로젝트 구조

```
webpack/Step2_UtilizingLoaders/
├── package.json              # 프로젝트 메타데이터 및 의존성 정의
├── webpack.config.js         # Webpack 설정 파일
└── src/
    ├── index.js              # 엔트리 포인트 JavaScript 파일
    ├── index.html            # HtmlWebpackPlugin을 위한 템플릿 HTML 파일
    ├── style.css             # 번들링될 CSS 파일
    ├── style.scss            # 번들링될 SCSS 파일
    ├── image.png             # 번들링될 이미지 파일 (더미)
    └── font.ttf              # 번들링될 폰트 파일 (더미)
└── README.md
```

## 파일 설명

-   **`package.json`**:
    -   `devDependencies`: `webpack`, `webpack-cli`, `webpack-dev-server`, `html-webpack-plugin` 외에 `babel-loader`, `@babel/core`, `@babel/preset-env`, `css-loader`, `style-loader`, `sass-loader`, `sass` 등 다양한 로더 및 관련 패키지가 추가됩니다.

-   **`webpack.config.js`**:
    -   **`module.rules`**:
        -   `{ test: /\.js$/, use: 'babel-loader' }`: `babel-loader`를 사용하여 `.js` 파일을 처리하고 ES6+ 문법을 이전 JavaScript 버전으로 트랜스파일링합니다.
        -   `{ test: /\.css$/i, use: ['style-loader', 'css-loader'] }`: `.css` 파일을 처리합니다.
        -   `{ test: /\.s[ac]ss$/i, use: ['style-loader', 'css-loader', 'sass-loader'] }`: `.scss` 또는 `.sass` 파일을 처리합니다. `sass-loader`가 Sass를 CSS로 컴파일한 후, `css-loader`와 `style-loader`가 처리합니다.
        -   `{ test: /\.(png|svg|jpg|jpeg|gif)$/i, type: 'asset/resource' }`: 이미지 파일을 처리합니다. Webpack 5의 `Asset Modules` 중 `asset/resource` 타입을 사용하여 파일을 별도의 번들로 내보냅니다.
        -   `{ test: /\.(woff|woff2|eot|ttf|otf)$/i, type: 'asset/resource' }`: 폰트 파일을 처리합니다. `asset/resource` 타입을 사용하여 파일을 별도의 번들로 내보냅니다.

-   **`src/index.js`**:
    -   `style.css`, `style.scss`, `image.png`, `font.ttf` 파일을 임포트하여 각 로더가 어떻게 작동하는지 보여줍니다.
    -   ES6+ 문법(화살표 함수, `const`)을 사용합니다.
    -   임포트된 이미지(`WebpackLogo`)를 `<img>` 태그에 `src`로 할당합니다.
    -   폰트 파일을 로드하여 사용자 정의 폰트를 HTML 요소에 적용하는 예시를 포함합니다.

-   **`src/index.html`**:
    -   `HtmlWebpackPlugin`이 사용할 템플릿 HTML 파일입니다.

-   **`src/style.css`**:
    -   `index.js`에서 임포트되는 간단한 CSS 파일입니다.

-   **`src/style.scss`**:
    -   `index.js`에서 임포트되는 간단한 SCSS 파일입니다. `$primary-color`, `&:hover`와 같은 Sass 문법을 사용합니다.

-   **`src/image.png`**:
    -   로더 테스트를 위한 더미 이미지 파일입니다.

-   **`src/font.ttf`**:
    -   로더 테스트를 위한 더미 폰트 파일입니다.

## 설정 및 실행 방법

`webpack/Step2_UtilizingLoaders` 디렉토리에서 터미널을 열고 다음 명령어를 실행합니다.

1.  **프로젝트 준비**:
    -   `webpack.config.js` 파일을 위 내용으로 생성합니다.
    -   `src` 디렉토리를 생성하고 `index.js`, `index.html`, `style.css`, `style.scss`, `image.png`, `font.ttf` 파일을 위 내용으로 생성합니다. (이미지 및 폰트 파일은 더미로 대체 가능)

2.  **의존성 설치**:
    ```bash
    npm install
    ```
    -   `package.json`에 정의된 모든 개발 의존성을 설치합니다.

3.  **개발 서버 시작**:
    ```bash
    npm start
    ```
    -   Webpack 개발 서버가 시작되고 브라우저가 자동으로 열립니다. `index.js`, `style.css`, `style.scss`, `image.png`, `font.ttf`가 모두 번들링되어 웹 페이지에 표시되는 것을 확인할 수 있습니다.
    -   개발자 도구(F12)를 통해 CSS 및 이미지, 폰트가 올바르게 로드되었는지 확인합니다.

4.  **프로덕션 빌드**:
    ```bash
    npm run build
    ```
    -   `dist` 디렉토리에 번들된 JavaScript 파일, CSS 파일, 이미지 파일, 폰트 파일이 생성됩니다. `Asset Modules`에 의해 이미지와 폰트가 `assets/images` 및 `assets/fonts` 디렉토리 아래에 생성되는 것을 확인할 수 있습니다.

## 나쁜 예시와 좋은 예시 (개념)

`webpack.config.js` 파일 내의 주석을 참조하여, Webpack 로더 활용 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 각 로더의 역할을 명확히 이해하고, 파일 유형에 맞는 로더를 적절히 설정하는 것은 효율적인 번들링과 애플리케이션의 호환성을 보장하는 데 중요합니다.

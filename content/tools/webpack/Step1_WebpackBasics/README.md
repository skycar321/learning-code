# Step1: Webpack 기본 개념 및 시작

이 디렉토리는 Webpack의 기본 개념과 설치, 그리고 간단한 빌드 설정 방법을 학습하기 위한 예제 코드입니다.

## 학습 목표

-   Webpack의 핵심 개념 (`Entry`, `Output`, `Loader`, `Plugin`, `Mode`) 이해
-   간단한 `webpack.config.js` 파일 작성
-   `webpack-dev-server`를 이용한 개발 서버 설정
-   Webpack을 이용한 JavaScript 및 CSS 파일 번들링

## 프로젝트 구조

```
webpack/Step1_WebpackBasics/
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
    -   `devDependencies`: `webpack`, `webpack-cli`, `webpack-dev-server` 등 Webpack 관련 필수 패키지를 정의합니다.
    -   `scripts`:
        -   `start`: `webpack-dev-server`를 개발 모드로 실행하고 브라우저를 자동으로 엽니다.
        -   `build`: `webpack`을 프로덕션 모드로 실행하여 번들 파일을 생성합니다.

-   **`webpack.config.js`**:
    -   **`entry: './src/index.js'`**: Webpack이 빌드를 시작할 엔트리 포인트를 `src/index.js`로 지정합니다.
    -   **`output`**:
        -   `filename: 'bundle.js'`: 번들될 JavaScript 파일의 이름을 `bundle.js`로 설정합니다.
        -   `path: path.resolve(__dirname, 'dist')`: 번들 파일이 생성될 디렉토리를 프로젝트 루트의 `dist` 폴더로 지정합니다.
        -   `clean: true`: 새로운 빌드 전에 `dist` 폴더의 이전 내용을 정리합니다.
    -   **`mode: 'development'`**: 빌드 모드를 개발 모드로 설정합니다. 프로덕션 모드로 변경하면 코드 압축 등 프로덕션 최적화가 적용됩니다.
    -   **`devServer`**:
        -   `static: './dist'`: 개발 서버가 `dist` 폴더의 정적 파일을 제공하도록 설정합니다.
        -   `port: 8080`, `open: true`: 서버 포트를 8080으로 설정하고 자동으로 브라우저를 엽니다.
    -   **`module.rules`**:
        -   `test: /\.css$/i, use: ['style-loader', 'css-loader']`: `.css` 확장자를 가진 파일을 처리하기 위한 로더를 정의합니다. `css-loader`는 CSS를 CommonJS 모듈로 변환하고, `style-loader`는 이 CSS를 DOM에 주입합니다.
    -   **`plugins`**:
        -   `HtmlWebpackPlugin`: `src/index.html` 파일을 템플릿으로 사용하여 `dist` 폴더에 `index.html` 파일을 생성하고, 번들된 JavaScript 파일을 자동으로 `<script>` 태그로 삽입합니다.

-   **`src/index.js`**:
    -   `import './style.css';`: `style.css` 파일을 임포트합니다. Webpack 로더에 의해 이 CSS가 애플리케이션에 적용됩니다.
    -   간단한 JavaScript 코드를 통해 DOM 엘리먼트를 생성하고 웹 페이지에 추가합니다.

-   **`src/index.html`**:
    -   `HtmlWebpackPlugin`이 사용할 템플릿 HTML 파일입니다.

-   **`src/style.css`**:
    -   `index.js`에서 임포트되는 간단한 CSS 파일입니다.

## 설정 및 실행 방법

`webpack/Step1_WebpackBasics` 디렉토리에서 터미널을 열고 다음 명령어를 실행합니다.

1.  **프로젝트 준비**:
    -   `webpack.config.js` 파일을 위 내용으로 생성합니다.
    -   `src` 디렉토리를 생성하고 `index.js`, `index.html`, `style.css` 파일을 위 내용으로 생성합니다.

2.  **의존성 설치**:
    ```bash
    npm install
    ```
    -   `package.json`에 정의된 `webpack`, `webpack-cli`, `webpack-dev-server`, `html-webpack-plugin`, `css-loader`, `style-loader` 등의 의존성을 설치합니다.

3.  **개발 서버 시작**:
    ```bash
    npm start
    ```
    -   Webpack 개발 서버가 8080번 포트에서 시작되고 브라우저가 자동으로 열립니다. `Hello from Webpack!` 메시지와 스타일이 적용된 페이지를 확인할 수 있습니다.
    -   `src/index.js` 또는 `src/style.css` 파일을 수정하고 저장하면, 브라우저가 자동으로 새로고침되어 변경 사항이 즉시 반영됩니다.

4.  **프로덕션 빌드**:
    ```bash
    npm run build
    ```
    -   프로젝트 루트에 `dist` 디렉토리가 생성되고, 그 안에 `bundle.js` 및 `index.html` 파일이 생성됩니다.
    -   `dist/index.html` 파일을 웹 브라우저로 열어 번들된 애플리케이션이 올바르게 동작하는지 확인할 수 있습니다.

## 나쁜 예시와 좋은 예시 (개념)

`webpack.config.js` 파일 내의 주석을 참조하여, Webpack 기본 설정 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. Webpack의 핵심 개념을 명확히 이해하고 `webpack.config.js`를 올바르게 구성하는 것은 효율적인 프론트엔드 빌드 시스템을 구축하는 첫걸음입니다.

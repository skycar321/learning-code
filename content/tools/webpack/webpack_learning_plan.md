# Webpack 학습 계획

## 개요 (Overview)
Webpack은 JavaScript 애플리케이션을 위한 정적 모듈 번들러입니다. 최신 웹 개발 환경에서 프론트엔드 리소스(JavaScript, CSS, 이미지 등)를 효율적으로 번들링하고 최적화하여 브라우저에서 로드 가능한 형태로 만들어주는 핵심 도구입니다. 이 학습 계획은 Webpack의 기본 개념부터 설정, 로더 및 플러그인 활용, 그리고 실무에 필요한 성능 최적화 전략까지 다루어, 견고하고 효율적인 프론트엔드 빌드 시스템을 구축하는 역량을 키우는 것을 목표로 합니다.

## 학습 목표 (Learning Objectives)
*   Webpack의 핵심 개념 및 동작 방식 이해
*   Webpack 설정 파일 (`webpack.config.js`) 작성 및 관리
*   로더(Loader)와 플러그인(Plugin)을 활용한 다양한 리소스 처리
*   개발 및 프로덕션 환경에 맞는 최적화 전략 적용
*   모듈 번들링 및 코드 스플리팅을 통한 성능 개선

## 학습 내용 (Learning Content)

### 1단계: Webpack 기본 개념 및 시작 (Webpack Basics & Getting Started)
*   모듈 번들러란 무엇인가? (What is a Module Bundler?) - Webpack의 역할
*   Webpack 핵심 개념 (Webpack Core Concepts) - Entry, Output, Loader, Plugin, Mode
*   Webpack 설치 및 기본 사용법 (Installation & Basic Usage)
*   간단한 `webpack.config.js` 파일 작성 (Writing a Simple `webpack.config.js`)
*   개발 서버 설정 (Development Server Setup) - `webpack-dev-server`

### 2단계: 로더 (Loaders) 활용 (Utilizing Loaders)
*   JavaScript(ES6+) 로더 (JavaScript (ES6+) Loaders) - Babel (`babel-loader`)
*   CSS 로더 (CSS Loaders) - `css-loader`, `style-loader`, `mini-css-extract-plugin`
*   SCSS/Sass 로더 (SCSS/Sass Loaders) - `sass-loader`
*   이미지 로더 (Image Loaders) - `file-loader`, `url-loader`, `asset modules` (Webpack 5+)
*   폰트 로더 (Font Loaders)
*   타입스크립트 로더 (TypeScript Loaders) - `ts-loader`

### 3단계: 플러그인 (Plugins) 활용 (Utilizing Plugins)
*   HTML 파일 자동 생성 (Automatic HTML File Generation) - `HtmlWebpackPlugin`
*   CSS 파일 추출 (Extracting CSS Files) - `MiniCssExtractPlugin`
*   환경 변수 설정 (Setting Environment Variables) - `DefinePlugin`
*   클린 빌드 (Clean Builds) - `CleanWebpackPlugin`
*   번들 분석 (Bundle Analysis) - `WebpackBundleAnalyzer`
*   서드파티 라이브러리 분리 (Splitting Third-party Libraries) - `DllPlugin`

### 4단계: 개발 및 프로덕션 환경 설정 (Development & Production Configuration)
*   `mode` 옵션 이해 (Understanding `mode` Option) - `development` vs `production`
*   개발 환경 설정 (Development Configuration) - Source Maps, Hot Module Replacement (HMR)
*   프로덕션 환경 설정 (Production Configuration) - 코드 압축 (Minification), 트리 쉐이킹 (Tree Shaking)
*   설정 파일 분리 (Separating Configuration Files) - `webpack-merge`
*   환경 변수를 이용한 동적 설정 (Dynamic Configuration with Environment Variables)

### 5단계: 성능 최적화 및 고급 기능 (Performance Optimization & Advanced Features)
*   코드 스플리팅 (Code Splitting) - `import()` 동적 임포트, `optimization.splitChunks`
*   캐싱 (Caching) 전략 - Content Hashing
*   Lazy Loading (지연 로딩)
*   외부(External) 라이브러리 사용 (Using External Libraries) - CDN 활용
*   Webpack 5의 새로운 기능 (New Features in Webpack 5) - Module Federation
*   Webpack 설정 디버깅 및 문제 해결 (Debugging & Troubleshooting Webpack Configurations)

## 예상 학습 시간 (Estimated Learning Time)
*   각 단계별 3-6시간 (총 15-30시간)

## 실습 과제 (Practical Exercises)
*   React/Vue 프로젝트에 Webpack을 직접 설정하여 빌드 시스템 구축 (Set up Webpack for a React/Vue project from scratch)
*   JavaScript, CSS, 이미지 파일을 로더를 이용하여 처리 (Process JS, CSS, Image files with loaders)
*   `HtmlWebpackPlugin`과 `MiniCssExtractPlugin`을 활용하여 빌드 결과물 생성 (Generate build output with HtmlWebpackPlugin & MiniCssExtractPlugin)
*   개발 및 프로덕션 환경에 맞는 Webpack 설정 분리 (Separate Webpack configs for dev & prod environments)
*   코드 스플리팅을 적용하여 번들 크기 최적화 (Optimize bundle size with code splitting)

## 참고 자료 (References)
*   Webpack 공식 문서 (Webpack Official Documentation)
*   Webpack from Scratch by Sean Larkin (Webpack Core Team)
*   Webpack 5: The Ultimate Guide by Zoltán Szabó
*   웹팩 핸드북 by Toby Lee

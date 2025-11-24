// webpack/Step1_WebpackBasics/webpack.config.js
// Webpack 학습 계획 - 1단계: Webpack 기본 개념 및 시작
// 이 파일은 Webpack의 기본 설정 파일인 `webpack.config.js` 예시입니다.
// `Entry`, `Output`, `Loader`, `Plugin`, `Mode`와 같은 Webpack 핵심 개념을 보여줍니다.
//
// Webpack은 JavaScript 모듈 번들러로, 프론트엔드 리소스(JS, CSS, 이미지 등)를
// 효율적으로 번들링하고 최적화하여 브라우저에서 로드 가능한 형태로 만들어줍니다.

const path = require('path'); // Node.js `path` 모듈 임포트
const HtmlWebpackPlugin = require('html-webpack-plugin'); // HTML 파일을 생성하고 번들된 JS를 삽입하는 플러그인

module.exports = {
  // -----------------------------------------------------------------------------
  // 학습 포인트 1: `entry` (엔트리 포인트)
  // - Webpack이 애플리케이션 빌드를 시작하는 지점입니다.
  // - 모듈 의존성 그래프를 구축할 메인 JavaScript 파일을 지정합니다.
  // -----------------------------------------------------------------------------
  entry: './src/index.js', // './src/index.js' 파일을 엔트리 포인트로 설정

  // -----------------------------------------------------------------------------
  // 학습 포인트 2: `output` (아웃풋)
  // - Webpack이 번들된 결과물(번들 파일)을 어디에, 어떤 이름으로 생성할지 지정합니다.
  // - `path`: 번들 파일이 생성될 디렉토리의 절대 경로.
  // - `filename`: 번들 파일의 이름. `[name]`은 엔트리 이름, `[contenthash]`는 파일 내용의 해시 값.
  // -----------------------------------------------------------------------------
  output: {
    filename: 'bundle.js', // 번들 파일 이름
    path: path.resolve(__dirname, 'dist'), // 번들 파일이 생성될 디렉토리
    clean: true, // 이전 빌드 결과물 삭제 (Webpack 5부터 지원)
    // 나쁜 예시: `clean: true`를 설정하지 않고 이전 빌드 결과물이 계속 남아있게 하는 것.
    // - 캐싱 문제나 예상치 못한 빌드 오류를 유발할 수 있습니다.
  },

  // -----------------------------------------------------------------------------
  // 학습 포인트 3: `mode` (모드)
  // - `development`, `production`, `none` 세 가지 모드가 있습니다.
  // - 각 모드에 따라 Webpack이 기본적으로 제공하는 최적화가 달라집니다.
  //   - `development`: 개발에 최적화 (빠른 빌드, 디버깅 용이).
  //   - `production`: 프로덕션에 최적화 (코드 압축, 트리 쉐이킹 등).
  // - CLI에서 `--mode` 옵션으로 설정하거나 `package.json`의 스크립트에서 설정 가능.
  // -----------------------------------------------------------------------------
  mode: 'development', // 개발 모드로 설정 (빠른 빌드, 디버깅 용이)

  // -----------------------------------------------------------------------------
  // 학습 포인트 4: `devServer` (개발 서버)
  // - `webpack-dev-server`를 사용하여 개발 중 웹 애플리케이션을 호스팅하고,
  // - 코드 변경 시 자동으로 브라우저를 새로고침하거나 HMR (Hot Module Replacement) 기능을 제공합니다.
  // -----------------------------------------------------------------------------
  devServer: {
    static: './dist', // 정적 파일을 제공할 디렉토리
    port: 8080, // 개발 서버 포트
    open: true, // 서버 시작 후 자동으로 브라우저 열기
    hot: true, // HMR (Hot Module Replacement) 활성화 (선택 사항)
    historyApiFallback: true, // SPA (Single Page Application) 라우팅 지원
  },

  // -----------------------------------------------------------------------------
  // 학습 포인트 5: `module.rules` (로더)
  // - Webpack은 JavaScript만 이해하므로, CSS, 이미지, TypeScript 등 다른 유형의
  //   파일을 모듈로 처리하려면 로더(Loader)를 사용해야 합니다.
  // - `test`: 어떤 파일을 처리할지 정규식으로 지정합니다.
  // - `use`: 해당 파일을 처리할 로더를 지정합니다.
  // -----------------------------------------------------------------------------
  module: {
    rules: [
      {
        test: /\.css$/i, // .css 확장자를 가진 파일 처리
        use: ['style-loader', 'css-loader'], // `style-loader`는 CSS를 DOM에 주입, `css-loader`는 CSS를 JavaScript 모듈로 변환
        // 나쁜 예시: CSS 파일을 JavaScript 모듈로 임포트하지 않고 HTML에 직접 `<style>` 태그로 포함하는 것.
        // - 코드 관리의 비효율성, 번들링 및 최적화의 어려움을 유발합니다.
      },
    ],
  },

  // -----------------------------------------------------------------------------
  // 학습 포인트 6: `plugins` (플러그인)
  // - 로더가 특정 파일 유형을 변환하는 데 사용되는 반면, 플러그인은 번들링 프로세스의
  //   더 넓은 범위에서 작업을 수행합니다 (예: 번들 최적화, 에셋 관리, 환경 변수 주입 등).
  // -----------------------------------------------------------------------------
  plugins: [
    new HtmlWebpackPlugin({
      title: 'Webpack Basic App', // HTML 파일의 <title> 태그 설정
      template: './src/index.html', // 템플릿으로 사용할 HTML 파일 지정
    }),
    // 나쁜 예시: `HtmlWebpackPlugin` 없이 HTML 파일을 수동으로 만들고 번들된 JS 파일을
    // - 직접 `<script>` 태그로 포함하는 것.
    // - 번들 파일 이름이 변경될 때마다 HTML 파일도 수동으로 수정해야 하므로 번거롭습니다.
  ],
};

/*
이 코드를 실행하려면:

1. `package.json` 파일과 함께 `webpack/Step1_WebpackBasics` 디렉토리에 이 파일을 `webpack.config.js`로 저장.
2. `webpack/Step1_WebpackBasics` 디렉토리에 `src` 서브 디렉토리를 생성하고 `index.js`, `index.html` 파일 생성.
3. `npm install` 명령으로 `package.json`에 정의된 의존성 설치.
4. `npm start` 명령으로 개발 서버 시작.
5. `npm run build` 명령으로 프로덕션 빌드.
*/

// webpack/Step2_UtilizingLoaders/webpack.config.js
// Webpack 학습 계획 - 2단계: 로더 (Loaders) 활용
// 이 파일은 다양한 유형의 파일을 처리하기 위한 Webpack 로더 설정을 보여주는 `webpack.config.js` 예시입니다.
// JavaScript (ES6+), CSS, SCSS, 이미지, 폰트 파일 처리를 위한 로더를 설정합니다.

const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
  entry: './src/index.js',
  output: {
    filename: 'bundle.js',
    path: path.resolve(__dirname, 'dist'),
    clean: true,
    assetModuleFilename: 'assets/[name][ext][query]', // Webpack 5 Asset Modules의 출력 파일명 설정
  },
  mode: 'development',
  devServer: {
    static: './dist',
    port: 8080,
    open: true,
    hot: true,
    historyApiFallback: true,
  },
  module: {
    rules: [
      // -----------------------------------------------------------------------------
      // 학습 포인트 1: JavaScript (ES6+) 로더 - Babel
      // - `babel-loader`를 사용하여 ES6+ 문법을 이전 JavaScript 버전으로 트랜스파일링합니다.
      // - `@babel/preset-env`는 어떤 환경에서 실행될지에 따라 필요한 변환을 자동으로 적용합니다.
      // -----------------------------------------------------------------------------
      {
        test: /\.js$/, // .js 확장자를 가진 파일 처리
        exclude: /node_modules/, // node_modules 디렉토리 제외
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env'], // ES6+ 문법 변환
          },
        },
        // 나쁜 예시: `babel-loader` 없이 최신 JavaScript 문법을 그대로 사용하는 것.
        // - 오래된 브라우저나 Node.js 환경에서 호환성 문제가 발생할 수 있습니다.
        // - 모든 타겟 브라우저를 지원하기 위해 `babel-loader`는 필수적입니다.
      },
      // -----------------------------------------------------------------------------
      // 학습 포인트 2: CSS 로더
      // - `css-loader`: CSS 파일을 JavaScript 모듈로 변환합니다.
      // - `style-loader`: 변환된 CSS를 `<style>` 태그로 DOM에 주입합니다.
      // - 로더는 `use` 배열의 역순으로 실행됩니다 (오른쪽에서 왼쪽).
      // -----------------------------------------------------------------------------
      {
        test: /\.css$/i,
        use: ['style-loader', 'css-loader'],
      },
      // -----------------------------------------------------------------------------
      // 학습 포인트 3: SCSS/Sass 로더
      // - `sass-loader`: Sass/SCSS 파일을 CSS로 컴파일합니다.
      // - `sass`: 실제 Sass 컴파일러 (Node.js 기반)
      // - `node-sass`는 더 이상 권장되지 않습니다.
      // -----------------------------------------------------------------------------
      {
        test: /\.s[ac]ss$/i, // .scss 또는 .sass 확장자를 가진 파일 처리
        use: [
          'style-loader', // 3. CSS를 DOM에 주입
          'css-loader',   // 2. CSS를 JavaScript 모듈로 변환
          'sass-loader',  // 1. Sass/SCSS를 CSS로 컴파일
        ],
        // 나쁜 예시: Sass/SCSS 파일을 CSS로 컴파일하지 않고 그대로 임포트하는 것.
        // - Webpack은 Sass를 직접 이해하지 못하므로 빌드 에러가 발생합니다.
      },
      // -----------------------------------------------------------------------------
      // 학습 포인트 4: 이미지/폰트 로더 (Webpack 5 Asset Modules)
      // - Webpack 5부터는 `file-loader`, `url-loader` 대신 `Asset Modules`를 사용하여
      //   이미지, 폰트 등 에셋 파일을 처리합니다.
      // - `type: 'asset/resource'`: 파일을 별도의 파일로 내보내고 URL을 반환. (file-loader와 유사)
      // - `type: 'asset/inline'`: 파일을 Base64 인코딩하여 JavaScript 번들에 삽입. (url-loader와 유사)
      // - `type: 'asset'`: 파일 크기에 따라 resource 또는 inline을 자동으로 선택.
      // -----------------------------------------------------------------------------
      {
        test: /\.(png|svg|jpg|jpeg|gif)$/i, // 이미지 파일 처리
        type: 'asset/resource', // 파일을 별도의 파일로 내보냄
        generator: {
          filename: 'images/[name][ext][query]' // 이미지 파일은 images 디렉토리 아래에 저장
        }
      },
      {
        test: /\.(woff|woff2|eot|ttf|otf)$/i, // 폰트 파일 처리
        type: 'asset/resource',
        generator: {
          filename: 'fonts/[name][ext][query]' // 폰트 파일은 fonts 디렉토리 아래에 저장
        }
        // 나쁜 예시: 큰 이미지나 폰트 파일을 Base64 인코딩하여 번들에 직접 삽입하는 것 (`type: 'asset/inline'`).
        // - 번들 파일 크기가 불필요하게 커져 초기 로딩 속도가 저하됩니다.
        // - 작은 파일(수 KB 이하)에만 `asset/inline` 또는 `asset` 타입을 사용해야 합니다.
      },
      // -----------------------------------------------------------------------------
      // 학습 포인트 5: 타입스크립트 로더 (개념)
      // - `ts-loader` 또는 `awesome-typescript-loader`를 사용하여 TypeScript 파일을 JavaScript로 컴파일합니다.
      // - `tsconfig.json` 파일과 함께 사용됩니다.
      // -----------------------------------------------------------------------------
      // {
      //   test: /\.tsx?$/, // .ts 또는 .tsx 확장자를 가진 파일 처리
      //   use: 'ts-loader',
      //   exclude: /node_modules/,
      // },
    ],
  },
  plugins: [
    new HtmlWebpackPlugin({
      title: 'Webpack Loaders',
      template: './src/index.html',
    }),
  ],
};

/*
이 코드를 실행하려면:

1. `package.json` 파일과 함께 `webpack/Step2_UtilizingLoaders` 디렉토리에 이 파일을 `webpack.config.js`로 저장.
2. `webpack/Step2_UtilizingLoaders` 디렉토리에 `src` 서브 디렉토리를 생성하고 `index.js`, `index.html`, `style.css`, `style.scss`, `image.png`, `font.ttf` 파일 생성.
3. `npm install` 명령으로 `package.json`에 정의된 의존성 설치.
4. `npm start` 명령으로 개발 서버 시작.
5. `npm run build` 명령으로 프로덕션 빌드.
*/

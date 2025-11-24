// webpack/Step3_UtilizingPlugins/webpack.config.js
// Webpack 학습 계획 - 3단계: 플러그인 (Plugins) 활용
// 이 파일은 `HtmlWebpackPlugin`, `MiniCssExtractPlugin`, `DefinePlugin`,
// `CleanWebpackPlugin` 등 Webpack 플러그인을 설정하는 `webpack.config.js` 예시입니다.
//
// 플러그인은 로더가 특정 파일 유형을 변환하는 데 사용되는 반면,
// 번들링 프로세스의 더 넓은 범위에서 작업을 수행합니다.

const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin'); // HTML 파일 생성 및 번들 삽입
const MiniCssExtractPlugin = require('mini-css-extract-plugin'); // CSS 파일을 별도의 파일로 추출
const { CleanWebpackPlugin } = require('clean-webpack-plugin'); // 빌드 전 dist 디렉토리 정리
const webpack = require('webpack'); // Webpack 자체를 임포트 (DefinePlugin 사용)

module.exports = {
  entry: './src/index.js',
  output: {
    filename: 'bundle.js',
    path: path.resolve(__dirname, 'dist'),
    // `clean: true`는 `CleanWebpackPlugin`의 기본 기능을 대체 (Webpack 5부터)
    // clean: true, // 이전 빌드 결과물 삭제 (CleanWebpackPlugin 플러그인과 중복될 수 있으므로 주석 처리)
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
      {
        test: /\.css$/i,
        use: [
          // -----------------------------------------------------------------------------
          // 학습 포인트 1: `MiniCssExtractPlugin.loader`
          // - `style-loader` 대신 `MiniCssExtractPlugin.loader`를 사용하면
          //   CSS를 JavaScript 번들 내부에 포함하는 대신 별도의 `.css` 파일로 추출합니다.
          // - 이는 CSS가 더 빠르게 로드되고 브라우저가 CSS를 병렬로 로드할 수 있게 하여
          //   성능 최적화에 기여합니다.
          // -----------------------------------------------------------------------------
          MiniCssExtractPlugin.loader, // CSS를 별도의 파일로 추출
          'css-loader',                // CSS 파일을 JavaScript 모듈로 변환
        ],
        // 나쁜 예시: 프로덕션 빌드에서도 `style-loader`를 사용하여 CSS를 JavaScript 번들 내에 유지하는 것.
        // - 브라우저가 JavaScript를 파싱한 후에야 CSS가 적용되므로 깜박임(FOUC) 현상이 발생할 수 있고,
        // - 병렬 다운로드가 불가능하여 렌더링을 지연시킵니다.
      },
    ],
  },
  plugins: [
    // -----------------------------------------------------------------------------
    // 학습 포인트 2: `CleanWebpackPlugin`
    // - 빌드 전 `output.path`에 지정된 디렉토리(여기서는 `dist`)의 모든 내용을 정리합니다.
    // - 이전 빌드 결과물로 인한 문제를 방지합니다.
    // - Webpack 5부터는 `output.clean: true` 옵션으로 대체 가능하지만,
    //   `clean-webpack-plugin`은 더 많은 옵션을 제공합니다.
    // -----------------------------------------------------------------------------
    new CleanWebpackPlugin(),

    // -----------------------------------------------------------------------------
    // 학습 포인트 3: `HtmlWebpackPlugin`
    // - HTML 파일을 생성하고, Webpack 번들에 의해 생성된 JavaScript 파일을
    //   `<script>` 태그로 자동으로 삽입합니다.
    // - `template`: 템플릿으로 사용할 HTML 파일 경로.
    // -----------------------------------------------------------------------------
    new HtmlWebpackPlugin({
      title: 'Webpack Plugins App',
      template: './src/index.html', // 템플릿으로 사용할 HTML 파일 지정
      filename: 'index.html', // 생성될 HTML 파일 이름
    }),

    // -----------------------------------------------------------------------------
    // 학습 포인트 4: `MiniCssExtractPlugin`
    // - JavaScript 번들 내에 포함된 CSS를 별도의 `.css` 파일로 추출합니다.
    // - 이 플러그인은 `module.rules`에서 `MiniCssExtractPlugin.loader`와 함께 사용되어야 합니다.
    // -----------------------------------------------------------------------------
    new MiniCssExtractPlugin({
      filename: '[name].[contenthash].css', // 추출될 CSS 파일 이름
      chunkFilename: '[id].css',
    }),

    // -----------------------------------------------------------------------------
    // 학습 포인트 5: `DefinePlugin`
    // - 컴파일 시점에 전역 상수를 정의하고, 코드에서 이 상수를 사용할 수 있도록 합니다.
    // - 환경 변수나 API 엔드포인트 등을 JavaScript 코드에 주입하는 데 유용합니다.
    // -----------------------------------------------------------------------------
    new webpack.DefinePlugin({
      'process.env.NODE_ENV': JSON.stringify(process.env.NODE_ENV || 'development'),
      'process.env.API_BASE_URL': JSON.stringify('http://localhost:3000/api'),
      'APP_VERSION': JSON.stringify('1.0.0'), // 사용자 정의 상수 주입
    }),
    // 나쁜 예시: `DefinePlugin` 없이 환경 변수를 코드에 직접 하드코딩하는 것.
    // - 환경 변경 시마다 코드를 수정하고 재빌드해야 합니다.
    // - 빌드 시점에 환경 변수를 주입하면 유연한 배포가 가능합니다.

    // -----------------------------------------------------------------------------
    // 학습 포인트 6: 번들 분석 (`WebpackBundleAnalyzer`) (개념)
    // - `webpack-bundle-analyzer` 플러그인을 사용하여 번들의 크기를 시각적으로 분석합니다.
    // - 번들 크기를 최적화하고 불필요한 의존성을 찾아내는 데 도움이 됩니다.
    // -----------------------------------------------------------------------------
    // new (require('webpack-bundle-analyzer').WebpackBundleAnalyzerPlugin)(),
  ],
};

/*
이 코드를 실행하려면:

1. `package.json` 파일과 함께 `webpack/Step3_UtilizingPlugins` 디렉토리에 이 파일을 `webpack.config.js`로 저장.
2. `webpack/Step3_UtilizingPlugins` 디렉토리에 `src` 서브 디렉토리를 생성하고 `index.js`, `index.html`, `style.css` 파일 생성.
3. `npm install` 명령으로 `package.json`에 정의된 의존성 설치.
4. `npm start` 명령으로 개발 서버 시작.
5. `npm run build` 명령으로 프로덕션 빌드.
*/

// webpack/Step4_DevProdConfig/webpack.common.js
// Webpack 학습 계획 - 4단계: 개발 및 프로덕션 환경 설정
// 이 파일은 개발(development) 및 프로덕션(production) 환경에서 공통으로 사용될
// Webpack 설정을 정의합니다.
//
// `webpack-merge` 라이브러리를 사용하여 `webpack.dev.js`와 `webpack.prod.js`에서
// 이 공통 설정을 가져와 각 환경에 특화된 설정을 추가합니다.

const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

module.exports = {
  // -----------------------------------------------------------------------------
  // 학습 포인트 1: `entry` (엔트리 포인트)
  // - 공통적으로 애플리케이션 빌드를 시작하는 지점입니다.
  // -----------------------------------------------------------------------------
  entry: './src/index.js',

  // -----------------------------------------------------------------------------
  // 학습 포인트 2: `output` (아웃풋)
  // - 공통적으로 번들된 결과물(번들 파일)을 생성할 위치와 이름을 정의합니다.
  // - `filename`: 캐싱을 위해 `[contenthash]`를 포함하는 것이 좋습니다.
  // - `path`: 번들 파일이 생성될 디렉토리의 절대 경로.
  // -----------------------------------------------------------------------------
  output: {
    filename: '[name].[contenthash].js', // 캐싱을 위해 contenthash 사용 (프로덕션에서 유용)
    path: path.resolve(__dirname, 'dist'),
    clean: true, // 이전 빌드 결과물 삭제
    // 나쁜 예시: 개발 환경에서 `[contenthash]`를 사용하여 불필요하게 파일 이름을 변경하는 것.
    // - 개발 중에는 `[name].js`와 같이 고정된 이름을 사용하여 빠르게 새로고침하는 것이 편리합니다.
  },

  // -----------------------------------------------------------------------------
  // 학습 포인트 3: `module.rules` (로더)
  // - CSS 파일을 처리하기 위한 로더를 정의합니다.
  // - `MiniCssExtractPlugin.loader`를 사용하여 CSS를 별도의 파일로 추출합니다.
  // -----------------------------------------------------------------------------
  module: {
    rules: [
      {
        test: /\.css$/i,
        use: [MiniCssExtractPlugin.loader, 'css-loader'],
      },
    ],
  },

  // -----------------------------------------------------------------------------
  // 학습 포인트 4: `plugins` (플러그인)
  // - `HtmlWebpackPlugin`: HTML 파일을 생성하고 번들된 JS/CSS를 삽입.
  // - `MiniCssExtractPlugin`: CSS를 별도의 파일로 추출.
  // - `CleanWebpackPlugin`: 빌드 전 `dist` 디렉토리 정리.
  // -----------------------------------------------------------------------------
  plugins: [
    new CleanWebpackPlugin(),
    new HtmlWebpackPlugin({
      template: './src/index.html',
    }),
    new MiniCssExtractPlugin({
      filename: '[name].[contenthash].css',
    }),
  ],

  // -----------------------------------------------------------------------------
  // 학습 포인트 5: `resolve`
  // - 모듈을 해석(resolve)하는 방법을 정의합니다 (예: 확장자, 별칭).
  // - `extensions`: 임포트 시 생략 가능한 확장자를 지정합니다.
  // -----------------------------------------------------------------------------
  resolve: {
    extensions: ['.js', '.jsx', '.ts', '.tsx', '.json'], // 임포트 시 확장자 생략 가능
    // alias: { // 모듈 경로 별칭 (절대 경로 임포트)
    //   '@components': path.resolve(__dirname, 'src/components/'),
    // },
  },
};

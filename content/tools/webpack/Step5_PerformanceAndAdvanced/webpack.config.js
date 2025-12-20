// webpack/Step5_PerformanceAndAdvanced/webpack.config.js
// Webpack 학습 계획 - 5단계: 성능 최적화 및 고급 기능
// 이 파일은 Webpack의 코드 스플리팅, 캐싱 전략, 지연 로딩(Lazy Loading) 등
// 성능 최적화 기능과 고급 기능을 보여주는 `webpack.config.js` 예시입니다.
//
// Webpack은 애플리케이션의 초기 로딩 속도를 개선하고, 사용자 경험을 향상시키기 위한
// 다양한 최적화 기능을 제공합니다.

const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const webpack = require('webpack'); // Webpack 자체를 임포트 (DefinePlugin 사용)

module.exports = {
  entry: {
    main: './src/index.js', // 메인 엔트리 포인트
    // another: './src/another.js', // 다른 엔트리 포인트를 추가하여 코드 스플리팅 확인 가능
  },
  output: {
    filename: '[name].[contenthash].js', // 캐싱을 위해 contenthash 사용
    path: path.resolve(__dirname, 'dist'),
    clean: true,
    publicPath: '/', // 에셋 모듈 및 지연 로딩 청크를 위한 공개 URL 경로
  },
  mode: 'production', // 프로덕션 모드로 설정하여 최적화 기능 활성화
  devtool: 'source-map',
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
        use: [MiniCssExtractPlugin.loader, 'css-loader'],
      },
    ],
  },
  plugins: [
    new CleanWebpackPlugin(),
    new HtmlWebpackPlugin({
      title: 'Webpack Performance App',
      template: './src/index.html',
    }),
    new MiniCssExtractPlugin({
      filename: '[name].[contenthash].css',
    }),
    new webpack.DefinePlugin({
      'process.env.NODE_ENV': JSON.stringify('production'),
    }),
  ],
  // -----------------------------------------------------------------------------
  // 학습 포인트 1: `optimization` (최적화)
  // - 프로덕션 빌드의 성능과 번들 크기를 최적화하는 설정을 정의합니다.
  // -----------------------------------------------------------------------------
  optimization: {
    // 1.1. `splitChunks` (코드 스플리팅)
    // - 공통 모듈을 별도의 번들로 분리하여 초기 로딩 시간을 단축하고 캐싱 효율을 높입니다.
    // - `vendors`: `node_modules`에서 가져온 서드파티 라이브러리를 별도의 청크로 분리합니다.
    // - `default`: 여러 청크에서 중복되는 모듈을 분리합니다.
    splitChunks: {
      chunks: 'all', // 모든 청크에 대해 최적화 적용
      cacheGroups: {
        vendor: {
          test: /[\\/]node_modules[\\/]/
, // node_modules 아래에 있는 모듈
          name: 'vendors', // 벤더 청크 파일 이름
          chunks: 'all',
        },
      },
    },
    // 나쁜 예시: `splitChunks` 설정을 누락하여 모든 JavaScript 코드를 하나의 큰 번들로 만드는 것.
    // - 초기 로딩 시간이 길어지고, 서드파티 라이브러리(변경될 가능성이 적음)가 애플리케이션 코드와 함께
    //   번들되어 캐싱 효율이 떨어집니다.
  },
  // -----------------------------------------------------------------------------
  // 학습 포인트 2: 캐싱 (Caching) 전략
  // - `output.filename`에 `[contenthash]`를 사용하여 파일 내용이 변경될 때만
  //   파일 이름이 변경되도록 합니다. 이를 통해 클라이언트 브라우저가 정적 파일을
  //   효율적으로 캐싱할 수 있습니다.
  // - `splitChunks`를 통해 벤더 라이브러리를 별도로 분리하면 벤더 라이브러리의
  //   해시 값이 변경될 가능성이 적어 장기 캐싱에 유리합니다.
  // -----------------------------------------------------------------------------

  // -----------------------------------------------------------------------------
  // 학습 포인트 3: `import()` 동적 임포트 (지연 로딩, Lazy Loading)
  // - 코드 스플리팅과 함께 사용하여 특정 모듈을 필요할 때(예: 사용자 액션) 로드합니다.
  // - `src/index.js`에서 `import('./utils.js')` 예시를 참조하세요.
  // - 이는 번들 크기를 줄이고 초기 로딩 시간을 개선하는 데 매우 효과적입니다.
  // -----------------------------------------------------------------------------

  // -----------------------------------------------------------------------------
  // 학습 포인트 4: `externals` (외부 라이브러리 사용 - CDN 활용) (개념)
  // - 특정 라이브러리를 번들하지 않고, 외부 CDN을 통해 로드하도록 설정합니다.
  // - `html-webpack-plugin`의 `template`에서 CDN 스크립트를 수동으로 추가해야 합니다.
  // - 예시: `externals: { lodash: 'lodash' }`
  // -----------------------------------------------------------------------------
  // externals: {
  //   lodash: 'lodash', // lodash를 번들하지 않고 전역 'lodash' 객체를 사용
  // },

  // -----------------------------------------------------------------------------
  // 학습 포인트 5: Webpack 5의 새로운 기능 (Module Federation) (개념)
  // - 여러 Webpack 빌드가 독립적으로 코드를 공유할 수 있게 하는 기술.
  // - 마이크로프론트엔드 아키텍처에 유용합니다.
  // -----------------------------------------------------------------------------

  // -----------------------------------------------------------------------------
  // 학습 포인트 6: Webpack 설정 디버깅 및 문제 해결 (개념)
  // - `webpack-bundle-analyzer` 플러그인: 번들 내용을 시각적으로 분석하여 최적화 기회 발견.
  // - `webpack --stats verbose` 또는 `webpack-cli analyze`: 상세한 빌드 통계 확인.
  // -----------------------------------------------------------------------------
};

// webpack/Step4_DevProdConfig/webpack.prod.js
// Webpack 학습 계획 - 4단계: 개발 및 프로덕션 환경 설정
// 이 파일은 프로덕션(production) 환경에 특화된 Webpack 설정을 정의합니다.
//
// `webpack-merge`를 사용하여 `webpack.common.js`의 공통 설정을 가져오고,
// 프로덕션 환경에 필요한 최적화(코드 압축, 트리 쉐이킹 등) 설정을 추가합니다.

const { merge } = require('webpack-merge');
const common = require('./webpack.common.js');
const TerserPlugin = require('terser-webpack-plugin'); // JavaScript 압축
const CssMinimizerPlugin = require('css-minimizer-webpack-plugin'); // CSS 압축

module.exports = merge(common, {
  // -----------------------------------------------------------------------------
  // 학습 포인트 1: `mode: 'production'`
  // - 프로덕션 모드로 설정합니다. Webpack이 프로덕션에 최적화된 기본 설정을 적용합니다.
  //   - 코드 압축, 트리 쉐이킹, 스코프 호이스팅 등이 자동으로 활성화됩니다.
  // -----------------------------------------------------------------------------
  mode: 'production',

  // -----------------------------------------------------------------------------
  // 학습 포인트 2: `devtool: 'source-map'` 또는 미사용
  // - 프로덕션 환경에서는 디버깅 정보가 외부에 노출되지 않도록 소스 맵을 생성하지 않거나,
  //   `source-map`과 같이 별도의 파일로 생성하여 배포 서버에 올리지 않는 것이 일반적입니다.
  // -----------------------------------------------------------------------------
  devtool: 'source-map', // 프로덕션에서는 `source-map` (별도 파일) 또는 `false`

  // -----------------------------------------------------------------------------
  // 학습 포인트 3: `optimization` (최적화)
  // - 프로덕션 빌드의 성능과 번들 크기를 최적화하는 설정을 정의합니다.
  //   - `minimize: true`: 번들 파일 압축 활성화.
  //   - `minimizer`: 번들을 압축할 플러그인을 지정합니다.
  //   - `splitChunks`: 코드 스플리팅 (Code Splitting) 설정. (5단계에서 자세히 다룸)
  // -----------------------------------------------------------------------------
  optimization: {
    minimize: true, // 번들 파일 압축 활성화
    minimizer: [
      new TerserPlugin(), // JavaScript 압축 (ES6+ 문법 지원)
      new CssMinimizerPlugin(), // CSS 압축
    ],
    // 나쁜 예시: 프로덕션 빌드에서 `optimization` 설정을 누락하여
    // - 번들 파일 크기가 불필요하게 커지고, 초기 로딩 속도가 저하되는 것.
    // - 사용자가 다운로드해야 하는 데이터 양을 최소화하여 성능을 최적화해야 합니다.
  },

  // -----------------------------------------------------------------------------
  // 학습 포인트 4: `plugins` (플러그인)
  // - 프로덕션 환경에서만 필요한 플러그인을 추가합니다.
  //   - `DefinePlugin`: 프로덕션 환경 변수를 주입하여 코드 내에서 `process.env.NODE_ENV === 'production'`과 같은
  //     조건부 코드가 빌드 시점에 제거되도록 합니다 (트리 쉐이킹).
  // -----------------------------------------------------------------------------
  plugins: [
    new webpack.DefinePlugin({
      'process.env.NODE_ENV': JSON.stringify('production'), // NODE_ENV를 'production'으로 주입
    }),
    // 나쁜 예시: 개발 환경에서만 필요한 플러그인(예: HMR)을 프로덕션 빌드에 포함하는 것.
    // - 불필요한 코드가 번들에 포함되어 번들 크기를 늘리고, 보안 위험을 초래할 수 있습니다.
  ],
});

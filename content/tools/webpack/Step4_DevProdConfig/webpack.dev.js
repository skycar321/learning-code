// webpack/Step4_DevProdConfig/webpack.dev.js
// Webpack 학습 계획 - 4단계: 개발 및 프로덕션 환경 설정
// 이 파일은 개발(development) 환경에 특화된 Webpack 설정을 정의합니다.
//
// `webpack-merge`를 사용하여 `webpack.common.js`의 공통 설정을 가져오고,
// 개발 환경에 필요한 `devtool`, `devServer` 등의 설정을 추가합니다.

const { merge } = require('webpack-merge'); // webpack-merge 임포트
const common = require('./webpack.common.js'); // 공통 설정 임포트
const webpack = require('webpack'); // Webpack 자체를 임포트 (HotModuleReplacementPlugin 사용)

module.exports = merge(common, {
  // -----------------------------------------------------------------------------
  // 학습 포인트 1: `mode: 'development'`
  // - 개발 모드로 설정합니다. Webpack이 개발에 최적화된 기본 설정을 적용합니다.
  // -----------------------------------------------------------------------------
  mode: 'development',

  // -----------------------------------------------------------------------------
  // 학습 포인트 2: `devtool: 'inline-source-map'`
  // - 개발 중 디버깅을 용이하게 하기 위해 소스 맵을 생성합니다.
  // - `inline-source-map`: 소스 맵을 번들 파일 내부에 Base64 인코딩하여 포함합니다.
  // - `eval-source-map`: 각 모듈을 eval로 감싸고 소스 맵을 추가. 개발 빌드 속도에 유리.
  // -----------------------------------------------------------------------------
  devtool: 'inline-source-map', // 소스 맵 생성 (디버깅 용이)

  // -----------------------------------------------------------------------------
  // 학습 포인트 3: `devServer` (개발 서버)
  // - `webpack-dev-server`를 사용하여 개발 중 웹 애플리케이션을 호스팅하고,
  // - 코드 변경 시 자동으로 브라우저를 새로고침하거나 HMR (Hot Module Replacement) 기능을 제공합니다.
  // -----------------------------------------------------------------------------
  devServer: {
    static: './dist', // 정적 파일을 제공할 디렉토리
    port: 8080, // 개발 서버 포트
    open: true, // 서버 시작 후 자동으로 브라우저 열기
    hot: true, // HMR (Hot Module Replacement) 활성화
    historyApiFallback: true, // SPA (Single Page Application) 라우팅 지원
  },

  // -----------------------------------------------------------------------------
  // 학습 포인트 4: `plugins` (플러그인)
  // - 개발 환경에서만 필요한 플러그인을 추가합니다.
  // - `HotModuleReplacementPlugin`: HMR을 활성화합니다.
  // -----------------------------------------------------------------------------
  plugins: [
    new webpack.HotModuleReplacementPlugin(), // HMR 활성화 플러그인
    // 나쁜 예시: 개발 환경에서 프로덕션 최적화 플러그인(예: 코드 압축)을 포함하는 것.
    // - 빌드 속도를 저하시키고, 디버깅을 어렵게 만듭니다.
    // - 각 환경에 필요한 플러그인만 포함해야 합니다.
  ],
});

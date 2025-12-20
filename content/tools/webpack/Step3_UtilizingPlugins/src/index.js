// webpack/Step3_UtilizingPlugins/src/index.js
// Webpack 학습 계획 - 3단계: 플러그인 (Plugins) 활용
// 이 파일은 Webpack의 엔트리 포인트로 사용되며, CSS 파일을 임포트하고
// `DefinePlugin`으로 주입된 전역 상수를 사용하는 예시를 포함합니다.

import './style.css'; // CSS 파일 임포트

function component() {
  const element = document.createElement('div');

  // `DefinePlugin`으로 주입된 상수 사용
  element.innerHTML = `Hello from Webpack Plugins! App Version: ${APP_VERSION}`;
  element.classList.add('plugin-text'); // style.css에 정의된 클래스 추가

  const envInfo = document.createElement('p');
  envInfo.innerHTML = `Environment: ${process.env.NODE_ENV}, API Base URL: ${process.env.API_BASE_URL}`;
  element.appendChild(envInfo);

  return element;
}

document.body.appendChild(component());

// 나쁜 예시: 개발 환경과 프로덕션 환경에 따라 API 엔드포인트를 코드 내에서
// - `if (process.env.NODE_ENV === 'development')` 와 같이 조건부로 설정하는 것.
// - `DefinePlugin`을 사용하면 빌드 시점에 환경별 값을 주입하여 코드를 더 간결하게 만들 수 있습니다.

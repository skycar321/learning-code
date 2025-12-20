// webpack/Step4_DevProdConfig/src/index.js
// Webpack 학습 계획 - 4단계: 개발 및 프로덕션 환경 설정
// 이 파일은 Webpack의 엔트리 포인트로 사용되며, CSS 파일을 임포트하고
// `process.env.NODE_ENV`와 같은 환경 변수에 따라 다른 로직을 실행하는 예시를 포함합니다.

import './style.css';

function component() {
  const element = document.createElement('div');
  element.classList.add('app-container');

  const title = document.createElement('h1');
  title.innerHTML = `Environment: ${process.env.NODE_ENV}`;
  element.appendChild(title);

  if (process.env.NODE_ENV === 'development') {
    const devInfo = document.createElement('p');
    devInfo.innerHTML = 'This is a development build. Debugging features are enabled.';
    devInfo.classList.add('dev-info');
    element.appendChild(devInfo);
  } else {
    const prodInfo = document.createElement('p');
    prodInfo.innerHTML = 'This is a production build. Code is optimized.';
    prodInfo.classList.add('prod-info');
    element.appendChild(prodInfo);
  }

  const button = document.createElement('button');
  button.innerHTML = 'Click me';
  button.onclick = () => alert(`Running in ${process.env.NODE_ENV} mode!`);
  element.appendChild(button);

  return element;
}

document.body.appendChild(component());

// 나쁜 예시: 개발/프로덕션 환경을 구분하는 로직이 너무 복잡하거나,
// - 빌드 시점에 환경 변수가 아닌 런타임에 환경 변수를 읽어서 처리하는 것.
// - Webpack의 `DefinePlugin`을 사용하면 빌드 시점에 환경 변수 값을 코드에 직접 주입하여
// - 불필요한 런타임 로직을 제거하고, 프로덕션 빌드에서 데드 코드를 트리 쉐이킹할 수 있습니다.

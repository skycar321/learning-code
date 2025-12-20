// webpack/Step5_PerformanceAndAdvanced/src/index.js
// Webpack 학습 계획 - 5단계: 성능 최적화 및 고급 기능
// 이 파일은 Webpack의 엔트리 포인트로 사용되며, 코드 스플리팅 및 지연 로딩을
// 시연하기 위해 다른 모듈을 동적으로 임포트하는 예시를 포함합니다.

import './style.css';

function component() {
  const element = document.createElement('div');
  element.innerHTML = 'Hello from Webpack Performance!';
  element.classList.add('main-content');

  const button = document.createElement('button');
  button.innerHTML = 'Load Utilities';
  button.onclick = async () => {
    // -----------------------------------------------------------------------------
    // 학습 포인트 1: `import()` 동적 임포트 (지연 로딩, Lazy Loading)
    // - `import()` 구문을 사용하면 해당 모듈이 필요할 때까지 로딩을 지연시킬 수 있습니다.
    // - Webpack은 이 구문을 만나면 해당 모듈을 별도의 JavaScript 파일(청크)로 분리합니다.
    // - 초기 로딩 시 불필요한 코드를 다운로드하지 않아 초기 로딩 속도를 개선합니다.
    // -----------------------------------------------------------------------------
    try {
      const { greet } = await import('./utils'); // './utils.js' 모듈을 동적으로 임포트
      const utilsMessage = document.createElement('p');
      utilsMessage.innerHTML = greet('Dynamic User');
      element.appendChild(utilsMessage);
      button.remove(); // 버튼 제거
    } catch (error) {
      console.error('Error loading utils module:', error);
    }
  };
  element.appendChild(button);

  return element;
}

document.body.appendChild(component());

// 나쁜 예시: 초기 로딩 시 모든 모듈을 한 번에 번들링하는 것.
// - 사용자가 실제로 사용하지 않을 수도 있는 코드를 모두 다운로드하게 하여
// - 초기 로딩 속도를 저하시킵니다.
// - `import()`를 이용한 지연 로딩을 통해 필요한 코드만 로드해야 합니다.

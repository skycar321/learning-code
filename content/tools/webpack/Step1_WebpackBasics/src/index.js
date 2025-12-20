// webpack/Step1_WebpackBasics/src/index.js
// Webpack 학습 계획 - 1단계: Webpack 기본 개념 및 시작
// 이 파일은 Webpack의 엔트리 포인트(Entry Point)로 사용되는 JavaScript 파일입니다.
// 다른 JavaScript 파일이나 모듈을 임포트하고, 간단한 콘솔 출력을 수행합니다.

import './style.css'; // CSS 파일 임포트 (Webpack 로더에 의해 처리)

function component() {
  const element = document.createElement('div');

  element.innerHTML = 'Hello from Webpack!';
  element.classList.add('hello'); // style.css에 정의된 클래스 추가

  const button = document.createElement('button');
  button.innerHTML = 'Click me';
  button.onclick = () => alert('Button Clicked!');
  element.appendChild(button);

  return element;
}

document.body.appendChild(component());

// 나쁜 예시: `webpack.config.js`에 로더 설정을 하지 않고 CSS 파일을 임포트하는 것.
// - Webpack은 기본적으로 JavaScript만 이해하므로, CSS 파일을 임포트하면 빌드 에러가 발생합니다.
// - `.css` 파일을 처리하기 위해서는 `css-loader`와 `style-loader`를 설정해야 합니다.

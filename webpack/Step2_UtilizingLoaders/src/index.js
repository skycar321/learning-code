// webpack/Step2_UtilizingLoaders/src/index.js
// Webpack 학습 계획 - 2단계: 로더 (Loaders) 활용
// 이 파일은 JavaScript (ES6+), CSS, SCSS, 이미지, 폰트 파일을 임포트하여
// Webpack 로더들이 어떻게 작동하는지 보여주는 엔트리 포인트 파일입니다.

// 1. CSS 파일 임포트 (style-loader, css-loader에 의해 처리)
import './style.css';

// 2. SCSS 파일 임포트 (sass-loader, css-loader, style-loader에 의해 처리)
import './style.scss';

// 3. 이미지 파일 임포트 (Webpack 5 Asset Modules에 의해 처리)
import WebpackLogo from './image.png';

// 4. 폰트 파일 임포트 (Webpack 5 Asset Modules에 의해 처리)
import './font.ttf';

// -----------------------------------------------------------------------------
// 학습 포인트 1: ES6+ 문법 사용 (babel-loader에 의해 처리)
// -----------------------------------------------------------------------------
const greeting = "Hello from Webpack Loaders!";
const sum = (a, b) => a + b; // 화살표 함수 (ES6)

console.log(greeting);
console.log(`2 + 3 = ${sum(2, 3)}`);

function component() {
  const element = document.createElement('div');
  element.innerHTML = greeting;
  element.classList.add('hello-text'); // style.css의 클래스 적용

  // SCSS에서 정의된 클래스 적용
  element.classList.add('scss-text');

  // 이미지 엘리먼트 생성
  const myIcon = new Image();
  myIcon.src = WebpackLogo; // 임포트된 이미지 URL 사용
  myIcon.style.width = '100px';
  myIcon.style.height = '100px';
  element.appendChild(myIcon);

  // 폰트 사용 예시
  const fontText = document.createElement('p');
  fontText.innerHTML = 'Custom Font Text';
  fontText.style.fontFamily = 'CustomFont';
  element.appendChild(fontText);

  return element;
}

document.body.appendChild(component());

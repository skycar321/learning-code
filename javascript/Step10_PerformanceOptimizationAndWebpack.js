// JavaScript 성능 최적화 및 웹팩 (Webpack)
// 번들링, 코드 스플리팅 등 웹팩을 이용한 성능 최적화 전략

// 나쁜 예시: 여러 개의 작은 JavaScript 파일을 `<script>` 태그로 로드하여 HTTP 요청이 많아지고 페이지 로딩 속도가 느려짐.
// 좋은 예시: Webpack과 같은 번들러를 사용하여 모듈을 번들링하고, 코드 스플리팅, 트리 쉐이킹 등으로 초기 로딩 성능을 최적화.

console.log("--- JavaScript 성능 최적화 전략 ---");

console.log("\n1. 불필요한 DOM 조작 최소화:");
console.log("   - 직접적인 DOM 조작은 비용이 많이 들므로, 가상 DOM을 사용하는 프레임워크(React, Vue)를 활용하거나,");
console.log("   - DOM 조작 횟수를 줄이고 변경 사항을 한 번에 적용하는 배치 업데이트 방식을 사용합니다.");

console.log("\n2. 이벤트 위임 (Event Delegation):");
console.log("   - 많은 자식 요소에 개별적으로 이벤트 리스너를 추가하는 대신, 부모 요소에 하나의 리스너를 추가하여 성능을 향상시킵니다.");
console.log("   - 동적으로 추가되는 요소에도 자동으로 이벤트 핸들링이 적용됩니다.");

// 예시 (HTML에 다음과 같은 구조가 있다고 가정)
// <ul id="parentList">
//     <li>아이템 1</li>
//     <li>아이템 2</li>
//     <li>아이템 3</li>
// </ul>
/*
const parentList = document.getElementById('parentList');
if (parentList) {
    parentList.addEventListener('click', (event) => {
        if (event.target.tagName === 'LI') { // 클릭된 요소가 LI 태그인 경우
            console.log('클릭된 아이템:', event.target.textContent);
        }
    });
}
*/

console.log("\n3. 스로틀링(Throttling)과 디바운싱(Debouncing):");
console.log("   - 스크롤, 리사이즈, 검색창 입력 등 빈번하게 발생하는 이벤트의 과도한 호출을 제어하여 성능 부하를 줄입니다.");
console.log("   - 스로틀링: 일정 시간 동안 한 번만 함수가 실행되도록 합니다.");
console.log("   - 디바운싱: 특정 시간 내에 같은 이벤트가 다시 발생하면 이전 호출을 취소하고 마지막 이벤트만 처리합니다.");

// 예시 (디바운싱 함수)
/*
function debounce(func, delay) {
    let timeoutId;
    return function(...args) {
        clearTimeout(timeoutId);
        timeoutId = setTimeout(() => {
            func.apply(this, args);
        }, delay);
    };
}

const handleResize = () => console.log("창 크기 조절 완료!");
window.addEventListener('resize', debounce(handleResize, 300));
*/

console.log("\n4. 이미지 최적화:");
console.log("   - 웹P(WebP), AVIF 등 차세대 이미지 포맷 사용.");
console.log("   - 이미지 지연 로딩(Lazy Loading) 적용.");
console.log("   - CDN(콘텐츠 전송 네트워크) 활용.");

console.log("\n--- Webpack을 이용한 모듈 번들링 및 최적화 ---");
console.log("Webpack은 여러 JavaScript, CSS, 이미지 등의 모듈을 하나 또는 여러 개의 번들 파일로 묶어주는 도구입니다.");

console.log("\n1. 번들링 (Bundling):");
console.log("   - 여러 모듈을 하나의 파일로 묶어 HTTP 요청 수를 줄입니다.");
console.log("   - (예시) entry.js -> bundle.js");

console.log("\n2. 코드 스플리팅 (Code Splitting):");
console.log("   - 번들 파일을 여러 작은 조각으로 나누어 필요한 코드만 로드하여 초기 로딩 시간을 단축합니다.");
console.log("   - (예시) 동적 import `import('./module').then(...)`");

console.log("\n3. 트리 쉐이킹 (Tree Shaking):");
console.log("   - 실제로 사용되지 않는 코드를 최종 번들에서 제거하여 파일 크기를 줄입니다.");
console.log("   - ES Modules의 `import/export` 구문을 사용해야 효과적입니다.");

console.log("\n4. 로더 (Loaders):");
console.log("   - JavaScript가 아닌 파일(CSS, 이미지, 폰트 등)을 웹팩이 이해할 수 있는 모듈로 변환합니다.");
console.log("   - (예시) `css-loader`, `style-loader`, `babel-loader` 등");

console.log("\n5. 플러그인 (Plugins):");
console.log("   - 번들링 과정에서 다양한 작업을 수행하여 최적화를 돕습니다.");
console.log("   - (예시) `HtmlWebpackPlugin` (HTML 파일 생성), `MiniCssExtractPlugin` (CSS 추출), `UglifyJsPlugin` (코드 압축) 등");

console.log("\nWebpack 설정 파일 (webpack.config.js) 예시:");
/*
// webpack.config.js
const path = require('path');

module.exports = {
  entry: './src/index.js', // 진입점 파일
  output: {
    filename: 'bundle.js', // 번들링된 파일 이름
    path: path.resolve(__dirname, 'dist'), // 출력 디렉토리
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
        },
      },
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader'],
      },
    ],
  },
  devServer: { // 개발 서버 설정
    static: './dist',
  },
  mode: 'development', // 'production'으로 설정하면 코드 압축 등 최적화가 자동으로 적용
};
*/

console.log("\nWebpack은 초기 설정이 복잡할 수 있지만, 웹 애플리케이션의 성능과 개발 효율성을 크게 향상시킬 수 있는 강력한 도구입니다.");

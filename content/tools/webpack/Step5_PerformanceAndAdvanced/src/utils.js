// webpack/Step5_PerformanceAndAdvanced/src/utils.js
// Webpack 학습 계획 - 5단계: 성능 최적화 및 고급 기능
// 이 파일은 `index.js`에서 동적으로 임포트되는 유틸리티 모듈입니다.
//
// 지연 로딩(Lazy Loading) 예시를 위해 별도의 파일로 분리되었습니다.

export function greet(name) {
  return `Hello, ${name} from utils.js! This module was lazy-loaded.`;
}

// 나쁜 예시: 초기 로딩 시에도 항상 필요한 작은 유틸리티 함수들을 동적으로 임포트하는 것.
// - 지연 로딩은 큰 모듈이나 초기 로딩 시에는 필요 없는 모듈에만 적용해야 합니다.
// - 작은 모듈에 적용하면 네트워크 요청 수가 늘어나 오히려 성능이 저하될 수 있습니다.

// TypeScript 모듈 (Modules)
// `import`와 `export`를 이용한 모듈 시스템 이해 및 활용

// 나쁜 예시: 모든 TypeScript/JavaScript 파일을 전역 스코프에서 관리하여 변수 및 함수 이름 충돌을 일으키고, 코드의 재사용성을 저해합니다.
// 좋은 예시: 모듈 시스템을 사용하여 코드를 기능별로 분리하고, 명시적인 의존성 관리를 통해 코드의 응집도를 높이고 재사용성과 유지보수성을 향상시킵니다.

// 모듈은 자체적인 스코프를 가지는 파일입니다.
// 모듈 내에서 선언된 모든 변수, 함수, 클래스 등은 해당 모듈 내에서만 접근 가능하며,
// `export` 키워드를 사용하여 외부로 노출하고, `import` 키워드를 사용하여 다른 모듈에서 불러와 사용합니다.

// --- 1. Export (내보내기) ---
// 다른 모듈에서 사용할 수 있도록 코드를 내보냅니다.

// 1-1. 이름 있는 내보내기 (Named Exports)
// 한 파일에서 여러 개를 내보낼 수 있습니다.
export const PI = 3.14159;

export function add(a: number, b: number): number {
    return a + b;
}

export class Calculator {
    add(x: number, y: number): number {
        return x + y;
    }
    subtract(x: number, y: number): number {
        return x - y;
    }
}

// 1-2. 기본 내보내기 (Default Export)
// 한 파일에서 단 하나만 내보낼 수 있습니다.
// `import` 할 때 원하는 이름으로 가져올 수 있습니다.
export default interface User {
    id: number;
    name: string;
}

// 이 파일 (Step9_Modules.ts)이 내보내는 내용입니다.
// 이 파일은 직접 실행하면 아무런 출력이 없지만, 다른 파일에서 import하여 사용될 것입니다.


/*
// --- 2. Import (가져오기) ---
// 다른 모듈에서 내보낸 코드를 가져와 사용합니다.

// 이 코드는 이 파일에 작성할 수 없으며,
// `src/main.ts`와 같은 다른 파일에서 `Step9_Modules.ts`를 import하여 사용하는 예시입니다.

// import { PI, add, Calculator } from './Step9_Modules'; // 이름 있는 내보내기 가져오기
// import MyUser from './Step9_Modules'; // 기본 내보내기 가져오기 (원하는 이름으로)

// console.log(`PI 값: ${PI}`);
// console.log(`덧셈 결과: ${add(5, 3)}`);

// const calc = new Calculator();
// console.log(`계산기 덧셈: ${calc.add(10, 5)}`);

// const user: MyUser = { id: 1, name: "TypeScript User" };
// console.log(`사용자: ${user.name}`);

// 모든 것을 한 번에 가져오기 (이름 있는 내보내기)
// import * as MathUtils from './Step9_Modules';
// console.log(MathUtils.PI);

// 주의: TypeScript 모듈은 컴파일러 설정(tsconfig.json의 `module` 옵션)에 따라
// CommonJS, ESNext 등 다양한 JavaScript 모듈 시스템으로 변환됩니다.
// 예를 들어, `module: "CommonJS"`로 설정하면 `require`와 `module.exports` 형태로 변환됩니다.
*/

// --- 모듈 로더 (Module Loaders) ---
// 브라우저는 기본적으로 CommonJS 모듈을 이해하지 못합니다.
// 웹팩(Webpack)과 같은 번들러를 사용하면 여러 모듈 파일을 하나로 묶고
// 브라우저가 이해할 수 있는 형태로 변환하여 로드합니다.
// Node.js는 CommonJS를 기본으로 지원하며, `--experimental-modules` 플래그나 `.mjs` 확장자를 통해 ES Modules도 지원합니다.

// 학습 포인트: 모듈 시스템은 현대적인 JavaScript/TypeScript 애플리케이션 개발의 핵심입니다.
// 코드의 재사용성, 유지보수성, 확장성을 크게 향상시키며, 전역 스코프 오염을 방지합니다.
// 프로젝트의 규모가 커질수록 모듈화를 잘 설계하는 것이 중요합니다.

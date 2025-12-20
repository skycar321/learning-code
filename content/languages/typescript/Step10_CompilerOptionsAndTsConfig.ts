// TypeScript 컴파일 옵션과 `tsconfig.json`
// `tsconfig.json` 파일을 통한 TypeScript 컴파일러 설정

// 나쁜 예시: `tsconfig.json` 없이 TypeScript를 사용하거나, 기본적인 설정만 사용하여 TypeScript의 잠재력을 충분히 활용하지 못합니다.
// 좋은 예시: 프로젝트의 요구사항에 맞춰 `tsconfig.json`을 세밀하게 구성하여, 엄격한 타입 검사, 모듈 해상도, 대상 JavaScript 버전 등을 최적화합니다.

console.log("--- tsconfig.json 파일의 역할 ---");
console.log("`tsconfig.json` 파일은 TypeScript 프로젝트의 루트에 위치하며, TypeScript 컴파일러(tsc)가 소스 파일을 컴파일하는 방식을 지정합니다.");
console.log("이 파일은 다음과 같은 정보를 제공합니다:");
console.log("1. **컴파일 대상 파일**: 어떤 파일을 컴파일할지 지정합니다.");
console.log("2. **컴파일러 옵션**: 어떤 타입 검사를 수행할지, 어떤 JavaScript 버전으로 컴파일할지 등을 설정합니다.");

console.log("\n--- `tsconfig.json` 예시 (간소화) ---");
/*
{
  "compilerOptions": {
    "target": "es2016", // 컴파일될 JavaScript 대상 버전 (예: "es5", "es2015", "esnext")
    "module": "commonjs", // 모듈 시스템 (예: "commonjs", "es2015", "esnext", "none")
    "rootDir": "./src", // TypeScript 소스 파일이 있는 루트 디렉토리
    "outDir": "./dist", // 컴파일된 JavaScript 파일이 출력될 디렉토리
    "strict": true, // 모든 엄격한 타입 검사 옵션을 활성화
    "esModuleInterop": true, // CommonJS 모듈을 ES Module처럼 가져올 수 있도록 허용
    "forceConsistentCasingInFileNames": true, // 파일 이름 대소문자 구분을 강제
    "skipLibCheck": true, // 선언 파일(*.d.ts)에 대한 타입 검사를 건너뜀
    "declaration": true, // .d.ts 파일 생성 (라이브러리 개발 시 유용)
    "sourceMap": true, // 소스맵 파일(.map) 생성 (디버깅 용이)
    "jsx": "react", // JSX 지원 방식 (예: "preserve", "react", "react-native")
    "baseUrl": "./", // 모듈 해석을 위한 기본 경로
    "paths": { // 모듈 경로 별칭 설정
      "@utils/*": ["src/utils/*"],
      "@models/*": ["src/models/*"]
    }
  },
  "include": [ // 컴파일할 파일 또는 파일 패턴
    "src/**/*.ts",
    "src/**/*.d.ts"
  ],
  "exclude": [ // 컴파일에서 제외할 파일 또는 파일 패턴
    "node_modules",
    "dist"
  ],
  "files": [ // 컴파일할 특정 파일 목록 (include/exclude 대신)
    // "src/main.ts",
    // "src/types.d.ts"
  ]
}
*/

console.log("\n--- 주요 `compilerOptions` 설명 ---");

console.log("\n`target`: 컴파일된 JavaScript 코드가 실행될 환경의 버전을 지정합니다.");
console.log("   - `es5`: IE11 등 구형 브라우저 지원. 대부분의 최신 JS 기능이 트랜스파일됨.");
console.log("   - `esnext`: 최신 JS 기능 그대로 유지 (Node.js 최신 버전 등).");

console.log("\n`module`: 모듈 로드 방식을 지정합니다.");
console.log("   - `commonjs`: Node.js에서 사용되는 `require`/`module.exports` 스타일.");
console.log("   - `esnext`: ES Modules (`import`/`export`) 스타일. 현대 웹 개발에서 주로 사용.");

console.log("\n`strict`: TypeScript의 핵심 기능 중 하나로, `true`로 설정하면 엄격한 타입 검사 모드 전체를 활성화합니다.");
console.log("   - `noImplicitAny`: `any` 타입으로 추론되는 경우 오류 발생.");
console.log("   - `strictNullChecks`: `null`과 `undefined`를 모든 타입에 할당할 수 없도록 엄격하게 검사.");
console.log("   - `strictFunctionTypes`: 함수 매개변수 타입 검사를 엄격하게.");
console.log("   - `strictPropertyInitialization`: 클래스 속성 초기화를 엄격하게.");
console.log("   - `noImplicitThis`: `this`의 암시적 `any` 타입을 방지.");

console.log("\n`esModuleInterop`: ES Module과 CommonJS 모듈 간의 호환성을 높여줍니다.");
console.log("   - `import * as React from 'react'`와 같이 CommonJS 모듈을 ES Module처럼 가져올 수 있게 합니다.");

console.log("\n`paths`와 `baseUrl`: 모듈 경로 별칭을 설정하여 긴 상대 경로 대신 짧은 별칭으로 모듈을 가져올 수 있게 합니다.");
console.log("   - (예시) `import { myUtility } from '@utils/my-utility';`");

console.log("\n--- `include`, `exclude`, `files` ---");
console.log("`include`: 컴파일할 TypeScript 파일을 지정하는 글로브(glob) 패턴 배열.");
console.log("`exclude`: 컴파일에서 제외할 파일 또는 디렉토리를 지정하는 글로브 패턴 배열 (`node_modules`, `dist` 등).");
console.log("`files`: 특정 TypeScript 파일 목록을 명시적으로 지정. `include`와 `exclude`를 무시합니다.");

console.log("\n학습 포인트: `tsconfig.json`은 TypeScript 프로젝트의 '뇌'와 같습니다. 프로젝트의 특성과 요구사항에 맞게 이 파일을 잘 설정하는 것이 매우 중요합니다.");
console.log("특히 `strict` 모드를 활성화하여 TypeScript의 모든 타입 검사 이점을 활용하는 것을 강력히 권장합니다.");

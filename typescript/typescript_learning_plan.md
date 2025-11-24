# 실무 TypeScript 코드 학습 계획

안녕하세요! 미래의 멋진 TypeScript 개발자 여러분!

이 학습 계획은 여러분이 단순한 문법 지식을 넘어, 실제 프로젝트에서 마주하게 될 상황에 대비하여 견고하고 유지보수하기 쉬운 TypeScript 코드를 구성하는 데 필요한 핵심 역량을 길러주기 위해 기획되었습니다. 각 단계에서 제시하는 '나쁜 예시'를 통해 흔히 저지르는 실수를 파악하고, '좋은 예시'를 통해 모범 사례와 그 배경에 있는 원칙을 깊이 있게 이해하는 것이 중요합니다.

각 학습 주제는 상세한 설명과 코드 예시를 포함하며, '왜', '어떤 상황에서', '이 해당 패턴을 사용해야 하는지'를 깊이 있게 이해하는 학습이 되도록 합니다. 주도적인 학습을 위해 직접 예시 코드를 실행해보고, 나쁜 코드를 좋은 코드로 리팩토링하는 연습을 해볼 것을 강력히 추천합니다! 모든 학습 과정을 성공적으로 마치고 나면, 여러분은 자신감 넘치는 개발자로 성장해 있을 것입니다. 자, 그럼 시작해볼까요!

---

### **학습 로드맵**

| 단계 | 주제 | 학습 목표 | 상태 |
| :-- | :--- | :--- | :--- |
| **Step 1** | **TypeScript 기본 타입** | `string`, `number`, `boolean`, `any`, `void`, `null`, `undefined` 등 기본 타입을 이해 | 완료 |
| **Step 2** | **인터페이스(Interface)** | 객체, 함수, 클래스의 타입을 정의하기 위한 인터페이스 사용 | 완료 |
| **Step 3** | **타입 별칭 (Type Aliases)** | 복잡한 타입을 정의하기 위한 타입 별칭 사용 및 인터페이스와의 차이점 | 완료 |
| **Step 4** | **클래스 (Class)** | TypeScript 클래스의 접근 제어자, 상속, 인터페이스 구현 | 완료 |
| **Step 5** | **함수 (Functions)** | 함수 오버로딩, 선택적 매개변수, 기본 매개변수, Rest 매개변수 | 완료 |
| **Step 6** | **제네릭(Generics)** | 재사용 가능한 컴포넌트 작성을 위한 제네릭 사용 | 완료 |
| **Step 7** | **열거형(Enums)** | 숫자 또는 문자열 기반의 열거형 정의 및 사용 | 완료 |
| **Step 8** | **타입 추론과 타입 단언** | TypeScript의 타입 추론 이해 및 `as` 키워드를 이용한 타입 단언 | 완료 |
| **Step 9** | **모듈 (Modules)** | `import`와 `export`를 이용한 모듈 시스템 이해 및 사용 | 완료 |
| **Step 10** | **컴파일러 옵션과 `tsconfig.json`** | `tsconfig.json` 파일을 이용한 TypeScript 컴파일러 설정 | 완료 |

---

### **각 단계별 상세 내용 (예시)**

#### **Step 1: TypeScript 기본 타입**
- **나쁜 예시**: 모든 변수를 `any` 타입으로 선언하여 TypeScript의 타입 검사 장점을 포기합니다.
- **좋은 예시**: 각 변수에 적절한 기본 타입을 명시적으로 지정하거나, 타입 추론을 활용하여 코드의 안정성을 높입니다.
- **학습 포인트**: TypeScript는 JavaScript에 정적 타입을 추가하여 코드의 안정성과 유지보수성을 향상시킵니다. 변수에 올바른 타입을 지정하는 것이 TypeScript의 가장 기본적인 작업이며, 타입 검사의 장점을 최대한 활용하는 방법입니다.

---

### **생성될 TypeScript 파일 목록**

`c:/Users/Nam/Documents/Cursor/Workspace/origin/learning-code/typescript` 경로에 다음 파일들이 생성될 예정입니다. 이 파일들은 나쁜 예시와 좋은 예시 코드를 포함하며, 상세한 주석을 통해 각 패턴을 심층적으로 학습할 수 있도록 구성될 것입니다.

```
learning-code/typescript/
├── Step1_TypeScriptBasicTypes.ts
├── Step2_Interface.ts
├── Step3_TypeAliases.ts
├── Step4_Class.ts
├── Step5_Functions.ts
├── Step6_Generics.ts
├── Step7_Enums.ts
├── Step8_TypeInferenceAndTypeAssertion.ts
├── Step9_Modules.ts
├── Step10_CompilerOptionsAndTsConfig.ts
```

---

### **추가 학습 권장 사항**

| 주제 | 설명 | 난이도 |
|:-----|:-----|:------:|
| **고급 타입 시스템** | Conditional Types, Mapped Types, Template Literal Types 등 고급 타입 기법을 학습합니다. | 중급 |
| **Zod/Yup 스키마 검증** | 런타임 타입 검증 라이브러리를 활용한 안전한 데이터 처리 방법을 익힙니다. | 중급 |
| **TypeScript와 React** | React 컴포넌트, Hooks, Context에 TypeScript를 적용하는 패턴과 모범 사례를 학습합니다. | 중급 |
| **Decorators & Metadata** | 데코레이터와 메타데이터 리플렉션을 활용한 선언적 프로그래밍 기법을 익힙니다. | 고급 |
| **타입 수준 프로그래밍** | 타입 시스템을 활용한 컴파일 타임 계산과 타입 안전한 DSL 구현 방법을 학습합니다. | 고급 |
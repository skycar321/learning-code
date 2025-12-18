# 실무 TypeScript 코드 학습 계획

TypeScript로 안전하고 유지보수하기 쉬운 코드를 작성하기 위한 단계별 로드맵입니다. 각 단계는 **나쁜 예시(bad)**와 **좋은 예시(good)**를 대비해 설명하며, 바로 실행 가능한 명령을 제공합니다.

---

### 학습 로드맵

| 단계 | 주제 | 학습 목표 | 상태 |
| :-- | :--- | :--- | :--- |
| **Step 1** | **기본 타입** | `string`, `number`, `boolean`, `any`, `void`, `null`, `undefined` 이해 | 완료 |
| **Step 2** | **인터페이스** | 객체 형태를 명확히 기술하고 선택적/읽기 전용 프로퍼티 정의 | 완료 |
| **Step 3** | **타입 별칭** | 복잡한 타입을 별칭으로 단순화하고 재사용 | 완료 |
| **Step 4** | **클래스** | 접근 제어자, 상속, 추상 클래스 활용 | 완료 |
| **Step 5** | **함수** | 매개변수/반환 타입, 옵셔널, Rest 파라미터 | 완료 |
| **Step 6** | **제네릭** | 타입 안전한 재사용 코드 작성 | 완료 |
| **Step 7** | **열거형** | enum을 사용한 의미 있는 상수 집합 정의 | 완료 |
| **Step 8** | **타입 추론·단언** | `infer`되는 타입 이해 및 `as` 사용 시 주의 | 완료 |
| **Step 9** | **모듈 시스템** | `import`/`export`, ES Modules vs CJS | 완료 |
| **Step 10** | **컴파일러 옵션/tsconfig** | `strict`, `noImplicitAny`, `paths`, `baseUrl` 등 설정 이해 | 완료 |

---

### 빠른 실행 안내 (Step 1~3)
```bash
npm init -y
npm install typescript ts-node @types/node --save-dev
npx ts-node Step1_TypeScriptBasicTypes.ts
npx ts-node Step2_Interface.ts
npx ts-node Step3_TypeAliases.ts
```
> ts-node가 없다면 `npx ts-node ...`로 실행하거나 `tsc Step1_TypeScriptBasicTypes.ts && node Step1_TypeScriptBasicTypes.js`로 실행하세요.

---

### 각 단계별 간단 노트

#### Step 1: 기본 타입
- **bad**: 모든 변수를 `any`로 선언 → 타입 안전성 상실.  
- **good**: 구체 타입 선언 + `unknown`으로 안전한 다운캐스팅 패턴 사용.

#### Step 2: 인터페이스
- **bad**: 중복되는 객체 리터럴을 그대로 반복.  
- **good**: 인터페이스/타입으로 계약을 정의하고 재사용.

#### Step 3: 타입 별칭
- **bad**: 중첩 객체 타입을 매번 인라인으로 작성.  
- **good**: `type User = { id: number; name: string }`처럼 명확한 이름 부여.

#### Step 4~8 추가 메모
- 옵셔널 체이닝/Null 병합: `user?.profile?.email ?? 'unknown'` (bad: `user && user.profile && user.profile.email`).
- 넓은 `any` 대신 `unknown` + 좁히기: `function handle(x: unknown) { if (typeof x === 'string') {...} }`
- 타입 내로잉을 돕는 사용자 정의 타입 가드: `function isUser(u: any): u is User { return u && 'id' in u; }`

---

### 추가 심화 주제
- `strict` 모드에서의 점진적 마이그레이션 전략
- `satisfies` 연산자 활용으로 런타임 객체 검증 강화
- `paths` / `baseUrl`로 모듈 경로 정리, `eslint + @typescript-eslint` 연동

### 파일 위치
`content/languages/typescript/Step1_TypeScriptBasicTypes.ts` 등 각 Step 파일을 참고하세요.

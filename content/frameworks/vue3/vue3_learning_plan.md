# 실무 Vue3 코드 학습 계획

안녕하세요! 미래의 멋진 Vue3 개발자 여러분!

이 학습 계획은 여러분이 단순한 문법 지식을 넘어, 실제 프로젝트에서 마주하게 될 상황에 대비하여 견고하고 유지보수하기 쉬운 Vue3 애플리케이션을 구성하는 데 필요한 핵심 역량을 길러주기 위해 기획되었습니다. 각 단계에서 제시하는 '나쁜 예시'를 통해 흔히 저지르는 실수를 파악하고, '좋은 예시'를 통해 모범 사례와 그 배경에 있는 원칙을 깊이 있게 이해하는 것이 중요합니다.

각 학습 주제는 상세한 설명과 코드 예시를 포함하며, '왜', '어떤 상황에서', '이 해당 패턴을 사용해야 하는지'를 깊이 있게 이해하는 학습이 되도록 합니다. 주도적인 학습을 위해 직접 예시 코드를 실행해보고, 나쁜 코드를 좋은 코드로 리팩토링하는 연습을 해볼 것을 강력히 추천합니다! 모든 학습 과정을 성공적으로 마치고 나면, 여러분은 자신감 넘치는 개발자로 성장해 있을 것입니다. 자, 그럼 시작해볼까요!

---

### **학습 로드맵**

| 단계 | 주제 | 학습 목표 | 상태 |
| :-- | :--- | :--- | :--- |
| **Step 1** | **Vue3 시작하기 (Composition API)** | Vue 인스턴스, 반응성, `setup` 함수, `ref`, `reactive` 등 Vue3 핵심 개념 이해 | 완료 |
| **Step 2** | **컴포넌트 기본 및 Props** | 컴포넌트 생성 및 등록, `defineProps`를 이용한 데이터 전달 | 완료 |
| **Step 3** | **컴포넌트 통신 ($emit, provide/inject)** | `defineEmits`, `provide/inject`를 이용한 컴포넌트 통신 | 완료 |
| **Step 4** | **Vue Router 4** | Vue Router 4의 새로운 API 및 동적 라우팅, 내비게이션 가드 학습 | 완료 |
| **Step 5** | **Pinia (상태 관리)** | Vue3 권장 상태 관리 라이브러리 Pinia의 개념 및 사용 | 완료 |
| **Step 6** | **Life Cycle Hooks (Composition API)** | `onMounted`, `onUpdated` 등 Composition API 기반 생명주기 훅 사용 | 완료 |
| **Step 7** | **Slot (Named Slots, Scoped Slots)** | Vue3 Slot의 구현과 활용, 특히 Named Slots와 Scope Slots | 완료 |
| **Step 8** | **Teleport** | DOM의 다른 위치로 콘텐츠를 이동시키는 Teleport 사용 | 완료 |
| **Step 9** | **Transition & Animation** | Vue3의 Transition 컴포넌트를 이용한 애니메이션 구현 | 완료 |
| **Step 10** | **성능 최적화 및 TypeScript 연동** | Vue 애플리케이션 성능 최적화 기법 및 TypeScript와의 통합 | 완료 |

---

### **각 단계별 상세 내용 (예시)**

#### **Step 1: Vue3 시작하기 (Composition API)**
- **나쁜 예시**: Options API 방식으로 복잡한 로직을 작성하여 컴포넌트의 가독성과 재사용성을 떨어뜨립니다.
- **좋은 예시**: Composition API를 사용하여 관련 로직을 한데 모으고 (로직 재사용 hook) 상태를 반응성 있게 관리하여 재사용 가능한 로직을 추출합니다.
- **학습 포인트**: Vue3의 가장 큰 변화는 Composition API입니다. 이를 통해 복잡한 컴포넌트의 로직을 효율적으로 구성하고 재사용성을 높일 수 있습니다. `setup` 함수, `ref`, `reactive` 등의 핵심 개념을 익히는 것이 중요합니다.

---

### **생성될 Vue3 파일 목록**

`c:/Users/Nam/Documents/Cursor/Workspace/origin/learning-code/vue3` 경로에 다음 파일들이 생성될 예정입니다. 이 파일들은 나쁜 예시와 좋은 예시 코드를 포함하며, 상세한 주석을 통해 각 패턴을 심층적으로 학습할 수 있도록 구성될 것입니다.

```
learning-code/vue3/
├── Step1_Vue3CompositionAPI.js
├── Step2_ComponentBasicsAndProps.js
├── Step3_ComponentCommunication.js
├── Step4_VueRouter4.js
├── Step5_Pinia.js
├── Step6_LifeCycleHooksCompositionAPI.js
├── Step7_Slot.js
├── Step8_Teleport.js
├── Step9_TransitionAndAnimation.js
├── Step10_PerformanceOptimizationAndTypeScript.js
```

---

### **추가 학습 권장 사항**

| 주제 | 설명 | 난이도 |
|:-----|:-----|:------:|
| **Composables 패턴 심화** | 재사용 가능한 Composable 함수 설계 및 VueUse 라이브러리 활용 | 중급 |
| **Suspense & Async Components** | 비동기 컴포넌트 로딩과 Suspense를 활용한 로딩 상태 관리 | 중급 |
| **Vue 3 Reactivity 심화** | shallowRef, triggerRef, customRef 등 고급 반응성 API 활용 | 고급 |
| **Server-Side Rendering (Nuxt 3)** | Nuxt 3를 활용한 최신 SSR/SSG 구현 및 하이브리드 렌더링 | 고급 |
| **Vue 3 + Vite 최적화** | Vite 빌드 최적화, 청크 분리, 트리 쉐이킹 전략 | 중급 |
| **Script Setup 고급 패턴** | defineExpose, defineOptions, 제네릭 컴포넌트 구현 | 중급 |
| **E2E 테스트 (Cypress/Playwright)** | Vue 3 애플리케이션의 End-to-End 테스트 자동화 | 중급 |
| **상태 관리 패턴 비교** | Pinia vs Vuex 5, 언제 어떤 것을 선택해야 하는지 실무 기준 | 중급 |
| **Vue 3 PWA 구현** | Service Worker, Workbox를 활용한 Progressive Web App 구축 | 고급 |

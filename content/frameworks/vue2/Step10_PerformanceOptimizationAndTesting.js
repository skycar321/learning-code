// Vue2 성능 최적화 및 테스트
// Vue 애플리케이션 성능 최적화 기법 및 테스트 전략

// 나쁜 예시: 대량의 데이터를 반응형으로 만들거나, 불필요한 컴포넌트 렌더링이 자주 발생하여 성능 저해.
// 좋은 예시: Vue의 최적화 기능을 활용하고, 테스트 코드를 작성하여 안정적이고 고성능의 애플리케이션을 개발.

// --- 1. 성능 최적화 기법 ---

console.log("--- Vue2 성능 최적화 ---");

console.log("\n1. v-if vs v-show:");
console.log("   - `v-if`: 조건에 따라 컴포넌트를 완전히 생성/파괴합니다. 초기 렌더링 비용은 높지만, 토글 비용은 낮습니다.");
console.log("     조건 변경이 드물 때 적합합니다.");
console.log("   - `v-show`: 엘리먼트를 DOM에 유지하고 CSS의 `display` 속성만 토글합니다. 초기 렌더링 비용은 낮지만, 토글 비용은 높습니다.");
console.log("     자주 토글되는 엘리먼트에 적합합니다.");

console.log("\n2. v-for에 key 속성 사용:");
console.log("   - `v-for`로 리스트를 렌더링할 때 `key` 속성을 항상 사용해야 합니다.");
console.log("   - `key`는 Vue가 노드를 추적하여 최소한의 DOM 조작으로 업데이트할 수 있도록 돕습니다. `index`를 key로 사용하는 것은 일반적으로 비추천.");

// 예시 (가상의 Vue 컴포넌트)
/*
<template>
    <div>
        <li v-for="item in items" :key="item.id">{{ item.name }}</li>
    </div>
</template>
<script>
export default {
    data() {
        return {
            items: [{ id: 1, name: 'A' }, { id: 2, name: 'B' }]
        };
    }
}
</script>
*/

console.log("\n3. 불필요한 반응성 제거 (Object.freeze(), v-once):");
console.log("   - 변경되지 않을 큰 데이터 객체는 `Object.freeze()`를 사용하여 Vue의 반응형 시스템이 추적하지 않도록 할 수 있습니다.");
console.log("   - `v-once` 디렉티브는 엘리먼트 또는 컴포넌트를 한 번만 렌더링하고, 이후 업데이트를 건너뛰어 성능을 최적화합니다.");

// 예시
/*
<template>
    <div v-once>
        이 메시지는 한 번만 렌더링됩니다: {{ message }}
    </div>
</template>
<script>
export default {
    data: () => ({
        frozenObject: Object.freeze({ count: 100 }),
        message: '초기 메시지'
    })
}
</script>
*/

console.log("\n4. 비동기 컴포넌트 (Async Components):");
console.log("   - 큰 컴포넌트나 당장 필요하지 않은 컴포넌트를 비동기적으로 로드하여 초기 로딩 시간을 단축합니다.");
console.log("   - `import()` 구문을 사용하여 Webpack의 코드 스플리팅과 연동됩니다.");

// 예시
/*
// routes.js
const Foo = () => import('./Foo.vue');

// main.js
new Vue({
    // ...
    components: {
        'my-async-component': () => import('./MyAsyncComponent.vue')
    }
});
*/

console.log("\n5. Lazy Loading Routes:");
console.log("   - Vue Router에서 라우트 컴포넌트를 필요할 때만 로드하여 초기 번들 크기를 줄입니다.");

// 예시
/*
// router.js
const Foo = () => import('./views/Foo.vue');
const routes = [
    { path: '/foo', component: Foo }
];
*/

console.log("\n6. 외부 라이브러리 CDN 사용:");
console.log("   - 큰 외부 라이브러리(ex: Vue, Vuex, Vue Router)는 CDN을 통해 로드하여 번들 크기를 줄이고 캐싱 효과를 얻을 수 있습니다.");


console.log("\n--- Vue 애플리케이션 테스트 전략 ---");

console.log("\n1. 단위 테스트 (Unit Tests):");
console.log("   - 개별 컴포넌트, 유틸리티 함수, Vuex 모듈 등 애플리케이션의 가장 작은 단위를 격리하여 테스트합니다.");
console.log("   - 주로 Jest와 Vue Test Utils 라이브러리를 사용합니다.");

// 예시 (MyComponent.vue 파일)
/*
// MyComponent.test.js
import { shallowMount } from '@vue/test-utils';
import MyComponent from './MyComponent.vue';

describe('MyComponent', () => {
  it('renders props.msg when passed', () => {
    const msg = 'new message';
    const wrapper = shallowMount(MyComponent, {
      propsData: { msg }
    });
    expect(wrapper.text()).toMatch(msg);
  });
});
*/

console.log("\n2. 통합 테스트 (Integration Tests):");
console.log("   - 여러 컴포넌트가 함께 작동하는 방식이나 Vuex 스토어와의 상호작용 등을 테스트합니다.");
console.log("   - Vue Test Utils로 충분하거나, Cypress, Playwright와 같은 E2E 테스트 도구를 사용할 수도 있습니다.");

console.log("\n3. 종단 간 테스트 (End-to-End Tests):");
console.log("   - 사용자의 관점에서 애플리케이션의 전체 흐름을 테스트합니다. 브라우저에서 실제 사용자가 상호작용하는 것처럼 테스트를 실행합니다.");
console.log("   - Cypress, Playwright, Selenium과 같은 도구를 사용합니다.");

console.log("\n테스트는 애플리케이션의 품질을 보장하고, 회귀 버그를 방지하며, 리팩토링 시 안정감을 제공합니다. ");
console.log("특히 대규모 애플리케이션에서는 필수적입니다.");

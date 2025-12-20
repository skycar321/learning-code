// Vue3 성능 최적화 및 TypeScript 연동
// Vue 애플리케이션 성능 최적화 기법 및 TypeScript와의 통합

// 나쁜 예시: 대량의 데이터를 반응형으로 만들거나, 불필요한 컴포넌트 렌더링이 자주 발생하여 성능 저해.
// 좋은 예시: Vue의 최적화 기능을 활용하고, TypeScript를 연동하여 타입 안전성을 확보하며 안정적인 고성능 애플리케이션을 개발.

console.log("--- Vue3 성능 최적화 ---");

console.log("\n1. v-if vs v-show:");
console.log("   - `v-if`: 조건에 따라 컴포넌트를 완전히 생성/파괴합니다. 초기 렌더링 비용은 높지만, 토글 비용은 낮습니다.");
console.log("     조건 변경이 드물 때 적합합니다.");
console.log("   - `v-show`: 엘리먼트를 DOM에 유지하고 CSS의 `display` 속성만 토글합니다. 초기 렌더링 비용은 낮지만, 토글 비용은 높습니다.");
console.log("     자주 토글되는 엘리먼트에 적합합니다.");

console.log("\n2. v-for에 key 속성 사용:");
console.log("   - `v-for`로 리스트를 렌더링할 때 `key` 속성을 항상 사용해야 합니다.");
console.log("   - `key`는 Vue가 노드를 추적하여 최소한의 DOM 조작으로 업데이트할 수 있도록 돕습니다. `index`를 key로 사용하는 것은 일반적으로 비추천.");

console.log("\n3. `markRaw`를 이용한 반응성 건너뛰기:");
console.log("   - `markRaw`는 객체를 반응성으로 만들지 않도록 표시합니다.");
console.log("   - 외부 라이브러리 인스턴스나, Vue가 반응성을 관리할 필요가 없는 큰 데이터 객체에 사용하면 성능 향상에 도움이 됩니다.");

// 예시
/*
import { reactive, markRaw } from 'vue';

const bigData = reactive({
    // ...
    charts: markRaw(new ChartLibrary.Chart()) // Chart.js 인스턴스 등
});
*/

console.log("\n4. `v-memo` 디렉티브 (Vue 3.2+):");
console.log("   - 특정 값의 변경이 없을 때 해당 부분의 템플릿 렌더링을 건너뛰어 성능을 최적화합니다.");
console.log("   - (예시) `<div v-memo='[valueA, valueB]'>...</div>`");

console.log("\n5. 비동기 컴포넌트 (Async Components) 및 라우트 Lazy Loading:");
console.log("   - Vue 2와 동일하게 `import()`를 사용하여 코드 스플리팅을 활용하고 초기 로딩 시간을 단축합니다.");

console.log("\n6. `keep-alive` 컴포넌트:");
console.log("   - 동적 컴포넌트 간에 전환할 때 비활성 컴포넌트 인스턴스를 캐싱하여 다시 렌더링하는 것을 방지합니다.");

// 예시
/*
<template>
    <keep-alive>
        <component :is="activeComponent"></component>
    </keep-alive>
</template>
*/


console.log("\n--- Vue3와 TypeScript 연동 ---");

console.log("\nTypeScript는 JavaScript에 타입 시스템을 추가하여 개발 단계에서 오류를 줄이고 코드의 유지보수성을 높이는 강력한 도구입니다.");
console.log("Vue3는 TypeScript와 함께 사용하도록 처음부터 설계되었으며, 완벽한 지원을 제공합니다.");

console.log("\n1. `defineComponent` 사용:");
console.log("   - Options API를 사용할 때 `defineComponent` 헬퍼 함수를 사용하면 Vue가 컴포넌트 옵션에서 타입을 올바르게 추론할 수 있도록 돕습니다.");

// 예시 (MyComponent.ts)
/*
import { defineComponent, PropType } from 'vue';

interface User {
    id: number;
    name: string;
}

export default defineComponent({
    props: {
        msg: {
            type: String,
            required: true
        },
        user: {
            type: Object as PropType<User>, // PropType을 사용하여 복잡한 객체 타입 정의
            required: false
        }
    },
    data() {
        return {
            count: 0 as number // 명시적 타입 지정
        };
    },
    methods: {
        increment(): void {
            this.count++;
        }
    },
    computed: {
        doubleCount(): number {
            return this.count * 2;
        }
    }
});
*/

console.log("\n2. `script setup`과 `<script lang='ts'>` 사용 (Composition API):");
console.log("   - Vue3에서 Composition API와 함께 TypeScript를 사용할 때 가장 권장되는 방식입니다.");
console.log("   - 별도의 타입 추론 설정 없이 `.vue` 파일 내에서 `<script setup lang='ts'>` 블록을 사용하면 됩니다.");

// 예시 (.vue 파일)
/*
<template>
    <div>
        <p>{{ greeting }} {{ user.name }}</p>
        <button @click="increment">{{ count }}</button>
    </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';

interface User {
    id: number;
    name: string;
}

// props 정의
interface Props {
    msg: string;
    user: User;
}
const props = defineProps<Props>(); // 타입 기반 props 정의

const count = ref(0);
const greeting = computed(() => `Hello, ${props.msg}!`);

const increment = () => {
    count.value++;
};
</script>
*/

console.log("\n3. Pinia와 TypeScript:");
console.log("   - Pinia는 TypeScript와 함께 사용하도록 설계되어 스토어의 상태, 게터, 액션에 대한 강력한 타입 추론을 제공합니다.");
console.log("   - (예시) `defineStore`를 사용하여 스토어를 정의하고 타입 인터페이스를 활용.");

// 예시 (stores/counter.ts)
/*
import { defineStore } from 'pinia';

interface CounterState {
    count: number;
    name: string;
}

export const useCounterStore = defineStore('counter', {
    state: (): CounterState => ({
        count: 0,
        name: 'Eduardo'
    }),
    getters: {
        doubleCount: (state): number => state.count * 2
    },
    actions: {
        increment() {
            this.count++;
        }
    }
});
*/

console.log("\nVue3와 TypeScript를 함께 사용하면 대규모 애플리케이션 개발 시 코드의 안정성, 가독성, 유지보수성을 크게 향상시킬 수 있습니다.");

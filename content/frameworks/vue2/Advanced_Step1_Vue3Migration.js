/**
 * Advanced Step 1: Vue 2 → Vue 3 마이그레이션 가이드
 *
 * 이 파일은 Vue 2 프로젝트를 Vue 3로 점진적으로 마이그레이션하는 전략을 학습합니다.
 * 호환성 빌드를 활용한 단계별 마이그레이션 방법을 배웁니다.
 *
 * 학습 목표:
 * 1. Vue 2와 Vue 3의 주요 차이점 이해
 * 2. 호환성 빌드(@vue/compat) 활용
 * 3. 단계별 마이그레이션 전략
 * 4. 주요 Breaking Changes 대응
 *
 * @author Learning Code Project
 */

// ============================================================
// 1. Vue 2와 Vue 3의 주요 차이점
// ============================================================

/*
 * [주요 변경사항 요약]
 *
 * 1. 전역 API 변경
 *    - Vue.component() → app.component()
 *    - Vue.directive() → app.directive()
 *    - Vue.mixin() → app.mixin()
 *
 * 2. v-model 변경
 *    - prop: value → modelValue
 *    - event: input → update:modelValue
 *
 * 3. 렌더 함수 API 변경
 *    - h() 함수를 import해서 사용
 *
 * 4. 생명주기 훅 이름 변경
 *    - destroyed → unmounted
 *    - beforeDestroy → beforeUnmount
 *
 * 5. 이벤트 API 제거
 *    - $on, $off, $once 제거 (이벤트 버스 사용 불가)
 *
 * 6. 필터 제거
 *    - {{ value | filter }} 문법 제거
 */

// ============================================================
// 2. 나쁜 예시: Vue 2 스타일 코드
// ============================================================

// [나쁜 예시] Vue 2 전역 API 사용
const Vue2GlobalExample = `
// main.js (Vue 2 스타일)
import Vue from 'vue'
import App from './App.vue'

// 전역 컴포넌트 등록 (Vue 3에서 변경됨)
Vue.component('GlobalButton', {
  template: '<button class="global-btn"><slot></slot></button>'
})

// 전역 디렉티브 등록 (Vue 3에서 변경됨)
Vue.directive('focus', {
  inserted(el) {
    el.focus()
  }
})

// 전역 믹스인 (Vue 3에서 권장하지 않음)
Vue.mixin({
  created() {
    console.log('Global mixin created')
  }
})

// 전역 설정 (Vue 3에서 변경됨)
Vue.config.productionTip = false
Vue.config.errorHandler = (err) => console.error(err)

new Vue({
  render: h => h(App)
}).$mount('#app')
`

// [나쁜 예시] Vue 2 v-model 사용
const Vue2VModelExample = `
// CustomInput.vue (Vue 2 스타일)
<template>
  <input
    :value="value"
    @input="$emit('input', $event.target.value)"
  />
</template>

<script>
export default {
  props: ['value']  // Vue 3에서는 'modelValue'
}
</script>

// 부모 컴포넌트
<template>
  <CustomInput v-model="username" />
</template>
`

// [나쁜 예시] 이벤트 버스 패턴 (Vue 3에서 제거됨)
const Vue2EventBusExample = `
// eventBus.js (Vue 3에서 작동 안 함!)
import Vue from 'vue'
export const EventBus = new Vue()

// ComponentA.vue
EventBus.$emit('user-logged-in', userData)

// ComponentB.vue
EventBus.$on('user-logged-in', (userData) => {
  this.user = userData
})
`

// [나쁜 예시] 필터 사용 (Vue 3에서 제거됨)
const Vue2FilterExample = `
// main.js
Vue.filter('currency', function(value) {
  return '₩' + value.toLocaleString()
})

// template
<template>
  <p>{{ price | currency }}</p>  <!-- Vue 3에서 작동 안 함 -->
</template>
`

// ============================================================
// 3. 좋은 예시: Vue 3 호환 코드 / 마이그레이션
// ============================================================

// [좋은 예시] Vue 3 스타일 전역 API
const Vue3GlobalExample = `
// main.js (Vue 3 스타일)
import { createApp } from 'vue'
import App from './App.vue'

const app = createApp(App)

// 애플리케이션 인스턴스에 등록
app.component('GlobalButton', {
  template: '<button class="global-btn"><slot></slot></button>'
})

app.directive('focus', {
  mounted(el) {  // inserted → mounted
    el.focus()
  }
})

// 전역 설정
app.config.errorHandler = (err) => console.error(err)

app.mount('#app')
`

// [좋은 예시] Vue 3 v-model 마이그레이션
const Vue3VModelExample = `
// CustomInput.vue (Vue 3 스타일)
<template>
  <input
    :value="modelValue"
    @input="$emit('update:modelValue', $event.target.value)"
  />
</template>

<script>
export default {
  props: ['modelValue'],  // value → modelValue
  emits: ['update:modelValue']  // 명시적 이벤트 선언
}
</script>

// 또는 Composition API 사용
<script setup>
defineProps(['modelValue'])
defineEmits(['update:modelValue'])
</script>
`

// [좋은 예시] 이벤트 버스 대체 - mitt 라이브러리 사용
const Vue3EventBusAlternative = `
// eventBus.js (mitt 라이브러리 사용)
import mitt from 'mitt'
export const emitter = mitt()

// ComponentA.vue
import { emitter } from './eventBus'
emitter.emit('user-logged-in', userData)

// ComponentB.vue
import { emitter } from './eventBus'
import { onMounted, onUnmounted } from 'vue'

onMounted(() => {
  emitter.on('user-logged-in', handleLogin)
})

onUnmounted(() => {
  emitter.off('user-logged-in', handleLogin)
})

// 또는 Provide/Inject 사용 (권장)
// App.vue
import { provide, reactive } from 'vue'
const state = reactive({ user: null })
provide('userState', state)

// ChildComponent.vue
import { inject } from 'vue'
const userState = inject('userState')
`

// [좋은 예시] 필터 대체 - 계산된 속성 또는 메서드 사용
const Vue3FilterAlternative = `
// Vue 3 스타일 - 메서드 또는 계산된 속성 사용
<template>
  <p>{{ formatCurrency(price) }}</p>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps(['price'])

// 방법 1: 메서드
function formatCurrency(value) {
  return '₩' + value.toLocaleString()
}

// 방법 2: 계산된 속성
const formattedPrice = computed(() => {
  return '₩' + props.price.toLocaleString()
})
</script>

// 전역 유틸리티 함수로 분리 (권장)
// utils/formatters.js
export function currency(value) {
  return '₩' + value.toLocaleString()
}
`

// ============================================================
// 4. 호환성 빌드를 사용한 점진적 마이그레이션
// ============================================================

const MigrationWithCompatBuild = `
/**
 * @vue/compat 호환성 빌드 사용 가이드
 *
 * Vue 3 호환성 빌드를 사용하면 Vue 2 코드를 Vue 3 환경에서
 * 실행하면서 점진적으로 마이그레이션할 수 있습니다.
 */

// Step 1: 패키지 설치
// npm install vue@3 @vue/compat
// npm install --save-dev @vue/compiler-sfc

// Step 2: vue.config.js 설정
module.exports = {
  chainWebpack: (config) => {
    config.resolve.alias.set('vue', '@vue/compat')

    config.module
      .rule('vue')
      .use('vue-loader')
      .tap((options) => {
        return {
          ...options,
          compilerOptions: {
            compatConfig: {
              MODE: 2  // Vue 2 호환 모드
            }
          }
        }
      })
  }
}

// Step 3: main.js 설정
import { createApp, configureCompat } from 'vue'
import App from './App.vue'

// 호환성 경고 설정
configureCompat({
  // 전역 설정으로 특정 기능의 호환성 모드 변경
  COMPONENT_V_MODEL: false,        // v-model 새 방식 사용
  INSTANCE_EVENT_EMITTER: false,   // $on/$off/$once 사용 금지
  OPTIONS_DATA_FN: false,          // data는 반드시 함수
  GLOBAL_MOUNT: false              // 새로운 마운트 방식 사용
})

const app = createApp(App)
app.mount('#app')

// Step 4: 컴포넌트별로 호환성 설정
// MyComponent.vue
export default {
  compatConfig: {
    MODE: 3,  // 이 컴포넌트는 Vue 3 모드로 실행
    COMPONENT_V_MODEL: false
  },
  // ...
}
`

// ============================================================
// 5. 주요 Breaking Changes 대응 체크리스트
// ============================================================

const MigrationChecklist = `
/**
 * Vue 2 → Vue 3 마이그레이션 체크리스트
 */

// ✅ 1. 전역 API 변경
// Before (Vue 2)
Vue.component('MyComponent', {...})
Vue.use(VueRouter)

// After (Vue 3)
const app = createApp(App)
app.component('MyComponent', {...})
app.use(router)


// ✅ 2. v-model 변경
// Before (Vue 2)
props: ['value']
this.$emit('input', newValue)

// After (Vue 3)
props: ['modelValue']
emit('update:modelValue', newValue)


// ✅ 3. 다중 v-model 지원 (Vue 3 새 기능)
// Vue 3에서는 여러 v-model 바인딩 가능
<UserForm
  v-model:name="userName"
  v-model:email="userEmail"
/>


// ✅ 4. 생명주기 훅 이름 변경
// Before (Vue 2)
beforeDestroy() {}
destroyed() {}

// After (Vue 3)
beforeUnmount() {}
unmounted() {}


// ✅ 5. $listeners 제거
// Before (Vue 2)
v-on="$listeners"

// After (Vue 3)
// $attrs에 통합됨


// ✅ 6. 렌더 함수 변경
// Before (Vue 2)
render(h) {
  return h('div', {}, this.text)
}

// After (Vue 3)
import { h } from 'vue'
render() {
  return h('div', {}, this.text)
}


// ✅ 7. Slot 문법 변경
// Before (Vue 2)
<template slot="header" slot-scope="{ data }">

// After (Vue 3)
<template #header="{ data }">


// ✅ 8. 비동기 컴포넌트 정의
// Before (Vue 2)
const AsyncComp = () => import('./MyComponent.vue')

// After (Vue 3)
import { defineAsyncComponent } from 'vue'
const AsyncComp = defineAsyncComponent(() =>
  import('./MyComponent.vue')
)


// ✅ 9. Vuex → Pinia 마이그레이션 (권장)
// Pinia는 Vue 3의 공식 상태 관리 라이브러리
// Vuex 4도 사용 가능하지만 Pinia 권장


// ✅ 10. Vue Router 3 → 4 마이그레이션
// Before (Vue 2 + Vue Router 3)
new VueRouter({ routes })

// After (Vue 3 + Vue Router 4)
import { createRouter, createWebHistory } from 'vue-router'
const router = createRouter({
  history: createWebHistory(),
  routes
})
`

// ============================================================
// 6. 마이그레이션 순서 권장
// ============================================================

const MigrationOrder = `
/**
 * 권장 마이그레이션 순서
 *
 * 1단계: 준비
 * - Vue 2.7로 업그레이드 (Composition API 사용 가능)
 * - ESLint 규칙으로 deprecated API 감지
 * - 테스트 커버리지 확인
 *
 * 2단계: 호환성 빌드 적용
 * - @vue/compat 설치 및 설정
 * - 호환성 경고 확인 및 수정
 *
 * 3단계: 컴포넌트 마이그레이션
 * - 컴포넌트별로 MODE: 3 설정
 * - Options API → Composition API 변환 (선택)
 *
 * 4단계: 의존성 업그레이드
 * - Vue Router 4로 업그레이드
 * - Vuex 4 또는 Pinia로 전환
 * - 기타 Vue 관련 라이브러리 업데이트
 *
 * 5단계: 호환성 빌드 제거
 * - vue에서 @vue/compat 별칭 제거
 * - 최종 테스트
 */
`

// ============================================================
// 학습 포인트 요약
// ============================================================

/*
 * 1. 주요 Breaking Changes:
 *    - 전역 API 변경 (Vue.xxx → app.xxx)
 *    - v-model 변경 (value/input → modelValue/update:modelValue)
 *    - 이벤트 API 제거 ($on, $off, $once)
 *    - 필터 제거
 *    - 생명주기 훅 이름 변경
 *
 * 2. 점진적 마이그레이션 전략:
 *    - @vue/compat 호환성 빌드 사용
 *    - 컴포넌트별로 Vue 3 모드 전환
 *    - 경고 메시지 기반으로 수정
 *
 * 3. 대체 패턴:
 *    - 이벤트 버스 → mitt 라이브러리 또는 Provide/Inject
 *    - 필터 → 메서드 또는 계산된 속성
 *    - Mixins → Composables
 *
 * 4. 권장 사항:
 *    - 먼저 Vue 2.7로 업그레이드
 *    - Composition API 미리 익히기
 *    - 테스트 커버리지 확보 후 마이그레이션
 */

export {
  Vue2GlobalExample,
  Vue2VModelExample,
  Vue2EventBusExample,
  Vue2FilterExample,
  Vue3GlobalExample,
  Vue3VModelExample,
  Vue3EventBusAlternative,
  Vue3FilterAlternative,
  MigrationWithCompatBuild,
  MigrationChecklist,
  MigrationOrder
}

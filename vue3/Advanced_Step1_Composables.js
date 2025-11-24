/**
 * Advanced Step 1: Vue 3 Composables 패턴 심화
 *
 * 이 파일은 Vue 3의 핵심 기능인 Composables(컴포저블) 패턴을 심층적으로 학습합니다.
 * 재사용 가능한 로직을 효과적으로 추출하고 공유하는 방법을 배웁니다.
 *
 * 학습 목표:
 * 1. Composables의 개념과 Mixins과의 차이점
 * 2. 재사용 가능한 Composable 함수 설계
 * 3. VueUse 라이브러리 활용
 * 4. 고급 Composable 패턴
 *
 * @author Learning Code Project
 */

// ============================================================
// 1. Mixins vs Composables 비교
// ============================================================

// [나쁜 예시] Vue 2 Mixins 사용의 문제점
const Vue2MixinProblems = `
// counterMixin.js
export const counterMixin = {
  data() {
    return {
      count: 0  // 이름 충돌 위험!
    }
  },
  methods: {
    increment() {  // 어디서 왔는지 불명확
      this.count++
    }
  }
}

// anotherMixin.js
export const anotherMixin = {
  data() {
    return {
      count: 100  // 이름 충돌 발생!
    }
  }
}

// MyComponent.vue
export default {
  mixins: [counterMixin, anotherMixin],  // 어떤 count가 사용될지 불명확
  methods: {
    doSomething() {
      this.increment()  // 어떤 mixin의 메서드인지 추적 어려움
    }
  }
}

/*
 * Mixins의 문제점:
 * 1. 이름 충돌 위험 (암시적 병합)
 * 2. 데이터/메서드 출처 불명확
 * 3. 타입스크립트 지원 어려움
 * 4. 여러 mixin 간 의존성 추적 어려움
 */
`

// [좋은 예시] Vue 3 Composables 사용
const Vue3ComposablesExample = `
// composables/useCounter.js
import { ref, computed } from 'vue'

/**
 * 카운터 로직을 캡슐화한 Composable
 *
 * @param {number} initialValue - 초기값
 * @returns {Object} 카운터 상태와 메서드
 */
export function useCounter(initialValue = 0) {
  // 반응형 상태
  const count = ref(initialValue)

  // 계산된 속성
  const doubleCount = computed(() => count.value * 2)
  const isPositive = computed(() => count.value > 0)

  // 메서드
  function increment() {
    count.value++
  }

  function decrement() {
    count.value--
  }

  function reset() {
    count.value = initialValue
  }

  // 명시적 반환 (무엇을 노출하는지 명확)
  return {
    count,
    doubleCount,
    isPositive,
    increment,
    decrement,
    reset
  }
}

// MyComponent.vue
<script setup>
import { useCounter } from '@/composables/useCounter'

// 명시적으로 사용, 이름 변경 가능 (충돌 방지)
const { count, increment, decrement } = useCounter(10)
const { count: otherCount, increment: otherIncrement } = useCounter(100)
</script>

<template>
  <div>
    <p>Count: {{ count }}</p>
    <button @click="increment">+</button>
    <button @click="decrement">-</button>

    <p>Other Count: {{ otherCount }}</p>
    <button @click="otherIncrement">+</button>
  </div>
</template>

/*
 * Composables의 장점:
 * 1. 명시적 import로 출처 명확
 * 2. 이름 변경으로 충돌 방지
 * 3. 완벽한 TypeScript 지원
 * 4. 테스트 용이
 */
`

// ============================================================
// 2. 실용적인 Composable 예제들
// ============================================================

// [좋은 예시] API 데이터 페칭 Composable
const useFetchComposable = `
// composables/useFetch.js
import { ref, watchEffect, toValue } from 'vue'

/**
 * 데이터 페칭 로직을 캡슐화한 Composable
 *
 * @param {string|Ref<string>} url - API URL (반응형 가능)
 * @returns {Object} 데이터, 로딩, 에러 상태
 */
export function useFetch(url) {
  const data = ref(null)
  const error = ref(null)
  const isLoading = ref(false)

  async function fetchData() {
    isLoading.value = true
    error.value = null

    try {
      const response = await fetch(toValue(url))  // toValue로 ref/일반값 모두 처리

      if (!response.ok) {
        throw new Error(\`HTTP error! status: \${response.status}\`)
      }

      data.value = await response.json()
    } catch (e) {
      error.value = e.message
    } finally {
      isLoading.value = false
    }
  }

  // URL이 변경되면 자동으로 다시 페칭
  watchEffect(() => {
    fetchData()
  })

  // 수동 리페치 함수도 제공
  function refetch() {
    return fetchData()
  }

  return { data, error, isLoading, refetch }
}

// 사용 예시
<script setup>
import { ref } from 'vue'
import { useFetch } from '@/composables/useFetch'

const userId = ref(1)
const apiUrl = computed(() => \`/api/users/\${userId.value}\`)

// URL이 변경되면 자동으로 다시 페칭됨
const { data: user, error, isLoading, refetch } = useFetch(apiUrl)
</script>

<template>
  <div v-if="isLoading">로딩 중...</div>
  <div v-else-if="error">에러: {{ error }}</div>
  <div v-else>
    <h2>{{ user?.name }}</h2>
    <button @click="userId++">다음 사용자</button>
    <button @click="refetch">새로고침</button>
  </div>
</template>
`

// [좋은 예시] 로컬 스토리지 동기화 Composable
const useLocalStorageComposable = `
// composables/useLocalStorage.js
import { ref, watch } from 'vue'

/**
 * 로컬 스토리지와 동기화되는 반응형 상태
 *
 * @param {string} key - 스토리지 키
 * @param {any} defaultValue - 기본값
 * @returns {Ref} 반응형 상태 (자동 저장)
 */
export function useLocalStorage(key, defaultValue) {
  // 초기값: 로컬 스토리지에서 읽거나 기본값 사용
  const storedValue = localStorage.getItem(key)
  const initialValue = storedValue ? JSON.parse(storedValue) : defaultValue

  const state = ref(initialValue)

  // 값이 변경되면 로컬 스토리지에 저장
  watch(
    state,
    (newValue) => {
      if (newValue === null || newValue === undefined) {
        localStorage.removeItem(key)
      } else {
        localStorage.setItem(key, JSON.stringify(newValue))
      }
    },
    { deep: true }  // 객체 내부 변경도 감지
  )

  return state
}

// 사용 예시
<script setup>
import { useLocalStorage } from '@/composables/useLocalStorage'

// 페이지 새로고침해도 값 유지
const theme = useLocalStorage('app-theme', 'light')
const userSettings = useLocalStorage('user-settings', {
  notifications: true,
  language: 'ko'
})

function toggleTheme() {
  theme.value = theme.value === 'light' ? 'dark' : 'light'
}
</script>
`

// [좋은 예시] 마우스 위치 추적 Composable
const useMouseComposable = `
// composables/useMouse.js
import { ref, onMounted, onUnmounted } from 'vue'

/**
 * 마우스 위치를 추적하는 Composable
 *
 * @returns {Object} x, y 좌표
 */
export function useMouse() {
  const x = ref(0)
  const y = ref(0)

  function updatePosition(event) {
    x.value = event.clientX
    y.value = event.clientY
  }

  onMounted(() => {
    window.addEventListener('mousemove', updatePosition)
  })

  onUnmounted(() => {
    window.removeEventListener('mousemove', updatePosition)
  })

  return { x, y }
}

// 사용 예시
<script setup>
import { useMouse } from '@/composables/useMouse'

const { x, y } = useMouse()
</script>

<template>
  <div>마우스 위치: ({{ x }}, {{ y }})</div>
</template>
`

// [좋은 예시] 디바운스/쓰로틀 Composable
const useDebounceComposable = `
// composables/useDebounce.js
import { ref, watch } from 'vue'

/**
 * 디바운스된 반응형 값을 반환
 *
 * @param {Ref} value - 원본 반응형 값
 * @param {number} delay - 디바운스 지연 시간 (ms)
 * @returns {Ref} 디바운스된 값
 */
export function useDebounce(value, delay = 300) {
  const debouncedValue = ref(value.value)
  let timeoutId

  watch(value, (newValue) => {
    clearTimeout(timeoutId)
    timeoutId = setTimeout(() => {
      debouncedValue.value = newValue
    }, delay)
  })

  return debouncedValue
}

// 사용 예시 - 검색어 입력
<script setup>
import { ref, watch } from 'vue'
import { useDebounce } from '@/composables/useDebounce'
import { useFetch } from '@/composables/useFetch'

const searchQuery = ref('')
const debouncedQuery = useDebounce(searchQuery, 500)

// debouncedQuery가 변경될 때만 API 호출
const searchUrl = computed(() =>
  debouncedQuery.value ? \`/api/search?q=\${debouncedQuery.value}\` : null
)

const { data: results, isLoading } = useFetch(searchUrl)
</script>

<template>
  <input v-model="searchQuery" placeholder="검색어 입력..." />
  <div v-if="isLoading">검색 중...</div>
  <ul v-else>
    <li v-for="item in results" :key="item.id">{{ item.name }}</li>
  </ul>
</template>
`

// ============================================================
// 3. VueUse 라이브러리 활용
// ============================================================

const VueUseExamples = `
/**
 * VueUse - Vue Composition API 유틸리티 모음
 * https://vueuse.org/
 *
 * 200개 이상의 유용한 Composable 함수 제공
 */

// 설치
// npm install @vueuse/core

// 주요 함수 예시
<script setup>
import {
  useMouse,           // 마우스 위치
  useLocalStorage,    // 로컬 스토리지
  useDark,            // 다크 모드
  useClipboard,       // 클립보드
  useWindowSize,      // 윈도우 크기
  useIntersectionObserver, // Intersection Observer
  useFetch,           // 데이터 페칭
  useDebounce,        // 디바운스
  useThrottleFn,      // 쓰로틀
  onClickOutside,     // 외부 클릭 감지
  useEventListener,   // 이벤트 리스너
} from '@vueuse/core'

// 1. 다크 모드 토글
const isDark = useDark()
const toggleDark = useToggle(isDark)

// 2. 클립보드 복사
const { copy, copied } = useClipboard()
async function copyText(text) {
  await copy(text)
  // copied.value가 일시적으로 true가 됨
}

// 3. 윈도우 크기 반응형
const { width, height } = useWindowSize()
const isMobile = computed(() => width.value < 768)

// 4. 무한 스크롤 (Intersection Observer)
const target = ref(null)
const { stop } = useIntersectionObserver(
  target,
  ([{ isIntersecting }]) => {
    if (isIntersecting) {
      loadMore()  // 더 불러오기
    }
  }
)

// 5. 외부 클릭 감지 (드롭다운 닫기)
const dropdown = ref(null)
const isOpen = ref(false)
onClickOutside(dropdown, () => {
  isOpen.value = false
})
</script>

<template>
  <button @click="toggleDark()">
    {{ isDark ? '🌙' : '☀️' }}
  </button>

  <div>화면 크기: {{ width }} x {{ height }}</div>
  <div v-if="isMobile">모바일 뷰</div>

  <div ref="dropdown" v-show="isOpen">
    드롭다운 메뉴
  </div>

  <div ref="target">무한 스크롤 트리거</div>
</template>
`

// ============================================================
// 4. 고급 Composable 패턴
// ============================================================

const AdvancedPatterns = `
// Pattern 1: 옵션 객체 패턴
export function useCounter(options = {}) {
  const {
    initialValue = 0,
    min = -Infinity,
    max = Infinity,
    step = 1
  } = options

  const count = ref(initialValue)

  function increment() {
    if (count.value + step <= max) {
      count.value += step
    }
  }

  function decrement() {
    if (count.value - step >= min) {
      count.value -= step
    }
  }

  return { count, increment, decrement }
}

// 사용
const { count } = useCounter({
  initialValue: 10,
  min: 0,
  max: 100,
  step: 5
})


// Pattern 2: Composable 조합
export function useUserProfile(userId) {
  const { data: user, isLoading: userLoading } = useFetch(
    computed(() => \`/api/users/\${userId.value}\`)
  )

  const { data: posts, isLoading: postsLoading } = useFetch(
    computed(() => \`/api/users/\${userId.value}/posts\`)
  )

  const isLoading = computed(() => userLoading.value || postsLoading.value)

  return {
    user,
    posts,
    isLoading
  }
}


// Pattern 3: 팩토리 패턴
export function createSharedComposable(composable) {
  let subscribers = 0
  let state, scope

  const dispose = () => {
    subscribers -= 1
    if (scope && subscribers <= 0) {
      scope.stop()
      state = undefined
      scope = undefined
    }
  }

  return (...args) => {
    subscribers += 1
    if (!state) {
      scope = effectScope(true)
      state = scope.run(() => composable(...args))
    }
    onScopeDispose(dispose)
    return state
  }
}

// 싱글톤 Composable 생성
const useSharedMouse = createSharedComposable(useMouse)
// 여러 컴포넌트에서 호출해도 하나의 이벤트 리스너만 사용


// Pattern 4: 비동기 Composable with Suspense
export function useAsyncData(fetchFn) {
  const data = ref(null)
  const error = ref(null)

  // Suspense와 함께 사용
  const promise = fetchFn()
    .then(result => {
      data.value = result
    })
    .catch(err => {
      error.value = err
    })

  // async setup에서 await 가능
  return { data, error, promise }
}

// 사용 (async setup)
<script setup>
const { data } = useAsyncData(() => fetch('/api/data').then(r => r.json()))
await data.promise
</script>
`

// ============================================================
// 5. TypeScript와 Composables
// ============================================================

const TypeScriptComposables = `
// composables/useCounter.ts
import { ref, computed, type Ref, type ComputedRef } from 'vue'

interface UseCounterOptions {
  initialValue?: number
  min?: number
  max?: number
}

interface UseCounterReturn {
  count: Ref<number>
  doubleCount: ComputedRef<number>
  increment: () => void
  decrement: () => void
  reset: () => void
}

export function useCounter(options: UseCounterOptions = {}): UseCounterReturn {
  const { initialValue = 0, min = -Infinity, max = Infinity } = options

  const count = ref(initialValue)
  const doubleCount = computed(() => count.value * 2)

  function increment(): void {
    if (count.value < max) {
      count.value++
    }
  }

  function decrement(): void {
    if (count.value > min) {
      count.value--
    }
  }

  function reset(): void {
    count.value = initialValue
  }

  return {
    count,
    doubleCount,
    increment,
    decrement,
    reset
  }
}
`

// ============================================================
// 학습 포인트 요약
// ============================================================

/*
 * 1. Composables vs Mixins:
 *    - Composables: 명시적, 타입 안전, 이름 충돌 없음
 *    - Mixins: 암시적 병합, 이름 충돌 위험, 출처 불명확
 *
 * 2. Composable 설계 원칙:
 *    - 단일 책임 원칙 (하나의 기능만)
 *    - 명시적 반환 (무엇을 노출하는지 명확)
 *    - 재사용성 고려 (옵션 객체 패턴)
 *
 * 3. 주요 패턴:
 *    - useFetch: 데이터 페칭
 *    - useLocalStorage: 로컬 스토리지 동기화
 *    - useDebounce: 입력 디바운싱
 *    - useMouse: 마우스 추적
 *
 * 4. VueUse 라이브러리:
 *    - 200+ 유틸리티 Composables
 *    - useDark, useClipboard, useIntersectionObserver 등
 *
 * 5. 고급 패턴:
 *    - 옵션 객체 패턴
 *    - Composable 조합
 *    - 팩토리 패턴 (싱글톤)
 *    - TypeScript 통합
 */

export {
  Vue2MixinProblems,
  Vue3ComposablesExample,
  useFetchComposable,
  useLocalStorageComposable,
  useMouseComposable,
  useDebounceComposable,
  VueUseExamples,
  AdvancedPatterns,
  TypeScriptComposables
}

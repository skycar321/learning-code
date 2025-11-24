# 프론트엔드 프레임워크 비교: React vs Vue 2 vs Vue 3

> React, Vue 2, Vue 3의 핵심 개념과 패턴을 비교하여 각 프레임워크의 특징을 이해합니다.

---

## 1. 프레임워크 철학

| 항목 | React | Vue 2 | Vue 3 |
|:-----|:------|:------|:------|
| **패러다임** | 라이브러리 (View 레이어) | 프로그레시브 프레임워크 | 프로그레시브 프레임워크 |
| **데이터 바인딩** | 단방향 (One-way) | 양방향 (Two-way) | 양방향 (Two-way) |
| **컴포넌트 작성** | JSX (JavaScript + HTML) | SFC (Single File Component) | SFC + Composition API |
| **상태 관리** | useState, Redux, Zustand | Vuex, data() | Pinia, ref(), reactive() |
| **렌더링** | Virtual DOM | Virtual DOM | Virtual DOM (최적화됨) |

---

## 2. 컴포넌트 정의 비교

### React (Functional Component + Hooks)
```jsx
// React - 함수형 컴포넌트와 Hooks
import React, { useState, useEffect } from 'react';

// 좋은 예시: 함수형 컴포넌트 + Hooks 사용
function Counter() {
    // useState로 상태 관리
    const [count, setCount] = useState(0);

    // useEffect로 사이드 이펙트 처리
    useEffect(() => {
        document.title = `Count: ${count}`;

        // 클린업 함수
        return () => {
            console.log('컴포넌트 언마운트 또는 의존성 변경');
        };
    }, [count]); // 의존성 배열

    return (
        <div>
            <p>카운트: {count}</p>
            <button onClick={() => setCount(count + 1)}>증가</button>
        </div>
    );
}

export default Counter;
```

### Vue 2 (Options API)
```vue
<!-- Vue 2 - Options API -->
<template>
    <div>
        <p>카운트: {{ count }}</p>
        <button @click="increment">증가</button>
    </div>
</template>

<script>
// 좋은 예시: Options API로 명확한 구조
export default {
    name: 'Counter',

    // 컴포넌트 상태
    data() {
        return {
            count: 0
        };
    },

    // 계산된 속성
    computed: {
        doubleCount() {
            return this.count * 2;
        }
    },

    // 메서드
    methods: {
        increment() {
            this.count++;
        }
    },

    // 라이프사이클 훅
    mounted() {
        document.title = `Count: ${this.count}`;
    },

    watch: {
        count(newVal) {
            document.title = `Count: ${newVal}`;
        }
    }
};
</script>
```

### Vue 3 (Composition API)
```vue
<!-- Vue 3 - Composition API -->
<template>
    <div>
        <p>카운트: {{ count }}</p>
        <button @click="increment">증가</button>
    </div>
</template>

<script setup>
// 좋은 예시: Composition API로 로직 재사용성 향상
import { ref, computed, watch, onMounted, onUnmounted } from 'vue';

// 반응형 상태
const count = ref(0);

// 계산된 속성
const doubleCount = computed(() => count.value * 2);

// 메서드
function increment() {
    count.value++;
}

// 라이프사이클 훅
onMounted(() => {
    document.title = `Count: ${count.value}`;
});

// 감시자
watch(count, (newVal) => {
    document.title = `Count: ${newVal}`;
});

// 클린업
onUnmounted(() => {
    console.log('컴포넌트 언마운트');
});
</script>
```

---

## 3. 상태 관리 비교

### 나쁜 예시: Prop Drilling

```jsx
// React - 나쁜 예시: 깊은 Prop 전달
function App() {
    const [user, setUser] = useState({ name: 'Kim' });
    return <Parent user={user} setUser={setUser} />;
}
function Parent({ user, setUser }) {
    return <Child user={user} setUser={setUser} />;
}
function Child({ user, setUser }) {
    return <GrandChild user={user} setUser={setUser} />;
}
// 여러 단계를 거쳐 props 전달 - 유지보수 어려움
```

### 좋은 예시: 전역 상태 관리

#### React (Zustand)
```jsx
// React - 좋은 예시: Zustand로 전역 상태 관리
import { create } from 'zustand';

// 스토어 정의
const useUserStore = create((set) => ({
    user: { name: 'Kim' },
    setUser: (user) => set({ user }),
    updateName: (name) => set((state) => ({
        user: { ...state.user, name }
    }))
}));

// 컴포넌트에서 사용
function UserProfile() {
    const { user, updateName } = useUserStore();
    return (
        <div>
            <p>{user.name}</p>
            <button onClick={() => updateName('Lee')}>이름 변경</button>
        </div>
    );
}
```

#### Vue 2 (Vuex)
```javascript
// Vue 2 - 좋은 예시: Vuex로 상태 관리
// store/index.js
import Vue from 'vue';
import Vuex from 'vuex';

Vue.use(Vuex);

export default new Vuex.Store({
    state: {
        user: { name: 'Kim' }
    },
    mutations: {
        SET_USER(state, user) {
            state.user = user;
        },
        UPDATE_NAME(state, name) {
            state.user.name = name;
        }
    },
    actions: {
        updateUser({ commit }, user) {
            commit('SET_USER', user);
        }
    },
    getters: {
        userName: (state) => state.user.name
    }
});
```

#### Vue 3 (Pinia)
```javascript
// Vue 3 - 좋은 예시: Pinia로 상태 관리
import { defineStore } from 'pinia';

export const useUserStore = defineStore('user', {
    state: () => ({
        user: { name: 'Kim' }
    }),

    getters: {
        userName: (state) => state.user.name
    },

    actions: {
        updateName(name) {
            this.user.name = name;
        }
    }
});

// 컴포넌트에서 사용
// <script setup>
import { useUserStore } from '@/stores/user';
const userStore = useUserStore();
// userStore.userName, userStore.updateName('Lee')
```

---

## 4. 조건부 렌더링 비교

### React
```jsx
// React - JSX 내에서 JavaScript 표현식 사용
function ConditionalRender({ isLoggedIn, role }) {
    return (
        <div>
            {/* 삼항 연산자 */}
            {isLoggedIn ? <UserDashboard /> : <LoginForm />}

            {/* 논리 AND 연산자 */}
            {isLoggedIn && <LogoutButton />}

            {/* 복잡한 조건 */}
            {role === 'admin' && <AdminPanel />}
            {role === 'user' && <UserPanel />}
            {role === 'guest' && <GuestPanel />}
        </div>
    );
}
```

### Vue 2 / Vue 3
```vue
<!-- Vue - 디렉티브 사용 -->
<template>
    <div>
        <!-- v-if / v-else -->
        <UserDashboard v-if="isLoggedIn" />
        <LoginForm v-else />

        <!-- v-show (CSS display로 토글) -->
        <LogoutButton v-show="isLoggedIn" />

        <!-- v-if / v-else-if / v-else -->
        <AdminPanel v-if="role === 'admin'" />
        <UserPanel v-else-if="role === 'user'" />
        <GuestPanel v-else />
    </div>
</template>
```

---

## 5. 리스트 렌더링 비교

### React
```jsx
// React - map() 함수 사용
function TodoList({ todos }) {
    return (
        <ul>
            {todos.map((todo) => (
                // key는 필수! 고유한 값 사용
                <li key={todo.id}>
                    <span>{todo.text}</span>
                    <span>{todo.completed ? '완료' : '미완료'}</span>
                </li>
            ))}
        </ul>
    );
}
```

### Vue 2 / Vue 3
```vue
<!-- Vue - v-for 디렉티브 사용 -->
<template>
    <ul>
        <!-- :key는 필수! 고유한 값 사용 -->
        <li v-for="todo in todos" :key="todo.id">
            <span>{{ todo.text }}</span>
            <span>{{ todo.completed ? '완료' : '미완료' }}</span>
        </li>
    </ul>
</template>
```

---

## 6. 이벤트 핸들링 비교

| 기능 | React | Vue 2/3 |
|:-----|:------|:--------|
| **클릭** | `onClick={handler}` | `@click="handler"` |
| **입력** | `onChange={handler}` | `@input="handler"` 또는 `v-model` |
| **제출** | `onSubmit={handler}` | `@submit="handler"` |
| **이벤트 전파 중단** | `e.stopPropagation()` | `@click.stop` |
| **기본 동작 방지** | `e.preventDefault()` | `@submit.prevent` |
| **키 이벤트** | `onKeyDown` + 조건 검사 | `@keyup.enter` |

### 이벤트 예시

```jsx
// React
function Form() {
    const handleSubmit = (e) => {
        e.preventDefault();
        // 폼 처리
    };

    return (
        <form onSubmit={handleSubmit}>
            <input
                type="text"
                onChange={(e) => console.log(e.target.value)}
                onKeyDown={(e) => e.key === 'Enter' && handleSubmit(e)}
            />
            <button type="submit">제출</button>
        </form>
    );
}
```

```vue
<!-- Vue -->
<template>
    <form @submit.prevent="handleSubmit">
        <input
            type="text"
            v-model="inputValue"
            @keyup.enter="handleSubmit"
        />
        <button type="submit">제출</button>
    </form>
</template>
```

---

## 7. Props와 Emit 비교

### React
```jsx
// React - Props와 콜백 함수
function Parent() {
    const [message, setMessage] = useState('안녕');

    const handleUpdate = (newMessage) => {
        setMessage(newMessage);
    };

    return (
        <Child
            message={message}
            onUpdate={handleUpdate}
        />
    );
}

function Child({ message, onUpdate }) {
    return (
        <div>
            <p>{message}</p>
            <button onClick={() => onUpdate('변경됨')}>변경</button>
        </div>
    );
}
```

### Vue 3
```vue
<!-- Vue 3 - Props와 Emit -->
<!-- Parent.vue -->
<template>
    <Child :message="message" @update="handleUpdate" />
</template>

<script setup>
import { ref } from 'vue';

const message = ref('안녕');

function handleUpdate(newMessage) {
    message.value = newMessage;
}
</script>

<!-- Child.vue -->
<template>
    <div>
        <p>{{ message }}</p>
        <button @click="emit('update', '변경됨')">변경</button>
    </div>
</template>

<script setup>
defineProps(['message']);
const emit = defineEmits(['update']);
</script>
```

---

## 8. 성능 최적화 비교

| 기법 | React | Vue 2 | Vue 3 |
|:-----|:------|:------|:------|
| **메모이제이션** | `useMemo`, `useCallback` | `computed` | `computed` |
| **컴포넌트 캐싱** | `React.memo` | `keep-alive` | `keep-alive` |
| **지연 로딩** | `React.lazy` + `Suspense` | 비동기 컴포넌트 | `defineAsyncComponent` |
| **가상 스크롤** | react-virtualized | vue-virtual-scroller | vue-virtual-scroller |

---

## 9. 학습 포인트

| 항목 | React 특징 | Vue 특징 |
|:-----|:----------|:---------|
| **진입 장벽** | JSX 학습 필요, 자유도 높음 | 템플릿 문법 직관적, 구조화됨 |
| **생태계** | 선택지 많음 (자유도 vs 복잡도) | 공식 도구 중심 (일관성) |
| **타입스크립트** | 좋은 지원 | Vue 3에서 크게 개선 |
| **모바일** | React Native | Vue + Capacitor, NativeScript |
| **SSR** | Next.js | Nuxt.js |

---

## 10. 선택 가이드

| 상황 | 권장 프레임워크 |
|:-----|:----------------|
| 대규모 엔터프라이즈 앱 | React (생태계, 채용 시장) |
| 빠른 프로토타이핑 | Vue 3 (낮은 진입 장벽) |
| 기존 Vue 2 프로젝트 | Vue 3 마이그레이션 고려 |
| 함수형 프로그래밍 선호 | React (Hooks) |
| 템플릿 기반 선호 | Vue |
| React Native 필요 | React |

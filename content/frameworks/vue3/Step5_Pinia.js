// Vue3 Pinia (상태 관리)
// Vue3 권장 상태 관리 라이브러리 Pinia의 개념 및 활용

// 나쁜 예시: 전역 변수나 컴포넌트 간 직접적인 통신으로 복잡한 애플리케이션의 상태를 관리하여 디버깅이 어렵고 상태 변화 추적이 불가능.
// 좋은 예시: Pinia를 사용하여 애플리케이션의 모든 컴포넌트가 공유하는 상태를 중앙 집중식으로 관리하고, 모듈화된 스토어와 예측 가능한 상태 변화를 통해 안정적인 애플리케이션 구축.

// Pinia는 Vuex 5의 새로운 이름이며, Vue3에서 Vuex를 대체하는 것을 목표로 합니다.
// Vuex에 비해 더 가볍고, 더 직관적인 API, TypeScript 완벽 지원 등의 장점이 있습니다.

// 1. Pinia 설치 (npm 또는 CDN)
// npm: `npm install pinia`
// CDN: <script src="https://unpkg.com/pinia@2"></script> (예시)

// 2. Pinia Store 정의 (defineStore)
// defineStore 함수는 스토어의 ID와 옵션 객체를 받습니다.
const useCounterStore = Pinia.defineStore('counter', {
    // state는 스토어의 데이터를 정의합니다. (Vue 컴포넌트의 data와 유사)
    state: () => ({
        count: 0,
        name: 'Pinia User'
    }),
    // getters는 state를 기반으로 계산된 값을 제공합니다. (Vue 컴포넌트의 computed와 유사)
    getters: {
        doubleCount: (state) => state.count * 2,
        // 다른 getter를 참조할 수도 있습니다.
        doubleCountPlusOne() {
            return this.doubleCount + 1;
        },
        // getters는 항상 첫 번째 인자로 state를 받으며, 두 번째 인자로 다른 getters를 받습니다.
        // `this`로도 다른 getter에 접근할 수 있습니다.
    },
    // actions는 state를 변경하는 로직이나 비동기 작업을 수행합니다. (Vue 컴포넌트의 methods와 유사)
    actions: {
        increment() {
            this.count++; // `this`를 사용하여 state에 접근
        },
        decrement() {
            this.count--;
        },
        async incrementAndSayHello() {
            // 비동기 작업 예시
            await new Promise(resolve => setTimeout(resolve, 1000));
            this.increment();
            alert(`Count는 ${this.count}로 증가했습니다. 안녕하세요!`);
        },
        setCount(amount) {
            this.count = amount;
        }
    }
});

const useUserStore = Pinia.defineStore('user', {
    state: () => ({
        firstName: 'John',
        lastName: 'Doe'
    }),
    getters: {
        fullName: (state) => `${state.firstName} ${state.lastName}`
    },
    actions: {
        setFirstName(name) {
            this.firstName = name;
        },
        setLastName(name) {
            this.lastName = name;
        }
    }
});


// 3. Vue 앱 인스턴스 생성 및 Pinia 연결
const app = Vue.createApp({
    template: `
        <div id="app-pinia">
            <h1>Pinia 상태 관리 예시</h1>
            <counter-component></counter-component>
            <user-profile-component></user-profile-component>
        </div>
    `,
    components: {
        'counter-component': {
            template: `
                <div style="border: 1px solid gray; padding: 10px; margin: 10px;">
                    <h3>카운터 컴포넌트</h3>
                    <p>현재 카운트: {{ counterStore.count }}</p>
                    <p>두 배 카운트 (getter): {{ counterStore.doubleCount }}</p>
                    <p>두 배 카운트 + 1 (getter): {{ counterStore.doubleCountPlusOne }}</p>
                    <button @click="counterStore.increment">증가</button>
                    <button @click="counterStore.decrement">감소</button>
                    <button @click="counterStore.incrementAndSayHello">1초 후 증가 & 인사</button>
                    <button @click="counterStore.setCount(100)">100으로 설정</button>
                </div>
            `,
            setup() {
                const counterStore = useCounterStore(); // 스토어 사용

                // 스토어의 state를 반응성 속성으로 직접 참조할 경우 `storeToRefs` 사용 권장
                // const { count, name } = Pinia.storeToRefs(counterStore);

                return {
                    counterStore
                };
            }
        },
        'user-profile-component': {
            template: `
                <div style="border: 1px solid blue; padding: 10px; margin: 10px;">
                    <h3>사용자 프로필 컴포넌트</h3>
                    <p>이름: {{ userStore.fullName }}</p>
                    <p>스토어의 이름: {{ counterStore.name }}</p>
                    <input type="text" :value="userStore.firstName" @input="event => userStore.setFirstName(event.target.value)" placeholder="First Name">
                    <input type="text" :value="userStore.lastName" @input="event => userStore.setLastName(event.target.value)" placeholder="Last Name">
                    <input type="text" :value="counterStore.name" @input="event => counterStore.name = event.target.value" placeholder="Counter Store Name">
                </div>
            `,
            setup() {
                const userStore = useUserStore();
                const counterStore = useCounterStore(); // 다른 스토어 사용 가능

                return {
                    userStore,
                    counterStore
                };
            }
        }
    }
});

const pinia = Pinia.createPinia(); // Pinia 인스턴스 생성
app.use(pinia); // Pinia를 Vue 앱에 연결
app.mount('#app-pinia');

// Pinia의 주요 특징 및 장점:
// - 모듈화: 각 스토어가 독립적으로 작동하여 코드 구성이 용이합니다.
// - TypeScript 지원: Vuex보다 훨씬 강력한 TypeScript 지원을 제공합니다.
// - 가벼움: 초기 로드 시 `state`만 필요하며, `getters`와 `actions`는 필요할 때만 로드됩니다.
// - 단순한 API: Vue3 Composition API와 유사하게 `setup` 함수 내에서 `useStore()` 훅을 사용하여 쉽게 접근합니다.
// - 플러그인: 스토어 확장 기능을 제공합니다.
// - 서버 사이드 렌더링 (SSR) 지원.

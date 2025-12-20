// Vue3 시작하기 (Composition API)
// Vue 인스턴스, 반응성, `setup` 함수, `ref`, `reactive` 등 Vue3 핵심 개념 이해

// 나쁜 예시: Options API 방식으로 복잡한 로직을 작성하여 컴포넌트의 가독성과 재사용성을 떨어뜨립니다.
// 좋은 예시: Composition API를 활용하여 관련 로직을 한데 모으고, 훅(hook) 형태로 재사용 가능한 로직을 추출합니다.

// Vue CDN을 통한 Vue3 로드 (예시)
// <script src="https://unpkg.com/vue@3"></script>

// Composition API 사용을 위한 import (Vue CLI 또는 Vite 프로젝트에서는 자동으로 처리)
// const { createApp, ref, reactive, computed, watch, onMounted, onUnmounted } = Vue;

// --- 1. setup() 함수 ---
// 컴포넌트 옵션(data, methods, computed 등)을 대체하여 로직을 구성하는 진입점
// 컴포넌트가 생성되기 전에 실행됩니다.

// --- 2. 반응성 (Reactivity) ---
// `ref`와 `reactive`를 사용하여 반응성 데이터를 생성합니다.

// ref(): 원시 값 (Primitive values)을 반응성으로 만들 때 사용. `.value`로 값에 접근.
const count = Vue.ref(0);
// reactive(): 객체 (Objects)를 반응성으로 만들 때 사용. `.value` 없이 직접 접근.
const state = Vue.reactive({
    message: 'Hello, Vue3!',
    person: {
        name: '김철수',
        age: 30
    }
});

// --- 3. Computed 속성 ---
// `computed`를 사용하여 반응성 데이터를 기반으로 계산된 값을 생성합니다.
const doubleCount = Vue.computed(() => count.value * 2);
const reversedMessage = Vue.computed(() => state.message.split('').reverse().join(''));

// --- 4. Watcher (감시자) ---
// `watch`를 사용하여 반응성 데이터의 변경을 감지하고 특정 콜백 함수를 실행합니다.
Vue.watch(count, (newVal, oldVal) => {
    console.log(`count가 ${oldVal}에서 ${newVal}로 변경되었습니다.`);
    if (newVal > 5) {
        state.message = '카운트가 5를 초과했습니다!';
    }
});

// 객체의 특정 속성 감시
Vue.watch(() => state.person.age, (newAge, oldAge) => {
    console.log(`person의 age가 ${oldAge}에서 ${newAge}로 변경되었습니다.`);
});

// --- 5. 라이프사이클 훅 (Lifecycle Hooks) ---
// `onMounted`, `onUpdated` 등 `on` 접두사를 사용하여 라이프사이클 훅을 Composition API에서 사용합니다.
Vue.onMounted(() => {
    console.log('Vue 인스턴스가 DOM에 마운트되었습니다 (onMounted).');
});
Vue.onUnmounted(() => {
    console.log('Vue 인스턴스가 언마운트됩니다 (onUnmounted).');
});


const App = {
    setup() {
        // methods와 유사
        const incrementCount = () => {
            count.value++; // ref는 .value로 접근
        };
        const updatePersonName = (newName) => {
            state.person.name = newName; // reactive는 직접 접근
        };

        // setup 함수에서 반환하는 객체의 속성들은 템플릿에서 직접 접근 가능
        return {
            count,
            state, // 객체 전체를 반환하여 템플릿에서 state.message, state.person.name 등으로 접근
            doubleCount,
            reversedMessage,
            incrementCount,
            updatePersonName
        };
    }
};

// Vue 앱 생성 및 마운트 (HTML에 <div id="app"></div> 필요)
Vue.createApp(App).mount('#app');

// HTML (예상)
/*
<div id="app">
    <h1>{{ state.message }}</h1>
    <p>뒤집힌 메시지: {{ reversedMessage }}</p>

    <button @click="incrementCount">카운트 증가</button>
    <p>카운트: {{ count }} (두 배: {{ doubleCount }})</p>

    <h2>사용자 정보</h2>
    <p>이름: {{ state.person.name }}, 나이: {{ state.person.age }}</p>
    <input type="text" :value="state.person.name" @input="event => updatePersonName(event.target.value)" placeholder="이름">
    <input type="number" v-model.number="state.person.age" placeholder="나이">

    <br>
    <p>Vue3의 Composition API는 관련 로직을 함께 조직화하고 재사용 가능한 함수로 추출하는 데 강력합니다.</p>
</div>
*/

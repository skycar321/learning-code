// Vue2 Vuex (상태 관리)
// 중앙 집중식 상태 관리 패턴 Vuex의 개념 및 활용

// 나쁜 예시: 전역 변수나 컴포넌트 간 직접적인 `props/$emit`만으로 복잡한 애플리케이션의 상태를 관리하여 디버깅이 어렵고 상태 변화 추적이 불가능.
// 좋은 예시: Vuex를 사용하여 애플리케이션의 모든 컴포넌트가 공유하는 상태를 중앙 집중식으로 관리하고, 예측 가능한 상태 변화를 통해 안정적인 애플리케이션 구축.

// 1. Vuex CDN 또는 npm으로 설치
// <script src="https://unpkg.com/vuex@3"></script>

// 2. Vuex Store 생성
const store = new Vuex.Store({
    state: { // 중앙 집중식 상태 (데이터)
        count: 0,
        message: 'Hello Vuex!'
    },
    getters: { // state를 기반으로 계산된 속성 (computed 속성과 유사)
        currentCount: state => state.count,
        doubleCount: state => state.count * 2,
        greetingMessage: state => state.message.toUpperCase()
    },
    mutations: { // state를 변경하는 유일한 방법 (동기적으로 동작)
        increment(state) { // 첫 번째 인자로 state를 받음
            state.count++;
        },
        decrement(state) {
            state.count--;
        },
        add(state, payload) { // 두 번째 인자로 페이로드(payload)를 받음
            state.count += payload.amount;
        },
        setMessage(state, newMessage) {
            state.message = newMessage;
        }
    },
    actions: { // mutations를 커밋하고 비동기 작업을 처리 (비동기적으로 동작)
        // 첫 번째 인자로 context 객체를 받음 (state, getters, commit, dispatch 포함)
        incrementAsync(context) {
            setTimeout(() => {
                context.commit('increment'); // mutation 호출
            }, 1000);
        },
        addAsync({ commit }, payload) { // 구조 분해 할당으로 commit만 가져올 수도 있음
            setTimeout(() => {
                commit('add', payload);
            }, 1000);
        },
        fetchMessage({ commit }) {
            return new Promise((resolve) => {
                setTimeout(() => {
                    const fetched = "Vuex 메시지 가져오기 성공!";
                    commit('setMessage', fetched);
                    resolve(fetched);
                }, 1500);
            });
        }
    },
    // 모듈: 애플리케이션이 커지면 스토어를 모듈로 분리할 수 있습니다.
    // modules: {
    //     user: userModule,
    //     cart: cartModule
    // }
});

// Vue 컴포넌트
const Counter = {
    template: `
        <div style="border: 1px solid gray; padding: 10px; margin: 10px;">
            <h3>카운터 컴포넌트</h3>
            <p>현재 카운트: {{ count }} (getter: {{ doubleCount }})</p>
            <button @click="increment">증가</button>
            <button @click="decrement">감소</button>
            <button @click="addTen">10 추가</button>
            <button @click="incrementAsync">1초 후 증가</button>
            <button @click="addHundredAsync">1초 후 100 추가</button>
        </div>
    `,
    computed: {
        // state 직접 접근
        // count() {
        //     return this.$store.state.count;
        // },
        // getters 사용 (권장)
        ...Vuex.mapGetters(['currentCount', 'doubleCount']), // 'currentCount'를 count로 매핑
        count() { // currentCount를 count로 사용
            return this.currentCount;
        }
    },
    methods: {
        // mutations 직접 커밋
        // increment() {
        //     this.$store.commit('increment');
        // },
        // actions 직접 디스패치
        // incrementAsync() {
        //     this.$store.dispatch('incrementAsync');
        // },
        // mapMutations 헬퍼 사용
        ...Vuex.mapMutations(['increment', 'decrement']),
        // 페이로드를 가진 mutation
        addTen() {
            this.$store.commit('add', { amount: 10 });
        },
        // mapActions 헬퍼 사용
        ...Vuex.mapActions(['incrementAsync']),
        // 페이로드를 가진 action
        addHundredAsync() {
            this.$store.dispatch('addAsync', { amount: 100 });
        }
    }
};

const MessageDisplay = {
    template: `
        <div style="border: 1px solid gray; padding: 10px; margin: 10px;">
            <h3>메시지 디스플레이</h3>
            <p>메시지: {{ message }} (getter: {{ greetingMessage }})</p>
            <button @click="updateMessage">메시지 업데이트</button>
            <button @click="fetchMessageAction">비동기 메시지 가져오기</button>
        </div>
    `,
    computed: {
        ...Vuex.mapState(['message']), // state를 컴포넌트의 computed 속성으로 매핑
        ...Vuex.mapGetters(['greetingMessage'])
    },
    methods: {
        updateMessage() {
            this.$store.commit('setMessage', 'Vuex 상태 업데이트 완료!');
        },
        fetchMessageAction() {
            this.$store.dispatch('fetchMessage')
                .then(res => console.log('메시지 가져오기 완료:', res))
                .catch(err => console.error('메시지 가져오기 실패:', err));
        }
    }
};


new Vue({
    el: '#app-vuex',
    store, // Vue 인스턴스에 Vuex store 주입
    components: {
        'counter-component': Counter,
        'message-display': MessageDisplay
    }
});

// HTML (예상)
/*
<div id="app-vuex">
    <h1>Vuex 상태 관리 예시</h1>
    <counter-component></counter-component>
    <message-display></message-display>
</div>
*/

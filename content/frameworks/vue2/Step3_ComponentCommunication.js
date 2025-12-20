// Vue2 컴포넌트 통신
// Events ($emit), Custom Events, Vuex를 이용한 컴포넌트 간 통신

// 나쁜 예시: 전역 이벤트 버스($emit/$on)를 과도하게 사용하여 디버깅을 어렵게 만들거나, 복잡한 부모-자식 통신을 위해 `props`와 `emit`의 체인이 길어져 유지보수 어려움.
// 좋은 예시: `props`는 하향식, `$emit`은 상향식 통신에 사용하고, 복잡한 전역 상태 관리는 Vuex를 활용하여 예측 가능하고 관리하기 쉽게 만듭니다.

// --- 1. Prop Down, Event Up (부모 -> 자식, 자식 -> 부모 통신) ---

// 자식 컴포넌트
Vue.component('child-comp', {
    template: `
        <div style="border: 1px solid blue; padding: 10px; margin: 10px;">
            <h3>자식 컴포넌트</h3>
            <p>부모로부터 받은 메시지: <strong>{{ parentMsg }}</strong></p>
            <input type="text" v-model="childData">
            <button @click="sendToParent">부모에게 데이터 보내기</button>
        </div>
    `,
    props: ['parentMsg'], // 부모로부터 메시지를 받음
    data() {
        return {
            childData: ''
        };
    },
    methods: {
        sendToParent() {
            // $emit을 사용하여 'child-data-updated' 이벤트를 부모에게 발생시킵니다.
            // 두 번째 인자는 부모에게 전달할 데이터입니다.
            this.$emit('child-data-updated', this.childData);
            this.childData = ''; // 전송 후 초기화
        }
    }
});

// 부모 컴포넌트
new Vue({
    el: '#app-communication',
    data: {
        messageForChild: '안녕, 자식 컴포넌트!',
        receivedFromChild: ''
    },
    methods: {
        handleChildDataUpdated(data) {
            this.receivedFromChild = data;
            console.log('부모가 자식으로부터 받은 데이터:', data);
        }
    }
});

// --- 2. 전역 이벤트 버스 (Global Event Bus) ---
// Vue 인스턴스를 이벤트 버스로 활용하여 컴포넌트 간 직접적인 부모-자식 관계가 없는 경우에도 통신 가능.
// 단, 이벤트를 추적하기 어렵고 관리가 복잡해질 수 있어 남용은 피하는 것이 좋습니다.
const eventBus = new Vue(); // 빈 Vue 인스턴스를 이벤트 버스로 사용

Vue.component('component-a', {
    template: `
        <div style="border: 1px solid green; padding: 10px; margin: 10px;">
            <h3>컴포넌트 A</h3>
            <button @click="sendToB">컴포넌트 B에게 메시지 보내기</button>
        </div>
    `,
    methods: {
        sendToB() {
            eventBus.$emit('message-from-a', '안녕하세요, 컴포넌트 B!');
        }
    }
});

Vue.component('component-b', {
    template: `
        <div style="border: 1px solid red; padding: 10px; margin: 10px;">
            <h3>컴포넌트 B</h3>
            <p>A로부터 받은 메시지: <strong>{{ messageA }}</strong></p>
        </div>
    `,
    data() {
        return {
            messageA: ''
        };
    },
    created() {
        // 컴포넌트 A로부터 'message-from-a' 이벤트를 수신
        eventBus.$on('message-from-a', (msg) => {
            this.messageA = msg;
        });
    },
    beforeDestroy() {
        // 컴포넌트 파괴 전에 이벤트 리스너를 제거하여 메모리 누수 방지
        eventBus.$off('message-from-a');
    }
});

new Vue({
    el: '#app-eventbus'
});

// --- 3. Vuex (중앙 집중식 상태 관리) ---
// 대규모 애플리케이션에서 복잡한 전역 상태를 관리하기 위한 패턴 + 라이브러리.
// Flux 패턴에서 영감을 받았으며, 모든 컴포넌트가 공유하는 상태를 예측 가능하게 관리합니다.
// (Step5에서 상세 학습 예정)

// HTML (예상)
/*
<div id="app-communication">
    <h1>컴포넌트 통신 예시 (Prop Down, Event Up)</h1>
    <p>부모 컴포넌트에서 자식에게: {{ messageForChild }}</p>
    <p>부모 컴포넌트가 자식으로부터 받은 데이터: <strong>{{ receivedFromChild }}</strong></p>
    <child-comp :parent-msg="messageForChild" @child-data-updated="handleChildDataUpdated"></child-comp>
</div>

<div id="app-eventbus">
    <h1>컴포넌트 통신 예시 (전역 이벤트 버스)</h1>
    <component-a></component-a>
    <component-b></component-b>
</div>
*/

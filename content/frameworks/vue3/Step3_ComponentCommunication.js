// Vue3 컴포넌트 통신 ($emit, provide/inject)
// `defineEmits`, `provide/inject`를 이용한 컴포넌트 간 통신

// 나쁜 예시: 전역 이벤트 버스를 남용하거나, 깊은 컴포넌트 계층에서 props 드릴링을 통해 데이터 전달.
// 좋은 예시: `defineEmits`로 부모-자식 간 이벤트를 명확히 하고, `provide/inject`로 깊은 계층의 컴포넌트 간 통신을 간결하게 처리.

// --- 1. Prop Down, Event Up (defineEmits) ---

// 자식 컴포넌트 (ChildComp.vue 또는 아래처럼 .js 파일에서 직접 정의)
const ChildComponent = {
    template: `
        <div style="border: 1px solid blue; padding: 10px; margin: 10px;">
            <h3>자식 컴포넌트</h3>
            <p>부모로부터 받은 메시지: <strong>{{ parentMsg }}</strong></p>
            <input type="text" v-model="childData">
            <button @click="sendToParent">부모에게 데이터 보내기</button>
        </div>
    `,
    props: ['parentMsg'],
    setup(props, { emit }) {
        const childData = Vue.ref('');

        const sendToParent = () => {
            emit('child-data-updated', childData.value); // 이벤트 발생
            childData.value = '';
        };

        return {
            childData,
            sendToParent
        };
    }
};

// 부모 컴포넌트
const App = {
    components: {
        'child-comp': ChildComponent
    },
    setup() {
        const messageForChild = Vue.ref('안녕, 자식 컴포넌트 (emit)!');
        const receivedFromChild = Vue.ref('');

        const handleChildDataUpdated = (data) => {
            receivedFromChild.value = data;
            console.log('부모가 자식으로부터 받은 데이터:', data);
        };

        return {
            messageForChild,
            receivedFromChild,
            handleChildDataUpdated
        };
    }
};

// Vue 앱 생성 및 마운트 (이 부분은 여러 컴포넌트 통신을 보여주기 위해 임시로 나눠서 보여줍니다)
// Vue.createApp(App).mount('#app-communication');


// --- 2. Provide / Inject (깊은 컴포넌트 계층 통신) ---
// 부모 컴포넌트가 `provide`로 데이터를 제공하고, 하위 컴포넌트는 `inject`로 데이터를 주입받습니다.
// 중간에 있는 컴포넌트들을 거치지 않고 직접 통신할 수 있습니다 (props 드릴링 방지).

// 부모 컴포넌트 (Provider)
const ProviderComponent = {
    template: `
        <div style="border: 1px solid green; padding: 10px; margin: 10px;">
            <h3>Provider 컴포넌트</h3>
            <p>제공할 메시지: <strong>{{ providedMessage }}</strong></p>
            <button @click="updateProvidedMessage">제공 메시지 변경</button>
            <middle-component></middle-component>
        </div>
    `,
    setup() {
        const providedMessage = Vue.ref('Provider에서 제공하는 메시지');

        // 메시지 제공
        Vue.provide('my-message', providedMessage); // ref 객체 자체를 provide

        const updateProvidedMessage = () => {
            providedMessage.value = '업데이트된 메시지: ' + new Date().toLocaleTimeString();
        };

        return {
            providedMessage,
            updateProvidedMessage
        };
    }
};

// 중간 컴포넌트 (Middle Component)
const MiddleComponent = {
    template: `
        <div style="border: 1px dashed gray; padding: 10px; margin: 10px;">
            <h4>중간 컴포넌트</h4>
            <consumer-component></consumer-component>
        </div>
    `,
    components: {
        'consumer-component': ConsumerComponent
    }
};

// 자식 컴포넌트 (Consumer)
const ConsumerComponent = {
    template: `
        <div style="border: 1px solid red; padding: 10px; margin: 10px;">
            <h5>Consumer 컴포넌트</h5>
            <p>주입받은 메시지: <strong>{{ injectedMessage }}</strong></p>
            <button @click="changeInjectedMessage">주입 메시지 변경 시도 (부모 반응성 확인)</button>
        </div>
    `,
    setup() {
        // 메시지 주입 (ref 객체를 주입받았으므로 .value로 접근)
        const injectedMessage = Vue.inject('my-message', '기본 메시지'); // 기본값 설정 가능

        const changeInjectedMessage = () => {
            if (injectedMessage && injectedMessage.value) { // 제공된 메시지가 반응성이 있는 ref인 경우
                 injectedMessage.value = 'Consumer에서 변경한 메시지!'; // ref.value 변경 시 부모도 반응
            } else {
                console.warn('주입받은 메시지는 반응형 ref가 아니거나, 변경할 수 없습니다.');
            }
        };

        return {
            injectedMessage,
            changeInjectedMessage
        };
    }
};


new Vue({
    el: '#app-provide-inject',
    components: {
        'provider-comp': ProviderComponent
    },
    template: `
        <div style="border: 2px solid purple; padding: 20px;">
            <h1>Vue3 Provide/Inject 예시</h1>
            <provider-comp></provider-comp>
        </div>
    `
});

// HTML (예상)
/*
<div id="app-communication">
    <h1>Vue3 컴포넌트 통신 예시 (defineEmits)</h1>
    <p>부모 컴포넌트 메시지: {{ messageForChild }}</p>
    <p>부모가 자식으로부터 받은 데이터: <strong>{{ receivedFromChild }}</strong></p>
    <child-comp
        :parent-msg="messageForChild"
        @child-data-updated="handleChildDataUpdated"
    ></child-comp>
</div>

<div id="app-provide-inject">
    <!-- Vue 앱이 여기에 마운트됩니다. -->
</div>
*/

// Vue3 컴포넌트 기본 및 Props
// 컴포넌트 생성 및 등록, `defineProps`를 이용한 데이터 전달

// 나쁜 예시: 모든 UI를 하나의 Vue 인스턴스 내에서 관리하여 코드 재사용성이 떨어지고, 유지보수가 어려움.
// 좋은 예시: UI를 재사용 가능한 작은 컴포넌트로 분리하고, `props`를 통해 데이터를 명확하게 전달하여 컴포넌트 간의 결합도를 낮춤.

// --- 1. 컴포넌트 정의 ---
// `script setup` 문법을 사용하여 컴포넌트를 정의하는 것이 Vue3에서 권장됩니다.
// <template>
//   <div class="child-component">
//     <h3>{{ title }}</h3>
//     <p>메시지: {{ message }}</p>
//     <p>부모로부터 받은 숫자: {{ initialNumber }}</p>
//     <button @click="emitUpdate">숫자 업데이트</button>
//   </div>
// </template>

// <script setup>
// import { ref, defineProps, defineEmits } from 'vue';

// // props 정의 (객체 형태 권장)
// const props = defineProps({
//   title: {
//     type: String,
//     required: true
//   },
//   message: String,
//   initialNumber: {
//     type: Number,
//     default: 0
//   }
// });

// // emit 정의 (이벤트 유효성 검사 등)
// const emit = defineEmits(['numberUpdated']);

// const currentNumber = ref(props.initialNumber); // prop을 초기 데이터로 사용

// const emitUpdate = () => {
//   currentNumber.value++;
//   emit('numberUpdated', currentNumber.value); // 부모에게 이벤트 발생
// };
// </script>

// <style scoped>
// .child-component {
//   border: 1px solid blue;
//   padding: 10px;
//   margin: 10px;
// }
// </style>

// 위 코드는 .vue 파일 내에서 작성됩니다.
// .js 파일에서는 일반적인 객체 형태로 컴포넌트를 정의하고 `createApp`에 전달하거나 전역 등록합니다.

// --- 2. .js 파일에서 컴포넌트 정의 및 등록 예시 ---
const ChildComponent = {
    template: `
        <div class="child-component-js">
            <h3>{{ title }}</h3>
            <p>메시지: {{ message }}</p>
            <p>부모로부터 받은 숫자: {{ initialNumber }}</p>
            <button @click="emitUpdate">숫자 업데이트 (JS)</button>
        </div>
    `,
    props: {
        title: {
            type: String,
            required: true
        },
        message: String,
        initialNumber: {
            type: Number,
            default: 0
        }
    },
    setup(props, { emit }) { // setup 함수 사용
        const currentNumber = Vue.ref(props.initialNumber);

        const emitUpdate = () => {
            currentNumber.value++;
            emit('numberUpdated', currentNumber.value);
        };

        return {
            currentNumber,
            emitUpdate
        };
    }
};

const App = {
    components: { // 지역 컴포넌트 등록
        'child-comp': ChildComponent
    },
    setup() {
        const parentMessage = Vue.ref('Vue3 컴포넌트 학습 중!');
        const numberForChild = Vue.ref(10);
        const receivedNumber = Vue.ref(0);

        const handleNumberUpdated = (newNumber) => {
            receivedNumber.value = newNumber;
            console.log('부모가 자식으로부터 받은 업데이트된 숫자:', newNumber);
        };

        return {
            parentMessage,
            numberForChild,
            receivedNumber,
            handleNumberUpdated
        };
    }
};

Vue.createApp(App).mount('#app');

// HTML (예상)
/*
<style>
.child-component-js {
  border: 1px solid blue;
  padding: 10px;
  margin: 10px;
  background-color: #e0f2f7;
}
</style>

<div id="app">
    <h1>{{ parentMessage }}</h1>

    <p>--- 지역 컴포넌트 (JS 파일) ---</p>
    <p>자식으로부터 받은 숫자: {{ receivedNumber }}</p>
    <child-comp
        title="자식 컴포넌트 제목 (JS)"
        message="부모가 전달한 메시지"
        :initial-number="numberForChild"
        @number-updated="handleNumberUpdated"
    ></child-comp>

    <child-comp title="다른 자식 컴포넌트 (JS)"></child-comp>
</div>
*/

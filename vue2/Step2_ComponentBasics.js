// Vue2 컴포넌트 기본
// 컴포넌트 생성 및 등록, props를 이용한 데이터 전달

// 나쁜 예시: 모든 UI를 하나의 Vue 인스턴스 내에서 관리하여 코드 재사용성이 떨어지고, 유지보수가 어려움.
// 좋은 예시: UI를 재사용 가능한 작은 컴포넌트로 분리하고, props를 통해 데이터를 명확하게 전달하여 컴포넌트 간의 결합도를 낮춤.

// --- 1. 전역 컴포넌트 등록 ---
// 모든 Vue 인스턴스/컴포넌트에서 사용 가능
Vue.component('my-button', {
    // 템플릿은 컴포넌트의 UI 구조를 정의합니다.
    template: `
        <button @click="handleClick">
            {{ text }} ({{ clickCount }})
        </button>
    `,
    // props는 부모 컴포넌트로부터 데이터를 전달받는 속성입니다.
    props: {
        text: {
            type: String,
            default: '클릭하세요'
        }
    },
    // 컴포넌트의 데이터는 함수로 정의하여 각 인스턴스가 독립적인 데이터 객체를 가지도록 합니다.
    data() {
        return {
            clickCount: 0
        };
    },
    methods: {
        handleClick() {
            this.clickCount++;
            // 부모 컴포넌트에 이벤트를 발생시켜 알립니다. (추후 Step3에서 상세 학습)
            this.$emit('button-clicked', this.clickCount);
        }
    }
});

// --- 2. 지역 컴포넌트 등록 ---
// 특정 Vue 인스턴스/컴포넌트에서만 사용 가능
const ChildComponent = {
    template: `
        <div>
            <h3>{{ title }}</h3>
            <p>메시지: {{ message }}</p>
            <p>부모로부터 받은 숫자: {{ initialNumber }}</p>
            <button @click="updateNumber">숫자 업데이트</button>
        </div>
    `,
    props: {
        title: {
            type: String,
            required: true // 필수 prop
        },
        message: String, // 타입만 지정
        initialNumber: {
            type: Number,
            default: 0 // 기본값 지정
        }
    },
    data() {
        return {
            currentNumber: this.initialNumber // prop을 초기 데이터로 사용
        };
    },
    methods: {
        updateNumber() {
            this.currentNumber++;
            // prop은 직접 변경하지 않고, 이벤트를 통해 부모에게 알립니다.
            // this.$emit('number-updated', this.currentNumber); // 추후 Step3에서 상세 학습
        }
    },
    // 컴포넌트의 유효성 검사 (개발 모드에서 경고 출력)
    // props: {
    //     propA: Number,
    //     propB: [String, Number],
    //     propC: {
    //         type: String,
    //         required: true
    //     },
    //     propD: {
    //         type: Number,
    //         default: 100
    //     },
    //     propE: {
    //         type: Object,
    //         default: function () {
    //             return { message: 'hello' }
    //         }
    //     },
    //     propF: {
    //         validator: function (value) {
    //             return ['success', 'warning', 'danger'].indexOf(value) !== -1
    //         }
    //     }
    // }
};

new Vue({
    el: '#app',
    components: { // 지역 컴포넌트 등록
        'child-component': ChildComponent
    },
    data: {
        parentMessage: 'Vue2 컴포넌트 학습 중!',
        numberForChild: 10,
        buttonClickCounts: {}
    },
    methods: {
        handleButtonClick(count) {
            console.log(`my-button 컴포넌트가 ${count}번 클릭되었습니다.`);
            this.$set(this.buttonClickCounts, 'myButton', count); // 반응형으로 객체 속성 추가
        }
    }
});


// HTML (예상)
/*
<div id="app">
    <h1>{{ parentMessage }}</h1>

    <p>--- 전역 컴포넌트 ---</p>
    <my-button text="전역 버튼 1" @button-clicked="handleButtonClick"></my-button>
    <my-button :text="'전역 버튼 2 (클릭수: ' + (buttonClickCounts.myButton || 0) + ')'"></my-button>

    <p>--- 지역 컴포넌트 ---</p>
    <child-component
        title="자식 컴포넌트 제목"
        message="부모가 전달한 메시지"
        :initial-number="numberForChild"
    ></child-component>

    <child-component title="다른 자식 컴포넌트"></child-component>
</div>
*/

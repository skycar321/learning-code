// Vue2 Life Cycle Hooks
// 컴포넌트 생명주기 훅의 종류 및 각 단계에서의 활용

// 나쁜 예시: 컴포넌트 라이프사이클을 이해하지 못하고, 부적절한 시점에 DOM 조작이나 비동기 요청을 수행하여 오류를 유발하거나 성능 저해.
// 좋은 예시: 각 라이프사이클 훅의 역할과 실행 시점을 정확히 이해하고, 적절한 훅에서 필요한 작업을 수행하여 안정적이고 효율적인 컴포넌트 구현.

// Vue 컴포넌트의 인스턴스 생명주기는 크게 4단계로 나눌 수 있습니다:
// 1. Creation (생성)
// 2. Mounting (마운트)
// 3. Updating (업데이트)
// 4. Destruction (소멸)

// 각 단계에는 특정 시점에 자동으로 호출되는 "훅(Hook)" 메서드들이 있습니다.

Vue.component('lifecycle-example', {
    template: `
        <div style="border: 1px solid #ccc; padding: 15px; margin: 15px;">
            <h2>라이프사이클 예제 컴포넌트</h2>
            <p>메시지: {{ message }}</p>
            <button @click="updateMessage">메시지 업데이트</button>
            <button @click="$destroy()">컴포넌트 제거</button>
        </div>
    `,
    data() {
        return {
            message: '초기 메시지',
            timer: null
        };
    },
    // --- 1. Creation (생성) 단계 훅 ---
    // 인스턴스가 생성되고 초기화되는 단계.
    // DOM에 접근할 수 없습니다. 데이터(data), 연산 속성(computed), 메서드(methods), watch 등이 설정됩니다.
    beforeCreate() {
        console.log('[Lifecycle] beforeCreate: 인스턴스 생성 전');
        // 데이터나 이벤트에 아직 접근할 수 없습니다.
        // console.log(this.message); // undefined
    },
    created() {
        console.log('[Lifecycle] created: 인스턴스 생성 완료');
        // 데이터, computed, methods, watch에 접근할 수 있습니다.
        // 하지만 DOM에는 아직 마운트되지 않았습니다.
        // 주로 비동기 데이터 로딩(API 호출)을 여기서 수행합니다.
        console.log('  Data message:', this.message); // 접근 가능
        this.timer = setInterval(() => {
            this.message = '메시지 자동 업데이트: ' + new Date().toLocaleTimeString();
        }, 3000);
    },

    // --- 2. Mounting (마운트) 단계 훅 ---
    // 가상 DOM이 생성되고 실제 DOM에 삽입되는 단계.
    // 인스턴스가 DOM에 부착되기 전과 후를 처리합니다.
    beforeMount() {
        console.log('[Lifecycle] beforeMount: DOM에 마운트되기 전');
        // 템플릿이 컴파일되고 가상 DOM이 생성되지만, 실제 DOM에 삽입되기 전.
        // 이때 DOM에 직접 접근하려 해도 아직 Vue가 처리한 최종 DOM이 아닙니다.
        // console.log(document.getElementById('lifecycle-app-area').children); // 아직 비어있을 수 있음
    },
    mounted() {
        console.log('[Lifecycle] mounted: DOM에 마운트 완료');
        // 인스턴스가 실제 DOM에 완전히 부착된 후.
        // DOM에 직접 접근해야 하는 라이브러리(D3.js, Chart.js 등)를 여기서 초기화합니다.
        // 주로 DOM 관련 작업이나, 외부 라이브러리 연동에 사용됩니다.
        console.log('  DOM에 접근 가능:', this.$el);
        this.$el.style.backgroundColor = '#f0f0f0'; // DOM 스타일 변경 예시
    },

    // --- 3. Updating (업데이트) 단계 훅 ---
    // 컴포넌트의 데이터가 변경되어 뷰가 업데이트될 때 호출됩니다.
    beforeUpdate() {
        console.log('[Lifecycle] beforeUpdate: 데이터 변경으로 DOM 업데이트 전');
        // 데이터가 변경되었고 가상 DOM이 다시 렌더링될 준비가 되었지만, 실제 DOM은 아직 업데이트되지 않았습니다.
        // 이때 DOM에 접근하면 이전 상태의 DOM을 볼 수 있습니다.
        console.log('  이전 메시지:', this.$el.querySelector('p').textContent);
    },
    updated() {
        console.log('[Lifecycle] updated: DOM 업데이트 완료');
        // 데이터 변경으로 인해 실제 DOM이 업데이트된 후.
        // 여기서 DOM 관련 작업(스크롤 위치 조정 등)을 수행할 수 있습니다.
        console.log('  업데이트된 메시지:', this.$el.querySelector('p').textContent);
    },

    // --- 4. Destruction (소멸) 단계 훅 ---
    // 컴포넌트 인스턴스가 소멸될 때 호출됩니다.
    beforeDestroy() {
        console.log('[Lifecycle] beforeDestroy: 인스턴스 소멸 전');
        // 인스턴스가 파괴되기 직전.
        // 메모리 누수를 방지하기 위해 `setInterval`, `setTimeout`, 이벤트 리스너 등을 여기서 정리합니다.
        if (this.timer) {
            clearInterval(this.timer);
            console.log('  타이머가 정리되었습니다.');
        }
        console.log('  이벤트 리스너 등 정리 시작.');
    },
    destroyed() {
        console.log('[Lifecycle] destroyed: 인스턴스 소멸 완료');
        // 인스턴스가 완전히 파괴된 후. 모든 디렉티브 바인딩, 이벤트 리스너 등이 제거됩니다.
        // 자식 컴포넌트도 모두 파괴됩니다.
        console.log('  컴포넌트가 DOM에서 완전히 제거되었습니다.');
    },

    methods: {
        updateMessage() {
            this.message = '수동으로 업데이트됨: ' + new Date().toLocaleTimeString();
        }
    }
});


new Vue({
    el: '#app-lifecycle',
    data: {
        showComponent: true
    }
});

// HTML (예상)
/*
<div id="app-lifecycle">
    <h1>Vue2 라이프사이클 훅 예시</h1>
    <button @click="showComponent = !showComponent">
        컴포넌트 {{ showComponent ? '숨기기' : '보이기' }}
    </button>
    <div id="lifecycle-app-area">
        <lifecycle-example v-if="showComponent"></lifecycle-example>
    </div>
</div>
*/

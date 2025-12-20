// Vue3 Life Cycle Hooks (Composition API)
// `onMounted`, `onUpdated` 등 Composition API 기반 생명주기 훅 활용

// 나쁜 예시: 컴포넌트 라이프사이클을 이해하지 못하고, 부적절한 시점에 DOM 조작이나 비동기 요청을 수행하여 오류를 유발하거나 성능 저해.
// 좋은 예시: 각 라이프사이클 훅의 역할과 실행 시점을 정확히 이해하고, 적절한 훅에서 필요한 작업을 수행하여 안정적이고 효율적인 컴포넌트 구현.

// Vue3의 Composition API에서는 라이프사이클 훅이 `on` 접두사를 가진 함수로 제공됩니다.
// 이 훅들은 `setup()` 함수 내에서만 호출되어야 합니다.

const { createApp, ref, onBeforeMount, onMounted, onBeforeUpdate, onUpdated, onBeforeUnmount, onUnmounted, onErrorCaptured } = Vue;

const LifecycleExample = {
    template: `
        <div style="border: 1px solid #ccc; padding: 15px; margin: 15px;">
            <h2>라이프사이클 예제 컴포넌트 (Composition API)</h2>
            <p>메시지: {{ message }}</p>
            <button @click="updateMessage">메시지 업데이트</button>
            <!-- $parent.$data.showComponent = false; 를 통해 부모 컴포넌트 상태를 변경하여 언마운트 가능 -->
        </div>
    `,
    setup() {
        const message = ref('초기 메시지');
        let timer = null;

        // --- 1. Creation (생성) 단계 훅 ---
        // setup() 함수 자체는 Options API의 `beforeCreate`와 `created` 훅 사이에 실행됩니다.
        // `beforeCreate`와 `created`는 Composition API에 직접적인 대응 훅이 없습니다.
        // 대신 `setup()`에서 반응형 데이터 선언, computed, watch, provide/inject 등을 설정합니다.
        console.log('[Lifecycle] setup: 컴포넌트 생성 전 실행'); // `beforeCreate`보다 먼저 실행

        // --- 2. Mounting (마운트) 단계 훅 ---
        onBeforeMount(() => {
            console.log('[Lifecycle] onBeforeMount: DOM에 마운트되기 전');
            // 아직 DOM에 접근할 수 없습니다.
        });

        onMounted(() => {
            console.log('[Lifecycle] onMounted: DOM에 마운트 완료');
            // 컴포넌트가 실제 DOM에 부착된 후. DOM 관련 작업이나 외부 라이브러리 연동에 사용.
            // 예: `this.$el` 대신 `document.querySelector` 등을 사용하거나, 템플릿 참조 변수(ref) 사용
            document.querySelector('.lifecycle-example-component-container').style.backgroundColor = '#e6f7ff'; // 부모의 DOM을 조작 (예시)
            timer = setInterval(() => {
                message.value = '메시지 자동 업데이트: ' + new Date().toLocaleTimeString();
            }, 3000);
        });

        // --- 3. Updating (업데이트) 단계 훅 ---
        onBeforeUpdate(() => {
            console.log('[Lifecycle] onBeforeUpdate: 데이터 변경으로 DOM 업데이트 전');
            // 데이터가 변경되었고 가상 DOM이 다시 렌더링될 준비가 되었지만, 실제 DOM은 아직 업데이트되지 않았습니다.
        });

        onUpdated(() => {
            console.log('[Lifecycle] onUpdated: DOM 업데이트 완료');
            // 데이터 변경으로 인해 실제 DOM이 업데이트된 후.
        });

        // --- 4. Unmounting (언마운트) 단계 훅 ---
        onBeforeUnmount(() => {
            console.log('[Lifecycle] onBeforeUnmount: 인스턴스 소멸 전');
            // 컴포넌트가 파괴되기 직전.
            // 메모리 누수를 방지하기 위해 `setInterval`, `setTimeout`, 이벤트 리스너 등을 여기서 정리합니다.
            if (timer) {
                clearInterval(timer);
                console.log('  타이머가 정리되었습니다.');
            }
            console.log('  이벤트 리스너 등 정리 시작.');
        });

        onUnmounted(() => {
            console.log('[Lifecycle] onUnmounted: 인스턴스 소멸 완료');
            // 인스턴스가 완전히 파괴된 후. 모든 디렉티브 바인딩, 이벤트 리스너 등이 제거됩니다.
        });

        // --- 에러 처리 훅 ---
        onErrorCaptured((err, instance, info) => {
            console.error('[Lifecycle] onErrorCaptured: 컴포넌트에서 에러 발생!', err, instance, info);
            // 에러 로깅, 사용자에게 에러 메시지 표시 등
            return true; // 에러가 상위 컴포넌트로 전파되는 것을 중지 (선택 사항)
        });

        const updateMessage = () => {
            message.value = '수동으로 업데이트됨: ' + new Date().toLocaleTimeString();
        };

        return {
            message,
            updateMessage
        };
    }
};

const AppRoot = {
    template: `
        <div id="app-lifecycle-root">
            <h1>Vue3 라이프사이클 훅 예시 (Composition API)</h1>
            <button @click="showComponent = !showComponent">
                컴포넌트 {{ showComponent ? '숨기기' : '보이기' }}
            </button>
            <div class="lifecycle-example-component-container">
                <lifecycle-example v-if="showComponent"></lifecycle-example>
            </div>
            <button @click="triggerError">에러 발생시키기 (내부 컴포넌트)</button>
            <error-child-component v-if="showComponent" />
        </div>
    `,
    components: {
        'lifecycle-example': LifecycleExample,
        'error-child-component': {
            template: `
                <div style="border: 1px dashed red; padding: 10px; margin: 10px;">
                    <h4>에러 발생 자식 컴포넌트</h4>
                    <button @click="triggerRuntimeError">런타임 에러 발생</button>
                </div>
            `,
            setup() {
                const triggerRuntimeError = () => {
                    throw new Error('자식 컴포넌트에서 발생한 런타임 에러!');
                };
                return { triggerRuntimeError };
            }
        }
    },
    setup() {
        const showComponent = ref(true);
        const triggerError = () => {
            console.log('에러 발생 버튼 클릭');
            // 이 버튼은 ErrorChildComponent 내의 버튼과 별개입니다.
            // 실제 에러는 ErrorChildComponent 내의 버튼을 통해 발생시킵니다.
        };

        return {
            showComponent,
            triggerError
        };
    }
};


createApp(AppRoot).mount('#app');

// HTML (예상)
/*
<style>
.lifecycle-example-component-container {
    border: 2px solid purple;
    padding: 10px;
    margin-top: 10px;
    background-color: #f0f0f0; /* onMounted에서 변경될 색 */
}
</style>

<div id="app">
    <!-- Vue 앱이 여기에 마운트됩니다. -->
</div>
*/

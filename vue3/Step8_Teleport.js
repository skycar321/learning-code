// Vue3 Teleport
// DOM의 다른 위치로 콘텐츠를 이동시키는 Teleport 활용

// 나쁜 예시: 전역 모달이나 툴팁과 같은 요소를 현재 컴포넌트의 DOM 구조 내에 직접 렌더링하여 CSS 스택 컨텍스트, z-index 문제, 스크롤 동작 등을 복잡하게 만듭니다.
// 좋은 예시: Teleport를 사용하여 모달, 알림, 로딩 스피너 등 전역적으로 표시되어야 하는 UI 요소를 DOM의 다른 곳으로 쉽게 이동시켜 CSS/DOM 구조 문제를 해결하고 관리 용이성을 높입니다.

// `Teleport`는 Vue3에서 새로 도입된 기능으로, 컴포넌트의 템플릿 일부를 DOM 트리의 다른 위치로 렌더링할 수 있게 해줍니다.

const { createApp, ref } = Vue;

// 모달 컴포넌트
const ModalComponent = {
    template: `
        <!-- Teleport는 to 속성에 지정된 DOM 요소로 이 내부의 콘텐츠를 이동시킵니다. -->
        <teleport to="#modal-target">
            <div v-if="isOpen" class="modal-backdrop" @click="closeModal">
                <div class="modal-content" @click.stop> <!-- 이벤트 버블링 중단 -->
                    <h3>모달 제목</h3>
                    <p>이것은 Teleport를 사용하여 렌더링된 모달입니다. 실제 DOM에서는 바디 바로 아래에 있습니다.</p>
                    <button @click="closeModal">닫기</button>
                    <slot></slot> <!-- 모달 내부에 추가 콘텐츠를 넣을 수 있도록 슬롯 제공 -->
                </div>
            </div>
        </teleport>
    `,
    props: {
        isOpen: {
            type: Boolean,
            required: true
        }
    },
    emits: ['update:isOpen'], // v-model을 위한 emit
    setup(props, { emit }) {
        const closeModal = () => {
            emit('update:isOpen', false); // 부모 컴포넌트의 v-model을 업데이트
        };
        return {
            closeModal
        };
    }
};

const App = {
    components: {
        'modal-component': ModalComponent
    },
    setup() {
        const showModal = ref(false);

        const openModal = () => {
            showModal.value = true;
        };

        return {
            showModal,
            openModal
        };
    }
};

const app = createApp(App);
app.mount('#app-teleport');

// HTML (예상)
/*
<style>
/* 모달 스타일 */
.modal-backdrop {
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    background-color: rgba(0, 0, 0, 0.5);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 1000; /* 다른 콘텐츠 위에 표시 */
}

.modal-content {
    background-color: white;
    padding: 20px;
    border-radius: 8px;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    width: 80%;
    max-width: 500px;
    z-index: 1001;
}

h3 { color: #333; }
p { color: #666; }
button {
    background-color: #42b983;
    color: white;
    border: none;
    padding: 8px 15px;
    border-radius: 4px;
    cursor: pointer;
    margin-top: 10px;
}
button:hover { background-color: #36a470; }
</style>

<div id="app-teleport">
    <h1>Vue3 Teleport 예시</h1>

    <p>이 내용은 컴포넌트의 일반적인 DOM 흐름에 있습니다.</p>
    <p>하지만 아래 버튼을 클릭하면 모달이 나타나고, 이 모달은 <code>body</code> 태그 바로 아래에 렌더링됩니다.</p>
    <button @click="openModal">모달 열기</button>

    <modal-component v-model:is-open="showModal">
        <p>추가적인 모달 콘텐츠를 슬롯을 통해 전달했습니다!</p>
    </modal-component>

    <!-- 모달이 렌더링될 대상 DOM 요소를 정의합니다. -->
    <!-- 일반적으로 body 태그 바로 아래에 위치시킵니다. -->
</div>
<div id="modal-target"></div>
*/

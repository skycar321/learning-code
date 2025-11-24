// Vue3 Transition & Animation
// Vue3의 Transition 컴포넌트를 이용한 애니메이션 구현

// 나쁜 예시: CSS `display: none` 등을 직접 토글하여 애니메이션 없이 요소가 갑자기 나타나거나 사라지게 만듭니다.
// 좋은 예시: Vue의 `Transition` 컴포넌트와 CSS 트랜지션/애니메이션을 활용하여 요소의 등장/사라짐에 부드러운 효과를 적용.

// Vue3는 `<Transition>` 컴포넌트를 사용하여 요소나 컴포넌트가 삽입/제거될 때 트랜지션 효과를 적용할 수 있도록 합니다.

const { createApp, ref } = Vue;

const App = {
    template: `
        <div id="app-transition-animation">
            <h1>Vue3 Transition & Animation 예시</h1>

            <h2>1. 기본 Transition (단일 요소)</h2>
            <button @click="show = !show">토글 박스</button>
            <Transition name="fade">
                <div v-if="show" class="box"></div>
            </Transition>

            <h2>2. CSS 애니메이션 사용</h2>
            <button @click="showAnimation = !showAnimation">토글 메시지</button>
            <Transition name="bounce">
                <p v-if="showAnimation" class="animated-message">안녕, 애니메이션!</p>
            </Transition>

            <h2>3. 초기 렌더링 시 Transition</h2>
            <Transition appear name="slide-fade">
                <h3 v-if="showOnLoad" class="initial-render">페이지 로드 시 나타나는 제목</h3>
            </Transition>

            <h2>4. Transition Group (리스트)</h2>
            <button @click="shuffleList">리스트 섞기</button>
            <button @click="addToList">아이템 추가</button>
            <TransitionGroup name="list" tag="ul" class="list-container">
                <li v-for="item in shuffledItems" :key="item.id" class="list-item">
                    {{ item.text }}
                </li>
            </TransitionGroup>
        </div>
    `,
    setup() {
        const show = ref(true);
        const showAnimation = ref(true);
        const showOnLoad = ref(true);

        // Transition Group용 데이터
        const items = ref([
            { id: 1, text: 'Vue' },
            { id: 2, text: 'React' },
            { id: 3, text: 'Angular' },
            { id: 4, text: 'Svelte' }
        ]);
        let nextId = 5;

        const shuffledItems = Vue.computed(() => {
            return [...items.value].sort(() => Math.random() - 0.5);
        });

        const shuffleList = () => {
            items.value.sort(() => Math.random() - 0.5);
        };

        const addToList = () => {
            const newItem = { id: nextId++, text: `New Item ${nextId - 1}` };
            items.value.push(newItem);
        };

        return {
            show,
            showAnimation,
            showOnLoad,
            shuffledItems,
            shuffleList,
            addToList
        };
    }
};

createApp(App).mount('#app-transition-animation');

// HTML (예상) 및 CSS 스타일
/*
<style>
/* 1. 기본 Transition을 위한 CSS */
.fade-enter-active, .fade-leave-active {
    transition: opacity 0.5s ease;
}
.fade-enter-from, .fade-leave-to {
    opacity: 0;
}

.box {
    width: 100px;
    height: 100px;
    background-color: lightblue;
    margin-top: 10px;
}

/* 2. CSS 애니메이션을 위한 CSS */
.bounce-enter-active {
    animation: bounce-in 0.8s;
}
.bounce-leave-active {
    animation: bounce-in 0.8s reverse;
}
@keyframes bounce-in {
    0% {
        transform: scale(0);
    }
    50% {
        transform: scale(1.25);
    }
    100% {
        transform: scale(1);
    }
}
.animated-message {
    margin-top: 10px;
    font-size: 1.2em;
    font-weight: bold;
    color: darkgreen;
}

/* 3. 초기 렌더링 Transition */
.slide-fade-enter-active {
    transition: all 0.3s ease-out;
}
.slide-fade-leave-active {
    transition: all 0.8s cubic-bezier(1, 0.5, 0.8, 1);
}
.slide-fade-enter-from,
.slide-fade-leave-to {
    transform: translateX(20px);
    opacity: 0;
}
.initial-render {
    margin-top: 10px;
    color: darkorchid;
}

/* 4. Transition Group (리스트 아이템 이동) */
.list-container {
    list-style: none;
    padding: 0;
    margin-top: 10px;
    max-width: 300px;
    border: 1px solid #eee;
    padding: 5px;
}
.list-item {
    background-color: #f9f9f9;
    border: 1px solid #ddd;
    margin-bottom: 5px;
    padding: 8px;
    display: flex; /* 이동 애니메이션을 위해 필요 */
    justify-content: center;
    align-items: center;
    height: 40px;
    transition: all 0.5s ease; /* 이동 애니메이션 */
}

/* 리스트 항목의 등장/사라짐 트랜지션 */
.list-enter-from, .list-leave-to {
    opacity: 0;
    transform: translateX(30px);
}
.list-leave-active {
    position: absolute; /* 사라지는 요소는 position: absolute 필요 */
}

button {
    background-color: #42b983;
    color: white;
    border: none;
    padding: 8px 15px;
    border-radius: 4px;
    cursor: pointer;
    margin-right: 5px;
    margin-top: 10px;
}
button:hover { background-color: #36a470; }
</style>

<div id="app-transition-animation">
    <!-- Vue 앱이 여기에 마운트됩니다. -->
</div>
*/

// Vue2 시작하기
// Vue 인스턴스, 데이터 바인딩, 디렉티브 등 Vue2 기본 개념 이해

// 나쁜 예시: `<script>` 태그 내에 모든 JavaScript 코드를 작성하거나, Vue 인스턴스 없이 직접 DOM을 조작합니다.
// 좋은 예시: Vue CDN을 통해 Vue를 로드하거나 Vue CLI를 사용하여 프로젝트를 생성하고, MVVM 패턴에 따라 Vue 인스턴스를 통해 데이터를 관리하고 DOM을 업데이트합니다.

// Vue CDN을 통한 Vue 로드 (예시)
// <script src="https://cdn.jsdelivr.net/npm/vue@2"></script>

// Vue 인스턴스 생성 및 데이터 바인딩
const app = new Vue({
    el: '#app', // Vue 인스턴스가 마운트될 DOM 요소 (HTML에 <div id="app"></div> 필요)
    data: { // 반응형 데이터
        message: '안녕하세요, Vue2!',
        count: 0,
        isVisible: true,
        items: ['사과', '바나나', '딸기'],
        person: {
            name: '김철수',
            age: 30
        }
    },
    methods: { // Vue 인스턴스에서 사용할 메서드
        incrementCount() {
            this.count++;
        },
        toggleVisibility() {
            this.isVisible = !this.isVisible;
        },
        greet() {
            return `Hello, ${this.person.name}!`;
        }
    },
    computed: { // 의존하는 데이터가 변경될 때만 다시 계산되는 캐시된 속성
        reversedMessage() {
            return this.message.split('').reverse().join('');
        },
        filteredItems() {
            // 예시: '사과'가 포함된 아이템만 필터링
            return this.items.filter(item => item.includes('사과'));
        }
    },
    watch: { // 데이터 변경을 감지하고 특정 로직을 실행
        count(newVal, oldVal) {
            console.log(`count가 ${oldVal}에서 ${newVal}로 변경되었습니다.`);
            if (newVal > 5) {
                this.message = '카운트가 5를 초과했습니다!';
            }
        },
        'person.age'(newAge, oldAge) { // 객체 내부 속성 감지
            console.log(`person의 age가 ${oldAge}에서 ${newAge}로 변경되었습니다.`);
        }
    },
    // 라이프사이클 훅 (예시)
    created() {
        console.log('Vue 인스턴스가 생성되었습니다 (created).');
        // 컴포넌트가 생성된 후 데이터 초기화, 비동기 작업 등을 수행하기 좋은 시점
    },
    mounted() {
        console.log('Vue 인스턴스가 DOM에 마운트되었습니다 (mounted).');
        // DOM에 접근하여 조작하거나 외부 라이브러리를 연동하기 좋은 시점
    }
});

// HTML (예상)
/*
<div id="app">
    <h1>{{ message }}</h1>
    <p>뒤집힌 메시지: {{ reversedMessage }}</p>

    <button @click="incrementCount">카운트 증가</button>
    <p>카운트: {{ count }}</p>

    <button @click="toggleVisibility">토글</button>
    <p v-if="isVisible">이것은 v-if 디렉티브입니다.</p>
    <p v-show="isVisible">이것은 v-show 디렉티브입니다.</p>

    <h2>아이템 목록</h2>
    <ul>
        <li v-for="(item, index) in items" :key="index">{{ index }}: {{ item }}</li>
    </ul>
    <h3>필터링된 아이템</h3>
    <ul>
        <li v-for="item in filteredItems" :key="item">{{ item }}</li>
    </ul>

    <h2>사용자 정보</h2>
    <p>{{ greet() }}</p>
    <input type="text" v-model="person.name" placeholder="이름">
    <input type="number" v-model.number="person.age" placeholder="나이">
    <p>이름: {{ person.name }}, 나이: {{ person.age }}</p>

    <br>
    <p>Vue.js는 데이터를 변경하면 자동으로 화면이 업데이트됩니다. 직접 DOM을 조작할 필요가 없습니다.</p>
</div>
*/

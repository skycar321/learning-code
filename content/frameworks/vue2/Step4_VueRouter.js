// Vue2 Vue Router
// SPA 구현을 위한 Vue Router 설정 및 동적 라우팅

// 나쁜 예시: 페이지 이동 시마다 전체 페이지를 새로 로드하여 사용자 경험을 저해하고, 비동기 데이터 로딩을 수동으로 관리하여 복잡도를 높임.
// 좋은 예시: Vue Router를 사용하여 SPA(Single Page Application)를 구현하고, 컴포넌트 기반 라우팅, 중첩 라우팅, 동적 라우팅으로 사용자 친화적인 내비게이션 제공.

// 1. Vue Router CDN 또는 npm으로 설치
// <script src="https://unpkg.com/vue-router@3"></script>

// 2. 라우팅을 위한 컴포넌트 정의
const Home = { template: '<div><h1>홈 페이지</h1><p>환영합니다!</p></div>' };
const About = { template: '<div><h1>회사 소개</h1><p>저희 회사에 대해 알아보세요.</p></div>' };
const User = {
    template: `
        <div>
            <h1>사용자 정보: {{ $route.params.id }}</h1>
            <p>이름: {{ userName }}</p>
            <button @click="goBack">뒤로 가기</button>
            <router-view></router-view> <!-- 중첩 라우팅을 위한 placeholder -->
        </div>
    `,
    data() {
        return {
            userName: ''
        };
    },
    // 라우트 파라미터가 변경될 때마다 데이터를 업데이트
    watch: {
        '$route': 'fetchData' // $route 객체 변경 감지하여 fetchData 메서드 호출
    },
    created() {
        this.fetchData();
    },
    methods: {
        fetchData() {
            // 실제 데이터는 API 호출을 통해 가져옵니다.
            const userId = this.$route.params.id;
            console.log(`사용자 ID ${userId}의 데이터를 가져옵니다.`);
            if (userId === '1') {
                this.userName = 'Alice';
            } else if (userId === '2') {
                this.userName = 'Bob';
            } else {
                this.userName = '알 수 없는 사용자';
            }
        },
        goBack() {
            this.$router.go(-1); // 이전 페이지로 이동
        }
    },
    // 중첩 라우팅 예시 (사용자 상세 정보)
    // <router-link :to="{ name: 'userPosts', params: { id: $route.params.id }}">게시물 보기</router-link>
    // <router-link :to="{ name: 'userProfile', params: { id: $route.params.id }}">프로필 상세</router-link>
};

const UserPosts = { template: '<div><h2>{{ $route.params.id }}의 게시물 목록</h2></div>' };
const UserProfile = { template: '<div><h2>{{ $route.params.id }}의 프로필 상세</h2></div>' };


// 3. 라우트 정의
const routes = [
    { path: '/', component: Home },
    { path: '/about', component: About },
    {
        path: '/user/:id', // 동적 라우팅 파라미터 (:id)
        component: User,
        name: 'user', // 라우트 이름 지정
        children: [ // 중첩 라우팅
            {
                path: 'posts',
                component: UserPosts,
                name: 'userPosts'
            },
            {
                path: 'profile',
                component: UserProfile,
                name: 'userProfile'
            }
        ]
    },
    { path: '*', redirect: '/' } // 매칭되는 라우트가 없으면 홈으로 리다이렉트
];

// 4. Vue Router 인스턴스 생성
const router = new VueRouter({
    mode: 'history', // URL에 # 없이 깔끔하게 사용 (서버 설정 필요)
    routes // `routes: routes`와 동일
});

// 5. Vue 인스턴스에 라우터 연결
new Vue({
    el: '#app-router',
    router, // `router: router`와 동일
    data: {
        dynamicUserId: '1' // 동적 사용자 ID
    },
    methods: {
        goToUser(id) {
            this.$router.push(`/user/${id}`); // 프로그래밍 방식으로 라우트 이동
        },
        goToUserProfile(id) {
            this.$router.push({ name: 'userProfile', params: { id: id }});
        }
    }
});


// HTML (예상)
/*
<div id="app-router">
    <h1>Vue Router 예시</h1>
    <p>
        <router-link to="/">Home</router-link> |
        <router-link to="/about">About</router-link> |
        <router-link to="/user/1">User 1</router-link> |
        <router-link to="/user/2">User 2</router-link>
    </p>

    <p>
        <input type="number" v-model="dynamicUserId">
        <button @click="goToUser(dynamicUserId)">사용자 페이지로 이동</button>
        <button @click="goToUserProfile(dynamicUserId)">사용자 프로필 상세로 이동</button>
    </p>

    <hr>
    <router-view></router-view> <!-- 현재 라우트에 해당하는 컴포넌트가 렌더링될 위치 -->
</div>
*/

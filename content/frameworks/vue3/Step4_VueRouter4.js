// Vue3 Vue Router 4
// Vue Router 4의 새로운 API 및 동적 라우팅, 네비게이션 가드 학습

// 나쁜 예시: 페이지 이동 시마다 전체 페이지를 새로 로드하여 사용자 경험을 저해하고, 비동기 데이터 로딩을 수동으로 관리하여 복잡도를 높임.
// 좋은 예시: Vue Router 4를 사용하여 SPA(Single Page Application)를 구현하고, 컴포넌트 기반 라우팅, 중첩 라우팅, 동적 라우팅으로 사용자 친화적인 내비게이션 제공.

// 1. Vue Router 4 CDN 또는 npm으로 설치
// <script src="https://unpkg.com/vue-router@4"></script>

// 2. 라우팅을 위한 컴포넌트 정의
const Home = { template: '<div><h1>홈 페이지 (Vue3)</h1><p>Vue Router 4 예제</p></div>' };
const About = { template: '<div><h1>회사 소개 (Vue3)</h1><p>저희 회사에 대해 알아보세요.</p></div>' };
const User = {
    template: `
        <div>
            <h1>사용자 정보: {{ userId }}</h1>
            <p>이름: {{ userName }}</p>
            <button @click="goBack">뒤로 가기</button>
            <router-view></router-view> <!-- 중첩 라우팅을 위한 placeholder -->
        </div>
    `,
    setup() {
        const route = VueRouter.useRoute(); // Vue Router 4의 useRoute 훅 사용
        const router = VueRouter.useRouter(); // Vue Router 4의 useRouter 훅 사용

        const userId = Vue.ref(route.params.id);
        const userName = Vue.ref('');

        const fetchData = () => {
            // 실제 데이터는 API 호출을 통해 가져옵니다.
            console.log(`사용자 ID ${userId.value}의 데이터를 가져옵니다.`);
            if (userId.value === '1') {
                userName.value = 'Alice';
            } else if (userId.value === '2') {
                userName.value = 'Bob';
            } else {
                userName.value = '알 수 없는 사용자';
            }
        };

        // 라우트 파라미터 변경 감지 (watch 사용)
        Vue.watch(() => route.params.id, (newId) => {
            userId.value = newId;
            fetchData();
        });

        Vue.onMounted(fetchData); // 컴포넌트 마운트 시 데이터 가져오기

        const goBack = () => {
            router.go(-1); // 이전 페이지로 이동
        };

        return {
            userId,
            userName,
            goBack
        };
    }
};

const UserPosts = { template: '<div><h2>{{ $route.params.id }}의 게시물 목록 (Vue3)</h2></div>' };
const UserProfile = { template: '<div><h2>{{ $route.params.id }}의 프로필 상세 (Vue3)</h2></div>' };


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
    // 모든 매칭되지 않는 경로를 처리 (Vue Router 4)
    { path: '/:pathMatch(.*)*', name: 'NotFound', redirect: '/' } // 매칭되는 라우트가 없으면 홈으로 리다이렉트
];

// 4. Vue Router 인스턴스 생성
const router = VueRouter.createRouter({
    history: VueRouter.createWebHistory(), // HTML5 History 모드 (URL에 # 없음)
    routes // `routes: routes`와 동일
});

// 5. 네비게이션 가드 (Navigation Guards)
// 라우트 이동 전/후에 특정 로직을 실행할 수 있습니다.
router.beforeEach((to, from, next) => {
    console.log(`[네비게이션 가드] 이동 전: ${from.path} -> ${to.path}`);
    // 예시: 특정 페이지에만 접근을 허용 (인증 여부 확인 등)
    // if (to.path === '/admin' && !isAuthenticated) {
    //     next('/login'); // 로그인 페이지로 리다이렉트
    // } else {
    //     next(); // 이동 허용
    // }
    next(); // 다음으로 이동
});

router.afterEach((to, from) => {
    console.log(`[네비게이션 가드] 이동 후: ${from.path} -> ${to.path}`);
    // 페이지 뷰 로깅, 스크롤 위치 초기화 등
});


// 6. Vue 앱 인스턴스 생성 및 라우터 연결
const app = Vue.createApp({
    setup() {
        const dynamicUserId = Vue.ref('1');

        const goToUser = (id) => {
            router.push(`/user/${id}`); // 프로그래밍 방식으로 라우트 이동
        };

        const goToUserProfile = (id) => {
            router.push({ name: 'userProfile', params: { id: id }});
        };

        return {
            dynamicUserId,
            goToUser,
            goToUserProfile
        };
    }
});
app.use(router); // 라우터 사용
app.mount('#app-router');


// HTML (예상)
/*
<div id="app-router">
    <h1>Vue3 Vue Router 4 예시</h1>
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

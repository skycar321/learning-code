// Vue2 Slot
// 컴포넌트 콘텐츠 배포를 위한 Slot 사용법

// 나쁜 예시: 컴포넌트 내부에서 콘텐츠를 하드코딩하거나, props를 통해 복잡한 HTML 구조를 문자열로 전달하여 컴포넌트의 유연성을 떨어뜨림.
// 좋은 예시: Slot을 사용하여 컴포넌트 재사용성을 높이고, 부모 컴포넌트가 자식 컴포넌트의 특정 위치에 원하는 콘텐츠를 주입할 수 있도록 함.

// --- 1. 기본 Slot (Default Slot) ---
// 자식 컴포넌트 내에 `<slot></slot>` 태그를 사용하여 부모 컴포넌트에서 전달된 콘텐츠를 렌더링합니다.
Vue.component('base-card', {
    template: `
        <div class="card">
            <header>
                <slot name="header">
                    <h2>기본 헤더</h2> <!-- 슬롯에 콘텐츠가 제공되지 않으면 이 내용이 렌더링됩니다. -->
                </slot>
            </header>
            <main>
                <slot>
                    <p>기본 콘텐츠</p> <!-- 이름 없는 슬롯 (기본 슬롯) -->
                </slot>
            </main>
            <footer>
                <slot name="footer">
                    <p>기본 푸터</p>
                </slot>
            </footer>
        </div>
    `,
    // CSS for .card (예시)
    // .card { border: 1px solid #ddd; border-radius: 5px; padding: 15px; margin-bottom: 10px; }
    // .card header { border-bottom: 1px solid #eee; padding-bottom: 10px; margin-bottom: 10px; }
    // .card footer { border-top: 1px solid #eee; padding-top: 10px; margin-top: 10px; }
});

// --- 2. 이름 있는 Slot (Named Slots) ---
// `<slot name="슬롯이름"></slot>`을 사용하여 여러 개의 슬롯을 정의하고, 부모 컴포넌트에서 `v-slot:슬롯이름` 또는 `#슬롯이름` 디렉티브로 해당 슬롯에 콘텐츠를 주입합니다.
Vue.component('named-slots-example', {
    template: `
        <div class="container">
            <header>
                <slot name="header"></slot>
            </header>
            <main>
                <slot></slot> <!-- 기본 슬롯 -->
            </main>
            <footer>
                <slot name="footer"></slot>
            </footer>
        </div>
    `,
    // CSS for .container (예시)
    // .container { border: 2px solid #aaddff; padding: 20px; margin-top: 20px; }
});

// --- 3. 스코프드 Slot (Scoped Slots) ---
// 자식 컴포넌트의 데이터를 부모 컴포넌트의 슬롯 콘텐츠에서 접근할 수 있도록 하는 기능.
// `<slot :데이터이름="데이터"></slot>` 형식으로 데이터를 노출하고, 부모에서는 `v-slot:슬롯이름="props"`로 받아서 사용합니다.
Vue.component('scoped-slot-example', {
    template: `
        <div class="list-wrapper">
            <h3>아이템 목록 (Scoped Slot)</h3>
            <ul>
                <slot name="item"
                      v-for="(item, index) in items"
                      :item="item"
                      :index="index"
                      :key="item.id">
                    <!-- 기본 폴백 콘텐츠 (슬롯 내용이 제공되지 않을 때) -->
                    <li>{{ index }}: {{ item.text }}</li>
                </slot>
            </ul>
        </div>
    `,
    props: {
        items: {
            type: Array,
            default: () => []
        }
    }
});


new Vue({
    el: '#app-slots',
    data: {
        myItems: [
            { id: 1, text: '첫 번째 데이터' },
            { id: 2, text: '두 번째 데이터' },
            { id: 3, text: '세 번째 데이터' }
        ]
    }
});


// HTML (예상)
/*
<style>
.card { border: 1px solid #ddd; border-radius: 5px; padding: 15px; margin-bottom: 10px; }
.card header { border-bottom: 1px solid #eee; padding-bottom: 10px; margin-bottom: 10px; }
.card footer { border-top: 1px solid #eee; padding-top: 10px; margin-top: 10px; }

.container { border: 2px solid #aaddff; padding: 20px; margin-top: 20px; }
.list-wrapper { border: 1px dashed #999; padding: 15px; margin-top: 20px; }
</style>

<div id="app-slots">
    <h1>Vue2 Slot 예시</h1>

    <h2>1. 기본 Slot & 폴백 콘텐츠</h2>
    <base-card>
        <template v-slot:header>
            <h3>제목입니다!</h3>
        </template>
        <p>카드 본문 내용입니다.</p>
        <template v-slot:footer>
            <button>더 보기</button>
        </template>
    </base-card>

    <base-card>
        <!-- 슬롯을 제공하지 않으면 기본 폴백 콘텐츠가 렌더링됩니다. -->
        <p>기본 슬롯에만 콘텐츠 제공.</p>
    </base-card>

    <h2>2. 이름 있는 Slot</h2>
    <named-slots-example>
        <template v-slot:header>
            <h1>여기는 이름 있는 헤더 슬롯입니다.</h1>
        </template>
        <p>여기는 이름 없는 기본 슬롯입니다.</p>
        <template v-slot:footer>
            <p>여기는 이름 있는 푸터 슬롯입니다. &copy; 2023</p>
        </template>
    </named-slots-example>

    <h2>3. 스코프드 Slot</h2>
    <scoped-slot-example :items="myItems">
        <template v-slot:item="slotProps">
            <li :style="{ color: slotProps.index % 2 === 0 ? 'purple' : 'orange' }">
                {{ slotProps.index + 1 }}. {{ slotProps.item.text }} (부모에서 커스터마이징)
            </li>
        </template>
    </scoped-slot-example>

    <scoped-slot-example :items="myItems">
        <!-- 슬롯 내용이 없으면 자식 컴포넌트의 폴백 콘텐츠가 렌더링됩니다. -->
        <h3>다른 스코프드 슬롯</h3>
    </scoped-slot-example>
</div>
*/

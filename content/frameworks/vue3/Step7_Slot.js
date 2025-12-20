// Vue3 Slot (Named Slots, Scoped Slots)
// Vue3 Slot의 유연한 사용법 및 Scope Slots

// 나쁜 예시: 컴포넌트 내부에서 콘텐츠를 하드코딩하거나, props를 통해 복잡한 HTML 구조를 문자열로 전달하여 컴포넌트의 유연성을 떨어뜨림.
// 좋은 예시: Slot을 사용하여 컴포넌트 재사용성을 높이고, 부모 컴포넌트가 자식 컴포넌트의 특정 위치에 원하는 콘텐츠를 주입할 수 있도록 함.

// Vue3에서는 `<template v-slot:슬롯이름>` 대신 `<template #슬롯이름>`을 짧게 사용할 수 있습니다.
// 기본 슬롯은 `<template #default>` 또는 그냥 `<template>`으로 사용할 수 있습니다.
// 스코프드 슬롯은 `{ 데이터 }` 형태로 구조 분해 할당을 사용하여 데이터를 받을 수 있습니다.

// --- 1. 기본 Slot & 이름 있는 Slot ---
const CardComponent = {
    template: `
        <div class="card-vue3">
            <header>
                <slot name="header">
                    <h2>기본 헤더</h2> <!-- 폴백 콘텐츠 -->
                </slot>
            </header>
            <main>
                <slot>
                    <p>기본 콘텐츠</p> <!-- 기본 슬롯 (name="default") -->
                </slot>
            </main>
            <footer>
                <slot name="footer">
                    <p>기본 푸터</p>
                </slot>
            </footer>
        </div>
    `,
    // CSS in .vue file:
    // <style scoped>
    // .card-vue3 { border: 1px solid #ddd; border-radius: 5px; padding: 15px; margin-bottom: 10px; }
    // .card-vue3 header { border-bottom: 1px solid #eee; padding-bottom: 10px; margin-bottom: 10px; }
    // .card-vue3 footer { border-top: 1px solid #eee; padding-top: 10px; margin-top: 10px; }
    // </style>
};


// --- 2. 스코프드 Slot ---
// 자식 컴포넌트의 데이터를 부모 컴포넌트의 슬롯 콘텐츠에서 접근할 수 있도록 하는 기능.
// `defineProps`와 `defineEmits`처럼 `defineSlots` (experimental) 또는 `setup` 컨텍스트의 `slots` 객체를 사용합니다.
// 그러나 주로 템플릿에서 `v-for`와 함께 `:propName="propValue"` 형태로 슬롯 프롭스를 전달합니다.

const ScopedSlotListComponent = {
    template: `
        <div class="list-wrapper-vue3">
            <h3>아이템 목록 (Scoped Slot Vue3)</h3>
            <ul>
                <!-- `v-for`와 함께 슬롯 프롭스(item, index)를 노출 -->
                <slot name="item"
                      v-for="(item, index) in items"
                      :item="item"
                      :index="index"
                      :key="item.id">
                    <!-- 기본 폴백 콘텐츠 -->
                    <li>{{ index }}: {{ item.text }}</li>
                </slot>
            </ul>
            <slot name="empty" v-if="items.length === 0">
                <p>표시할 아이템이 없습니다.</p>
            </slot>
        </div>
    `,
    props: {
        items: {
            type: Array,
            default: () => []
        }
    }
};


const App = {
    components: {
        'card-component': CardComponent,
        'scoped-slot-list': ScopedSlotListComponent
    },
    setup() {
        const myItems = Vue.ref([
            { id: 101, text: '첫 번째 Vue3 데이터' },
            { id: 102, text: '두 번째 Vue3 데이터' },
            { id: 103, text: '세 번째 Vue3 데이터' }
        ]);
        const emptyItems = Vue.ref([]);

        return {
            myItems,
            emptyItems
        };
    }
};

Vue.createApp(App).mount('#app-slots');

// HTML (예상)
/*
<style>
.card-vue3 { border: 1px solid #ddd; border-radius: 5px; padding: 15px; margin-bottom: 10px; background-color: #f9f9f9; }
.card-vue3 header { border-bottom: 1px solid #eee; padding-bottom: 10px; margin-bottom: 10px; }
.card-vue3 footer { border-top: 1px solid #eee; padding-top: 10px; margin-top: 10px; }

.list-wrapper-vue3 { border: 1px dashed #999; padding: 15px; margin-top: 20px; background-color: #f0fff0; }
</style>

<div id="app-slots">
    <h1>Vue3 Slot 예시</h1>

    <h2>1. 기본 & 이름 있는 Slot</h2>
    <card-component>
        <template #header>
            <h3>Custom Header from Parent</h3>
        </template>
        <p>This is the main content for the default slot.</p>
        <template #footer>
            <button>Click Me!</button>
        </template>
    </card-component>

    <card-component>
        <!-- 기본 슬롯에만 내용 제공, 헤더/푸터는 폴백 콘텐츠 사용 -->
        <p>Only default slot content here.</p>
    </card-component>

    <h2>2. 스코프드 Slot</h2>
    <scoped-slot-list :items="myItems">
        <!-- v-slot 대신 # 약어를 사용할 수 있습니다. -->
        <!-- slotProps 객체에서 자식 컴포넌트가 노출한 item, index를 구조 분해 할당으로 받습니다. -->
        <template #item="{ item, index }">
            <li :style="{ color: index % 2 === 0 ? 'darkblue' : 'darkgreen' }">
                <strong>{{ index + 1 }}.</strong> {{ item.text }} (ID: {{ item.id }})
                <span style="font-size: 0.8em; color: gray;">- 부모에서 커스터마이징됨</span>
            </li>
        </template>
        <template #empty>
             <p style="color: red;">데이터가 현재 없습니다.</p>
        </template>
    </scoped-slot-list>

    <h3>빈 리스트 스코프드 슬롯</h3>
    <scoped-slot-list :items="emptyItems">
        <template #empty>
             <p style="color: gray; font-style: italic;">여기는 비어있는 리스트 슬롯을 위한 커스텀 메시지입니다.</p>
        </template>
    </scoped-slot-list>
</div>
*/

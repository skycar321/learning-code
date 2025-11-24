// Vue2 Mixin
// 컴포넌트 옵션 재사용을 위한 Mixin 사용법

// 나쁜 예시: 여러 컴포넌트에서 동일하거나 유사한 로직(데이터, 메서드, 라이프사이클 훅 등)을 중복해서 작성하여 코드의 효율성과 유지보수성을 떨어뜨림.
// 좋은 예시: Mixin을 사용하여 컴포넌트 간에 재사용 가능한 로직을 추출하고 공유하여 코드 중복을 줄이고 개발 효율성을 높임.

// Mixin은 컴포넌트 옵션을 재사용하는 유연한 방법입니다.
// 여러 컴포넌트에 동일한 로직(data, methods, computed, lifecycle hooks 등)을 "주입"할 수 있습니다.

// --- 1. 간단한 Mixin 예시 ---
const myMixin = {
    data() {
        return {
            mixinMessage: 'Mixin에서 온 메시지!',
            counter: 0
        };
    },
    methods: {
        mixinLog() {
            console.log(this.mixinMessage);
        },
        incrementCounter() {
            this.counter++;
        }
    },
    created() {
        console.log('[Mixin] created 훅이 실행되었습니다.');
    }
};

// --- 2. Mixin을 사용하는 컴포넌트 ---
const ComponentA = {
    mixins: [myMixin], // mixin 적용
    template: `
        <div style="border: 1px solid blue; padding: 10px; margin: 10px;">
            <h3>컴포넌트 A (Mixin 사용)</h3>
            <p>{{ mixinMessage }}</p>
            <p>카운터: {{ counter }}</p>
            <button @click="incrementCounter">카운터 증가 (Mixin 메서드)</button>
            <button @click="localMethodA">컴포넌트 A 메서드</button>
        </div>
    `,
    data() {
        return {
            localDataA: '컴포넌트 A의 로컬 데이터'
        };
    },
    methods: {
        localMethodA() {
            alert('컴포넌트 A에서 실행된 메서드. Mixin 메시지: ' + this.mixinMessage);
        }
    },
    created() {
        console.log('[Component A] created 훅이 실행되었습니다.');
        // Mixin의 훅이 먼저 실행되고, 컴포넌트의 훅이 나중에 실행됩니다.
    }
};

const ComponentB = {
    mixins: [myMixin], // 동일한 mixin 적용
    template: `
        <div style="border: 1px solid green; padding: 10px; margin: 10px;">
            <h3>컴포넌트 B (Mixin 사용)</h3>
            <p>메시지: {{ mixinMessage }}</p>
            <p>카운터: {{ counter }}</p>
            <button @click="incrementCounter">카운터 증가 (Mixin 메서드)</button>
            <button @click="localMethodB">컴포넌트 B 메서드</button>
        </div>
    `,
    data() {
        return {
            localDataB: '컴포넌트 B의 로컬 데이터'
        };
    },
    methods: {
        localMethodB() {
            alert('컴포넌트 B에서 실행된 메서드. Mixin 메시지: ' + this.mixinMessage);
        }
    },
    created() {
        console.log('[Component B] created 훅이 실행되었습니다.');
    }
};

// --- 3. Mixin과 컴포넌트 옵션 병합 동작 ---
// - 데이터(data): Mixin의 데이터와 컴포넌트의 데이터는 재귀적으로 병합됩니다. 충돌이 발생하면 컴포넌트의 데이터가 우선합니다.
// - 메서드(methods), 컴포넌트(components), 디렉티브(directives): 동일한 이름의 경우 컴포넌트 옵션이 우선합니다.
// - 라이프사이클 훅(lifecycle hooks): 같은 이름의 훅은 배열로 병합되어 Mixin의 훅이 먼저 실행되고 컴포넌트의 훅이 나중에 실행됩니다.

const overridingMixin = {
    data() {
        return {
            message: 'Mixin 메시지'
        };
    },
    methods: {
        myMethod() {
            console.log('Mixin의 myMethod');
        }
    }
};

const ComponentC = {
    mixins: [overridingMixin],
    template: `
        <div style="border: 1px solid red; padding: 10px; margin: 10px;">
            <h3>컴포넌트 C (Mixin 오버라이딩)</h3>
            <p>메시지: {{ message }}</p>
            <button @click="myMethod">메서드 호출</button>
        </div>
    `,
    data() {
        return {
            message: '컴포넌트 C의 메시지' // Mixin의 message를 오버라이딩
        };
    },
    methods: {
        myMethod() {
            console.log('컴포넌트 C의 myMethod (Mixin 오버라이딩)'); // Mixin의 myMethod를 오버라이딩
        }
    }
};


new Vue({
    el: '#app-mixin',
    components: {
        'component-a': ComponentA,
        'component-b': ComponentB,
        'component-c': ComponentC
    }
});


// Mixin의 장점:
// - 코드 재사용성: 여러 컴포넌트에서 공통 로직을 쉽게 공유할 수 있습니다.
// - 모듈화: 관련 로직을 별도의 파일로 분리하여 관리할 수 있습니다.

// Mixin의 단점 (주의 사항):
// - 명시적이지 않은 출처: Mixin에 정의된 속성이나 메서드가 어떤 Mixin에서 왔는지 파악하기 어려울 수 있습니다.
// - 이름 충돌 가능성: Mixin과 컴포넌트, 또는 여러 Mixin 간에 동일한 이름의 속성/메서드가 있을 경우 예상치 못한 동작을 할 수 있습니다.
// - 디버깅 어려움: 로직이 여러 계층에 분산되어 있어 디버깅이 복잡해질 수 있습니다.

// Vue3에서는 Composition API가 Mixin의 많은 단점을 해결하면서 로직 재사용의 더 강력하고 유연한 대안으로 제시되었습니다.
// (Step9_Mixin.js)

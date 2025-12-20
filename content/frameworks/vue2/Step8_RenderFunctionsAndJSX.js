// Vue2 Render Functions & JSX
// 템플릿의 대안인 렌더 함수와 JSX 활용

// 나쁜 예시: 모든 컴포넌트 로직을 템플릿으로만 처리하여 복잡한 동적 렌더링이나 조건부 렌더링 로직이 장황해짐.
// 좋은 예시: 렌더 함수나 JSX를 사용하여 컴포넌트의 렌더링 로직을 JavaScript 코드로 직접 작성하여 더 유연하고 강력한 제어 가능. (특히 동적/프로그래밍적 UI 구성에 유용)

// --- 1. 렌더 함수 (Render Function) ---
// Vue 컴포넌트는 `template` 옵션 외에 `render` 함수를 사용하여 렌더링 로직을 정의할 수 있습니다.
// `render` 함수는 `createElement` 함수 (일반적으로 `h`로 별칭)를 인자로 받습니다.
// `h` 함수는 HTML 태그 이름, 데이터 객체(props, attrs, class, style 등), 자식 노드 배열을 인자로 받습니다.

Vue.component('render-function-example', {
    props: ['level'],
    render: function (createElement) {
        // 이 컴포넌트의 렌더링 로직은 H1 ~ H6 태그 중 하나를 동적으로 생성합니다.
        return createElement(
            'h' + this.level, // 태그 이름
            {
                // 데이터 객체: 속성, 클래스, 스타일, 이벤트 리스너 등을 설정
                class: {
                    'title-level': true,
                    'is-large': this.level <= 2
                },
                style: {
                    color: this.level === 1 ? 'red' : 'black'
                },
                attrs: {
                    id: 'dynamic-title-' + this.level
                },
                on: {
                    click: this.handleClick
                }
            },
            [ // 자식 노드 배열
                createElement('span', 'Render Function '),
                createElement('strong', 'Level ' + this.level)
            ]
        );
    },
    methods: {
        handleClick() {
            alert(`Level ${this.level} 제목이 클릭되었습니다!`);
        }
    }
});

// --- 2. JSX (JavaScript XML) ---
// JSX는 React에서 널리 사용되는 문법 확장으로, JavaScript 코드 내에서 HTML과 유사한 마크업을 작성할 수 있게 합니다.
// Vue에서도 Babel 플러그인(babel-plugin-transform-vue-jsx)을 통해 JSX를 사용할 수 있습니다.
// JSX는 내부적으로 렌더 함수로 변환됩니다.

// JSX를 사용하려면 Babel 설정이 필요하며, 여기서는 개념적인 코드만 보여줍니다.
// 실제 프로젝트에서는 Vue CLI와 Babel 플러그인 설정이 되어 있어야 합니다.

// Vue.component('jsx-example', {
//     props: ['message'],
//     render() {
//         // JSX 문법 사용
//         return (
//             <div class="jsx-container">
//                 <h3>JSX 예제</h3>
//                 <p>{this.message.toUpperCase()}</p>
//                 <button onClick={() => alert('JSX 버튼 클릭됨!')}>클릭하세요</button>
//             </div>
//         );
//     }
// });

new Vue({
    el: '#app-render-jsx',
    data: {
        currentLevel: 1
    },
    methods: {
        changeLevel() {
            this.currentLevel = this.currentLevel % 6 + 1; // 1부터 6까지 순환
        }
    }
});

// 렌더 함수와 JSX의 장점:
// - JavaScript의 모든 기능을 활용하여 렌더링 로직을 작성할 수 있습니다.
// - 복잡한 동적 UI, 프로그래밍적 컴포넌트 구성에 템플릿보다 더 유연하고 강력합니다.
// - 템플릿 컴파일 오버헤드가 없으므로 미세한 성능 최적화가 가능합니다 (대부분의 경우 템플릿으로도 충분).

// 단점:
// - 템플릿보다 가독성이 떨어질 수 있습니다 (특히 익숙하지 않은 경우).
// - 개발 환경 설정이 필요할 수 있습니다 (JSX의 경우).

// HTML (예상)
/*
<style>
.title-level { font-family: sans-serif; }
.title-level.is-large { font-size: 2.5em; }
.jsx-container { border: 1px dashed blue; padding: 10px; margin-top: 10px; }
</style>

<div id="app-render-jsx">
    <h1>Vue2 렌더 함수 & JSX 예시</h1>

    <h2>렌더 함수 컴포넌트</h2>
    <render-function-example :level="1"></render-function-example>
    <render-function-example :level="2"></render-function-example>
    <render-function-example :level="currentLevel"></render-function-example>
    <button @click="changeLevel">레벨 변경</button>

    <h2>JSX 컴포넌트 (개념적 예시)</h2>
    <p>JSX 예시는 Babel 플러그인이 필요하므로, 여기서는 코드만 제시합니다.</p>
    <!-- <jsx-example message="Hello from JSX!"></jsx-example> -->
</div>
*/

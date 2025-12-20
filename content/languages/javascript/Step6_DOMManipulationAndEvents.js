// JavaScript DOM 조작과 이벤트
// 웹 페이지 요소 조작, 이벤트 핸들링, 가상 DOM 개념 이해

// 나쁜 예시: `innerHTML`을 사용하여 복잡한 HTML 문자열을 삽입하거나, 이벤트 리스너를 동적으로 추가/제거하지 않고 비효율적으로 관리.
// 좋은 예시: `document.createElement`, `appendChild` 등을 사용하여 DOM을 조작하고, `addEventListener`로 이벤트를 효율적으로 처리.

// HTML 구조 (예상):
// <div id="app">
//     <h1 id="title">DOM 조작 예시</h1>
//     <button id="myButton">클릭하세요!</button>
//     <ul id="myList">
//         <li>아이템 1</li>
//         <li>아이템 2</li>
//     </ul>
//     <div id="messageContainer"></div>
// </div>

document.addEventListener('DOMContentLoaded', () => { // DOM이 완전히 로드된 후 스크립트 실행

    console.log("DOM이 로드되었습니다.");

    // --- 1. 요소 선택 ---
    const title = document.getElementById('title');
    const button = document.getElementById('myButton');
    const list = document.getElementById('myList');
    const messageContainer = document.getElementById('messageContainer');

    console.log("선택된 요소:", title, button, list, messageContainer);

    // --- 2. 요소 내용 변경 ---
    if (title) {
        title.textContent = 'JavaScript DOM 조작 실습'; // 텍스트만 변경 (안전)
        // title.innerHTML = '<i>JavaScript</i> DOM 조작 실습'; // HTML 태그도 인식 (보안 위험 주의)
    }

    // --- 3. 요소 스타일 변경 ---
    if (title) {
        title.style.color = 'blue';
        title.style.fontSize = '24px';
    }

    // --- 4. 클래스 추가/제거 ---
    if (button) {
        button.classList.add('btn', 'btn-primary'); // 여러 클래스 추가
        // button.classList.remove('btn-primary');
        // button.classList.toggle('active');
    }

    // --- 5. 새로운 요소 생성 및 추가 ---
    if (list) {
        const newItem = document.createElement('li'); // <li> 요소 생성
        newItem.textContent = '새로운 아이템 3'; // 텍스트 설정
        list.appendChild(newItem); // 리스트의 마지막에 추가

        const firstItem = document.createElement('li');
        firstItem.textContent = '새로운 아이템 0';
        list.prepend(firstItem); // 리스트의 처음에 추가 (ES6+)

        // 특정 위치에 삽입
        const existingItem = list.children[2]; // 기존 아이템 2 (원래 아이템 1)
        const insertItem = document.createElement('li');
        insertItem.textContent = '삽입된 아이템';
        list.insertBefore(insertItem, existingItem); // 기존 아이템 2 앞에 삽입
    }

    // --- 6. 요소 제거 ---
    if (list && list.children.length > 0) {
        const itemToRemove = list.children[1]; // 두 번째 아이템 제거
        // list.removeChild(itemToRemove);
        itemToRemove.remove(); // 최신 방식 (IE 지원 안 함)
    }

    // --- 7. 이벤트 핸들링 ---
    let clickCount = 0;
    if (button) {
        button.addEventListener('click', () => { // 버튼 클릭 이벤트 리스너 추가
            clickCount++;
            if (messageContainer) {
                messageContainer.textContent = `버튼이 ${clickCount}번 클릭되었습니다.`;
                messageContainer.style.color = 'green';
            }
        });

        // 마우스 오버/아웃 이벤트
        button.addEventListener('mouseover', () => {
            button.style.backgroundColor = 'lightgray';
        });
        button.addEventListener('mouseout', () => {
            button.style.backgroundColor = ''; // 원래대로
        });
    }

    // --- 8. 가상 DOM (Virtual DOM) 개념 (프레임워크 없이 구현은 복잡, 개념 설명) ---
    // 실제 DOM을 직접 조작하는 것은 느리고 비효율적일 수 있습니다.
    // React, Vue와 같은 라이브러리는 가상 DOM이라는 개념을 사용하여 이 문제를 해결합니다.
    // 가상 DOM은 실제 DOM의 가벼운 사본으로, 변경 사항이 생기면 먼저 가상 DOM에서 업데이트를 합니다.
    // 그 후 이전 가상 DOM과 현재 가상 DOM을 비교(Diffing)하여 최소한의 변경 사항만 실제 DOM에 반영(Reconciliation)합니다.
    // 이 과정은 실제 DOM 조작 횟수를 줄여 성능을 향상시킵니다.

    if (messageContainer) {
        const virtualDomExplanation = document.createElement('p');
        virtualDomExplanation.innerHTML = `
            <br>
            <strong>가상 DOM (Virtual DOM) 개념:</strong><br>
            React, Vue 같은 프레임워크에서 실제 DOM의 가벼운 사본을 만들어 변경 사항을 미리 계산하고,
            최소한의 변경만 실제 DOM에 반영하여 성능을 최적화하는 기술입니다.
            직접 DOM을 조작하는 것보다 효율적입니다.
        `;
        messageContainer.appendChild(virtualDomExplanation);
    }
});

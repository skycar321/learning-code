// JavaScript Fetch API와 AJAX
// 서버와 통신하는 Fetch API 및 XHR (AJAX) 학습

// 나쁜 예시: XMLHttpRequest를 직접 사용하여 코드가 복잡해지거나, 비동기 처리를 제대로 하지 않아 UI가 멈추는 현상 발생.
// 좋은 예시: Fetch API를 사용하여 간결하고 현대적인 방식으로 서버와 통신하고, Promise 기반의 비동기 처리를 통해 사용자 경험을 개선.

console.log("--- 1. Fetch API (Modern JavaScript) ---");
// Fetch API는 Promise 기반으로 비동기 네트워크 요청을 수행합니다.
// 주로 GET 요청을 통해 데이터를 가져오고, POST/PUT/DELETE 등으로 데이터를 전송합니다.

const API_URL = "https://jsonplaceholder.typicode.com/posts/1"; // 공개 테스트 API 예시

// GET 요청 예시
async function fetchPost() {
    try {
        const response = await fetch(API_URL); // 요청
        if (!response.ok) { // HTTP 상태 코드가 200번대가 아니면 에러
            throw new Error(`HTTP 오류! 상태: ${response.status}`);
        }
        const data = await response.json(); // 응답을 JSON 형태로 파싱
        console.log("Fetch GET 성공:", data);
    } catch (error) {
        console.error("Fetch GET 실패:", error);
    }
}

fetchPost();

// POST 요청 예시
async function createPost() {
    try {
        const newPost = {
            title: 'foo',
            body: 'bar',
            userId: 1,
        };

        const response = await fetch('https://jsonplaceholder.typicode.com/posts', {
            method: 'POST', // HTTP 메서드
            headers: {
                'Content-Type': 'application/json', // 전송할 데이터 타입
            },
            body: JSON.stringify(newPost), // JavaScript 객체를 JSON 문자열로 변환하여 전송
        });

        if (!response.ok) {
            throw new Error(`HTTP 오류! 상태: ${response.status}`);
        }

        const data = await response.json();
        console.log("Fetch POST 성공:", data);
    } catch (error) {
        console.error("Fetch POST 실패:", error);
    }
}

createPost();


console.log("\n--- 2. XMLHttpRequest (XHR) / AJAX (레거시 방식) ---");
// Asynchronous JavaScript and XML (AJAX)는 JavaScript를 사용하여 비동기적으로 서버와 통신하는 기술을 총칭합니다.
// XMLHttpRequest(XHR) 객체를 사용하며, Fetch API 이전에 주로 사용되던 방식입니다.

function loadDoc() {
    const xhttp = new XMLHttpRequest(); // XMLHttpRequest 객체 생성
    
    // 응답이 준비되면 실행될 함수 정의
    xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) { // readyState 4: 요청 완료, status 200: 성공
            console.log("XHR GET 성공:", JSON.parse(this.responseText)); // 응답 텍스트를 JSON으로 파싱
        } else if (this.readyState == 4 && this.status != 200) {
            console.error(`XHR GET 실패: 상태 ${this.status}`);
        }
    };
    
    // 요청 설정
    xhttp.open("GET", API_URL, true); // GET 메서드, URL, 비동기(true)
    xhttp.send(); // 요청 전송
}

loadDoc();

// XHR POST 요청 예시 (Fetch API에 비해 복잡함)
function sendDataXHR() {
    const xhttp = new XMLHttpRequest();
    const newPost = {
        title: 'XHR foo',
        body: 'XHR bar',
        userId: 1,
    };

    xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 201) { // POST 성공 시 주로 201 Created
            console.log("XHR POST 성공:", JSON.parse(this.responseText));
        } else if (this.readyState == 4 && this.status != 201) {
            console.error(`XHR POST 실패: 상태 ${this.status}`);
        }
    };

    xhttp.open("POST", 'https://jsonplaceholder.typicode.com/posts', true);
    xhttp.setRequestHeader("Content-Type", "application/json"); // 헤더 설정
    xhttp.send(JSON.stringify(newPost)); // 데이터 전송
}

sendDataXHR();

console.log("\nFetch API가 XHR보다 더 현대적이고 사용하기 쉽습니다. 특별한 이유가 없다면 Fetch API를 사용하는 것이 좋습니다.");

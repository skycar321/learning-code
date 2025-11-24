// JavaScript 비동기 처리
// Callback, Promise, Async/Await를 이용한 비동기 프로그래밍 학습

// 나쁜 예시: 콜백 헬(Callback Hell)로 인해 코드 가독성이 떨어지고 유지보수가 어려움.
// 좋은 예시: Promise와 Async/Await를 사용하여 비동기 코드를 동기 코드처럼 읽기 쉽게 작성하고 오류 처리를 명확하게 함.

// --- 1. Callback (콜백) ---
// 비동기 작업이 완료되면 실행될 함수를 인자로 넘기는 방식
console.log("--- Callback 예시 ---");
function fetchData(callback) {
    setTimeout(() => {
        const data = "데이터 가져오기 성공!";
        callback(data); // 데이터 가져온 후 콜백 함수 호출
    }, 1000);
}

function processData(data, callback) {
    setTimeout(() => {
        const processedData = data.toUpperCase();
        callback(processedData);
    }, 500);
}

function displayData(processedData) {
    console.log("콜백 최종 결과:", processedData);
}

// 콜백 헬 예시 (나쁜 예시)
// fetchData((data) => {
//     processData(data, (processedData) => {
//         displayData(processedData);
//     });
// });


// --- 2. Promise (프로미스) ---
// 비동기 작업의 최종 완료 또는 실패를 나타내는 객체
console.log("\n--- Promise 예시 ---");

function fetchDataPromise() {
    return new Promise((resolve, reject) => {
        setTimeout(() => {
            const success = true; // 가상으로 성공/실패 여부 결정
            if (success) {
                resolve("데이터 가져오기 성공 (Promise)!"); // 성공 시 resolve 호출
            } else {
                reject("데이터 가져오기 실패 (Promise)!"); // 실패 시 reject 호출
            }
        }, 1000);
    });
}

function processDataPromise(data) {
    return new Promise((resolve) => {
        setTimeout(() => {
            resolve(data.toUpperCase());
        }, 500);
    });
}

// Promise 체이닝 (좋은 예시)
fetchDataPromise()
    .then((data) => {
        console.log("1단계 Promise:", data);
        return processDataPromise(data);
    })
    .then((processedData) => {
        console.log("2단계 Promise:", processedData);
        console.log("Promise 최종 결과:", processedData);
    })
    .catch((error) => { // 체인 중 발생한 모든 에러를 한 번에 처리
        console.error("Promise 오류:", error);
    });


// --- 3. Async/Await (비동기/대기) ---
// Promise를 더 쉽고 동기 코드처럼 보이게 작성하는 ES2017 문법
console.log("\n--- Async/Await 예시 ---");

async function fetchDataAsync() {
    return new Promise((resolve) => {
        setTimeout(() => {
            resolve("데이터 가져오기 성공 (Async/Await)!");
        }, 1200);
    });
}

async function processDataAsync(data) {
    return new Promise((resolve) => {
        setTimeout(() => {
            resolve(data.toUpperCase());
        }, 600);
    });
}

async function performAsyncTask() {
    try {
        const data = await fetchDataAsync(); // Promise가 resolve될 때까지 기다림
        console.log("1단계 Async/Await:", data);
        const processedData = await processDataAsync(data);
        console.log("2단계 Async/Await:", processedData);
        console.log("Async/Await 최종 결과:", processedData);
    } catch (error) { // try-catch 블록으로 에러 처리
        console.error("Async/Await 오류:", error);
    }
}

performAsyncTask();

console.log("\n비동기 작업이 백그라운드에서 진행 중...");

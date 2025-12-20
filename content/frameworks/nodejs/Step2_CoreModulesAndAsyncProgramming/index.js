// nodejs/Step2_CoreModulesAndAsyncProgramming/index.js
// Node.js 학습 계획 - 2단계: 핵심 모듈 및 비동기 프로그래밍
// 이 파일은 Node.js의 핵심 모듈(파일 시스템: `fs`, 이벤트: `events`)과
// JavaScript의 비동기 프로그래밍 패턴(Promise, Async/Await)을 학습하기 위한 예시입니다.
//
// Node.js는 단일 스레드, 비동기, 이벤트 기반 아키텍처를 통해 높은 처리량을 제공합니다.
// 이 아키텍처를 이해하고 비동기 코드를 올바르게 작성하는 것이 Node.js 개발의 핵심입니다.

const fs = require('fs').promises; // Promise 기반의 fs 모듈 사용
const EventEmitter = require('events'); // EventEmitter 클래스 임포트
const path = require('path'); // 경로 처리 모듈

// -----------------------------------------------------------------------------
// 학습 포인트 1: 파일 시스템 (File System) - `fs` 모듈
// - Node.js의 내장 `fs` 모듈은 파일 및 디렉토리와 상호 작용하는 기능을 제공합니다.
// - 비동기(Promise 기반 또는 콜백) 및 동기 API를 제공합니다.
// - 비동기 API를 사용하는 것이 Node.js의 이벤트 루프를 블로킹하지 않아 성능에 유리합니다.
// -----------------------------------------------------------------------------
async function fileSystemOperations() {
    console.log("--- 2.1. 파일 시스템 (fs) 모듈 ---");

    const filePath = path.join(__dirname, 'sample.txt'); // 현재 디렉토리에 sample.txt 파일 경로 생성
    const newFilePath = path.join(__dirname, 'renamed.txt');
    const dirPath = path.join(__dirname, 'temp_dir');

    try {
        // 1.1. 파일 쓰기 (비동기)
        await fs.writeFile(filePath, 'Hello Node.js File System!\n', 'utf8');
        console.log(`'${filePath}' 파일에 쓰기 완료.`);

        // 1.2. 파일 내용 추가 (비동기)
        await fs.appendFile(filePath, 'Appending new line.\n', 'utf8');
        console.log(`'${filePath}' 파일에 내용 추가 완료.`);

        // 1.3. 파일 읽기 (비동기)
        const content = await fs.readFile(filePath, 'utf8');
        console.log(`'${filePath}' 파일 내용:\n${content}`);

        // 1.4. 파일 이름 변경 (비동기)
        await fs.rename(filePath, newFilePath);
        console.log(`'${filePath}' 파일 이름이 '${newFilePath}'로 변경 완료.`);

        // 1.5. 디렉토리 생성 (비동기)
        await fs.mkdir(dirPath);
        console.log(`'${dirPath}' 디렉토리 생성 완료.`);

        // 1.6. 디렉토리 읽기 (비동기)
        const files = await fs.readdir(__dirname);
        console.log(`현재 디렉토리 파일 목록: ${files.join(', ')}`);

        // 1.7. 디렉토리 삭제 (비동기)
        await fs.rmdir(dirPath); // Node.js 14+부터는 fs.rm(dirPath, { recursive: true }) 권장
        console.log(`'${dirPath}' 디렉토리 삭제 완료.`);

    } catch (err) {
        console.error("파일 시스템 작업 중 오류 발생:", err);
    } finally {
        // 생성했던 파일 정리
        try {
            await fs.unlink(newFilePath); // 파일 삭제
            console.log(`'${newFilePath}' 파일 정리 완료.`);
        } catch (err) {
            // 파일이 없으면 에러가 발생할 수 있으므로 무시
        }
    }
    console.log("");
}

// -----------------------------------------------------------------------------
// 학습 포인트 2: 이벤트(Events) - `events` 모듈, `EventEmitter`
// - Node.js의 많은 내장 모듈은 EventEmitter를 상속하여 이벤트를 발행하고 수신합니다.
// - `on()` 또는 `addListener()`: 이벤트 리스너 등록.
// - `emit()`: 이벤트 발행.
// - `once()`: 이벤트를 한 번만 수신.
// -----------------------------------------------------------------------------
function eventEmitterExample() {
    console.log("--- 2.2. EventEmitter 예시 ---");

    // EventEmitter 인스턴스 생성
    const myEmitter = new EventEmitter();

    // 이벤트 리스너 등록
    myEmitter.on('greet', (name) => {
        console.log(`'greet' 이벤트 수신: Hello, ${name}!`);
    });

    // 한 번만 실행될 이벤트 리스너
    myEmitter.once('firstConnection', () => {
        console.log("'firstConnection' 이벤트가 처음이자 마지막으로 수신되었습니다.");
    });

    // 에러 이벤트 핸들링 (없으면 uncaughtException 발생 가능)
    myEmitter.on('error', (err) => {
        console.error(`'error' 이벤트 수신: ${err.message}`);
    });

    // 이벤트 발행
    myEmitter.emit('greet', 'Bob');
    myEmitter.emit('greet', 'Charlie'); // 'greet' 이벤트 다시 발행
    myEmitter.emit('firstConnection'); // 'firstConnection' 이벤트 발행 (한 번만 실행)
    myEmitter.emit('firstConnection'); // 다시 발행해도 실행되지 않음

    // 에러 이벤트 발행
    myEmitter.emit('error', new Error('Something went wrong!'));

    // 나쁜 예시: 비동기 작업에서 에러를 이벤트를 통해 발행했는데,
    // - 해당 에러 이벤트를 `on('error', ...)`로 처리하지 않는 것.
    // - `error` 이벤트는 특별하게 취급되므로, 항상 리스너를 등록해야 합니다.
    // - 그렇지 않으면 Node.js 프로세스가 비정상 종료될 수 있습니다.
    console.log("");
}


// -----------------------------------------------------------------------------
// 학습 포인트 3: Promise 및 Async/Await
// - 비동기 작업의 결과를 나타내는 객체입니다. 콜백 지옥(Callback Hell)을 해결합니다.
// - `Promise`: `resolve` (성공), `reject` (실패) 콜백을 인자로 받는 함수로 생성.
// - `then()`, `catch()`, `finally()` 메서드를 사용하여 Promise의 상태 변화에 따른 로직 처리.
// - `async/await`: Promise를 더 간결하고 동기적인 코드처럼 작성할 수 있게 하는 문법.
//   - `async` 함수는 항상 Promise를 반환.
//   - `await`는 `async` 함수 내에서만 사용 가능하며, Promise가 해결될 때까지 함수의 실행을 일시 중단.
// -----------------------------------------------------------------------------
function simulateAsyncOperation(delayMs, shouldSucceed) {
    return new Promise((resolve, reject) => {
        setTimeout(() => {
            if (shouldSucceed) {
                resolve(`작업 성공: ${delayMs}ms 지연`);
            } else {
                reject(new Error(`작업 실패: ${delayMs}ms 지연`));
            }
        }, delayMs);
    });
}

async function asyncAwaitExample() {
    console.log("--- 2.3. Promise 및 Async/Await 예시 ---");

    try {
        console.log("Async/Await: 작업 1 시작");
        const result1 = await simulateAsyncOperation(1000, true);
        console.log(result1);

        console.log("Async/Await: 작업 2 시작");
        const result2 = await simulateAsyncOperation(500, true);
        console.log(result2);

        // 병렬 처리: `Promise.all()`
        console.log("Async/Await: 병렬 작업 시작");
        const [parallelResult1, parallelResult2] = await Promise.all([
            simulateAsyncOperation(1200, true),
            simulateAsyncOperation(800, true)
        ]);
        console.log(`병렬 작업 결과 1: ${parallelResult1}`);
        console.log(`병렬 작업 결과 2: ${parallelResult2}`);

        console.log("Async/Await: 실패하는 작업 시작 (에러 처리)");
        await simulateAsyncOperation(300, false); // 이 라인에서 에러 발생
        console.log("이 메시지는 출력되지 않습니다.");

    } catch (error) {
        // 나쁜 예시: `async/await`을 사용하면서 `try-catch` 블록으로 에러를 처리하지 않는 것.
        // - 비동기 함수 내에서 발생하는 에러는 `try-catch`로 명시적으로 잡아야 합니다.
        // - 그렇지 않으면 `UnhandledPromiseRejection` 경고나 프로세스 종료로 이어질 수 있습니다.
        console.error(`Async/Await에서 에러 캐치: ${error.message}`);
    } finally {
        console.log("Async/Await: 모든 작업 시도 완료.");
    }
    console.log("");
}

// -----------------------------------------------------------------------------
// 학습 포인트 4: 스트림(Streams) (개념)
// - 대규모 데이터를 작은 청크(chunk) 단위로 처리하는 방식.
// - Readable (읽기), Writable (쓰기), Duplex (양방향), Transform (읽기-변환-쓰기) 스트림.
// - 이벤트 기반으로 동작하며, `pipe()` 메서드를 통해 스트림 간 데이터를 연결할 수 있습니다.
// - 용도: 대용량 파일 처리, 네트워크 데이터 전송, 실시간 데이터 처리 등.
// -----------------------------------------------------------------------------
function streamsExample() {
    console.log("--- 2.4. 스트림 (Streams) 예시 (개념적) ---");
    console.log("  스트림은 대규모 데이터를 효율적으로 처리하는 데 사용됩니다.");
    console.log("  예시: 대용량 파일을 읽고 압축하여 다른 파일에 쓰는 작업 (fs.createReadStream, zlib.createGzip, fs.createWriteStream)");
    console.log("  fs.createReadStream('input.txt')")
    console.log("    .pipe(zlib.createGzip())")
    console.log("    .pipe(fs.createWriteStream('input.txt.gz'))");
    console.log("  이를 통해 전체 파일을 메모리에 로드하지 않고 데이터를 청크 단위로 처리할 수 있습니다.");
    console.log("나쁜 예시: 대용량 파일이나 네트워크 데이터를 `fs.readFile`로 한 번에 메모리에 로드하는 것.")
    console.log("  - 메모리 부족(OOM) 오류를 유발하거나, Node.js 이벤트 루프를 블로킹하여 성능 저하를 일으킬 수 있습니다.");
    console.log("");
}

// -----------------------------------------------------------------------------
// 학습 포인트 5: Error Handling (오류 처리)
// - Node.js는 비동기 환경이므로 동기/비동기 에러 처리를 구분해야 합니다.
// - `try-catch`: 동기 코드 블록의 에러 처리. 비동기 Promise의 `.catch()`와 `async/await`의 `try-catch`에 사용.
// - `process.on('uncaughtException', ...)`: 처리되지 않은 동기 예외를 잡음. (최후의 수단)
// - `process.on('unhandledRejection', ...)`: 처리되지 않은 Promise 거부(rejection)를 잡음. (최후의 수단)
// -----------------------------------------------------------------------------
function errorHandlingExample() {
    console.log("--- 2.5. Error Handling (오류 처리) ---");

    // 동기 에러 처리
    try {
        // throw new Error("동기 에러 발생!");
        console.log("동기 에러 처리 테스트 (주석 해제 후 확인)");
    } catch (e) {
        console.error("동기 에러 캐치:", e.message);
    }

    // `process.on('uncaughtException')`는 처리되지 않은 동기 예외를 잡는 최후의 수단
    // `process.on('unhandledRejection')`는 처리되지 않은 Promise 거부를 잡는 최후의 수단
    // 이들은 일반적으로 모든 에러를 잡는 용도로 사용되지만,
    // 실제 운영 환경에서는 가능한 한 명시적으로 에러를 처리하고 프로세스를 정상 종료하는 것이 좋습니다.
    // 나쁜 예시: `uncaughtException`이나 `unhandledRejection`으로 에러를 잡은 후
    // - 프로세스를 계속 실행하여 불안정한 상태를 유지하는 것.
    // - 이런 최상위 에러 핸들러는 로그를 남기고 프로세스를 종료하는 용도로 사용해야 합니다.
    console.log("에러 처리 완료.");
    console.log("");
}


async function main() {
    console.log("--- 2단계: 핵심 모듈 및 비동기 프로그래밍 ---");
    await fileSystemOperations();
    eventEmitterExample();
    await asyncAwaitExample();
    streamsExample();
    errorHandlingExample();
    console.log("--- 2단계 학습 완료 ---");
}

main(); // 메인 함수 실행

/*
이 코드를 실행하려면:

1. `package.json` 파일과 함께 `nodejs/Step2_CoreModulesAndAsyncProgramming` 디렉토리를 생성.
2. `index.js` 파일을 이 파일의 내용으로 저장.
3. 터미널에서 `nodejs/Step2_CoreModulesAndAsyncProgramming` 디렉토리로 이동.
4. `node index.js` 명령으로 애플리케이션 실행.
*/

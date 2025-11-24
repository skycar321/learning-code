# Step2: Node.js 핵심 모듈 및 비동기 프로그래밍

이 디렉토리는 Node.js의 핵심 모듈(`fs`, `events`, `path`)과 JavaScript의 비동기 프로그래밍 패턴(`Promise`, `Async/Await`)을 학습하기 위한 예제 코드입니다.

## 학습 목표

-   `fs` 모듈을 이용한 파일 시스템 비동기 처리
-   `EventEmitter`를 이용한 이벤트 기반 프로그래밍
-   `Promise` 및 `Async/Await`를 이용한 비동기 코드 작성
-   Node.js의 비동기 모델 및 에러 처리 전략 이해
-   스트림(Streams)을 이용한 효율적인 데이터 처리 개념

## 프로젝트 구조

```
nodejs/Step2_CoreModulesAndAsyncProgramming/
├── index.js                  # 핵심 모듈 및 비동기 프로그래밍 예제
├── sample.txt                # fs 모듈 테스트용 임시 파일 (생성 후 삭제됨)
├── renamed.txt               # fs 모듈 테스트용 임시 파일 (생성 후 삭제됨)
├── temp_dir/                 # fs 모듈 테스트용 임시 디렉토리 (생성 후 삭제됨)
└── README.md
```

## 파일 설명

-   **`index.js`**:
    -   **파일 시스템 (`fs`) 모듈**: `fs.promises`를 사용하여 Promise 기반의 비동기 파일 읽기, 쓰기, 추가, 이름 변경, 디렉토리 생성 및 삭제 작업을 보여줍니다.
    -   **이벤트 (`events`) 모듈**: `EventEmitter` 클래스를 사용하여 `on()`, `emit()`, `once()`, `on('error', ...)` 메서드를 통해 이벤트를 발행하고 수신하는 방법을 보여줍니다.
    -   **`Promise` 및 `Async/Await`**: `simulateAsyncOperation` 함수에서 Promise를 생성하고, `asyncAwaitExample` 함수에서 `await` 키워드를 사용하여 비동기 작업을 동기 코드처럼 순차적으로 실행하며 `Promise.all()`을 통해 여러 비동기 작업을 병렬로 처리하는 방법을 보여줍니다. `try-catch`를 이용한 에러 처리도 포함합니다.
    -   **스트림 (`Streams`)**: 대용량 파일 처리의 효율성을 높이는 스트림의 개념을 설명합니다. (실제 구현은 생략)
    -   **오류 처리 (Error Handling)**: `try-catch`를 이용한 동기 에러 처리와 `process.on('uncaughtException')`, `process.on('unhandledRejection')`과 같은 최상위 에러 핸들링의 개념을 설명합니다.

## 설정 및 실행 방법

`nodejs/Step2_CoreModulesAndAsyncProgramming` 디렉토리에서 터미널을 열고 다음 명령어를 실행합니다.

1.  **프로젝트 준비**:
    -   `index.js` 파일을 위 내용으로 생성합니다. `package.json` 파일은 필요하지 않습니다 (외부 의존성 없음).

2.  **애플리케이션 실행**:
    ```bash
    node index.js
    ```
    -   콘솔에 파일 시스템 작업, 이벤트 발생 및 수신, 비동기 작업의 시작과 완료 메시지가 순서대로 출력됩니다.
    -   파일 시스템 작업 후 `sample.txt`, `renamed.txt`, `temp_dir` 등의 임시 파일/디렉토리가 자동으로 생성되었다가 삭제되는 것을 확인할 수 있습니다.

## 나쁜 예시와 좋은 예시 (개념)

`index.js` 파일 내의 주석을 참조하여, Node.js 핵심 모듈 및 비동기 프로그래밍 사용 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. Node.js는 비동기 프로그래밍이 기본이므로, 콜백, Promise, `Async/Await`를 올바르게 사용하고 에러를 명시적으로 처리하는 것이 안정적인 애플리케이션 개발의 핵심입니다.

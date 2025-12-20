# Step1: Node.js 기본 개념 및 시작

이 디렉토리는 Node.js의 기본 개념, 모듈 시스템, 패키지 관리자(npm) 및 이벤트 루프를 학습하기 위한 예제 코드입니다.

## 학습 목표

-   Node.js의 `CommonJS` 모듈 시스템 (`require`, `module.exports`) 이해
-   `package.json` 파일의 역할 및 `scripts` 관리
-   `npm` (Node Package Manager)을 이용한 의존성 관리
-   `process` 객체를 이용한 Node.js 환경 정보 확인

## 프로젝트 구조

```
nodejs/Step1_NodeJSBasics/
├── package.json              # 프로젝트 메타데이터 및 의존성 정의
├── index.js                  # 애플리케이션의 메인 엔트리 포인트
├── myModule.js               # CommonJS 모듈 예제
└── README.md
```

## 파일 설명

-   **`package.json`**:
    -   `name`, `version`, `description`: 프로젝트의 기본 정보.
    -   `main: "index.js"`: 애플리케이션의 메인 스크립트 파일을 지정합니다.
    -   `scripts`: `npm start`, `npm run dev`와 같이 명령줄에서 실행할 사용자 정의 스크립트를 정의합니다. `start`는 `node index.js`를 실행하고, `dev`는 `node --watch index.js`를 실행하여 파일 변경 시 자동으로 재시작합니다.
    -   `dependencies`, `devDependencies`: 프로젝트의 런타임 및 개발 시 필요한 외부 라이브러리를 정의합니다.

-   **`index.js`**:
    -   `require('./myModule')`: `myModule.js` 파일을 임포트하여 `myModule.greet()` 및 `myModule.add()` 함수를 사용합니다.
    -   `process` 객체: `process.version`, `process.platform`, `process.argv`, `process.env`를 통해 Node.js 런타임 환경 정보를 확인하는 방법을 보여줍니다.

-   **`myModule.js`**:
    -   `module.exports = { greet, add };`: `greet`와 `add` 함수를 객체 형태로 내보내어 다른 파일에서 `require()`로 임포트하여 사용할 수 있도록 합니다.

## 설정 및 실행 방법

`nodejs/Step1_NodeJSBasics` 디렉토리에서 터미널을 열고 다음 명령어를 실행합니다.

1.  **프로젝트 준비**:
    -   `index.js` 및 `myModule.js` 파일을 위 내용으로 생성합니다.

2.  **의존성 설치**:
    ```bash
    npm install
    ```
    -   `package.json`에 정의된 의존성을 설치합니다. 현재 예시에는 외부 의존성이 없으므로 설치되는 것은 없습니다.

3.  **애플리케이션 실행**:
    ```bash
    npm start
    # 또는 node index.js
    ```
    -   콘솔에 "Hello from Node.js!"와 `myModule`에서 반환된 메시지 및 계산 결과가 출력됩니다.
    -   `process` 객체를 통해 Node.js 버전, 플랫폼, 환경 변수 등이 출력됩니다.

4.  **개발 모드 실행 (파일 변경 감지)**:
    ```bash
    npm run dev
    ```
    -   `--watch` 옵션을 사용하여 `index.js` 파일이 변경될 때마다 애플리케이션이 자동으로 재시작됩니다. `index.js`나 `myModule.js` 파일을 수정하고 저장하면 콘솔에서 재시작 메시지를 확인할 수 있습니다.

5.  **명령줄 인자 테스트**:
    ```bash
    node index.js "Hello argument"
    ```
    -   `process.argv`를 통해 명령줄 인자가 어떻게 전달되는지 확인합니다.

## 나쁜 예시와 좋은 예시 (개념)

`index.js` 및 `myModule.js` 파일 내의 주석을 참조하여, Node.js 기본 개념 사용 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 특히 `CommonJS` 모듈 시스템을 올바르게 사용하고, `process` 객체를 통해 Node.js 런타임 환경을 이해하는 것은 Node.js 개발의 기초입니다.

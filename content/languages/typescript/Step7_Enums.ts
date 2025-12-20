// TypeScript 열거형 (Enums)
// 숫자 또는 문자열 기반의 열거형 정의 및 활용

// 나쁜 예시: 하드코딩된 '마법의 문자열/숫자'를 사용하여 코드의 의미를 파악하기 어렵게 만들거나, 오타로 인한 오류를 발생시킵니다.
// 좋은 예시: 열거형을 사용하여 관련 값들의 집합에 의미 있는 이름을 부여하고, 코드의 가독성 및 유지보수성을 높입니다.

// --- 1. 숫자 열거형 (Numeric Enums) ---
// 기본적으로 0부터 시작하여 1씩 증가합니다.
enum Direction {
    Up,      // 0
    Down,    // 1
    Left,    // 2
    Right    // 3
}

let userDirection: Direction = Direction.Up;
console.log(`사용자 방향: ${userDirection} (${Direction.Up})`); // 0

// 값을 수동으로 지정할 수도 있습니다.
enum StatusCode {
    NotFound = 404,
    Success = 200,
    Accepted = 202,
    BadRequest = 400
}

let responseStatus: StatusCode = StatusCode.Success;
console.log(`응답 상태: ${responseStatus} (${StatusCode.Success})`); // 200

// 역방향 매핑 (Reverse Mapping): 숫자 열거형은 숫자 값을 통해 열거형 멤버의 이름을 얻을 수 있습니다.
let successCode: number = 200;
console.log(`200의 열거형 이름: ${StatusCode[successCode]}`); // Success


// --- 2. 문자열 열거형 (String Enums) ---
// 모든 멤버에 문자열 리터럴로 초기화해야 합니다.
// 숫자 열거형에 비해 가독성이 좋고 디버깅에 유리합니다.
enum UserRole {
    Admin = "ADMIN",
    Editor = "EDITOR",
    Viewer = "VIEWER"
}

let currentUserRole: UserRole = UserRole.Admin;
console.log(`현재 사용자 역할: ${currentUserRole}`); // ADMIN

function checkPermissions(role: UserRole): void {
    if (role === UserRole.Admin) {
        console.log("관리자 권한이 있습니다.");
    } else {
        console.log("일반 사용자 권한입니다.");
    }
}
checkPermissions(currentUserRole);
checkPermissions(UserRole.Editor);

// 문자열 열거형은 역방향 매핑을 지원하지 않습니다.
// console.log(UserRole["ADMIN"]); // Error: Element implicitly has an 'any' type because expression of type '"ADMIN"' can't be used to index type 'typeof UserRole'.


// --- 3. 이종 열거형 (Heterogeneous Enums) ---
// 숫자와 문자열 멤버를 섞어서 사용할 수 있지만 권장되지 않습니다. (가독성 저해)
enum Mixed {
    No = 0,
    Yes = "YES"
}
let answerNo: Mixed = Mixed.No;
let answerYes: Mixed = Mixed.Yes;
console.log(`Mixed.No: ${answerNo}`); // 0
console.log(`Mixed.Yes: ${answerYes}`); // YES


// --- 4. Const 열거형 (Const Enums) ---
// 열거형 멤버가 사용되는 곳에 인라인(inline)으로 치환되어 추가적인 코드가 생성되지 않습니다.
// 런타임에 열거형 객체가 필요하지 않고, 오직 타입 안정성과 가독성 향상 목적으로만 사용될 때 유용합니다.
const enum LogLevel {
    ERROR,
    WARN,
    INFO,
    DEBUG
}

let level: LogLevel = LogLevel.INFO;

function logMessage(message: string, level: LogLevel) {
    if (level === LogLevel.ERROR) {
        console.error(`[ERROR] ${message}`);
    } else if (level === LogLevel.INFO) {
        console.info(`[INFO] ${message}`);
    }
    // ...
}
logMessage("데이터베이스 연결 실패", LogLevel.ERROR);
logMessage("사용자 로그인 성공", LogLevel.INFO);

// 컴파일 후 (JavaScript):
// "데이터베이스 연결 실패", 0 /* LogLevel.ERROR */
// "사용자 로그인 성공", 2 /* LogLevel.INFO */
// 실제 런타임 코드에는 LogLevel 객체 자체가 남지 않고 값으로 대체됩니다.

// 학습 포인트: 열거형은 코드의 의도를 명확하게 전달하고, 오타로 인한 오류를 방지하며,
// 관련된 상수들을 한곳에 모아 관리할 수 있게 해줍니다.
// 문자열 열거형이 숫자 열거형보다 가독성이 좋고 명시적이며, 대부분의 경우 권장됩니다.

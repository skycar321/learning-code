// Step1_GolangBasicsAndTools.go
// Golang 기본 문법 및 도구 학습을 위한 코드 예시입니다.
// 이 파일은 Golang의 기본적인 문법, 변수, 자료형, 연산자, 흐름 제어, 함수,
// 패키지 및 모듈 관리, 그리고 Go CLI 도구 사용법을 이해하는 데 중점을 둡니다.
//
// Go 언어는 간결하고 효율적인 문법을 특징으로 하며, 강력한 표준 라이브러리와
// 빌트인 도구를 통해 개발 생산성을 높여줍니다.

package main // 'main' 패키지는 실행 가능한 프로그램의 진입점을 포함합니다.

import (
	"fmt"      // 포맷된 입출력 함수 (예: Println)
	"math"     // 수학 함수 (예: Pi)
	"runtime"  // 런타임 환경 정보 (예: Go 버전)
	"strconv"  // 문자열-숫자 변환
	"time"     // 시간 관련 함수
)

// -----------------------------------------------------------------------------
// 학습 포인트 1: Golang 소개 및 환경 설정 (개념)
// - Go 설치: 공식 웹사이트 (golang.org)에서 다운로드 및 설치.
// - GOPATH, Workspace: Go 모듈 시스템 도입 이후 GOPATH의 중요성은 줄어들었습니다.
//   이제 프로젝트 디렉토리에서 `go mod init`으로 모듈을 초기화하는 것이 일반적입니다.
// - `go env`: Go 환경 변수 확인.
// -----------------------------------------------------------------------------
func init() {
	// init() 함수는 main() 함수가 호출되기 전에 자동으로 실행됩니다.
	fmt.Println("--- 1단계: Golang 기본 문법 및 도구 ---")
	fmt.Printf("Go 버전: %s\n", runtime.Version())
	fmt.Printf("OS: %s, 아키텍처: %s\n", runtime.GOOS, runtime.GOARCH)
	fmt.Println("")
}

// -----------------------------------------------------------------------------
// 학습 포인트 2: 기본 문법 (변수, 상수, 데이터 타입, 연산자)
// -----------------------------------------------------------------------------

func basicSyntax() {
	fmt.Println("2.1. 변수 선언 (Variables)")
	// 2.1.1. `var` 키워드를 사용한 변수 선언
	var a int        // int 타입의 변수 'a' 선언 (초기값은 0)
	var b string = "Hello Go" // string 타입의 변수 'b' 선언 및 초기화
	var c bool       // bool 타입의 변수 'c' 선언 (초기값은 false)
	fmt.Printf("var a: %d, var b: %s, var c: %t\n", a, b, c)

	// 2.1.2. 타입 추론 (`:=`)을 사용한 변수 선언 (함수 내에서만 사용 가능)
	// `:=` 연산자는 변수 선언과 초기화를 동시에 수행하며, Go가 타입을 자동으로 추론합니다.
	x := 10          // int 타입
	y := "World"     // string 타입
	z := true        // bool 타입
	fmt.Printf(":= x: %d, y: %s, z: %t\n", x, y, z)

	// 나쁜 예시: 불필요하게 `var` 키워드를 사용하거나, 사용하지 않는 변수를 선언하는 것.
	// - Go는 사용하지 않는 변수가 있으면 컴파일 에러를 발생시켜 클린 코드를 유도합니다.
	// var unusedVar int // 이 줄은 컴파일 에러를 유발합니다 (사용하지 않는 변수).

	fmt.Println("2.2. 상수 선언 (Constants)")
	const PI = 3.141592
	const Greeting = "안녕하세요"
	fmt.Printf("const PI: %f, Greeting: %s\n", PI, Greeting)

	// 2.3. 데이터 타입 (Data Types)
	// - 정수형: int, int8, int16, int32, int64, uint (부호 없는 정수)
	// - 부동소수점형: float32, float64
	// - 불리언형: bool
	// - 문자열형: string
	// - 복소수형: complex64, complex128
	var numInt int = 100
	var numFloat float64 = 3.14
	var isGo bool = true
	var str string = "Go is awesome"
	fmt.Printf("numInt: %T, numFloat: %T, isGo: %T, str: %T\n", numInt, numFloat, isGo, str)

	// 2.4. 연산자 (Operators)
	// - 산술: +, -, *, /, %, ++, --
	// - 관계: ==, !=, <, <=, >, >=
	// - 논리: &&, ||, !
	// - 비트: &, |, ^, <<, >>
	result := numInt + 5
	fmt.Printf("100 + 5 = %d\n", result)
	fmt.Printf("isGo && true = %t\n", isGo && true)
	fmt.Println("")
}

// -----------------------------------------------------------------------------
// 학습 포인트 3: 흐름 제어 (Control Flow)
// - `if`, `for`, `switch`
// -----------------------------------------------------------------------------

func controlFlow() {
	fmt.Println("3.1. `if` 문")
	num := 15
	if num%2 == 0 { // 조건문에 괄호 `()`는 필요 없습니다.
		fmt.Printf("%d는 짝수입니다.\n", num)
	} else if num%3 == 0 {
		fmt.Printf("%d는 3의 배수입니다.\n", num)
	} else {
		fmt.Printf("%d는 홀수입니다.\n", num)
	}

	// `if` 문에 간단한 선언문(short statement) 포함 가능
	if val := getResult(); val > 10 {
		fmt.Printf("getResult()의 결과는 10보다 큽니다: %d\n", val)
	} else {
		fmt.Printf("getResult()의 결과는 10보다 작거나 같습니다: %d\n", val)
	}
	// 'val' 변수는 이 `if-else` 블록 내에서만 유효합니다.

	fmt.Println("3.2. `for` 문")
	// 3.2.1. C 스타일 for 루프
	for i := 0; i < 3; i++ {
		fmt.Printf("for loop iteration: %d\n", i)
	}

	// 3.2.2. while 스타일 for 루프 (조건식만 사용)
	sum := 1
	for sum < 100 {
		sum += sum
	}
	fmt.Printf("sum (while style): %d\n", sum)

	// 3.2.3. 무한 루프
	// for { // 이 루프는 무한히 실행되므로 주석 처리합니다.
	// 	fmt.Println("This is an infinite loop!")
	// }

	// 3.2.4. `for-range` 루프 (슬라이스, 맵 등 컬렉션 순회)
	numbers := []int{10, 20, 30}
	for index, value := range numbers {
		fmt.Printf("Index: %d, Value: %d\n", index, value)
	}

	fmt.Println("3.3. `switch` 문")
	day := "Wednesday"
	switch day { // `switch` 문도 `if`와 마찬가지로 조건문에 괄호가 필요 없습니다.
	case "Monday", "Tuesday": // 여러 케이스를 콤마로 구분 가능
		fmt.Println("주 초입니다.")
	case "Wednesday":
		fmt.Println("주 중반입니다.")
	case "Thursday", "Friday":
		fmt.Println("주 후반입니다.")
	default: // 일치하는 케이스가 없을 경우
		fmt.Println("주말입니다.")
	}

	// `switch` 문에도 간단한 선언문(short statement) 포함 가능
	hour := time.Now().Hour()
	switch { // 조건식 생략 시 `true`를 가정
	case hour < 12:
		fmt.Println("오전입니다.")
	case hour < 18:
		fmt.Println("오후입니다.")
	default:
		fmt.Println("저녁입니다.")
	}
	fmt.Println("")
}

func getResult() int {
	return 12
}

// -----------------------------------------------------------------------------
// 학습 포인트 4: 함수 (Functions)
// - 다중 반환 값 (Multiple return values)
// - defer 문 (defer statement)
// -----------------------------------------------------------------------------

func functions() {
	fmt.Println("4.1. 다중 반환 값")
	// Go 함수는 여러 개의 값을 반환할 수 있습니다.
	// 주로 `(result, error)` 패턴으로 에러 처리 시 사용됩니다.
	area, circumference := calculateCircle(5.0)
	fmt.Printf("원의 넓이: %.2f, 원의 둘레: %.2f\n", area, circumference)

	value, err := parseStringToInt("123")
	if err != nil {
		fmt.Printf("문자열 변환 오류: %v\n", err)
	} else {
		fmt.Printf("문자열 '123'을 숫자로 변환: %d\n", value)
	}

	_, err = parseStringToInt("abc") // 에러만 관심 있을 경우 `_` (블랭크 식별자) 사용
	if err != nil {
		fmt.Printf("문자열 'abc' 변환 오류: %v\n", err)
	}

	fmt.Println("4.2. `defer` 문")
	// `defer` 문에 지정된 함수는 현재 함수가 종료되기 직전에 실행됩니다.
	// 주로 파일 닫기, 락 해제, 리소스 정리 등에 사용되어 오류 발생 시에도 자원 누수를 방지합니다.
	fmt.Println("  함수 시작")
	defer fmt.Println("  함수 종료 (defer 1)") // LIFO (Last-In, First-Out)
	defer fmt.Println("  함수 종료 (defer 2)") // 이 메시지가 먼저 출력됩니다.
	fmt.Println("  함수 중간 작업")

	// 나쁜 예시: 리소스 해제를 `defer` 없이 `if err != nil` 블록 안에만 두는 것.
	// - 함수 내 다른 경로에서 오류가 발생하면 리소스가 해제되지 않을 수 있습니다.
	// - 항상 리소스 획득 직후 `defer`로 해제를 예약하는 것이 좋습니다.
	// file, err := os.Open("example.txt")
	// if err != nil { /* ... */ }
	// defer file.Close() // 좋은 예시
	// if err2 != nil { /* ... */ return }
	// if err3 != nil { /* ... */ return }
	// file.Close() // 나쁜 예시 (함수 종료 시점에만 닫히지 않을 수 있음)
	fmt.Println("")
}

func calculateCircle(radius float64) (float64, float64) {
	area := math.Pi * radius * radius
	circumference := 2 * math.Pi * radius
	return area, circumference
}

func parseStringToInt(s string) (int, error) {
	val, err := strconv.Atoi(s)
	if err != nil {
		return 0, fmt.Errorf("문자열 '%s'을 숫자로 변환할 수 없습니다: %w", s, err)
	}
	return val, nil // 에러가 없을 경우 `nil`을 반환
}

// -----------------------------------------------------------------------------
// 학습 포인트 5: 패키지(Packages) 및 모듈(Modules) 이해
// - 패키지: Go 코드의 캡슐화 단위. 관련된 함수, 타입 등을 묶습니다.
//   - `main` 패키지는 실행 가능한 프로그램의 진입점.
//   - `fmt`, `math`, `time` 등은 표준 라이브러리 패키지.
// - 모듈: 여러 패키지를 포함할 수 있는 버전 관리 단위.
//   - `go mod init <module-path>`: 현재 디렉토리를 모듈로 초기화. `go.mod` 파일 생성.
//   - `go get <package-path>`: 외부 패키지 다운로드 및 `go.mod`에 기록.
//   - `go mod tidy`: 사용되지 않는 의존성 제거.
// -----------------------------------------------------------------------------

func packagesAndModules() {
	fmt.Println("5.1. 패키지 사용 예시")
	// `fmt.Println`은 `fmt` 패키지의 `Println` 함수를 호출합니다.
	fmt.Printf("수학 상수 Pi: %f\n", math.Pi) // `math` 패키지의 `Pi` 상수 사용
	fmt.Println("현재 시간: ", time.Now()) // `time` 패키지의 `Now` 함수 사용

	fmt.Println("5.2. 모듈 관리 (개념적 설명)")
	fmt.Println("  - `go mod init <module_name>`: 현재 프로젝트를 모듈로 초기화합니다.")
	fmt.Println("  - `go get <외부_패키지_경로>`: 외부 패키지를 다운로드하고 `go.mod`에 의존성을 추가합니다.")
	fmt.Println("  - `go mod tidy`: `go.mod`와 `go.sum` 파일을 정리합니다.")
	fmt.Println("나쁜 예시: `go mod tidy`를 주기적으로 실행하지 않아 불필요한 의존성이 쌓이는 것.")
	fmt.Println("좋은 예시: 프로젝트의 루트 디렉토리에서 `go mod init`으로 시작하고,")
	fmt.Println("           필요한 외부 패키지는 `go get`으로 추가하며, `go mod tidy`로 관리하는 것.")
	fmt.Println("")
}

// -----------------------------------------------------------------------------
// 학습 포인트 6: Go CLI 도구 활용 (`go run`, `go build`, `go mod`)
// -----------------------------------------------------------------------------

func cliTools() {
	fmt.Println("6. Go CLI 도구 활용 (개념적 설명)")
	fmt.Println("  - `go run <file.go>`: 소스 코드를 컴파일하고 바로 실행합니다.")
	fmt.Println("  - `go build <file.go>`: 실행 가능한 바이너리 파일을 생성합니다.")
	fmt.Println("  - `go install <package-path>`: 패키지를 컴파일하고 실행 파일을 GOPATH/bin에 설치합니다.")
	fmt.Println("  - `go test`: 테스트 파일을 실행합니다.")
	fmt.Println("  - `go fmt`: 코드 스타일을 Go 표준에 맞게 포맷합니다.")
	fmt.Println("  - `go vet`: 잠재적인 버그를 찾아주는 정적 분석 도구입니다.")
	fmt.Println("  - `go doc <symbol>`: 특정 심볼에 대한 문서를 출력합니다.")
	fmt.Println("나쁜 예시: `go fmt` 없이 코드를 개발하여 팀 내에서 일관되지 않은 코드 스타일을 사용하는 것.")
	fmt.Println("좋은 예시: `go fmt`를 사용하여 일관된 코드 스타일을 유지하고, `go vet`으로 잠재적인 문제를 미리 해결하는 것.")
	fmt.Println("")
}

// main 함수는 프로그램의 시작점입니다.
func main() {
	basicSyntax()
	controlFlow()
	functions()
	packagesAndModules()
	cliTools()

	fmt.Println("--- 1단계 학습 완료 ---")
}

/*
이 코드를 실행하려면:

1. Go SDK 설치 (golang.org에서 다운로드 및 설치).
2. 터미널 또는 명령 프롬프트에서 이 파일이 있는 디렉토리로 이동.
3. `go run Step1_GolangBasicsAndTools.go` 명령을 실행.

Go 모듈 관련 실습을 하려면:
1. 새 디렉토리 생성 (예: `myproject`).
2. `myproject` 디렉토리로 이동.
3. `go mod init example.com/myproject` 실행 (모듈 이름은 고유하게).
4. `go get github.com/gorilla/mux`와 같은 외부 패키지 설치 시도.
5. `go mod tidy` 실행.
*/

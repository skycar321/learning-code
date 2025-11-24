// Step5_TestingDeploymentAndAdvancedTopics.go
// Golang 테스트, 배포 및 고급 주제 학습을 위한 코드 예시입니다.
// 이 파일은 Go의 내장 테스트 프레임워크를 활용한 유닛 테스트, 테이블 테스트,
// 벤치마킹 방법을 보여줍니다. 또한 Docker를 이용한 배포와 Go의 고급 주제에 대한
// 개념적인 설명을 포함합니다.
//
// Go는 개발자가 테스트를 쉽게 작성하고, 애플리케이션의 성능을 측정하며,
// 효율적으로 배포할 수 있도록 강력한 도구들을 내장하고 있습니다.

package main // 'main' 패키지는 실행 가능한 프로그램의 진입점을 포함합니다.

import (
	"fmt"
	"reflect" // 리플렉션 패키지
	"runtime" // 런타임 패키지
	"sync"    // 동시성 제어
	"testing" // 테스트 패키지 (이 파일에서는 예시로만 사용, 실제는 별도 _test.go 파일)
	"time"    // 시간 관련
)

// -----------------------------------------------------------------------------
// 학습 포인트 1: 테스트 (Testing)
// - Go는 `testing` 패키지를 통해 내장된 테스트 기능을 제공합니다.
// - 테스트 파일은 `_test.go` 접미사를 가지며, `go test` 명령어로 실행됩니다.
// - 테스트 함수는 `TestXxx(*testing.T)` 시그니처를 가집니다.
// - `t.Error`, `t.Errorf`, `t.Fail`, `t.FailNow`, `t.Fatal`, `t.Fatalf` 등으로 테스트 실패를 알립니다.
// -----------------------------------------------------------------------------

// 예시 함수: 두 정수의 합을 반환
func Add(a, b int) int {
	return a + b
}

// 예시 함수: 문자열을 역순으로 반환
func ReverseString(s string) string {
	runes := []rune(s) // 유니코드 문자를 올바르게 처리하기 위해 rune 슬라이스 사용
	for i, j := 0, len(runes)-1; i < j; i, j = i+1, j-1 {
		runes[i], runes[j] = runes[j], runes[i]
	}
	return string(runes)
}

/*
// --- Unit Test 예시 (실제로는 `_test.go` 파일에 작성되어야 합니다) ---
// func TestAdd(t *testing.T) {
// 	if Add(1, 2) != 3 {
// 		t.Error("Add(1, 2) should be 3")
// 	}
// 	if Add(-1, 1) != 0 {
// 		t.Errorf("Add(-1, 1) expected 0, got %d", Add(-1, 1))
// 	}
// }

// --- Table Test 예시 ---
// 여러 입력과 예상 출력 쌍을 테이블 형태로 정의하여 테스트합니다.
// func TestReverseString(t *testing.T) {
// 	tests := []struct {
// 		input    string
// 		expected string
// 	}{
// 		{"hello", "olleh"},
// 		{"Go", "oG"},
// 		{"안녕하세요", "요세하녕안"}, // 유니코드 테스트
// 		{"", ""},
// 		{"a", "a"},
// 	}
//
// 	for _, test := range tests {
// 		t.Run(test.input, func(t *testing.T) { // `t.Run`을 사용하여 서브 테스트를 생성
// 			actual := ReverseString(test.input)
// 			if actual != test.expected {
// 				t.Errorf("For input %q, expected %q, got %q", test.input, test.expected, actual)
// 			}
// 		})
// 	}
// }
*/

// -----------------------------------------------------------------------------
// 학습 포인트 2: 벤치마킹 (Benchmarking)
// - Go는 `testing` 패키지를 통해 내장된 벤치마킹 기능을 제공합니다.
// - 벤치마크 함수는 `BenchmarkXxx(*testing.B)` 시그니처를 가집니다.
// - `b.N`은 벤치마크 루프의 반복 횟수를 나타내며, 런타임에 동적으로 조정됩니다.
// - `go test -bench=.` 명령어로 실행됩니다.
// -----------------------------------------------------------------------------

/*
// --- Benchmark 예시 (실제로는 `_test.go` 파일에 작성되어야 합니다) ---
// func BenchmarkAdd(b *testing.B) {
// 	for i := 0; i < b.N; i++ {
// 		Add(i, i+1)
// 	}
// }

// func BenchmarkReverseString(b *testing.B) {
// 	testString := "benchmark string for testing performance"
// 	for i := 0; i < b.N; i++ {
// 		ReverseString(testString)
// 	}
// }
*/

// -----------------------------------------------------------------------------
// 학습 포인트 3: 리플렉션 (Reflection)
// - 런타임에 변수의 타입, 값, 구조체 필드 등에 접근하고 조작할 수 있게 합니다.
// - `reflect` 패키지를 사용합니다.
// - 주로 직렬화/역직렬화, ORM, 테스팅 프레임워크 등에서 사용됩니다.
// - 성능 오버헤드가 있으므로 필요한 경우에만 신중하게 사용해야 합니다.
// -----------------------------------------------------------------------------
type Person struct {
	Name string `json:"name_field"` // JSON 태그
	Age  int
}

func reflectionExample() {
	fmt.Println("\n3. 리플렉션 (Reflection)")

	p := Person{"Alice", 30}
	pType := reflect.TypeOf(p)
	pValue := reflect.ValueOf(p)

	fmt.Printf("값: %v, 타입: %v\n", pValue, pType)

	// 필드 정보 접근
	for i := 0; i < pType.NumField(); i++ {
		field := pType.Field(i)
		fmt.Printf("  필드 이름: %s, 타입: %v, 값: %v\n", field.Name, field.Type, pValue.Field(i).Interface())
		// JSON 태그 읽기
		jsonTag := field.Tag.Get("json")
		if jsonTag != "" {
			fmt.Printf("    JSON 태그: %s\n", jsonTag)
		}
	}

	// 값 변경 (포인터를 통해서만 가능)
	ptrToP := reflect.ValueOf(&p)
	if ptrToP.Kind() == reflect.Pointer && ptrToP.Elem().CanSet() {
		ptrToP.Elem().FieldByName("Age").SetInt(31)
		fmt.Printf("리플렉션을 통한 Age 변경: %v\n", p)
	}

	// 나쁜 예시: 리플렉션을 과도하게 사용하여 코드 가독성과 성능을 저하시키는 것.
	// - Go는 명시적인 코드를 선호하며, 리플렉션은 마지막 수단으로 고려해야 합니다.
	fmt.Println("")
}

// -----------------------------------------------------------------------------
// 학습 포인트 4: 포인터 (Pointers) 심화
// - 변수의 메모리 주소를 저장하는 타입.
// - `*` 연산자로 포인터가 가리키는 값에 접근하고, `&` 연산자로 변수의 주소를 가져옵니다.
// - 값 타입 (int, string, struct)은 함수에 전달될 때 복사되지만, 포인터는 주소만 복사.
// - 대규모 구조체를 함수에 전달할 때 성능 향상 (복사 오버헤드 감소).
// - 함수 내에서 원본 값을 변경해야 할 때 사용.
// -----------------------------------------------------------------------------
func pointersExample() {
	fmt.Println("\n4. 포인터 (Pointers) 심화")

	x := 10
	fmt.Printf("초기 x의 값: %d, 주소: %p\n", x, &x)

	// `&` 연산자로 변수의 주소를 가져와 포인터 변수에 할당
	ptr := &x
	fmt.Printf("ptr의 값 (x의 주소): %p, ptr이 가리키는 값: %d\n", ptr, *ptr)

	// `*` 연산자로 포인터가 가리키는 값을 변경
	*ptr = 20
	fmt.Printf("포인터를 통해 변경 후 x의 값: %d\n", x)

	// 함수에 포인터 전달
	y := 100
	fmt.Printf("함수 호출 전 y: %d\n", y)
	modifyValue(&y) // y의 주소를 전달
	fmt.Printf("함수 호출 후 y: %d\n", y)

	// 나쁜 예시: 포인터를 너무 복잡하게 중첩하여 사용하거나,
// 불필요한 상황에서 포인터를 사용하여 코드 가독성을 해치는 것.
// - 적절한 상황 (큰 구조체 전달, 원본 값 변경)에서만 사용하는 것이 좋습니다.
	fmt.Println("")
}

func modifyValue(val *int) {
	*val = *val * 2 // 포인터가 가리키는 값을 두 배로 만듭니다.
	fmt.Printf("  함수 내에서 포인터를 통해 변경된 값: %d\n", *val)
}

// -----------------------------------------------------------------------------
// 학습 포인트 5: Docker를 이용한 배포 (Deployment with Docker) (개념적 설명)
// - Go 애플리케이션은 정적 컴파일되어 단일 바이너리로 생성되므로 Docker 이미지로 만들기 매우 쉽습니다.
// - `Dockerfile`을 사용하여 Go 애플리케이션을 빌드하고 컨테이너화합니다.
// -----------------------------------------------------------------------------
/*
// 예시 Dockerfile:
// # Build Stage
// FROM golang:1.21-alpine AS builder
// WORKDIR /app
// COPY . .
// RUN go mod download
// RUN CGO_ENABLED=0 GOOS=linux go build -o /app/main .

// # Run Stage
// FROM alpine:latest
// WORKDIR /root/
// COPY --from=builder /app/main .
// CMD ["./main"]

// Go 앱을 Docker 이미지로 빌드하고 실행하는 단계:
// 1. `go mod init <module_name>` (아직 안 했다면)
// 2. `docker build -t my-go-app .`
// 3. `docker run -p 8080:8080 my-go-app`
*/
func dockerDeploymentConcept() {
	fmt.Println("\n5. Docker를 이용한 배포 (개념적 설명)")
	fmt.Println("  - Go는 정적 컴파일 언어이므로, 최종 빌드된 바이너리 파일 하나만 있으면 실행 가능합니다.")
	fmt.Println("  - 이를 Alpine 리눅스 같은 경량 베이스 이미지에 복사하여 매우 작은 Docker 이미지를 만들 수 있습니다.")
	fmt.Println("  - Dockerfile을 사용하여 Go 애플리케이션을 컨테이너화하면, 환경 일관성과 배포 용이성을 확보할 수 있습니다.")
	fmt.Println("나쁜 예시: 개발 환경과 다른 운영 환경에 대한 고려 없이 Go 바이너리만 복사하여 배포하는 것.")
	fmt.Println("좋은 예시: Dockerfile을 multistage build로 작성하여 작고 안전하며 이식성 있는 이미지를 만드는 것.")
	fmt.Println("")
}

// -----------------------------------------------------------------------------
// 학습 포인트 6: 마이크로서비스 아키텍처에서의 Golang (개념적 설명)
// - Go는 경량 고루틴, 빠른 시작 시간, 뛰어난 네트워크 성능으로 마이크로서비스 개발에 이상적입니다.
// - gRPC와 Protocol Buffers를 사용하여 고성능 서비스 간 통신을 구현하기 용이합니다.
// -----------------------------------------------------------------------------
func microservicesConcept() {
	fmt.Println("\n6. 마이크로서비스 아키텍처에서의 Golang (개념적 설명)")
	fmt.Println("  - Go는 저지연(low-latency) 및 고처리량(high-throughput)이 요구되는 마이크로서비스에 적합합니다.")
	fmt.Println("  - gRPC를 이용한 서비스 간 통신은 Go에서 특히 강력합니다.")
	fmt.Println("나쁜 예시: 마이크로서비스 아키텍처를 도입하면서도 각 서비스 간의 통신 부하를 고려하지 않는 것.")
	fmt.Println("좋은 예시: Go와 gRPC를 사용하여 서비스 간 빠르고 효율적인 통신 메커니즘을 구축하는 것.")
	fmt.Println("")
}

// -----------------------------------------------------------------------------
// 학습 포인트 7: Go Best Practices 및 Clean Code (개념적 설명)
// - 간결하고 명확한 코드 작성.
// - 에러 처리 철학 준수 (try-catch 대신 `(result, error)`).
// - 적절한 패키지 구조.
// - 테스트 용이한 코드 설계.
// - `go fmt`, `go vet`, `golint` 등 도구 활용.
// -----------------------------------------------------------------------------
func bestPracticesConcept() {
	fmt.Println("\n7. Go Best Practices 및 Clean Code (개념적 설명)")
	fmt.Println("  - Go는 '명시적(explicit)'이고 '간결한(simple)' 코드를 선호합니다.")
	fmt.Println("  - 불필요한 복잡성을 피하고, 작은 함수와 명확한 변수 이름을 사용합니다.")
	fmt.Println("  - 일관된 코드 스타일과 에러 처리 패턴을 유지합니다.")
	fmt.Println("나쁜 예시: Java/Python 등 다른 언어의 패턴을 Go에 억지로 적용하려 하거나, 불필요한 추상화를 사용하는 것.")
	fmt.Println("좋은 예시: Go의 관용적인(idiomatic) 코드 작성 방식을 따르고, Go 철학에 맞는 설계를 지향하는 것.")
	fmt.Println("")
}

// main 함수는 프로그램의 시작점입니다.
func main() {
	fmt.Println("--- 5단계: 테스트, 배포 및 고급 주제 ---")
	// 테스트 및 벤치마킹은 실제 `_test.go` 파일에서 실행되므로, 이 main 함수에서는 호출하지 않습니다.
	// 대신, 다른 고급 주제들을 실행합니다.

	reflectionExample()
	pointersExample()
	dockerDeploymentConcept()
	microservicesConcept()
	bestPracticesConcept()

	fmt.Println("--- 5단계 학습 완료 ---")
}

/*
이 코드를 실행하려면:

1. Go SDK 설치 (golang.org에서 다운로드 및 설치).
2. 터미널 또는 명령 프롬프트에서 이 파일이 있는 디렉토리로 이동.
3. `go run Step5_TestingDeploymentAndAdvancedTopics.go` 명령을 실행.

테스트 및 벤치마크 코드를 실행하려면:

1. 위 `main` 함수 블록 내의 주석 처리된 `TestXxx` 및 `BenchmarkXxx` 함수들을
   별도의 `step5_test.go` 파일에 복사합니다.
2. `go test` 명령어로 유닛 테스트를 실행.
3. `go test -bench=.` 명령어로 벤치마크 테스트를 실행.

예시 `step5_test.go` 파일 내용:

```go
package main

import (
	"testing"
)

func TestAdd(t *testing.T) {
	if Add(1, 2) != 3 {
		t.Error("Add(1, 2) should be 3")
	}
	if Add(-1, 1) != 0 {
		t.Errorf("Add(-1, 1) expected 0, got %d", Add(-1, 1))
	}
}

func TestReverseString(t *testing.T) {
	tests := []struct {
		input    string
		expected string
	}{
		{"hello", "olleh"},
		{"Go", "oG"},
		{"안녕하세요", "요세하녕안"},
		{"", ""},
		{"a", "a"},
	}

	for _, test := range tests {
		t.Run(test.input, func(t *testing.T) {
			actual := ReverseString(test.input)
			if actual != test.expected {
				t.Errorf("For input %q, expected %q, got %q", test.input, test.expected, actual)
			}
		})
	}
}

func BenchmarkAdd(b *testing.B) {
	for i := 0; i < b.N; i++ {
		Add(i, i+1)
	}
}

func BenchmarkReverseString(b *testing.B) {
	testString := "benchmark string for testing performance"
	for i := 0; i < b.N; i++ {
		ReverseString(testString)
	}
}
```
*/

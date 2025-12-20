// Step2_DataStructuresAndInterfaces.go
// Golang 데이터 구조 및 인터페이스 학습을 위한 코드 예시입니다.
// 이 파일은 Go의 핵심 데이터 구조인 배열, 슬라이스, 맵, 구조체와
// Go만의 강력한 특징인 인터페이스, 그리고 에러 핸들링 기법을 이해하는 데 중점을 둡니다.
//
// Go는 명확하고 효율적인 데이터 관리를 위해 강력한 내장 데이터 타입을 제공하며,
// 인터페이스를 통해 유연하고 확장 가능한 설계를 가능하게 합니다.

package main

import (
	"errors" // 에러 타입 생성
	"fmt"    // 포맷된 입출력 함수
)

// -----------------------------------------------------------------------------
// 학습 포인트 1: 배열(Arrays) 및 슬라이스(Slices)
// - 배열: 고정된 크기를 가지는 요소들의 시퀀스. Go에서는 거의 사용되지 않습니다.
// - 슬라이스: 가변적인 크기를 가지는 요소들의 시퀀스. 배열 위에 구축된 동적 배열의 개념.
// -----------------------------------------------------------------------------
func arraysAndSlices() {
	fmt.Println("1.1. 배열 (Arrays)")
	// 배열 선언: `[크기]타입`
	var a [3]int // int 타입의 3개 요소를 가지는 배열, 초기값은 0
	a[0] = 10
	a[1] = 20
	a[2] = 30
	fmt.Printf("배열 a: %v, 길이: %d\n", a, len(a)) // %v는 값, %d는 정수 출력

	// 배열 초기화와 동시에 선언
	b := [3]int{1, 2, 3}
	fmt.Printf("배열 b: %v\n", b)

	// 나쁜 예시: 배열의 크기가 고정되어 있어 런타임에 유연하게 대응하기 어렵습니다.
	// 함수 파라미터로 배열을 전달하면 값이 복사되어 오버헤드가 발생할 수 있습니다.
	// Go에서는 대부분 슬라이스를 사용합니다.

	fmt.Println("1.2. 슬라이스 (Slices)")
	// 슬라이스 선언: `[]타입` (크기 지정 없음)
	var s []int // nil 슬라이스 (길이, 용량 0)
	fmt.Printf("초기 슬라이스 s: %v, 길이: %d, 용량: %d\n", s, len(s), cap(s))

	// `make` 함수를 이용한 슬라이스 생성: `make([]타입, 길이, 용량)`
	// `길이`: 슬라이스가 포함할 요소의 수.
	// `용량`: 슬라이스에 할당된 기본 배열의 최대 크기.
	s2 := make([]int, 5, 10) // 길이 5, 용량 10인 슬라이스
	fmt.Printf("make로 생성된 슬라이스 s2: %v, 길이: %d, 용량: %d\n", s2, len(s2), cap(s2))

	// 슬라이스 리터럴 (초기화)
	s3 := []int{10, 20, 30}
	fmt.Printf("슬라이스 리터럴 s3: %v, 길이: %d, 용량: %d\n", s3, len(s3), cap(s3))

	// 슬라이스 추가: `append` 함수
	s3 = append(s3, 40, 50) // 용량을 초과하면 새로운 기본 배열을 할당하고 복사합니다.
	fmt.Printf("append 후 s3: %v, 길이: %d, 용량: %d\n", s3, len(s3), cap(s3))

	// 슬라이스 자르기 (Slicing): `[low:high]` 또는 `[low:high:max]`
	// `low`: 포함되는 시작 인덱스 (기본값 0)
	// `high`: 포함되지 않는 끝 인덱스 (기본값 len(slice))
	// `max`: 용량을 제한하는 인덱스 (기본값 cap(slice))
	sliced := s3[1:4] // s3의 인덱스 1부터 3까지 (20, 30, 40)
	fmt.Printf("자른 슬라이스 sliced: %v, 길이: %d, 용량: %d\n", sliced, len(sliced), cap(sliced))
	// `sliced`는 `s3`와 동일한 기본 배열을 공유합니다.

	// 슬라이스 복사: `copy` 함수 (내용만 복사, 새로운 기본 배열)
	source := []int{1, 2, 3}
	destination := make([]int, 2) // 복사될 길이만큼만 생성
	n := copy(destination, source)
	fmt.Printf("copy 후 destination: %v, 복사된 요소 수: %d\n", destination, n) // [1 2], 2
	fmt.Println("")
}

// -----------------------------------------------------------------------------
// 학습 포인트 2: 맵(Maps)
// - 키-값 쌍을 저장하는 컬렉션. 다른 언어의 해시 테이블(Hash Table) 또는 딕셔너리(Dictionary)와 유사.
// - 순서가 보장되지 않습니다.
// -----------------------------------------------------------------------------
func maps() {
	fmt.Println("2. 맵 (Maps)")
	// 맵 선언 및 초기화
	var m map[string]int // nil 맵. 사용하려면 `make`로 초기화해야 합니다.
	fmt.Printf("초기 맵 m: %v\n", m)
	// m["key"] = 1 // 런타임 패닉 발생: nil 맵에 추가 시도

	// `make` 함수를 이용한 맵 생성
	codes := make(map[string]int) // string 키, int 값

codes["USA"] = 1
codes["KOR"] = 82
codes["JPN"] = 81
	fmt.Printf("codes 맵: %v\n", codes)

	// 맵 리터럴로 초기화
	capitals := map[string]string{
		"South Korea": "Seoul",
		"Japan":       "Tokyo",
		"USA":         "Washington D.C.",
	}
	fmt.Printf("capitals 맵: %v\n", capitals)

	// 맵에서 값 가져오기
	fmt.Printf("한국의 수도: %s\n", capitals["South Korea"])

	// 맵에서 키의 존재 여부 확인 (두 번째 반환 값 `ok`)
	koreaCapital, ok := capitals["South Korea"]
	if ok {
		fmt.Printf("South Korea의 수도는 %s 입니다.\n", koreaCapital)
	} else {
		fmt.Println("South Korea의 수도를 찾을 수 없습니다.")
	}

	franceCapital, ok := capitals["France"]
	if !ok {
		fmt.Printf("France의 수도는 %s 입니다 (nil).\n", franceCapital)
		fmt.Println("France의 수도를 찾을 수 없습니다.")
	}

	// 맵에서 요소 삭제: `delete` 함수
	delete(capitals, "Japan")
	fmt.Printf("Japan 삭제 후 capitals: %v\n", capitals)

	// 맵 순회 (for-range)
	fmt.Println("맵 순회:")
	for country, capital := range capitals {
		fmt.Printf("  %s: %s\n", country, capital)
	}
	fmt.Println("")
}

// -----------------------------------------------------------------------------
// 학습 포인트 3: 구조체(Structs)
// - 필드의 컬렉션. 다른 언어의 클래스나 객체와 유사하지만, 메서드를 가지는 방식이 다릅니다.
// - Go는 상속을 지원하지 않지만, 임베딩을 통해 유사한 효과를 낼 수 있습니다.
// -----------------------------------------------------------------------------
func structs() {
	fmt.Println("3.1. 구조체 (Structs)")
	// 구조체 선언
	type Person struct {
		Name string
		Age  int
		City string
	}

	// 구조체 인스턴스 생성
	p1 := Person{"Alice", 30, "Seoul"} // 필드 순서대로 초기화
	fmt.Printf("p1: %v\n", p1)

	p2 := Person{Name: "Bob", Age: 25} // 필드 이름을 지정하여 초기화 (순서 무관, 생략 가능)
	fmt.Printf("p2: %v\n", p2)

	// 필드 접근 및 수정
	p1.Age = 31
	fmt.Printf("p1 나이 변경: %v\n", p1)

	// 구조체 포인터
	p3 := &Person{Name: "Charlie", Age: 35, City: "Busan"}
	fmt.Printf("p3 (포인터): %v, 이름: %s\n", p3, p3.Name) // p3.Name은 (*p3).Name과 동일

	fmt.Println("3.2. 메서드 (Methods) 및 리시버 (Receivers)")
	// 메서드는 특정 타입에 바인딩된 함수입니다.
	// 리시버(Receiver)를 통해 어떤 타입의 메서드인지를 정의합니다.
	// - 값 리시버 (Value Receiver): 메서드 호출 시 수신자 값의 복사본을 받습니다. 원본 값 변경 불가.
	// - 포인터 리시버 (Pointer Receiver): 메서드 호출 시 수신자 값의 주소를 받습니다. 원본 값 변경 가능.
	p1.Greet()       // 값 리시버 호출
	p1.HaveBirthday() // 값 리시버를 사용했지만 구조체 값 자체가 복사되어 원본 p1.Age는 변경되지 않음.
	fmt.Printf("생일 후 p1 나이: %d\n", p1.Age)

	p3.Greet()
	p3.HaveBirthdayPointer() // 포인터 리시버를 사용하여 원본 p3.Age 변경
	fmt.Printf("생일 후 p3 나이: %d\n", p3.Age)

	fmt.Println("3.3. 구조체 임베딩 (Struct Embedding)")
	// Go는 상속 대신 임베딩을 통해 코드 재사용을 달성합니다.
	// 다른 구조체를 필드로 포함함으로써 해당 구조체의 필드와 메서드를 '승격'시킵니다.
	emp := Employee{
		Person: Person{Name: "David", Age: 40, City: "Jeju"},
		ID:     "EMP001",
		Role:   "Developer",
	}
	fmt.Printf("직원 정보: %v\n", emp)
	emp.Greet() // 임베딩된 Person 구조체의 메서드를 직접 호출 가능
	emp.Work()  // Employee 자체의 메서드
	fmt.Println("")
}

// Person 구조체에 바인딩된 메서드 (값 리시버)
func (p Person) Greet() {
	fmt.Printf("%s가 인사합니다: 안녕하세요!\n", p.Name)
}

// Person 구조체에 바인딩된 메서드 (값 리시버)
func (p Person) HaveBirthday() {
	p.Age++ // 복사된 값의 Age만 증가하므로 원본은 변경되지 않음
	fmt.Printf("값 리시버: %s의 나이가 %d가 되었습니다.\n", p.Name, p.Age)
}

// Person 구조체에 바인딩된 메서드 (포인터 리시버)
func (p *Person) HaveBirthdayPointer() {
	p.Age++ // 원본 구조체의 Age가 증가
	fmt.Printf("포인터 리시버: %s의 나이가 %d가 되었습니다.\n", p.Name, p.Age)
}

type Employee struct {
	Person // Person 구조체 임베딩
	ID     string
	Role   string
}

func (e Employee) Work() {
	fmt.Printf("%s (ID: %s)가 %s 역할을 수행합니다.\n", e.Name, e.ID, e.Role)
}

// -----------------------------------------------------------------------------
// 학습 포인트 4: 인터페이스(Interfaces)
// - Go의 인터페이스는 특정 메서드 시그니처(이름, 파라미터, 반환 값)의 집합을 정의합니다.
// - 암시적으로 구현됩니다: 어떤 타입이 인터페이스의 모든 메서드를 구현하면, 
//   해당 타입은 그 인터페이스를 구현한 것으로 간주됩니다. (implements 키워드 없음)
// - 다형성(Polymorphism)을 구현하는 핵심 메커니즘입니다.
// -----------------------------------------------------------------------------
func interfaces() {
	fmt.Println("4. 인터페이스 (Interfaces)")
	// 인터페이스 선언
	type Speaker interface {
		Speak() string
	}

	type Runner interface {
		Run() string
	}

	animal := Animal{ Name: "동물" } // Animal 타입의 인스턴스 생성

	func (a Animal) Speak() string {
		return fmt.Sprintf("%s가 소리냅니다.", a.Name)
	}

	func (a Animal) Run() string {
		return fmt.Sprintf("%s가 달립니다.", a.Name)
	}

	// Dog 타입은 Animal을 임베딩하여 Speak()와 Run() 메서드를 가집니다.
	type Dog struct {
		Animal
	}

	// Cat 타입은 Animal을 임베딩하여 Speak()와 Run() 메서드를 가집니다.
	type Cat struct {
		Animal
	}

	// Duck 타입은 Animal을 임베딩했지만, Fly()라는 추가 메서드를 가집니다.
	type Duck struct {
		Animal
	}

	func (d Duck) Fly() string {
		return fmt.Sprintf("%s가 날아갑니다.", d.Name)
	}

	// 인터페이스 사용
	var s1 Speaker = Dog{Animal: animal}
	var s2 Speaker = Cat{Animal: animal}

	fmt.Println(s1.Speak())
	fmt.Println(s2.Speak())

	var r1 Runner = Dog{Animal: animal}
	fmt.Println(r1.Run())

	// Duck은 Speaker 인터페이스도, Runner 인터페이스도 구현합니다.
	// `Duck`은 `Animal`을 임베딩했기 때문에 `Speak()`와 `Run()` 메서드를 가집니다.
	// 따라서 `Duck`은 `Speaker`와 `Runner` 인터페이스를 모두 구현하는 타입입니다.
	duck := Duck{Animal: animal}
	var s3 Speaker = duck
	var r2 Runner = duck
	fmt.Println(s3.Speak())
	fmt.Println(r2.Run())
	fmt.Println(duck.Fly()) // Fly()는 Duck 타입 자체의 메서드

	// 타입 어설션 (Type Assertion)
	// 인터페이스 값이 특정 기본 타입 또는 인터페이스 타입을 가지는지 확인
	if d, ok := s3.(Duck); ok {
		fmt.Printf("s3는 Duck 타입이며, %s가 날아갑니다.\n", d.Fly())
	}

	// 나쁜 예시: 인터페이스를 너무 광범위하게 정의하거나, 필요 없이 많은 메서드를 포함시키는 것.
	// - Go 인터페이스는 작고(Small) 응집도(Cohesive)가 높게 정의하는 것이 좋습니다.
	// - 특정 행동 하나를 정의하는 인터페이스(예: io.Reader, Stringer)가 이상적입니다.
	fmt.Println("")
}

// -----------------------------------------------------------------------------
// 학습 포인트 5: 에러 핸들링 (Error Handling)
// - Go는 `try-catch` 대신 `(result, error)` 다중 반환 값을 사용하여 에러를 명시적으로 처리합니다.
// - `error`는 인터페이스이며, `errors.New` 또는 `fmt.Errorf`를 사용하여 에러를 생성합니다.
// - `errors.Is`, `errors.As`를 사용하여 특정 에러 타입 확인.
// -----------------------------------------------------------------------------
func errorHandling() {
	fmt.Println("5. 에러 핸들링 (Error Handling)")

	// 5.1. `(result, error)` 패턴
	result, err := divide(10, 2)
	if err != nil {
		fmt.Printf("오류 발생: %v\n", err)
	} else {
		fmt.Printf("10 / 2 = %f\n", result)
	}

	result, err = divide(10, 0)
	if err != nil {
		fmt.Printf("오류 발생: %v\n", err)
		// errors.Is를 사용하여 특정 에러 타입인지 확인
		if errors.Is(err, ErrDivideByZero) {
			fmt.Println("  -> 0으로 나누기 오류입니다.")
		}
	} else {
		fmt.Printf("10 / 0 = %f\n", result)
	}

	// 5.2. 사용자 정의 에러
	// `errors.New` 또는 `fmt.Errorf`를 사용하여 에러 객체를 생성합니다.
	// `error` 인터페이스를 구현하는 모든 타입은 에러로 사용될 수 있습니다.
	customErr := &MyCustomError{Code: 500, Message: "내부 서버 오류"}
	fmt.Printf("사용자 정의 에러: %v\n", customErr)

	processPayment(100)
	processPayment(-50)
	fmt.Println("")

	// 나쁜 예시: 에러를 무시하거나, 단순히 로그만 남기고 프로그램을 계속 실행하는 것.
	// - `_` (블랭크 식별자)를 사용하여 에러 반환 값을 무시하는 것은 매우 위험합니다.
	// - 에러는 항상 명시적으로 확인하고 적절히 처리해야 합니다.
	// badResult, _ := divide(10, 0) // 에러를 무시하는 나쁜 예시
	// fmt.Printf("나쁜 예시: 0으로 나눈 결과: %f\n", badResult)

	// 나쁜 예시: 모든 에러를 `panic-recover`로 처리하려는 것.
	// - `panic`은 복구 불가능한 프로그램 상태 (예: 인덱스 범위를 벗어난 접근)에 사용해야 합니다.
	// - 일반적인 에러는 `error`를 반환하여 처리하는 것이 Go의 컨벤션입니다.
}

// 사용자 정의 에러 타입
type MyCustomError struct {
	Code    int
	Message string
}

// `error` 인터페이스를 구현하기 위한 `Error()` 메서드
func (e *MyCustomError) Error() string {
	return fmt.Sprintf("Error Code: %d, Message: %s", e.Code, e.Message)
}

var ErrDivideByZero = errors.New("0으로 나눌 수 없습니다")

func divide(a, b float64) (float64, error) {
	if b == 0 {
		return 0, ErrDivideByZero // 미리 정의된 에러 반환
	}
	return a / b, nil
}

var ErrInvalidAmount = errors.New("유효하지 않은 금액입니다")

func processPayment(amount float64) error {
	if amount <= 0 {
		// fmt.Errorf를 사용하여 에러에 추가 정보를 포함할 수 있습니다.
		return fmt.Errorf("%w: 금액은 양수여야 합니다. 현재 금액: %f", ErrInvalidAmount, amount)
	}
	fmt.Printf("결제 처리: %f\n", amount)
	return nil
}

// -----------------------------------------------------------------------------
// 학습 팁:
// - Go Playground (play.golang.org)에서 코드를 직접 실행하고 테스트해보세요.
// - `go doc <패키지명> <함수명>` 명령어로 표준 라이브러리 문서 확인.
// - `godoc -http=:6060` 명령어로 로컬에서 Go 문서 서버 실행.
// -----------------------------------------------------------------------------

func main() {
	arraysAndSlices()
	maps()
	structs()
	interfaces()
	errorHandling()

	fmt.Println("--- 2단계 학습 완료 ---")
}

/*
이 코드를 실행하려면:

1. Go SDK 설치 (golang.org에서 다운로드 및 설치).
2. 터미널 또는 명령 프롬프트에서 이 파일이 있는 디렉토리로 이동.
3. `go run Step2_DataStructuresAndInterfaces.go` 명령을 실행.

*/

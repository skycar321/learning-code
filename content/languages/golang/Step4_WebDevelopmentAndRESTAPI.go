// Step4_WebDevelopmentAndRESTAPI.go
// Golang 웹 개발 및 REST API 학습을 위한 코드 예시입니다.
// 이 파일은 Go의 `net/http` 패키지를 사용하여 간단한 HTTP 서버를 구축하고,
// RESTful API를 설계 및 구현하며, JSON 데이터를 처리하는 방법을 보여줍니다.
// 또한 미들웨어와 데이터베이스 연동(개념적)에 대해서도 다룹니다.
//
// Go는 고성능 웹 서비스 및 API를 구축하는 데 매우 강력하며,
// 특히 `net/http` 패키지 하나만으로도 충분한 기능을 제공합니다.

package main

import (
	"database/sql" // 데이터베이스 연동 (개념적)
	"encoding/json" // JSON 처리
	"fmt"
	"log"      // 로깅
	"net/http" // HTTP 서버
	"time"     // 시간 관련
)

// -----------------------------------------------------------------------------
// 학습 포인트 1: HTTP 서버 구축 (net/http 패키지)
// - `http.HandleFunc`: 특정 URL 경로에 대한 핸들러 함수를 등록합니다.
// - `http.ListenAndServe`: 지정된 주소와 포트에서 HTTP 요청을 수신 대기합니다.
// -----------------------------------------------------------------------------

// 1.1. 간단한 핸들러 함수
func homeHandler(w http.ResponseWriter, r *http.Request) {
	// `http.ResponseWriter`는 HTTP 응답을 작성하는 데 사용됩니다.
	// `*http.Request`는 클라이언트의 HTTP 요청에 대한 정보를 제공합니다.
	fmt.Fprintf(w, "Hello, Go Web! 요청 경로: %s", r.URL.Path)
}

// -----------------------------------------------------------------------------
// 학습 포인트 2: 라우팅 (Routing)
// - `net/http` 기본 라우터: `http.HandleFunc`은 패턴 매칭을 통해 라우팅합니다.
//   - `/` 경로는 모든 요청을 처리하는 catch-all 핸들러가 될 수 있습니다.
//   - `/users`와 `/users/{id}` 같은 복잡한 라우팅에는 외부 라이브러리(Gin, Echo, Gorilla Mux)가 유용.
// - 여기서는 `net/http`의 기본 패턴 매칭과 수동 파싱을 보여줍니다.
// -----------------------------------------------------------------------------

// URL 경로에서 동적 파라미터 추출 (net/http에서는 수동으로 파싱)
func userHandler(w http.ResponseWriter, r *http.Request) {
	// 나쁜 예시: `net/http`만 사용하여 복잡한 패턴 매칭을 구현하는 것.
	// - 정규식을 직접 사용하거나 `strings.TrimPrefix` 등으로 수동 파싱해야 하므로 코드가 복잡해집니다.
	// - 외부 라우팅 라이브러리를 사용하면 이 과정을 단순화할 수 있습니다.

	userID := r.URL.Path[len("/users/"):] // /users/ 다음에 오는 부분을 추출
	if userID == "" {
		fmt.Fprintf(w, "모든 사용자 목록을 보여줍니다.")
		return
	}
	fmt.Fprintf(w, "사용자 %s의 정보를 보여줍니다.", userID)
}

// -----------------------------------------------------------------------------
// 학습 포인트 3: JSON 처리 (encoding/json)
// - Go의 구조체(struct)와 JSON 간의 마샬링(encoding) 및 언마샬링(decoding).
// - 구조체 필드에 `json:"key_name"` 태그를 사용하여 JSON 필드 이름을 지정할 수 있습니다.
// -----------------------------------------------------------------------------

// 요청 및 응답에 사용할 구조체 정의
type Product struct {
	ID    string  `json:"id"`     // JSON 필드명: "id"
	Name  string  `json:"name"`   // JSON 필드명: "name"
	Price float64 `json:"price"`  // JSON 필드명: "price"`
}

var products = []Product{
	{"p001", "Laptop", 1200.00},
	{"p002", "Mouse", 25.00},
}

func getProducts(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json") // 응답 헤더 설정
	json.NewEncoder(w).Encode(products)                // 구조체를 JSON으로 인코딩하여 응답
}

func createProduct(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	var newProduct Product
	// 요청 바디의 JSON을 구조체로 디코딩 (언마샬링)
	err := json.NewDecoder(r.Body).Decode(&newProduct)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	newProduct.ID = fmt.Sprintf("p%03d", len(products)+1) // 간단한 ID 생성
	products = append(products, newProduct)
	w.WriteHeader(http.StatusCreated) // HTTP 201 Created
	json.NewEncoder(w).Encode(newProduct)
}

// -----------------------------------------------------------------------------
// 학습 포인트 4: 미들웨어(Middleware) 구현
// - 요청이 핸들러에 도달하기 전/후에 공통 로직(로깅, 인증, 권한, 압축 등)을 처리합니다.
// - Go에서는 함수를 반환하는 함수 형태로 미들웨어를 구현합니다.
// -----------------------------------------------------------------------------

// 로깅 미들웨어
func loggingMiddleware(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		next(w, r) // 다음 핸들러 또는 미들웨어 호출
		log.Printf("요청: %s %s, 처리 시간: %s", r.Method, r.URL.Path, time.Since(start))
	}
}

// 인증 미들웨어 (간단한 예시)
func authMiddleware(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		token := r.Header.Get("Authorization")
		if token != "Bearer my-secret-token" {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}
		next(w, r)
	}
}

// -----------------------------------------------------------------------------
// 학습 포인트 5: 데이터베이스 연동 (Database Integration) (개념적)
// - `database/sql` 패키지: Go의 표준 SQL 인터페이스. 특정 드라이버(MySQL, PostgreSQL 등)와 함께 사용.
// - ORM/SQL Builder: `GORM`, `sqlx`, `squirrel` 등 외부 라이브러리 사용.
// -----------------------------------------------------------------------------
func setupDatabase() (*sql.DB, error) {
	// 나쁜 예시: DB 연결 정보를 하드코딩하거나, 에러 처리를 소홀히 하는 것.
	// - DB 연결 정보는 환경 변수나 설정 파일에서 로드해야 합니다.
	// - DB 연결 실패 시 적절한 오류 처리 및 재시도 로직이 필요합니다.

	// 실제 DB 연결 시 주석 해제 (예: SQLite)
	// db, err := sql.Open("sqlite3", "./test.db")
	// if err != nil {
	// 	return nil, fmt.Errorf("DB 연결 실패: %w", err)
	// }
	// if err = db.Ping(); err != nil {
	// 	return nil, fmt.Errorf("DB 핑 테스트 실패: %w", err)
	// }
	// fmt.Println("데이터베이스 연결 성공 (개념적).")
	// return db, nil
	return nil, nil // 학습 목적으로 nil 반환
}

func main() {
	fmt.Println("--- 4단계: 웹 개발 및 REST API ---")

	// 데이터베이스 설정 (개념적)
	// db, err := setupDatabase()
	// if err != nil {
	// 	log.Fatalf("데이터베이스 초기화 실패: %v", err)
	// }
	// defer func() {
	// 	if db != nil {
	// 		db.Close()
	// 	}
	// }()

	// 1. HTTP 핸들러 등록
	http.HandleFunc("/", loggingMiddleware(homeHandler))
	http.HandleFunc("/users/", loggingMiddleware(userHandler)) // `/users/`로 끝나면 모든 하위 경로 처리
	http.HandleFunc("/products", loggingMiddleware(http.HandlerFunc(getProducts)).ServeHTTP)
	http.HandleFunc("/products/new", authMiddleware(loggingMiddleware(http.HandlerFunc(createProduct)).ServeHTTP))

	fmt.Println("웹 서버가 8080 포트에서 시작됩니다. http://localhost:8080")
	fmt.Println("Ctrl+C를 눌러 서버를 종료하세요.")

	// 나쁜 예시: `http.ListenAndServe`에서 반환되는 에러를 무시하는 것.
	// - 서버가 실패하면 알 수 없으므로 항상 에러를 처리해야 합니다.
	// `log.Fatal`은 에러 발생 시 프로그램을 종료하고 에러 메시지를 출력합니다.
	log.Fatal(http.ListenAndServe(":8080", nil))

	// Go의 HTTP 서버는 기본적으로 단일 메인 고루틴에서 실행되지만, 각 요청은 별도의 고루틴에서 처리됩니다.
	// 따라서 고루틴과 채널을 활용한 동시성 프로그래밍이 웹 서버 개발에 자연스럽게 통합됩니다.

	fmt.Println("--- 4단계 학습 완료 ---") // 이 메시지는 서버가 종료된 후에만 출력됩니다.
}

/*
이 코드를 실행하려면:

1. Go SDK 설치 (golang.org에서 다운로드 및 설치).
2. 터미널 또는 명령 프롬프트에서 이 파일이 있는 디렉토리로 이동.
3. `go run Step4_WebDevelopmentAndRESTAPI.go` 명령을 실행.
4. 웹 브라우저 또는 `curl` 명령어를 사용하여 다음 엔드포인트에 접근합니다.

테스트 엔드포인트:
- GET http://localhost:8080/
- GET http://localhost:8080/users
- GET http://localhost:8080/users/123
- GET http://localhost:8080/products

- POST http://localhost:8080/products/new
  Headers:
    Authorization: Bearer my-secret-token
    Content-Type: application/json
  Body:
    {
      "name": "New Keyboard",
      "price": 75.50
    }
  (토큰이 없거나 잘못되면 401 Unauthorized, 올바르면 201 Created 응답)

서버를 종료하려면 터미널에서 `Ctrl+C`를 누르세요.
*/

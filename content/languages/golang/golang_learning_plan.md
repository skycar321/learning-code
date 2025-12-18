# Golang 학습 계획

## 개요 (Overview)
Go(Golang)는 Google에서 개발한 오픈소스 프로그래밍 언어로, 효율적인 컴파일, 동시성, 가비지 컬렉션 기능을 특징으로 합니다. 현대적인 시스템 프로그래밍, 백엔드 서비스, 마이크로서비스 및 분산 시스템 개발에 특히 강점을 보이며, Docker, Kubernetes 등 다양한 핵심 인프라 프로젝트에서 사용되고 있습니다. 이 학습 계획은 Golang의 기본 문법부터 동시성 프로그래밍, 웹 개발, 그리고 실무에 필요한 고급 패턴까지 다루는 것을 목표로 합니다.

## 학습 목표 (Learning Objectives)
*   Golang의 기본 문법 및 특징 이해
*   Goroutine 및 Channel을 이용한 동시성 프로그래밍 마스터
*   Golang을 이용한 웹 애플리케이션 및 REST API 개발
*   테스트, 에러 핸들링 및 패키지 관리 능력 향상
*   실용적인 Golang 프로젝트 구조 및 배포 전략 이해

## 학습 내용 (Learning Content)

### 1단계: Golang 기본 문법 및 도구 (Golang Basics & Tools)
*   Golang 소개 (Introduction to Golang) - 역사, 철학, 특징
*   환경 설정 (Environment Setup) - Go 설치, GOPATH, Workspace
*   기본 문법 (Basic Syntax) - 변수, 상수, 데이터 타입, 연산자
*   흐름 제어 (Control Flow) - `if`, `for`, `switch`
*   함수 (Functions) - 다중 반환 값, defer
*   패키지(Packages) 및 모듈(Modules) 이해 (Understanding Packages & Modules)
*   Go CLI 도구 활용 (Using Go CLI Tools) - `go run`, `go build`, `go mod`

### 빠른 실행 안내 (Step 1~3)
```bash
go run Step1_GolangBasicsAndTools.go
go run Step2_DataStructuresAndInterfaces.go
go run Step3_ConcurrencyProgramming.go
```
> bad 예시는 주석으로 남겨 두었습니다. 주석을 해제하고 실행해 보며 컴파일러/런타임의 경고를 직접 확인하세요.

### 2단계: 데이터 구조 및 인터페이스 (Data Structures & Interfaces)
*   배열(Arrays) 및 슬라이스(Slices) (Arrays & Slices)
*   맵(Maps) (Maps)
*   구조체(Structs) (Structs) - 메서드, 포인터 리시버
*   인터페이스(Interfaces) (Interfaces) - 다형성, 임베딩
*   에러 핸들링 (Error Handling) - `error` 인터페이스, 사용자 정의 에러

### 3단계: 동시성 프로그래밍 (Concurrency Programming)
*   동시성(Concurrency) vs 병렬성(Parallelism) (Concurrency vs Parallelism)
*   고루틴(Goroutines) (Goroutines) - 경량 스레드
*   채널(Channels) (Channels) - 고루틴 간 통신
*   `select` 문 (The `select` Statement) - 다중 채널 처리
*   `sync` 패키지 (The `sync` Package) - Mutex, WaitGroup
*   데드락(Deadlock) 및 라이블락(Livelock) 방지

### 4단계: 웹 개발 및 REST API (Web Development & REST API)
*   HTTP 서버 구축 (Building HTTP Servers) - `net/http` 패키지
*   라우팅 (Routing) - Mux, Gorilla Mux 등 외부 라이브러리
*   JSON 처리 (JSON Handling) - `encoding/json`
*   미들웨어(Middleware) 구현 (Implementing Middleware)
*   데이터베이스 연동 (Database Integration) - `database/sql`, ORM/SQL Builder
*   RESTful API 설계 및 구현 (Designing & Implementing RESTful API)

### 5단계: 테스트, 배포 및 고급 주제 (Testing, Deployment & Advanced Topics)
*   테스트 (Testing) - 유닛 테스트, 테이블 테스트 (`go test`)
*   벤치마킹 (Benchmarking) - `go test -bench`
*   리플렉션 (Reflection) - `reflect` 패키지
*   포인터 (Pointers) 심화
*   Docker를 이용한 배포 (Deployment with Docker)
*   마이크로서비스 아키텍처에서의 Golang (Golang in Microservices Architecture)
*   Go Best Practices 및 Clean Code

## 예상 학습 시간 (Estimated Learning Time)
*   각 단계별 4-8시간 (총 20-40시간)

## 실습 과제 (Practical Exercises)
*   간단한 커맨드라인 도구 개발 (Develop a simple command-line tool)
*   고루틴과 채널을 이용한 동시성 프로그램 작성 (Write a concurrent program using goroutines & channels)
*   Golang으로 RESTful API 서버 구축 (Build a RESTful API server with Golang)
*   유닛 테스트 및 벤치마킹 코드 작성 (Write unit tests & benchmarking code)
*   데이터베이스와 연동하여 CRUD 기능 구현 (Implement CRUD functionality with database integration)

## 참고 자료 (References)
*   The Go Programming Language (by Alan A. A. Donovan, Brian W. Kernighan)
*   Go by Example (gobyexample.com)
*   Effective Go (golang.org/doc/effective_go)
*   Golang 공식 문서 (Golang Official Documentation)
*   각종 Golang 웹 프레임워크 문서 (e.g., Gin, Echo)

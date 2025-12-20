# Node.js 학습 계획

## 개요 (Overview)
Node.js는 Chrome V8 JavaScript 엔진으로 빌드된 JavaScript 런타임으로, 서버 및 네트워크 애플리케이션 개발에 널리 사용됩니다. 비동기 이벤트 기반 아키텍처를 통해 높은 확장성과 성능을 제공하며, 단일 언어로 프론트엔드와 백엔드를 모두 개발할 수 있는 Full-stack JavaScript 개발 환경을 가능하게 합니다. 이 학습 계획은 Node.js의 기본 개념부터 비동기 처리, 웹 서버 구축, 데이터베이스 연동, 그리고 실무에 필요한 고급 기능까지 다루는 것을 목표로 합니다.

## 학습 목표 (Learning Objectives)
*   Node.js의 핵심 개념 및 동작 원리 이해
*   JavaScript를 사용하여 서버 사이드 애플리케이션 개발
*   비동기 프로그래밍 및 이벤트 기반 아키텍처 활용
*   Express.js와 같은 프레임워크를 이용한 REST API 구축
*   데이터베이스 연동 및 배포 전략 수립

## 학습 내용 (Learning Content)

### 1단계: Node.js 기본 개념 및 시작 (Node.js Basics & Getting Started)
*   Node.js 소개 (Introduction to Node.js) - 역사, 특징, 사용 사례
*   Node.js 설치 및 환경 설정 (Installation & Setup)
*   모듈 시스템 (Module System) - CommonJS (`require`, `module.exports`), ES Modules (`import`, `export`)
*   패키지 관리자 (Package Manager) - npm, yarn
    *   `package.json` 이해 및 의존성 관리
*   이벤트 루프 (Event Loop) 및 비동기 모델 (Asynchronous Model)

### 2단계: 핵심 모듈 및 비동기 프로그래밍 (Core Modules & Asynchronous Programming)
*   파일 시스템 (File System) - `fs` 모듈 (동기/비동기 API)
*   경로(Path) 처리 - `path` 모듈
*   이벤트(Events) - `events` 모듈, `EventEmitter`
*   스트림(Streams) - Readable, Writable, Duplex, Transform Streams
*   Promise 및 Async/Await (Promise & Async/Await) - 비동기 코드 패턴
*   Error Handling (오류 처리) - try-catch, uncaughtException, unhandledRejection

### 3단계: 웹 서버 구축 및 REST API (Building Web Servers & REST API)
*   HTTP 모듈 (HTTP Module) - 내장 HTTP 서버 생성
*   Express.js 프레임워크 (Express.js Framework) - 설치 및 기본 설정
    *   라우팅 (Routing), 미들웨어 (Middleware)
    *   요청(Request) 및 응답(Response) 객체
*   RESTful API 설계 원칙 (RESTful API Design Principles)
*   데이터베이스 연동 (Database Integration) - MongoDB (Mongoose), PostgreSQL (Sequelize)
*   인증 및 인가 (Authentication & Authorization) - JWT, Passport.js

### 4단계: 고급 기능 및 모범 사례 (Advanced Features & Best Practices)
*   클러스터링 (Clustering) - `cluster` 모듈을 이용한 다중 코어 활용
*   프로세스 관리 (Process Management) - PM2
*   환경 변수 (Environment Variables) - `dotenv`
*   로깅 (Logging) - Winston, Pino
*   테스트 (Testing) - Jest, Mocha, Chai
*   보안 (Security) - Helmet, CORS, CSRF 보호
*   TypeScript와 Node.js (Node.js with TypeScript)

### 5단계: 배포 및 마이크로서비스 (Deployment & Microservices)
*   Docker를 이용한 컨테이너화 (Containerization with Docker)
*   클라우드 플랫폼 배포 (Deployment to Cloud Platforms) - AWS EC2/Lambda, Azure App Service, Google Cloud Run
*   CI/CD 파이프라인 (CI/CD Pipelines) - GitHub Actions, Jenkins
*   마이크로서비스 아키텍처 (Microservices Architecture)
    *   API Gateway, 메시지 큐 (Kafka, RabbitMQ)

## 예상 학습 시간 (Estimated Learning Time)
*   각 단계별 3-6시간 (총 15-30시간)

## 실습 과제 (Practical Exercises)
*   Express.js를 이용한 간단한 CRUD API 서버 구축 (Build a simple CRUD API server using Express.js)
*   데이터베이스(MongoDB 또는 PostgreSQL)와 연동하여 데이터 저장 및 조회 (Integrate with a database for data storage and retrieval)
*   JWT 기반의 사용자 인증 시스템 구현 (Implement a JWT-based user authentication system)
*   Node.js 애플리케이션을 Docker 이미지로 빌드하고 실행 (Build and run a Node.js application as a Docker image)
*   비동기 파일 읽기/쓰기 및 스트림 활용 (Practice asynchronous file I/O and streams)

## 참고 자료 (References)
*   Node.js 공식 문서 (Node.js Official Documentation)
*   Express.js 공식 문서 (Express.js Official Documentation)
*   Node.js Design Patterns by Mario Casciaro, Luciano Mammino
*   Node.js in Action by Alex R. Young, Bradley Meck, Mike Cantelon

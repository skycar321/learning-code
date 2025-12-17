# Step 10: NestJS 트러블슈팅 가이드 (Troubleshooting Guide)

NestJS 개발 중 자주 마주치는 오류 Top 50을 정리했습니다. 에러 메시지(`Nest can't resolve...` 등)로 검색(`Ctrl+F`)하여 해결책을 찾으세요.

## 1. Dependency Injection & Modules (의존성 주입)

### 1-1. `Nest can't resolve dependencies of the <Service>...`
- **원인**: 의존성 주입 실패. 해당 서비스가 `providers` 목록에 없거나, 다른 모듈에서 export 되지 않았음.
- **해결**:
  - 같은 모듈 내라면 `providers` 배열 확인.
  - 다른 모듈이라면 해당 모듈을 `imports`에 추가하고, 그 모듈에서 서비스를 `exports` 했는지 확인.

### 1-2. `Circular dependency detected`
- **원인**: A 서비스가 B를 주입받고, B 서비스가 A를 주입받음.
- **해결**: `forwardRef(() => Module)` 사용 또는 설계 변경(공통 로직 분리).

### 1-3. `UnknownDependenciesException`
- **원인**: 생성자 파라미터 타입이 인터페이스(Interface)인데 `@Inject()` 데코레이터가 없음. (인터페이스는 런타임에 사라짐).
- **해결**: 클래스 타입을 사용하거나 `@Inject('TOKEN')` 사용.

### 1-4. `Cannot find module ...` (Build/Runtime)
- **원인**: `dist` 폴더가 갱신되지 않았거나, 모노레포 설정 오류.
- **해결**: `rimraf dist` 후 재빌드. `nest-cli.json`의 `entryFile` 확인.

### 1-5. `No provider for <Token>`
- **원인**: 커스텀 Provider 토큰이 일치하지 않음.
- **해결**: `provide: 'TOKEN'`과 `@Inject('TOKEN')` 문자열 일치 확인.

### 1-6. ConfigService returning undefined
- **원인**: `ConfigModule.forRoot()`가 루트 모듈에 없거나, 환경변수 파일(.env) 로드 실패.
- **해결**: `isGlobal: true` 설정 또는 필요한 모듈에서 `ConfigModule` 임포트.

### 1-7. Repository Injection failed (`No repository for "..." was found`)
- **원인**: TypeORM/Mongoose 모듈 설정 누락.
- **해결**: `TypeOrmModule.forFeature([Entity])`가 현재 모듈에 있는지 확인.

### 1-8. `Scope.REQUEST` injection in Singleton
- **원인**: 싱글톤 서비스(기본)에 Request 스코프 서비스를 주입하면 전체가 Request 스코프가 됨(성능 저하).
- **해결**: 구조 변경 또는 의도한 것인지 확인.

### 1-9. Abstract Class Injection
- **원인**: 추상 클래스는 인스턴스화 불가.
- **해결**: `useClass` 또는 `useExisting`으로 구현체 지정.

### 1-10. Global Module overriding
- **원인**: `@Global()` 모듈과 지역 모듈에서 같은 토큰 제공 시 충돌/덮어쓰기.
- **해결**: 프로바이더 우선순위 이해 또는 토큰 분리.

---

## 2. Controller & Routing (라우팅)

### 2-1. `Cannot POST /path` (404 Not Found)
- **원인**: HTTP 메서드 불일치(`@Get` vs `@Post`) 또는 경로 오타.
- **해결**: 컨트롤러 데코레이터 확인. Global Prefix(`api/v1`) 확인.

### 2-2. `Ambiguous route definition`
- **원인**: `/users/:id`와 `/users/profile` 처럼 경로가 겹침.
- **해결**: 정적 경로(`profile`)를 동적 경로(`:id`)보다 위에 선언.

### 2-3. DTO Validation Failed (`BadRequestException`)
- **원인**: `class-validator` 데코레이터 조건 불만족.
- **해결**: 요청 Body 확인. `main.ts`에 `ValidationPipe` 설정 확인.

### 2-4. `Unexpected token ... in JSON`
- **원인**: Body Parser 설정 문제 또는 JSON 형식이 아님.
- **해결**: 클라이언트 `Content-Type: application/json` 헤더 확인.

### 2-5. Param/Query Parsing Issue
- **원인**: `@Param('id')`로 받은 값은 무조건 `string`임.
- **해결**: `ParseIntPipe` 사용 (`@Param('id', ParseIntPipe) id: number`).

### 2-6. CORS Error (`No 'Access-Control-Allow-Origin'`)
- **원인**: 브라우저 보안 정책.
- **해결**: `main.ts`에서 `app.enableCors()` 호출.

### 2-7. `Headers already sent`
- **원인**: 응답을 보낸 후(`res.send`) 다시 응답을 보내려 함 (미들웨어/인터셉터 충돌).
- **해결**: 로직 흐름 확인. `return` 처리.

### 2-8. File Upload `undefined`
- **원인**: `FileInterceptor` 누락 또는 필드명 불일치.
- **해결**: `@UseInterceptors(FileInterceptor('file'))` 사용.

### 2-9. `Route handler method "..." returns a Promise` (hanging)
- **원인**: `async` 함수인데 `await`나 `return`이 없어서 영원히 대기.
- **해결**: `return` 문 추가.

### 2-10. Controller not loading
- **원인**: Module의 `controllers` 배열에 등록 안 함.
- **해결**: 모듈 등록 확인.

---

## 3. Guards & Auth (보안)

### 3-1. `Forbidden resource` (403)
- **원인**: Guard가 `false`를 리턴함.
- **해결**: AuthGuard 로직 확인. 토큰 유효성 확인.

### 3-2. `Unauthorized` (401)
- **원인**: 인증 헤더 없음 또는 토큰 만료.
- **해결**: `Authorization: Bearer <token>` 헤더 확인.

### 3-3. Passport Strategy not found
- **원인**: `PassportModule` 등록 누락 또는 Strategy 이름 불일치.
- **해결**: `AuthModule` imports 확인. Strategy 클래스 내 `super('jwt')` 이름 확인.

### 3-4. Current User `undefined` in Request
- **원인**: Guard가 실행되지 않았거나 `request.user` 매핑 실패.
- **해결**: `validate()` 메서드 리턴값이 `request.user`에 들어감. 리턴값 확인.

### 3-5. Role Guard not working
- **원인**: 메타데이터(`@SetMetadata` 또는 `@Roles`)를 못 읽음.
- **해결**: `Reflector` 주입 및 `reflector.get()` 사용법 확인.

---

## 4. Microservices & Gateway

### 4-1. `Amqp connection failed`
- **원인**: RabbitMQ 서버 다운 또는 URL 오류.
- **해결**: 브로커 상태 및 접속 정보 확인.

### 4-2. `Redis connection refused`
- **원인**: Redis 포트/호스트 오류.
- **해결**: Redis 설정 확인.

### 4-3. `Pattern handler not found`
- **원인**: 마이크로서비스 `@MessagePattern` 불일치.
- **해결**: 클라이언트 `send('pattern', data)`와 서버 `@MessagePattern('pattern')` 일치 확인.

### 4-4. Gateway Timeout
- **원인**: 마이크로서비스 응답 지연.
- **해결**: 타임아웃 설정 증가 또는 서비스 최적화.

### 4-5. WebSocket Connection Failed
- **원인**: Gateway 포트 다름 또는 CORS.
- **해결**: `@WebSocketGateway({ cors: true })` 설정.

---

## 🔍 Good vs Bad Troubleshooting Habits

### ❌ Bad Practice
- **`any` 타입 남발**: TS의 장점을 버리고 런타임 에러를 유발함.
- **비즈니스 로직을 컨트롤러에 작성**: 테스트가 어렵고 재사용 불가. 서비스로 분리해야 함.
- **Global Pipe 무분별 사용**: 모든 요청에 무거운 파이프가 돌면 성능 저하.

### ✅ Good Practice
- **DTO 사용**: 데이터 형식을 명확히 정의하고 검증(`class-validator`)함.
- **Exception Filters**: 예외 처리를 중앙화하여 일관된 에러 응답 포맷 유지.
- **Logging**: `Logger` 서비스를 사용하여 디버깅 가능한 로그 남기기.

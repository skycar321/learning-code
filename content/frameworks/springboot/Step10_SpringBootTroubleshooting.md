# Step 10: Spring Boot 트러블슈팅 가이드 (Troubleshooting Guide)

Spring Boot 개발 및 운영 중 자주 마주치는 오류 Top 50을 정리했습니다. 예외 이름(Exception Name)으로 검색(`Ctrl+F`)하여 원인과 해결책을 빠르게 찾으세요.

## 1. Bean & Dependency Injection (빈 생성 및 의존성 주입)

### 1-1. `BeanCreationException`
- **원인**: 빈을 생성하는 도중 에러 발생 (설정 오류, 생성자 에러 등).
- **해결**: "Caused by" 이하의 로그를 확인. `@Autowired` 필드 누락이나 `@Value` 파싱 에러 점검.

### 1-2. `NoSuchBeanDefinitionException`
- **원인**: 주입하려는 빈이 컨테이너에 없음.
- **해결**:
  - 해당 클래스에 `@Component`, `@Service`, `@Repository` 등이 붙어있는지 확인.
  - `@ComponentScan` 범위(패키지) 확인.

### 1-3. `CircularDependencyException` (The dependencies of some of the beans form a cycle)
- **원인**: A가 B를 필요로 하고, B가 A를 필요로 함 (생성자 주입 시 주로 발생).
- **해결**:
  - `@Lazy` 주입 사용.
  - 설계를 변경하여 순환 참조 끊기 (공통 기능을 제3의 빈으로 분리).

### 1-4. `UnsatisfiedDependencyException`
- **원인**: 의존성 주입 실패. (타입이 안 맞거나, 빈이 2개 이상이거나, 없음).
- **해결**: 에러 메시지의 필드/생성자 파라미터 확인.

### 1-5. `NoUniqueBeanDefinitionException`
- **원인**: 주입하려는 타입의 빈이 2개 이상 존재.
- **해결**: `@Qualifier("beanName")` 사용 또는 `@Primary` 어노테이션 사용.

### 1-6. `@Value("${...")` injection failed
- **원인**: `application.properties/yml`에 해당 키가 없음.
- **해결**: 프로퍼티 키 확인 또는 기본값 설정 (`@Value("${key:default}")`).

### 1-7. `BeanCurrentlyInCreationException`
- **원인**: 생성자 주입 시 순환 참조 발생 시 주로 나타남.
- **해결**: 1-3과 동일. Setter 주입으로 변경 고려(권장하지 않음).

### 1-8. `DefinitionOverrideException`
- **원인**: 같은 이름의 빈이 중복 등록됨 (최신 버전은 기본적으로 오버라이딩 금지).
- **해결**: 빈 이름 변경 또는 `spring.main.allow-bean-definition-overriding=true` 설정.

### 1-9. `ApplicationContextException: Unable to start web server`
- **원인**: 내장 톰캣 시작 실패 (포트 충돌 등).
- **해결**: 포트 변경 또는 서블릿 컨테이너 설정 확인.

### 1-10. Proxy Bean Injection Issue
- **원인**: JDK Dynamic Proxy는 인터페이스 기반이라 구현 클래스에 주입 불가.
- **해결**: 인터페이스로 주입받거나 `proxyTargetClass=true` 설정 (CGLIB 사용).

---

## 2. JPA & Database (데이터 접근)

### 2-1. `LazyInitializationException`
- **원인**: 트랜잭션이 끝난 후(Session Close) 지연 로딩(`FetchType.LAZY`)된 엔티티에 접근.
- **해결**:
  - `@Transactional` 범위 내에서 접근.
  - `JOIN FETCH` 또는 `@EntityGraph`로 미리 로딩.
  - **Bad**: `enable_lazy_load_no_trans=true` (성능 이슈).

### 2-2. `EntityNotFoundException` / `JpaObjectRetrievalFailureException`
- **원인**: `getReference()` 등으로 프록시를 가져왔으나 실제 DB에 데이터 없음.
- **해결**: `findById()` 사용 후 `Optional.orElseThrow()` 처리.

### 2-3. `TransientPropertyValueException`
- **원인**: 영속화되지 않은(Transient) 객체를 영속 객체의 필드로 저장하려 함.
- **해결**: 연관된 객체를 먼저 `save()` 하거나 `CascadeType.PERSIST` 설정.

### 2-4. `NonUniqueResultException`
- **원인**: `getOne()`이나 `Optional` 반환 메서드인데 결과가 2건 이상임.
- **해결**: 쿼리 조건 수정 또는 리턴 타입을 `List`로 변경.

### 2-5. `DataIntegrityViolationException`
- **원인**: DB 제약조건 위반 (Unique Key, Not Null, FK 등).
- **해결**: 입력 데이터 검증.

### 2-6. `InvalidDataAccessApiUsageException`
- **원인**: JPQL 문법 오류나 파라미터 바인딩 오류.
- **해결**: 레포지토리 메서드 이름이나 `@Query` 문법 확인.

### 2-7. N+1 Problem (Performance)
- **원인**: 목록 조회(1) 후 각 객체의 연관 엔티티를 조회(N)하며 쿼리 폭증.
- **해결**: `JOIN FETCH`, `@EntityGraph`, `@BatchSize` 사용.

### 2-8. `TransactionRequiredException`
- **원인**: 트랜잭션 없이 `UPDATE`, `DELETE` 수행.
- **해결**: 메서드나 클래스에 `@Transactional` 추가.

### 2-9. `ObjectOptimisticLockingFailureException`
- **원인**: `@Version` 필드를 사용하는 낙관적 락 충돌 (동시 수정).
- **해결**: 재시도 로직 구현 또는 비즈니스 흐름 점검.

### 2-10. `CannotCreateTransactionException`
- **원인**: DB 커넥션 풀 고갈 또는 DB 서버 다운.
- **해결**: DB 상태 확인, HikariCP `maximum-pool-size` 조정.

---

## 3. Web & Network (웹 및 네트워크)

### 3-1. `PortInUseException` (Port 8080 was already in use)
- **원인**: 이미 다른 프로세스가 해당 포트 점유.
- **해결**:
  - `lsof -i :8080` 후 `kill -9`.
  - `server.port=0` (랜덤 포트) 또는 다른 포트 설정.

### 3-2. `404 Not Found` (Static Resources)
- **원인**: 정적 리소스 위치(`/static`, `/public`)가 아니거나 매핑 설정 오류.
- **해결**: 파일 위치 확인. `addResourceHandlers` 설정 확인.

### 3-3. `405 Method Not Allowed`
- **원인**: `GET` 요청인데 컨트롤러는 `POST`만 받음.
- **해결**: `@GetMapping`, `@PostMapping` 어노테이션 일치 확인.

### 3-4. `400 Bad Request` (MethodArgumentNotValidException)
- **원인**: `@Valid` 검증 실패.
- **해결**: `BindingResult`로 에러 처리하거나 `@ExceptionHandler`로 메시지 응답.

### 3-5. `415 Unsupported Media Type`
- **원인**: 요청 `Content-Type`이 `application/json`이 아닌데 `@RequestBody` 사용.
- **해결**: 클라이언트 헤더 확인.

### 3-6. `HttpMessageNotReadableException`
- **원인**: JSON 파싱 실패 (포맷 오류 또는 DTO 필드 타입 불일치).
- **해결**: 요청 JSON 형식 확인. Jackson 라이브러리 설정 확인.

### 3-7. `MissingServletRequestParameterException`
- **원인**: `@RequestParam(required=true)` 파라미터 누락.
- **해결**: 파라미터 전달 또는 `required=false` 설정.

### 3-8. CORS Error (`Access-Control-Allow-Origin`)
- **원인**: 브라우저의 동일 출처 정책 위반.
- **해결**: `@CrossOrigin` 또는 `WebMvcConfigurer`에서 CORS 설정.

### 3-9. `client_loop: send disconnect: Broken pipe` (DB Connection)
- **원인**: DB 커넥션이 타임아웃으로 끊김.
- **해결**: HikariCP `max-lifetime`을 DB `wait_timeout`보다 짧게 설정.

### 3-10. `MultipartException` (File Upload)
- **원인**: 파일 크기 제한 초과.
- **해결**: `spring.servlet.multipart.max-file-size` 설정 증가.

---

## 4. Security (보안)

### 4-1. `401 Unauthorized`
- **원인**: 인증 토큰 없음 또는 유효하지 않음.
- **해결**: 로그인 여부, 헤더(`Authorization: Bearer ...`) 확인.

### 4-2. `403 Forbidden` (CSRF)
- **원인**: POST 요청 시 CSRF 토큰 누락.
- **해결**: CSRF 비활성화(`http.csrf().disable()`) 또는 토큰 전달.

### 4-3. `403 Forbidden` (Role)
- **원인**: 인증은 되었으나 권한(Role) 부족.
- **해결**: `@PreAuthorize` 설정 또는 유저 권한 DB 확인.

### 4-4. `AuthenticationCredentialsNotFoundException`
- **원인**: SecurityContext에 인증 객체가 없음.
- **해결**: 필터 체인 확인. 인증 로직이 정상적으로 `SecurityContextHolder`에 저장하는지 확인.

### 4-5. `UsernameNotFoundException`
- **원인**: `UserDetailsService`에서 유저를 찾지 못함.
- **해결**: DB 조회 로직 및 데이터 확인.

### 4-6. Password Encoder Error (`There is no PasswordEncoder mapped`)
- **원인**: 비밀번호 앞에 `{id}` 식별자가 없거나 인코더 설정 누락.
- **해결**: `BCryptPasswordEncoder` 빈 등록 또는 `{bcrypt}` 접두사 사용.

### 4-7. `AccessDeniedException`
- **원인**: 접근 거부.
- **해결**: 글로벌 예외 처리기에서 403 응답으로 변환.

### 4-8. OAuth2 Redirect Loop
- **원인**: 인증 성공 후 리다이렉트 설정 오류.
- **해결**: `successHandler` 로직 점검.

### 4-9. Session Fixation Attack Protection
- **원인**: 로그인 시 세션 ID 변경됨 (정상).
- **해결**: 세션 유지 전략 확인.

### 4-10. `StrictHttpFirewall` (The request was rejected...)
- **원인**: URL에 허용되지 않은 문자(`//`, `\`) 포함.
- **해결**: 요청 URL 정제 또는 방화벽 설정 완화(비권장).

---

## 🔍 Good vs Bad Troubleshooting Habits

### ❌ Bad Practice
- **e.printStackTrace()**: 에러를 콘솔에만 찍고 넘어가서, 운영 환경에서 로그 추적이 불가능함.
- **`spring.jpa.hibernate.ddl-auto=update` (운영)**: 운영 DB 스키마가 의도치 않게 변경될 위험.
- **모든 예외를 Exception으로 잡기**: `catch (Exception e)`는 구체적인 원인 파악을 어렵게 함.

### ✅ Good Practice
- **Global Exception Handler**: `@ControllerAdvice`를 사용하여 예외를 일관된 JSON 포맷(코드, 메시지)으로 응답.
- **Logging**: `log.error("Error occurred: ", e)`와 같이 스택 트레이스를 포함하여 로깅.
- **Validation**: 입력값 검증은 컨트롤러 레벨(`@Valid`)에서 수행하여 비즈니스 로직 오염 방지.

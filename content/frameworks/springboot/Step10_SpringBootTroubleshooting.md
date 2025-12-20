# Spring Boot Top 50 Troubleshooting Guide

Spring Boot 애플리케이션 개발 및 운영 중 자주 발생하는 50가지 오류와 그 해결 방법을 정리한 가이드입니다.
증상, 원인, 해결책 순으로 구성되어 있으며, 문제 상황에 맞춰 빠르게 찾아볼 수 있습니다.

---

## 1. Startup & Bean Issues (시작 및 빈 관련)

### 1. BeanCreationException
- **증상**: 애플리케이션 시작 실패, 스택 트레이스에 `Error creating bean with name...` 표시.
- **원인**: 의존성 주입 실패, `@Autowired` 대상 빈이 없음, 생성자 파라미터 불일치.
- **해결**:
  - `@Service`, `@Component` 어노테이션이 클래스에 붙어있는지 확인.
  - `@ComponentScan` 패키지 범위 확인.
  - 생성자 주입 시 `final` 필드와 `@RequiredArgsConstructor` 사용 권장.

### 2. NoSuchBeanDefinitionException
- **증상**: `No qualifying bean of type '...' available`.
- **원인**: 인터페이스를 주입받으려 했으나 구현체가 없거나, 구현체가 2개 이상임(Primary 미지정).
- **해결**: 구현 클래스에 빈 등록 어노테이션 확인. 구현체가 여러 개면 `@Qualifier("beanName")` 또는 `@Primary` 사용.

### 3. CircularDependency (순환 참조)
- **증상**: `The dependencies of some of the beans in the application context form a cycle`.
- **원인**: A가 B를 주입받고, B가 다시 A를 주입받는 구조.
- **해결**:
  - **설계 개선**: 공통 기능을 제3의 서비스(C)로 분리.
  - **임시 방편**: 한쪽에 `@Lazy` 사용. `private final ServiceA a;` -> `@Lazy @Autowired private ServiceA a;`.

### 4. PortInUseException
- **증상**: `Web server failed to start. Port 8080 was already in use.`
- **원인**: 다른 프로세스나 이전 실행된 톰캣이 포트를 점유 중.
- **해결**:
  - 프로세스 종료: `lsof -i :8080` (Mac/Linux) -> `kill -9 <PID>`, `netstat -ano | findstr 8080` (Win).
  - 포트 변경: `server.port=8081` (application.properties).

### 5. DataSourceConnectionFailure
- **증상**: `HikariPool-1 - Exception during pool initialization`.
- **원인**: DB URL, Username, Password 오타 또는 DB 서버 다운.
- **해결**: `spring.datasource.url` 등 설정 확인. 방화벽 및 DB 상태 점검.

### 6. ApplicationContextException
- **증상**: `Unable to start web server`.
- **원인**: 필수 환경 변수 누락, 서블릿 컨테이너 초기화 실패.
- **해결**: 로그의 `Caused by`를 찾아 근본 원인 해결.

---

## 2. Configuration & Properties (설정)

### 7. ConfigurationPropertiesBindingException
- **증상**: `Failed to bind properties under ...`.
- **원인**: `application.properties` 키와 매핑 클래스 필드 타입 불일치.
- **해결**: 타입 확인(String -> Int 변환 오류 등). `@ConstructorBinding` 사용 시 설정 확인.

### 8. ValueInjectionNull (`@Value` is null)
- **증상**: `@Value("${my.prop}")` 필드가 null 이거나 `${my.prop}` 문자열 그대로 들어옴.
- **원인**: 빈으로 등록되지 않은 객체(`new`로 생성)에서 사용, 또는 프로퍼티 파일 로드 실패.
- **해결**: 해당 클래스를 빈으로 등록, `static` 필드에는 사용 불가.

### 9. ProfileMismatch
- **증상**: 특정 환경 설정이 적용되지 않음.
- **원인**: 활성 프로파일 설정 누락 (`spring.profiles.active`).
- **해결**: 실행 인자 `-Dspring.profiles.active=dev` 추가 또는 환경 변수 설정.

### 10. PropertyFileNotFound
- **증상**: 커스텀 프로퍼티 파일을 찾을 수 없음.
- **원인**: `@PropertySource("classpath:custom.properties")` 경로 오류.
- **해결**: `src/main/resources` 위치 확인.

---

## 3. Web & API Issues

### 11. 404 Not Found
- **증상**: API 호출 시 404 응답.
- **원인**:
  - 컨트롤러 패키지가 `@SpringBootApplication` 패키지 하위에 없음.
  - URL 경로 오타 (`/api/v1` vs `/api/v2`).
- **해결**: 패키지 구조 이동 또는 `@ComponentScan` 설정. URL 매핑 확인.

### 12. 405 Method Not Allowed
- **증상**: `Request method 'POST' not supported`.
- **원인**: `@GetMapping`으로 선언하고 POST 요청을 보냄.
- **해결**: 클라이언트 요청 메서드 수정 또는 컨트롤러 매핑 변경.

### 13. 415 Unsupported Media Type
- **증상**: `Content type 'application/json' not supported`.
- **원인**:
  - `Content-Type: application/json` 헤더 누락.
  - DTO에 기본 생성자(NoArgsConstructor) 누락 (Jackson 역직렬화 실패).
- **해결**: 헤더 추가, DTO에 기본 생성자 추가.

### 14. 400 Bad Request (Validation)
- **증상**: 입력값 검증 실패.
- **원인**: `@Valid` 어노테이션 누락 또는 제약 조건(`@NotNull` 등) 위반.
- **해결**: 컨트롤러 파라미터에 `@Valid` 추가, `BindingResult`로 에러 처리.

### 15. HttpMessageNotReadableException
- **증상**: `Required request body is missing`.
- **원인**: `@RequestBody`가 필요한데 본문이 비어있음.
- **해결**: JSON Body 전송 확인.

### 16. CORS Error
- **증상**: 브라우저 콘솔에 `Access-Control-Allow-Origin` 에러.
- **원인**: 다른 도메인에서 API 호출 시 보안 차단.
- **해결**: `@CrossOrigin` 추가 또는 `WebMvcConfigurer`에서 글로벌 설정.

### 17. MissingServletRequestParameterException
- **증상**: `Required String parameter 'id' is not present`.
- **원인**: `@RequestParam` 필수 파라미터 누락.
- **해결**: 파라미터 전송 또는 `required=false` 설정.

---

## 4. Database & JPA

### 18. LazyInitializationException
- **증상**: `failed to lazily initialize a collection... no session`.
- **원인**: 트랜잭션 범위 밖에서 지연 로딩(Lazy Loading) 엔티티 접근.
- **해결**:
  - `@Transactional` 붙이기.
  - `Fetch Join` 또는 `EntityGraph` 사용하여 미리 로딩.

### 19. N+1 Problem
- **증상**: 쿼리가 예상보다 훨씬 많이 실행됨 (성능 저하).
- **원인**: 연관 관계 엔티티를 루프 돌며 하나씩 조회.
- **해결**: `join fetch` 사용 (JPQL).

### 20. TransientPropertyValueException
- **증상**: `object references an unsaved transient instance`.
- **원인**: 영속화되지 않은(저장 안 된) 객체를 다른 객체의 연관관계로 저장하려 함.
- **해결**: 연관 객체를 먼저 `save()` 하거나, `CascadeType.PERSIST` 옵션 사용.

### 21. OptimisticLockingFailureException
- **증상**: `Row was updated or deleted by another transaction`.
- **원인**: 동시 수정 발생 (`@Version` 필드 불일치).
- **해결**: 재시도 로직 구현 또는 비즈니스 로직 검토.

### 22. InvalidDataAccessApiUsageException
- **증상**: JPA 사용법 오류.
- **원인**: 엔티티가 아닌 객체를 저장하려 하거나, 트랜잭션 없이 수정.
- **해결**: `@Entity` 확인, `@Transactional` 확인.

### 23. QuerySyntaxException
- **증상**: JPQL 문법 오류.
- **원인**: 테이블명이 아닌 엔티티 클래스명을 써야 함.
- **해결**: SQL이 아닌 JPQL 문법 확인 (`FROM Member m` 등).

---

## 5. Security (Spring Security)

### 24. 401 Unauthorized
- **증상**: 로그인 실패 또는 토큰 만료.
- **해결**: 자격 증명 확인, JWT 만료 시간 확인.

### 25. 403 Forbidden
- **증상**: 로그인은 했으나 접근 권한 없음.
- **원인**: `hasRole('ADMIN')` 등 권한 부족. CSRF 토큰 누락.
- **해결**: DB 권한 데이터 확인, API 테스트 시 `csrf().disable()` (개발 환경).

### 26. Infinite Redirect Loop
- **증상**: 브라우저가 계속 리다이렉트됨 (`ERR_TOO_MANY_REDIRECTS`).
- **원인**: 로그인 페이지 설정 오류 (로그인 페이지 자체도 인증 요구).
- **해결**: `permitAll()`에 로그인 페이지 경로 추가.

### 27. PasswordEncoder Mismatch
- **증상**: `Encoded password does not look like BCrypt`.
- **원인**: DB에 평문 비밀번호 저장 후 BCrypt로 검증 시도.
- **해결**: `{noop}` 접두사 사용(테스트용) 또는 회원가입 시 반드시 `passwordEncoder.encode()` 사용.

---

## 6. Miscellaneous (기타)

### 28. NullPointerException (NPE)
- **증상**: 가장 흔한 런타임 에러.
- **원인**: 주입받지 못한 빈 사용, DB 조회 결과 null 접근.
- **해결**: `Optional` 사용, 디버깅.

### 29. OutOfMemoryError
- **증상**: `Java heap space`.
- **원인**: 메모리 누수, 대량 데이터 조회.
- **해결**: 힙 사이즈 증가(`-Xmx`), 페이징 처리(`Pageable`) 적용.

### 30. StackOverflowError
- **증상**: 무한 재귀 호출.
- **원인**: 양방향 연관관계 엔티티의 `toString()` 또는 JSON 직렬화 무한 루프.
- **해결**: `@JsonIgnore`, `@ToString(exclude=...)`, DTO 변환 사용.

---

## Tip: 디버깅 체크리스트
1. **로그 레벨 변경**: `logging.level.root=DEBUG`로 상세 로그 확인.
2. **의존성 트리 확인**: `mvn dependency:tree` 또는 `gradle dependencies`로 버전 충돌 확인.
3. **단위 테스트**: 문제가 되는 부분만 격리하여 `@Test` 작성.
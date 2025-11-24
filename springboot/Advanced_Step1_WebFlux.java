/**
 * Advanced Step 1: Spring WebFlux - 리액티브 프로그래밍
 *
 * 이 파일은 Spring WebFlux를 활용한 리액티브 웹 애플리케이션 개발을 학습합니다.
 * 비동기 논블로킹 방식으로 높은 처리량을 달성하는 방법을 배웁니다.
 *
 * 학습 목표:
 * 1. Mono와 Flux의 개념 이해
 * 2. 리액티브 스트림 연산자 활용
 * 3. WebClient를 사용한 리액티브 HTTP 클라이언트
 * 4. 리액티브 에러 처리
 * 5. Spring MVC vs WebFlux 비교
 *
 * @author Learning Code Project
 * @since Spring Boot 3.x
 */

package com.example.webflux;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.reactive.function.client.WebClient;

import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.core.scheduler.Schedulers;

import java.time.Duration;
import java.util.List;
import java.util.Map;

// ============================================================
// 1. 기본 설정 및 애플리케이션 엔트리 포인트
// ============================================================

@SpringBootApplication
public class Advanced_Step1_WebFlux {

    public static void main(String[] args) {
        SpringApplication.run(Advanced_Step1_WebFlux.class, args);
    }

    /**
     * WebClient Bean 설정
     * RestTemplate 대신 리액티브 HTTP 클라이언트 사용
     */
    @Bean
    public WebClient webClient() {
        return WebClient.builder()
                .baseUrl("https://api.example.com")
                .defaultHeader("Content-Type", MediaType.APPLICATION_JSON_VALUE)
                .build();
    }
}

// ============================================================
// 2. Mono와 Flux 기본 개념
// ============================================================

/**
 * Mono: 0개 또는 1개의 요소를 발행하는 리액티브 스트림
 * Flux: 0개 이상의 요소를 발행하는 리액티브 스트림
 */
@RestController
@RequestMapping("/api/reactive")
class ReactiveBasicsController {

    // ------------------------------------------------------------
    // [나쁜 예시] 블로킹 방식의 데이터 조회
    // ------------------------------------------------------------

    /**
     * 문제점:
     * 1. Thread.sleep()으로 스레드 블로킹
     * 2. 동시 요청 처리 시 스레드 고갈
     * 3. 확장성 제한
     */
    // @GetMapping("/blocking")
    // public String getBlockingData() throws InterruptedException {
    //     Thread.sleep(1000); // 블로킹!
    //     return "Blocking Response";
    // }

    // ------------------------------------------------------------
    // [좋은 예시] 논블로킹 방식의 데이터 조회
    // ------------------------------------------------------------

    /**
     * Mono를 사용한 단일 값 반환
     * 논블로킹으로 지연 후 응답
     */
    @GetMapping("/mono")
    public Mono<String> getMonoData() {
        return Mono.just("Hello, Reactive World!")
                .delayElement(Duration.ofSeconds(1)) // 논블로킹 지연
                .doOnSubscribe(s -> System.out.println("구독 시작"))
                .doOnSuccess(data -> System.out.println("완료: " + data));
    }

    /**
     * Flux를 사용한 스트림 데이터 반환
     * Server-Sent Events (SSE) 형태로 실시간 스트리밍
     */
    @GetMapping(value = "/flux", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public Flux<String> getFluxData() {
        return Flux.interval(Duration.ofMillis(500))
                .take(10)
                .map(seq -> "Event #" + seq + " at " + System.currentTimeMillis());
    }

    /**
     * Flux를 사용한 컬렉션 데이터 반환
     */
    @GetMapping("/users")
    public Flux<User> getAllUsers() {
        return Flux.just(
                new User(1L, "김철수", "kim@example.com"),
                new User(2L, "이영희", "lee@example.com"),
                new User(3L, "박민수", "park@example.com")
        ).delayElements(Duration.ofMillis(100)); // 각 요소 사이에 지연
    }
}

// ============================================================
// 3. 리액티브 스트림 연산자
// ============================================================

@RestController
@RequestMapping("/api/operators")
class ReactiveOperatorsController {

    /**
     * map: 각 요소를 변환
     */
    @GetMapping("/map")
    public Flux<String> mapOperator() {
        return Flux.just(1, 2, 3, 4, 5)
                .map(n -> "Number: " + n * 2);
    }

    /**
     * flatMap: 각 요소를 Mono/Flux로 변환 후 병합 (비동기 변환)
     *
     * [나쁜 예시] 순차적 처리가 필요한 곳에 flatMap 사용
     * flatMap은 순서를 보장하지 않음!
     */
    @GetMapping("/flatmap")
    public Flux<String> flatMapOperator() {
        return Flux.just("A", "B", "C")
                .flatMap(letter ->
                        Mono.just(letter + "-processed")
                                .delayElement(Duration.ofMillis((long) (Math.random() * 100)))
                );
        // 결과 순서가 보장되지 않음: B-processed, A-processed, C-processed 등
    }

    /**
     * [좋은 예시] concatMap: 순서를 보장하는 비동기 변환
     */
    @GetMapping("/concatmap")
    public Flux<String> concatMapOperator() {
        return Flux.just("A", "B", "C")
                .concatMap(letter ->
                        Mono.just(letter + "-processed")
                                .delayElement(Duration.ofMillis(100))
                );
        // 결과 순서 보장: A-processed, B-processed, C-processed
    }

    /**
     * filter: 조건에 맞는 요소만 통과
     */
    @GetMapping("/filter")
    public Flux<Integer> filterOperator() {
        return Flux.range(1, 20)
                .filter(n -> n % 2 == 0) // 짝수만 통과
                .filter(n -> n > 5);      // 5보다 큰 것만
    }

    /**
     * reduce: 모든 요소를 하나로 집계
     */
    @GetMapping("/reduce")
    public Mono<Integer> reduceOperator() {
        return Flux.range(1, 10)
                .reduce(0, Integer::sum); // 1+2+3+...+10 = 55
    }

    /**
     * zip: 여러 스트림의 요소를 결합
     */
    @GetMapping("/zip")
    public Flux<String> zipOperator() {
        Flux<String> names = Flux.just("김철수", "이영희", "박민수");
        Flux<Integer> ages = Flux.just(25, 30, 28);

        return Flux.zip(names, ages, (name, age) -> name + " (" + age + "세)");
    }

    /**
     * buffer: 요소를 그룹으로 묶음
     */
    @GetMapping("/buffer")
    public Flux<List<Integer>> bufferOperator() {
        return Flux.range(1, 10)
                .buffer(3); // [1,2,3], [4,5,6], [7,8,9], [10]
    }
}

// ============================================================
// 4. WebClient - 리액티브 HTTP 클라이언트
// ============================================================

@Service
class ReactiveHttpService {

    private final WebClient webClient;

    public ReactiveHttpService(WebClient webClient) {
        this.webClient = webClient;
    }

    // ------------------------------------------------------------
    // [나쁜 예시] RestTemplate 사용 (블로킹)
    // ------------------------------------------------------------

    /*
    // RestTemplate은 블로킹 방식
    public User getUserBlocking(Long id) {
        RestTemplate restTemplate = new RestTemplate();
        return restTemplate.getForObject("/users/" + id, User.class);
        // 응답을 받을 때까지 스레드가 블로킹됨
    }
    */

    // ------------------------------------------------------------
    // [좋은 예시] WebClient 사용 (논블로킹)
    // ------------------------------------------------------------

    /**
     * 단일 리소스 조회 (Mono)
     */
    public Mono<User> getUserById(Long id) {
        return webClient.get()
                .uri("/users/{id}", id)
                .retrieve()
                .bodyToMono(User.class)
                .timeout(Duration.ofSeconds(5))
                .doOnError(e -> System.err.println("Error: " + e.getMessage()));
    }

    /**
     * 컬렉션 리소스 조회 (Flux)
     */
    public Flux<User> getAllUsers() {
        return webClient.get()
                .uri("/users")
                .retrieve()
                .bodyToFlux(User.class)
                .timeout(Duration.ofSeconds(10));
    }

    /**
     * POST 요청으로 리소스 생성
     */
    public Mono<User> createUser(User user) {
        return webClient.post()
                .uri("/users")
                .bodyValue(user)
                .retrieve()
                .bodyToMono(User.class);
    }

    /**
     * 여러 API 병렬 호출 후 결합
     */
    public Mono<Map<String, Object>> getAggregatedData(Long userId) {
        Mono<User> userMono = getUserById(userId);
        Mono<List<Order>> ordersMono = getOrdersByUserId(userId).collectList();

        return Mono.zip(userMono, ordersMono)
                .map(tuple -> Map.of(
                        "user", tuple.getT1(),
                        "orders", tuple.getT2()
                ));
    }

    private Flux<Order> getOrdersByUserId(Long userId) {
        return webClient.get()
                .uri("/users/{id}/orders", userId)
                .retrieve()
                .bodyToFlux(Order.class);
    }
}

// ============================================================
// 5. 리액티브 에러 처리
// ============================================================

@RestController
@RequestMapping("/api/error-handling")
class ErrorHandlingController {

    /**
     * onErrorReturn: 에러 발생 시 기본값 반환
     */
    @GetMapping("/fallback")
    public Mono<String> errorFallback() {
        return Mono.error(new RuntimeException("API 호출 실패"))
                .onErrorReturn("기본 응답값")
                .cast(String.class);
    }

    /**
     * onErrorResume: 에러 발생 시 대체 Publisher로 전환
     */
    @GetMapping("/resume")
    public Mono<User> errorResume(@RequestParam Long id) {
        return fetchUserFromPrimaryService(id)
                .onErrorResume(e -> {
                    System.err.println("Primary 서비스 실패: " + e.getMessage());
                    return fetchUserFromBackupService(id);
                });
    }

    /**
     * retry: 에러 발생 시 재시도
     */
    @GetMapping("/retry")
    public Mono<String> errorRetry() {
        return Mono.defer(() -> {
                    System.out.println("API 호출 시도: " + System.currentTimeMillis());
                    if (Math.random() < 0.7) {
                        return Mono.error(new RuntimeException("일시적 오류"));
                    }
                    return Mono.just("성공!");
                })
                .retry(3) // 최대 3번 재시도
                .onErrorReturn("모든 재시도 실패");
    }

    /**
     * retryWhen: 고급 재시도 전략 (지수 백오프)
     */
    @GetMapping("/retry-backoff")
    public Mono<String> errorRetryWithBackoff() {
        return Mono.defer(() -> {
                    if (Math.random() < 0.8) {
                        return Mono.error(new RuntimeException("일시적 오류"));
                    }
                    return Mono.just("성공!");
                })
                .retryWhen(reactor.util.retry.Retry.backoff(3, Duration.ofMillis(100))
                        .maxBackoff(Duration.ofSeconds(2))
                        .doBeforeRetry(signal ->
                                System.out.println("재시도 #" + signal.totalRetries())
                        ));
    }

    private Mono<User> fetchUserFromPrimaryService(Long id) {
        return Mono.error(new RuntimeException("Primary 서비스 다운"));
    }

    private Mono<User> fetchUserFromBackupService(Long id) {
        return Mono.just(new User(id, "백업 사용자", "backup@example.com"));
    }
}

// ============================================================
// 6. 스케줄러와 스레드 관리
// ============================================================

@RestController
@RequestMapping("/api/schedulers")
class SchedulerController {

    /**
     * publishOn: 이후 연산자를 다른 스레드에서 실행
     * subscribeOn: 구독(소스)을 다른 스레드에서 실행
     */
    @GetMapping("/threading")
    public Mono<String> schedulerDemo() {
        return Mono.fromCallable(() -> {
                    System.out.println("소스 스레드: " + Thread.currentThread().getName());
                    return "데이터";
                })
                .subscribeOn(Schedulers.boundedElastic()) // I/O 작업용 스레드 풀
                .map(data -> {
                    System.out.println("변환 스레드: " + Thread.currentThread().getName());
                    return data.toUpperCase();
                })
                .publishOn(Schedulers.parallel()) // CPU 집약 작업용 스레드 풀
                .map(data -> {
                    System.out.println("처리 스레드: " + Thread.currentThread().getName());
                    return data + " - 처리완료";
                });
    }
}

// ============================================================
// DTO 클래스
// ============================================================

record User(Long id, String name, String email) {}

record Order(Long id, Long userId, String product, int quantity) {}

// ============================================================
// 학습 포인트 요약
// ============================================================

/*
 * 1. Mono vs Flux:
 *    - Mono: 0..1개 요소 (단일 결과)
 *    - Flux: 0..N개 요소 (스트림)
 *
 * 2. 주요 연산자:
 *    - map: 동기 변환
 *    - flatMap: 비동기 변환 (순서 보장 X)
 *    - concatMap: 비동기 변환 (순서 보장 O)
 *    - filter, reduce, zip, buffer
 *
 * 3. WebClient vs RestTemplate:
 *    - WebClient: 논블로킹, 리액티브
 *    - RestTemplate: 블로킹 (Deprecated)
 *
 * 4. 에러 처리:
 *    - onErrorReturn: 기본값 반환
 *    - onErrorResume: 대체 Publisher
 *    - retry/retryWhen: 재시도
 *
 * 5. 스케줄러:
 *    - Schedulers.boundedElastic(): I/O 작업
 *    - Schedulers.parallel(): CPU 작업
 *    - subscribeOn: 소스 스레드 지정
 *    - publishOn: 이후 연산 스레드 지정
 *
 * 6. WebFlux 적합한 경우:
 *    - 높은 동시성 요구
 *    - 스트리밍 데이터
 *    - 마이크로서비스 간 통신
 *
 * 7. Spring MVC가 나은 경우:
 *    - JDBC/JPA (블로킹 DB)
 *    - 단순한 CRUD
 *    - 팀의 리액티브 경험 부족
 */

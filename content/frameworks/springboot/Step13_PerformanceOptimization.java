package com.example.springboot;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Executor;

/**
 * ========================================================================================
 * Step 13: 성능 최적화 (Performance Optimization) A-Z 완전 정복
 * ========================================================================================
 *
 * 이 파일은 Spring Boot 애플리케이션의 속도를 비약적으로 향상시키는 3대장
 * (캐싱, 비동기 처리, 벌크 연산)을 다룹니다.
 *
 * [학습 목표]
 * 1. **캐싱(@Cacheable)**을 통해 DB 부하를 줄이고 응답 속도를 높이는 법을 배웁니다.
 * 2. **비동기 처리(@Async)**를 통해 긴 작업을 백그라운드로 넘기는 법을 익힙니다.
 * 3. **벌크 연산(Batch Insert)**으로 대량 데이터를 빠르게 저장하는 법을 배웁니다.
 * 4. [주의] 캐시 메모리 누수와 비동기 스레드 풀 고갈(OOM) 문제를 피하는 법을 이해합니다.
 */

@SpringBootApplication
@EnableCaching // 캐싱 활성화
@EnableAsync   // 비동기 처리 활성화
public class Step13_PerformanceOptimization {
    public static void main(String[] args) {
        SpringApplication.run(Step13_PerformanceOptimization.class, args);
    }
}

// ========================================================================================
// 1. 캐싱 (Caching) - 자주 조회되는 데이터 메모리에 저장
// ========================================================================================

/**
 * [캐싱 전략: Look-Aside (Lazy Loading)]
 * 데이터가 캐시에 있으면 리턴, 없으면 DB 조회 후 캐시에 저장.
 *
 * [주의: TTL (Time To Live)]
 * 기본 `ConcurrentMapCacheManager`는 만료 시간이 없습니다. 데이터가 계속 쌓이면 **OOM(메모리 부족)** 발생!
 * 실무에서는 Redis나 Caffeine을 사용하여 반드시 만료 시간(TTL)을 설정해야 합니다.
 */
@Service
class ProductService {

    // 캐시 저장 (key: id, value: 메서드 리턴값)
    @Cacheable(value = "products", key = "#id")
    public String getProductInfo(Long id) {
        simulateSlowService(); // DB 조회 3초 걸린다고 가정
        return "Product Info " + id;
    }

    // 데이터 수정 시 캐시도 갱신
    @CachePut(value = "products", key = "#id")
    public String updateProduct(Long id, String newInfo) {
        return newInfo;
    }

    // 데이터 삭제 시 캐시 제거
    @CacheEvict(value = "products", key = "#id")
    public void deleteProduct(Long id) {
        // DB delete logic...
    }

    private void simulateSlowService() {
        try { Thread.sleep(3000); } catch (InterruptedException e) {}
    }
}

// ========================================================================================
// 2. 비동기 처리 (Async) - 느린 작업은 나중에
// ========================================================================================

@Configuration
class AsyncConfig {
    /**
     * [중요: 커스텀 스레드 풀 설정]
     * 기본 설정(`SimpleAsyncTaskExecutor`)은 요청마다 스레드를 새로 만듭니다.
     * 요청이 폭주하면 스레드가 무한정 생성되어 서버가 죽습니다 (OOM).
     * 반드시 `ThreadPoolTaskExecutor`를 정의해서 스레드 개수를 제한해야 합니다.
     */
    @Bean(name = "taskExecutor")
    public Executor taskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(5);     // 기본 스레드 수
        executor.setMaxPoolSize(10);     // 최대 스레드 수
        executor.setQueueCapacity(100);  // 대기열 크기
        executor.setThreadNamePrefix("Async-");
        executor.initialize();
        return executor;
    }
}

@Service
class NotificationService {

    // 결과값이 필요 없는 작업 (Fire and Forget)
    @Async("taskExecutor")
    public void sendEmail(String email) {
        System.out.println("[Async] 이메일 전송 시작: " + Thread.currentThread().getName());
        try { Thread.sleep(2000); } catch (InterruptedException e) {}
        System.out.println("[Async] 이메일 전송 완료");
    }

    // 결과값이 필요한 작업 (CompletableFuture)
    @Async("taskExecutor")
    public CompletableFuture<String> processPayment() {
        return CompletableFuture.completedFuture("결제 완료");
    }
}

// ========================================================================================
// 3. 대용량 데이터 처리 (Batch Insert)
// ========================================================================================

@Service
class BulkInsertService {
    private final JdbcTemplate jdbcTemplate;

    public BulkInsertService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    /**
     * [JPA saveAll vs JDBC Batch]
     * JPA `saveAll()`은 내부적으로 한 건씩 insert 하거나 최적화가 제한적입니다.
     * 데이터 1만 건 이상을 넣을 때는 `JdbcTemplate.batchUpdate`가 10배 이상 빠릅니다.
     */
    public void insert10000Products() {
        List<Object[]> batchArgs = new ArrayList<>();
        for (int i = 0; i < 10000; i++) {
            batchArgs.add(new Object[]{"Product " + i, 1000});
        }

        String sql = "INSERT INTO product (name, price) VALUES (?, ?)";
        
        // 한 방에 쿼리 전송
        jdbcTemplate.batchUpdate(sql, batchArgs);
    }
}

// ========================================================================================
// 4. 테스트 컨트롤러
// ========================================================================================

@RestController
class PerformanceController {
    private final ProductService productService;
    private final NotificationService notificationService;

    public PerformanceController(ProductService productService, NotificationService notificationService) {
        this.productService = productService;
        this.notificationService = notificationService;
    }

    @GetMapping("/cache/{id}")
    public String getProduct(@PathVariable Long id) {
        long start = System.currentTimeMillis();
        String result = productService.getProductInfo(id); // 첫 호출 3초, 두 번째부터 0초
        long end = System.currentTimeMillis();
        return result + " (Time: " + (end - start) + "ms)";
    }

    @GetMapping("/async")
    public String sendEmail() {
        notificationService.sendEmail("user@example.com");
        return "이메일 전송 요청됨 (즉시 응답)"; // 사용자는 기다리지 않음
    }
}
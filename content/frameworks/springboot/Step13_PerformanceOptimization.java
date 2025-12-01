// Step13_PerformanceOptimization.java
// Spring Boot 애플리케이션 성능 최적화 학습을 위한 코드 예시입니다.
// 이 파일은 캐싱(Caching), 비동기 처리(Asynchronous Processing), 쿼리 최적화 등
// Spring Boot 애플리케이션의 성능을 개선하는 다양한 기법들을 보여줍니다.
//
// 성능 최적화는 사용자 경험 향상, 리소스 효율 증대, 비용 절감 등
// 애플리케이션 운영에 있어 매우 중요한 부분입니다.

package com.example.performanceoptimization;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.Bean;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.PostConstruct;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Executor;
import java.util.concurrent.TimeUnit;

// -----------------------------------------------------------------------------
// 학습 포인트 1: 캐싱 (Caching)
// - `@EnableCaching`: Spring Boot에서 캐싱 기능을 활성화합니다.
// - `@Cacheable`: 메서드의 결과를 캐시에 저장하고, 동일한 요청이 오면 캐시된 결과를 반환합니다.
// - `@CachePut`: 메서드를 항상 실행하고, 결과를 캐시에 업데이트합니다.
// - `@CacheEvict`: 캐시에서 데이터를 제거합니다.
// - 캐시 구현체: Caffeine, Redis 등 다양한 캐시 솔루션을 Spring Cache와 통합할 수 있습니다.
// -----------------------------------------------------------------------------
@SpringBootApplication
@EnableCaching // 캐싱 기능 활성화
@EnableAsync // 비동기 기능 활성화 (학습 포인트 2)
public class PerformanceOptimizationApplication {
    public static void main(String[] args) {
        SpringApplication.run(PerformanceOptimizationApplication.class, args);
    }

    // 비동기 작업을 위한 커스텀 Executor (학습 포인트 2)
    @Bean(name = "taskExecutor")
    public Executor taskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(2); // 기본 스레드 수
        executor.setMaxPoolSize(5);  // 최대 스레드 수
        executor.setQueueCapacity(500); // 큐 용량
        executor.setThreadNamePrefix("AsyncTask-");
        executor.initialize();
        return executor;
    }
}

// 예시 Repository (데이터베이스 역할을 시뮬레이션)
@Repository
class ItemRepository {
    private static final Logger logger = LoggerFactory.getLogger(ItemRepository.class);
    private final Map<Long, String> itemStore = new HashMap<>();

    @PostConstruct
    public void init() {
        itemStore.put(1L, "고성능 노트북");
        itemStore.put(2L, "인체공학 키보드");
        itemStore.put(3L, "무선 마우스");
    }

    public String findItemById(Long id) {
        logger.info("DB에서 Item {} 조회 중...", id);
        try {
            TimeUnit.SECONDS.sleep(2); // DB 조회 지연 시간 시뮬레이션
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        return itemStore.get(id);
    }

    public String updateItem(Long id, String newItemName) {
        logger.info("DB에서 Item {} 업데이트 중...", id);
        try {
            TimeUnit.SECONDS.sleep(1); // DB 업데이트 지연 시간 시뮬레이션
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        return itemStore.put(id, newItemName);
    }

    // 나쁜 예시: 캐싱 없이 매번 DB에 접근하여 동일한 데이터를 조회
    // - 데이터 변경이 거의 없는 데이터를 매번 DB에서 읽어오면
    //   DB 부하가 증가하고 응답 시간이 길어집니다.
    public String findItemByIdBadExample(Long id) {
        logger.warn("나쁜 예시: 캐싱 없이 매번 DB에서 Item {} 조회 중...", id);
        try {
            TimeUnit.SECONDS.sleep(2);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        return itemStore.get(id);
    }
}

// 예시 서비스 (캐싱 적용)
@Service
class ItemService {
    private static final Logger logger = LoggerFactory.getLogger(ItemService.class);
    private final ItemRepository itemRepository;

    public ItemService(ItemRepository itemRepository) {
        this.itemRepository = itemRepository;
    }

    @Cacheable(value = "items", key = "#id") // "items" 캐시에 id를 키로 사용하여 메서드 결과 캐싱
    public String getItemName(Long id) {
        logger.info("ItemService: getItemName({}) 호출 (캐시 미적용 또는 만료 시)", id);
        return itemRepository.findItemById(id);
    }

    @CachePut(value = "items", key = "#id") // 메서드 실행 후 캐시 업데이트
    public String updateItemName(Long id, String newName) {
        logger.info("ItemService: updateItemName({}, {}) 호출 (캐시 업데이트)", id, newName);
        itemRepository.updateItem(id, newName);
        return newName; // 업데이트된 새 이름을 캐시에 저장
    }

    @CacheEvict(value = "items", key = "#id") // 캐시에서 특정 항목 제거
    public void evictItemCache(Long id) {
        logger.info("ItemService: evictItemCache({}) 호출 (캐시 제거)", id);
    }

    @CacheEvict(value = "items", allEntries = true) // 캐시의 모든 항목 제거
    public void evictAllItemsCache() {
        logger.info("ItemService: evictAllItemsCache 호출 (모든 캐시 제거)");
    }
}

// -----------------------------------------------------------------------------
// 학습 포인트 2: 비동기 처리 (Asynchronous Processing)
// - `@EnableAsync`: 비동기 메서드 실행을 활성화합니다.
// - `@Async`: 메서드를 비동기적으로 실행하도록 지정합니다.
// - `CompletableFuture<T>`: 비동기 메서드의 결과를 감싸는 객체로, 콜백 체이닝이 가능합니다.
// - 사용 용도: 긴 시간이 소요되는 작업(외부 API 호출, 파일 처리, 이메일 전송)을
//   메인 스레드에서 분리하여 응답 시간을 단축합니다.
// -----------------------------------------------------------------------------
@Service
class AsyncService {
    private static final Logger logger = LoggerFactory.getLogger(AsyncService.class);

    @Async("taskExecutor") // "taskExecutor" 빈에서 정의된 스레드 풀을 사용
    public CompletableFuture<String> performLongRunningTask(String taskName) {
        logger.info("[Async] {} 시작 (Thread: {})", taskName, Thread.currentThread().getName());
        try {
            TimeUnit.SECONDS.sleep(3); // 긴 작업 시뮬레이션
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        logger.info("[Async] {} 완료 (Thread: {})", taskName, Thread.currentThread().getName());
        return CompletableFuture.completedFuture("작업 " + taskName + " 완료!");
    }

    // 나쁜 예시: 모든 작업을 동기적으로 처리하여 사용자 요청을 블로킹하는 경우
    // - 사용자에게 응답이 지연되거나, 서버의 동시 요청 처리량이 줄어들어 성능 병목 발생.
    public String performLongRunningTaskBadExample(String taskName) {
        logger.warn("[Sync] {} 시작 (Thread: {})", taskName, Thread.currentThread().getName());
        try {
            TimeUnit.SECONDS.sleep(3);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        logger.warn("[Sync] {} 완료 (Thread: {})", taskName, Thread.currentThread().getName());
        return "작업 " + taskName + " 완료 (동기)!";
    }
}

// -----------------------------------------------------------------------------
// 학습 포인트 3: 쿼리 최적화 (Query Optimization)
// - N+1 문제 해결 (Fetch Join, EntityGraph)
// - 지연 로딩(Lazy Loading)과 즉시 로딩(Eager Loading)의 적절한 사용
// - Batch Size 설정
// - JPQL, Querydsl, Native Query 등 적절한 쿼리 방법 선택
// - Index 활용: DB 인덱스를 효과적으로 사용하여 쿼리 성능 향상
// -----------------------------------------------------------------------------
// 예시: Product, Category (N+1 문제 시뮬레이션)
// @Entity
// class Category {
//     @Id @GeneratedValue private Long id;
//     private String name;
//     @OneToMany(mappedBy = "category", fetch = FetchType.LAZY)
//     private List<Product> products = new ArrayList<>();
//     // Getter, Setter, Constructors...
// }
//
// @Entity
// class Product {
//     @Id @GeneratedValue private Long id;
//     private String name;
//     @ManyToOne(fetch = FetchType.LAZY)
//     @JoinColumn(name = "category_id")
//     private Category category;
//     // Getter, Setter, Constructors...
// }
//
// @Repository
// interface OptimizedProductRepository extends JpaRepository<Product, Long> {
//     // 좋은 예시: Fetch Join을 사용하여 N+1 문제 해결
//     @Query("SELECT p FROM Product p JOIN FETCH p.category")
//     List<Product> findAllWithCategoryFetchJoin();
//
//     // 좋은 예시: @EntityGraph를 사용하여 N+1 문제 해결
//     @EntityGraph(attributePaths = "category")
//     List<Product> findAllWithCategoryEntityGraph();
//
//     // 나쁜 예시: 모든 제품을 조회한 후 각 제품의 카테고리를 다시 조회 (N+1 발생)
//     // List<Product> findAll();
// }


// -----------------------------------------------------------------------------
// 예시 컨트롤러: PerformanceController
// -----------------------------------------------------------------------------
@RestController
@RequestMapping("/performance")
class PerformanceController {

    private static final Logger logger = LoggerFactory.getLogger(PerformanceController.class);
    private final ItemService itemService;
    private final AsyncService asyncService;
    private final ItemRepository itemRepository; // 나쁜 예시 테스트용

    public PerformanceController(ItemService itemService, AsyncService asyncService, ItemRepository itemRepository) {
        this.itemService = itemService;
        this.asyncService = asyncService;
        this.itemRepository = itemRepository;
    }

    // 캐싱 테스트 엔드포인트
    @GetMapping("/item/{id}")
    public String getItem(@PathVariable Long id) {
        long startTime = System.currentTimeMillis();
        String item = itemService.getItemName(id);
        long endTime = System.currentTimeMillis();
        logger.info("getItem({}) 요청 처리 시간: {}ms", id, (endTime - startTime));
        return item;
    }

    // 캐싱 없는 조회 (나쁜 예시)
    @GetMapping("/item/bad/{id}")
    public String getItemBadExample(@PathVariable Long id) {
        long startTime = System.currentTimeMillis();
        String item = itemRepository.findItemByIdBadExample(id);
        long endTime = System.currentTimeMillis();
        logger.warn("getItemBadExample({}) 요청 처리 시간: {}ms (캐싱 없음)", id, (endTime - startTime));
        return item;
    }

    @GetMapping("/item/{id}/update/{newName}")
    public String updateItem(@PathVariable Long id, @PathVariable String newName) {
        itemService.updateItemName(id, newName);
        return "Item " + id + " updated to " + newName;
    }

    @GetMapping("/item/{id}/evict")
    public String evictItem(@PathVariable Long id) {
        itemService.evictItemCache(id);
        return "Item " + id + " cache evicted";
    }

    @GetMapping("/item/evictAll")
    public String evictAllItems() {
        itemService.evictAllItemsCache();
        return "All items cache evicted";
    }

    // 비동기 처리 테스트 엔드포인트
    @GetMapping("/async/{taskName}")
    public CompletableFuture<String> runAsyncTask(@PathVariable String taskName) {
        logger.info("[Main] 비동기 작업 {} 시작 요청 (Thread: {})", taskName, Thread.currentThread().getName());
        // CompletableFuture를 반환하여 비동기 작업이 완료되면 응답을 보냅니다.
        return asyncService.performLongRunningTask(taskName)
                .thenApply(result -> {
                    logger.info("[Main] 비동기 작업 {} 완료 응답 준비 (Thread: {})", taskName, Thread.currentThread().getName());
                    return "Controller received: " + result;
                })
                .exceptionally(ex -> {
                    logger.error("[Main] 비동기 작업 {} 실패: {}", taskName, ex.getMessage());
                    return "Controller received: 작업 실패 - " + ex.getMessage();
                });
    }

    // 동기 처리 (나쁜 예시)
    @GetMapping("/sync/{taskName}")
    public String runSyncTask(@PathVariable String taskName) {
        logger.warn("[Main] 동기 작업 {} 시작 요청 (Thread: {})", taskName, Thread.currentThread().getName());
        String result = asyncService.performLongRunningTaskBadExample(taskName);
        logger.warn("[Main] 동기 작업 {} 완료 응답 준비 (Thread: {})", taskName, Thread.currentThread().getName());
        return "Controller received: " + result;
    }
}

/*
이 애플리케이션을 실행하고 다음 URL로 접근하여 테스트할 수 있습니다:

1. 캐싱 테스트:
   - http://localhost:8080/performance/item/1 (처음에는 2초 지연, 두 번째부터는 즉시 응답)
   - http://localhost:8080/performance/item/bad/1 (항상 2초 지연)
   - http://localhost:8080/performance/item/1/update/새노트북 (캐시 업데이트 후 다시 item/1 조회)
   - http://localhost:8080/performance/item/1/evict (캐시 제거 후 다시 item/1 조회 시 2초 지연)

2. 비동기 처리 테스트:
   - http://localhost:8080/performance/async/taskA (컨트롤러가 즉시 응답하지 않고 비동기 작업이 완료되면 응답)
   - http://localhost:8080/performance/sync/taskB (컨트롤러가 3초 동안 블로킹 된 후 응답)
   - 두 개의 `async` 요청을 동시에 보내보면, `sync` 요청과 비교했을 때 응답 속도 차이를 체감할 수 있습니다.
*/

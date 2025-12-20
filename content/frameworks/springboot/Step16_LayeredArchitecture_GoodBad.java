package frameworks.springboot;

import java.util.Map;
import java.util.HashMap;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

/**
 * Spring Boot 아키텍처 패턴 비교: Good vs Bad
 * 
 * 주제: Layered Architecture (계층형 아키텍처) vs Fat Controller (비대한 컨트롤러)
 * 
 * [학습 목표]
 * 1. 컨트롤러에 비즈니스 로직을 넣는 것(Fat Controller)이 왜 나쁜지 이해한다.
 * 2. Service, Repository, DTO를 활용한 계층 분리의 장점을 익힌다.
 * 3. 유지보수성과 테스트 용이성이 높은 코드를 작성하는 법을 배운다.
 */
public class Step16_LayeredArchitecture_GoodBad {

    /* ========================================================================
     * [BAD EXAMPLE] Fat Controller (비대한 컨트롤러)
     * 
     * 문제점:
     * 1. 역할 혼재: HTTP 요청 처리, 비즈니스 로직, 데이터 접근이 한 곳에 섞여 있음.
     * 2. DTO 미사용: 내부 DB 구조(Map)가 API 응답으로 그대로 노출됨.
     * 3. 테스트 난해: 비즈니스 로직만 따로 테스트하기 어려움 (HTTP 컨텍스트와 DB가 결합됨).
     * 4. 유지보수 불가: 로직이 복잡해질수록 코드가 스파게티처럼 얽힘.
     * ======================================================================== */
    static class FatOrderController {
        // 실제 앱에서는 @RestController가 붙음

        // [BAD] DB 역할을 하는 Map을 컨트롤러가 직접 관리 (Repository 부재)
        private final Map<Long, Map<String, Object>> database = new HashMap<>();

        // [BAD] 모든 로직이 하나의 메서드에 뭉쳐 있음
        public String createOrder(Map<String, Object> requestBody) {
            // 1. HTTP 요청 검증이 비즈니스 로직과 섞임
            if (!requestBody.containsKey("customerId")) {
                return "400 Bad Request: missing customerId";
            }

            // 2. 비즈니스 로직이 컨트롤러에 하드코딩됨 (총액 100 초과 시 무료 배송)
            double total = Double.parseDouble(requestBody.get("total").toString());
            boolean freeShipping = total > 100;

            // 3. 데이터 저장 로직도 직접 수행 (트랜잭션 관리 불가)
            long id = database.size() + 1;
            requestBody.put("id", id);
            requestBody.put("freeShipping", freeShipping);
            database.put(id, requestBody);

            // 4. 응답 생성도 하드코딩
            return "201 Created Order#" + id + " freeShipping=" + freeShipping;
        }

        public String getOrder(long id) {
            // [BAD] DB 엔티티(Map)를 직접 반환 -> 내부 구조 변경 시 API 스펙도 깨짐
            var row = database.get(id);
            if (row == null) return "404 Not Found";
            return row.toString();
        }
    }

    /* ========================================================================
     * [GOOD EXAMPLE] Layered Architecture (계층형 아키텍처)
     * 
     * 원칙:
     * 1. Controller: HTTP 요청 파싱 및 응답 반환만 담당 (매우 얇음).
     * 2. Service: 비즈니스 로직의 중심. 트랜잭션 관리.
     * 3. Repository: 데이터 저장소 접근 추상화.
     * 4. DTO: 계층 간 데이터 전송 객체 (API 스펙과 도메인 분리).
     * ======================================================================== */
    static class OrderApiController {
        private final OrderService orderService;

        // 생성자 주입 (DI)
        OrderApiController(OrderService orderService) {
            this.orderService = orderService;
        }

        // 실제 앱: @PostMapping("/orders")
        public OrderResponse createOrder(OrderRequest request) {
            // 1. 요청 검증 (HTTP 레벨)
            if (request == null || request.customerId() == null) {
                throw new IllegalArgumentException("customerId is required");
            }
            // 2. 비즈니스 로직은 서비스에게 위임
            return orderService.placeOrder(request);
        }

        // 실제 앱: @GetMapping("/orders/{id}")
        public OrderResponse getOrder(long id) {
            return orderService.fetchOrder(id);
        }
    }

    /* ---------------------------------------------------------
     * Service Layer: 비즈니스 로직의 집합소
     * HTTP나 DB 기술에 의존하지 않는 순수 자바 로직 권장
     * --------------------------------------------------------- */
    static class OrderService {
        private final OrderRepository repository;

        OrderService(OrderRepository repository) {
            this.repository = repository;
        }

        OrderResponse placeOrder(OrderRequest request) {
            // [비즈니스 로직] 100달러 초과 시 무료 배송
            boolean freeShipping = request.total() > 100.00;

            // 도메인 엔티티 생성 (DB 저장용)
            OrderEntity entity = new OrderEntity(
                    repository.nextId(),
                    request.customerId(),
                    request.total(),
                    freeShipping
            );

            // DB 저장 위임
            repository.save(entity);

            // API 응답용 DTO 변환
            return toResponse(entity);
        }

        OrderResponse fetchOrder(long id) {
            return repository.findById(id)
                    .map(this::toResponse)
                    .orElseThrow(() -> new IllegalArgumentException("Order not found: " + id));
        }

        private OrderResponse toResponse(OrderEntity entity) {
            return new OrderResponse(entity.id(), entity.customerId(), entity.total(), entity.freeShipping());
        }
    }

    /* ---------------------------------------------------------
     * Repository Layer: 데이터 접근 추상화
     * JPA, MyBatis 등으로 구현체만 갈아끼울 수 있음
     * --------------------------------------------------------- */
    interface OrderRepository {
        long nextId();
        void save(OrderEntity entity);
        Optional<OrderEntity> findById(long id);
    }

    // 메모리 DB 구현체 (실제로는 JpaRepository 사용)
    static class InMemoryOrderRepository implements OrderRepository {
        private final Map<Long, OrderEntity> store = new ConcurrentHashMap<>();
        private final AtomicLong seq = new AtomicLong(0);

        @Override
        public long nextId() {
            return seq.incrementAndGet();
        }

        @Override
        public void save(OrderEntity entity) {
            store.put(entity.id(), entity);
        }

        @Override
        public Optional<OrderEntity> findById(long id) {
            return Optional.ofNullable(store.get(id));
        }
    }

    /* ---------------------------------------------------------
     * DTO & Entity: 데이터 모델 분리
     * --------------------------------------------------------- */
    // API 요청/응답 스펙 (변경 가능성 높음)
    record OrderRequest(Long customerId, double total) {}
    record OrderResponse(long id, Long customerId, double total, boolean freeShipping) {}

    // 핵심 도메인/DB 데이터 (변경 가능성 낮음, 비즈니스 규칙 포함)
    record OrderEntity(long id, Long customerId, double total, boolean freeShipping) {}

    /* ========================================================================
     * [DEMO] 실행 예제
     * ======================================================================== */
    public static void main(String[] args) {
        System.out.println("=== BAD: Fat Controller ===");
        FatOrderController fat = new FatOrderController();
        System.out.println(fat.createOrder(Map.of("customerId", 7L, "total", 150.0)));
        System.out.println(fat.getOrder(1));

        System.out.println("\n=== GOOD: Layered Architecture ===");
        OrderRepository repo = new InMemoryOrderRepository();
        OrderService service = new OrderService(repo);
        OrderApiController api = new OrderApiController(service);

        OrderResponse created = api.createOrder(new OrderRequest(7L, 150.0));
        System.out.println("Created: " + created);
        System.out.println("Fetched: " + api.getOrder(created.id()));
    }
}

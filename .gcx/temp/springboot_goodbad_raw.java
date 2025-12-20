**Created comparison code** – illustrates fat controller vs properly layered Spring-style design; file: `Step16_LayeredArchitecture_GoodBad.java`.

```java
// Step16_LayeredArchitecture_GoodBad.java
// ENGLISH ONLY. Static inner classes keep everything in one file for teaching.
// Topic: Layered Architecture vs Fat Controller Anti-Pattern.

public class Step16_LayeredArchitecture_GoodBad {

    /* ============================= BAD EXAMPLE =============================
     * Symptoms:
     * - Controller owns HTTP concerns, business rules, and data access.
     * - No DTOs → HTTP shape leaks into domain and DB; future refactors are costly.
     * - Direct DB call couples web thread to persistence; hard to test.
     * - Error handling, validation, and transactions scattered here.
     */
    static class FatOrderController {
        // Pretend this is annotated with @RestController in a real app
        // (omitted to keep dependencies minimal).

        // Simulated "DB"
        private final java.util.Map<Long, java.util.Map<String, Object>> table = new java.util.HashMap<>();

        // HTTP handler and business logic and persistence in one method: anti-pattern.
        public String createOrder(java.util.Map<String, Object> requestBody) {
            // HTTP validation logic mixed with business rules and DB writes.
            if (!requestBody.containsKey("customerId")) { // HTTP-level check intertwined
                return "400 Bad Request: missing customerId";
            }

            // Business rule jammed here: free shipping if total > 100.
            double total = Double.parseDouble(requestBody.get("total").toString());
            boolean freeShipping = total > 100;

            // Direct "DB" write: no transaction boundaries, no repository abstraction.
            long id = table.size() + 1;
            requestBody.put("id", id);
            requestBody.put("freeShipping", freeShipping);
            table.put(id, requestBody);

            // HTTP response formatting here too.
            return "201 Created Order#" + id + " freeShipping=" + freeShipping;
        }

        public String getOrder(long id) {
            // Controller reaches straight into DB and returns internal map shape.
            var row = table.get(id);
            if (row == null) return "404 Not Found";
            return row.toString(); // Leaks persistence shape to clients.
        }
    }

    /* ============================= GOOD EXAMPLE =============================
     * Principles:
     * - Thin controller: HTTP parsing/serialization only, delegates to service.
     * - Service owns business rules, orchestrates repository calls.
     * - DTOs insulate HTTP layer from domain and persistence shapes.
     * - Repository hides data source; swapping DB or mocking is trivial.
     */
    static class OrderApiController {
        private final OrderService orderService = new OrderService(new InMemoryOrderRepository());

        // In real Spring: @PostMapping("/orders") public ResponseEntity<OrderResponse>
        public OrderResponse createOrder(OrderRequest request) {
            // Controller validates only transport-level concerns.
            if (request == null || request.customerId() == null) {
                // In Spring, throw MethodArgumentNotValidException → 400 handler.
                throw new IllegalArgumentException("customerId is required");
            }
            return orderService.placeOrder(request);
        }

        // In real Spring: @GetMapping("/orders/{id}")
        public OrderResponse getOrder(long id) {
            return orderService.fetchOrder(id);
        }
    }

    /* ============================= SERVICE LAYER =============================
     * Owns business logic; independent of HTTP and DB specifics.
     */
    static class OrderService {
        private final OrderRepository repository;

        OrderService(OrderRepository repository) {
            this.repository = repository;
        }

        OrderResponse placeOrder(OrderRequest request) {
            // Business rule: free shipping over threshold.
            boolean freeShipping = request.total() > 100.00;

            // Domain model could be richer; using simple DTO-to-entity mapping here.
            OrderEntity entity = new OrderEntity(
                    repository.nextId(),
                    request.customerId(),
                    request.total(),
                    freeShipping
            );

            repository.save(entity);
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

    /* ============================= REPOSITORY LAYER =============================
     * Encapsulates persistence concerns. Switching to JDBC/JPA only touches this layer.
     */
    interface OrderRepository {
        long nextId();
        void save(OrderEntity entity);
        java.util.Optional<OrderEntity> findById(long id);
    }

    // Simple in-memory implementation for demo; could be swapped with JDBC/JPA.
    static class InMemoryOrderRepository implements OrderRepository {
        private final java.util.Map<Long, OrderEntity> store = new java.util.concurrent.ConcurrentHashMap<>();
        private final java.util.concurrent.atomic.AtomicLong seq = new java.util.concurrent.atomic.AtomicLong(0);

        @Override
        public long nextId() {
            return seq.incrementAndGet();
        }

        @Override
        public void save(OrderEntity entity) {
            store.put(entity.id(), entity);
        }

        @Override
        public java.util.Optional<OrderEntity> findById(long id) {
            return java.util.Optional.ofNullable(store.get(id));
        }
    }

    /* ============================= DATA TRANSFER OBJECTS =============================
     * DTOs shield API from domain/persistence changes (e.g., renaming fields).
     */
    static record OrderRequest(Long customerId, double total) {}
    static record OrderResponse(long id, Long customerId, double total, boolean freeShipping) {}

    /* ============================= DOMAIN ENTITY =============================
     * Represents business data; independent of HTTP payloads.
     */
    static record OrderEntity(long id, Long customerId, double total, boolean freeShipping) {}

    /* ============================= DEMO MAIN =============================
     * Quick illustration without Spring runtime.
     */
    public static void main(String[] args) {
        // Bad path
        FatOrderController fat = new FatOrderController();
        System.out.println("BAD: " + fat.createOrder(java.util.Map.of("customerId", 7L, "total", 150.0)));
        System.out.println("BAD: " + fat.getOrder(1));

        // Good path
        OrderApiController api = new OrderApiController();
        OrderResponse created = api.createOrder(new OrderRequest(7L, 150.0));
        System.out.println("GOOD: " + created);
        System.out.println("GOOD: " + api.getOrder(created.id()));
    }
}
```

Next steps you might want:
1) Save this code to `Step16_LayeredArchitecture_GoodBad.java` and run `javac Step16_LayeredArchitecture_GoodBad.java && java Step16_LayeredArchitecture_GoodBad` to see outputs.
2) If using real Spring Boot, replace comments with actual annotations (`@RestController`, `@PostMapping`, etc.) and wire beans via dependency injection.

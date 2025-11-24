/**
 * Advanced Step 1: Java 21+ 가상 스레드 (Virtual Threads / Project Loom)
 *
 * 이 파일은 Java 21에서 정식 도입된 가상 스레드의 개념과 활용법을 학습합니다.
 * 가상 스레드는 기존 플랫폼 스레드의 한계를 극복하고 높은 동시성을 효율적으로 처리합니다.
 *
 * @author Learning Code Project
 * @since Java 21+
 */

import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.*;
import java.util.stream.IntStream;

public class Advanced_Step1_VirtualThreads {

    public static void main(String[] args) throws Exception {
        System.out.println("=== Java 21+ 가상 스레드 (Virtual Threads) 심화 학습 ===\n");

        // 1. 플랫폼 스레드 vs 가상 스레드 비교
        comparePlatformAndVirtualThreads();

        // 2. 가상 스레드 생성 방법들
        virtualThreadCreationMethods();

        // 3. 대량의 동시 작업 처리
        massiveConcurrencyDemo();

        // 4. ExecutorService와 가상 스레드
        executorServiceWithVirtualThreads();

        // 5. 구조화된 동시성 (Structured Concurrency)
        structuredConcurrencyDemo();

        // 6. 가상 스레드 사용 시 주의사항
        virtualThreadCautions();
    }

    // ============================================================
    // 1. 플랫폼 스레드 vs 가상 스레드 비교
    // ============================================================

    /**
     * 플랫폼 스레드와 가상 스레드의 차이점을 비교합니다.
     *
     * 플랫폼 스레드 (Platform Thread):
     * - OS 커널 스레드와 1:1 매핑
     * - 스레드당 약 1MB 스택 메모리 사용
     * - 생성/전환 비용이 큼
     * - 동시 스레드 수 제한 (수천 개 수준)
     *
     * 가상 스레드 (Virtual Thread):
     * - JVM이 관리하는 경량 스레드
     * - 스레드당 수 KB 메모리만 사용
     * - 생성/전환 비용이 매우 작음
     * - 수백만 개의 동시 스레드 가능
     */
    private static void comparePlatformAndVirtualThreads() throws Exception {
        System.out.println("1. 플랫폼 스레드 vs 가상 스레드 비교");
        System.out.println("-".repeat(50));

        // 나쁜 예시: 대량의 플랫폼 스레드 생성 (메모리 부족 위험)
        System.out.println("\n[나쁜 예시] 플랫폼 스레드로 대량 작업 처리:");
        System.out.println("// 10,000개의 플랫폼 스레드 생성 시 OutOfMemoryError 위험!");
        System.out.println("// 각 스레드가 약 1MB 스택 메모리를 사용하므로 ~10GB 메모리 필요");

        /*
        // 위험한 코드 (실행하지 마세요!)
        List<Thread> platformThreads = new ArrayList<>();
        for (int i = 0; i < 10000; i++) {
            Thread t = new Thread(() -> {
                try { Thread.sleep(1000); } catch (InterruptedException e) {}
            });
            platformThreads.add(t);
            t.start();
        }
        */

        // 좋은 예시: 가상 스레드로 대량 작업 처리
        System.out.println("\n[좋은 예시] 가상 스레드로 대량 작업 처리:");

        int threadCount = 10_000;
        Instant start = Instant.now();

        List<Thread> virtualThreads = new ArrayList<>();
        for (int i = 0; i < threadCount; i++) {
            // Thread.ofVirtual()로 가상 스레드 생성
            Thread vt = Thread.ofVirtual().start(() -> {
                try {
                    Thread.sleep(100); // I/O 대기 시뮬레이션
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
            });
            virtualThreads.add(vt);
        }

        // 모든 가상 스레드 완료 대기
        for (Thread vt : virtualThreads) {
            vt.join();
        }

        Duration duration = Duration.between(start, Instant.now());
        System.out.println("  - " + threadCount + "개 가상 스레드 생성 및 실행 완료");
        System.out.println("  - 소요 시간: " + duration.toMillis() + "ms");
        System.out.println("  - 메모리 효율적으로 처리됨 (수 KB/스레드)");

        System.out.println();
    }

    // ============================================================
    // 2. 가상 스레드 생성 방법들
    // ============================================================

    /**
     * 가상 스레드를 생성하는 다양한 방법을 학습합니다.
     */
    private static void virtualThreadCreationMethods() throws Exception {
        System.out.println("2. 가상 스레드 생성 방법들");
        System.out.println("-".repeat(50));

        // 방법 1: Thread.ofVirtual().start()
        System.out.println("\n[방법 1] Thread.ofVirtual().start()");
        Thread vt1 = Thread.ofVirtual().start(() -> {
            System.out.println("  가상 스레드 1 실행 중: " + Thread.currentThread());
        });
        vt1.join();

        // 방법 2: Thread.ofVirtual().name().start()
        System.out.println("\n[방법 2] 이름이 지정된 가상 스레드");
        Thread vt2 = Thread.ofVirtual()
                .name("my-virtual-thread")
                .start(() -> {
                    System.out.println("  가상 스레드 2 실행 중: " + Thread.currentThread().getName());
                });
        vt2.join();

        // 방법 3: Thread.startVirtualThread() (간편 메서드)
        System.out.println("\n[방법 3] Thread.startVirtualThread() - 간편 메서드");
        Thread vt3 = Thread.startVirtualThread(() -> {
            System.out.println("  가상 스레드 3 실행 중: " + Thread.currentThread());
        });
        vt3.join();

        // 방법 4: Thread.Builder를 사용한 팩토리 패턴
        System.out.println("\n[방법 4] Thread.Builder를 사용한 팩토리 패턴");
        Thread.Builder builder = Thread.ofVirtual().name("worker-", 0);

        for (int i = 0; i < 3; i++) {
            final int taskId = i;
            Thread vt = builder.start(() -> {
                System.out.println("  " + Thread.currentThread().getName() + " 실행 중 (작업 " + taskId + ")");
            });
            vt.join();
        }

        // 가상 스레드 확인 방법
        System.out.println("\n[가상 스레드 확인 방법]");
        Thread virtualThread = Thread.startVirtualThread(() -> {});
        Thread platformThread = new Thread(() -> {});

        System.out.println("  virtualThread.isVirtual(): " + virtualThread.isVirtual());  // true
        System.out.println("  platformThread.isVirtual(): " + platformThread.isVirtual()); // false

        System.out.println();
    }

    // ============================================================
    // 3. 대량의 동시 작업 처리
    // ============================================================

    /**
     * 가상 스레드를 활용한 대량의 동시 HTTP 요청 시뮬레이션
     * 실제 웹 서버에서 동시 요청 처리 시 매우 효과적입니다.
     */
    private static void massiveConcurrencyDemo() throws Exception {
        System.out.println("3. 대량의 동시 작업 처리 (HTTP 요청 시뮬레이션)");
        System.out.println("-".repeat(50));

        // 나쁜 예시: 전통적인 스레드 풀 사용
        System.out.println("\n[나쁜 예시] 고정 크기 스레드 풀 (병목 현상 발생):");
        System.out.println("// ExecutorService pool = Executors.newFixedThreadPool(100);");
        System.out.println("// 100개의 스레드로 10,000개 요청 처리 시 병목 발생");

        // 좋은 예시: 가상 스레드로 대량 동시 처리
        System.out.println("\n[좋은 예시] 가상 스레드로 대량 동시 처리:");

        int requestCount = 10_000;
        Instant start = Instant.now();

        // 가상 스레드용 ExecutorService 사용
        try (ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor()) {
            List<Future<String>> futures = new ArrayList<>();

            for (int i = 0; i < requestCount; i++) {
                final int requestId = i;
                Future<String> future = executor.submit(() -> {
                    // HTTP 요청 시뮬레이션 (I/O 대기)
                    Thread.sleep(50);
                    return "Request-" + requestId + " completed";
                });
                futures.add(future);
            }

            // 모든 작업 완료 대기
            int completedCount = 0;
            for (Future<String> future : futures) {
                future.get(); // 결과 대기
                completedCount++;
            }

            Duration duration = Duration.between(start, Instant.now());
            System.out.println("  - " + completedCount + "개 요청 처리 완료");
            System.out.println("  - 소요 시간: " + duration.toMillis() + "ms");
            System.out.println("  - 초당 처리량: " + (requestCount * 1000 / duration.toMillis()) + " req/s");
        }

        System.out.println();
    }

    // ============================================================
    // 4. ExecutorService와 가상 스레드
    // ============================================================

    /**
     * ExecutorService와 가상 스레드를 함께 사용하는 패턴
     */
    private static void executorServiceWithVirtualThreads() throws Exception {
        System.out.println("4. ExecutorService와 가상 스레드");
        System.out.println("-".repeat(50));

        // 나쁜 예시: 가상 스레드에 고정 풀 사용
        System.out.println("\n[나쁜 예시] 가상 스레드에 고정 크기 풀 사용:");
        System.out.println("// Executors.newFixedThreadPool()은 가상 스레드의 장점을 활용 못함");

        // 좋은 예시 1: newVirtualThreadPerTaskExecutor
        System.out.println("\n[좋은 예시 1] newVirtualThreadPerTaskExecutor:");
        try (ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor()) {
            List<Future<Integer>> futures = IntStream.range(0, 100)
                .mapToObj(i -> executor.submit(() -> {
                    Thread.sleep(10);
                    return i * 2;
                }))
                .toList();

            int sum = 0;
            for (Future<Integer> future : futures) {
                sum += future.get();
            }
            System.out.println("  - 100개 작업 결과 합계: " + sum);
        }

        // 좋은 예시 2: ThreadFactory를 사용한 커스터마이징
        System.out.println("\n[좋은 예시 2] 커스텀 ThreadFactory 사용:");
        ThreadFactory factory = Thread.ofVirtual()
                .name("custom-vt-", 0)
                .factory();

        try (ExecutorService executor = Executors.newThreadPerTaskExecutor(factory)) {
            executor.submit(() -> {
                System.out.println("  - 실행 스레드: " + Thread.currentThread().getName());
            }).get();
        }

        System.out.println();
    }

    // ============================================================
    // 5. 구조화된 동시성 (Structured Concurrency) - Preview
    // ============================================================

    /**
     * Java 21+ 구조화된 동시성 (Structured Concurrency)
     * 여러 동시 작업을 하나의 단위로 관리하여 오류 처리와 취소를 단순화합니다.
     *
     * 주의: Java 21에서는 Preview 기능입니다.
     * 컴파일: javac --enable-preview --release 21 Advanced_Step1_VirtualThreads.java
     * 실행: java --enable-preview Advanced_Step1_VirtualThreads
     */
    private static void structuredConcurrencyDemo() throws Exception {
        System.out.println("5. 구조화된 동시성 (Structured Concurrency) - Preview");
        System.out.println("-".repeat(50));

        System.out.println("\n[개념 설명]");
        System.out.println("  - 여러 하위 작업을 하나의 작업 단위로 그룹화");
        System.out.println("  - 부모 작업이 종료되면 모든 하위 작업도 함께 종료");
        System.out.println("  - 에러 발생 시 다른 하위 작업들 자동 취소");

        System.out.println("\n[코드 예시] (Preview 기능):");
        System.out.println("""
            try (var scope = new StructuredTaskScope.ShutdownOnFailure()) {
                // 여러 하위 작업 동시 실행
                Subtask<String> user = scope.fork(() -> fetchUser(userId));
                Subtask<Order> order = scope.fork(() -> fetchOrder(orderId));

                // 모든 작업 완료 대기 또는 첫 번째 실패 시 종료
                scope.join();
                scope.throwIfFailed();

                // 결과 사용
                return new Response(user.get(), order.get());
            }
            """);

        // 가상 스레드로 유사한 패턴 구현
        System.out.println("[가상 스레드로 유사 패턴 구현]:");

        try (ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor()) {
            // 두 개의 동시 작업 실행
            Future<String> userFuture = executor.submit(() -> {
                Thread.sleep(100);
                return "User: John Doe";
            });

            Future<String> orderFuture = executor.submit(() -> {
                Thread.sleep(150);
                return "Order: #12345";
            });

            // 두 작업 모두 완료 대기
            String user = userFuture.get();
            String order = orderFuture.get();

            System.out.println("  - " + user);
            System.out.println("  - " + order);
        }

        System.out.println();
    }

    // ============================================================
    // 6. 가상 스레드 사용 시 주의사항
    // ============================================================

    /**
     * 가상 스레드 사용 시 알아야 할 주의사항과 안티패턴
     */
    private static void virtualThreadCautions() {
        System.out.println("6. 가상 스레드 사용 시 주의사항");
        System.out.println("-".repeat(50));

        System.out.println("\n[주의사항 1] synchronized 블록 내 blocking 피하기");
        System.out.println("  - synchronized 블록 내에서 I/O 작업 시 carrier thread가 pinning됨");
        System.out.println("  - 해결책: ReentrantLock 사용");
        System.out.println("""
            // 나쁜 예시
            synchronized (lock) {
                Thread.sleep(1000); // carrier thread pinning!
            }

            // 좋은 예시
            private final ReentrantLock lock = new ReentrantLock();
            lock.lock();
            try {
                Thread.sleep(1000); // OK - lock 해제 후 unmount 가능
            } finally {
                lock.unlock();
            }
            """);

        System.out.println("[주의사항 2] ThreadLocal 사용 최소화");
        System.out.println("  - 수백만 가상 스레드에서 ThreadLocal 사용 시 메모리 문제");
        System.out.println("  - 해결책: ScopedValue (Java 21 Preview) 사용 고려");

        System.out.println("\n[주의사항 3] CPU-bound 작업에는 부적합");
        System.out.println("  - 가상 스레드는 I/O-bound 작업에 최적화");
        System.out.println("  - CPU-bound 작업: 플랫폼 스레드 또는 ForkJoinPool 사용");

        System.out.println("\n[주의사항 4] 풀링하지 말 것");
        System.out.println("  - 가상 스레드는 생성 비용이 매우 저렴");
        System.out.println("  - 풀링은 불필요하며 오히려 복잡성만 증가");
        System.out.println("  - 작업마다 새 가상 스레드 생성이 권장 패턴");

        System.out.println("\n[학습 포인트]");
        System.out.println("  1. 가상 스레드는 I/O-bound 동시성 작업에 최적");
        System.out.println("  2. Thread.ofVirtual() 또는 Executors.newVirtualThreadPerTaskExecutor() 사용");
        System.out.println("  3. synchronized 대신 ReentrantLock 사용 권장");
        System.out.println("  4. 풀링하지 말고 작업마다 새로 생성");
        System.out.println("  5. CPU-bound 작업에는 플랫폼 스레드 사용");
    }
}

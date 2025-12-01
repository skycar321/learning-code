package java;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

/**
 * Step 8: 동시성 처리 (Concurrency)
 *
 * <p>동시성 처리는 여러 스레드가 동시에 실행될 때 발생하는 문제들을 올바르게 해결하고 성능을 최적화하는 방법을 다룹니다.</p>
 * <p>{@code synchronized} 키워드의 한계를 이해하고, {@code java.util.concurrent} 패키지의 {@code ExecutorService}나 {@code Lock} 등을 사용한 현대적인 동시성 처리 방법을 학습합니다.</p>
 * <p>{@code volatile}, {@code Atomic} 클래스, {@code CompletableFuture} 등도 다룰 수 있습니다.</p>
 */
public class Step8_Concurrency {

    /**
     * 나쁜 예시: {@code synchronized} 블록 없이 여러 스레드에서 공유 변수를 직접 수정
     *
     * <p>설명: 이 예시에서는 여러 스레드가 동시에 {@code sharedCounter} 변수를 증가시킵니다.</p>
     * <p>{@code synchronized} 키워드나 {@code Lock}을 사용하지 않기 때문에, 증감 연산이 원자적(atomic)으로 이루어지지 않아 경쟁 조건(Race Condition)이 발생합니다.</p>
     * <p>결과적으로 최종 {@code sharedCounter} 값은 예상치 못한, 일관되지 않은 값을 가지게 됩니다.</p>
     */
    private static class BadCounter {
        private int sharedCounter = 0;

        public void increment() {
            sharedCounter++;
        }

        public int getSharedCounter() {
            return sharedCounter;
        }

        public void runBadExample() throws InterruptedException {
            System.out.println("--- Bad Example: Unsafe Counter ---");
            sharedCounter = 0; // Reset for demonstration
            ExecutorService service = Executors.newFixedThreadPool(10);

            for (int i = 0; i < 1000; i++) {
                service.submit(this::increment);
            }

            service.shutdown();
            service.awaitTermination(1, TimeUnit.MINUTES);

            // 예상보다 작은 값이 출력될 가능성이 높음
            System.out.println("Final Shared Counter (Bad): " + sharedCounter);
            System.out.println("Expected: 1000. Actual: " + sharedCounter + " (Likely incorrect due to race condition)");
            System.out.println("------------------------------------");
        }
    }

    /**
     * 좋은 예시 1: {@code AtomicInteger}를 사용한 안전한 카운터
     *
     * <p>설명: {@code AtomicInteger}는 내부적으로 CAS(Compare-And-Swap) 연산을 사용하여 스레드 안전성을 보장합니다.</p>
     * <p>별도의 명시적인 락(lock) 메커니즘 없이도 원자적인 연산이 가능하여 경쟁 조건을 방지하고 정확한 결과를 얻을 수 있습니다.</p>
     * <p>성능 면에서도 {@code synchronized} 블록보다 우수할 수 있습니다.</p>
     */
    private static class GoodCounterAtomic {
        private final AtomicInteger sharedCounter = new AtomicInteger(0);

        public void increment() {
            sharedCounter.incrementAndGet();
        }

        public int getSharedCounter() {
            return sharedCounter.get();
        }

        public void runGoodExample() throws InterruptedException {
            System.out.println("--- Good Example 1: AtomicInteger ---");
            sharedCounter.set(0); // Reset for demonstration
            ExecutorService service = Executors.newFixedThreadPool(10);

            for (int i = 0; i < 1000; i++) {
                service.submit(this::increment);
            }

            service.shutdown();
            service.awaitTermination(1, TimeUnit.MINUTES);

            // 항상 1000이 출력됨
            System.out.println("Final Shared Counter (Good - Atomic): " + sharedCounter.get());
            System.out.println("Expected: 1000. Actual: " + sharedCounter.get() + " (Correct)");
            System.out.println("---------------------------------------");
        }
    }

    /**
     * 좋은 예시 2: {@code ReentrantLock}을 사용한 안전한 카운터
     *
     * <p>설명: {@code ReentrantLock}은 {@code synchronized} 키워드보다 더 유연하고 정교한 락킹 메커니즘을 제공합니다.</p>
     * <p>명시적으로 {@code lock()}과 {@code unlock()}을 호출하여 임계 영역(Critical Section)을 보호하며, 락 획득 시도 및 타임아웃 설정 등 다양한 기능을 제공합니다.</p>
     * <p>{@code finally} 블록에서 {@code unlock()}을 호출하여 락이 항상 해제되도록 하는 것이 중요합니다.</p>
     */
    private static class GoodCounterLock {
        private int sharedCounter = 0;
        private final Lock lock = new ReentrantLock();

        public void increment() {
            lock.lock(); // 락 획득
            try {
                sharedCounter++;
            } finally {
                lock.unlock(); // 락 해제 (항상 해제되도록 finally 블록에 위치)
            }
        }

        public int getSharedCounter() {
            lock.lock(); // 읽기 작업도 보호해야 함
            try {
                return sharedCounter;
            } finally {
                lock.unlock();
            }
        }

        public void runGoodExample() throws InterruptedException {
            System.out.println("--- Good Example 2: ReentrantLock ---");
            sharedCounter = 0; // Reset for demonstration
            ExecutorService service = Executors.newFixedThreadPool(10);

            for (int i = 0; i < 1000; i++) {
                service.submit(this::increment);
            }

            service.shutdown();
            service.awaitTermination(1, TimeUnit.MINUTES);

            // 항상 1000이 출력됨
            System.out.println("Final Shared Counter (Good - Lock): " + getSharedCounter());
            System.out.println("Expected: 1000. Actual: " + getSharedCounter() + " (Correct)");
            System.out.println("---------------------------------------");
        }
    }

    /**
     * 메인 메소드: 동시성 처리의 나쁜 예시와 좋은 예시를 실행합니다.
     *
     * @param args 커맨드 라인 인자 (사용되지 않음)
     * @throws InterruptedException 스레드 실행 중 인터럽트 발생 시
     */
    public static void main(String[] args) throws InterruptedException {
        // 나쁜 예시 실행
        new BadCounter().runBadExample();

        // 좋은 예시 1 실행 (AtomicInteger)
        new GoodCounterAtomic().runGoodExample();

        // 좋은 예시 2 실행 (ReentrantLock)
        new GoodCounterLock().runGoodExample();
    }
}
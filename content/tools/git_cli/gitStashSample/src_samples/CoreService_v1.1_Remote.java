import java.time.LocalDateTime;
import java.util.UUID;

// [원격 Dev v1.1] 동료가 수정한 최신 클래스 정의 (AutoCloseable 구현)
public class CoreService implements AutoCloseable {
    private static final String SERVICE_VERSION = "1.1";
    private final UUID instanceId = UUID.randomUUID();
    private int retryLimit = 2;
    private LocalDateTime lastRunAt = LocalDateTime.now();

    public void processData() {
        System.out.println("Basic Data Processing");
        // Initialization code
    }

    public void commonUtil() {
        // [원격 Dev v1.1] 동료가 성능을 개선한 코드
        System.out.println("Common Util v1.1 (Performance Improved)");
        System.out.println("[v1.1] Cache warmed");
    }

    public String getInstanceId() {
        return instanceId.toString();
    }

    public void archiveData() {
        System.out.println("[v1.1] Archiving daily data at " + lastRunAt);
        System.out.println("[v1.1] retryLimit=" + retryLimit);
    }
    
    @Override
    public void close() {
        System.out.println("Closing resources...");
    }
} 

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Locale;
import java.util.UUID;

// [통합 완료] 동료의 AutoCloseable과 내 Runnable을 모두 구현
public class CoreService implements AutoCloseable, Runnable {
    private static final String SERVICE_VERSION = "1.1"; // 버전은 최신으로
    private final UUID instanceId = UUID.randomUUID();
    private int retryLimit = 2; // 동료 설정 따름
    private LocalDateTime lastRunAt = LocalDateTime.now();
    private boolean debugEnabled = true; // 내 설정 유지

    public void processData() {
        System.out.println("Basic Data Processing");
    }

    // [SR1 예정] 이 메서드는 SR1 브랜치로 갑니다.
    public void preProcess() {
        System.out.println("[SR1] Pre-processing Logic Added");
        System.out.println("[SR1] Locale=" + Locale.getDefault());
    }

    // [CommonUtil 통합] 동료 성능개선 + 내 로그 합침
    public void commonUtil() {
        System.out.println("Common Util v1.1 (Performance Improved)");
        System.out.println("[v1.1] Cache warmed");
        System.out.println("[SR1] Extra diagnostics enabled");
    }

    // [동료 메서드들] 원격 v1.1 기능 유지
    public String getInstanceId() { return instanceId.toString(); }
    public void archiveData() {
        System.out.println("[v1.1] Archiving daily data at " + lastRunAt);
    }
    public void close() { System.out.println("Closing resources..."); }

    // [SR2 예정] 이 메서드는 나중에 SR2 브랜치로 갑니다.
    public void createReport() {
        System.out.println("[SR2] Generating PDF Report for " + LocalDate.now());
    }
    public void run() { System.out.println("Running service..."); }
}

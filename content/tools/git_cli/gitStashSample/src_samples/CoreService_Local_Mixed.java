import java.time.LocalDate;
import java.util.Locale;

// [내 로컬 v1.0] 나는 아직 구버전 기반에서 작업 중입니다 (Runnable 구현)
public class CoreService implements Runnable {
    private static final String SERVICE_VERSION = "1.0-SR";
    private int retryLimit = 5;
    private boolean debugEnabled = true;

    public void processData() {
        System.out.println("Basic Data Processing");
        // Initialization code
    }

    // [SR1 예정] 이 부분은 나중에 SR1 브랜치로 커밋해야 합니다.
    public void preProcess() {
        System.out.println("[SR1] Pre-processing Logic Added");
        System.out.println("[SR1] Locale=" + Locale.getDefault());
    }

    public void commonUtil() {
        // [내 로컬 v1.0] 나는 아직 구버전 코드를 가지고 있습니다.
        System.out.println("Common Util v1.0");
        System.out.println("[SR1] Extra diagnostics enabled"); // SR1에서 추가한 로그
    }

    // [SR2 예정] 이 부분은 나중에 SR2 브랜치로 커밋해야 합니다.
    public void createReport() {
        System.out.println("[SR2] Generating PDF Report for " + LocalDate.now());
    }
    
    @Override
    public void run() {
        System.out.println("Running service...");
    }
} 

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Scanner;

/**
 * <h1>실무 Java 학습: 5단계 - 예외 처리</h1>
 *
 * <h2>학습 목표</h2>
 * <ul>
 *     <li>포괄적인 `Exception`으로 모든 예외를 한 번에 처리하는 방식의 문제점을 이해합니다.</li>
 *     <li>구체적인 예외 타입을 `catch`하여, 각 상황에 맞는 적절한 복구 로직을 구현하는 방법의 중요성을 배웁니다.</li>
 *     <li>`try-catch` 블록을 구조화하여 코드의 안정성과 가독성을 높이는 방법을 익힙니다.</li>
 * </ul>
 *
 * @author Gemini
 */
public class Step5_ExceptionHandling {

    /**
     * <h3>나쁜 예시: 모든 예외를 `Exception`으로 뭉뚱그려 처리</h3>
     * <p>편리해 보일 수 있지만, 실제로는 오류의 원인을 파악하기 어렵게 만들고 적절한 대응을 불가능하게 하는 위험한 방식입니다.</p>
     * <h4>언제 이런 코드를 마주하는가?</h4>
     * <ul>
     *     <li>귀찮아서 예외 처리를 소홀히 할 때</li>
     *     <li>어떤 예외가 발생할지 예측하지 않고 '안전하게' 모든 것을 잡으려고 할 때</li>
     * </ul>
     */
    public static class BadExample {
        public void processFile(String filePath) {
            System.out.println("나쁜 예시 실행:");
            File file = new File(filePath);
            try {
                Scanner scanner = new Scanner(file);
                while (scanner.hasNextLine()) {
                    System.out.println(scanner.nextLine());
                }
                scanner.close();
            } catch (Exception e) {
                // 왜 나쁜가?
                // 1. 원인 불명: 이 블록으로 들어온 예외가 '파일이 없어서'인지, '파일 읽기 권한이 없어서'인지,
                //    '디스크에 오류가 생겨서'인지, 아니면 전혀 다른 'NullPointerException'인지 알 수 없습니다.
                // 2. 부적절한 대응: 모든 오류에 대해 "알 수 없는 오류"라는 동일한 메시지만 보여주므로,
                //    사용자는 무엇을 해야 할지 알 수 없으며, 개발자도 로그만 보고는 원인을 추적하기 어렵습니다.
                // 3. 복구 불가능: 오류의 종류를 모르기 때문에, '파일을 다시 만들도록 유도'하거나 '권한을 요청'하는 등의
                //    상황에 맞는 복구 로직을 구현할 수 없습니다.
                System.err.println("파일 처리 중 알 수 없는 오류가 발생했습니다: " + e.getMessage());
            }
            System.out.println("----------------------------------------");
        }
    }

    /**
     * <h3>좋은 예시: 구체적인 예외 타입을 순서대로 처리</h3>
     * <p>발생할 가능성이 있는 예외들을 구체적으로 명시하고, 각각에 맞는 처리 로직을 구현하는 방식입니다.</p>
     * <h4>왜, 언제 이렇게 사용해야 하는가?</h4>
     * <ul>
     *     <li><b>이유:</b> 코드 자체가 어떤 오류가 발생할 수 있는지를 알려주는 문서 역할을 합니다. 각 오류 상황에 맞춰 사용자에게 더 친절한 안내를 하거나,
     *         시스템이 자동으로 복구 시도를 하는 등 정교한 제어가 가능해져 프로그램의 안정성이 크게 향상됩니다.</li>
     *     <li><b>상황:</b> 예외 발생 가능성이 있는 모든 코드, 특히 파일 I/O, 네트워크 통신, 데이터베이스 접근 등 외부 시스템과 연동하는 부분에서 필수적입니다.</li>
     * </ul>
     */
    public static class GoodExample {
        public void processFile(String filePath) {
            System.out.println("좋은 예시 실행:");
            File file = new File(filePath);
            try {
                Scanner scanner = new Scanner(file);
                while (scanner.hasNextLine()) {
                    System.out.println(scanner.nextLine());
                }
                scanner.close();
            // catch 블록은 순서가 중요합니다. 더 구체적인(자식 클래스) 예외부터 잡아야 합니다.
            } catch (FileNotFoundException e) {
                // 파일이 존재하지 않는 매우 구체적인 상황에 대한 처리
                System.err.println("파일을 찾을 수 없습니다. 경로를 확인해주세요: " + filePath);
                // 여기에 기본 설정 파일을 생성하는 등의 복구 로직을 추가할 수 있습니다.
            } catch (IOException e) {
                // 파일을 읽는 도중 발생할 수 있는 모든 입출력 오류에 대한 처리
                System.err.println("파일을 읽는 중 오류가 발생했습니다. 파일 권한이나 디스크 상태를 확인해주세요: " + e.getMessage());
            } catch (Exception e) {
                // 위에서 잡지 못한, 예상치 못한 다른 모든 예외에 대한 최후의 방어선입니다.
                // 이 블록이 실행된다면 개발자가 예측하지 못한 새로운 문제가 발생했다는 신호일 수 있습니다.
                System.err.println("예상치 못한 오류가 발생했습니다. 관리자에게 문의해주세요: " + e.getMessage());
            }
            System.out.println("========================================");
        }
    }

    public static void main(String[] args) {
        System.out.println("### 5단계: 예외 처리 학습 ###\n");
        
        String nonExistingFilePath = "non_existing_file.txt";

        BadExample badExample = new BadExample();
        // 원인은 '파일이 없음'이지만, 출력은 '알 수 없는 오류'로 나옵니다.
        badExample.processFile(nonExistingFilePath);

        GoodExample goodExample = new GoodExample();
        // 원인에 맞는 '파일을 찾을 수 없습니다'라는 명확한 메시지가 출력됩니다.
        goodExample.processFile(nonExistingFilePath);

        System.out.println("\n학습 결론: 예외 처리는 `try-catch`를 쓰는 것에서 그치지 않고, 발생할 수 있는 예외를 구체적으로 나누어 각각의 상황에 맞게 처리하는 것이 중요합니다. 이는 안정적이고 유지보수하기 좋은 소프트웨어를 만드는 핵심 요소입니다.");
    }
}

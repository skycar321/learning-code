/**
 * <h1>실무 Java 학습: 1단계 - 변수와 상수</h1>
 *
 * <h2>학습 목표</h2>
 * <ul>
 *     <li>'매직 넘버(Magic Number)'의 문제점을 이해합니다.</li>
 *     <li>의미 있는 이름의 상수를 사용하여 코드의 가독성과 유지보수성을 높이는 방법을 배웁니다.</li>
 *     <li>Java에서 상수를 선언하는 표준적인 방법을 익힙니다.</li>
 * </ul>
 *
 * @author Gemini
 */
public class Step1_VariablesAndConstants {

    /**
     * <h3>나쁜 예시: 매직 넘버 사용</h3>
     * <p>코드 내에 프로그래머만 아는 의미를 가진 숫자(매직 넘버)를 직접 사용하는 방식입니다.</p>
     * <h4>언제 이런 코드를 마주하는가?</h4>
     * <ul>
     *     <li>빠른 프로토타이핑 과정에서</li>
     *     <li>코드 작성 규칙이 없는 팀에서</li>
     *     <li>상수 관리의 중요성을 간과했을 때</li>
     * </ul>
     */
    public static class BadExample {
        public void process() {
            System.out.println("나쁜 예시 실행:");

            // 왜 나쁜가?
            // 1. 가독성 저하: `86400`이라는 숫자가 '하루의 초'라는 것을 즉시 알 수 없습니다.
            //    코드를 읽는 사람은 이 숫자의 의미를 파악하기 위해 추가적인 시간을 소모해야 합니다.
            // 2. 유지보수성 저하: 만약 '하루'의 기준이 바뀌거나 이 숫자가 여러 곳에서 사용된다면,
            //    모든 곳을 찾아서 일일이 수정해야 합니다. 하나라도 놓치면 버그가 됩니다.
            long dailyMilliseconds = 86400 * 1000;
            System.out.println("하루는 " + dailyMilliseconds + " 밀리초입니다.");
            System.out.println("----------------------------------------");
        }
    }

    /**
     * <h3>좋은 예시: 의미 있는 상수 사용</h3>
     * <p>숫자에 구체적인 의미를 부여하는 상수로 정의하여 사용하는 방식입니다.</p>
     * <h4>왜, 언제 이렇게 사용해야 하는가?</h4>
     * <ul>
     *     <li><b>이유:</b> 코드 자체가 문서가 되어(Self-documenting) 가독성이 향상되고, 값의 변경이 필요할 때 한 곳만 수정하면 되므로 유지보수성이 극대화됩니다.</li>
     *     <li><b>상황:</b> 코드에서 한 번 이상 사용되는 고정값, 혹은 의미를 명확히 해야 할 필요가 있는 모든 값에 적용해야 합니다.</li>
     * </ul>
     */
    public static class GoodExample {
        // 상수는 `public static final`로 선언하며, 이름은 관례적으로 대문자와 언더스코어(_)를 사용합니다.
        // public: 어디서든 접근 가능
        // static: 인스턴스 없이 클래스 레벨에서 접근 가능
        // final: 값이 변경될 수 없음
        public static final int SECONDS_PER_MINUTE = 60;
        public static final int MINUTES_PER_HOUR = 60;
        public static final int HOURS_PER_DAY = 24;

        // 다른 상수들을 조합하여 새로운 상수를 만들 수도 있어, 로직의 명확성을 더욱 높입니다.
        public static final int SECONDS_PER_DAY = SECONDS_PER_MINUTE * MINUTES_PER_HOUR * HOURS_PER_DAY;

        public void process() {
            System.out.println("좋은 예시 실행:");

            // `SECONDS_PER_DAY`라는 이름만으로도 이 변수가 '하루의 초'를 다룬다는 것을 명확히 알 수 있습니다.
            long dailyMilliseconds = SECONDS_PER_DAY * 1000L; // long 타입과의 연산을 위해 'L' 접미사 사용
            System.out.println("하루는 " + dailyMilliseconds + " 밀리초입니다.");
            System.out.println("========================================");
        }
    }

    public static void main(String[] args) {
        System.out.println("### 1단계: 변수와 상수 학습 ###\n");

        BadExample badExample = new BadExample();
        badExample.process();

        GoodExample goodExample = new GoodExample();
        goodExample.process();

        System.out.println("학습 결론: 코드에 직접 숫자를 쓰는 '매직 넘버'는 가독성과 유지보수성을 해치는 주범입니다. 항상 의미 있는 이름의 상수로 대체하는 습관을 들여야 합니다.");
    }
}

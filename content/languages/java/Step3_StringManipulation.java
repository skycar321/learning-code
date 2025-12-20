/**
 * <h1>실무 Java 학습: 3단계 - 문자열 처리</h1>
 *
 * <h2>학습 목표</h2>
 * <ul>
 *     <li>Java의 `String` 객체가 불변(immutable)이라는 특성을 이해합니다.</li>
 *     <li>반복문 안에서 `+` 연산자로 문자열을 합치는 것이 왜 비효율적인지 원리를 파악합니다.</li>
 *     <li>가변(mutable) 문자열을 다루는 `StringBuilder`를 사용하여 문자열을 효율적으로 조합하는 방법을 익힙니다.</li>
 * </ul>
 *
 * @author Gemini
 */
public class Step3_StringManipulation {

    /**
     * <h3>나쁜 예시: 반복문 안에서 '+' 연산자로 문자열 연결</h3>
     * <p>편리함 때문에 자주 사용되지만, 반복문 안에서는 심각한 성능 저하를 유발할 수 있는 방식입니다.</p>
     * <h4>언제 이런 코드를 마주하는가?</h4>
     * <ul>
     *     <li>Java의 문자열 처리 메커니즘에 대한 이해가 부족할 때</li>
     *     <li>적은 수의 문자열을 합칠 때의 습관을 많은 데이터를 처리하는 곳에도 그대로 적용할 때</li>
     * </ul>
     */
    public static class BadExample {
        public void process() {
            System.out.println("나쁜 예시 실행:");
            String result = "";
            String[] items = {"Java", "is", "a", "powerful", "language"};

            long startTime = System.nanoTime();
            for (String item : items) {
                // 왜 나쁜가?
                // 1. String의 불변성(Immutability): Java의 String 객체는 한 번 생성되면 그 내용을 바꿀 수 없습니다.
                // 2. 불필요한 객체 생성: `result += item + " "` 코드가 실행될 때마다,
                //    기존 `result`의 내용과 `item`, 그리고 " "가 합쳐진 '새로운' String 객체가 메모리에 생성됩니다.
                //    이전 `result` 객체는 버려지고 가비지 컬렉션의 대상이 됩니다.
                // 3. 성능 저하: 이 반복문은 5번 돌지만, 그 과정에서 총 5개의 중간 결과 String 객체가 생성되고 버려집니다.
                //    만약 반복 횟수가 수천, 수만 번이 된다면 이는 심각한 메모리 낭비와 성능 저하로 이어집니다.
                result += item + " ";
            }
            long endTime = System.nanoTime();

            System.out.println("결과: " + result);
            System.out.println("소요 시간: " + (endTime - startTime) + " ns");
            System.out.println("----------------------------------------");
        }
    }

    /**
     * <h3>좋은 예시: `StringBuilder`를 사용한 효율적인 문자열 조합</h3>
     * <p>문자열을 여러 번 수정하거나 조합해야 할 때 사용하는 표준적인 방식입니다.</p>
     * <h4>왜, 언제 이렇게 사용해야 하는가?</h4>
     * <ul>
     *     <li><b>이유:</b> `StringBuilder`는 내부적으로 가변적인 문자 배열(버퍼)을 가지고 있습니다. `append` 메소드는 이 버퍼의 내용을 직접 수정하므로,
     *         매번 새로운 객체를 생성하지 않아 매우 빠르고 효율적입니다.</li>
     *     <li><b>상황:</b> 반복문 안에서 문자열을 조합하거나, 조건에 따라 문자열을 동적으로 구성해야 하는 모든 경우에 사용해야 합니다.</li>
     * </ul>
     */
    public static class GoodExample {
        public void process() {
            System.out.println("좋은 예시 실행:");
            // 1. 처음에 적절한 크기의 내부 버퍼를 가진 StringBuilder 객체를 하나만 생성합니다.
            StringBuilder sb = new StringBuilder();
            String[] items = {"Java", "is", "a", "powerful", "language"};

            long startTime = System.nanoTime();
            for (String item : items) {
                // 2. append 메소드는 새로운 객체를 만들지 않고, 내부 버퍼에 문자열을 계속 추가합니다.
                sb.append(item).append(" ");
            }
            long endTime = System.nanoTime();

            // 3. 모든 조합이 끝난 후, `toString()` 메소드를 호출하여 최종적으로 하나의 String 객체만 생성합니다.
            String result = sb.toString();

            System.out.println("결과: " + result);
            System.out.println("소요 시간: " + (endTime - startTime) + " ns");
            System.out.println("========================================");
        }
    }

    public static void main(String[] args) {
        System.out.println("### 3단계: 문자열 처리 학습 ###\n");

        BadExample badExample = new BadExample();
        badExample.process();

        GoodExample goodExample = new GoodExample();
        goodExample.process();

        System.out.println("학습 결론: 반복적으로 문자열을 변경하거나 추가해야 할 때는 반드시 `StringBuilder`를 사용해야 합니다.");
        System.out.println("(참고: `StringBuffer`는 멀티스레드 환경에서 안전(thread-safe)하지만, 동기화 오버헤드 때문에 단일 스레드 환경에서는 `StringBuilder`가 더 빠릅니다.)");
    }
}

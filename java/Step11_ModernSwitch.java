package java;

/**
 * <h1>실무 Java 학습: 11단계 - 새로운 `switch` 표현식 (Modern Switch - Java 14+)</h1>
 *
 * <h2>학습 목표</h2>
 * <ul>
 *     <li>기존 `switch` 문의 문제점(fall-through, 가독성 저하)을 이해합니다.</li>
 *     <li>Java 14+에 도입된 새로운 `switch` 표현식의 문법(화살표 `->`, `yield`)과 장점을 배웁니다.</li>
 *     <li>`switch` 표현식을 사용하여 코드를 더 간결하고 안전하게 만드는 방법을 익힙니다.</li>
 * </ul>
 *
 * @author Gemini
 */
public class Step11_ModernSwitch {

    /**
     * <h3>나쁜 예시: 기존 `switch` 문 사용</h3>
     * <p>Java 12 이전의 `switch` 문은 `fall-through` 특성 때문에 `break` 문을 실수로 누락하면
     * 예상치 못한 버그를 유발할 수 있으며, 여러 케이스가 동일한 로직을 공유할 때 가독성이 떨어집니다.</p>
     */
    public static class BadExample {
        public String getDayType(int dayOfWeek) {
            System.out.println("나쁜 예시 실행: 기존 switch 문");
            String dayType;
            // 왜 나쁜가?
            // 1. fall-through: 각 case 끝에 break를 명시적으로 써주지 않으면,
            //    다음 case로 실행 흐름이 이어집니다. 이는 흔한 버그의 원인입니다.
            // 2. 가독성 저하: 각 case마다 동일한 로직을 수행하는 경우에도 중복 코드가 발생하거나,
            //    break를 빠뜨리지 않기 위해 주의를 기울여야 합니다.
            // 3. 표현식이 아님: switch 문은 특정 값을 '생산'하는 표현식이 아니라, '실행'하는 문장입니다.
            //    따라서 값을 할당받기 위해 외부 변수를 선언하고 각 case에서 할당하는 방식을 사용해야 합니다.
            switch (dayOfWeek) {
                case 1:
                    dayType = "주말";
                    break;
                case 2:
                case 3:
                case 4:
                case 5:
                case 6:
                    dayType = "평일";
                    break;
                case 7:
                    dayType = "주말";
                    break;
                default:
                    dayType = "알 수 없음";
                    break;
            }
            System.out.println("요일 (" + dayOfWeek + "): " + dayType);
            System.out.println("----------------------------------------");
            return dayType;
        }

        public void process() {
            getDayType(1); // 일요일
            getDayType(3); // 화요일
            getDayType(7); // 토요일
            getDayType(9); // 잘못된 요일
        }
    }

    /**
     * <h3>좋은 예시: 새로운 `switch` 표현식 (Java 14+) 사용</h3>
     * <p>Java 14부터 표준화된 `switch` 표현식은 `->` 화살표 문법과 `yield` 키워드를 도입하여
     * 기존 `switch` 문의 문제점을 해결하고, 코드를 더욱 간결하고 안전하게 만듭니다.</p>
     * <h4>왜, 언제 이렇게 사용해야 하는가?</h4>
     * <ul>
     *     <li><b>이유:</b> `fall-through`가 기본적으로 없어 `break` 누락으로 인한 버그를 방지합니다.
     *         여러 케이스를 콤마로 묶어 처리할 수 있어 가독성이 높습니다.
     *         값을 직접 반환하는 표현식(expression)으로 사용할 수 있어 간결합니다.</li>
     *     <li><b>상황:</b> 특정 입력 값에 따라 다른 값을 계산하거나 반환해야 하는 모든 상황에서
     *         기존 `if-else if` 체인이나 `switch` 문을 대체하여 사용할 수 있습니다.</li>
     * </ul>
     */
    public static class GoodExample {
        public String getDayType(int dayOfWeek) {
            System.out.println("좋은 예시 실행: 새로운 switch 표현식");
            String dayType = switch (dayOfWeek) {
                // 1. 화살표(->) 문법: 해당 case에서 하나의 표현식 또는 블록을 실행하고 값을 반환합니다.
                //    break를 명시적으로 작성할 필요 없이, 자동으로 해당 case만 실행됩니다.
                case 1, 7 -> "주말"; // 여러 case를 콤마로 묶어 한 번에 처리
                case 2, 3, 4, 5, 6 -> "평일";
                // 2. yield 키워드: switch 표현식 내에서 복잡한 로직을 수행한 후 값을 반환할 때 사용합니다.
                //    break 대신 switch 표현식의 결과 값을 지정합니다.
                default -> {
                    System.out.println("경고: 유효하지 않은 요일 번호입니다: " + dayOfWeek);
                    yield "알 수 없음";
                }
            };
            System.out.println("요일 (" + dayOfWeek + "): " + dayType);
            System.out.println("========================================");
            return dayType;
        }

        public void process() {
            getDayType(1);
            getDayType(3);
            getDayType(7);
            getDayType(9);
        }
    }

    public static void main(String[] args) {
        System.out.println("### 11단계: 새로운 `switch` 표현식 학습 ###\n");

        BadExample badExample = new BadExample();
        badExample.process();

        GoodExample goodExample = new GoodExample();
        goodExample.process();

        System.out.println("학습 결론: Java 14+를 사용한다면, `switch` 문을 대체하는 `switch` 표현식을 적극적으로 활용하여 더 안전하고 간결하며 가독성 높은 코드를 작성할 수 있습니다. `fall-through` 버그를 원천적으로 방지하고 코드를 '표현식'으로 다룰 수 있게 됩니다.");
    }
}

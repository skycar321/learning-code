import java.util.Optional;

/**
 * <h1>실무 Java 학습: 2단계 - Null 처리</h1>
 *
 * <h2>학습 목표</h2>
 * <ul>
 *     <li>`NullPointerException` (NPE)의 위험성과 방어적인 `null` 체크의 번거로움을 이해합니다.</li>
 *     <li>Java 8에 도입된 `Optional<T>`을 사용하여 '값이 없을 수 있음'을 타입 시스템에 명시적으로 표현하는 방법을 배웁니다.</li>
 *     <li>`ifPresent`, `orElse`, `orElseThrow` 등 `Optional`의 다양한 API를 활용하여 안전하고 가독성 높은 코드를 작성합니다.</li>
 * </ul>
 *
 * @author Gemini
 */
public class Step2_NullHandling {

    static class User {
        private final String name;

        public User(String name) {
            this.name = name;
        }

        public String getName() {
            return name;
        }
    }

    /**
     * <h3>나쁜 예시: 반복적인 null 체크</h3>
     * <p>과거의 Java 코드에서 흔히 볼 수 있는 방식으로, 메소드가 `null`을 반환할 가능성이 있을 때마다
     * 호출하는 쪽에서 `if (obj != null)` 구문을 사용하여 방어적으로 코딩해야 합니다.</p>
     * <h4>언제 이런 코드를 마주하는가?</h4>
     * <ul>
     *     <li>Java 8 이전의 레거시 코드</li>
     *     <li>`Optional`의 개념이 익숙하지 않은 개발자가 작성한 코드</li>
     * </ul>
     */
    public static class BadExample {
        public User findUser(String name) {
            // 실제로는 데이터베이스 조회 등이 들어갈 위치
            if ("test".equals(name)) {
                return new User("테스트 유저");
            }
            return null; // 사용자가 없으면 '값이 없음'을 의미하기 위해 null을 반환
        }

        public void process() {
            System.out.println("나쁜 예시 실행:");
            User user = findUser("test");

            // 왜 나쁜가?
            // 1. NPE 위험: 만약 `if (user != null)` 체크를 실수로 빠뜨리면, `user.getName()` 호출 시 NullPointerException이 발생합니다.
            //    이러한 실수는 컴파일 시점에는 발견되지 않고, 런타임에만 드러납니다.
            // 2. 가독성 저하: 코드 곳곳에 null 체크 로직이 반복되어 비즈니스 로직의 흐름을 파악하기 어렵게 만듭니다.
            // 3. 계약의 불분명함: `findUser` 메소드의 시그니처만 봐서는 이 메소드가 null을 반환할 수 있는지 아닌지 알 수 없습니다.
            if (user != null) {
                System.out.println("사용자 이름: " + user.getName());
            } else {
                System.out.println("사용자를 찾을 수 없습니다.");
            }

            User user2 = findUser("unknown");
            if (user2 != null) {
                System.out.println("사용자 이름: " + user2.getName());
            } else {
                System.out.println("사용자를 찾을 수 없습니다.");
            }
            System.out.println("----------------------------------------");
        }
    }

    /**
     * <h3>좋은 예시: `Optional<T>`을 사용한 명시적인 값 처리</h3>
     * <p>`Optional`은 '값이 존재하지 않을 수 있음'을 타입 자체에 명시하는 Wrapper 클래스입니다.
     * 이를 통해 `null`을 직접 다루지 않고도 안전하게 값을 처리할 수 있습니다.</p>
     * <h4>왜, 언제 이렇게 사용해야 하는가?</h4>
     * <ul>
     *     <li><b>이유:</b> 컴파일러가 '값이 없을 수 있는 경우'를 인지하게 하여, 개발자가 해당 상황을 처리하도록 강제합니다. 이는 NPE를 근본적으로 방지하는 데 큰 도움이 됩니다.</li>
     *     <li><b>상황:</b> 메소드의 반환 값이 '없을 수도 있을 때' 사용하는 것이 가장 이상적입니다. (예: ID로 엔티티를 조회했지만 결과가 없는 경우)</li>
     * </ul>
     */
    public static class GoodExample {
        /**
         * @param name 찾을 사용자의 이름
         * @return Optional<User> - 사용자가 존재하면 Optional.of(user), 없으면 Optional.empty()를 반환합니다.
         *         메소드 시그니처만으로도 반환값이 없을 수 있음을 명확히 알려줍니다.
         */
        public Optional<User> findUser(String name) {
            if ("test".equals(name)) {
                return Optional.of(new User("테스트 유저")); // 값이 확실히 존재할 때 .of() 사용
            }
            return Optional.empty(); // 값이 없을 때 .empty() 사용
        }

        public void process() {
            System.out.println("좋은 예시 실행:");

            // 1. ifPresent: 값이 존재할 경우에만 특정 동작을 수행하고 싶을 때 사용합니다.
            //    전통적인 'if (user != null)' 구문을 대체합니다.
            findUser("test").ifPresent(user -> System.out.println("사용자 이름 (ifPresent): " + user.getName()));

            // 2. orElse: 값이 없을 경우, 제공된 기본값을 사용하고 싶을 때 사용합니다.
            //    null일 때 기본 객체를 할당하는 로직을 간결하게 표현합니다.
            User user2 = findUser("unknown").orElse(new User("기본 유저"));
            System.out.println("사용자 이름 (orElse): " + user2.getName());

            // 3. orElseThrow: 값이 없을 경우, 예외를 발생시키고 싶을 때 사용합니다.
            //    값이 반드시 있어야 하는 로직에서 유용합니다.
            try {
                User user3 = findUser("unknown").orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));
            } catch (IllegalArgumentException e) {
                System.out.println("예외 발생 (orElseThrow): " + e.getMessage());
            }
            System.out.println("========================================");
        }
    }

    public static void main(String[] args) {
        System.out.println("### 2단계: Null 처리 학습 ###\n");

        BadExample badExample = new BadExample();
        badExample.process();

        GoodExample goodExample = new GoodExample();
        goodExample.process();

        System.out.println("학습 결론: `Optional`은 '값이 없을 수 있음'을 타입으로 명시하여, 컴파일 시점에 안전한 코드를 작성하도록 유도합니다. 이를 통해 지긋지긋한 NullPointerException을 예방하고 코드의 의도를 명확하게 만들 수 있습니다.");
    }
}

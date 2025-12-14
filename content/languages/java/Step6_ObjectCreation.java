/**
 * <h1>실무 Java 학습: 6단계 - 객체 생성</h1>
 *
 * <h2>학습 목표</h2>
 * <ul>
 *     <li>파라미터가 많은 생성자의 문제점(일명 '점층적 생성자 패턴' 안티패턴)을 이해합니다.</li>
 *     <li>빌더 패턴(Builder Pattern)을 사용하여 복잡한 객체를 명확하고 유연하게 생성하는 방법을 배웁니다.</li>
 *     <li>메소드 체이닝을 통해 가독성 높은 객체 생성 코드를 작성하는 방법을 익힙니다.</li>
 * </ul>
 *
 * @author Gemini
 */
public class Step6_ObjectCreation {

    /**
     * 객체를 생성하기 위한 데이터 클래스입니다.
     * 필수 파라미터(name, email)와 선택 파라미터(age, address)를 가집니다.
     */
    static class User {
        private final String name;    // 필수
        private final String email;   // 필수
        private final int age;        // 선택
        private final String address; // 선택

        /**
         * <h4>나쁜 예시에서 사용되는 생성자</h4>
         * <p>선택적 파라미터를 처리하기 위해 여러 개의 생성자를 만드는 것을 '점층적 생성자 패턴(Telescoping Constructor Pattern)'이라고 하며,
         * 이는 대표적인 안티패턴입니다. 파라미터가 많아질수록 코드 관리가 어려워집니다.</p>
         * <pre>
         * public User(String name, String email) { this(name, email, 0, null); }
         * public User(String name, String email, int age) { this(name, email, age, null); }
         * public User(String name, String email, String address) { this(name, email, 0, address); }
         * </pre>
         * @param name 이름 (필수)
         * @param email 이메일 (필수)
         * @param age 나이 (선택)
         * @param address 주소 (선택)
         */
        public User(String name, String email, int age, String address) {
            this.name = name;
            this.email = email;
            this.age = age;
            this.address = address;
        }

        /**
         * <h4>빌더 패턴에서 사용되는 private 생성자</h4>
         * <p>오직 UserBuilder 클래스만이 이 생성자를 호출하여 User 객체를 생성할 수 있습니다.
         * 이를 통해 객체 생성의 일관성을 유지하고, 불완전한 상태의 객체 생성을 막습니다.</p>
         * @param builder User 객체 생성에 필요한 모든 정보를 담고 있는 빌더 객체
         */
        private User(UserBuilder builder) {
            this.name = builder.name;
            this.email = builder.email;
            this.age = builder.age;
            this.address = builder.address;
        }

        @Override
        public String toString() {
            return "User{" + "name='" + name + "'\'', email='" + email + "'\'', age=" + age + ", address='" + address + '\'' + '}' ;
        }

        /**
         * <h3>User 객체 생성을 위한 빌더 클래스</h3>
         * <p>User 클래스 내부에 static 중첩 클래스로 만들어, `User.UserBuilder` 형태로 사용합니다.</p>
         */
        public static class UserBuilder {
            // 필수 필드는 생성자에서 받도록 하여 반드시 값이 설정되도록 강제합니다.
            private final String name;
            private final String email;
            // 선택 필드는 초기값을 설정해 둡니다.
            private int age = 0;
            private String address = "주소 불명";

            /**
             * 빌더 생성자는 필수 파라미터만 받습니다.
             * @param name 이름
             * @param email 이메일
             */
            public UserBuilder(String name, String email) {
                this.name = name;
                this.email = email;
            }

            /**
             * 나이를 설정하는 메소드입니다.
             * @param age 나이
             * @return UserBuilder 자기 자신을 반환하여 메소드 체이닝(method chaining)을 가능하게 합니다.
             */
            public UserBuilder age(int age) {
                this.age = age;
                return this;
            }

            public UserBuilder address(String address) {
                this.address = address;
                return this;
            }

            /**
             * 최종적으로 User 객체를 생성하여 반환합니다.
             * @return 완성된 User 객체
             */
            public User build() {
                // 필요하다면 build() 메소드에서 파라미터들의 유효성 검사를 수행할 수도 있습니다.
                return new User(this);
            }
        }
    }


    /**
     * <h3>나쁜 예시: 파라미터가 많은 생성자 직접 호출</h3>
     * <p>파라미터가 4~5개를 넘어가면 생성자만 보고 어떤 값이 무엇을 의미하는지 파악하기 매우 어려워집니다.</p>
     */
    public static class BadExample {
        public void process() {
            System.out.println("나쁜 예시 실행:");

            // 왜 나쁜가?
            // 1. 가독성: `30`이 나이인지, `null`이 주소인지 코드만 보고 즉시 파악하기 어렵습니다.
            // 2. 실수 유발: `new User("이름", "이메일", "주소", 30)` 처럼 파라미터 순서를 실수로 바꿔도
            //    컴파일러가 잡아내지 못하는 경우가 많아, 런타임에 의도와 다른 버그를 만듭니다.
            // 3. 비유연성: 선택적 파라미터(`age`)만 설정하고 싶어도, `address` 자리에 `null`을 명시적으로 전달해야만 합니다.
            User user1 = new User("김철수", "chulsoo@example.com", 30, "서울시 강남구");
            User user2 = new User("이영희", "younghee@example.com", 0, null); // 나이와 주소를 설정하고 싶지 않을 때의 모습

            System.out.println("User 1: " + user1);
            System.out.println("User 2: " + user2);
            System.out.println("----------------------------------------");
        }
    }

    /**
     * <h3>좋은 예시: 빌더 패턴(Builder Pattern) 사용</h3>
     * <p>객체 생성 과정을 여러 단계로 나누고, 각 단계를 명명된 메소드로 표현하여 가독성과 안정성을 높이는 디자인 패턴입니다.</p>
     * <h4>왜, 언제 이렇게 사용해야 하는가?</h4>
     * <ul>
     *     <li><b>이유:</b> 어떤 필드에 어떤 값을 설정하는지 명확히 보이며, 필수 값과 선택 값을 쉽게 구분할 수 있습니다. 체인 형태의 코드는 읽기 쉽고 작성하기도 편리합니다.</li>
     *     <li><b>상황:</b> 생성자에 3개 이상의 파라미터가 필요할 때, 특히 그 중 일부가 선택 사항일 때 빌더 패턴 도입을 적극적으로 고려해야 합니다.</li>
     * </ul>
     */
    public static class GoodExample {
        public void process() {
            System.out.println("좋은 예시 실행:");

            // 장점:
            // 1. 가독성: `.name("김철수")`, `.age(30)` 처럼 각 값이 어떤 필드를 위한 것인지 명확합니다.
            // 2. 유연성: 필요한 값만 선택적으로 설정할 수 있으며, 순서에 상관없습니다.
            // 3. 안정성: 필수 값은 빌더 생성자에서 강제하므로, 객체가 불완전한 상태로 생성되는 것을 막을 수 있습니다.
            User user1 = new User.UserBuilder("김철수", "chulsoo@example.com")
                .age(30)
                .address("서울시 강남구")
                .build();

            // 나이만 설정하고 주소는 설정하지 않아도, 빌더에 정의된 기본값("주소 불명")이 사용됩니다.
            User user2 = new User.UserBuilder("이영희", "younghee@example.com")
                .age(28)
                .build();
            
            // 필수 값만으로도 객체 생성이 가능합니다.
            User user3 = new User.UserBuilder("박민준", "minjoon@example.com").build();

            System.out.println("User 1: " + user1);
            System.out.println("User 2: " + user2);
            System.out.println("User 3: " + user3);
            System.out.println("========================================");
        }
    }

    public static void main(String[] args) {
        System.out.println("### 6단계: 객체 생성 학습 ###\n");

        BadExample badExample = new BadExample();
        badExample.process();

        GoodExample goodExample = new GoodExample();
        goodExample.process();

        System.out.println("학습 결론: 객체 생성 시 파라미터가 많아 복잡해진다면, 빌더 패턴은 코드를 훨씬 더 읽기 쉽고, 안전하며, 유연하게 만들어주는 강력한 해결책입니다. (Lombok의 `@Builder` 어노테이션을 사용하면 이 패턴을 더 쉽게 구현할 수 있습니다.)");
    }
}

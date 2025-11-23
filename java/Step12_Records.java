package java;

/**
 * <h1>실무 Java 학습: 12단계 - 레코드 (Records - Java 16+)</h1>
 *
 * <h2>학습 목표</h2>
 * <ul>
 *     <li>불변(immutable) 데이터 객체를 생성할 때 발생하는 상용구(boilerplate) 코드의 문제점을 이해합니다.</li>
 *     <li>Java 16+에 도입된 `record` 키워드를 사용하여 데이터 클래스를 간결하게 정의하는 방법을 배웁니다.</li>
 *     <li>`record`가 자동으로 제공하는 `equals()`, `hashCode()`, `toString()`, 접근자 메소드의 이점을 이해하고 활용합니다.</li>
 * </ul>
 *
 * @author Gemini
 */
public class Step12_Records {

    /**
     * <h3>나쁜 예시: 불변 데이터 객체를 클래스로 정의</h3>
     * <p>Java 16 이전에는 불변 데이터 객체를 만들기 위해 많은 상용구 코드를 작성해야 했습니다.
     * 이는 코드의 양을 늘리고 가독성을 저해하며, 실수할 여지를 만듭니다.</p>
     */
    public static class BadExample {

        /**
         * 불변 데이터 객체 {@code Point}를 일반 클래스로 정의한 예시입니다.
         */
        public static final class Point { // 불변성을 위해 final 클래스로 선언
            private final int x; // 필드는 final
            private final int y; // 필드는 final

            public Point(int x, int y) { // 모든 필드를 초기화하는 생성자
                this.x = x;
                this.y = y;
            }

            // 모든 필드에 대한 getter (setter 없음)
            public int getX() {
                return x;
            }

            public int getY() {
                return y;
            }

            // equals() 메소드 오버라이딩 (x, y 값이 같으면 동일하다고 판단)
            @Override
            public boolean equals(Object o) {
                if (this == o) return true;
                if (o == null || getClass() != o.getClass()) return false;
                Point point = (Point) o;
                return x == point.x && y == point.y;
            }

            // hashCode() 메소드 오버라이딩 (equals가 true인 객체는 동일한 hashCode를 반환해야 함)
            @Override
            public int hashCode() {
                return java.util.Objects.hash(x, y);
            }

            // toString() 메소드 오버라이딩 (객체의 상태를 보기 좋게 출력)
            @Override
            public String toString() {
                return "Point{"
                       + "x=" + x +
                       ", y=" + y +
                       '}';
            }
        }

        public void process() {
            System.out.println("나쁜 예시 실행: 일반 클래스 사용");
            Point p1 = new Point(10, 20);
            Point p2 = new Point(10, 20);
            Point p3 = new Point(30, 40);

            System.out.println("p1: " + p1);
            System.out.println("p1 == p2: " + (p1 == p2)); // 참조 비교 -> false
            System.out.println("p1.equals(p2): " + p1.equals(p2)); // 값 비교 -> true (오버라이딩했으므로)
            System.out.println("p1.hashCode(): " + p1.hashCode());
            System.out.println("p2.hashCode(): " + p2.hashCode());
            System.out.println("----------------------------------------");
        }
    }

    /**
     * <h3>좋은 예시: `record` 사용 (Java 16+)</h3>
     * <p>`record`는 불변 데이터 객체를 간결하게 선언하기 위한 새로운 타입 선언입니다.
     * 필수적으로 필요한 필드만 선언하면, 컴파일러가 자동으로 생성자, 접근자(getter),
     * `equals()`, `hashCode()`, `toString()` 메소드를 생성해줍니다.</p>
     * <h4>왜, 언제 이렇게 사용해야 하는가?</h4>
     * <ul>
     *     <li><b>이유:</b> 데이터 운반 객체(DTO), 값 객체(Value Object) 등 불변 데이터 객체를 정의할 때
     *         상용구 코드를 극적으로 줄여 코드를 간결하고 명확하게 만듭니다.</li>
     *     <li><b>상황:</b> 주로 데이터를 저장하는 목적으로 사용되며, 객체의 필드가 불변해야 하고
     *         별도의 비즈니스 로직이나 상속 계층이 필요 없는 경우에 매우 유용합니다.</li>
     * </ul>
     */
    public static class GoodExample {

        /**
         * 불변 데이터 객체 {@code PointRecord}를 `record`로 정의한 예시입니다.
         * 모든 필드는 자동으로 final로 선언되며, 접근자 메소드(x(), y()),
         * equals(), hashCode(), toString()이 자동으로 생성됩니다.
         */
        public record PointRecord(int x, int y) {
            // compact constructor: 필요하다면 생성자를 간결하게 추가할 수 있습니다.
            // 보통 유효성 검사 등에 사용됩니다.
            public PointRecord {
                if (x < 0 || y < 0) {
                    throw new IllegalArgumentException("Coordinates must be non-negative");
                }
            }

            // 필요하다면 추가 메소드를 정의할 수도 있습니다.
            public double distance() {
                return Math.sqrt(x * x + y * y);
            }
        }

        public void process() {
            System.out.println("좋은 예시 실행: record 사용");
            PointRecord pr1 = new PointRecord(10, 20);
            PointRecord pr2 = new PointRecord(10, 20);
            PointRecord pr3 = new PointRecord(30, 40);

            System.out.println("pr1: " + pr1); // 자동으로 생성된 toString()
            System.out.println("pr1.x(): " + pr1.x()); // 자동으로 생성된 접근자
            System.out.println("pr1.distance(): " + pr1.distance()); // 추가된 메소드

            System.out.println("pr1 == pr2: " + (pr1 == pr2)); // 참조 비교 -> false
            System.out.println("pr1.equals(pr2): " + pr1.equals(pr2)); // 값 비교 -> true (자동 생성)
            System.out.println("pr1.hashCode(): " + pr1.hashCode());
            System.out.println("pr2.hashCode(): " + pr2.hashCode());

            try {
                new PointRecord(-1, 5); // compact constructor의 유효성 검사
            } catch (IllegalArgumentException e) {
                System.out.println("유효성 검사 예외: " + e.getMessage());
            }

            System.out.println("========================================");
        }
    }

    public static void main(String[] args) {
        System.out.println("### 12단계: 레코드 (Records) 학습 ###\n");

        BadExample badExample = new BadExample();
        badExample.process();

        GoodExample goodExample = new GoodExample();
        goodExample.process();

        System.out.println("학습 결론: Java 16 이상에서는 데이터 운반 목적으로 사용되는 불변 객체를 정의할 때 `record`를 사용하는 것이 강력히 권장됩니다. 코드의 상용구를 줄여 개발 생산성을 높이고, 가독성을 향상시키며, 객체의 목적을 명확하게 합니다.");
    }
}

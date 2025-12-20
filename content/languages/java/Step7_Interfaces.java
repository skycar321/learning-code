import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

/**
 * <h1>실무 Java 학습: 7단계 - 인터페이스와 구현체</h1>
 *
 * <h2>학습 목표</h2>
 * <ul>
 *     <li>구체적인 클래스 타입으로 변수를 선언했을 때 발생하는 문제점(낮은 유연성, 높은 결합도)을 이해합니다.</li>
 *     <li>'구현이 아닌 인터페이스에 프로그래밍하라(Program to an interface, not an implementation)'는 핵심 디자인 원칙을 배웁니다.</li>
 *     <li>인터페이스 타입을 사용하여 코드의 유연성, 확장성, 재사용성을 극대화하는 방법을 익힙니다.</li>
 * </ul>
 *
 * @author Gemini
 */
public class Step7_Interfaces {

    /**
     * <h3>나쁜 예시: 구체적인 클래스 타입으로 변수 선언</h3>
     * <p>변수와 메소드의 파라미터 타입을 `ArrayList`와 같은 구체적인 구현 클래스로 지정하는 방식입니다.</p>
     * <h4>언제 이런 코드를 마주하는가?</h4>
     * <ul>
     *     <li>초급 개발자가 컬렉션의 인터페이스-구현체 관계를 명확히 이해하지 못했을 때</li>
     *     <li>당장은 문제가 없어 보여 대수롭지 않게 생각했을 때</li>
     * </ul>
     */
    public static class BadExample {
        /**
         * 이 메소드는 오직 `ArrayList<String>` 타입의 리스트만 파라미터로 받을 수 있습니다.
         *
         * @param list 처리할 ArrayList 객체
         */
        public void processList(ArrayList<String> list) {
            System.out.println("리스트 처리 중 (구체 클래스 사용):");
            // 이 메소드는 ArrayList의 특정 기능에 의존하는 코드를 포함할 수 있습니다.
            // (예: ArrayList에만 있는 특정 메소드 호출)
            for (String item : list) {
                System.out.println("- " + item);
            }
        }

        public void process() {
            System.out.println("나쁜 예시 실행:");
            // 왜 나쁜가?
            // 1. 낮은 유연성: `specificList`는 명확히 `ArrayList` 타입입니다.
            //    만약 나중에 `LinkedList`가 더 효율적이라는 요구사항이 생기면,
            //    이 변수 선언은 물론이고, 이 `specificList`를 사용하는 `processList` 메소드까지
            //    파라미터 타입을 `LinkedList`로 바꿔야 하는 등 광범위한 코드 수정이 필요할 수 있습니다.
            // 2. 높은 결합도: `processList` 메소드는 `ArrayList`라는 특정 구현체에 강하게 의존(결합)되어 있습니다.
            //    이는 코드 변경에 대한 파급 효과(Ripple Effect)를 크게 만듭니다.
            ArrayList<String> specificList = new ArrayList<>();
            specificList.add("Apple");
            specificList.add("Banana");

            processList(specificList);
            System.out.println("----------------------------------------");
        }
    }

    /**
     * <h3>좋은 예시: 인터페이스 타입으로 변수 선언</h3>
     * <p>변수와 메소드의 파라미터 타입을 `List`와 같은 인터페이스로 지정하는 방식입니다.</p>
     * <h4>왜, 언제 이렇게 사용해야 하는가?</h4>
     * <ul>
     *     <li><b>이유:</b> '구현이 아닌 인터페이스에 맞춰 프로그래밍하라'는 객체 지향의 핵심 원칙입니다.
     *         코드가 특정 구현체에 얽매이지 않고, 더 추상적이고 유연하게 동작하도록 만듭니다.
     *         이는 코드의 재사용성을 높이고, 미래의 변경에 훨씬 유연하게 대응할 수 있도록 합니다.</li>
     *     <li><b>상황:</b> 컬렉션을 다룰 때, 객체 지향 설계 시 의존성 주입(Dependency Injection)을 활용할 때 등,
     *         구체적인 구현보다 역할(인터페이스)이 중요한 모든 경우에 적용되어야 합니다.</li>
     * </ul>
     */
    public static class GoodExample {
        /**
         * 이 메소드는 `List<String>` 인터페이스를 구현하는 모든 종류의 리스트 객체를 파라미터로 받을 수 있습니다.
         *
         * @param list 처리할 List 인터페이스 객체
         */
        public void processList(List<String> list) {
            System.out.println("리스트 처리 중 (인터페이스 사용):");
            // 이 메소드는 List 인터페이스가 제공하는 공통적인 기능에만 의존합니다.
            // 따라서 실제 파라미터가 ArrayList이든 LinkedList이든 동일하게 동작합니다.
            for (String item : list) {
                System.out.println("- " + item);
            }
        }

        public void process() {
            System.out.println("좋은 예시 실행:");
            // 1. 변수를 `List` 인터페이스 타입으로 선언했습니다.
            //    이렇게 하면 이 변수 `interfaceList`는 `List`의 추상적인 동작에만 의존하며,
            //    실제 구현체가 무엇인지는 중요하지 않게 됩니다.
            List<String> interfaceList = new ArrayList<>(); // 초기 구현은 ArrayList
            interfaceList.add("Apple");
            interfaceList.add("Banana");

            processList(interfaceList);

            // 2. 나중에 요구사항 변경 등으로 인해 `LinkedList`가 더 효율적이라고 판단되면,
            //    오직 객체를 생성하는 부분 한 곳만 수정하면 됩니다.
            //    `processList` 메소드를 포함한 다른 코드는 전혀 변경할 필요가 없습니다. 이것이 바로 유연성입니다.
            List<String> flexibleList = new LinkedList<>(); // 구현체만 LinkedList로 변경
            flexibleList.add("Cherry");
            flexibleList.add("Durian");

            System.out.println("\n구현체를 LinkedList로 변경:");
            processList(flexibleList);
            System.out.println("========================================");
        }
    }

    public static void main(String[] args) {
        System.out.println("### 7단계: 인터페이스와 구현체 학습 ###\n");

        BadExample badExample = new BadExample();
        badExample.process();

        GoodExample goodExample = new GoodExample();
        goodExample.process();

        System.out.println("학습 결론: 변수나 파라미터를 선언할 때 구체적인 클래스 대신 인터페이스를 사용하면, 코드가 특정 구현체에 얽매이지 않아 유연성과 확장성이 크게 향상됩니다. 이는 잘 설계된 객체 지향 시스템의 기본 원칙입니다.");
    }
}

package java;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.function.Consumer;
import java.util.function.Function;
import java.util.function.Predicate;
import java.util.stream.Collectors;

/**
 * <h1>실무 Java 학습: 10단계 - 람다와 메소드 참조 (Lambdas & Method References)</h1>
 *
 * <h2>학습 목표</h2>
 * <ul>
 *     <li>익명 내부 클래스(Anonymous Inner Class)의 문제점과 람다 표현식의 등장 배경을 이해합니다.</li>
 *     <li>함수형 인터페이스(Functional Interface)의 개념과 람다 표현식을 활용하여 간결하고 유연한 코드를 작성하는 방법을 배웁니다.</li>
 *     <li>메소드 참조(Method Reference)를 사용하여 코드를 더욱 간결하고 가독성 높게 만드는 방법을 익힙니다.</li>
 * </ul>
 *
 * @author Gemini
 */
public class Step10_LambdasAndMethodReferences {

    /**
     * <h3>나쁜 예시: 익명 내부 클래스 사용</h3>
     * <p>Java 8 이전에는 함수형 인터페이스(예: Runnable, Comparator)의 인스턴스를 구현하기 위해 주로 익명 내부 클래스를 사용했습니다.</p>
     * <p>이는 코드가 장황해지고 가독성이 떨어지는 문제를 야기합니다.</p>
     */
    public static class BadExample {
        public void process() {
            System.out.println("나쁜 예시 실행: 익명 내부 클래스");

            // Runnable 인터페이스를 익명 내부 클래스로 구현
            Runnable runnable = new Runnable() {
                @Override
                public void run() {
                    System.out.println("Hello from an anonymous inner class!");
                }
            };
            new Thread(runnable).start();

            List<String> names = Arrays.asList("Alice", "Bob", "Charlie");

            // List.forEach에 Consumer 인터페이스를 익명 내부 클래스로 전달
            names.forEach(new Consumer<String>() {
                @Override
                public void accept(String name) {
                    System.out.println("Greeting: " + name);
                }
            });

            // 왜 나쁜가?
            // 1. 장황함: 단일 추상 메소드를 구현하기 위해 많은 상용구(boilerplate) 코드가 필요합니다.
            //    실제 로직보다 인터페이스 구현을 위한 코드가 더 많습니다.
            // 2. 가독성 저하: 로직의 핵심이 코드의 중간에 파묻혀 있어 한눈에 파악하기 어렵습니다.
            // 3. 유지보수 어려움: 불필요하게 긴 코드는 수정 및 이해에 더 많은 노력을 필요로 합니다.
            System.out.println("----------------------------------------");
        }
    }

    /**
     * <h3>좋은 예시 1: 람다 표현식 사용</h3>
     * <p>Java 8부터 도입된 람다 표현식은 단일 추상 메소드를 가진 인터페이스(함수형 인터페이스)를
     * 간결하게 표현할 수 있도록 해줍니다.</p>
     * <h4>왜, 언제 이렇게 사용해야 하는가?</h4>
     * <ul>
     *     <li><b>이유:</b> 불필요한 상용구 코드를 제거하여 코드를 훨씬 간결하고 가독성 높게 만듭니다.
     *         코드의 핵심 로직에 집중할 수 있게 해주며, 함수형 프로그래밍 스타일을 가능하게 합니다.</li>
     *     <li><b>상황:</b> 익명 내부 클래스를 대체하여 함수형 인터페이스의 인스턴스를 생성할 때,
     *         특히 Stream API와 함께 사용될 때 강력한 시너지를 발휘합니다.</li>
     * </ul>
     */
    public static class GoodExampleLambdas {
        public void process() {
            System.out.println("좋은 예시 1 실행: 람다 표현식");

            // 람다 표현식: (parameter) -> { body }
            // 익명 내부 클래스 대신 람다로 Runnable 구현
            Runnable runnable = () -> System.out.println("Hello from a lambda!");
            new Thread(runnable).start();

            List<String> names = Arrays.asList("Alice", "Bob", "Charlie");

            // Consumer 인터페이스를 람다로 전달
            names.forEach(name -> System.out.println("Greeting: " + name));

            // Predicate 람다: 특정 조건을 테스트
            Predicate<String> startsWithA = (String s) -> s.startsWith("A");
            List<String> filteredNames = names.stream()
                .filter(startsWithA)
                .collect(Collectors.toList());
            System.out.println("Names starting with 'A': " + filteredNames);

            // Function 람다: 값을 변환
            Function<String, Integer> nameLength = s -> s.length();
            List<Integer> nameLengths = names.stream()
                .map(nameLength)
                .collect(Collectors.toList());
            System.out.println("Name lengths: " + nameLengths);

            System.out.println("----------------------------------------");
        }
    }

    /**
     * <h3>좋은 예시 2: 메소드 참조 사용</h3>
     * <p>람다 표현식이 기존 메소드를 단순히 호출하는 형태로 구현될 때, 이를 더 간결하게 표현하는 문법입니다.</p>
     * <h4>왜, 언제 이렇게 사용해야 하는가?</h4>
     * <ul>
     *     <li><b>이유:</b> 이미 존재하는 메소드를 재사용하여 코드를 더욱 읽기 쉽고 간결하게 만듭니다.
     *         명확한 이름의 메소드를 가리키므로 코드의 의도를 명확하게 전달합니다.</li>
     *     <li><b>상황:</b> 람다 표현식의 본문이 단순히 다른 메소드를 호출하는 경우 (예: `s -> System.out.println(s)` 대신 `System.out::println`),
     *         혹은 생성자를 호출하는 경우(`ClassName::new`)에 사용합니다.</li>
     * </ul>
     */
    public static class GoodExampleMethodReferences {
        public void process() {
            System.out.println("좋은 예시 2 실행: 메소드 참조");

            List<String> names = Arrays.asList("Alice", "Bob", "Charlie");

            // 인스턴스 메소드 참조: object::instanceMethod
            // `name -> System.out.println(name)` 대신 `System.out::println`
            names.forEach(System.out::println);

            // 스태틱 메소드 참조: Class::staticMethod
            // `s -> String.valueOf(s)` 대신 `String::valueOf`
            List<String> stringNumbers = Arrays.asList("1", "2", "3");
            List<Integer> parsedNumbers = stringNumbers.stream()
                .map(Integer::parseInt) // s -> Integer.parseInt(s)
                .collect(Collectors.toList());
            System.out.println("Parsed numbers: " + parsedNumbers);

            // 특정 객체의 인스턴스 메소드 참조: Class::instanceMethod (첫 번째 파라미터가 메소드의 대상이 되는 경우)
            // `s -> s.toUpperCase()` 대신 `String::toUpperCase`
            List<String> upperCaseNames = names.stream()
                .map(String::toUpperCase)
                .collect(Collectors.toList());
            System.out.println("Uppercase names: " + upperCaseNames);

            // 생성자 참조: Class::new
            // `() -> new ArrayList<String>()` 대신 `ArrayList::new`
            List<String> emptyList = Arrays.asList("A", "B", "C").stream()
                .collect(ArrayList::new, ArrayList::add, ArrayList::addAll);
            System.out.println("Collected to new list: " + emptyList);

            System.out.println("========================================");
        }
    }

    public static void main(String[] args) {
        System.out.println("### 10단계: 람다와 메소드 참조 학습 ###\n");

        BadExample badExample = new BadExample();
        badExample.process();

        GoodExampleLambdas goodExampleLambdas = new GoodExampleLambdas();
        goodExampleLambdas.process();

        GoodExampleMethodReferences goodExampleMethodReferences = new GoodExampleMethodReferences();
        goodExampleMethodReferences.process();

        System.out.println("학습 결론: 람다 표현식과 메소드 참조는 Java 코드를 더욱 간결하고 함수형 스타일에 가깝게 만듭니다. 이를 통해 코드의 가독성이 향상되고, 특히 Stream API와 결합될 때 데이터 처리 로직을 매우 효과적으로 표현할 수 있습니다.");
    }
}

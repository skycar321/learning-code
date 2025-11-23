package java;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * <h1>실무 Java 학습: 9단계 - 제네릭 심화 (Advanced Generics)</h1>
 *
 * <h2>학습 목표</h2>
 * <ul>
 *     <li>'타입 소거(Type Erasure)'의 개념과 그로 인한 제네릭의 한계를 이해합니다.</li>
 *     <li>와일드카드(`? super T`, `? extends T`)를 사용하여 제네릭 코드의 유연성을 높이는 PECS(Producer Extends, Consumer Super) 원칙을 배웁니다.</li>
 *     <li>제네릭 메소드를 직접 구현하여 다양한 타입의 데이터를 안전하게 처리하는 방법을 익힙니다.</li>
 * </ul>
 *
 * @author Gemini
 */
public class Step9_AdvancedGenerics {

    /**
     * 나쁜 예시: 제네릭을 제대로 활용하지 못하거나 타입 안전성을 고려하지 않은 코드
     *
     * <p>설명: 이 예시에서는 제네릭이 제공하는 타입 안전성 이점을 충분히 활용하지 못하여 런타임 오류가 발생할 가능성이 있습니다.</p>
     * <p>특히 원시 타입(Raw Type) 컬렉션을 사용하거나, 와일드카드 제한을 잘못 이해했을 때 발생할 수 있는 문제를 보여줍니다.</p>
     */
    public static class BadExample {

        /**
         * 원시 타입 {@code List}를 파라미터로 받는 메소드.
         * 타입 안전성을 잃어버려 어떤 타입의 객체든 추가될 수 있습니다.
         */
        public void printListRawType(List list) {
            System.out.println("나쁜 예시 실행: 원시 타입 List 사용");
            list.add(10); // 컴파일 에러 없이 다양한 타입 추가 가능
            list.add("Hello");
            list.add(new Object());
            System.out.println("원시 타입 리스트: " + list);

            // 런타임에 ClassCastException이 발생할 가능성이 있습니다.
            // 아래 코드는 List가 String을 담고 있다고 가정하지만, 실제로는 그렇지 않을 수 있습니다.
            try {
                for (Object item : list) {
                    // System.out.println((String) item); // 잠재적인 런타임 오류 지점
                }
            } catch (ClassCastException e) {
                System.out.println("!!! 런타임 오류 발생 가능성 (ClassCastException): " + e.getMessage());
            }
            System.out.println("----------------------------------------");
        }

        /**
         * {@code List<Object>}를 받는 메소드.
         * {@code List<String>}이나 {@code List<Integer>}를 파라미터로 받을 수 없습니다 (타입 불변성).
         * 이는 유연성이 떨어지는 코드입니다.
         */
        public void printListObject(List<Object> list) {
            // 이 메소드는 List<String>과 같은 List<하위타입>을 인자로 받을 수 없습니다.
            // List<Object>와 List<String>은 상속 관계가 아닙니다.
            System.out.println("나쁜 예시 실행: List<Object>의 유연성 부족");
            list.forEach(System.out::println);
            System.out.println("----------------------------------------");
        }

        public void process() {
            List rawList = new ArrayList();
            rawList.add("String 1");
            rawList.add("String 2");
            printListRawType(rawList); // 경고 발생: Raw type usage

            List<String> stringList = Arrays.asList("Apple", "Banana");
            // printListObject(stringList); // 컴파일 에러: List<String>은 List<Object>의 하위 타입이 아님
            System.out.println("List<Object> 메소드에 List<String> 전달 시 컴파일 에러 발생");
        }
    }

    /**
     * 좋은 예시: 와일드카드와 PECS 원칙을 활용한 타입 안전하고 유연한 제네릭 코드
     *
     * <p>설명: PECS 원칙(Producer Extends, Consumer Super)과 제네릭 메소드를 사용하여 타입 안전성을 유지하면서도
     * 유연하게 다양한 타입의 컬렉션을 처리하는 방법을 보여줍니다.</p>
     */
    public static class GoodExample {

        /**
         * PECS 원칙 적용 (Producer Extends):
         * {@code List<? extends Number>}는 {@code Number}를 생산하는(읽기 전용) 리스트를 의미합니다.
         * {@code List<Integer>}, {@code List<Double>} 등 {@code Number}를 상속하는 어떤 타입의 리스트라도 받을 수 있습니다.
         * 이 리스트에서는 {@code Number} 또는 그 상위 타입의 객체만 읽을 수 있고, {@code null} 외에는 추가할 수 없습니다.
         */
        public void printNumbersExtends(List<? extends Number> numbers) {
            System.out.println("좋은 예시 실행: Producer Extends (읽기 전용)");
            numbers.forEach(number -> System.out.println("Number: " + number.doubleValue()));
            // numbers.add(10); // 컴파일 에러: ? extends Number는 Number의 하위 타입 객체를 담을 수 있지만,
                               //           어떤 구체적인 하위 타입인지 알 수 없어 안전하게 추가할 수 있는 타입이 없음 (null 제외)
            System.out.println("----------------------------------------");
        }

        /**
         * PECS 원칙 적용 (Consumer Super):
         * {@code List<? super Integer>}는 {@code Integer}를 소비하는(쓰기 가능) 리스트를 의미합니다.
         * {@code List<Integer>}, {@code List<Number>}, {@code List<Object>} 등 {@code Integer}의 상위 타입 리스트를 받을 수 있습니다.
         * 이 리스트에는 {@code Integer} 또는 그 하위 타입의 객체(즉, {@code Integer})를 추가할 수 있습니다.
         */
        public void addIntegersSuper(List<? super Integer> integers) {
            System.out.println("좋은 예시 실행: Consumer Super (쓰기 가능)");
            integers.add(10);
            integers.add(20);
            integers.add(30);
            System.out.println("추가 후 리스트: " + integers);
            // Integer 타입의 값을 추가할 수 있습니다.
            // Object item = integers.get(0); // 읽을 때는 Object 타입으로 읽어야 합니다.
            System.out.println("----------------------------------------");
        }

        /**
         * 제네릭 메소드 예시: 두 리스트를 복사하는 유틸리티 메소드
         *
         * <p>소스(src) 리스트에서 요소를 읽어와서 데스티네이션(dest) 리스트에 추가합니다.</p>
         * <p>여기서 {@code ? extends T}는 소스 리스트에서 T 타입 또는 T의 하위 타입 객체를 '생산'함을 의미합니다.</p>
         * <p>그리고 {@code ? super T}는 데스티네이션 리스트가 T 타입 또는 T의 상위 타입 객체를 '소비'할 수 있음을 의미합니다.</p>
         * <p>이는 PECS 원칙을 완벽하게 따릅니다.</p>
         */
        public <T> void copyList(List<? extends T> src, List<? super T> dest) {
            for (T item : src) {
                dest.add(item);
            }
        }

        public void process() {
            List<Integer> integers = Arrays.asList(1, 2, 3);
            List<Double> doubles = Arrays.asList(1.1, 2.2, 3.3);
            List<Number> numbers = new ArrayList<>();
            List<Object> objects = new ArrayList<>();

            printNumbersExtends(integers); // List<Integer>는 List<? extends Number>에 해당
            printNumbersExtends(doubles); // List<Double>도 List<? extends Number>에 해당

            addIntegersSuper(numbers); // List<Number>는 List<? super Integer>에 해당
            addIntegersSuper(objects); // List<Object>도 List<? super Integer>에 해당

            System.out.println("제네릭 메소드 copyList 실행:");
            List<Number> sourceNumbers = Arrays.asList(1, 2.5, 3L);
            List<Number> destNumbers = new ArrayList<>();
            copyList(sourceNumbers, destNumbers);
            System.out.println("복사 후 destNumbers: " + destNumbers);

            List<Integer> sourceIntegers = Arrays.asList(10, 20, 30);
            List<Object> destObjects = new ArrayList<>();
            copyList(sourceIntegers, destObjects); // List<? extends Integer>를 List<? super Integer>로 복사
            System.out.println("복사 후 destObjects: " + destObjects);
            System.out.println("========================================");
        }
    }

    public static void main(String[] args) {
        System.out.println("### 9단계: 제네릭 심화 학습 ###\n");

        BadExample badExample = new BadExample();
        badExample.process();

        GoodExample goodExample = new GoodExample();
        goodExample.process();

        System.out.println("학습 결론: 제네릭을 사용할 때는 타입 소거의 한계를 이해하고, PECS(Producer Extends, Consumer Super) 원칙과 와일드카드를 적절히 활용하여 유연하면서도 타입 안전한 코드를 작성하는 것이 중요합니다.");
    }
}

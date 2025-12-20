import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * <h1>실무 Java 학습: 4단계 - 컬렉션과 스트림</h1>
 *
 * <h2>학습 목표</h2>
 * <ul>
 *     <li>명령형 프로그래밍(Imperative Programming) 방식인 `for` 루프의 특징을 이해합니다.</li>
 *     <li>선언형 프로그래밍(Declarative Programming) 방식인 Java 8 `Stream API`의 장점을 배웁니다.</li>
 *     <li>`filter`, `map`, `collect` 등 스트림의 핵심 중간 연산과 최종 연산을 사용하여 데이터를 우아하게 처리하는 방법을 익힙니다.</li>
 * </ul>
 *
 * @author Gemini
 */
public class Step4_CollectionsAndStreams {

    static class Product {
        private final String name;
        private final int price;
        private final boolean onSale;

        public Product(String name, int price, boolean onSale) {
            this.name = name;
            this.price = price;
            this.onSale = onSale;
        }

        public String getName() { return name; }
        public int getPrice() { return price; }
        public boolean isOnSale() { return onSale; }

        @Override
        public String toString() {
            return "Product{" + "name='" + name + '\'' + ", price=" + price + '}';
        }
    }

    private static List<Product> getProducts() {
        return List.of(
            new Product("노트북", 1200000, true),
            new Product("모니터", 350000, false),
            new Product("키보드", 150000, true),
            new Product("마우스", 50000, true),
            new Product("헤드셋", 250000, false)
        );
    }

    /**
     * <h3>나쁜 예시: `for`와 `if`를 사용한 명령형 프로그래밍</h3>
     * <p>데이터를 처리하는 '방법(How)'을 하나하나 직접 명시하는 방식입니다.</p>
     * <h4>언제 이런 코드를 마주하는가?</h4>
     * <ul>
     *     <li>Java 8 이전의 레거시 코드</li>
     *     <li>Stream API에 익숙하지 않은 경우</li>
     *     <li>매우 복잡한 제어 흐름이 필요하여 스트림으로 표현하기 어려운 경우 (드묾)</li>
     * </ul>
     */
    public static class BadExample {
        public void process() {
            System.out.println("나쁜 예시 실행:");
            List<Product> products = getProducts();
            List<String> saleProductNames = new ArrayList<>();

            // 왜 나쁜가?
            // 1. 가독성 저하: '어떻게' 처리할지에 대한 로직(for, if, add 등)이 비즈니스 로직과 섞여 있습니다.
            //    코드가 길어지고 중첩이 깊어지면 '무엇을' 하려는지 한눈에 파악하기 어렵습니다.
            // 2. 실수 유발: 새로운 리스트를 생성하고, 조건문을 중첩하는 과정에서 실수가 발생하기 쉽습니다.
            // 3. 재사용성 부족: 이 로직 덩어리는 다른 곳에서 재사용하기 어렵습니다.
            for (Product product : products) {
                if (product.isOnSale()) {
                    if (product.getPrice() > 100000) {
                        saleProductNames.add(product.getName().toUpperCase());
                    }
                }
            }

            System.out.println("10만원 초과 세일 상품명: " + saleProductNames);
            System.out.println("----------------------------------------");
        }
    }

    /**
     * <h3>좋은 예시: `Stream API`를 사용한 선언형 프로그래밍</h3>
     * <p>'무엇을(What)' 원하는지에 집중하여 데이터 처리 과정을 선언하는 방식입니다.</p>
     * <h4>왜, 언제 이렇게 사용해야 하는가?</h4>
     * <ul>
     *     <li><b>이유:</b> 데이터 처리 파이프라인을 명확하게 보여주어 코드가 간결하고 가독성이 매우 높아집니다.
     *         또한, 내부적으로 최적화되거나 병렬 처리가 가능하여 성능상 이점을 가질 수도 있습니다.</li>
     *     <li><b>상황:</b> 컬렉션(List, Set, Map 등)의 데이터를 필터링, 변환, 그룹핑 등 여러 단계로 처리해야 하는 모든 경우에 사용하는 것이 좋습니다.</li>
     * </ul>
     */
    public static class GoodExample {
        public void process() {
            System.out.println("좋은 예시 실행:");
            List<Product> products = getProducts();

            // Stream API는 데이터 처리 단계를 물 흐르듯이(stream) 연결합니다.
            // 각 단계는 명확한 하나의 책임만 가집니다.
            List<String> saleProductNames = products.stream() // 1. products 리스트를 데이터의 흐름(stream)으로 변환합니다.
                
                // 2. 중간 연산: filter - 조건을 만족하는 요소만 남깁니다.
                //    메소드 참조(Product::isOnSale)를 사용하여 코드를 더욱 간결하게 만들었습니다.
                .filter(Product::isOnSale)
                
                // 3. 중간 연산: filter - 연달아 다른 조건을 적용할 수 있습니다.
                .filter(product -> product.getPrice() > 100000)
                
                // 4. 중간 연산: map - 각 요소를 다른 형태나 값으로 변환합니다.
                //    Product 객체에서 상품명(String)을 대문자로 바꾼 새로운 스트림을 생성합니다.
                .map(product -> product.getName().toUpperCase())
                
                // 5. 최종 연산: collect - 스트림의 요소들을 모아서 최종 결과(여기서는 List)를 만듭니다.
                //    최종 연산이 호출되기 전까지 중간 연산들은 실제로 실행되지 않습니다 (지연 평가, Lazy Evaluation).
                .collect(Collectors.toList());

            System.out.println("10만원 초과 세일 상품명: " + saleProductNames);
            System.out.println("========================================");
        }
    }

    public static void main(String[] args) {
        System.out.println("### 4단계: 컬렉션과 스트림 학습 ###\n");

        BadExample badExample = new BadExample();
        badExample.process();

        GoodExample goodExample = new GoodExample();
        goodExample.process();

        System.out.println("학습 결론: Java 8 이상의 프로젝트에서 컬렉션 데이터를 다룰 때는 `Stream API`를 적극적으로 사용하는 것이 현대적인 Java 개발 방식입니다. 코드가 간결해지고, 가독성이 향상되며, 병렬 처리 등 추가적인 최적화의 가능성도 열어줍니다.");
    }
}

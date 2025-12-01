// Step11_TestCodeWriting.java
// Spring Boot 테스트 코드 작성 학습을 위한 코드 예시입니다.
// 이 파일은 단위 테스트(Unit Test), 통합 테스트(Integration Test), Mocking 등
// 다양한 테스트 전략과 기법을 사용하여 Spring Boot 애플리케이션의 품질을 높이는 방법을 보여줍니다.
//
// 테스트는 소프트웨어 개발의 필수적인 부분이며, 오류를 조기에 발견하고
// 코드 변경 시 예상치 못한 부작용을 방지하는 데 도움을 줍니다.

package com.example.testcodewriting;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.context.WebApplicationContext;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

// -----------------------------------------------------------------------------
// 학습 포인트 1: 단위 테스트 (Unit Test)
// - 특정 모듈이나 컴포넌트(메서드, 클래스)를 독립적으로 테스트합니다.
// - 의존성이 있는 객체는 Mocking하여 실제 객체와 분리합니다.
// - 목적: 빠른 피드백, 코드 변경의 영향 최소화, 버그 위치 특정 용이.
// -----------------------------------------------------------------------------

// 예시 도메인: Product
class Product {
    private Long id;
    private String name;
    private double price;

    public Product(Long id, String name, double price) {
        this.id = id;
        this.name = name;
        this.price = price;
    }

    public Long getId() { return id; }
    public String getName() { return name; }
    public double getPrice() { return price; }
}

// 예시 Repository (인터페이스만): ProductRepository
interface ProductRepository {
    Optional<Product> findById(Long id);
    Product save(Product product);
}

// 예시 서비스: ProductService
@Service
class ProductService {
    private final ProductRepository productRepository;

    public ProductService(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }

    public Product getProductById(Long id) {
        return productRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("상품을 찾을 수 없습니다."));
    }

    public Product createProduct(String name, double price) {
        if (name == null || name.isEmpty()) {
            throw new IllegalArgumentException("상품 이름은 비워둘 수 없습니다.");
        }
        Product newProduct = new Product(null, name, price); // ID는 DB에서 생성될 예정
        return productRepository.save(newProduct);
    }
}

// 단위 테스트: ProductServiceTest (Mockito 사용)
@ExtendWith(MockitoExtension.class) // JUnit 5에서 Mockito 사용을 위한 확장
class ProductServiceTest {

    @Mock // ProductRepository를 Mock 객체로 생성
    private ProductRepository productRepository;

    @InjectMocks // productRepository Mock 객체를 ProductService에 주입
    private ProductService productService;

    @BeforeEach // 각 테스트 메서드 실행 전에 호출
    void setUp() {
        // Mock 객체의 행동 정의
        given(productRepository.findById(1L)).willReturn(Optional.of(new Product(1L, "Laptop", 1000.0)));
        given(productRepository.findById(2L)).willReturn(Optional.empty()); // 2번 ID는 없는 경우
    }

    @Test
    @DisplayName("유효한 ID로 상품 조회 시, 상품 반환")
    void getProductById_ValidId_ReturnsProduct() {
        // When
        Product product = productService.getProductById(1L);

        // Then
        assertThat(product.getName()).isEqualTo("Laptop");
        assertThat(product.getPrice()).isEqualTo(1000.0);
        // Mock 객체가 호출되었는지 검증
        verify(productRepository, times(1)).findById(1L);
    }

    @Test
    @DisplayName("유효하지 않은 ID로 상품 조회 시, 예외 발생")
    void getProductById_InvalidId_ThrowsException() {
        // When & Then
        assertThrows(IllegalArgumentException.class, () -> productService.getProductById(2L));
        verify(productRepository, times(1)).findById(2L);
    }

    @Test
    @DisplayName("새 상품 생성 시, Repository의 save 메서드 호출")
    void createProduct_ValidInput_CallsSaveMethod() {
        // Given
        Product newProduct = new Product(3L, "Keyboard", 150.0);
        given(productRepository.save(any(Product.class))).willReturn(newProduct); // 어떤 Product 객체가 save되어도 newProduct 반환

        // When
        Product savedProduct = productService.createProduct("Keyboard", 150.0);

        // Then
        assertThat(savedProduct.getName()).isEqualTo("Keyboard");
        verify(productRepository, times(1)).save(any(Product.class)); // save 메서드가 1번 호출되었는지 검증
    }

    // 나쁜 예시: Mocking 없이 실제 DB에 연결하여 테스트
    // - 테스트 실행 속도가 느려지고, 테스트 간 의존성이 생겨 독립적인 테스트가 어려워집니다.
    // - 테스트 환경(DB 상태)에 따라 결과가 달라질 수 있습니다.
    // - 단위 테스트의 목적(단일 컴포넌트 격리 테스트)에 부합하지 않습니다.
    // @Test
    // void getProductById_RealDbConnection_BadExample() {
    //     // 이 테스트는 ProductRepository의 실제 구현체가 필요합니다.
    //     // 이는 단위 테스트가 아닌 통합 테스트에 가깝습니다.
    // }
}


// -----------------------------------------------------------------------------
// 학습 포인트 2: 통합 테스트 (Integration Test)
// - 여러 계층(컨트롤러, 서비스, 리포지토리)이 함께 동작하는 것을 테스트합니다.
// - `@SpringBootTest`: 전체 Spring 애플리케이션 컨텍스트를 로드합니다.
// - `@WebMvcTest`: MVC 계층(컨트롤러)만 테스트할 때 사용하며, 불필요한 빈 로딩을 줄여줍니다.
// - `MockMvc`: HTTP 요청을 보내고 응답을 검증하는 데 사용됩니다.
// - 목적: 컴포넌트 간의 연동 확인, 실제 환경과 유사한 테스트.
// -----------------------------------------------------------------------------

// 예시 컨트롤러: ProductController
@RestController
@RequestMapping("/products")
class ProductController {
    private final ProductService productService;

    public ProductController(ProductService productService) {
        this.productService = productService;
    }

    @GetMapping("/{id}")
    public String getProduct(@PathVariable Long id) {
        return productService.getProductById(id).getName();
    }
}

// 통합 테스트: ProductControllerTest (WebMvcTest 사용)
@WebMvcTest(ProductController.class) // ProductController와 관련된 빈만 로드
class ProductControllerTest {

    @Autowired
    private MockMvc mockMvc; // HTTP 요청을 시뮬레이션

    @MockBean // ProductService를 Mock 객체로 생성하여 주입 (실제 ProductService 빈 대신)
    private ProductService productService;

    @Test
    @DisplayName("상품 조회 API 호출 시, 정상 응답 반환")
    void getProduct_ValidId_ReturnsProductName() throws Exception {
        // Given
        given(productService.getProductById(1L)).willReturn(new Product(1L, "Laptop", 1000.0));

        // When & Then
        mockMvc.perform(get("/products/1"))
                .andExpect(status().isOk()) // HTTP 200 OK
                .andExpect(content().string("Laptop")); // 응답 본문 검증
        verify(productService, times(1)).getProductById(1L);
    }

    @Test
    @DisplayName("없는 상품 조회 API 호출 시, 400 Bad Request 반환")
    void getProduct_InvalidId_ReturnsBadRequest() throws Exception {
        // Given
        given(productService.getProductById(anyLong())).willThrow(new IllegalArgumentException("상품을 찾을 수 없습니다."));

        // When & Then
        mockMvc.perform(get("/products/2"))
                .andExpect(status().isBadRequest()); // HTTP 400 Bad Request
        verify(productService, times(1)).getProductById(2L);
    }
}

// 전체 애플리케이션 통합 테스트 (SpringBootTest 사용)
// 실제 데이터베이스, 모든 빈을 로드하므로 가장 무거운 테스트입니다.
// @SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
// class FullIntegrationTest {
//
//     @LocalServerPort
//     private int port;
//
//     @Autowired
//     private TestRestTemplate restTemplate; // 실제 HTTP 요청을 보내는 유틸리티
//
//     @MockBean
//     private ProductRepository productRepository; // 실제 DB 연결 대신 Mock 사용
//
//     @BeforeEach
//     void setUp() {
//         given(productRepository.findById(1L)).willReturn(Optional.of(new Product(1L, "Laptop", 1000.0)));
//         // 실제 DB를 사용하는 통합 테스트라면 MockBean 대신 실제 Repository를 주입받고
//         // 테스트용 DB (H2 등)를 설정하여 테스트합니다.
//     }
//
//     @Test
//     void getProduct_ReturnsProductDetails() {
//         assertThat(this.restTemplate.getForObject("http://localhost:" + port + "/products/1",
//                 String.class)).contains("Laptop");
//     }
// }


@SpringBootApplication
public class TestCodeWritingApplication {
    public static void main(String[] args) {
        SpringApplication.run(TestCodeWritingApplication.class, args);
    }
}

/*
이 파일은 실행 가능한 메인 클래스를 포함하지만, 테스트는 JUnit 5를 사용하여 별도로 실행해야 합니다.
IDE(IntelliJ, Eclipse)에서 해당 테스트 클래스를 마우스 오른쪽 버튼으로 클릭하여 실행하거나,
Maven/Gradle 명령어를 통해 실행할 수 있습니다:

Maven:
mvn test

Gradle:
./gradlew test

학습 시점:
- 단위 테스트는 `ProductServiceTest` 클래스 코드를 집중적으로 살펴보세요.
- 통합 테스트는 `ProductControllerTest` 클래스 코드를 집중적으로 살펴보세요.
- `@SpringBootTest`를 이용한 전체 통합 테스트는 설정이 더 복잡하며, 실제 DB 연결 등이 필요한 경우가 많습니다.
  가장 가볍고 빠르게 피드백을 받을 수 있는 단위 테스트부터 작성하는 습관을 들이세요.
*/

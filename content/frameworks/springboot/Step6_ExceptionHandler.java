// Step6_ExceptionHandler.java
// Spring Boot 애플리케이션의 전역 예외 처리 학습을 위한 코드 예시입니다.
// 이 파일은 `@ControllerAdvice`와 `@ExceptionHandler` 어노테이션을 사용하여
// REST API의 예외를 중앙 집중식으로 처리하는 방법을 보여줍니다.
//
// 예외 처리는 애플리케이션의 안정성과 사용자 경험에 매우 중요합니다.
// Spring Boot는 이러한 예외 처리를 효과적으로 할 수 있는 다양한 방법을 제공합니다.

package com.example.exceptionhandler;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.NoSuchElementException;

// -----------------------------------------------------------------------------
// 학습 포인트 1: Custom Exception 정의
// - 애플리케이션 특유의 오류 상황을 명확히 표현하기 위해 사용자 정의 예외를 생성합니다.
// - RuntimeException을 상속받아 Unchecked Exception으로 만듭니다.
// -----------------------------------------------------------------------------
class ProductNotFoundException extends RuntimeException {
    public ProductNotFoundException(String message) {
        super(message);
    }
}

class InvalidInputException extends RuntimeException {
    public InvalidInputException(String message) {
        super(message);
    }
}

// -----------------------------------------------------------------------------
// 학습 포인트 2: `@ControllerAdvice` 및 `@ExceptionHandler`를 이용한 전역 예외 처리
// - `@ControllerAdvice`: 모든 `@Controller`에 대한 예외를 전역적으로 처리하는 클래스임을 나타냅니다.
//   - 특정 패키지, 특정 어노테이션이 붙은 컨트롤러 등 대상을 지정할 수도 있습니다.
// - `@ExceptionHandler`: 특정 예외가 발생했을 때 해당 메서드가 예외를 처리하도록 지정합니다.
//   - HTTP 응답 코드, 응답 본문 등을 커스터마이징할 수 있습니다.
// -----------------------------------------------------------------------------
@ControllerAdvice
class GlobalExceptionHandler extends ResponseEntityExceptionHandler {

    // 좋은 예시: ProductNotFoundException 발생 시 HTTP 404 (NOT_FOUND) 응답을 반환
    @ExceptionHandler(ProductNotFoundException.class)
    public ResponseEntity<Object> handleProductNotFoundException(ProductNotFoundException ex, WebRequest request) {
        Map<String, Object> body = new HashMap<>();
        body.put("timestamp", LocalDateTime.now());
        body.put("message", ex.getMessage());
        body.put("status", HttpStatus.NOT_FOUND.value());
        body.put("error", HttpStatus.NOT_FOUND.getReasonPhrase());
        body.put("path", request.getDescription(false).replace("uri=", ""));
        return new ResponseEntity<>(body, HttpStatus.NOT_FOUND);
    }

    // 좋은 예시: InvalidInputException 발생 시 HTTP 400 (BAD_REQUEST) 응답을 반환
    @ExceptionHandler(InvalidInputException.class)
    public ResponseEntity<Object> handleInvalidInputException(InvalidInputException ex, WebRequest request) {
        Map<String, Object> body = new HashMap<>();
        body.put("timestamp", LocalDateTime.now());
        body.put("message", ex.getMessage());
        body.put("status", HttpStatus.BAD_REQUEST.value());
        body.put("error", HttpStatus.BAD_REQUEST.getReasonPhrase());
        body.put("path", request.getDescription(false).replace("uri=", ""));
        return new ResponseEntity<>(body, HttpStatus.BAD_REQUEST);
    }

    // 나쁜 예시: 일반적인 Exception을 광범위하게 처리.
    // - 어떤 예외인지 명확하지 않고, 모든 예외를 500으로 처리하면 클라이언트에게
    //   정확한 정보를 전달하기 어렵고 디버깅도 어렵습니다.
    // - 가능한 한 구체적인 예외를 `@ExceptionHandler`로 처리하는 것이 좋습니다.
    // - 다만, 예상치 못한 모든 예외를 처리하기 위한 최종 방어선으로는 사용할 수 있습니다.
    @ExceptionHandler(Exception.class)
    public ResponseEntity<Object> handleAllUncaughtException(Exception ex, WebRequest request) {
        Map<String, Object> body = new HashMap<>();
        body.put("timestamp", LocalDateTime.now());
        body.put("message", "내부 서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
        body.put("status", HttpStatus.INTERNAL_SERVER_ERROR.value());
        body.put("error", HttpStatus.INTERNAL_SERVER_ERROR.getReasonPhrase());
        body.put("path", request.getDescription(false).replace("uri=", ""));
        // 실제로는 로깅 시스템에 ex.getMessage()와 스택 트레이스를 기록해야 합니다.
        System.err.println("예상치 못한 오류 발생: " + ex.getMessage());
        ex.printStackTrace();
        return new ResponseEntity<>(body, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    // -----------------------------------------------------------------------------
    // 학습 포인트 3: Spring이 기본으로 제공하는 예외 처리 (ResponseEntityExceptionHandler 상속)
    // - ResponseEntityExceptionHandler를 상속받으면 Spring MVC에서 발생하는
    //   일부 일반적인 예외(예: MethodArgumentNotValidException, HttpRequestMethodNotSupportedException)를
    //   커스터마이징하여 처리할 수 있습니다.
    // - `@Override`하여 원하는 예외 처리 메서드를 재정의할 수 있습니다.
    // -----------------------------------------------------------------------------

    // 예시: @Valid 어노테이션으로 인한 유효성 검사 실패 시 처리
    // @Override
    // protected ResponseEntity<Object> handleMethodArgumentNotValid(
    //         MethodArgumentNotValidException ex, HttpHeaders headers, HttpStatus status, WebRequest request) {
    //     Map<String, String> errors = new HashMap<>();
    //     ex.getBindingResult().getAllErrors().forEach((error) -> {
    //         String fieldName = ((FieldError) error).getField();
    //         String errorMessage = error.getDefaultMessage();
    //         errors.put(fieldName, errorMessage);
    //     });
    //     Map<String, Object> body = new HashMap<>();
    //     body.put("timestamp", LocalDateTime.now());
    //     body.put("message", "유효성 검사 실패");
    //     body.put("errors", errors);
    //     body.put("status", status.value());
    //     return new ResponseEntity<>(body, HttpStatus.BAD_REQUEST);
    // }
}

// -----------------------------------------------------------------------------
// 예시 도메인: Product
// -----------------------------------------------------------------------------
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

// -----------------------------------------------------------------------------
// 예시 서비스: ProductService
// -----------------------------------------------------------------------------
@Service
class ProductService {
    private final Map<Long, Product> products = new HashMap<>();

    public ProductService() {
        products.put(1L, new Product(1L, "Laptop", 1200.00));
        products.put(2L, new Product(2L, "Mouse", 25.00));
    }

    public Product getProduct(Long id) {
        return products.get(id);
    }

    public Product getProductOrThrow(Long id) {
        return products.computeIfAbsent(id, key -> {
            throw new ProductNotFoundException("ID가 " + id + "인 상품을 찾을 수 없습니다.");
        });
    }

    public Product updateProductPrice(Long id, double newPrice) {
        if (newPrice <= 0) {
            throw new InvalidInputException("상품 가격은 0보다 커야 합니다.");
        }
        Product product = products.get(id);
        if (product == null) {
            throw new ProductNotFoundException("ID가 " + id + "인 상품을 찾을 수 없습니다.");
        }
        products.put(id, new Product(id, product.getName(), newPrice));
        return products.get(id);
    }

    public void throwGenericException() {
        throw new NullPointerException("의도적으로 NullPointerException을 발생시켰습니다.");
    }

    public void throwUncheckedException() {
        throw new RuntimeException("의도적으로 RuntimeException을 발생시켰습니다.");
    }
}

// -----------------------------------------------------------------------------
// 예시 컨트롤러: ProductController
// -----------------------------------------------------------------------------
@RestController
@RequestMapping("/products")
class ProductController {

    private final ProductService productService;

    public ProductController(ProductService productService) {
        this.productService = productService;
    }

    @GetMapping("/{id}")
    public ResponseEntity<Product> getProduct(@PathVariable Long id) {
        Product product = productService.getProductOrThrow(id);
        return ResponseEntity.ok(product);
    }

    @PutMapping("/{id}/price")
    public ResponseEntity<Product> updateProductPrice(@PathVariable Long id, @RequestParam double newPrice) {
        Product updatedProduct = productService.updateProductPrice(id, newPrice);
        return ResponseEntity.ok(updatedProduct);
    }

    // 나쁜 예시: 컨트롤러 메서드 내에서 직접 예외를 try-catch로 처리
    // - 모든 컨트롤러 메서드마다 반복적인 예외 처리 코드가 들어가 코드가 지저분해집니다.
    // - 전역 예외 처리기가 있으면 이렇게 개별적으로 처리할 필요가 없습니다.
    @GetMapping("/legacy/{id}")
    public ResponseEntity<Object> getProductLegacy(@PathVariable Long id) {
        try {
            Product product = productService.getProduct(id);
            if (product == null) {
                return new ResponseEntity<>("상품을 찾을 수 없습니다.", HttpStatus.NOT_FOUND);
            }
            return ResponseEntity.ok(product);
        } catch (Exception e) {
            return new ResponseEntity<>("오류 발생: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/error/productNotFound")
    public ResponseEntity<String> throwProductNotFound() {
        throw new ProductNotFoundException("이 상품은 이제 판매하지 않습니다.");
    }

    @GetMapping("/error/invalidInput")
    public ResponseEntity<String> throwInvalidInput() {
        throw new InvalidInputException("입력 값이 유효하지 않습니다.");
    }

    @GetMapping("/error/generic")
    public ResponseEntity<String> throwGenericError() {
        productService.throwGenericException();
        return ResponseEntity.ok("Generic error occurred.");
    }

    @GetMapping("/error/runtime")
    public ResponseEntity<String> throwRuntimeError() {
        productService.throwUncheckedException();
        return ResponseEntity.ok("Runtime error occurred.");
    }
}

@SpringBootApplication
public class ExceptionHandlerApplication {
    public static void main(String[] args) {
        SpringApplication.run(ExceptionHandlerApplication.class, args);
    }
}

/*
이 애플리케이션을 실행하고 다음 URL로 접근하여 테스트할 수 있습니다:

1. 정상적인 상품 조회:
   GET http://localhost:8080/products/1

2. 없는 상품 조회 (ProductNotFoundException 처리):
   GET http://localhost:8080/products/3

3. 상품 가격 업데이트 (정상):
   PUT http://localhost:8080/products/1/price?newPrice=1250.00

4. 유효하지 않은 가격으로 업데이트 (InvalidInputException 처리):
   PUT http://localhost:8080/products/1/price?newPrice=0

5. ProductNotFoundException 강제 발생:
   GET http://localhost:8080/products/error/productNotFound

6. InvalidInputException 강제 발생:
   GET http://localhost:8080/products/error/invalidInput

7. 일반적인 RuntimeException 강제 발생 (GlobalExceptionHandler의 Exception.class 처리):
   GET http://localhost:8080/products/error/runtime

8. NullPointerException 강제 발생 (GlobalExceptionHandler의 Exception.class 처리):
   GET http://localhost:8080/products/error/generic

*/

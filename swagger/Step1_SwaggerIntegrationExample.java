package com.example.swagger;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.Collections;
import java.util.List;

@SpringBootApplication
@Tag(name = "Swagger Example API", description = "간단한 Swagger/OpenAPI 통합 예제 API")
public class Step1_SwaggerIntegrationExample {

    public static void main(String[] args) {
        SpringApplication.run(Step1_SwaggerIntegrationExample.class, args);
    }

    @RestController
    @RequestMapping("/example")
    public static class ExampleController {

        @Operation(
            summary = "환영 메시지 가져오기",
            description = "이름을 기반으로 개인화된 환영 메시지를 반환합니다.",
            parameters = @Parameter(name = "name", description = "환영할 사용자 이름", required = true, example = "World"),
            responses = {
                @ApiResponse(responseCode = "200", description = "성공적인 응답",
                    content = @Content(mediaType = "text/plain",
                    schema = @Schema(type = "string", example = "Hello, World!"))),
                @ApiResponse(responseCode = "400", description = "잘못된 요청: 이름이 제공되지 않음")
            }
        )
        @GetMapping("/hello")
        public String sayHello(@RequestParam(defaultValue = "World") String name) {
            return "Hello, " + name + "!";
        }

        @Operation(
            summary = "새 항목 생성",
            description = "새로운 항목을 생성하고 생성된 항목을 반환합니다.",
            requestBody = @io.swagger.v3.oas.annotations.parameters.RequestBody(
                description = "생성할 항목의 데이터",
                required = true,
                content = @Content(mediaType = "application/json",
                schema = @Schema(implementation = Item.class))
            ),
            responses = {
                @ApiResponse(responseCode = "201", description = "항목 생성 성공",
                    content = @Content(mediaType = "application/json",
                    schema = @Schema(implementation = Item.class))),
                @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터")
            }
        )
        @PostMapping("/items")
        @ResponseStatus(HttpStatus.CREATED)
        public Item createItem(@RequestBody Item item) {
            // 실제 구현에서는 항목을 저장하고 ID를 할당합니다.
            item.setId(1L); // 예시 ID 할당
            return item;
        }

        @Operation(
            summary = "모든 항목 조회",
            description = "시스템에 등록된 모든 항목 목록을 반환합니다.",
            responses = {
                @ApiResponse(responseCode = "200", description = "항목 목록 조회 성공",
                    content = @Content(mediaType = "application/json",
                    schema = @Schema(implementation = Item.class)))
            }
        )
        @GetMapping("/items")
        public List<Item> getAllItems() {
            return Collections.singletonList(new Item(1L, "Sample Item", "This is a sample item."));
        }
    }

    public static class Item {
        private Long id;
        private String name;
        private String description;

        public Item() {}

        public Item(Long id, String name, String description) {
            this.id = id;
            this.name = name;
            this.description = description;
        }

        public Long getId() {
            return id;
        }

        public void setId(Long id) {
            this.id = id;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getDescription() {
            return description;
        }

        public void setDescription(String description) {
            this.description = description;
        }
    }
}

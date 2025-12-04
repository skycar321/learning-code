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
@Tag(name = "Swagger Example API", description = "Simple Swagger/OpenAPI Integration Example")
public class Step1_SwaggerIntegrationExample {

    public static void main(String[] args) {
        SpringApplication.run(Step1_SwaggerIntegrationExample.class, args);
    }

    @RestController
    @RequestMapping("/example")
    public static class ExampleController {

        @Operation(
            summary = "Get Welcome Message",
            description = "Returns a personalized welcome message based on the name.",
            parameters = @Parameter(name = "name", description = "User name to welcome", required = true, example = "World"),
            responses = {
                @ApiResponse(responseCode = "200", description = "Successful response",
                    content = @Content(mediaType = "text/plain",
                    schema = @Schema(type = "string", example = "Hello, World!"))),
                @ApiResponse(responseCode = "400", description = "Bad Request: Name not provided")
            }
        )
        @GetMapping("/hello")
        public String sayHello(@RequestParam(defaultValue = "World") String name) {
            return "Hello, " + name + "!";
        }

        @Operation(
            summary = "Create New Item",
            description = "Creates a new item and returns the created item.",
            requestBody = @io.swagger.v3.oas.annotations.parameters.RequestBody(
                description = "Data of the item to create",
                required = true,
                content = @Content(mediaType = "application/json",
                schema = @Schema(implementation = Item.class))
            ),
            responses = {
                @ApiResponse(responseCode = "201", description = "Item created successfully",
                    content = @Content(mediaType = "application/json",
                    schema = @Schema(implementation = Item.class))),
                @ApiResponse(responseCode = "400", description = "Invalid input data")
            }
        )
        @PostMapping("/items")
        @ResponseStatus(HttpStatus.CREATED)
        public Item createItem(@RequestBody Item item) {
            // In real implementation, save item and assign ID.
            item.setId(1L); // Example ID assignment
            return item;
        }

        @Operation(
            summary = "Get All Items",
            description = "Returns a list of all items registered in the system.",
            responses = {
                @ApiResponse(responseCode = "200", description = "Successfully retrieved item list",
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

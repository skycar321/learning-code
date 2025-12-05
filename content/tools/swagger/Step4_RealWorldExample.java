package com.example.swagger;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/users")
@Tag(name = "User Management", description = "Operations related to User Management")
public class Step4_RealWorldExample {

    @Operation(summary = "Get User by ID", description = "Fetches user details based on the provided ID.")
    @ApiResponse(responseCode = "200", description = "User found",
            content = @Content(mediaType = "application/json", schema = @Schema(implementation = UserDTO.class)))
    @ApiResponse(responseCode = "404", description = "User not found")
    @GetMapping("/{id}")
    public UserDTO getUser(@PathVariable Long id) {
        return new UserDTO(id, "John Doe", "john@example.com");
    }

    @Operation(summary = "Create User", description = "Creates a new user.")
    @ApiResponse(responseCode = "201", description = "User created",
            content = @Content(mediaType = "application/json", schema = @Schema(implementation = UserDTO.class)))
    @PostMapping
    public UserDTO createUser(@RequestBody UserCreateRequest request) {
        return new UserDTO(1L, request.getName(), request.getEmail());
    }

    // DTOs
    @Schema(description = "User Data Transfer Object")
    public static class UserDTO {
        @Schema(description = "Unique identifier of the user", example = "1")
        private Long id;
        
        @Schema(description = "Full name of the user", example = "John Doe")
        private String name;
        
        @Schema(description = "Email address of the user", example = "john@example.com")
        private String email;

        public UserDTO() {}

        public UserDTO(Long id, String name, String email) {
            this.id = id;
            this.name = name;
            this.email = email;
        }

        public Long getId() { return id; }
        public void setId(Long id) { this.id = id; }
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
    }

    @Schema(description = "Request object for creating a user")
    public static class UserCreateRequest {
        @Schema(description = "Full name", requiredMode = Schema.RequiredMode.REQUIRED, example = "Jane Doe")
        private String name;

        @Schema(description = "Email address", requiredMode = Schema.RequiredMode.REQUIRED, example = "jane@example.com")
        private String email;

        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
    }
}

package com.example.swagger;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.enums.ParameterIn;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/advanced")
@Tag(name = "Advanced Usage", description = "Advanced Swagger Annotations Example")
public class Step3_AdvancedAnnotations {

    @Operation(summary = "Search Products", description = "Demonstrates advanced parameters usage including sorting and filtering")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Search successful"),
            @ApiResponse(responseCode = "400", description = "Invalid search parameters")
    })
    @GetMapping("/search")
    public String searchProducts(
            @Parameter(description = "Search query", required = true) @RequestParam String q,
            @Parameter(description = "Sort field", in = ParameterIn.QUERY, schema = @Schema(type = "string", allowableValues = {"name", "price", "date"})) @RequestParam(defaultValue = "name") String sort,
            @Parameter(description = "Page number", example = "1") @RequestParam(defaultValue = "1") int page
    ) {
        return "Searching for " + q + ", sorted by " + sort + ", page " + page;
    }

    @Operation(summary = "Upload File", description = "Demonstrates file upload documentation")
    @PostMapping(value = "/upload", consumes = "multipart/form-data")
    public String uploadFile(
            @Parameter(description = "File to upload") 
            @RequestPart MultipartFile file
    ) {
        return "File uploaded: " + file.getOriginalFilename();
    }
    
    @Operation(summary = "Deprecated Endpoint", description = "Demonstrates marking an endpoint as deprecated", deprecated = true)
    @GetMapping("/old-feature")
    public String oldFeature() {
        return "This is deprecated";
    }
}

package com.example.argos;

import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

// 클라이언트의 HTTP 요청을 처리하고 ArgosService를 통해 비즈니스 로직을 호출하는 컨트롤러
@RestController
@RequestMapping("/api/v1/argos")
public class ArgosController {

    private final ArgosService argosService;

    public ArgosController(ArgosService argosService) {
        this.argosService = argosService;
    }

    // GET /api/v1/argos/{id} 엔드포인트: 특정 ID의 Argos 데이터를 조회합니다.
    @GetMapping("/{id}")
    public Mono<ArgosData> getArgosData(@PathVariable String id) {
        System.out.println("Received request to get Argos data for ID: " + id);
        return argosService.fetchAndProcessArgosData(id);
    }

    // POST /api/v1/argos 엔드포인트: 새로운 Argos 데이터를 생성하고 전송합니다.
    @PostMapping
    public Mono<ArgosData> createArgosData(@RequestBody ArgosData data) {
        System.out.println("Received request to create Argos data with payload: " + data.getPayload());
        return argosService.createAndSendArgosData(data.getPayload());
    }
}

package com.example.argos;

import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

// Argos 시스템 관련 비즈니스 로직을 처리하는 서비스 계층
// ArgosServiceClient를 주입받아 외부 시스템과의 통신을 추상화하고 비즈니스 규칙을 적용합니다.
@Service
public class ArgosService {

    private final ArgosServiceClient argosServiceClient;

    public ArgosService(ArgosServiceClient argosServiceClient) {
        this.argosServiceClient = argosServiceClient;
    }

    // ID를 기반으로 Argos 데이터를 조회하는 비즈니스 로직
    public Mono<ArgosData> fetchAndProcessArgosData(String id) {
        // 실제 서비스에서는 여기에 추가적인 비즈니스 로직이 들어갈 수 있습니다.
        // 예를 들어, 데이터 유효성 검사, 다른 내부 시스템과의 연동, 데이터 변환 등
        System.out.println("Processing request for Argos data with ID: " + id + " in ArgosService.");
        return argosServiceClient.getArgosData(id)
                .map(data -> {
                    // 조회된 데이터를 가공하는 로직
                    data.setMessage("Processed by ArgosService: " + data.getMessage());
                    return data;
                });
    }

    // 새로운 Argos 데이터를 생성하여 외부 시스템으로 전송하는 비즈니스 로직
    public Mono<ArgosData> createAndSendArgosData(String payload) {
        ArgosData newData = new ArgosData(null, "PENDING", "Data created by system", payload);
        System.out.println("Creating and sending new Argos data: " + newData.getPayload());
        return argosServiceClient.sendArgosData(newData);
    }
}

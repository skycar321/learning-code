package com.example.argos;

import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import io.github.resilience4j.retry.annotation.Retry;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.time.Duration;

// ArgosServiceClient 인터페이스의 실제 구현체
// WebClient를 사용하여 가상의 Argos API를 호출하는 것을 시뮬레이션합니다.
@Component
public class ArgosServiceClientImpl implements ArgosServiceClient {

    private final WebClient webClient;
    private final String argosApiBaseUrl;

    // application.yml/properties에서 argos.api.base-url 설정을 주입받습니다.
    public ArgosServiceClientImpl(WebClient.Builder webClientBuilder,
                                 @Value("${argos.api.base-url:http://localhost:8081/mock-argos}") String argosApiBaseUrl) {
        this.argosApiBaseUrl = argosApiBaseUrl;
        this.webClient = webClientBuilder.baseUrl(argosApiBaseUrl)
                                         .build();
    }

    // @CircuitBreaker: "argosService"라는 이름의 회로 차단기를 적용합니다.
    // 외부 시스템 호출 실패 시 시스템 전체 장애로 이어지지 않도록 보호합니다.
    // @Retry: "argosService"라는 이름의 재시도 정책을 적용합니다.
    // 일시적인 네트워크 문제 등으로 인한 실패 시 자동으로 재시도하여 성공 가능성을 높입니다.
    @Override
    @CircuitBreaker(name = "argosService", fallbackMethod = "getArgosDataFallback")
    @Retry(name = "argosService")
    public Mono<ArgosData> getArgosData(String id) {
        System.out.println("Calling Argos API for id: " + id + " at " + argosApiBaseUrl + "/data/" + id);
        // 실제 외부 API 호출을 시뮬레이션합니다.
        // 여기서는 WebClient를 사용하여 가상의 Mock API를 호출하는 것으로 가정합니다.
        // 실제 Argus 시스템이 있다면 해당 API의 엔드포인트와 응답 구조에 맞게 구현합니다.
        return webClient.get()
                .uri("/data/{id}", id)
                .retrieve()
                .bodyToMono(ArgosData.class)
                .timeout(Duration.ofSeconds(2)); // 2초 타임아웃 설정
    }

    // getArgosData 메서드 실패 시 호출될 Fallback 메서드
    // 외부 시스템 장애 시 사용자에게 기본값 또는 캐시된 데이터를 제공하여
    // 서비스의 가용성을 유지하는 데 사용됩니다.
    private Mono<ArgosData> getArgosDataFallback(String id, Throwable t) {
        System.err.println("Fallback for getArgosData (id: " + id + ") due to: " + t.getMessage());
        // 예를 들어, 캐시에서 데이터를 가져오거나, 기본값을 반환할 수 있습니다.
        return Mono.just(new ArgosData(id, "ERROR", "Argos service unavailable (fallback)", "{}"));
    }

    @Override
    @CircuitBreaker(name = "argosService", fallbackMethod = "sendArgosDataFallback")
    @Retry(name = "argosService")
    public Mono<ArgosData> sendArgosData(ArgosData data) {
        System.out.println("Sending data to Argos API: " + data.getId() + " at " + argosApiBaseUrl + "/data");
        return webClient.post()
                .uri("/data")
                .bodyValue(data)
                .retrieve()
                .bodyToMono(ArgosData.class)
                .timeout(Duration.ofSeconds(3)); // 3초 타임아웃 설정
    }

    // sendArgosData 메서드 실패 시 호출될 Fallback 메서드
    private Mono<ArgosData> sendArgosDataFallback(ArgosData data, Throwable t) {
        System.err.println("Fallback for sendArgosData (id: " + data.getId() + ") due to: " + t.getMessage());
        return Mono.just(new ArgosData(data.getId(), "ERROR", "Argos service unavailable (fallback for send)", "{}"));
    }
}

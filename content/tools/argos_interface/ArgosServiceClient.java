package com.example.argos;

import reactor.core.publisher.Mono;

// Argos 외부 시스템과의 통신을 위한 클라이언트 인터페이스
// 실제로는 REST API 호출, 메시지 전송 등 다양한 통신 방식이 올 수 있습니다.
public interface ArgosServiceClient {

    // Argos 시스템으로부터 데이터를 조회하는 가상의 메서드
    // Mono<ArgosData>는 비동기 및 리액티브 처리를 위한 Reactor 타입입니다.
    Mono<ArgosData> getArgosData(String id);

    // Argos 시스템으로 데이터를 전송하는 가상의 메서드
    Mono<ArgosData> sendArgosData(ArgosData data);
}

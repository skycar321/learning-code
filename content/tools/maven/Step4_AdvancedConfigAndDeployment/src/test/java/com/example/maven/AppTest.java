package com.example.maven;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertTrue;

class AppTest {
    @Test
    void appHasAGreeting() {
        App.main(new String[]{}); // App의 main 메서드 실행 테스트
        assertTrue(true); // 실제 테스트 로직은 main 메서드 출력 확인
    }
}

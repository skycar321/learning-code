package com.example.maven;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertTrue;

class AppIntegrationTest {
    @Test
    void integrationTestRuns() {
        // 이 테스트는 통합 테스트 페이즈에서 실행됩니다.
        System.out.println("AppIntegrationTest is running...");
        assertTrue(true);
    }
}

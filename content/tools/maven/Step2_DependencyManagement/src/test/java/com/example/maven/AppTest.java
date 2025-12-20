package com.example.maven;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;

class AppTest {
    @Test
    void appHasAGreeting() {
        App classUnderTest = new App();
        assertEquals("Hello Maven Dependency Management!", classUnderTest.getGreeting(), "app should have a greeting");
    }
}

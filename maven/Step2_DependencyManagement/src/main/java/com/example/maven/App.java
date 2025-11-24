package com.example.maven;

import com.google.common.base.Strings;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class App {
    private static final Logger logger = LoggerFactory.getLogger(App.class);

    public String getGreeting() {
        return "Hello Maven Dependency Management!";
    }

    public static void main(String[] args) {
        App app = new App();
        logger.info(app.getGreeting());
        // Guava 라이브러리 사용 예시
        logger.info(Strings.repeat("Guava is working! ", 3));
    }
}

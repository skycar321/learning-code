package com.example.gradle.deps;

import lombok.Data; // Lombok 어노테이션

@Data // Getter, Setter, toString, equals, hashCode 등을 자동으로 생성
public class App {
    private String greeting = "Hello World!";

    public static void main(String[] args) {
        App app = new App();
        System.out.println(app.getGreeting());
        // Guava 라이브러리 사용 예시 (컴파일 후 실행 시 확인 가능)
        // System.out.println(com.google.common.base.Strings.repeat("Guava! ", 3));
    }
}

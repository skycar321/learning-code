package com.example.app;

import com.example.lib.Greeter; // library 서브 프로젝트의 Greeter 클래스 임포트

public class App {
    public static void main(String[] args) {
        Greeter greeter = new Greeter();
        System.out.println(greeter.getGreeting()); // library의 기능 사용

        // Guava 라이브러리 사용 예시 (app 프로젝트에 추가된 의존성)
        // System.out.println(com.google.common.base.Strings.repeat("Guava App! ", 2));
    }
}

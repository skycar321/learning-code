package com.example.maven;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class App {
    public static void main(String[] args) {
        System.out.println("Hello Maven Advanced Config and Deployment!");

        // 리소스 필터링을 통해 주입된 프로퍼티 값 읽기
        Properties prop = new Properties();
        try (InputStream input = App.class.getClassLoader().getResourceAsStream("application.properties")) {
            if (input == null) {
                System.out.println("Sorry, unable to find application.properties");
                return;
            }
            prop.load(input);
            System.out.println("Profile: " + prop.getProperty("app.profile"));
            System.out.println("DB URL: " + prop.getProperty("app.db.url"));
            System.out.println("API Endpoint: " + prop.getProperty("app.api.endpoint"));
        } catch (IOException ex) {
            ex.printStackTrace();
        }
    }
}

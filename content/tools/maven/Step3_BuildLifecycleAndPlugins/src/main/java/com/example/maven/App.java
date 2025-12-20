package com.example.maven;

public class App {
    public String getGreeting() {
        return "Hello Maven Build Lifecycle!";
    }

    public static void main(String[] args) {
        System.out.println(new App().getGreeting());
    }
}

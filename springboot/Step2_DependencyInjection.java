// Placeholder for Spring Boot Step 2: DependencyInjection.java
// This file will contain examples and explanations for Dependency Injection in Spring Boot.
// Good Example: Constructor injection, using @Autowired wisely.
// Bad Example: Field injection everywhere without careful consideration.
package com.example.springboot;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class Step2_DependencyInjection {

    private final MyService myService;

    // Good Example: Constructor Injection (recommended)
    public Step2_DependencyInjection(MyService myService) {
        this.myService = myService;
    }

    // Bad Example: Field Injection (can hide dependencies, harder to test)
    // @Autowired
    // private AnotherService anotherService;

    public void performAction() {
        myService.doSomething();
    }
}

@Service
class MyService {
    public void doSomething() {
        System.out.println("MyService is doing something.");
    }
}

// class AnotherService {
//     public void doAnotherThing() {
//         System.out.println("AnotherService is doing another thing.");
//     }
// }

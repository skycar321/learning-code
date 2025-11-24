// kotlin/JavaInteroperability.java
// Step5_JavaInteroperabilityAndAdvancedTopics.kt 파일에서 참조하는 Java 코드 예시입니다.
// Kotlin과 Java 코드 간의 상호 운용성을 보여주기 위해 사용됩니다.

package com.example.kotlinadvanced;

import java.io.IOException;

public class JavaInteroperability {
    private String javaName;
    private int javaAge;

    public JavaInteroperability(String javaName, int javaAge) {
        this.javaName = javaName;
        this.javaAge = javaAge;
    }

    public String getJavaName() {
        return javaName;
    }

    public void setJavaName(String javaName) {
        this.javaName = javaName;
    }

    public int getJavaAge() {
        return javaAge;
    }

    public void setJavaAge(int javaAge) {
        this.javaAge = javaAge;
    }

    public void printMessage(String message) {
        System.out.println("Java에서 받은 메시지: " + message);
    }

    public static String getStaticMessage() {
        return "Java의 정적 메시지";
    }

    // Checked Exception 예시 (Kotlin에서 다룰 때 차이점)
    public void throwCheckedException() throws IOException {
        throw new IOException("Java Checked Exception 발생!");
    }
}

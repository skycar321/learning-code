package com.example.lib;

import org.apache.commons.lang3.StringUtils; // commons-lang3 라이브러리 사용

public class Greeter {
    public String getGreeting() {
        // Apache Commons Lang의 StringUtils를 사용
        // StringUtils.capitalize는 문자열의 첫 글자를 대문자로 만듭니다.
        return StringUtils.capitalize("hello from library!");
    }
}

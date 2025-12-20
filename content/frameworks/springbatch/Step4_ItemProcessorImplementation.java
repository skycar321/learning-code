// Spring Batch Step 4: ItemProcessorImplementation.java
// 비즈니스 로직을 포함하는 ItemProcessor 작성 및 데이터 변환 처리를 학습합니다.
// 좋은 예시: 불필요한 데이터를 필터링하거나, 데이터를 다른 형식으로 변환하는 명확한 비즈니스 규칙을 구현합니다.
// 나쁜 예시: Processor 내에서 과도한 비즈니스 로직을 처리하거나, Reader/Writer의 역할을 침범합니다.
package com.example.springbatch;

import org.springframework.batch.item.ItemProcessor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class Step4_ItemProcessorImplementation {

    // Person 객체를 PersonDto 객체로 변환하고, 특정 조건을 만족하는 데이터만 필터링하는 ItemProcessor 예시
    @Bean
    public ItemProcessor<Person, PersonDto> personItemProcessor() {
        return new ItemProcessor<Person, PersonDto>() {
            @Override
            public PersonDto process(Person person) throws Exception {
                // 이름이 "John"인 사람만 처리하고 나머지는 null (필터링)
                if ("John".equalsIgnoreCase(person.getFirstName())) {
                    return new PersonDto(person.getFirstName() + " " + person.getLastName(), "Active");
                }
                return null; // null을 반환하면 해당 아이템은 Writer로 전달되지 않고 스킵됩니다.
            }
        };
    }
}

class PersonDto {
    private String fullName;
    private String status;

    public PersonDto() {}

    public PersonDto(String fullName, String status) {
        this.fullName = fullName;
        this.status = status;
    }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    @Override
    public String toString() {
        return "PersonDto [fullName=" + fullName + ", status=" + status + "]";
    }
}

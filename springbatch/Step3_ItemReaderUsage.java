// Spring Batch Step 3: ItemReaderUsage.java
// 다양한 ItemReader (JdbcPagingItemReader, FlatFileItemReader 등) 사용법을 학습합니다.
// 좋은 예시: 데이터 소스에 따라 적절한 ItemReader를 선택하고, 커서 기반/페이징 기반 리더를 활용하여 메모리 효율적으로 데이터를 읽습니다.
// 나쁜 예시: 대량의 데이터를 한 번에 메모리에 로드하는 ItemReader를 사용하여 OutOfMemoryError를 발생시킵니다.
package com.example.springbatch;

import org.springframework.batch.item.ItemReader;
import org.springframework.batch.item.file.FlatFileItemReader;
import org.springframework.batch.item.file.builder.FlatFileItemReaderBuilder;
import org.springframework.batch.item.file.mapping.BeanWrapperFieldSetMapper;
import org.springframework.batch.item.file.mapping.DefaultLineMapper;
import org.springframework.batch.item.file.transform.DelimitedLineTokenizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;

@Configuration
public class Step3_ItemReaderUsage {

    // CSV 파일에서 데이터를 읽는 FlatFileItemReader 예시
    @Bean
    public FlatFileItemReader<Person> flatFileItemReader() {
        return new FlatFileItemReaderBuilder<Person>()
                .name("personItemReader")
                .resource(new ClassPathResource("persons.csv")) // resources/persons.csv 파일 가정
                .delimited()
                .names(new String[]{"firstName", "lastName"}) // CSV 헤더 정의
                .fieldSetMapper(new BeanWrapperFieldSetMapper<Person>() {{
                    setTargetType(Person.class);
                }})
                .build();
    }

    // JDBC에서 페이징 기반으로 데이터를 읽는 JdbcPagingItemReader (설정만 예시)
    // 실제 사용 시 DataSource, PagingQueryProvider 등이 필요
    /*
    @Bean
    public JdbcPagingItemReader<User> jdbcPagingItemReader(DataSource dataSource, PlatformTransactionManager transactionManager) {
        return new JdbcPagingItemReaderBuilder<User>()
                .name("userItemReader")
                .dataSource(dataSource)
                .fetchSize(100) // 한 번에 가져올 데이터 수
                .rowMapper(new BeanPropertyRowMapper<>(User.class))
                .queryProvider(new SqlPagingQueryProviderFactoryBean() {{
                    setDataSource(dataSource);
                    setSelectClause("id, name, age");
                    setFromClause("from users");
                    setSortKeys(Collections.singletonMap("id", Order.ASCENDING));
                }}.getObject())
                .build();
    }
    */
}

class Person {
    private String firstName;
    private String lastName;

    public Person() {}

    public Person(String firstName, String lastName) {
        this.firstName = firstName;
        this.lastName = lastName;
    }

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }
    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }

    @Override
    public String toString() {
        return "Person [firstName=" + firstName + ", lastName=" + lastName + "]";
    }
}

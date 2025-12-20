// Spring Batch Step 5: ItemWriterUsage.java
// 다양한 ItemWriter (JdbcBatchItemWriter, FlatFileItemWriter 등) 사용법을 학습합니다.
// 좋은 예시: 청크 단위로 데이터를 효율적으로 데이터베이스에 삽입하거나 파일에 기록합니다.
// 나쁜 예시: ItemWriter 내에서 건별로 커밋하거나, I/O 작업 시 성능을 고려하지 않습니다.
package com.example.springbatch;

import org.springframework.batch.item.ItemWriter;
import org.springframework.batch.item.file.FlatFileItemWriter;
import org.springframework.batch.item.file.builder.FlatFileItemWriterBuilder;
import org.springframework.batch.item.file.transform.DelimitedLineAggregator;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.FileSystemResource;

@Configuration
public class Step5_ItemWriterUsage {

    // PersonDto 객체를 CSV 파일로 쓰는 FlatFileItemWriter 예시
    @Bean
    public FlatFileItemWriter<PersonDto> flatFileItemWriter() {
        return new FlatFileItemWriterBuilder<PersonDto>()
                .name("personDtoItemWriter")
                .resource(new FileSystemResource("output/processed_persons.csv")) // output 디렉토리에 파일 생성
                .lineAggregator(new DelimitedLineAggregator<PersonDto>() {{
                    setDelimiter(",");
                    setFieldExtractor(item -> new Object[]{item.getFullName(), item.getStatus()});
                }})
                .build();
    }

    // 데이터베이스에 쓰는 JdbcBatchItemWriter (설정만 예시)
    // 실제 사용 시 DataSource, PreparedStatementSetter 등이 필요
    /*
    @Bean
    public JdbcBatchItemWriter<PersonDto> jdbcBatchItemWriter(DataSource dataSource) {
        return new JdbcBatchItemWriterBuilder<PersonDto>()
                .dataSource(dataSource)
                .sql("INSERT INTO processed_persons (full_name, status) VALUES (:fullName, :status)")
                .beanMapped() // PersonDto 객체의 필드와 SQL 파라미터를 매핑
                .build();
    }
    */
}

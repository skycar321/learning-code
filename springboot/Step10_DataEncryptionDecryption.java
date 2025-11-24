// Step10_DataEncryptionDecryption.java
// Spring Boot 데이터 암복호화 학습을 위한 코드 예시입니다.
// 이 파일은 AES-256 GCM과 같은 대칭키 암호화 알고리즘을 사용하여
// 민감 데이터를 안전하게 암호화하고 복호화하는 방법을 보여줍니다.
// 또한, Spring 환경에서 암복호화 유틸리티를 통합하는 개념을 다룹니다.
//
// 민감 데이터 보호는 현대 애플리케이션 보안에서 매우 중요한 요소입니다.
// 데이터베이스에 저장되거나 네트워크를 통해 전송되는 개인 정보, 금융 정보 등을
// 암호화하여 데이터 유출 시에도 정보가 보호되도록 해야 합니다.

package com.example.encryptiondecryption;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.stereotype.Service;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

// -----------------------------------------------------------------------------
// 학습 포인트 1: AES-256 GCM 암호화 구현
// - 대칭키 암호화: 암호화와 복호화에 동일한 키를 사용합니다.
// - AES (Advanced Encryption Standard): 현재 가장 널리 사용되는 강력한 블록 암호 알고리즘.
// - GCM (Galois/Counter Mode): 인증된 암호화(Authenticated Encryption) 모드로,
//   데이터의 기밀성(Confidentiality)과 무결성(Integrity), 인증(Authenticity)을 동시에 제공합니다.
// - IV (Initialization Vector): 암호화 시마다 달라지는 랜덤 값으로, 동일한 평문이더라도
//   항상 다른 암호문이 생성되도록 하여 패턴 분석을 어렵게 합니다.
// - Tag: GCM 모드에서 생성되는 인증 태그로, 데이터 변조 여부를 확인하는 데 사용됩니다.
// -----------------------------------------------------------------------------
@Service
class AesGcmEncryptor {

    private static final String ALGORITHM = "AES/GCM/NoPadding";
    private static final int GCM_IV_LENGTH = 12; // GCM 권장 IV 길이 12바이트
    private static final int GCM_TAG_LENGTH = 16; // GCM 권장 Tag 길이 16바이트 (128비트)

    private SecretKey secretKey; // 암호화/복호화에 사용할 비밀 키

    // 실제 환경에서는 키를 하드코딩하지 않고, 환경 변수, Azure Key Vault, AWS KMS 등에서 안전하게 로드해야 합니다.
    // 여기서는 학습 목적으로 간단히 생성하거나 설정 파일에서 주입받습니다.
    public AesGcmEncryptor(@Value("${app.encryption.key:}") String base64Key) throws NoSuchAlgorithmException {
        if (base64Key.isEmpty()) {
            this.secretKey = generateNewKey(); // 키가 없으면 새로 생성
            System.out.println("새로운 암호화 키가 생성되었습니다 (학습 목적): " + Base64.getEncoder().encodeToString(secretKey.getEncoded()));
        } else {
            byte[] decodedKey = Base64.getDecoder().decode(base64Key);
            this.secretKey = new SecretKeySpec(decodedKey, "AES");
            System.out.println("설정 파일에서 암호화 키를 로드했습니다.");
        }
    }

    // 새로운 AES 키 생성
    private SecretKey generateNewKey() throws NoSuchAlgorithmException {
        KeyGenerator keyGen = KeyGenerator.getInstance("AES");
        keyGen.init(256, SecureRandom.getInstanceStrong()); // AES-256 비트 키
        return keyGen.generateKey();
    }

    // 평문 데이터를 암호화합니다.
    // 결과는 "IV + 암호문 + Tag"를 합친 형태로 Base64 인코딩하여 반환합니다.
    public String encrypt(String plainText) throws Exception {
        byte[] iv = new byte[GCM_IV_LENGTH];
        (new SecureRandom()).nextBytes(iv); // 암호화 시마다 새로운 IV 생성

        Cipher cipher = Cipher.getInstance(ALGORITHM);
        GCMParameterSpec parameterSpec = new GCMParameterSpec(GCM_TAG_LENGTH * 8, iv); // Tag 길이는 비트 단위
        cipher.init(Cipher.ENCRYPT_MODE, secretKey, parameterSpec);

        byte[] cipherText = cipher.doFinal(plainText.getBytes(StandardCharsets.UTF_8));

        // IV와 암호문, Tag를 합쳐서 Base64 인코딩합니다.
        // 복호화 시 IV를 분리하여 사용해야 합니다.
        ByteBuffer byteBuffer = ByteBuffer.allocate(iv.length + cipherText.length);
        byteBuffer.put(iv);
        byteBuffer.put(cipherText);
        return Base64.getEncoder().encodeToString(byteBuffer.array());
    }

    // 암호화된 데이터를 복호화합니다.
    // "IV + 암호문 + Tag" 형태의 Base64 인코딩된 문자열을 받아 복호화합니다.
    public String decrypt(String encryptedText) throws Exception {
        byte[] decodedBytes = Base64.getDecoder().decode(encryptedText);

        ByteBuffer byteBuffer = ByteBuffer.wrap(decodedBytes);
        byte[] iv = new byte[GCM_IV_LENGTH];
        byteBuffer.get(iv); // 앞에서 GCM_IV_LENGTH 만큼 IV를 추출

        byte[] cipherText = new byte[byteBuffer.remaining()];
        byteBuffer.get(cipherText); // 나머지 바이트는 암호문 (Tag 포함)

        Cipher cipher = Cipher.getInstance(ALGORITHM);
        GCMParameterSpec parameterSpec = new GCMParameterSpec(GCM_TAG_LENGTH * 8, iv);
        cipher.init(Cipher.DECRYPT_MODE, secretKey, parameterSpec);

        byte[] plainText = cipher.doFinal(cipherText);
        return new String(plainText, StandardCharsets.UTF_8);
    }

    // 키를 외부로 노출하지 않기 위한 안전한 방법 (학습용)
    public String getKeyInfo() {
        return "Key Algorithm: " + secretKey.getAlgorithm() + ", Key Size: " + (secretKey.getEncoded().length * 8) + " bits";
    }
}


// -----------------------------------------------------------------------------
// 학습 포인트 2: Spring 환경에서 암복호화 유틸리티 통합
// - `@Value`를 사용하여 `application.properties` 또는 `application.yml`에서
//   암호화 키를 주입받아 사용할 수 있습니다.
// - `@Configuration` 클래스에 `@Bean`으로 등록하여 필요한 곳에 주입받아 사용합니다.
// -----------------------------------------------------------------------------
@Configuration
class EncryptionConfig {
    // app.encryption.key는 application.properties에서 설정됩니다.
    // 예: app.encryption.key=BASE64_ENCODED_AES_KEY
    @Bean
    public AesGcmEncryptor aesGcmEncryptor(@Value("${app.encryption.key:}") String base64Key) throws NoSuchAlgorithmException {
        return new AesGcmEncryptor(base64Key);
    }
}


// -----------------------------------------------------------------------------
// 예시 서비스: UserService (민감 데이터 저장 및 조회)
// -----------------------------------------------------------------------------
@Service
class UserService {
    private final AesGcmEncryptor encryptor;
    private final Map<Long, UserData> userDatabase = new ConcurrentHashMap<>();
    private long nextId = 1;

    public UserService(AesGcmEncryptor encryptor) {
        this.encryptor = encryptor;
    }

    // 사용자 데이터를 암호화하여 저장
    public UserData saveUser(String email, String phoneNumber, String password) throws Exception {
        Long id = nextId++;
        String encryptedEmail = encryptor.encrypt(email);
        String encryptedPhoneNumber = encryptor.encrypt(phoneNumber);
        // 비밀번호는 단방향 해싱 (예: BCrypt) 후 저장하는 것이 일반적이지만,
        // 여기서는 양방향 암복호화 예시를 위해 암호화하여 저장. 실제로는 해싱 권장.
        String encryptedPassword = encryptor.encrypt(password);

        UserData userData = new UserData(id, encryptedEmail, encryptedPhoneNumber, encryptedPassword);
        userDatabase.put(id, userData);
        System.out.println("사용자 저장 (암호화된 데이터): " + userData);
        return userData;
    }

    // 사용자 데이터를 복호화하여 조회
    public UserData getDecryptedUser(Long id) throws Exception {
        UserData encryptedUserData = userDatabase.get(id);
        if (encryptedUserData == null) {
            return null;
        }

        String decryptedEmail = encryptor.decrypt(encryptedUserData.getEncryptedEmail());
        String decryptedPhoneNumber = encryptor.decrypt(encryptedUserData.getEncryptedPhoneNumber());
        String decryptedPassword = encryptor.decrypt(encryptedUserData.getEncryptedPassword()); // 실제 사용 시 해싱된 비밀번호는 복호화 불필요

        return new UserData(id, decryptedEmail, decryptedPhoneNumber, decryptedPassword);
    }

    // 나쁜 예시: 민감 데이터를 평문으로 저장하거나, 간단한 인코딩/디코딩만 사용하는 경우
    // - 데이터 유출 시 심각한 보안 문제가 발생합니다.
    // - Base64는 인코딩이지 암호화가 아님을 인지해야 합니다.
    public void saveUserBadExample(String email, String phoneNumber) {
        Long id = nextId++;
        String base64EncodedEmail = Base64.getEncoder().encodeToString(email.getBytes(StandardCharsets.UTF_8));
        String base64EncodedPhoneNumber = Base64.getEncoder().encodeToString(phoneNumber.getBytes(StandardCharsets.UTF_8));

        System.out.println("나쁜 예시 - 사용자 저장 (Base64 인코딩):");
        System.out.println("  ID: " + id + ", Email: " + base64EncodedEmail + ", Phone: " + base64EncodedPhoneNumber);
    }
}

// 사용자 데이터 모델 (저장 시 암호화된 필드를 가집니다)
class UserData {
    private Long id;
    private String encryptedEmail;
    private String encryptedPhoneNumber;
    private String encryptedPassword;

    public UserData(Long id, String encryptedEmail, String encryptedPhoneNumber, String encryptedPassword) {
        this.id = id;
        this.encryptedEmail = encryptedEmail;
        this.encryptedPhoneNumber = encryptedPhoneNumber;
        this.encryptedPassword = encryptedPassword;
    }

    public Long getId() { return id; }
    public String getEncryptedEmail() { return encryptedEmail; }
    public String getEncryptedPhoneNumber() { return encryptedPhoneNumber; }
    public String getEncryptedPassword() { return encryptedPassword; }

    @Override
    public String toString() {
        return "UserData{"
               + "id=" + id +
               ", email='" + encryptedEmail + "'"
               + ", phoneNumber='" + encryptedPhoneNumber + "'"
               + ", password='" + encryptedPassword + "'"
               + '}'
    }
}


@SpringBootApplication
public class DataEncryptionDecryptionApplication {

    public static void main(String[] args) {
        // SpringApplication.run 전에 암호화 키 환경 변수를 설정할 수 있습니다.
        // 또는 application.properties에 app.encryption.key=... 와 같이 설정할 수 있습니다.
        // System.setProperty("app.encryption.key", "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789==");
        SpringApplication.run(DataEncryptionDecryptionApplication.class, args);
    }

    // CommandLineRunner를 사용하여 애플리케이션 시작 시 테스트 코드 실행
    @Bean
    public org.springframework.boot.CommandLineRunner run(UserService userService) {
        return args -> {
            System.out.println("--- 데이터 암복호화 예제 실행 ---");

            // 나쁜 예시 테스트
            System.out.println("\n[나쁜 예시: 평문 또는 Base64 인코딩 데이터 저장]");
            userService.saveUserBadExample("bad_example@test.com", "010-1234-5678");

            // 좋은 예시 테스트
            System.out.println("\n[좋은 예시: AES-256 GCM 암호화 데이터 저장 및 복호화]");
            try {
                UserData savedUser = userService.saveUser("user@example.com", "010-1111-2222", "myStrongPassword123!");
                System.out.println("저장된 사용자 ID: " + savedUser.getId());

                UserData decryptedUser = userService.getDecryptedUser(savedUser.getId());
                System.out.println("복호화된 사용자 이메일: " + decryptedUser.getEncryptedEmail());
                System.out.println("복호화된 사용자 전화번호: " + decryptedUser.getEncryptedPhoneNumber());
                System.out.println("복호화된 사용자 비밀번호: " + decryptedUser.getEncryptedPassword());

                // 존재하지 않는 사용자 조회 시
                UserData nonExistentUser = userService.getDecryptedUser(99L);
                System.out.println("존재하지 않는 사용자 조회 결과: " + nonExistentUser);

                // 동일한 평문을 여러 번 암호화해도 다른 암호문이 생성됨을 확인 (IV 덕분)
                String plainEmail = "test@test.com";
                String encryptedEmail1 = userService.encryptor.encrypt(plainEmail);
                String encryptedEmail2 = userService.encryptor.encrypt(plainEmail);
                System.out.println("\n동일 평문 암호화 (IV 효과):");
                System.out.println("  평문: " + plainEmail);
                System.out.println("  암호문1: " + encryptedEmail1);
                System.out.println("  암호문2: " + encryptedEmail2);
                System.out.println("  암호문1 == 암호문2 ? " + encryptedEmail1.equals(encryptedEmail2)); // false 예상

            } catch (Exception e) {
                System.err.println("암복호화 중 오류 발생: " + e.getMessage());
                e.printStackTrace();
            }

            System.out.println("\n--- 데이터 암복호화 예제 완료 ---");
        };
    }
}

/*
이 애플리케이션을 실행하기 전에 `application.properties`에 암호화 키를 설정하거나,
`main` 메서드 내의 `System.setProperty`를 통해 설정할 수 있습니다.

application.properties 예시:
app.encryption.key=YOUR_BASE64_ENCODED_AES_256_KEY_HERE
(키가 없으면 애플리케이션 시작 시 자동으로 생성되어 콘솔에 출력됩니다. 이를 복사하여 사용하세요.)

키 생성 예시 (Java):
SecretKey secretKey = KeyGenerator.getInstance("AES").generateKey();
String base64Key = Base64.getEncoder().encodeToString(secretKey.getEncoded());
System.out.println(base64Key); // 이 값을 application.properties에 붙여넣으세요.

테스트 결과:
- "나쁜 예시"는 단순히 Base64 인코딩된 데이터를 출력.
- "좋은 예시"는 암호화된 데이터를 저장하고, 조회 시 복호화하여 평문 데이터를 출력.
- 동일한 평문을 두 번 암호화했을 때 다른 암호문이 생성되는 것을 확인하여 IV의 역할 이해.
*/

package com.example.springboot;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * ========================================================================================
 * Step 10: 데이터 암복호화 (Encryption) & 해싱 (Hashing) A-Z 완전 정복
 * ========================================================================================
 *
 * 이 파일은 민감한 정보(개인정보, 비밀번호)를 안전하게 다루는 방법을 다룹니다.
 * "암호화(Encryption)"와 "해싱(Hashing)"의 결정적인 차이를 이해하는 것이 핵심입니다.
 *
 * [학습 목표]
 * 1. **암호화(양방향)**와 **해싱(단방향)**을 언제 써야 하는지 구분합니다.
 * 2. **AES-256 GCM** 알고리즘을 사용하여 안전하게 데이터를 암복호화하는 유틸리티를 만듭니다.
 * 3. **IV(Initialization Vector)**가 왜 필수적이며, 랜덤이어야 하는지 이해합니다.
 * 4. 실무에서 절대 하지 말아야 할 "나쁜 암호화 습관"을 배웁니다.
 */

@SpringBootApplication
public class Step10_DataEncryptionDecryption {
    public static void main(String[] args) {
        SpringApplication.run(Step10_DataEncryptionDecryption.class, args);
    }

    @Bean
    CommandLineRunner test(CryptoService cryptoService, PasswordService passwordService) {
        return args -> {
            System.out.println("===== 1. 양방향 암호화 (AES-256) =====");
            String phone = "010-1234-5678";
            String encrypted = cryptoService.encrypt(phone);
            String decrypted = cryptoService.decrypt(encrypted);
            System.out.println("원본: " + phone);
            System.out.println("암호화: " + encrypted);
            System.out.println("복호화: " + decrypted);

            System.out.println("\n===== 2. 단방향 해싱 (BCrypt) =====");
            String password = "mySecretPassword";
            String hash = passwordService.hashPassword(password);
            System.out.println("비밀번호: " + password);
            System.out.println("해시값: " + hash);
            System.out.println("검증 결과: " + passwordService.matches(password, hash));
        };
    }
}

// ========================================================================================
// 1. [BAD Example] 잘못된 암호화 방식
// ========================================================================================

class BadCryptoExample {
    /**
     * [실수 1: 비밀번호를 '암호화'해서 저장함]
     * 비밀번호는 절대 복호화할 수 있으면 안 됩니다. (관리자도 몰라야 함)
     * AES로 암호화하면 키가 유출됐을 때 모든 비밀번호가 털립니다.
     * -> 해결: 해싱(Hashing)을 써야 합니다.
     */
    public String encryptPassword(String password) {
        return "AES_ENCRYPTED_" + password; // 절대 금지!
    }

    /**
     * [실수 2: ECB 모드 사용 & 고정 IV]
     * ECB 모드는 같은 평문이 항상 같은 암호문으로 나옵니다. (패턴 분석 가능)
     * -> 해결: CBC 또는 GCM 모드를 쓰고, 매번 랜덤 IV를 생성해야 합니다.
     */
    public void useWeakAlgorithm() {
        // Cipher.getInstance("AES/ECB/PKCS5Padding"); // 사용 금지
    }
    
    /**
     * [실수 3: 키 하드코딩]
     * 소스코드에 키를 적어두면 깃허브에 올리는 순간 전 세계에 공개됩니다.
     * -> 해결: 환경 변수나 Key Vault 서비스 사용.
     */
    private String secretKey = "1234567812345678"; // 절대 금지!
}

// ========================================================================================
// 2. [GOOD Example] 안전한 데이터 암호화 (AES-256 GCM)
// ========================================================================================

@Component
class CryptoService {
    // 알고리즘: AES, 모드: GCM (데이터 무결성 보장), 패딩: NoPadding
    private static final String ALGORITHM = "AES/GCM/NoPadding";
    private static final int TAG_LENGTH_BIT = 128; // GCM 인증 태그 길이
    private static final int IV_LENGTH_BYTE = 12;  // GCM 권장 IV 길이

    private final SecretKey secretKey;

    // 실제로는 @Value("${encryption.key}")로 주입받아야 함
    public CryptoService() {
        // 테스트용 임시 키 (32바이트 = 256비트)
        byte[] keyBytes = "12345678901234561234567890123456".getBytes(StandardCharsets.UTF_8);
        this.secretKey = new SecretKeySpec(keyBytes, "AES");
    }

    public String encrypt(String plainText) {
        try {
            // 1. 랜덤 IV 생성 (매번 달라야 함!)
            byte[] iv = new byte[IV_LENGTH_BYTE];
            new SecureRandom().nextBytes(iv);

            // 2. 암호화 설정
            Cipher cipher = Cipher.getInstance(ALGORITHM);
            GCMParameterSpec spec = new GCMParameterSpec(TAG_LENGTH_BIT, iv);
            cipher.init(Cipher.ENCRYPT_MODE, secretKey, spec);

            // 3. 암호화 수행
            byte[] cipherText = cipher.doFinal(plainText.getBytes(StandardCharsets.UTF_8));

            // 4. 결과물에 IV를 붙여서 반환 (복호화할 때 필요함)
            // 포맷: [IV (12byte)] + [Cipher Text]
            byte[] combined = new byte[iv.length + cipherText.length];
            System.arraycopy(iv, 0, combined, 0, iv.length);
            System.arraycopy(cipherText, 0, combined, iv.length, cipherText.length);

            return Base64.getEncoder().encodeToString(combined);

        } catch (Exception e) {
            throw new RuntimeException("암호화 실패", e);
        }
    }

    public String decrypt(String encryptedText) {
        try {
            byte[] decoded = Base64.getDecoder().decode(encryptedText);

            // 1. 앞부분에서 IV 추출
            byte[] iv = new byte[IV_LENGTH_BYTE];
            System.arraycopy(decoded, 0, iv, 0, IV_LENGTH_BYTE);

            // 2. 뒷부분에서 암호문 추출
            int cipherTextLength = decoded.length - IV_LENGTH_BYTE;
            byte[] cipherText = new byte[cipherTextLength];
            System.arraycopy(decoded, IV_LENGTH_BYTE, cipherText, 0, cipherTextLength);

            // 3. 복호화 설정
            Cipher cipher = Cipher.getInstance(ALGORITHM);
            GCMParameterSpec spec = new GCMParameterSpec(TAG_LENGTH_BIT, iv);
            cipher.init(Cipher.DECRYPT_MODE, secretKey, spec);

            // 4. 복호화 수행
            byte[] plainText = cipher.doFinal(cipherText);
            return new String(plainText, StandardCharsets.UTF_8);

        } catch (Exception e) {
            throw new RuntimeException("복호화 실패 (키가 틀리거나 데이터가 변조됨)", e);
        }
    }
}

// ========================================================================================
// 3. [GOOD Example] 안전한 비밀번호 해싱 (BCrypt)
// ========================================================================================

@Service
class PasswordService {
    private final PasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    /**
     * [해싱(Hashing)]
     * - 단방향이므로 복호화가 불가능합니다.
     * - 같은 비밀번호라도 매번 다른 결과(Salt)가 나옵니다. (Rainbow Table 공격 방지)
     */
    public String hashPassword(String rawPassword) {
        return passwordEncoder.encode(rawPassword);
    }

    /**
     * [검증]
     * 사용자가 입력한 비밀번호를 해시해서 DB에 있는 해시값과 비교합니다.
     */
    public boolean matches(String rawPassword, String encodedPassword) {
        return passwordEncoder.matches(rawPassword, encodedPassword);
    }
}
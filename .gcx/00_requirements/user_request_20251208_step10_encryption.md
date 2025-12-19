# User Request
**Date**: 2025-12-08
**Requester**: User
**Project**: Learning Platform (Spring Boot)

## Original Request
(Continuing bulk update Steps 1-14)

## Scope
- **Target**: `content/frameworks/springboot/Step10_DataEncryptionDecryption.java`

## Requirements for Step 10
1.  **Concept Explanation**: Hashing (One-way) vs Encryption (Two-way). Symmetric (AES) vs Asymmetric (RSA).
2.  **Good vs Bad**:
    - *Bad*: Hardcoding keys. Using weak algorithms (DES, AES-ECB). Encrypting passwords (should be hashed).
    - *Good*: Using AES-256 GCM. Managing keys via Environment Variables. Creating a Thread-safe Crypto Service.
3.  **Codex Role**: Audit the crypto implementation (IV usage, algorithm choice security).

## Protocol
Modified GCX (Gemini Draft -> Codex Audit -> Gemini Finalize).

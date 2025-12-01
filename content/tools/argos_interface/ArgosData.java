package com.example.argos;

import java.time.LocalDateTime;

// Argos 시스템과 주고받을 데이터를 정의하는 DTO (Data Transfer Object)
// 실제 Argos 시스템의 응답/요청 스키마에 따라 유연하게 변경될 수 있습니다.
public class ArgosData {
    private String id;
    private String status;
    private String message;
    private LocalDateTime timestamp;
    private String payload; // Argos에서 전달하는 실제 데이터 내용

    public ArgosData() {
    }

    public ArgosData(String id, String status, String message, String payload) {
        this.id = id;
        this.status = status;
        this.message = message;
        this.timestamp = LocalDateTime.now();
        this.payload = payload;
    }

    // Getters and Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }

    public String getPayload() {
        return payload;
    }

    public void setPayload(String payload) {
        this.payload = payload;
    }

    @Override
    public String toString() {
        return "ArgosData{" +
               "id='" + id + "'" +
               ", status='" + status + "'" +
               ", message='" + message + "'" +
               ", timestamp=" + timestamp +
               ", payload='" + payload + "'" +
               '}';
    }
}

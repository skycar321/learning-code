# Step 6: 보안 및 운영 체크리스트 (Security & Checklist)

로컬에선 필요 없지만, 프로덕션 오픈 전에 반드시 확인해야 할 리스트입니다.

## 1. Security Overview

Kafka는 기본적으로 인증/인가가 없습니다(PLAINTEXT). 누구나 접속해서 데이터를 지울 수 있습니다.

### 1.1 Encryption (SSL/TLS)
- 클라이언트와 브로커 간의 통신 암호화.
- 성능 저하가 있으므로(CPU 사용량 약 20% 증가), 내부망이라면 제외하기도 함.

### 1.2 Authentication (SASL)
- **SASL/PLAIN**: 아이디/비번 방식. 간단하지만 비밀번호 관리가 필요.
- **SASL/SCRAM**: 비밀번호를 해시(Salt)해서 전송. 더 안전함.
- **mTLS**: 인증서를 교환하여 상호 인증. 가장 강력하지만 관리 복잡.

### 1.3 Authorization (ACL)
- "User A는 Topic B에 대해 Read만 가능하고 Write는 불가능"과 같은 권한 제어.
- `kafka-acls.sh` 명령어로 관리.

---

## 2. Production Checklist (오픈 전 확인)

- [ ] **Replication Factor**: 최소 3인가? (`min.insync.replicas`는 2인가?)
- [ ] **Unclean Leader Election**: `false`로 되어 있는가? (데이터 유실 방지)
- [ ] **Disk Usage**: 로그 보관 주기(`retention.ms`)에 따른 디스크 용량 산정이 되었는가?
- [ ] **Monitoring**: JMX Exporter 등을 통해 Grafana/Prometheus 연동이 되었는가?
    - **필수 지표**: `Under Replicated Partitions` (0이어야 함), `Consumer Lag` (0에 가까워야 함).
- [ ] **Network**: 브로커 간 통신 대역폭은 충분한가? (10GbE 권장)

---

## 3. 마치며

Kafka는 "설정(Configuration)의 예술"입니다. 기본값으로도 잘 돌아가지만, 트래픽이 튀는 순간 설정값 하나가 전체 장애를 부를 수도, 막을 수도 있습니다.
제공된 Good/Bad 예제를 기반으로, 여러분의 환경에 맞는 최적의 값을 찾아가시길 바랍니다.

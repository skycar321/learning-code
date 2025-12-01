#!/bin/bash

# nginx/Step4_SSLTLSAndSecurity/generate-certs.sh
# Nginx 학습 계획 - 4단계: SSL/TLS 설정 및 보안
# 이 스크립트는 Nginx에서 HTTPS 설정을 위해 자체 서명된 SSL/TLS 인증서 및 개인 키를 생성합니다.
#
# 이 인증서는 개발 및 테스트 목적으로 사용되며, 실제 프로덕션 환경에서는 Let's Encrypt와 같은
# 신뢰할 수 있는 CA(Certificate Authority)에서 발급받은 인증서를 사용해야 합니다.

echo "--- 자체 서명 SSL/TLS 인증서 생성 스크립트 시작 ---"

# certs 디렉토리가 없으면 생성
mkdir -p certs

# OpenSSL을 사용하여 자체 서명 인증서와 개인 키 생성
# -x509: X.509 인증서 요청을 생성하지 않고 자체 서명 인증서를 직접 생성
# -nodes: 개인 키를 암호화하지 않음 (passphrase 없음)
# -days 365: 인증서 유효 기간 365일
# -newkey rsa:2048: 2048비트 RSA 개인 키 생성
# -keyout certs/nginx.key: 생성될 개인 키 파일 경로
# -out certs/nginx.crt: 생성될 인증서 파일 경로
# -subj "/CN=localhost": 인증서의 Common Name (CN)을 localhost로 설정
#                         (실제 도메인 사용 시 /CN=your.domain.com 으로 변경)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout certs/nginx.key -out certs/nginx.crt -subj "/CN=localhost"

if [ $? -eq 0 ]; then
    echo "자체 서명 SSL/TLS 인증서 및 개인 키가 'certs/' 디렉토리에 성공적으로 생성되었습니다."
    echo "  - certs/nginx.key (개인 키)"
    echo "  - certs/nginx.crt (인증서)"
    echo ""
    echo "주의: 이 인증서는 개발/테스트용입니다. 프로덕션에서는 사용하지 마세요!"
else
    echo "인증서 생성 중 오류가 발생했습니다."
    exit 1
fi

echo "--- 자체 서명 SSL/TLS 인증서 생성 스크립트 완료 ---"

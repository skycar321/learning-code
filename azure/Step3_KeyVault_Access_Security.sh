#!/bin/bash

# Azure Key Vault 접근 정책 및 보안 스크립트 예시
# 이 스크립트는 Azure Key Vault 학습 계획의 3단계인 '접근 정책 및 보안'을 위한
# 개념적인 Azure CLI 명령어들을 포함하고 있습니다.
# 실제 환경에서는 구독 ID, 리소스 그룹 이름, Key Vault 이름 등을 환경에 맞게
# 설정하고 실행해야 합니다.

echo "--- 3단계: Key Vault 접근 정책 및 보안 ---"

# 변수 설정 (2단계에서 사용한 Key Vault 정보와 일치시켜야 합니다)
RESOURCE_GROUP_NAME="my-keyvault-rg" # 2단계에서 생성한 리소스 그룹 이름
KEY_VAULT_NAME="my-unique-keyvault-$(date +%s)" # 2단계에서 생성한 Key Vault 이름

# 주의: 이 스크립트를 독립적으로 실행하려면
# KEY_VAULT_NAME이 이미 존재하는 유효한 Key Vault 이름이어야 합니다.
# 학습 목적으로는 2단계 스크립트를 먼저 실행하여 Key Vault를 생성한 후
# 이 스크립트를 실행하는 것을 권장합니다.
echo "Key Vault 이름: $KEY_VAULT_NAME"

# 1. 사용자/그룹/서비스 주체에 대한 접근 정책 구성 (Access Policies)
# -------------------------------------------------------------------
# 현재 로그인한 사용자(혹은 서비스 주체)의 Object ID를 가져옵니다.
# 이는 접근 정책을 설정할 때 Principal ID로 사용됩니다.
CURRENT_USER_OBJECT_ID=$(az ad signed-in-user show --query id -o tsv)
if [ -z "$CURRENT_USER_OBJECT_ID" ]; then
  echo "오류: 현재 로그인한 사용자의 Object ID를 찾을 수 없습니다."
  echo "Azure CLI에 로그인되어 있는지 확인하거나, 특정 Object ID를 직접 지정해야 합니다."
  exit 1
fi
echo "현재 로그인한 사용자 Object ID: $CURRENT_USER_OBJECT_ID"
echo ""

echo "1.1. 현재 사용자에게 비밀(Secrets) 'Get' 및 'List' 권한 부여"
az keyvault set-policy \
  --name $KEY_VAULT_NAME \
  --object-id $CURRENT_USER_OBJECT_ID \
  --secret-permissions get list
echo "현재 사용자에게 Key Vault '$KEY_VAULT_NAME'의 비밀에 대한 'Get' 및 'List' 권한 부여 완료."
echo ""

# 1.2. 키(Keys)에 대한 접근 권한 부여 (예시: encrypt, decrypt, sign, verify)
az keyvault set-policy \
  --name $KEY_VAULT_NAME \
  --object-id $CURRENT_USER_OBJECT_ID \
  --key-permissions encrypt decrypt sign verify
echo "현재 사용자에게 Key Vault '$KEY_VAULT_NAME'의 키에 대한 암호화 관련 권한 부여 완료."
echo ""

# 1.3. 인증서(Certificates)에 대한 접근 권한 부여 (예시: get, list, update)
az keyvault set-policy \
  --name $KEY_VAULT_NAME \
  --object-id $CURRENT_USER_OBJECT_ID \
  --certificate-permissions get list update
echo "현재 사용자에게 Key Vault '$KEY_VAULT_NAME'의 인증서에 대한 접근 권한 부여 완료."
echo ""

# 2. 관리 ID (Managed Identities)를 이용한 안전한 접근 (Secure Access using Managed Identities)
# -------------------------------------------------------------------------------------------
# 관리 ID는 Azure 리소스가 Azure AD를 통해 안전하게 다른 Azure 서비스에 인증할 수 있도록 합니다.
# VM에 시스템 할당 관리 ID를 활성화하는 예시 (VM이 이미 존재한다고 가정)
VM_NAME="myManagedIDVM" # 관리 ID를 활성화할 VM 이름

echo "2.1. 가상 머신 '$VM_NAME'에 시스템 할당 관리 ID 활성화 (개념적 명령어)"
# 실제 환경에서는 VM이 존재해야 하며, 해당 VM에 대한 권한이 필요합니다.
# az vm identity assign --resource-group $RESOURCE_GROUP_NAME --name $VM_NAME
# SYSTEM_ASSIGNED_ID=$(az vm identity show --resource-group $RESOURCE_GROUP_NAME --name $VM_NAME --query principalId -o tsv)
# echo "VM '$VM_NAME'의 시스템 할당 관리 ID Principal ID: $SYSTEM_ASSIGNED_ID"

# 활성화된 관리 ID에 Key Vault 접근 권한 부여 (개념적 명령어)
# az keyvault set-policy \
#   --name $KEY_VAULT_NAME \
#   --object-id $SYSTEM_ASSIGNED_ID \
#   --secret-permissions get list
# echo "VM '$VM_NAME'의 관리 ID에 Key Vault '$KEY_VAULT_NAME'의 비밀에 대한 'Get' 및 'List' 권한 부여 완료."
echo "----------------------------------------------------------------------------"
echo "VM에 관리 ID를 활성화하고 Key Vault 접근 권한을 부여하는 명령어는 주석 처리되어 있습니다."
echo "실습 시에는 특정 VM과 Managed ID를 생성하고 해당 ID에 권한을 부여해야 합니다."
echo "----------------------------------------------------------------------------"
echo ""

# 3. 네트워크 보안 (Network Security) - Private Endpoint, Virtual Network 서비스 엔드포인트 (개념)
# ----------------------------------------------------------------------------------------------
echo "3.1. Key Vault의 방화벽 및 가상 네트워크 설정 (개념적 설명)"
echo "Key Vault는 '네트워킹' 섹션에서 특정 IP 주소, Virtual Network, Private Endpoint를 통해"
echo "접근을 제한할 수 있습니다. 이는 Key Vault에 대한 공용 접근을 제한하여 보안을 강화합니다."
# 예시: 특정 Virtual Network의 서브넷에서만 접근 허용
# az keyvault network-rule add \
#   --name $KEY_VAULT_NAME \
#   --vnet-name <your-vnet-name> \
#   --subnet <your-subnet-name>
#
# 예시: 특정 IP 주소에서만 접근 허용
# az keyvault network-rule add \
#   --name $KEY_VAULT_NAME \
#   --ip-address <your-ip-address>
#
# 모든 공용 접근을 비활성화하고 Private Endpoint만 허용
# az keyvault update --name $KEY_VAULT_NAME --resource-group $RESOURCE_GROUP_NAME --public-network-access Disabled
echo "----------------------------------------------------------------------------"
echo "Key Vault 네트워크 보안 설정 명령어는 주석 처리되어 있습니다."
echo "실습 시에는 특정 네트워크 환경을 구성한 후 적용해야 합니다."
echo "----------------------------------------------------------------------------"
echo ""

# 4. 로깅 및 모니터링 (Logging & Monitoring) - Azure Monitor, Audit Logs (개념)
# ---------------------------------------------------------------------------
echo "4.1. Key Vault 진단 설정 (Diagnostic Settings) 활성화 (개념적 설명)"
echo "Key Vault의 모든 작업(생성, 삭제, 접근 시도 등)은 감사 로그로 기록될 수 있습니다."
echo "이를 Azure Monitor Log Analytics Workspace 또는 Storage Account로 전송하여"
echo "모니터링 및 분석할 수 있습니다."
# az monitor diagnostic-settings create \
#   --name "keyvault-diagnostics" \
#   --resource $KEY_VAULT_NAME \
#   --resource-group $RESOURCE_GROUP_NAME \
#   --logs '[{"category": "AuditEvent", "enabled": true}]' \
#   --workspace <your-log-analytics-workspace-id>
echo "----------------------------------------------------------------------------"
echo "Key Vault 진단 설정 명령어는 주석 처리되어 있습니다."
echo "실습 시에는 Log Analytics Workspace를 먼저 생성한 후 적용해야 합니다."
echo "----------------------------------------------------------------------------"
echo ""

echo "Key Vault 접근 정책 및 보안 단계 완료."

# 학습용 Key Vault 리소스 그룹 삭제 명령어 (주의해서 사용하세요)
# az group delete --name $RESOURCE_GROUP_NAME --yes --no-wait

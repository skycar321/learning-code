#!/bin/bash

# Azure Key Vault 생성 및 관리 스크립트 예시
# 이 스크립트는 Azure Key Vault 학습 계획의 2단계인 'Key Vault 생성 및 관리'를 위한
# 개념적인 Azure CLI 명령어들을 포함하고 있습니다.
# 실제 환경에서는 구독 ID, 리소스 그룹 이름, Key Vault 이름 등을 환경에 맞게
# 설정하고 실행해야 합니다.

echo "--- 2단계: Key Vault 생성 및 관리 ---"

# 변수 설정 (필요에 따라 변경하세요)
RESOURCE_GROUP_NAME="my-keyvault-rg"
KEY_VAULT_NAME="my-unique-keyvault-$(date +%s)" # Key Vault 이름은 전역적으로 고유해야 합니다.
LOCATION="koreacentral" # 또는 eastus, westus 등 원하는 지역

# 1. Azure Resource Group 생성
echo "1. Azure Resource Group 생성: $RESOURCE_GROUP_NAME"
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION
echo "Resource Group '$RESOURCE_GROUP_NAME' 생성 완료."
echo ""

# 2. Azure Key Vault 생성
echo "2. Azure Key Vault 생성: $KEY_VAULT_NAME (지역: $LOCATION)"
# Key Vault 생성 시, SKU (Standard 또는 Premium)를 지정할 수 있습니다.
# Premium SKU는 HSM(Hardware Security Module) 보호 키를 제공합니다.
az keyvault create \
  --name $KEY_VAULT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --location $LOCATION \
  --enabled-for-deployment true \
  --enabled-for-disk-encryption true \
  --enabled-for-template-deployment true \
  --sku Standard
echo "Key Vault '$KEY_VAULT_NAME' 생성 완료."
echo ""

# 3. 비밀(Secrets) 관리 (Managing Secrets)
SECRET_NAME="myDbConnectionString"
SECRET_VALUE="Server=tcp:mydbserver.database.windows.net,1433;Database=mydb;Uid=user;Pwd=password;"

echo "3.1. Key Vault에 비밀 추가: $SECRET_NAME"
az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name $SECRET_NAME \
  --value "$SECRET_VALUE"
echo "비밀 '$SECRET_NAME' 추가 완료."
echo ""

echo "3.2. Key Vault에서 비밀 가져오기: $SECRET_NAME"
retrieved_secret=$(az keyvault secret show \
  --vault-name $KEY_VAULT_NAME \
  --name $SECRET_NAME \
  --query value \
  --output tsv)
echo "가져온 비밀: $retrieved_secret" # 보안상 실제 환경에서는 콘솔에 출력하지 않도록 주의!
echo ""

# 3.3. 비밀의 새 버전 추가 (업데이트)
SECRET_VALUE_NEW="Server=tcp:mydbserver.database.windows.net,1433;Database=mydb;Uid=user;Pwd=new_password;"
echo "3.3. 비밀 '$SECRET_NAME'의 새 버전 추가 (업데이트)"
az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name $SECRET_NAME \
  --value "$SECRET_VALUE_NEW"
echo "비밀 '$SECRET_NAME' 새 버전 추가 완료."
echo ""

echo "3.4. 비밀의 모든 버전 확인"
az keyvault secret list-versions \
  --vault-name $KEY_VAULT_NAME \
  --name $SECRET_NAME \
  --query '[].id' \
  --output tsv
echo ""

# 4. 키(Keys) 관리 (Managing Keys)
KEY_NAME="myEncryptionKey"

echo "4.1. Key Vault에 키 생성: $KEY_NAME (RSA 2048)"
az keyvault key create \
  --vault-name $KEY_VAULT_NAME \
  --name $KEY_NAME \
  --kty RSA \
  --size 2048
echo "키 '$KEY_NAME' 생성 완료."
echo ""

echo "4.2. Key Vault에서 키 정보 가져오기: $KEY_NAME"
az keyvault key show \
  --vault-name $KEY_VAULT_NAME \
  --name $KEY_NAME \
  --query id \
  --output tsv
echo ""

# 5. 인증서(Certificates) 관리 (Managing Certificates - 개념)
CERT_NAME="myAppCertificate"
echo "5.1. Key Vault에 인증서 생성 (자체 서명 예시 - 실제 사용 시 CA 발급 인증서 권장)"
# 이 명령어는 자체 서명 인증서 생성 예시이며, 실제 환경에서는 CA로부터 발급받은
# 인증서를 가져오거나 Key Vault를 통해 CSR을 생성하고 서명받는 과정을 거칩니다.
az keyvault certificate create \
  --vault-name $KEY_VAULT_NAME \
  --name $CERT_NAME \
  --policy "$(az keyvault certificate get-default-policy)"
echo "인증서 '$CERT_NAME' 생성 완료 (자체 서명)."
echo ""

echo "5.2. Key Vault에서 인증서 정보 가져오기: $CERT_NAME"
az keyvault certificate show \
  --vault-name $KEY_VAULT_NAME \
  --name $CERT_NAME \
  --query id \
  --output tsv
echo ""

echo "Key Vault 생성 및 관리 단계 완료."

# 경고: 이 스크립트는 학습용이므로, 리소스를 정리하는 명령어가 포함되어 있지 않습니다.
# 실제 운영 환경에서는 사용하지 않는 Key Vault와 Resource Group을 반드시 삭제하여
# 불필요한 비용이 발생하지 않도록 하세요.
# az group delete --name $RESOURCE_GROUP_NAME --yes --no-wait

#!/bin/bash

# Azure Log Analytics Workspace 생성 및 데이터 수집 구성 스크립트 예시
# 이 스크립트는 Azure 모니터링 대시보드 학습 계획의 2단계인 'Log Analytics 및 KQL'을 위한
# 개념적인 Azure CLI 명령어들을 포함하고 있습니다.
# 실제 환경에서는 구독 ID, 리소스 그룹 이름, Log Analytics Workspace 이름 등을 환경에 맞게
# 설정하고 실행해야 합니다.

echo "--- 2단계: Log Analytics 및 KQL ---"

# 변수 설정 (필요에 따라 변경하세요)
RESOURCE_GROUP_NAME="my-monitor-rg"
LOG_ANALYTICS_WORKSPACE_NAME="my-loganalytics-workspace-$(date +%s)" # Log Analytics Workspace 이름은 고유해야 합니다.
LOCATION="koreacentral" # 또는 eastus, westus 등 원하는 지역

# 1. Azure Resource Group 생성 (아직 없는 경우)
echo "1. Azure Resource Group 생성: $RESOURCE_GROUP_NAME"
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION
echo "Resource Group '$RESOURCE_GROUP_NAME' 생성 완료."
echo ""

# 2. Log Analytics Workspace 생성
echo "2. Log Analytics Workspace 생성: $LOG_ANALYTICS_WORKSPACE_NAME (지역: $LOCATION)"
az monitor log-analytics workspace create \
  --resource-group $RESOURCE_GROUP_NAME \
  --workspace-name $LOG_ANALYTICS_WORKSPACE_NAME \
  --location $LOCATION
echo "Log Analytics Workspace '$LOG_ANALYTICS_WORKSPACE_NAME' 생성 완료."
echo ""

# 생성된 Workspace의 ID와 Shared Key를 가져옵니다.
WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --resource-group $RESOURCE_GROUP_NAME \
  --workspace-name $LOG_ANALYTICS_WORKSPACE_NAME \
  --query id \
  --output tsv)
WORKSPACE_CUSTOMER_ID=$(az monitor log-analytics workspace show \
  --resource-group $RESOURCE_GROUP_NAME \
  --workspace-name $LOG_ANALYTICS_WORKSPACE_NAME \
  --query customerId \
  --output tsv)
WORKSPACE_SHARED_KEY=$(az monitor log-analytics workspace get-shared-keys \
  --resource-group $RESOURCE_GROUP_NAME \
  --workspace-name $LOG_ANALYTICS_WORKSPACE_NAME \
  --query primarySharedKey \
  --output tsv)

echo "Workspace ID: $WORKSPACE_ID"
echo "Workspace Customer ID: $WORKSPACE_CUSTOMER_ID"
echo "Workspace Shared Key (일부): ${WORKSPACE_SHARED_KEY:0:10}..."
echo ""

# 3. 데이터 수집 구성 (Configuring Data Collection)
# --------------------------------------------------
# 예시: 가상 머신(VM)에 Log Analytics 에이전트 설치 및 연결
# 이 부분은 실제 VM이 존재해야 실행 가능합니다.
VM_NAME="my-monitored-vm" # 모니터링할 가상 머신 이름

echo "3.1. 가상 머신 '$VM_NAME'에 Log Analytics VM 확장 설치 (개념적 명령어)"
# 실제 환경에서는 VM이 존재해야 하며, 해당 VM에 대한 권한이 필요합니다.
# az vm extension set \
#   --resource-group $RESOURCE_GROUP_NAME \
#   --vm-name $VM_NAME \
#   --name MicrosoftMonitoringAgent \
#   --publisher Microsoft.EnterpriseCloud.Monitoring \
#   --version 1.0 \
#   --protected-settings "{\"workspaceId\": \"$WORKSPACE_CUSTOMER_ID\", \"workspaceKey\": \"$WORKSPACE_SHARED_KEY\"}"
echo "----------------------------------------------------------------------------"
echo "VM에 Log Analytics 에이전트 설치 명령어는 주석 처리되어 있습니다."
echo "실습 시에는 특정 VM을 생성하고 해당 VM에 에이전트를 설치해야 합니다."
echo "----------------------------------------------------------------------------"
echo ""

# 예시: Azure 리소스에 진단 설정 구성 (Storage Account 로그를 Log Analytics로 전송)
STORAGE_ACCOUNT_NAME="mystoragelogdemo$(date +%s)" # 진단 설정할 스토리지 계정 이름

echo "3.2. 스토리지 계정 '$STORAGE_ACCOUNT_NAME' 생성 (진단 설정 예시를 위해)"
az storage account create \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --location $LOCATION \
  --sku Standard_LRS
echo "스토리지 계정 '$STORAGE_ACCOUNT_NAME' 생성 완료."
echo ""

echo "3.3. 스토리지 계정의 진단 설정 구성 (로그를 Log Analytics Workspace로 전송)"
# 스토리지 계정의 Blob, File, Table, Queue 서비스에 대한 로그를 Log Analytics로 전송합니다.
az monitor diagnostic-settings create \
  --name "storage-log-analytics" \
  --resource $STORAGE_ACCOUNT_NAME \
  --workspace $LOG_ANALYTICS_WORKSPACE_NAME \
  --logs '[{"categoryGroup": "allLogs", "enabled": true}]' \
  --metrics '[{"category": "Transaction", "enabled": true}]'
echo "스토리지 계정 '$STORAGE_ACCOUNT_NAME'의 진단 설정 구성 완료."
echo ""

echo "Log Analytics Workspace 생성 및 데이터 수집 구성 단계 완료."

# 학습용 리소스 정리 명령어 (주의해서 사용하세요)
# az group delete --name $RESOURCE_GROUP_NAME --yes --no-wait

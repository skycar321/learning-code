#!/bin/bash

# Azure 모니터링 대시보드 학습 - 5단계: 경고 및 자동화된 응답
# 이 스크립트는 Azure 모니터링 대시보드 학습 계획의 5단계인 '경고 및 자동화된 응답'을 위한
# 개념적인 Azure CLI 명령어들을 포함하고 있습니다.
# 메트릭 기반 경고 규칙과 액션 그룹을 생성하여 모니터링 이벤트에 대응하는 방법을 보여줍니다.

echo "--- 5단계: 경고 및 자동화된 응답 ---"

# 변수 설정 (필요에 따라 변경하세요)
RESOURCE_GROUP_NAME="my-monitor-rg" # 이전 단계에서 생성한 리소스 그룹 이름
LOCATION="koreacentral"             # 리소스 그룹과 동일한 지역
ACTION_GROUP_NAME="my-notification-ag"
ALERT_RULE_NAME="HighCpuAlert"
VM_NAME="my-monitored-vm" # 경고 규칙을 적용할 가상 머신 이름 (예시)

# 1. 액션 그룹(Action Groups) 구성 (Configuring Action Groups)
# -----------------------------------------------------------------------------
# 액션 그룹은 경고가 발생했을 때 수행할 작업(이메일 전송, SMS 전송, 웹훅 호출 등)을 정의합니다.

echo "1. 액션 그룹 '$ACTION_GROUP_NAME' 생성"
az monitor action-group create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $ACTION_GROUP_NAME \
  --short-name "MyAG" \
  --actions email MyEmail "emailreceiver@example.com" webhook MyWebhook "http://your.webhook.url/endpoint"
echo "액션 그룹 '$ACTION_GROUP_NAME' 생성 완료 (이메일 및 웹훅 액션 포함)."
echo ""
# 참고: 실제 이메일 주소와 웹훅 URL로 대체해야 합니다.

# 2. 경고 규칙 생성 (Creating Alert Rules)
# -----------------------------------------------------------------------------
# 경고 규칙은 특정 조건(메트릭 임계값 초과, 로그 쿼리 결과 등)이 충족될 때
# 액션 그룹에 정의된 작업을 트리거합니다.

# 2.1. 메트릭 기반 경고 규칙 생성 (예: VM CPU 사용률)
# 가상 머신이 존재해야 실행 가능합니다.
echo "2.1. 메트릭 기반 경고 규칙 '$ALERT_RULE_NAME' 생성 (VM CPU 사용률)"

# 경고 규칙을 생성하려면 먼저 대상 리소스의 ID를 알아야 합니다.
# VM_ID=$(az vm show --resource-group $RESOURCE_GROUP_NAME --name $VM_NAME --query id -o tsv)

# if [ -z "$VM_ID" ]; then
#   echo "오류: VM '$VM_NAME'을(를) 찾을 수 없습니다. 경고 규칙을 생성할 수 없습니다."
#   echo "이 스크립트를 독립적으로 실행하려면 '$VM_NAME'이(가) 존재하는 유효한 VM 이름이어야 합니다."
#   echo "또는 '--resource' 인자를 실제 리소스 ID로 교체하세요."
# else
#   echo "VM ID: $VM_ID"
#   az monitor metrics alert create \
#     --resource-group $RESOURCE_GROUP_NAME \
#     --name $ALERT_RULE_NAME \
#     --scopes $VM_ID \
#     --condition "avg Percentage CPU > 80" \
#     --description "VM CPU 사용률이 80%를 초과했을 때 경고를 발생시킵니다." \
#     --action $ACTION_GROUP_NAME \
#     --severity 3 \
#     --window-size 5m \
#     --evaluation-frequency 1m
#   echo "메트릭 기반 경고 규칙 '$ALERT_RULE_NAME' 생성 완료."
# fi

echo "----------------------------------------------------------------------------"
echo "메트릭 기반 경고 규칙 생성 명령어는 주석 처리되어 있습니다."
echo "실습 시에는 경고 규칙을 적용할 대상 리소스 (VM 등)를 먼저 생성해야 합니다."
echo "----------------------------------------------------------------------------"
echo ""

# 2.2. 로그 기반 경고 규칙 생성 (개념적 설명)
# Log Analytics Workspace에서 KQL 쿼리 결과에 따라 경고를 발생시킵니다.
# 예를 들어, 특정 오류 메시지가 지난 5분 동안 10회 이상 발생하면 경고를 트리거할 수 있습니다.
echo "2.2. 로그 기반 경고 규칙 생성 (개념적 설명)"
# 로그 기반 경고 규칙을 생성하려면 Log Analytics Workspace ID가 필요합니다.
# WORKSPACE_ID=$(az monitor log-analytics workspace show \
#   --resource-group $RESOURCE_GROUP_NAME \
#   --workspace-name $LOG_ANALYTICS_WORKSPACE_NAME \
#   --query id \
#   --output tsv)

# az monitor scheduled-query create \
#   --resource-group $RESOURCE_GROUP_NAME \
#   --name "CriticalErrorLogAlert" \
#   --scopes $WORKSPACE_ID \
#   --condition "count of results > 0" \
#   --description "지난 5분 동안 심각한 오류 로그가 발생했을 때 경고합니다." \
#   --action-groups $ACTION_GROUP_NAME \
#   --severity 1 \
#   --window-size 5m \
#   --frequency 5m \
#   --query "ContainerLogV2 | where LogLevel == 'Critical'" \
#   --query-type "ResultCount"

echo "----------------------------------------------------------------------------"
echo "로그 기반 경고 규칙 생성 명령어는 주석 처리되어 있습니다."
echo "실습 시에는 Log Analytics Workspace와 모니터링할 로그 데이터가 필요합니다."
echo "----------------------------------------------------------------------------"
echo ""

# 3. 자동 복구 및 자동 확장 (Auto-healing & Auto-scaling) 연동 (개념적 설명)
# -----------------------------------------------------------------------------
# Azure Monitor 경고는 Logic Apps 또는 Azure Functions와 연동하여
# 자동화된 복구(예: VM 재시작, 애플리케이션 재배포) 또는 자동 확장(예: 스케일 아웃)과 같은
# 복잡한 액션을 수행할 수 있습니다.

echo "3. 자동 복구 및 자동 확장 연동 (개념적 설명)"
echo "Logic Apps나 Azure Functions를 액션 그룹의 웹훅 액션으로 연결하여"
echo "경고 발생 시 커스텀 로직을 실행할 수 있습니다."
echo "예: CPU 사용률 경고 발생 시 Logic App이 트리거되어 VM을 재시작하거나,"
echo "웹 애플리케이션의 인스턴스를 추가하는 스크립트를 실행합니다."
echo ""

echo "경고 및 자동화된 응답 단계 완료."

# 학습용 리소스 정리 명령어 (주의해서 사용하세요)
# az group delete --name $RESOURCE_GROUP_NAME --yes --no-wait

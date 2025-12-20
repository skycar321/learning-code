# Azure Key Vault 애플리케이션 통합 파이썬 예시
# 이 파일은 Azure Key Vault 학습 계획의 4단계인 '애플리케이션 통합'을 위한
# 개념적인 파이썬 코드 예시입니다.
# 파이썬 애플리케이션에서 Azure Key Vault에 저장된 비밀(Secret)을 안전하게
# 가져와 사용하는 방법을 보여줍니다.

# 필요한 라이브러리 설치:
# pip install azure-identity azure-keyvault-secrets

# -----------------------------------------------------------------------------
# 1. 관리 ID 또는 서비스 주체를 사용한 인증 (Authentication using Managed Identity or Service Principal)
# -----------------------------------------------------------------------------
# Azure Key Vault에 접근하기 위해서는 애플리케이션이 Azure AD를 통해 인증되어야 합니다.
# 일반적으로 권장되는 방법은 Managed Identity를 사용하는 것입니다.

from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
import os

# Key Vault URL (Azure Portal 또는 Azure CLI에서 확인 가능)
# 예: "https://<your-key-vault-name>.vault.azure.net/"
KEY_VAULT_URL = os.environ.get("KEY_VAULT_URL", "https://your-key-vault-name.vault.azure.net/")
SECRET_NAME = os.environ.get("SECRET_NAME", "myDbConnectionString")

def get_secret_from_keyvault():
    """
    Azure Key Vault에서 비밀(Secret)을 가져오는 함수.
    DefaultAzureCredential을 사용하여 애플리케이션이 실행되는 환경에 따라
    가장 적절한 인증 방법을 자동으로 찾습니다 (Managed Identity, Azure CLI, 환경 변수 등).
    """
    try:
        # DefaultAzureCredential은 다음과 같은 순서로 자격 증명을 시도합니다:
        # 1. 환경 변수 (AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_CLIENT_SECRET)
        # 2. Managed Identity (Azure VM, App Service, Functions, AKS 등)
        # 3. Azure CLI
        # 4. Visual Studio Code
        # 5. 기타 개발 도구
        credential = DefaultAzureCredential()
        print("Azure 인증 자격 증명 획득 성공.")

        # SecretClient를 초기화하여 Key Vault Secrets에 접근합니다.
        secret_client = SecretClient(vault_url=KEY_VAULT_URL, credential=credential)
        print(f"Key Vault '{KEY_VAULT_URL}'에 연결 시도 중...")

        # 특정 Secret을 가져옵니다.
        # 최신 버전을 가져오려면 version을 지정하지 않습니다.
        secret = secret_client.get_secret(SECRET_NAME)
        print(f"비밀 '{SECRET_NAME}' 가져오기 성공.")
        return secret.value

    except Exception as e:
        print(f"Azure Key Vault에서 비밀을 가져오는 중 오류 발생: {e}")
        # 실제 애플리케이션에서는 적절한 오류 처리 로직을 추가해야 합니다.
        # 예: 기본값 사용, 애플리케이션 종료 등
        return None

# -----------------------------------------------------------------------------
# 2. 애플리케이션에서 비밀 사용 (Using Secrets in Application)
# -----------------------------------------------------------------------------
if __name__ == "__main__":
    print(f"Key Vault URL: {KEY_VAULT_URL}")
    print(f"가져올 비밀 이름: {SECRET_NAME}")

    # 실제 Key Vault URL과 SECRET_NAME을 환경 변수로 설정하거나 코드에서 직접 지정해야 합니다.
    # 예시:
    # export KEY_VAULT_URL="https://my-awesome-keyvault.vault.azure.net/"
    # export SECRET_NAME="myDbConnectionString"

    db_connection_string = get_secret_from_keyvault()

    if db_connection_string:
        print(f"애플리케이션에서 사용될 DB 연결 문자열 (보안상 일부만 표시): {db_connection_string[:10]}...")
        # 이 연결 문자열을 사용하여 데이터베이스에 연결하는 등의 작업을 수행합니다.
        # 절대 콘솔이나 로그에 전체 비밀 값을 출력하지 마십시오.
        #
        # 예시:
        # import pymysql # 또는 다른 DB 라이브러리
        # try:
        #     connection = pymysql.connect(host='localhost',
        #                                  user='webuser',
        #                                  password=db_connection_string, # 이 위치에 비밀이 사용됩니다.
        #                                  database='webdb')
        #     print("데이터베이스 연결 성공!")
        # except Exception as e:
        #     print(f"데이터베이스 연결 실패: {e}")
    else:
        print("DB 연결 문자열을 가져오는 데 실패했습니다. 애플리케이션을 시작할 수 없습니다.")

# -----------------------------------------------------------------------------
# 3. CI/CD 파이프라인에서 Key Vault 사용 (개념적 설명)
# -----------------------------------------------------------------------------
# GitHub Actions, Azure DevOps Pipelines 등 CI/CD 환경에서는
# 서비스 주체(Service Principal)를 사용하여 Key Vault에 접근할 수 있습니다.
#
# Azure DevOps:
#   - Variable Group을 Key Vault에 연결하여 비밀을 파이프라인 변수로 직접 주입.
#   - Azure Key Vault 태스크를 사용하여 런타임에 비밀을 가져옴.
#
# GitHub Actions:
#   - OIDC (OpenID Connect)를 사용하여 워크플로우를 Azure에 인증.
#   - Azure CLI 액션을 사용하여 비밀을 가져옴.
#
# 핵심은 CI/CD 에이전트에 Key Vault에 접근할 수 있는 최소한의 권한을 부여하는 것입니다.

# Python 가상 환경 및 패키지 관리
# `venv`를 이용한 가상 환경 설정 및 `pip`를 이용한 패키지 관리

# 나쁜 예시: 모든 프로젝트에서 시스템 전체의 Python 환경을 공유하여, 프로젝트 간 의존성 충돌을 일으키거나 불필요한 패키지로 환경을 오염시킵니다.
# 좋은 예시: 각 프로젝트마다 독립적인 가상 환경을 구축하고 `pip`를 사용하여 필요한 패키지만 설치, `requirements.txt`로 의존성을 명확하게 관리합니다.

import os
import subprocess
import sys

# 가상 환경 생성 및 활성화 (스크립트 내에서 직접 수행하기보다는 터미널에서 수동으로 하는 것이 일반적입니다)
# 이 스크립트는 가상 환경을 생성하는 명령어를 보여주는 예시입니다.

def create_and_activate_venv(venv_name="venv"):
    """
    지정된 이름으로 가상 환경을 생성하고 활성화하는 방법을 안내합니다.
    실제 활성화는 셸 스크립트 실행이 필요합니다.
    """
    venv_path = os.path.join(os.getcwd(), venv_name)
    
    if sys.platform == "win32":
        activate_script = os.path.join(venv_path, "Scripts", "activate")
        deactivate_script = os.path.join(venv_path, "Scripts", "deactivate")
        print(f"Windows에서 가상 환경 생성: python -m venv {venv_name}")
        print(f"Windows에서 가상 환경 활성화: .\\{venv_name}\\Scripts\\activate")
        print(f"Windows에서 가상 환경 비활성화: .\\{venv_name}\\Scripts\\deactivate")
    else: # Linux, macOS
        activate_script = os.path.join(venv_path, "bin", "activate")
        deactivate_script = os.path.join(venv_path, "bin", "deactivate")
        print(f"Linux/macOS에서 가상 환경 생성: python3 -m venv {venv_name}")
        print(f"Linux/macOS에서 가상 환경 활성화: source {venv_name}/bin/activate")
        print(f"Linux/macOS에서 가상 환경 비활성화: deactivate")

    print(f"\n참고: 가상 환경 생성 후 터미널에서 위 명령어를 실행해야 활성화됩니다.")
    
    # 실제 가상 환경 생성 명령어 실행 (선택 사항, 주의해서 사용)
    # try:
    #     subprocess.run([sys.executable, "-m", "venv", venv_name], check=True)
    #     print(f"가상 환경 '{venv_name}'이(가) 성공적으로 생성되었습니다.")
    # except subprocess.CalledProcessError as e:
    #     print(f"가상 환경 생성 중 오류 발생: {e}")
    
# 패키지 설치 및 관리 (pip 사용)
def manage_packages():
    """pip를 사용하여 패키지를 설치하고 의존성을 관리하는 방법을 안내합니다."""
    print("\n--- 패키지 관리 (pip) ---")
    print("패키지 설치: pip install <package_name>")
    print("특정 버전 패키지 설치: pip install <package_name>==<version>")
    print("패키지 업그레이드: pip install --upgrade <package_name>")
    print("패키지 제거: pip uninstall <package_name>")
    print("설치된 패키지 목록 보기: pip list")
    print("설치된 패키지 정보 보기: pip show <package_name>")
    
    # 의존성 파일 (requirements.txt) 생성 및 설치
    print("\n--- requirements.txt를 이용한 의존성 관리 ---")
    print("현재 가상 환경의 패키지를 requirements.txt로 저장: pip freeze > requirements.txt")
    print("requirements.txt에 있는 패키지 설치: pip install -r requirements.txt")

    # 예시: requests 라이브러리 설치 안내
    print("\n예시: requests 라이브러리 설치")
    print("가상 환경 활성화 후: pip install requests")
    
    # 예시: requests 라이브러리 사용
    try:
        import requests
        response = requests.get("https://api.github.com")
        print(f"requests 라이브러리 테스트 - GitHub API 응답 상태 코드: {response.status_code}")
    except ImportError:
        print("requests 라이브러리가 설치되지 않았습니다. 'pip install requests' 명령으로 설치해주세요.")
    except Exception as e:
        print(f"requests 라이브러리 사용 중 오류 발생: {e}")


if __name__ == "__main__":
    print("--- 가상 환경 생성 및 활성화 ---")
    create_and_activate_venv("my_project_venv")
    
    manage_packages()
    
    print("\n가상 환경과 패키지 관리에 대한 학습이 완료되었습니다.")
    print("각 명령어는 터미널에서 직접 실행해야 합니다.")

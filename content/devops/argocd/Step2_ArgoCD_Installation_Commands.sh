#!/bin/bash

# ArgoCD 설치 및 초기 설정 스크립트 예시
# 이 스크립트는 ArgoCD 학습 계획의 2단계인 'ArgoCD 설치 및 초기 설정'을 위한
# 개념적인 명령어들을 포함하고 있습니다. 실제 환경에서는 공식 문서를 참조하여
# 환경에 맞게 수정하고 실행해야 합니다.

echo "--- 2단계: ArgoCD 설치 및 초기 설정 ---"

# 1. Kubernetes 환경 준비 (Preparing Kubernetes Environment)
echo "Kubernetes 환경이 준비되었는지 확인합니다 (minikube, kind, 또는 클라우드 클러스터)."
echo "예시: minikube 시작 명령어"
# minikube start
echo ""

# 2. ArgoCD 설치 방법 (Installation Methods)
# 2.1. YAML Manifests를 이용한 설치 (Using YAML Manifests)
echo "ArgoCD를 Kubernetes 클러스터에 설치합니다."
echo "공식 ArgoCD 설치 YAML을 다운로드하고 적용합니다."
# kubectl create namespace argocd
# kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
echo "설치 완료 후 ArgoCD 파드가 실행될 때까지 기다립니다."
# kubectl get pods -n argocd

echo ""

# 2.2. Helm을 이용한 설치 (Using Helm - 대안)
echo "Helm을 사용하는 경우, 다음 명령어를 사용할 수 있습니다 (선택 사항)."
# helm repo add argo https://argoproj.github.io/argo-helm
# helm repo update
# helm install argocd argo/argo-cd --namespace argocd --create-namespace
echo ""

# 3. ArgoCD CLI 설치 (Installing ArgoCD CLI)
echo "ArgoCD CLI를 로컬 시스템에 설치합니다."
echo "운영체제에 맞는 CLI를 다운로드하고 PATH에 추가합니다."
# 예시: Linux/macOS
# curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-darwin-amd64 # macOS
# curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 # Linux
# chmod +x /usr/local/bin/argocd
# argocd version --client

echo ""

# 4. ArgoCD UI 접근 및 초기 로그인 (Accessing UI & Initial Login)
echo "ArgoCD API 서버 포트 포워딩을 통해 UI에 접근합니다."
# kubectl port-forward svc/argocd-server -n argocd 8080:443 &
echo "브라우저에서 https://localhost:8080 으로 접근합니다."

echo "초기 관리자 비밀번호를 가져옵니다."
# argocd admin initial-password -n argocd
echo "ArgoCD CLI에 로그인합니다."
# argocd login localhost:8080

echo ""

# 5. 클러스터 등록 (Registering Clusters)
echo "ArgoCD에 외부 Kubernetes 클러스터를 등록합니다 (현재 클러스터에 배포했다면 불필요)."
# argocd cluster add <CONTEXT_NAME>
echo "또는 kubeconfig 파일을 사용하여 클러스터를 추가합니다."
# argocd cluster add <SERVER_URL> --name <CLUSTER_NAME> --kubeconfig <PATH_TO_KUBECONFIG>

echo "ArgoCD 설치 및 초기 설정 단계 완료."

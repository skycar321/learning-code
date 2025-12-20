// jenkins/Step4_AdvancedJenkinsFeatures.Jenkinsfile
// Jenkins 학습 계획 - 4단계: 고급 Jenkins 기능 및 플러그인 활용
// 이 파일은 Jenkins Declarative Pipeline에서 공유 라이브러리(Shared Libraries)와
// 자격 증명 관리(Credential Management)와 같은 고급 기능을 활용하는 예시를 보여줍니다.
//
// 이러한 기능들은 파이프라인 코드의 재사용성을 높이고, 민감한 정보를 안전하게 관리하여
// CI/CD 파이프라인의 효율성과 보안을 향상시킵니다.

// Declarative Pipeline의 최상위 블록
pipeline {
    agent any // 이 파이프라인은 사용 가능한 모든 Jenkins Agent에서 실행됩니다.

    // -----------------------------------------------------------------------------
    // 학습 포인트 1: 공유 라이브러리 (Shared Libraries)
    // - 여러 파이프라인에서 재사용 가능한 Groovy 코드를 중앙에서 관리할 수 있게 합니다.
    // - `vars` 디렉토리에 함수를 정의하거나, `src` 디렉토리에 클래스를 정의할 수 있습니다.
    // - Jenkins 관리 -> 시스템 설정 -> Global Pipeline Libraries에서 라이브러리를 등록합니다.
    //   - 이름, Git Repository URL, 자격 증명 등을 설정.
    // - 파이프라인에서 `@Library('my-shared-library@main')`와 같이 선언하여 사용합니다.
    // -----------------------------------------------------------------------------
    libraries {
        // 'my-shared-library'는 Jenkins Global Pipeline Libraries에 등록된 라이브러리 이름입니다.
        // `@main`은 라이브러리의 'main' 브랜드를 사용하겠다는 의미입니다.
        // 나쁜 예시: 모든 파이프라인에 중복되는 코드를 복사-붙여넣기 하는 것.
        // - 코드 변경 시 모든 파이프라인을 수정해야 하며, 일관성 유지도 어렵습니다.
        // 좋은 예시: 재사용 가능한 스텝이나 함수를 공유 라이브러리로 만들어 파이프라인 코드의
        // - 유지보수성을 높이고 표준화를 강제하는 것.
        // library('my-shared-library@main')
    }

    environment {
        // Jenkins Credentials에 저장된 ID가 'my-docker-cred'인 자격 증명을 환경 변수로 주입합니다.
        // WithCredentials 구문은 나중에 Credentials를 사용하여 Docker 로그인 등을 할 때 사용됩니다.
        // 이 환경 변수는 파이프라인 스크립트 내에서 사용 가능합니다.
        DOCKER_REGISTRY_CREDENTIAL_ID = 'my-docker-registry-credentials'
    }

    stages {
        // Stage 1: Checkout
        stage('Checkout') {
            steps {
                script {
                    echo "소스 코드를 체크아웃합니다."
                    git branch: 'main', url: 'https://github.com/your-org/your-repo.git'
                }
            }
        }

        // Stage 2: Build
        stage('Build') {
            steps {
                script {
                    echo "프로젝트를 빌드합니다."
                    sh './gradlew clean build -x test' // 예시: Gradle 빌드
                }
            }
        }

        // Stage 3: Docker 이미지 빌드 및 푸시
        stage('Build and Push Docker Image') {
            agent {
                // 이 Stage는 Docker가 설치된 에이전트에서 실행되어야 합니다.
                // 또는 Docker 컨테이너 내에서 빌드할 수도 있습니다 (예: agent { docker { image 'docker:dind' } }).
                label 'docker-agent'
            }
            steps {
                script {
                    echo "Docker 이미지를 빌드하고 레지스트리에 푸시합니다."
                    def dockerImage = "my-registry/my-app:${env.BUILD_NUMBER}"
                    sh "docker build -t ${dockerImage} ."

                    // -----------------------------------------------------------------------------
                    // 학습 포인트 2: Credential Management (자격 증명 관리)
                    // - Jenkins Credentials는 비밀번호, SSH 키, Secret Text 등 민감한 정보를 안전하게 저장합니다.
                    // - `withCredentials` 블록을 사용하여 파이프라인 스크립트 내에서 자격 증명을 안전하게 참조합니다.
                    // - `usernamePassword(credentialsId: '...', usernameVariable: '...', passwordVariable: '...')`
                    // -----------------------------------------------------------------------------
                    withCredentials([usernamePassword(
                            credentialsId: env.DOCKER_REGISTRY_CREDENTIAL_ID, // Jenkins Credentials ID
                            usernameVariable: 'DOCKER_USERNAME',
                            passwordVariable: 'DOCKER_PASSWORD')]) {
                        // 나쁜 예시: `echo "docker login -u admin -p password"`와 같이 비밀번호를 로그에 노출하는 것.
                        // - 민감한 정보는 절대 로그나 스크립트에 평문으로 노출해서는 안 됩니다.
                        // 좋은 예시: `withCredentials` 블록을 사용하여 환경 변수로 비밀 값을 주입받아 사용하는 것.
                        sh "echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin my-registry"
                        sh "docker push ${dockerImage}"
                    }
                    echo "Docker 이미지가 ${dockerImage}로 푸시되었습니다."
                }
            }
        }

        // Stage 4: 테스트
        stage('Test') {
            steps {
                sh './gradlew test' // 테스트 실행
            }
        }

        // Stage 5: 배포 (개발/스테이징 환경)
        stage('Deploy to Dev') {
            when {
                branch 'main'
            }
            steps {
                script {
                    echo "개발 환경에 배포합니다."
                    // sh "mySharedLibrary.deployApp(environment: 'dev', image: dockerImage)" // 공유 라이브러리 함수 호출 예시
                    sh "echo '배포 성공!'"
                }
            }
        }
    }

    post {
        always {
            echo "파이프라인 실행 완료."
        }
        failure {
            echo "빌드 실패!"
            // -----------------------------------------------------------------------------
            // 학습 포인트 3: 플러그인 활용 (Slack/Email 알림)
            // - `slackSend` (Slack Notification Plugin), `mail` (Email Extension Plugin)
            // - Jenkins 플러그인을 사용하여 빌드 결과에 따라 외부 서비스로 알림을 보냅니다.
            // -----------------------------------------------------------------------------
            // 나쁜 예시: 빌드 실패 시 아무런 알림도 보내지 않아 문제를 늦게 발견하는 것.
            // - 또는 모든 빌드 결과에 대해 불필요한 알림을 보내 팀의 피로도를 높이는 것.
            // 좋은 예시: 빌드 실패 시 개발 팀에 즉시 알림을 보내어 신속한 문제 해결을 돕고,
            // - 성공 시에도 중요한 빌드에 대해서만 알림을 보내는 등 알림 전략을 세우는 것.
            // slackSend channel: '#devops', message: "빌드 실패: ${env.JOB_NAME} - ${env.BUILD_NUMBER}. ${env.BUILD_URL}"
            // mail to: 'devs@example.com', subject: "Jenkins Build Failed: ${env.JOB_NAME}", body: "Build URL: ${env.BUILD_URL}"
        }
    }
}

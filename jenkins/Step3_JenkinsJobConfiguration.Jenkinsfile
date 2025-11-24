// jenkins/Step3_JenkinsJobConfiguration.Jenkinsfile
// Jenkins 학습 계획 - 3단계: Jenkins Job 구성 (Declarative Pipeline)
// 이 파일은 Jenkins Declarative Pipeline을 사용하여 CI/CD 파이프라인을 정의하는 예시입니다.
// 소스 코드 관리(Git), 빌드, 테스트, 아티팩트 생성 등 기본적인 파이프라인 단계를 보여줍니다.
//
// Jenkins Pipeline은 '코드로서의 파이프라인(Pipeline as Code)' 개념을 구현하며,
// Jenkinsfile이라는 텍스트 파일에 파이프라인의 전체 워크플로우를 정의하여
// 버전 관리 시스템(VCS)에 커밋할 수 있도록 합니다.

// Declarative Pipeline의 최상위 블록
pipeline {
    // -----------------------------------------------------------------------------
    // 학습 포인트 1: `agent` 섹션
    // - 파이프라인 또는 개별 Stage를 실행할 Jenkins Agent(노드)를 지정합니다.
    // - `any`: 사용 가능한 모든 Agent에서 실행.
    // - `none`: 파이프라인 전체에는 Agent를 지정하지 않고, 각 `stage`에서 Agent를 지정.
    // - `label 'my-agent'`: 특정 레이블을 가진 Agent에서 실행.
    // - `docker { image 'maven:3.8.1-jdk-11' }`: Docker 컨테이너 내에서 Stage 실행 (빌드 환경 격리).
    // -----------------------------------------------------------------------------
    agent any // 이 파이프라인은 사용 가능한 모든 Jenkins Agent에서 실행됩니다.
    // 나쁜 예시: `agent none`을 사용하면서 각 Stage에 `agent`를 지정하지 않아 빌드 실패.
    // - 또는 Docker 컨테이너를 사용해야 하는데 `any`를 사용하여 호스트 환경에 의존하는 것.

    // -----------------------------------------------------------------------------
    // 학습 포인트 2: `environment` 섹션
    // - 파이프라인 전체 또는 특정 Stage에서 사용할 환경 변수를 정의합니다.
    // - `credentials()` 함수를 사용하여 Jenkins Credentials에서 비밀 값을 가져올 수 있습니다.
    // -----------------------------------------------------------------------------
    environment {
        // BUILD_VERSION = "1.0.0" // 고정된 빌드 버전
        // DOCKER_REGISTRY_CREDENTIAL = credentials('my-docker-registry-credentials') // Jenkins Credentials 사용 예시
    }

    // -----------------------------------------------------------------------------
    // 학습 포인트 3: `tools` 섹션
    // - Jenkins Controller에 미리 설정된 도구(JDK, Maven, Gradle 등)를 사용합니다.
    // - 'Global Tool Configuration'에서 설정된 이름과 일치해야 합니다.
    // -----------------------------------------------------------------------------
    tools {
        // JDK 'JDK_11' // Jenkins 관리 -> Global Tool Configuration에 설정된 JDK 11 사용
        // MAVEN 'Maven_3.8.1' // Jenkins 관리 -> Global Tool Configuration에 설정된 Maven 3.8.1 사용
        // GRADLE 'Gradle_7.5' // Jenkins 관리 -> Global Tool Configuration에 설정된 Gradle 7.5 사용
    }

    // -----------------------------------------------------------------------------
    // 학습 포인트 4: `stages` 섹션
    // - 파이프라인의 핵심. 빌드, 테스트, 배포 등 순차적으로 실행될 단계들을 정의합니다.
    // - 각 `stage`는 명확한 이름과 목적을 가져야 합니다.
    // -----------------------------------------------------------------------------
    stages {
        // Stage 1: 소스 코드 체크아웃 (Source Code Checkout)
        stage('Checkout') {
            steps {
                // -----------------------------------------------------------------------------
                // 학습 포인트 5: `steps` 섹션
                // - 각 Stage 내에서 실행될 명령어 또는 스크립트 블록입니다.
                // - `git`, `sh`, `dir`, `echo`, `script` 등 다양한 스텝이 있습니다.
                // -----------------------------------------------------------------------------
                script {
                    echo "Git Repository로부터 소스 코드를 가져옵니다."
                    // Git 플러그인을 사용하여 소스 코드를 체크아웃합니다.
                    // `scm`은 Jenkins Job 설정에서 지정된 SCM (Source Code Management) 정보를 사용합니다.
                    // 나쁜 예시: `git clone <repo_url>`을 스크립트에서 직접 실행하여 Jenkins Job 설정과 중복되거나
                    // - 인증 정보를 스크립트에 하드코딩하는 것.
                    git branch: 'main', url: 'https://github.com/your-org/your-repo.git'
                    // 실제 GitHub/GitLab URL로 변경해야 합니다.
                }
            }
        }

        // Stage 2: 빌드 (Build)
        stage('Build') {
            steps {
                script {
                    echo "프로젝트를 빌드합니다."
                    // Java/Maven/Gradle 프로젝트를 빌드하는 스텝
                    // sh 'mvn clean install -DskipTests' // Maven 프로젝트 예시
                    // sh './gradlew clean build -x test' // Gradle 프로젝트 예시
                    sh 'bash ./Step3_JenkinsJobConfiguration.build.sh' // 외부 쉘 스크립트 실행 예시
                }
            }
        }

        // Stage 3: 테스트 (Test)
        stage('Test') {
            steps {
                script {
                    echo "단위 및 통합 테스트를 실행합니다."
                    // sh 'mvn test' // Maven 프로젝트 예시
                    // sh './gradlew test' // Gradle 프로젝트 예시
                    sh 'echo "테스트가 성공적으로 실행되었습니다."'
                }
            }
        }

        // Stage 4: 아티팩트 패키징 (Package Artifact)
        stage('Package') {
            steps {
                script {
                    echo "빌드된 결과물(JAR/WAR)을 패키징합니다."
                    // `archiveArtifacts` 스텝을 사용하여 빌드 결과를 Jenkins Job 아티팩트로 저장.
                    archiveArtifacts artifacts: 'build/libs/**/*.jar', fingerprint: true
                    // 나쁜 예시: 빌드된 아티팩트를 아카이빙하지 않아 이전 빌드의 결과를 추적하기 어렵게 하는 것.
                    // - `archiveArtifacts`를 사용하여 아티팩트를 저장하고, `fingerprint: true`로 의존성을 추적하는 것이 좋습니다.
                }
            }
        }

        // Stage 5: 배포 (Deploy) - 개발/스테이징 환경
        stage('Deploy to Dev') {
            // `when` 블록을 사용하여 특정 조건에서만 Stage를 실행할 수 있습니다.
            when {
                branch 'main' // 'main' 브랜치에서만 배포 Stage 실행
                // environment name: 'ENV_TYPE', value: 'DEV' // 특정 환경 변수 조건
            }
            steps {
                script {
                    echo "개발 환경에 배포합니다."
                    // sh 'kubectl apply -f k8s/dev-deployment.yaml' // Kubernetes 배포 예시
                    // sh 'docker push my-registry/my-app:latest' // Docker 이미지 푸시 예시
                    sh 'echo "애플리케이션이 개발 환경에 성공적으로 배포되었습니다."'
                }
            }
        }
    }

    // -----------------------------------------------------------------------------
    // 학습 포인트 6: `post` 섹션
    // - 파이프라인 빌드 결과(성공, 실패, 항상)에 따라 특정 액션을 수행합니다.
    // -----------------------------------------------------------------------------
    post {
        always { // 빌드 결과와 상관없이 항상 실행
            echo "파이프라인 실행 완료."
            // cleanWs() // 워크스페이스 정리 (불필요한 파일 삭제)
        }
        success { // 빌드가 성공했을 때 실행
            echo "빌드 성공! 알림을 보냅니다."
            // `slackSend channel: '#devops', message: '빌드 성공: ${env.BUILD_URL}'` // Slack 알림 예시
        }
        failure { // 빌드가 실패했을 때 실행
            echo "빌드 실패! 에러를 확인하세요."
            // `mail to: 'devs@example.com', subject: 'Jenkins 빌드 실패', body: '빌드 실패: ${env.BUILD_URL}'` // 이메일 알림 예시
        }
    }
}

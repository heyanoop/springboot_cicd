pipeline {
    agent any
    tools {
        jdk 'jdk'
        maven 'maven'
    }
    environment {
        SCANNER_HOME = tool "sonar-scanner"
        DOCKER_IMAGE = 'heyanoop/spring-boot-hello-world'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        DOCKER_CREDENTIALS = credentials('docker-hub')
        GIT_ACCESS_TOKEN = credentials('github-access-token') 
    }
    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/heyanoop/springboot_cicd.git'
            }
        }
        
        stage('Maven Build') {
            steps {
                sh "mvn clean package"
            }
        }
        
        stage('Unit Tests') {
            steps {
                sh "mvn test"
            }
        }
       
        stage('Docker Login & Build') {
            steps {
                script {
                    sh "echo $DOCKER_CREDENTIALS_PSW | docker login -u $DOCKER_CREDENTIALS_USR --password-stdin"
                    sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                }
            }
        }
        
        stage('Docker Tag & Push') {
            steps {
                script {
                    sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
                }
            }
        }
        
        stage('Docker Logout') {
            steps {
                script {
                    sh "docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG}"
                    sh "docker logout"
                }
            }
        }

        stage('Modify Helm Chart') {
            steps {
                script {
                    sh "sed -i 's/tag: .*/tag: "${DOCKER_TAG}"/' helm/springboot-chart/values.yaml"
                }
            }
        }
        
        stage('Package Helm Chart') {
            steps {
                script {
                    sh "helm package helm/springboot-chart -d ."
                }
            }
        }
        
        stage('Push Helm Chart to GitHub') {
            steps {
                script {
                    sh """
                        git config --global user.email "anoopsabu@live.com"
                        git config --global user.name "anoop"
                        git clone https://github.com/heyanoop/helm-repo.git
                        cp springboot-chart-0.1.0.tgz helm-repo/
                        cd helm-repo
                        git add .
                        git commit -m "Update Helm chart to version ${DOCKER_TAG}"
                        git push https://${GIT_ACCESS_TOKEN}@github.com/heyanoop/helm-repo.git
                    """
                }
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check the logs for more details.'
        }
    }
}


pipeline {
    agent any
    tools {
        jdk 'jdk'
        maven 'maven'
    }
    environment {
        SCANNER_HOME = tool "sonar-scanner"
        DOCKER_IMAGE = 'your-docker-hub-username/spring-boot-hello-world'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        DOCKER_CREDENTIALS = credentials('docker-hub')
    }
    stages {
        stage('Git checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/BuntyRaghani/spring-boot-hello-world.git'
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
        stage('Code Analysis') {
            steps {
                withSonarQubeEnv("sonar-server") {
                    sh '''
                    $SCANNER_HOME/bin/sonar-scanner \
                    -D sonar.projectName=spring-boot-hello-world \
                    -D sonar.java.binaries=target/classes \
                    -D sonar.projectKey=spring-boot-hello-world
                    '''
                }
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
    }
    post {
        always {
            sh "docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG}"
            sh "docker logout"
        }
    }
}

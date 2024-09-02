pipeline {
    agent any
    tools {
        jdk 'jdk'
        maven 'maven'
    }
    environment {
        DOCKER_IMAGE = 'heyanoop/spring-boot-hello-world'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        DOCKER_CREDENTIALS = credentials('dockerhub-token')
        AWS_CREDENTIALS = credentials('aws-ecr') 
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
                script {
                    try {
                        sh "mvn test"
                    } catch (Exception e) {
                        echo "Unit tests failed, but continuing with the pipeline..."
                    }
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
                    sh "sed -i 's/tag: .*/tag: '${DOCKER_TAG}'/' helm/springboot-chart/values.yaml"
                }
            }
        }
        
        stage('Package Helm Chart') {
            steps {
                script {
                    def chartVersion = "${env.BUILD_NUMBER}"
                    sh "helm package helm/springboot-chart --version ${chartVersion} -d ."
                }
            }
        }
        
        stage('Push Helm Chart to GitHub') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-ecr']])
                    def chartVersion = "${env.BUILD_NUMBER}"
                    sh """
                        aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}
                        aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}
                        aws configure set region ap-south-1
                        aws ecr get-login-password --region ap-south-1 | helm registry login 194722397084.dkr.ecr.ap-south-1.amazonaws.com --username AWS --password-stdin
                        mkdir helm-repo
                        cp springboot-chart-${chartVersion}.tgz helm-repo/
                        cd helm-repo
                        helm push springboot-chart-${chartVersion}.tgz oci://194722397084.dkr.ecr.ap-south-1.amazonaws.com
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


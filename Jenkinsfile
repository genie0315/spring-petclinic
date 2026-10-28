pipeline {
    agent any
    options {
        skipDefaultCheckout() // 젠킨스 자동 중복 체크아웃 충돌 원천 차단
    }
    tools {
        jdk 'JDK21'
        maven 'M3'
    }
    environment {
        DOCKERHUB_CRED = credentials('dockerhub-credentials')
        IMAGE_NAME = 'genie0315/spring-petclinic'
        TAG = 'latest'
    }
    
    stages {
        // 1. 명시적 SCM 체크아웃
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        // 2. Maven Build
        stage('Maven Build') {
            steps {
                echo 'Maven Build'
                sh 'mvn -Dmaven.test.failure.ignore=true clean package'
            }
        }

        // 3. Docker Image 생성
        stage('Docker Image Create') {
            steps {
                echo 'Docker Image Create'
                sh '''
                    docker build -t spring-petclinic:${BUILD_NUMBER} .
                    docker tag spring-petclinic:${BUILD_NUMBER} ${IMAGE_NAME}:${TAG}
                '''
            }
        }    

        // 4. Dockerhub Image Push
        stage('Docker Image Push') {
            steps {
                echo 'Docker Image Push'
                sh 'echo ${DOCKERHUB_CRED_PSW} | docker login -u ${DOCKERHUB_CRED_USR} --password-stdin'
                sh 'docker image push ${IMAGE_NAME}:${TAG}'
            } 
            post {
                always {
                    sh '''
                        docker rmi -f spring-petclinic:${BUILD_NUMBER}
                        docker rmi -f ${IMAGE_NAME}:${TAG}
                    '''
                } 
            }    
        }    

        // 5. Kubernetes 배포 (호스트 kubectl 직접 활용)
        stage('Kubernetes Deploy') {
            steps {
                echo 'Deploying to Kubernetes Cluster...'
                sh """
                    kubectl set image deployment/spring-petclinic spring-petclinic=${IMAGE_NAME}:${TAG} -n clinic-ns
                    kubectl rollout restart deployment/spring-petclinic -n clinic-ns
                """
            }
        }
    }
}

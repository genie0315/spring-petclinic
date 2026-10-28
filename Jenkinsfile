pipeline {
    agent any
    options {
        skipDefaultCheckout() // 자동 중복 체크아웃을 막아 Git 충돌을 원천 차단합니다.
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
        // [삭제 완료] 젠킨스가 SCM 설정으로 이미 코드를 받아오므로 Git Clone 단계는 필요 없습니다.

        // Maven을 이용한 Build
        stage('Maven Build') {
            steps {
                echo 'Maven Build'
                sh 'mvn -Dmaven.test.failure.ignore=true clean package'
            }
        }
        // Docker Image 생성
        stage('Docker Image Create') {
            steps {
                echo 'Docker Image Create'
                sh '''
                    docker build -t spring-petclinic:${BUILD_NUMBER} .
                    docker tag spring-petclinic:${BUILD_NUMBER} ${IMAGE_NAME}:${TAG}
                '''
            }
        }    
        // Dockerhub Image Push
        stage('Docker Image Push') {
            steps {
                echo 'Docker Image Push'
                // Docker Login
                sh 'echo ${DOCKERHUB_CRED_PSW} | docker login -u ${DOCKERHUB_CRED_USR} --password-stdin'

                // Docker Hub Push
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
        // Kubernetes를 이용한 배포 (도커 이미지 내부 환경 사용)
        stage('Kubernetes Deploy') {
            steps {
                echo 'Deploying to Kubernetes Cluster...'
                
                sh """
                    docker run --rm \
                      -v /var/run/docker.sock:/var/run/docker.sock \
                      -v /home/ubuntu/.kube:/root/.kube \
                      ${IMAGE_NAME}:${TAG} \
                      sh -c "kubectl set image deployment/spring-petclinic spring-petclinic=${IMAGE_NAME}:${TAG} -n clinic-ns && \
                            kubectl rollout restart deployment/spring-petclinic -n clinic-ns"
                """
            }
        }
    }
}

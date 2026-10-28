pipeline {
    agent any
    options {
        skipDefaultCheckout() // 자동 중복 체크아웃 방지
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
        // Github로부터 소스코드 다운로드
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

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

        // Kubernetes를 이용한 배포
        stage('Kubernetes Deploy') {
            steps {
                echo 'Deploying to Kubernetes Cluster...'
                sh """
                    docker run --rm \
                      -v /var/run/docker.sock:/var/run/docker.sock \
                      -v /home/ubuntu/.kube:/root/.kube \
                      -e KUBECONFIG=/root/.kube/config \
                      ${IMAGE_NAME}:${TAG} \
                      sh -c "kubectl --kubeconfig=/root/.kube/config set image deployment/spring-petclinic spring-petclinic=${IMAGE_NAME}:${TAG} -n clinic-ns && \
                            kubectl --kubeconfig=/root/.kube/config rollout restart deployment/spring-petclinic -n clinic-ns"
                """
            }
        }
    }
}

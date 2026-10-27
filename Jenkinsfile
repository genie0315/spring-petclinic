pipeline {
    agent any
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
        stage('Git Clone') {
            steps {
                echo 'Git Clone'
                git url: 'https://github.com/genie0315/spring-petclinic.git',
                branch: 'main'
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
        stage ('Docker Image Create') {
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
                  -v /root/.kube:/root/.kube \
                  ${IMAGE_NAME}:${TAG} \
                  sh -c "kubectl set image deployment/spring-petclinic spring-petclinic=${IMAGE_NAME}:${TAG} -n clinic-ns && \
                         kubectl rollout restart deployment/spring-petclinic -n clinic-ns"
            """
        }
    }
        
        
        
    }

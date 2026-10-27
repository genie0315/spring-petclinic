FROM jenkins/jenkins:lts-jdk21
USER root
RUN apt-get update && apt-get install -y \
    git \
    curl \
    sudo \
    wget \
    && apt-get clean

# Jenkins에 Docker 설치
COPY ./jenkins-in-docker-install.sh jenkins-in-docker-install.sh
RUN chmod u+x jenkins-in-docker-install.sh && ./jenkins-in-docker-install.sh

# Jenkins 사용자 도커 그룹에 추가
RUN groupadd -g 999 docker_host || true && getent group docker || groupadd docker && usermod -aG docker jenkins

RUN rm jenkins-in-docker-install.sh
# kubectl을 다운받아서 /usr/local/bin에 추가
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && mv kubectl /usr/local/bin

EXPOSE 8080
EXPOSE 50000

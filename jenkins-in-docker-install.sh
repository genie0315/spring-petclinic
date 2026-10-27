#!/bin/bash
set -e

echo "=== Installing Docker CLI ==="

# 도커 공식 스태틱 바이너리를 다운로드하여 컨테이너 내부에 설치
curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-24.0.7.tgz -o docker.tgz
tar xzvf docker.tgz
mv docker/docker /usr/local/bin/
rm -rf docker.tgz docker

echo "=== Docker CLI Installation Completed ==="

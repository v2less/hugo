---
title: "Docker Tips"
date: 2022-10-26T09:37:15+08:00
author: v2less
tags: ["linux"]
draft: false
---

## 安装docker

```bash
#!/bin/bash
curl -fsSL https://get.docker.com | sudo bash -s docker --mirror Aliyun
```
## 国内加速
```bash
cat /etc/docker/daemon.json
{
  "registry-mirrors": [
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com"
  ],
  "live-restore": true
}

```
## 代理

### 构建代理

```bash
docker build --net=host --build-arg http_proxy=http://x.x.x.x:8118 --build-arg https_proxy=http://x.x.x.x:8118 -t imagename .
```
### 运行代理

```bash
docker run -it --rm -e http_proxy=http://x.x.x.x:8118 -e https_proxy=http://x.x.x.x:8118 nginx:latest
```
## Docker镜像内置sshd服务

```yaml
ARG user=jenkins
ARG group=jenkins
ARG uid=1100
ARG gid=1100
RUN groupadd -g ${gid} ${group}
RUN useradd -c "Jenkins user" -d /home/${user} -u ${uid} -g ${gid} -m ${user}
ENV DEBIAN_FRONTEND=noninteractive
RUN apt install -y openssh-server ssh
# 变更root密码
RUN echo "root:uos123"|chpasswd
RUN echo "jenkins:uos123"|chpasswd
COPY .ssh/* /root/.ssh/
# 修改/etc/ssh/sshd_config
RUN sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config && \
      sed -i 's/required/sufficient/g' /etc/pam.d/chsh
# 生成sshkey
RUN yes 'y' | ssh-keygen -q -t dsa -N '' -f /etc/ssh/ssh_host_dsa_key
# 开放22端口
EXPOSE 22
USER ${user}
COPY .ssh/* /home/${user}/.ssh/
COPY entrypoint.sh /entrypoint.sh
RUN sudo chown -R ${user}:${jenkins} /home/${user}/.ssh
WORKDIR /home/jenkins
ENTRYPOINT [ "/entrypoint.sh" ]
```

entrypoint.sh
```bash
#!/usr/bin/env bash
set -e
echo "127.0.0.1 $HOSTNAME" | sudo tee -a /etc/hosts
sudo service ssh start
## Running passed command
if [[ "$1" ]]; then
        eval "$@"
else
  eval "/bin/zsh"
fi
```

## Docker镜像支持中文显示

```yaml
RUN apt install -y locales
ENV TZ 'Asia/Shanghai'
RUN locale-gen en_US.UTF-8 zh_CN.UTF-8
RUN dpkg-reconfigure locales
ENV LC_ALL="en_US.UTF-8"
ENV LANGUAGE="zh_CN:zh:en_US:en"
ENV LANG="en_US.UTF-8"
```

## 设置Docker镜像用户默认SHELL
```yaml
RUN chsh ${user} -s /bin/zsh
```

## Ubuntu默认Docker镜像没有ping ifconfig命令
```yaml
RUN apt install -y iproute2 net-tools iputils-ping
```
## docker中运行docker的方法之一

```bash
sudo chmod 666 /var/run/docker.sock
docker run --privileged=true -v /var/run/docker.sock:/var/run/docker.sock -it ...
```
## 使用主机的代理
docker-compose.yml
```yaml
---
version: "2"

services:
  xxx:
    build: .
    container_name: xxx
    image: xxx:latest
    extra_hosts:
      - "host.docker.internal:host-gateway"
    ports:
      - "127.0.0.1:8853:53/udp"
      - "127.0.0.1:9150:9150/tcp"
    restart: unless-stopped
```
在容器中就可以使用`host.docker.internal`作为host的地址来访问。

## Docker-copose.yaml实例
### android构建用自构建docker镜像
```yaml
version: '3'
services:
  ub:
    image: 'docker/private/ub'
    container_name: ub-media
    restart: always
    user: jenkins
    entrypoint: /entrypoint.sh
    tty: true
    environment:
      - TZ=Asia/Shanghai
    privileged: true
    ports:
      - '11022:22'
    volumes:
      - '/home/jenkins/build:/home/jenkins/build'
    deploy:
      resources:
        limits:
          cpus: '16'
          memory: 32G
        reservations:
          cpus: '12'
          memory: 24G
```

其中资源限制:
```yaml
    deploy:
      resources:
        limits:
          cpus: '16'
          memory: 32G
        reservations:
          cpus: '12'
          memory: 24G
```
启动:
```bash
docker-compose --compatibility up -d
```
停止:
```bash
docker-compose down
```

### gitlab实例

```yaml
version: '3'
services:
  gitlab:
    image: 'twang2218/gitlab-ce-zh'
    container_name: gitlab
    restart: always
    hostname: '10.12.21.251'
    environment:
      TZ: 'Asia/Shanghai'
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'http://10.12.21.251:9001'
        gitlab_rails['gitlab_shell_ssh_port'] = 3022
        unicorn['port'] = 8888
        nginx['listen_port'] = 9001
    ports:
      - '9001:9001'
      - '443:443'
      - '3022:22'
    volumes:
      - /git/gitlab/config:/etc/gitlab
      - /git/gitlab/data:/var/opt/gitlab
      - /git/gitlab/log:/var/log/gitlab
    deploy:
      resources:
        limits:
          cpus: '16'
          memory: 32G
        reservations:
          cpus: '12'
          memory: 24G
```



### nexus实例

```yaml
version: '3'
services:
  nexus:
    image: 'sonatype/nexus3'
    container_name: nexus
    restart: always
    user: root
    environment:
      - TZ=Asia/Shanghai
    ports:
      - '8081:8081'
      - '5000:5000'
    volumes:
      - '/nexus:/nexus-data'
    deploy:
      resources:
        limits:
          cpus: '16'
          memory: 32G
        reservations:
          cpus: '12'
          memory: 24G
```

## 图形化管理工具portainer

### 设置docker registry镜像和自架设的nexus地址
```bash
cat /etc/docker/daemon.json
{
  "registry-mirrors": [
    "http://10.12.21.251:5000"
  ],
  "insecure-registries": [
    "10.12.21.251:5000"
  ]
}
```

### 启动portainer

#### docker run方式
```bash
docker volume create portainer_data

docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data -e http_proxy=http://10.12.18.48:8118 -e https_proxy=http://10.12.18.48:8118 portainer/portainer-ce
```
#### docker-compose方式
docker-compose.yml
```yml
version: '3'
services:
  portainer:
    image: 'portainer/portainer-ce'
    container_name: portainer
    restart: always
    environment:
      - TZ=Asia/Shanghai
    privileged: true
    ports:
      - '8000:8000'
      - '9443:9443'
    volumes:
      - '/var/run/docker.sock:/var/run/docker.sock'
      - '/var/lib/docker/volumes/portainer_data:/data'
    deploy:
      resources:
        limits:
          cpus: '16'
          memory: 32G
        reservations:
          cpus: '12'
          memory: 24G
```
启动:
```bash
docker-compose --compatibility up -d
```

### 浏览器打开: https://127.0.0.1:9443

## protainer-agent

在客户端服务器上运行:

### docker run方式
```bash
docker run -d -p 9101:9001 --name portainer_agent --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker/volumes:/var/lib/docker/volumes portainer/agent
```
### docker-compose方式
docker-compose.yml
```yml
version: '3'
services:
  portainer:
    image: 'portainer/agent'
    container_name: portainer_agent
    restart: always
    environment:
      - TZ=Asia/Shanghai
    privileged: true
    ports:
      - '9101:9001'
    volumes:
      - '/var/run/docker.sock:/var/run/docker.sock'
      - '/var/lib/docker/volumes:/var/lib/docker/volumes'
    deploy:
      resources:
        limits:
          cpus: '8'
          memory: 8G
        reservations:
          cpus: '4'
          memory: 4G
```
启动:
```bash
docker-compose --compatibility up -d
```

到portainer管理界面, 添加一个 Environments

Docker Standalone --> Agent -->

Environment address: agent_ip:9101

## 有用的docker镜像

- nginx文件服务器带主题: https://github.com/fraoustin/fancyindex
```bash
docker run -d -v <localpath>:/share -e DISABLE_AUTH=true --name fancyindex -p 80:80 fraoustin/fancyindex
```

## Casaos

Casa OS是一个基于Docker生态系统的开源家庭云系统，专为家庭场景而设计。致力于打造全球最简单、最易用、最优雅的家居云系统。

```bash
curl -fsSL get.casaos.io/install.sh | sudo bash
```

## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2022-10-26T09:37:15+08:00

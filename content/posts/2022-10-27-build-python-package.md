---
title: "Build Python Package"
date: 2022-10-27T10:51:50+08:00
author: v2less
tags: ["linux"]
draft: false
---



## 构建环境

```bash
FROM arm64v8/ubuntu:16.04
ENV DEBIAN_FRONTEND=noninteractive
MAINTAINER username <username@gmail.com>
ARG user=jenkins
ARG group=jenkins
ARG uid=1100
ARG gid=1100
RUN groupadd -g ${gid} ${group}
RUN useradd -c "Jenkins user" -d /home/${user} -u ${uid} -g ${gid} -m ${user}
RUN sed -ri "s;http://ports.ubuntu.com;[trusted=yes] http://10.12.21.251:8081/repository;g" "/etc/apt/sources.list" && \
    sed -ri "s;http://archive.ubuntu.com;[trusted=yes] http://10.12.21.251:8081/repository;g" "/etc/apt/sources.list" && \
    sed -ri "s;http://security.ubuntu.com;[trusted=yes] http://10.12.21.251:8081/repository;g" "/etc/apt/sources.list" && \
    apt update && \
    apt install -y python3-requests python3-pip openssh-server ssh git \
        curl wget sudo rsync iputils-ping \
        iproute2 net-tools locales zsh fonts-powerline pigz gzip unzip vim-common
RUN curl -fsSL https://bootstrap.pypa.io/pip/3.5/get-pip.py | python3.5 && \
    python3 -m pip install -i http://10.12.21.251:8081/repository/pypi/simple --trusted-host 10.12.21.251 setuptools wheel twine
RUN usermod -aG sudo $user && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    mkdir -p /root/.ssh /home/${user}/.ssh
# 变更root密码
RUN echo "root:abc123"|chpasswd
RUN echo "jenkins:abc123"|chpasswd
COPY .ssh/* /root/.ssh/
# 修改/etc/ssh/sshd_config
RUN sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config && \
      sed -i 's/required/sufficient/g' /etc/pam.d/chsh
# 生成sshkey
RUN yes 'y' | ssh-keygen -q -t dsa -N '' -f /etc/ssh/ssh_host_dsa_key
# 开放22端口
EXPOSE 22
COPY vimrc /root/.vimrc
COPY vimrc /home/${user}/.vimrc
ENV TZ 'Asia/Shanghai'
RUN locale-gen en_US.UTF-8 zh_CN.UTF-8
RUN dpkg-reconfigure locales
ENV LC_ALL="en_US.UTF-8"
ENV LANGUAGE="zh_CN:zh:en_US:en"
ENV LANG="en_US.UTF-8"
COPY entrypoint.sh /entrypoint.sh
ADD install_oh_my_zsh.sh /tmp/
ADD install_check_format.sh /tmp/
RUN /tmp/install_oh_my_zsh.sh
RUN /tmp/install_check_format.sh
RUN chsh -s /bin/zsh
USER ${user}
COPY .ssh/* /home/${user}/.ssh/
RUN sudo chown -R ${user}:${jenkins} /home/${user}/.ssh
RUN /tmp/install_oh_my_zsh.sh
RUN /tmp/install_check_format.sh
RUN sudo chsh ${user} -s /bin/zsh
SHELL ["/bin/zsh", "-c"]
WORKDIR /home/jenkins
ENTRYPOINT [ "/entrypoint.sh" ]
```



## 构建

```bash
[ -f requirements.txt ] &&  python3 -m pip install -i http://10.12.21.251:8081/repository/pypi/simple --trusted-host 10.12.21.251 -r requirements.txt
python3 setup.py check || exit 1
python3 setup.py sdist bdist_wheel || exit 1
```

## 上传

```bash
twine upload dist/* --repository-url http://10.12.21.251:8081/repository/pypi-hosted/  -u user -p user123
```



## 安装

```bash
python3 -m pip install -i http://10.12.21.251:8081/repository/pypi/simple --trusted-host 10.12.21.251 pyclip
```



## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2022-10-27T10:51:50+08:00

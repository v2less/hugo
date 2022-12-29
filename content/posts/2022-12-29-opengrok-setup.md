---
title: "Opengrok搭建"
date: 2022-12-29T10:08:47+08:00
author: v2less
tags: ["linux"]
draft: false
---

## Opengrok简介

OpenGrok是一个快速，便于使用的源码搜索引擎与对照引擎，它能够帮助我们快速的搜索、定位、对照代码树。一般常用于大型的项目中，比如Android系统源码。 

# 环境

### 硬件配置

CPU建议16核心以上，内存32G以上，硬盘2T(根据需要)

OS:Debian11

Web Server: tomcat10

JDK: openjdk-11-jre

opengrok: 1.7.41

python:3.9+

### 软件依赖

```bash
sudo apt update
sudo apt install -y openjdk-11-jre universal-ctags vim xfsprogs git locales
```

 ### 配置磁盘

逻辑卷、格式化、挂载到/opengrok目录

```bash
sudo vgcreate -s 128M data /dev/sdb
sudo lvcreate -l 100%FREE -n data data
sudo mkfs.xfs -L data /dev/data/data
blkid /dev/data/data
sudo mkdir /opengrok
cat <<EOF | sudo tee -a /etc/fstab
UUID="cdf4bd32-525b-4340-97ad-b67c34b64d2c" /opengrok  xfs  defaults 0 2
EOF
sudo mount -a
```



## Tomcat搭建

```bash
#!/bin/bash
sudo sed -ri "s/^#(.*zh_CN.UTF-8)/\1/g" /etc/locale.gen
sudo locale-gen
sudo useradd -m -U -d /opt/tomcat -s /bin/bash tomcat
VERSION=10.1.4
#wget -c -O /tmp/apache-tomcat-${VERSION}.tar.gz https://dlcdn.apache.org/tomcat/tomcat-10/v${VERSION}/bin/apache-tomcat-${VERSION}.tar.gz
wget -c -O /tmp/apache-tomcat-${VERSION}.tar.gz https://mirrors.cnnic.cn/apache/tomcat/tomcat-10/v${VERSION}/bin/apache-tomcat-${VERSION}.tar.gz || exit 1

sudo tar -xf /tmp/apache-tomcat-${VERSION}.tar.gz -C /opt/tomcat/
sudo ln -sfn /opt/tomcat/apache-tomcat-${VERSION} /opt/tomcat/latest
sudo sh -c 'chmod +x /opt/tomcat/latest/bin/*.sh'
sudo chown -R tomcat: /opt/tomcat

cat <<EOF | sudo tee /etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat 9.0 servlet container
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"

Environment="CATALINA_BASE=/opt/tomcat/latest"
Environment="CATALINA_HOME=/opt/tomcat/latest"
Environment="CATALINA_PID=/opt/tomcat/latest/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/tomcat/latest/bin/startup.sh
ExecStop=/opt/tomcat/latest/bin/shutdown.sh

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now tomcat
sudo systemctl restart tomcat
sudo systemctl status tomcat
```



## Opengrok搭建

### opengrok安装

```bash
#!/bin/bash
sudo chown -R tomcat: /opengrok
mkdir -p /opengrok/{src,data,dist,etc,log}
sudo wget -c -O /tmp/opengrok.tar.gz https://github.com/oracle/opengrok/releases/download/1.7.41/opengrok-1.7.41.tar.gz || exit 1
sync
tar -C /opengrok/dist --strip-components=1 -xzf /tmp/opengrok.tar.gz
cp /opengrok/dist/doc/logging.properties /opengrok/etc
pushd /opengrok/dist/tools/ >/dev/null || exit 1
sudo pip3 install opengrok-tools.tar.gz
popd >/dev/null || exit 1

sudo rm -rf /opt/tomcat/latest/webapps/ROOT
sudo rm -rf /opt/tomcat/latest/webapps/ROOT.war
sudo chown -R tomcat: /opengrok
#改成ROOT.war是为了访问http地址时不需要跟/source路径
sudo runuser -l tomcat -c "cp /opengrok/dist/lib/source.war /opengrok/dist/lib/ROOT.war"
sudo runuser -l tomcat -c "opengrok-deploy -c /opengrok/etc/configuration.xml /opengrok/dist/lib/ROOT.war /opt/tomcat/latest/webapps/"
#sudo runuser -l tomcat -c "java -Djava.util.logging.config.file=/opengrok/etc/logging.properties -jar /opengrok/dist/lib/opengrok.jar -c /usr/bin/ctags -s /opengrok/src -d /opengrok/data -H -P -S -G -W /opengrok/etc/configuration.xml -U http://127.0.0.1:8080"
cat << EOF | sudo tee /usr/local/bin/opengrok-index
sudo runuser -l tomcat -c "opengrok-indexer \
    -J=-Djava.util.logging.config.file=/opengrok/etc/logging.properties \
    -a /opengrok/dist/lib/opengrok.jar -- \
    -c /usr/bin/ctags \
    -s /opengrok/src -d /opengrok/data -H -P -S -G \
    -W /opengrok/etc/configuration.xml -U http://127.0.0.1:8080"
EOF
sudo chmod +x /usr/local/bin/opengrok-index
```

### 存放源码

在/opengrok/src目录下存放源码，或者link过去

### 创建索引

吃CPU，过程很慢，系统硬件配置要高配

```bash
/usr/local/bin/opengrok-index
```



## 参考

https://github.com/oracle/opengrok/wiki/How-to-setup-OpenGrok



## 文档信息

---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2022-12-29T10:08:47+08:00

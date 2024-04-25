---
title: "Install Jenkins on Debian_ubuntu"
date: 2024-01-06T08:45:33+08:00
author: v2less
tags: ["linux"]
draft: false
---
## 安装

```bash
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install jenkins -y
```
sudo vi /lib/systemd/system/jenkins.service
修改启动用户为你自己的用户名，替换掉jenkins用户
```bash
User=username
Group=username
```
设定工作目录，默认即可
```bash
Environment="JENKINS_HOME=/var/lib/jenkins"
WorkingDirectory=/var/lib/jenkins
```
自定义端口号
```bash
Environment="JENKINS_PORT=8079"
```
如果没有单独的域名，是作为域名子路经来配置的话：
```bash
Environment="JENKINS_PREFIX=/jenkins"
```
为了支持老版本的gerrit，需要修改配置
```bash
Environment="JAVA_OPTS=-Djava.awt.headless=true \
-Djsch.client_pubkey=\"ssh-ed25519,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521,rsa-sha2-512,rsa-sha2-256,ssh-rsa\" \
-Djsch.server_host_key=\"ssh-ed25519,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521,rsa-sha2-512,rsa-sha2-256,ssh-rsa\""
```
使得jenkins.service文件生效
```bash
sudo systemctl daemon-reload
```
其他步骤：
```bash
#修改权限
sudo chown -R username:groupname /var/lib/jenkins
sudo chown -R username:groupname /var/cache/jenkins
#启动
sudo systemctl restart jenkins
#替换插件升级服务器
sed -i 's/http:\/\/updates.jenkins-ci.org\/download/https:\/\/mirrors.tuna.tsinghua.edu.cn\/jenkins/g' /var/lib/jenkins/updates/default.json && sed -i 's/http:\/\/www.google.com/https:\/\/www.baidu.com/g' /var/lib/jenkins/updates/default.json

sed -i 's/<url.*url>/<url>https:\/\/mirrors.tuna.tsinghua.edu.cn\/jenkins\/updates\/update-center.json<\/url>/g' /var/li
b/jenkins/hudson.model.UpdateCenter.xml

#让你的用户为sudo用户，并免密码
sudo visudo
#启动
sudo systemctl enable jenkins --now

#获取初始密码
cat /var/lib/jenkins/secrets/initialAdminPassword
```
## 访问jenkins
http://ip:8080
## 安装推荐的插件
## 设置一个管理员账号
## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期：2024-01-06T08:45:33+08:00

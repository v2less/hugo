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

## 常用插件

- Localization: Chinese (Simplified)
- Timestamper
- - 提供 timestamps()方法，日志打印时间
- Blue Ocean
- Workspace Cleanup
- - 提供cleanWs()方法，清理工作空间
- Build Timeout
- ansiColor 彩色输出
- Parameterized Trigger
- Build With Parameters
- Role-based Authorization Strategy
- - 首先到 系统管理-->安全-->全局安全设置(manage/configureSecurity/) --> 授权策略，选择 Role-Based Strategy
- - 然后到 系统管理-->安全-->Manage and Assign Roles
- Scriptler
- ThinBackup
- Job Configuration History
    功能：保存job configuration的历史，记录每一次改动的信息。对于job configuration每一次的改变，保存一个config.xml文件。提供overview页面，方便查看全部的改变。可以对比查看两次改动之间的区别。
- Conditional BuildStep
    功能：可以灵活配置的build step。通常和Parameterized Trigger配合使用。
- Groovy Postbuild
该插件在 Jenkins JVM 执行 Groovy 脚本。通常基于 build 的运行结果，check 一些条件和变化。例如，可以在 build history 中 build 旁边添加图标 badges 或是显示有关 build 的描述。
```groovy
if(manager.logContains("Started by timer")){
    env.BUILD_MODE = "new"
}
manager.addShortText("${manager.getEnvVariable('Project_Name')}")
manager.addBadge("success.gif", "success")
manager.addWarningBadge("build Failure.")
manager.addBadge("error.gif", "failed")
```
- 给描述增加超链接
/manage/configureSecurity/
标记格式器 改成 Safe HTML
```groovy
String description = "<a href='${env.DOWNLOAD_URL}' target='_blank'>Download</a>"
currentBuild.description = "${env.PROC_NAME} " +  "${env.BUILD_VERSION} \n" +
    ¦   ¦   "${env.BUILD_MODE} " + "${env.BUILD_EDITION} \n" +
    ¦   ¦   "${description}"
```
- SSH Agent
该插件允许您通过 Jenkins 中的 ssh-agent 提供 SSH 凭据来构建。

- HashiCorp Vault
一款对敏感信息进行存储，并进行访问控制的工具。敏感信息指的是密码、token、秘钥等。它不仅可以存储敏感信息，还具有滚动更新、审计等功能。
```groovy
environment {
    SECRET = vault path: 'secret/hello', key:'value'
}
```
- Docker Pipeline
- Rebuilder
- Gerrit Trigger
- build user vars
```groovy
node {
  def user=""
  def userEmail=""
  wrap([$class: 'BuildUser']) {
    user = env.BUILD_USER_ID
    userEmail = env.BUILD_USER_EMAIL
  }
  echo "The user name ${user }"
  echo "The user email ${userEmail }"
}
```
- warnings-ng
>Jenkins 下一代静态分析工具报告的问题收集并可视化结果。


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
#修改启动用户为你自己的用户名，替换掉jenkins用户
sudo vi /etc/systemd/system/multi-user.target.wants/jenkins.service
sudo systemctl daemon-reload
#修改权限
sudo chown -R username:groupname /var/lib/jenkins
sudo chown -R username:groupname /var/cache/jenkins
#替换插件升级服务器
sed -i 's/http:\/\/updates.jenkins-ci.org\/download/https:\/\/mirrors.tuna.tsinghua.edu.cn\/jenkins/g' /var/lib/jenkins/updates/default.json && sed -i 's/http:\/\/www.google.com/https:\/\/www.baidu.com/g' /var/lib/jenkins/updates/default.json

sed -i 's/<url.*url>/<url>https:\/\/mirrors.tuna.tsinghua.edu.cn\/jenkins\/updates\/update-center.json<\/url>/g' /var/li
b/jenkins/hudson.model.UpdateCenter.xml

#让你的用户为sudo用户，并免密码
#启动
sudo systemctl enable jenkins --now

#获取初始密码
cat /var/lib/jenkins/secrets/initialAdminPassword
```
## 访问jenkins
http://ip:8080
## 安装推荐的插件
## 设置一个管理员账号

## 再安装下面的插件

- Localization: Chinese (Simplified)
- Timestamper
    提供 timestamps()方法，日志打印时间
- Blue Ocean
- Workspace Cleanup
    提供cleanWs()方法，清理工作空间
- Build Timeout
- ansiColor
    彩色输出
- Parameterized Trigger
- Build With Parameters
- Role-based Authorization Strategy
    首先到 系统管理–>安全–>全局安全设置(manage/configureSecurity/) –> 授权策略，选择 Role-Based Strategy
    然后到 系统管理–>安全–>Manage and Assign Roles
- Scriptler
- ThinBackup
- Job Configuration History
    功能：保存job configuration的历史，记录每一次改动的信息。对于job configuration每一次的改变，保存一个config.xml文件。提供overview页面，方便查看全部的改变。可以对比查看两次改动之间的区别。
- Conditional BuildStep
    功能：可以灵活配置的build step。通常和Parameterized Trigger配合使用。

```






## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2024-01-06T08:45:33+08:00

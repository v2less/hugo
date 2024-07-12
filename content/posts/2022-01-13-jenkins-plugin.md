---
title: "Jenkins Plugin"
date: 2022-01-13T20:12:58+08:00
author: v2less
tags: ["linux"]
draft: false
---

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
- buildtriggerbadge
>该插件直接在构建历史记录中显示代表构建原因的图标。
比如：谁触发了构建，定时构建等。
- mask-passwords
>该插件允许屏蔽可能出现在控制台中的密码，包括定义为构建参数的密码。
- Pipeline Utility Steps
从流水线中的特定阶段重新开始执行
- Build Timestamp
生成构建启动时间，无论是否排队，变量：BUILD_TIMESTAMP

## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2022-01-13T20:12:58+08:00

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



## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2022-01-13T20:12:58+08:00

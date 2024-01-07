---
title: "SSH Connections Manager MRemoteNG"
date: 2024-01-07T22:15:51+08:00
author: v2less
tags: ["linux"]
draft: false
---
## 下载

- [官方网站](https://mremoteng.org/)
- [Github项目主页](https://github.com/mRemoteNG/mRemoteNG)
## 转换ssh 私钥为putty私钥


- 下载并安装Putty和Puttygen工具：

- 使用puttygen创建私钥文件

打开puttygen，Type of key to generate 处选择RSA，然后单击 Load。

选择显示所有类型的文件，选择创建密钥对时下载到本地的密钥对文件，单击 打开。

然后点击 Save private key，生成私钥文件。

选择私钥文件的保存路径，单击 保存。

- 使用putty配置密钥登录

打开mRemoteNG,文件-->选项-->高级， load putty，在Session的Host Name处输入远程主机的IP地址。

说明：如果需要保存会话，请在 Saved Sessions 处输入要保存会话的名称，然后单击 Save

在 SSH > Auth 处配置SSH的认证方式，单击 Browse，选择使用puttygen创建的私钥文件。

## 添加connetion

新建连接-->配置，填写相关信息-->其中：协议下的PuTTY会话，选择相应的配置，会使用这个配置的私钥进行连接，如果你不想用密码直接连接的话。
## 添加工具WinSCP
WinSCP 是一个 Windows 环境下使用的 SSH 的开源图形化 SFTP 客户端。同时支持 SCP 协议。它的主要功能是在本地与远程计算机间安全地复制文件，并且可以直接编辑文件。
下载并安装winscp

打开mRemoteNG,工具-->外部工具:
```bash
显示名称：WinSCP
文件名： 浏览到WinSCP.exe
参数：scp://%Username%@%Hostname%:%Port%/ /privatekey=Path_to_putty.ppk
如果你直接用密码的话，这样填写：
参数：scp://%Username%:%Password%@%Hostname%:%Port%/
```
## 更多外部工具
<https://lazywinadmin.com/2010/08/mremoteng-external-applications.html>




## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2024-01-07T22:15:51+08:00

---
title: "Install Wsl2 on Windows11"
date: 2024-01-07T17:47:11+08:00
author: v2less
tags: ["linux"]
draft: false
---

## 安装wsl
> 需要运行 Windows 10 build 18917 或更高版本才能使用 WSL 2，并且你需要安装 WSL

- Open the start menu and search for "Turn Windows features on or off".
- In the resulting window, check 'Windows Subsystem for Linux' and 'Virtual Machine Platform' and then click 'ok'. This starts the system installed for WSL and will ask us to restart after it downloads the stuff it needs. This really only gives you the WSL1 setup.
- Download a kernel update to get WSL2 going.
```cmd
wsl.exe --update
```
- 如果你想使 WSL 2 成为默认架构，可以使用以下命令执行此操作：
```cmd
wsl --set-default-version 2
```

## 安装ubuntu
- uninstall image (if needed)
```cmd
# wsl --unregister <distroName>
wsl --unregister ubuntu-22.04
```
- 要验证每个发行版使用的 WSL 版本，请使用以下命令：
```cmd
wsl --list --verbose
或
wsl -l -v
```
- 安装ubuntu
```cmd
wsl --install -d Ubuntu
```

## 新的 WSL 命令
WSL 添加了一些新命令选项来帮助控制和查看 WSL 版本和发行版。

除了上面提到的 --set-version 和 --set-default-version 之外，还有：

- - wsl --shutdown
立即终止所有正在运行的发行版和 WSL 2 轻量级实用程序虚拟机。
一般来说，支持 WSL 2 发行版的虚拟机是由 WSL 来管理的，因此会在需要时将其打开并在不需要时将其关闭。但也可能存在你希望手动关闭它的情况，此命令允许你通过终止所有发行版并关闭 WSL 2 虚拟机来执行此操作。
- - wsl --list --quiet
仅列出发行版名称。此命令对于脚本编写很有用，因为它只会输出你已安装的发行版的名称，而不显示其他信息，如默认发行版、版本等。
- - wsl --list --verbose
显示有关所有发行版的详细信息。此命令列出每个发行版的名称，发行版所处的状态以及正在运行的版本。默认发行版标以星号。







## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2024-01-07T17:47:11+08:00

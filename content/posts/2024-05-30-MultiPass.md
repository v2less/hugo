---
title: "MultiPass"
date: 2024-05-30T00:37:30Z
author: v2less
tags: ["linux"]
draft: false
---
Get an instant Ubuntu VM with a single command.
<https://multipass.run/>

## 查看支持的系统镜像列表
```bash
multipass find
```
## 设置桥接模式的网络
```bash
# 比如重命名以太网2为lan2
multipass set local.bridged-network=lan2
```
### ❤️ 扩展知识
可能有小伙伴会问 笔记本电脑没有 有线网卡。只有Wifi 应该如何桥接呢？有时候，windows 下的multipass 可能打印不出wifi网卡。比如 输入 `multipass networks`

遇到识别不出wifi 网卡的情况，其实还可以利用Hyper-V 管理器新建一个虚拟交换机。

>打开hyper-v管理器。点击【虚拟交换管理器】-【新建虚拟网络交换机】-【外部】-【创建】 然后你勾选一下你的 wifi 无线网卡，然后 名称的话 改成英文吧，比如 wifi 。这样应用之后，你再去打印multipass networks 就能识别wifi啦

## 创建桥接模式的虚拟机vm1

可以指定使用ubuntu-22.04版本，不指定则用最新版本

使用桥接模式，新建 4核心 4GB内存 100G虚拟磁盘的ubuntu 实例
```bash
multipass launch --name vm1 -c 4 -m 4G -d 100G --network bridged  ubuntu-22.04
```
## 如何换 国内 软件源 比如阿里云 Ubuntu 24.04 为例
```bash
sudo sed -i 's|http://archive.ubuntu.com/|http://mirrors.aliyun.com/|g' /etc/apt/sources.list.d/ubuntu.sources
sudo -i
apt update -y
apt upgrade -y
```

## 如何删除虚拟机实例（分三步）
```bash
# 停止 vm1
multipass stop vm1
# 删除 vm1
multipass delete vm1
# 清理回收
multipass purge

# 附加

# 停止全部虚拟机
multipass stop --all
```
## 查看虚拟机列表 包括其状态（正在运行、已经删除的、已经停止的、标记未知状态的）
```bash
multipass list
```





## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2024-05-30T00:37:30Z

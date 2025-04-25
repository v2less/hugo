---
title: "网络聚合Network Bonding"
date: 2025-04-25T17:37:13+08:00
author: v2less
tags: ["linux"]
draft: false
---

## 虚拟机下模拟的配置
```bash
cat /etc/netplan/00-installer-config.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:
      dhcp4: no
    ens36:
      dhcp4: no
  bonds:
    bond0:
      interfaces:
        - ens33
        - ens36
      addresses:
        - 192.168.217.129/24
      gateway4: 192.168.217.2
      nameservers:
        addresses:
          - 114.114.114.114
          - 19.29.29.29
      parameters:
        mode: active-backup
        mii-monitor-interval: 100
        primary: ens33

#生效
sudo netplay apply
#可能需要重启后才能生效

#链路聚合结果查看
cat /proc/net/bonding/bond0
```
>特点：只有一个设备处于活动状态，当一个宕掉另一个马上由备份转换为主设备。mac地址是外部可见得，从外面看来，bond的MAC地址是唯一的，以避免switch(交换机)发生混乱。此模式只提供了容错能力；由此可见此算法的优点是可以提供高网络连接的可用性，但是它的资源利用率较低，只有一个接口处于工作状态，在有N个网络接口的情况下，资源利用率为1/N。

高可用模式，运行时只使用一个网卡，其余网卡作为备份，在负载不超过单块网卡带宽或压力时建议使用。

## 服务器使用802.3ad模式


对于服务器，如果交换机支持LACP, 可以使用其他模式，例如：802.3ad
>特点：创建一个聚合组，它们共享同样的速率和双工设定。根据802.3ad规范将多个slave工作在同一个激活的聚合体下。外出流量的slave选举是基于传输hash策略，该策略可以通过xmit_hash_policy选项从缺省的XOR策略改变到其他策略。需要注意的是，并不是所有的传输策略都是802.3ad适应的，尤其考虑到在802.3ad标准43.2.4章节提及的包乱序问题。不同的实现可能会有不同的适应性。

>802.3ab负载均衡模式，要求交换机也支持802.3ab模式，理论上服务器及交换机都支持此模式时，网卡带宽最高可以翻倍(如从1Gbps翻到2Gbps)

>必要条件：
条件1：ethtool支持获取每个slave的速率和双工设定
条件2：switch(交换机)支持IEEE802.3ad Dynamic link aggregation
条件3：大多数switch(交换机)需要经过特定配置才能支持802.3ad模式

```bash
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:
      dhcp4: no
    ens36:
      dhcp4: no
  bonds:
    bond0:
      interfaces:
        - ens33
        - ens36
      addresses:
        - 192.168.217.129/24
      gateway4: 192.168.217.2
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1
      parameters:
        mode: 802.3ad
        lacp-rate: fast  # 可选，设置 LACP 协商速度（fast 或 slow）
        mii-monitor-interval: 100
        primary: ens33
```






## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2025-04-25T17:37:13+08:00

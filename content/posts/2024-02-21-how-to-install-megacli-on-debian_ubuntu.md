---
title: "How to install megacli on debian/ubuntu"
date: 2024-02-21T07:13:11Z
author: v2less
tags: ["linux"]
draft: false
---
## 安装
```bash
DISTRO=$(lsb_release -si | tr [A-Z] [a-z])
DIST=$(lsb_release -c | grep "Codename:" | awk '{print $2}')  # jessie wheezy or stratch  whatelse
wget -O - https://hwraid.le-vert.net/$DISTRO/hwraid.le-vert.net.gpg.key | sudo apt-key add -
echo " deb http://hwraid.le-vert.net/$DISTRO $DIST main " | sudo tee /etc/apt/sources.list.d/raidtoolRepo.list
sudo apt-get update
sudo apt-get install megactl megacli megamgr
```

## 使用
```bash
megacli -LDInfo -Lall -aALL 查raid级别
megacli -AdpAllInfo -aALL 查raid卡信息
megacli -PDList -aALL 查看硬盘信息
megacli -AdpBbuCmd -aAll 查看电池信息
megacli -FwTermLog -Dsply -aALL 查看raid卡日志

megacli常用参数介绍
megacli -adpCount 【显示适配器个数】
megacli -AdpGetTime –aALL 【显示适配器时间】
megacli -AdpAllInfo -aAll 【显示所有适配器信息】
megacli -LDInfo -LALL -aAll 【显示所有逻辑磁盘组信息】
megacli -PDList -aAll 【显示所有的物理信息】
megacli -AdpBbuCmd -GetBbuStatus -aALL |grep ‘Charger Status’ 【查看充电状态】
megacli -AdpBbuCmd -GetBbuStatus -aALL【显示BBU状态信息】
megacli -AdpBbuCmd -GetBbuCapacityInfo -aALL【显示BBU容量信息】
megacli -AdpBbuCmd -GetBbuDesignInfo -aALL 【显示BBU设计参数】
megacli -AdpBbuCmd -GetBbuProperties -aALL 【显示当前BBU属性】
megacli -cfgdsply -aALL 【显示Raid卡型号，Raid设置，Disk相关信息】
```


## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2024-02-21T07:13:11Z

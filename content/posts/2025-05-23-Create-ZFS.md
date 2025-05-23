---
title: "2025 05 23 Create ZFS"
date: 2025-05-23T08:27:03+08:00
author: v2less
tags: ["linux"]
draft: false
---

```bash
# 安装 ZFS 支持
sudo apt install zfsutils-linux

# 创建 ZFS RAID-Z1 存储池
sudo zpool create data raidz1 /dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf /dev/sdg

# 如果需要热备，编译用途没必要
sudo zpool create data raidz1 /dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf spare /dev/sdg

# 优化设置
sudo zfs set compression=lz4 data
sudo zfs set atime=off data
sudo zfs set recordsize=128K data
sudo zfs set acltype=posixacl
sudo zfs set atime=off data


# （可选）禁用同步写入加速编译
sudo zfs set sync=disabled data

# 用于编译源码
cd /data
repo init ...

# 设置容量限制
zfs create data/user1
zfs set quota=10G data/user1
zfs list
# 定时进行数据修复
(crontab -l ; echo "0 2 * * 0 /sbin/zpool scrub data") | crontab -

# smart监控
sudo apt install smartmontools

# 测速
fio --name=write --directory=/data --size=1G --rw=write --bs=1M --numjobs=4 --direct=1 --ioengine=libaio

```







## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2025-05-23T08:27:03+08:00

---
title: "Windows11上利用WSL挂载 Linux硬盘"
date: 2023-05-20T14:04:32+08:00
author: v2less
tags: ["linux"]
draft: false
---

0. 把硬盘接到电脑上
1. 用管理员权限打开Powershell
在powershell中输入以下命令查看硬盘信息
```cmd
GET-CimInstance -query "SELECT * from Win32_DiskDrive"
```

我的输出：
```cmd
DeviceID           Caption                               Partitions Size          Model
--------           -------                               ---------- ----          -----
\\.\PHYSICALDRIVE0 KXG6AZNV512G TOSHIBA                  3          512105932800  KXG6AZNV512G TOSHIBA
\\.\PHYSICALDRIVE1 ATA WDC WD40EFRX-68N SCSI Disk Device 2          4000784417280 ATA WDC WD40EFRX-68N SCSI Disk Device
```

2. 然后挂载磁盘
```cmd
 wsl --mount \\.\PHYSICALDRIVE1 --bare
```
4. wls中挂载磁盘分区
```bash
lsblk
sudo kdir /mnt/sdc1
sudo mount /dev/sdc1 /mnt/sdc1

```
5.卸载磁盘分区
```bash
sudo umount /dev/sdc1
```
6. 卸载磁盘
```cmd
 wsl --unmount \\.\PHYSICALDRIVE1
```





## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2023-05-20T14:04:32+08:00

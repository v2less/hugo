---
title: "Emuelec Img Write to Udisk on Linux"
date: 2023-02-24T12:55:09+08:00
author: v2less
tags: ["linux"]
draft: false
---

## 下载Emuelec整合img
https://www.emuelec.cn/category/integrate

## 查看Emuelec img分区情况
```bash
parted Emuelec\ 4.6-正式版-s905x2x3X4-s922-57.5g-2.img
> unit b
> print
Sector size (logical/physical): 512B/512B
Partition Table: msdos
Disk Flags:

Number  Start        End           Size          Type     File system  Flags
 1      4194304B     2151677951B   2147483648B   primary  fat32        boot, lba
 2      2151677952B  4294967295B   2143289344B   primary  ext4
 3      4294967296B  61813555199B  57518587904B  primary  fat32        lba
> quit
```
## 准备一个64G优盘，分区
分三个分区，比照img的情况,图形工具gparted.
```bash
设备       启动    起点      末尾      扇区  大小 Id 类型
/dev/sda1  *       2048   4399103   4397056  2.1G  c W95 FAT32 (LBA)
/dev/sda2       4399104   8787967   4388864  2.1G 83 Linux
/dev/sda3       8787968 120176639 111388672 53.1G  c W95 FAT32 (LBA)
```
## 多分区img虚拟loop设备
```bash
sudo losetup --partscan --show --find Emuelec\ 4.6-正式版-s905x2x3X4-s922-57.5g-2.img
```
设备``/dev/loop11，三个分区：/dev/loop11p1 /dev/loop11p2 /dev/loop11p3
## dd img的分区到优盘对应分区
```bash
sudo dd if=/dev/loop11p1 of=/dev/sda1 bs=1024 status=progress
sudo dd if=/dev/loop11p2 of=/dev/sda2 bs=1024 status=progress
```
至于第三个分区，可以挂载到目录后进行删减不需要的内容，比如kof94-96的内容。再进行复制到优盘第三个分区。
```bash
sudo mount -o iocharset=utf8 /dev/loop15p3 rootfs
sudo mount /dev/sda3 /mnt
sudo rsync -av --delete rootfs/* /mnt/
```







## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2023-02-24T12:55:09+08:00

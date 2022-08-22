---
title: "2022 08 22 Install Rocky Linux 9"
date: 2022-08-22T13:53:20+08:00
author: v2less
tags: ["linux"]
draft: false
---


## 更好国内源

```bash
sed -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.sjtug.sjtu.edu.cn/rocky|g' \
    -i.bak \
    /etc/yum.repos.d/rocky-*.repo
```
## 安装epel
```bash
sudo dnf install epel-release -y
sudo dnf install neofetch -y
```

## vdo
```bash
dnf install vdo kmod-kvdo
```

创建逻辑卷
```bash
pvcreate /dev/sdb
vgcreate vg-name /dev/sdb
vgdisplay
lvcreate --type vdo \
           --name vdo-name
           --size physical-size
           --virtualsize logical-size \
           vg-name
#逻辑大小差不多是物理大小的十倍

mkfs.xfs /dev/vg-name/vdo-name
mkdir /mnt/vdo
blkid /dev/vg-name/vdo-name
#然后配置挂载信息到/etc/fstab
```



## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2022-08-22T13:53:20+08:00

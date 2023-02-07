---
title: "Local Debug rootfs.img"
date: 2023-02-07T11:38:48+08:00
author: v2less
tags: ["linux"]
draft: false
---

## rootfs.img本地调试

在x86主机上，使用systemd-container容器技术进行。

- 安装依赖
```bash
sudo apt-get install -y qemu qemu-user-static binfmt-support systemd-container
```
- 获取 rootfs.img.gz

```bash
gunzip rootfs.img.gz
#保留原文件的解压方法
gunzip -c rootfs.img.gz > rootfs.img
sync
[ -d /rootfs ] && sudo umount /rootfs || true
[ -d /rootfs ] && sudo rm -rf /rootfs || true
sudo mkdir -p /rootfs
sudo mount rootfs.img /rootfs
sudo systemd-nspawn --bind /usr/bin/qemu-aarch64-static:/usr/bin/qemu-aarch64-static -D /rootfs
```

其中 --bind参数 就是绑定/映射的意思，前面是宿主机地址，后面是nspawn容器地址 

比如绑定当前目录到 容器里的 /build 目录: 
```bash
sudo systemd-nspawn -q --bind /usr/bin/qemu-aarch64-static:/usr/bin/qemu-aarch64-static --bind $(pwd):/build -D /rootfs
```
- 下面是进入容器后的操作

查看版本构建信息:

`cat /etc/product-info.build`

查看已经安装的deb包列表

`dpkg-query -W --showformat='${Package} ${Version}\n'`



当然也可以编译deb包，不过相比准备好的docker编译环境，需要手动装一些工具链
```bash
apt update #更新apt仓库索引，这步一定要做
apt -y install pbuilder git aptitude dpkg-dev \
     autoconf automake autopoint autotools-dev bsdmainutils cmake cmake-data debhelper dh-autoreconf \
     dh-strip-nondeterminism file gettext gettext-base groff-base intltool-debian m4 man-db po-debconf \
     procps build-essential fakeroot dh-make equivs devscripts quilt
```
个别软件包安装时需要`_apt`账户，警告信息：
```bash
No sandbox user '_apt' on the system, can not drop privileges
```
解决办法：
```bash
adduser --force-badname --system --no-create-home _apt
```

如果 只是想下载源码 而不编译 ，则 只需要 安装 `dpkg-dev`即可。

apt policy可以查看软件包的来源仓库优先级,数字越大，优先级越高。

```bash
apt policy wget
```

apt source下载代码 或者 用 git clone代码仓库

```bash
cd /build
apt source wget
cd wget-1.17.1
```
生成dsc
```bash
dpkg-source -b .
```

安装编译依赖, 依赖于debian/control文件的正确性
```bash
bash -x /usr/lib/pbuilder/pbuilder-satisfydepends
#或者用devscripts提供的脚本处理依赖(速度更快）
mk-build-deps -ir
```

如果想要编译**debug包**(dbgsym),可以先安装一个脚本deb包:
```bash
apt install -y pkg-create-dbgsym
```

编译deb包, 如果 deb项目是quilt格式,请参考 #54 

```
一般用法: dpkg-buildpackage -us -uc

CI的deb构建参数:
DEB_BUILD_OPTIONS=nocheck dpkg-buildpackage -rfakeroot -d -uc -us -F -J6
```

编译后的清理
```bash
dpkg-buildpackage -Tclean
```

- 更多语法参考: http://www.jinbuguo.com/systemd/systemd-nspawn.html


- 保存修改过的img文件

**因linux存在缓存机制,不会立即保存文件到磁盘,要么等,要么在需要立即写盘时输入: `sync`**

首先 `exit` 退出容器环境

```bash
#卸载挂载点
sync
sudo umount /rootfs
sync

#本地调试,倒是**不需要**压缩rootfs.img

#如果需要传递给他人,可以压缩rootfs.img
pigz --fast rootfs.img
sync
```

- resize rootfs.img size

```bash
e2fsck -f rootfs.img
resize2fs rootfs.img 10G
```



## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2023-02-07T11:38:48+08:00

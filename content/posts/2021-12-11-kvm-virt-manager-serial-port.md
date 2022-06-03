---
title: "Kvm Virt Manager Serial Port"
date: 2021-12-11T16:21:39+08:00
author: v2less
tags: ["linux"]
draft: false
---

## 修改kvm虚拟机中的cmdline

`console=ttyS0`

例如 Debian 系统，修改`/etc/default/grub`文件中的`GRUB_CMDLINE_LINUX_DEFAULT=" console=ttyS0"`

然后更新grub: `update-grub`

## livecd

新建一个虚拟机Guest，按向导选择iso，并命名一个GuestNAME，

虚拟机iso启动，编辑grub启动菜单，在`linux`最后追加选项`console=ttyS0`

先不要启动系统，等接下来设置好minicom后再启动。

## 获取主机映射的串口

GusestNAME: 虚拟机名字

```bash
#获取串口
$ virsh --connect qemu:///system dumpxml GuestNAME | grep -oP "(?<='pty' tty=').*(?='>)"

/dev/pts/15
```

## minicom连接串口

设置：

```bash
sudo minicom -s
#设置串口
- Serial port setup:
- - A Serial Device: /dev/pts/15
- - E Bps/Par/Bits : 115200 8N1
- - F Hardware Flow Control: Yes
- - press enter to comfirm.
- - Save settings：choose "Save setup as dfl"
```

连接:

```bash
sudo minicom -c on
```

**也可以直接连接：**

```bash
sudo minicom -c on -D /dev/pts/20 -b 115200
```



## 参考链接

- [Setting up a serial console in qemu and libvirt](https://rwmj.wordpress.com/2011/07/08/setting-up-a-serial-console-in-qemu-and-libvirt/)





## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2021-12-11T16:21:39+08:00

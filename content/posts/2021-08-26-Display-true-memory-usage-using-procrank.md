---
title: "Display True Memory Usage Using Procrank"
date: 2021-08-26T16:27:14+08:00
author: v2less
tags: ["linux"]
draft: false
---



## procrank

项目地址：https://github.com/csimmonds/procrank_linux

```bash
make
sudo ./procrank
PID       Vss      Rss      Pss      Uss  cmdline
 7857  1520040K  497760K  488438K  487436K  /usr/bin/qemu-system-x86_64
 2515   752720K  422976K  387668K  384532K  zathura
……………………………………………………………………………………………………………………………………………………………………………………………… 
                            ------   ------  ------
                          5838973K  5288868K  TOTAL

RAM: 16348936K total, 1551300K free, 1521220K buffers, 7195352K cached, 195612K shmem, 784504K slab

```

- **PID**- 进程标识号process identification，它在大多数操作系统内核（如 Linux、Unix、macOS 和 Windows）中使用。它是在操作系统中创建时自动分配给每个进程的唯一标识号。一个进程是一个正在运行的程序实例。
- **VSS** Virtual Set Size 虚拟耗用内存（包含共享库占用的内存） 
- **RSS** Resident Set Size 实际使用物理内存（包含共享库占用的内存） 
- **PSS** Proportional Set Size 实际使用的物理内存（比例分配共享库占用的内存） 
- **USS** Unique Set Size 进程独自占用的物理内存（不包含共享库占用的内存） 
- **cmdline** 命令行
- **buffers** 表示块设备(block device)所占用的缓存页，包括：直接读写块设备、以及文件系统元数据(metadata)比如SuperBlock所使用的缓存页。
- **cached** 表示普通文件数据所占用的缓存页。
- **shmem** 指的就是 tmpfs 所使用的内存 —— 一个基于内存的文件系统，提供可以接近零延迟的快速存储区域。
- **slab** slab allocation是一种用来对内核对象进行分配内存的管理机制，这种机制可以高效的找到那些因为频繁分配以及回收内存而造成的被忽略掉的内存碎片。


>
>
>top  | grep app名称
>ps  |  grep app名称
>procrank | grep app名称
>
>前两个命令只能查到VSS RSS内存占用信息
>
>而后面一个命令可以查出  PSS USS内存占用


## 参考

- [/proc/meminfo之谜](http://linuxperf.com/?p=142)

## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2021-08-26T16:27:14+08:00

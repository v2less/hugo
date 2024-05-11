---
title: "Tee Write Competition Problem Under Pipeline"
date: 2024-05-11T09:32:09Z
author: v2less
tags: ["linux"]
draft: false
---

```bash
 sort -u foo | tee foo
```
有时会覆盖原文件，有时则不会

这涉及到了 UNIX 系统对于文件描述符和数据流的处理方式。

在这个命令中：

`sort -u foo` 读取文件 foo 并输出唯一行。
`tee foo` 将其输入同时输出到标准输出和写回到文件 foo。

**为什么会有不确定的行为：**

当你使用 tee 写回到相同的文件时，tee 和 sort 的处理对文件的打开、读取、写入的时序会影响最终结果。这个命令有一个竞态条件的问题：

文件读写的时间差：sort 命令开始读取文件 foo 的内容，并进行排序。如果在 sort 读取完成之前 tee 就开始写入数据到 foo，tee 的写入操作可能会覆盖 sort 还未读取的数据，导致数据丢失。

缓存和写入的延迟：UNIX 系统通常会使用缓存来优化读写操作。sort 可能还在处理数据，而 tee 可能已经开始写入，这种不同的处理速度可能导致 foo 文件的内容在未完全排序前就被覆盖。

```bash
sort -u foo | sponge foo
```
这里使用了 sponge 命令，它属于 moreutils 包的一部分。sponge 会读取所有的标准输入直到 EOF，然后将数据写入到文件。这样可以避免在读取数据时同时写入同一个文件所引起的问题。

如果你的系统上还没有 sponge，你可以通过包管理器安装 moreutils：

对于 Ubuntu/Debian 系统：

```bash
sudo apt-get install moreutils
```




## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2024-05-11T09:32:09Z

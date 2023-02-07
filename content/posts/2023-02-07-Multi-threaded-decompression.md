---
title: "Multi Threaded Decompression"
date: 2023-02-07T12:02:45+08:00
author: v2less
tags: ["linux"]
draft: false
---

想要多线程解压，先多线程压缩

## tar with pigz

- 压缩
```bash
tar --use-compress-program=pigz -cvpf app.tar.gz app
```
- 解压
```bash
tar --use-compress-program=pigz -xvpf app.tar.gz
```

## tar with xz
- 压缩
```bash
tar --use-compress-program='xz -1T0' -cvpf app.tar.xz app
```
- 解压
```bash
tar --use-compress-program='xz -1T0' -xvpf app.tar.xz
```





## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2023-02-07T12:02:45+08:00

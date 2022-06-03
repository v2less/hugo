---
title: "Local chroot arm64 on amd64"
date: 2022-01-27T17:35:58+08:00
author: v2less
tags: ["linux"]
draft: false
---
```bash
sudo apt-get install -y qemu qemu-user-static binfmt-support systemd-container
sudo mount rootfs.img /mnt
sudo cp /usr/bin/qemu-aarch64-static /mnt/usr/bin/
sudo systemd-nspawn -D /mnt
```






## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2022-01-27T17:35:58+08:00

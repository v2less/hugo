---
title: "How to Run Arm64 Docker on X86"
date: 2022-04-29T10:41:24+08:00
author: v2less
tags: ["linux"]
draft: false
---
```bash
sudo apt update
sudo apt-get -y install qemu binfmt-support qemu-user-static # Install the qemu packages

docker run --rm --privileged multiarch/qemu-user-static --reset -p yes # This step will execute the registering scripts

docker run --rm -t arm64v8/ubuntu:16.04 uname -m # Testing the emulation environment
#aarch64
```

run it
```bash
sudo docker run -it -u root --net=host -v $(pwd):/root --workdir /root --privileged -t arm64v8/ubuntu:16.04

```







## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2022-04-29T10:41:24+08:00

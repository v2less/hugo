---
title: "Configure vim with python support"
date: 2021-08-14T21:35:59-10:00
author: v2less
tags: ["linux"]
draft: false
---

## 编译安装vim支持python3

```bash
#!/bin/bash
cd /tmp/ || exit 1
git clone https://github.com/vim/vim.git || exit 1

cd vim || exit 1
export LDFLAGS="-fno-lto"
./configure --with-features=huge \
            --enable-multibyte \
            --enable-rubyinterp=yes \
            --enable-python3interp=yes \
            --with-python3-config-dir=$(python3-config --configdir) \
            --enable-perlinterp=yes \
            --enable-luainterp=yes \
            --enable-gui=gtk2 \
            --enable-cscope \
            --prefix=/usr/local

make VIMRUNTIMEDIR=/usr/local/share/vim/vim82

sudo make install
```






## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2021-08-14T21:35:59-10:00



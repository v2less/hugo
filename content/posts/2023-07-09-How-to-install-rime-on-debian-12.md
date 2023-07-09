---
title: "How to Install Rime on Debian 12"
date: 2023-07-09T14:58:01+08:00
author: v2less
tags: ["linux"]
draft: false
---

## install fcitx-rime

<https://github.com/fcitx/fcitx-rime>

```bash
sudo apt-get install fcitx-rime
fcitx-autostart
```
## switch ibus to fcitx
```bash
im-config
```
## rime-setting

<https://github.com/Iorest/rime-setting>

- 安装Rime输入法,并注销或重启
- 下载仓库所有配置文件到本地
- 将下载的除字体外的所有文件覆盖到用户设定文件夹
- 安装字体 ( font 目录)
- 也可以在“用户文件夹”中查看
- 右键点击rime输入法图标，点击重新部署，部署完毕即可用
- 将词库文件拷贝到文件夹，修改 luna_pinyin.extended.dict.yaml文件
- 将词库名字加在 import_tables 下(注意格式)(我的另一个仓库rime-dict中收集了很多词库)
- 重新部署即可

```bash
git clone https://github.com/Iorest/rime-setting.git
mkdir ~/.config/fcitx/rime
cd rime-setting
cp -ra font/* ~/.local/share/fonts/
fc-cache -fv ~/.local/share/fonts/
rm -rf fonts
cp -av * ~/.config/fcitx/rime/
cd ..
git clone https://github.com/Iorest/rime-dict.git
cd rime-dict
cp -av * ~/.config/fcitx/rime/dicts/
cd ~/.config/fcitx/rime/
vi luna_pinyin.extended.dict.yaml
```




## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2023-07-09T14:58:01+08:00

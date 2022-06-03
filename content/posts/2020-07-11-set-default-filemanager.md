+++
title = "Set Default Filemanager and filedialog"  # 文章标题
date = 2020-07-11T12:08:08+08:00  # 自动添加日期信息
draft = false  # 设为false可被编译为HTML，true供本地修改
tags = ["linux"]  # 文章标签，可设置多个，用逗号隔开。Hugo会自动生成标签的子URL

+++

## 动态平铺窗口管理器 DWM

官网： https://dwm.suckless.org/

需要编译安装，编译失败会提示缺少包，依据提示安装相关lib**-dev开发包。如：`libx11-dev  libxft-dev  libxinerama-dev`

参考：http://www.danamlund.dk/dwm_setup.html 

## 安装图形切换软件

原来的桌面环境是DDE，切换到dwm后，使用pcmanfm。

```bash
sudo apt install exo-utils libexo-1-0
exo-preferred-applications
#选择默认应用
xdg-mime default pcmanfm.desktop inode/directory
vi .config/mimeapps.list
sudo vi /usr/share/applications/mimeapps.list
sudo vi /usr/share/applications/mimeinfo.cache
```
测试一下： `xdg-open ~`
## 解决恼人的filedialog还是调用dde-desktop
查看dbus服务：
```bash
dbus-send --print-reply --dest=org.freedesktop.DBus  /org/freedesktop/DBus org.freedesktop.DBus.ListNames
dbus-send --system --print-reply --dest=org.freedesktop.DBus  /org/freedesktop/DBus org.freedesktop.DBus.ListNames
```
看到有`filedialog`相关服务：
`/usr/share/dbus-1/services/com.deepin.filemanager.filedialog.service`

屏蔽掉执行命令：
```bash
[D-BUS Service]
Name=com.deepin.filemanager.filedialog
#Exec=/usr/bin/dde-desktop --file-dialog-only
```
OK。


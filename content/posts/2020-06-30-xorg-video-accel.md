+++
title = "Xorg配置：禁用休眠、视频加速等"  # 文章标题
date = 2020-06-30T20:24:19+08:00  # 自动添加日期信息
draft = false  # 设为false可被编译为HTML，true供本地修改
tags = ["linux"]  # 文章标签，可设置多个，用逗号隔开。Hugo会自动生成标签的子URL

+++

 `/etc/X11/xorg.conf.d/`目录下：
### 禁止休眠：
`10-monitor.conf`

```bash
Section "ServerFlags"
        Option "BlankTime" "0"
        Option "StandbyTime" "0"
        Option "SuspendTime" "0"
        Option "OffTime" "0"
EndSection

Section "Monitor"
       Option "DPMS" "false"
EndSection


Section "Monitor"
       Option "DPMS" "false"
EndSection

​```临时
禁止显示器休眠：
`xset -dpms`
### 显卡加速
Nvidia开源驱动：
10-nouveau.conf
​```bash
Section "OutputClass"
    Identifier "Nvidia"
    MatchDriver "nouveau"
    Driver "nouveau"
    Option "NoAccel" "on"
EndSection
```
### 禁止硬件加速（尽量不可取）

AMD显卡驱动：
`10-radeon.conf`

```bash
Section "OutputClass"
    Identifier "Radeon"
    MatchDriver "radeon"
    Driver "radeon"
    Option "Accel" "off"
EndSection
```
Intel显卡驱动：
`20-intel.conf`

```bash
Section "Device"
   Identifier "Intel Graphics"
   Driver "intel"
   Option "NoAccel" "off"
EndSection
```

## kwin配置

调整开启动画，解决拖影问题，同时开启上面的视频加速

```bash
 [Compositing]
#窗口最小化后也保持map状态
HiddenPreviews=6
#动画速度调整为快
AnimationSpeed=2
Enabled=true
AllowSwitch=false
```

### Openbox 拖影

由于openbox、i3等窗口管理器本身没有窗口混合功能，在开启视频加速时，会出现拖影现象。

安装一个独立的窗口混合器,并加入开机启动即可。

> Compton 是一个独立的合成管理器，可以给不带合成功能的窗口管理器（例如 i3）带来淡入淡出、半透明、阴影等视觉效果。

```bash
sudo apt install compton
sudo cp /usr/share/applications/compton.desktop /etc/xdg/autostart/
```


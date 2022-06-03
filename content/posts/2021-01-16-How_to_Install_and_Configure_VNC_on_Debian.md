+++
title = "How to Install and Configure VNC on Debian"  # 文章标题
date = 2021-01-16T15:21:30+08:00  # 自动添加日期信息
draft = false  # 设为false可被编译为HTML，true供本地修改
tags = ["Linux","VNC"]  # 文章标签，可设置多个，用逗号隔开。Hugo会自动生成标签的子URL
+++
## 介绍

VNC (Virtual Network Computer)是 虚拟网络 计算机的缩写。VNC 是一款优秀的 远程控制工具软件，由著名的 AT&T 的欧洲研究实验室开发的。VNC 是在基于 UNIX 和 Linux 操作系统的免费的 开源软件， 远程控制能力强大，高效实用，其性能可以和 Windows 和 MAC 中的任何远程控制软件媲美。 在 Linux 中，VNC 包括以下四个命令：vncserver，vncviewer，vncpasswd，和 vncconnect。大多数情况下用户只需要其中的两个命令：vncserver 和 vncviewer。 

**命令描述**
- vncserver
此服务程序必须在在主（或遥控） 计算机上运行。你只能作为使用者（不需要根用户身份）使用此项服务。
- vncviewer
本地应用程序，用于远程接入运行 vncserver的 计算机并显示其环境。你需要知道远程 计算机的IP地址和 vncserver设定的密码。
- vncpasswd
vncserver的密码设置工具。 vncserver服务程序没有设置密码将不能运行（好习惯）。如果你没有设置，运行 vncserver时它会提示你输入一个密码。所以，一般我不会单独运行这个命令来设置密码。
- vncconnect
告诉 vncserver连接到远程一个运行vncviewer的 计算机的IP和端口号。这样我就可以避免给其他人一个接入的密码。 

**VNC工作流程**
（1） 在服务器端启动 VNC Server。
（2） VNC客户端通过浏览器或 VNC Viewer 连接至VNC Server。
（3） VNC Server传送一对话窗口至客户端，要求输入连接密码， 以及存取的VNC Server显示装置。
（4） 在客户端输入联机密码后，VNC Server验证客户端是否具有存取权限。
（5） 若是客户端通过 VNC Server 的验证，客户端即要求VNC Server显示桌面环境。
（6） VNC Server通过X Protocol 要求X Server将画面显示控制权交由VNC Server负责。
（7） VNC Server将来由 X Server 的桌面环境利用VNC通信协议送至客户端， 并且允许客户端控制VNC Server的桌面环境及输入装置。 

本文将使用[TightVNC](https://www.tightvnc.com/)在Debian系上创建VNCServer以及如何使用VNCViewer通过SSH隧道连接VNCServer。


## 安装桌面环境和VNCServer


Xfce 是一个基于 GTK+2 的轻量级模块化的 桌面环境。如果需要的话，还可以安装 xfce4-goodies 包组。此包组提供了一些额外的插件和一些有用的工具，如 mousepad 编辑器。 

```bash
sudo apt install xfce4 xfce4-goodies
```
安装  TightVNC server:

```bash
sudo apt install tightvncserver
```

 

运行 `vncserver` 命令，并设置VNC访问密码,创建一个配置文件，并启动一个服务实例。

```bash
vncserver
```

```
OutputYou will require a password to access your desktops.

Password:
Verify:
```
密码强度6-8位，超过8位会被自动截断。
设置访问密码后，会询问只读密码，可以选择否。

**重要的是**，默认服务端口 `5901`，对应的显示端口为 `:1`；`:2` 对应`5902`, `:3` 对应 `5903`, 以此类推。

```
OutputWould you like to enter a view-only password (y/n)? n
xauth:  file /home/sandy/.Xauthority does not exist

New 'X' desktop is your_hostname:1

Creating default startup script /home/sandy/.vnc/xstartup
Starting applications specified in /home/sandy/.vnc/xstartup
Log file is /home/sandy/.vnc/your_hostname:1.log
```

你也可以再次运行 `vncpasswd` 修改密码。

```bash
vncpasswd
```



## 配置 VNC Server

配置VNC Server前，先停止运行在默认端口`5901`的实例：

```bash
vncserver -kill :1
```

```
OutputKilling Xtightvnc process ID 17648
```

修改配置 `xstartup`文件前，先备份一下：
```bash
mv ~/.vnc/xstartup ~/.vnc/xstartup.bak
```

 

现在创建新的配置文件：

```bash
vim ~/.vnc/xstartup
```

写入以下内容到配置文件:~/.vnc/xstartup

```bash
#!/bin/bash
xrdb $HOME/.Xresources
startxfce4 &
```

第一行是 [*shebang*](https://en.wikipedia.org/wiki/Shebang_(Unix)).在*nix系统， shebang告诉系统使用什么解释器来执行此文件。

第一条命令： `xrdb $HOME/.Xresources`,加载个性化的桌面环境,比如终端颜色、主题、字体等。

第二条命令：启动 Xfce桌面环境。


保存退出后，给予执行权限：

```bash
chmod +x ~/.vnc/xstartup
```

再次启动 VNC server:

```bash
vncserver -localhost ：99
```

注意，这次命令包含了-localhost选项，它将VNC服务器绑定到服务器的loopback接口。这将导致VNC只允许来自它所安装的服务器的连接。

参数`:99`将使用`5999`的服务端口，显示端口对应为`99`。

**如果服务器安装了虚拟机，大概率默认端口5901是被占用的了，此时建议使用大一点的端口号，比如50～99.**



输出大概是这样：

```
OutputNew 'X' desktop is your_hostname:99

Starting applications specified in /home/sandy/.vnc/xstartup
Log file is /home/sandy/.vnc/your_hostname:99.log
```


## 通过SSH隧道连接VNC

vnc默认监听5901端口，连接时不加密，所以认为是一个不安全的连接。
ssh连接是相对安全的，vnc可以设置监听地址为本地，通过ssh隧道去连接vnc可以认为是较安全可靠的。

创建一个本地端口转发（隧道）：
```bash
ssh -L 6901:localhost:5901 -C -N -l sandy your_server_ip
```
这个命令建立一个SSH隧道，通过端口22 (SSH的默认端口)将信息从VNC服务器上的5901端口转发到本地机器上的6901端口。

这里的localhost指的是your_server_ip，因为目标主机是相对your_server_ip而言的，也可以替换为127.0.0.1。

其他参数的含义：

- `-L 一共接受三个值，分别是"本地端口:目标主机:目标主机端口"，它们之间用冒号分隔。
- `-C`: 启用压缩。
- `-N`:不执行远程命令。
- `-l sandy your_server_ip`: `-l`后面直接跟的是远程Server主机的登录用户名。

至于ssh的访问许可，需要输入口令，或者提前使用`ssh-copy-id`建立可信通道。

也可以借助`sshpass`在命令中传入密码：
```bash
sshpass -p vncserver_host_user_passwd ssh -L 6901:localhost:5901 -C -N -l sandy your_server_ip
```



**VNC客户端**

使用VNC 客户端连接 localhost:6901，可能需要你输入前面设置的VNCServer访问密码。

这里我们使用`xtightvncviewer`

```bash
sudo apt install -y sshpass tigervnc-common xtightvncviewer
```

可以指定密码文件：

```bash
xtightvncviewer -passwd ~/your_server_ip.pass localhost:6901
```


## 创建VNCServer系统服务

创建一个服务文件： `/etc/systemd/system/vncserver@.service`:

```bash
sudo vim /etc/systemd/system/vncserver@.service
```
名字后面的@符号可以让我们传入一个参数，使用它来指定管理服务时希望使用的VNC显示端口。

```bash
[Unit]
Description=Start TightVNC server at startup
After=syslog.target network.target

[Service]
Type=forking
User=sandy
Group=sandy
WorkingDirectory=/home/sandy

PIDFile=/home/sandy/.vnc/%H:%i.pid
ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/vncserver -depth 24 -geometry 1920x1080 -localhost :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
```

让systemd unit重新加载：

```bash
sudo systemctl daemon-reload
```

加入自启服务：

```bash
sudo systemctl enable vncserver@99.service
```
如果实例在运行，停止它：

```bash
vncserver -kill :99
```

启动服务：

```bash
sudo systemctl start vncserver@99
```

查看服务状态：

```bash
sudo systemctl status vncserver@1
```


启动正常，输出大概为：

```
Output● vncserver@1.service - Start TightVNC server at startup
     Loaded: loaded (/etc/systemd/system/vncserver@.service; enabled; vendor preset: enabled)
     Active: active (running) since Thu 2020-05-07 17:23:50 UTC; 6s ago
    Process: 39768 ExecStartPre=/usr/bin/vncserver -kill :1 > /dev/null 2>&1 (code=exited, status=2)
    Process: 39772 ExecStart=/usr/bin/vncserver -depth 24 -geometry 1280x800 :1 (code=exited, status=0/SUCCESS)
   Main PID: 39795 (Xtightvnc)
```



## VNCServer脚本



项目地址： https://github.com/waytoarcher/shellcripts/tree/main/vnc

用法：

- `bash vncserver.sh -h` 	查看帮助
- `bash vncserver.sh 88` 传入显示端口`88`

## Reference:

- [How to Install and Configure VNC on Debian](https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-vnc-on-Debian-20-04)
- [SSH原理与运用（二）：远程操作与端口转发](https://www.ruanyifeng.com/blog/2011/12/ssh_port_forwarding.html)

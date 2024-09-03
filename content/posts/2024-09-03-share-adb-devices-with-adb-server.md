---
title: "Share Adb Devices With Adb Server"
date: 2024-09-03T11:31:31+08:00
author: v2less
tags: ["android"]
draft: false
---
## Remote ADB server

To connect to a remote adb server, make the server listen on all interfaces:


```bash
adb kill-server

adb -a nodaemon server start

# keep this open
```
Warning: all communications between clients and the adb server are unencrypted.

## Run adb shell from another terminal

Suppose that this server is accessible at 192.168.1.2. Then, from another terminal, run adb shell:


- in bash
```bash
export ADB_SERVER_SOCKET=tcp:192.168.1.2:5037
```

- in cmd
```cmd
set ADB_SERVER_SOCKET=tcp:192.168.1.2:5037
```

- in PowerShell
```powsershell
$env:ADB_SERVER_SOCKET = 'tcp:192.168.1.2:5037'
```




## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2024-09-03T11:31:31+08:00

---
title: "Redir for Linux Port Forward"
date: 2022-01-20T19:49:14+08:00
author: v2less
tags: ["linux"]
draft: false
---

```bash
sudo apt-get install redir -y

sudo redir :中转服务器端口 需转发ip或者域名:端口
sudo redir :1022 192.168.122.66:22

ssh root@127.0.0.1 -p 1022

```





## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2022-01-20T19:49:14+08:00

---
title: "Aliyun Webdav"
date: 2021-12-14T21:12:58+08:00
author: v2less
tags: ["linux"]
draft: false
---

## 获取refresh-token

浏览器F12 --> Application --> Storage --> Local Storage --> token --> refresh-token

## 安装webdav服务软件

```bash
pip install aliyundrive-webdav devfs2 apache2-utils
```
## 运行webdav服务

```bash
 aliyundrive-webdav [FLAGS] [OPTIONS] --refresh-token <refresh-token>
```
## 挂载webdav服务

```bash
sudo mkdir -p /mnt/aliyun
sudo mount -t davfs -o noexec http://0.0.0.0:8080 /mnt/aliyun
```


## nginx 配置

```bash
sudo ln -sf /mnt/aliyun /usr/share/nginx/html/aliyun
sudo htpasswd -c /etc/.htpasswd user
sudo vi /etc/nginx/site-availble/default

#增加
location /aliyun {
        autoindex on;
        charset utf-8;
        auth_basic           "Administrator’s Area";
        auth_basic_user_file /etc/.htpasswd;
}



sudo systemctl restart nginx
```




## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2021-12-14T21:12:58+08:00

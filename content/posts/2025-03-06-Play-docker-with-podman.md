---
title: "Play Docker With Podman"
date: 2025-03-06T17:53:28+08:00
author: v2less
tags: ["docker"]
draft: false
---

## Install and Setup
### OS
Debian/Ubuntu
### Install
```bash
sudo apt update
sudo apt install podman podman-compose buildah skopeo
```
### Config podman
- /etc/containers/registries.conf
```conf
unqualified-search-registries = ["docker.io"]

[[registry]]
location = "docker.io/library"
[[registry.mirror]]
location = "docker.1panel.live/library"
[[registry.mirror]]
location = "docker.m.daocloud.io/library"

[[registry]]
location = "10.8.250.192:5000"
insecure = true

[[registry]]
location = "10.8.250.192:5001"
insecure = true
```

### Show info
```bash
podman info | less
```
### Podman pull image
```bash
podman --log-level=debug pull debian:12
```

## manage container

### search
```bash
podman search nginx
```
### pull
```bash
podman pull nginx
```
### show images
```bash
podman images
```
### check image
```bash
podman inspect nginx
```
### check remote image
```bash
skopeo inspect docker://docker.io/mariadb
```
### delete image
```bash
podman rmi nginx
```
### run container
```bash
podman run --name weubuntu -it ubuntu
```
### run container backend
```bash
podman run --name nginx -d \
-v $(pwd):/usr/share/nginx/html -p 8080:80 nginx:alpine
```
### show container
```bash
podman ps -a
```
### show log of contaner
```bash
podman logs nginx
```
### stop container
```bash
podman stop nginx
```
### rm container
```bash
podman rm nginx
```







## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2025-03-06T17:53:28+08:00

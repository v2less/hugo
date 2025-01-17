---
title: "Setup Wordpress With Docker"
date: 2025-01-17T11:17:43+08:00
author: v2less
tags: ["wordpress"]
draft: false
---

## docker-compose.yml
```yaml
version: '3.0'

services:
  db:
    image: mysql:8.0 # 使用mysql镜像，不建议修改版本号，后续如果要升级，千万记得备份数据库
    container_name: wordpress-db
    restart: unless-stopped
    command: --max-binlog-size=200M --expire-logs-days=2
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword # 这里是上面的root密码
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: rootpassword # 这里是原来的密码
    volumes:
      - './db:/var/lib/mysql'
    networks:
      - default

  app:
    image: wordpress:latest
    container_name: wordpress-app
    restart: unless-stopped
    ports:
      - 8080:80  # 按需修改,左边的8080可以改成服务器上没有用过的端口
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: rootpassword
    volumes:
      - './app:/var/www/html'
    links:
      - db:db
    depends_on:
      - redis
      - db
    networks:
      - default

  redis:
    image: redis:alpine
    container_name: wordpress-redis
    restart: unless-stopped
    volumes:
      - ./redis-data:/data
    networks:
      - default

networks:
  default:
    name: wordpress
```
## 启动一次
```bash
docker compose pull
docker compose up -d
```
## 启用redis
```bash
docker compose down
docker compose up -d
```
第二次启动后，应该可以看见安装向导。

wp-admin/plugins.php

然后安装插件：Redis Object Cache

修改配置：
```bash
docker compose down
vi app/wp-config.php
在
define( 'DB_COLLATE', getenv_docker('WORDPRESS_DB_COLLATE', '') );
后面插入：

/** Redis Object Cache */
define('WP_REDIS_HOST', 'wordpress-redis');
define('WP_REDIS_DATABASE', '0');
```

```bash
docker compose up -d
```
## 绑定域名
如果要使用api发布文章，需要https协议，故需要一个域名
首先解析域名到wordpress地址；然后：
wp-admin/options-general.php
修改：WordPress 地址（URL）	 站点地址（URL）	

## 主题推荐
OceanWP
可以自定义，关闭主页文章内容的显示，只保留标题。






## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2025-01-17T11:17:43+08:00

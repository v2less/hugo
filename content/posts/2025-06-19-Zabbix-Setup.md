---
title: "Zabbix Setup"
date: 2025-06-19T15:03:02+08:00
author: v2less
tags: ["linux"]
draft: false
---

## zabbix7.0 服务端安装及配置
### install zabbix7.0
```bash
wget https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.0+debian12_all.deb
sudo dpkg -i zabbix-release_latest_7.0+debian12_all.deb
sudo apt update
# 安装Zabbix server，Web前端，agent
sduo apt install zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-sql-scripts zabbix-agent2
```
### install mysql8.0
```bash
wget https://repo.mysql.com/mysql-apt-config_0.8.34-1_all.deb
sudo dpkg -i mysql-apt-config_0.8.34-1_all.deb
sudo apt update
sudo apt purge mariadb-client-core
sudo apt install mysql-server
```
### 安全加固MySQL
修改root密码
```bash
sudo mysql -u root
ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY '你的新密码';
FLUSH PRIVILEGES;

#删除匿名用户
DELETE FROM mysql.user WHERE user = '';
#禁止root远程登录
UPDATE mysql.user SET host='localhost' WHERE user='root';
#删除测试数据库
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

FLUSH PRIVILEGES;
```
### 创建初始数据库
```bash
# mysql -uroot -p
password
mysql> create database zabbix character set utf8mb4 collate utf8mb4_bin;
mysql> create user zabbix@localhost identified by 'password';
mysql> grant all privileges on zabbix.* to zabbix@localhost;
mysql> set global log_bin_trust_function_creators = 1;
mysql> FLUSH PRIVILEGES;
mysql> quit;
```
### 导入初始架构和数据，系统将提示您输入新创建的密码。
```bash
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix
```
Disable log_bin_trust_function_creators option after importing database schema.
```bash
# mysql -uroot -p
password
mysql> set global log_bin_trust_function_creators = 0;
mysql> quit;
```
### 为Zabbix server配置数据库
编辑配置文件 /etc/zabbix/zabbix_server.conf
```conf
DBPassword=password
```
### 为Zabbix前端配置PHP
编辑配置文件 /etc/zabbix/nginx.conf uncomment and set 'listen' and 'server_name' directives.
```bash
# listen 8080;
# server_name example.com;
```
### 启动Zabbix server和agent进程
```bash
sudo systemctl restart zabbix-server zabbix-agent2 nginx php8.2-fpm
sudo systemctl enable zabbix-server zabbix-agent2 nginx php8.2-fpm
```
### 中文支持
```bash
sudo apt install locales -y
sudo dpkg-reconfigure locales
#前端乱码，安装字体
sudo apt install fonts-noto-cjk
sudo cp /usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc /usr/share/zabbix/assets/fonts/graphfont.ttf
```
### 打开web端配置向导
http://10.8.253.48:8080/

## 客户端安装及配置
```bash
export DEBIAN_FRONTEND=noninteractive
distro=$(lsb_release -s -i|tail -n1|tr [A-Z] [a-z])
osversion=$(lsb_release -s -r|tail -n1)
wget https://repo.zabbix.com/zabbix/7.0/${distro}/pool/main/z/zabbix-release/zabbix-release_latest_7.0+${distro}${osversion}_all.deb
sudo dpkg -i zabbix-release_latest_7.0+${distro}${osversion}_all.deb
sudo apt update
sudo apt install zabbix-agent2
if ! grep -q "^Plugins.Systemd.Enable=true" /etc/zabbix/zabbix_agent2.conf; then
    sudo sed -i '/# Plugins.Log.MaxLinesPerSecond=20/a Plugins.Systemd.Enable=true' /etc/zabbix/zabbix_agent2.conf
fi
sudo sed -i "s/Server=.*/Server=10.8.253.48/g" /etc/zabbix/zabbix_agent2.conf
sudo sed -i "s/ServerActive=.*/ServerActive=10.8.253.48/g" /etc/zabbix/zabbix_agent2.conf
sudo sed -i "s/Hostname=.*/Hostname=$(hostname -I | awk '{print $1}')/g" /etc/zabbix/zabbix_agent2.conf
sudo systemctl enable zabbix-agent2 --now
sudo systemctl restart zabbix-agent2 
```
## zfs监控模板和配置文件

- TrueNAS因禁止了apt，无法使用apt安装。可选择下载二进制agent压缩包
```bash
wget https://cdn.zabbix.com/zabbix/binaries/stable/7.0/7.0.10/zabbix_agent-7.0.10-linux-3.0-amd64-static.tar.gz
```

- zfs配置项目

https://github.com/bartmichu/zfs-zabbix-userparams








## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2025-06-19T15:03:02+08:00

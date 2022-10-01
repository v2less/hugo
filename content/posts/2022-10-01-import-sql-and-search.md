---
title: "Import Sql and Search"
date: 2022-10-01T23:42:57+08:00
author: v2less
tags: ["linux"]
draft: false
---
## install mariadb-server

```bash
sudo apt install -y mariadb-server
sudo systemctl start mariadb
```
## 设置数据库
- 设置密码
```bash
sudo mysqladmin -uroot password 'test'
```
- 登陆数据库
```bash
sudo mysql -uroot -p
```
- 显示数据库
```bash
SHOW DATABASES
```
- 创建数据库
```bash
CREATE DATABASE mydb
```
## 导入数据库并查询

- 导入数据库
```bash
sudo mysql -uroot -p mydb < mysql.sql
```
- 查看数据库的表信息
```bash
sudo mysql -uroot -p -e "SHOW TABLES FROM mydb"
```
- 查看数据库表的标题信息
```bash
sudo mysql -uroot -p -e "SHOW INDEX FROM zlib.books"
```
- 搜索查询数据库字段信息
```bash
sudo mysql -uroot -p -e "select zlibrary_id, date_modified,title,extension from zlib.books  where title like '%linux%';" | sed 's/\t/,/g'
```

## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2022-10-01T23:42:57+08:00

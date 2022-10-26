---
title: "Nginx Tips"
date: 2022-10-26T09:51:47+08:00
author: v2less
tags: ["linux"]
draft: false
---

## WebDAV模块配置

可以使用curl命令行上传文件到nginx服务器

- 设置登录账号及密码
```bash
echo "admin:$(openssl passwd 123456)" >/etc/nginx/conf/.davpasswd
```
-  Nginx 配置
```yaml
        dav_methods PUT DELETE MKCOL COPY MOVE;      # DAV支持的请求方法
        dav_ext_methods PROPFIND OPTIONS LOCK UNLOCK;# DAV扩展支持的请求方法
        dav_ext_lock zone=davlock;                   # DAV扩展锁绑定的内存区域
        create_full_put_path  on;                    # 启用创建目录支持
        dav_access user:rw group:r all:r;            # 设置创建的文件及目录的访问权限

        auth_basic "Authorized Users WebDAV";
        auth_basic_user_file /etc/nginx/conf/.davpasswd;
```
参考: https://www.weixueyuan.net/a/738.html

- curl上传
```bash
curl -u username:password -T testfile http://x.x.x.x/test/
```







## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2022-10-26T09:51:47+08:00

---
title: "Nginx Tips"
date: 2022-12-13T22:28:27+08:00
author: v2less
tags: ["linux"]
draft: false
---

## nginx反代一个http的内部服务
/etc/nginx/sites-enabled/navi.domain.com
```ini
upstream heimdall {
    server 127.0.0.1:8090;
    keepalive 128;
}

server {
    listen 443 ssl http2;
    server_name navi.domain.com;
    ssl_certificate /data/navi.domain.com.crt;
    ssl_certificate_key /data/navi.domain.com.key;
    ssl_trusted_certificate /data/navi.domain.com.crt;
    include /etc/nginx/ssl_params;

    access_log /var/log/nginx/navi.domain.com_access.log;
    location / {
        proxy_pass http://heimdall;
        proxy_http_version 1.1;
        proxy_redirect off;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port $server_port;
        proxy_set_header X-Nginx-Proxy true;
    }
}
```
## nginx反代一个https网站

/etc/nginx/sites-enabled/test.domain.com
```ini
server {
    listen 443 ssl http2;
    server_name test.domain.com;
    ssl_certificate /data/test.domain.com.crt;
    ssl_certificate_key /data/test.domain.com.key;
    ssl_trusted_certificate /data/test.domain.com.crt;
    add_header Strict-Transport-Security "max-age=31536000";
    include /etc/nginx/ssl_params;

    access_log /var/log/nginx/test.domain.com_access.log;
    if ( $scheme = http ){
        return 301 https://$server_name$request_uri;
    }
    if ($http_user_agent ~* (baiduspider|360spider|haosouspider|googlebot|soso|bing|sogou|yahoo|sohu-search|yodao|YoudaoBot|robozilla|msnbot|MJ12bot|NHN|Twiceler)) {
        return  403;
    }
    location / {
        sub_filter upstream.com test.domain.com;
        sub_filter_once off;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Referer https://upstream.com;
        proxy_set_header Host upstream.com;
        proxy_pass https://upstream.com;
        proxy_set_header Accept-Encoding "";
    }
}
```







## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2022-12-13T22:28:27+08:00

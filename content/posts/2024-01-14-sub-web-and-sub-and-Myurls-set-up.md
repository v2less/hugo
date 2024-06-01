---
title: "Sub-Web and Sub and Myurls Set Up"
date: 2024-01-14T21:48:38+08:00
author: v2less
tags: ["linux"]
draft: false
---
## 准备一个域名
https://www.namesilo.com/login.php
## 做几个二级域名，A记录到你的服务器
https://dash.cloudflare.com/login
## 安装好nginx 和 docker
```bash
apt install nginx
curl -fsSL https://get.docker.com | bash -s docker
```
## 二级域名证书
- 安装acme.sh
```bash
curl https://get.acme.sh | sh
```
- recert.sh

```bash
#!/bin/bash
mkdir -p /data
email_addr="waytoarcher@gmail.com"
domain_name=${1:-abc.abc.com}
/root/.acme.sh/acme.sh --register-account -m "${email_addr}"
/root/.acme.sh/acme.sh --issue -d "${domain_name}" --standalone -k ec-256 --force
sleep 2
/root/.acme.sh/acme.sh --installcert -d "${domain_name}" --fullchainpath /data/"${domain_name}".crt --keypath /data/"${domain_name}".key --ecc --force
```

- 更新证书前，需要停掉nginx服务
```bash
systemctl stop nginx
bash recert.sh sub.abc.com
bash recert.sh subweb.abc.com
bash recert.sh i.abc.com
```
## sub后端
- 下载git仓
```bash
cd root
wget https://github.com/tindy2013/subconverter/releases/download/v0.8.1/subconverter_linux64.tar.gz
tar -xvf subconverter_linux64.tar.gz
cd subconverter
cp pref.example.ini pref.ini
```
- 修改pref.ini
```ini
managed_config_prefix=https://sub.abc.com:25500
listen=127.0.0.1
```
- 创建sub服务
```bash
cat <<EOF | tee /etc/systemd/system/sub.service
[Unit]
Description=A API For Subscription Convert
After=network.target

[Service]
Type=simple
ExecStart=/root/subconverter/subconverter
WorkingDirectory=/root/subconverter
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable sub.service --now
```
## sub-web
```bash
cd /root
mkdir subweb
git clone https://github.com/CareyWang/sub-web
cd sub-web
```
- 修改 `.env`
```ini
# API 后端
VUE_APP_SUBCONVERTER_DEFAULT_BACKEND = "https://sub.abc.com"

# 短链接后端,要带short
VUE_APP_MYURLS_API = "https://i.abc.com/short"

# 文本托管后端
# VUE_APP_CONFIG_UPLOAD_API = "https://oss.wcc.best/upload"

```
- 修改src/views/Subconverter.vue
```vue
backendOptions: [{ value: "https://sub.abc.com/sub?" }],
#remoteConfig字段下增加一些配置：
          {
            label: "ACL4SSR",
            options: [
              {
                label: "ACL4SSR_Online 默认版 分组比较全 (与 Github 同步)",
                value:
                  "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/config/ACL4SSR_Online.ini"
              },
              {
                label: "ACL4SSR_Online_AdblockPlus 更多去广告 (与 Github 同步)",
                value:
                  "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/config/ACL4SSR_Online_AdblockPlus.ini"
              },
              {
                label: "ACL4SSR_Online_NoAuto 无自动测速 (与 Github 同步)",
                value:
                  "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/config/ACL4SSR_Online_NoAuto.ini"
              },
              {
                label: "ACL4SSR_Online_NoReject 无广告拦截规则 (与 Github 同步)",
                value:
                  "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/config/ACL4SSR_Online_NoReject.ini"
              },
              {
                label: "ACL4SSR_Online_Mini 精简版 (与 Github 同步)",
                value:
                  "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/config/ACL4SSR_Online_Mini.ini"
              },
              {
                label: "ACL4SSR_Online_Mini_AdblockPlus.ini 精简版 更多去广告 (与 Github 同步)",
                value:
                  "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/config/ACL4SSR_Online_Mini_AdblockPlus.ini"
              },
              {
                label: "ACL4SSR_Online_Mini_NoAuto.ini 精简版 不带自动测速 (与 Github 同步)",
                value:
                  "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/config/ACL4SSR_Online_Mini_NoAuto.ini"
              },
              {
                label: "ACL4SSR_Online_Mini_Fallback.ini 精简版 带故障转移 (与 Github 同步)",
                value:
                  "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/config/ACL4SSR_Online_Mini_Fallback.ini"
              },
              {
                label: "ACL4SSR_Online_Mini_MultiMode.ini 精简版 自动测速、故障转移、负载均衡 (与 Github 同步)",
                value:
                  "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/config/ACL4SSR_Online_Mini_MultiMode.ini"
              },
              {
                label: "ACL4SSR_Online_Full 全分组 重度用户使用 (与 Github 同步)",
                value:
                  "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/config/ACL4SSR_Online_Full.ini"
              },
              {
                label: "ACL4SSR_Online_Full_NoAuto.ini 全分组 无自动测速 重度用户使用 (与 Github 同步)",
                value:
                  "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/config/ACL4SSR_Online_Full_NoAuto.ini"
              },
              {
                label: "ACL4SSR_Online_Full_AdblockPlus 全分组 重度用户使用 更多去广告 (与 Github 同步)",
                value:
                  "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/config/ACL4SSR_Online_Full_AdblockPlus.ini"
              },
              {
                label: "ACL4SSR_Online_Full_Netflix 全分组 重度用户使用 奈飞全量 (与 Github 同步)",
                value:
                  "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/config/ACL4SSR_Online_Full_Netflix.ini"
              },
              {
                label: "ACL4SSR 本地 默认版 分组比较全",
                value: "config/ACL4SSR.ini"
              },
              {
                label: "ACL4SSR_Mini 本地 精简版",
                value: "config/ACL4SSR_Mini.ini"
              },
              {
                label: "ACL4SSR_Mini_NoAuto.ini 本地 精简版+无自动测速",
                value: "config/ACL4SSR_Mini_NoAuto.ini"
              },
              {
                label: "ACL4SSR_Mini_Fallback.ini 本地 精简版+fallback",
                value: "config/ACL4SSR_Mini_Fallback.ini"
              },
              {
                label: "ACL4SSR_BackCN 本地 回国",
                value: "config/ACL4SSR_BackCN.ini"
              },
              {
                label: "ACL4SSR_NoApple 本地 无苹果分流",
                value: "config/ACL4SSR_NoApple.ini"
              },
              {
                label: "ACL4SSR_NoAuto 本地 无自动测速 ",
                value: "config/ACL4SSR_NoAuto.ini"
              },
              {
                label: "ACL4SSR_NoAuto_NoApple 本地 无自动测速&无苹果分流",
                value: "config/ACL4SSR_NoAuto_NoApple.ini"
              },
              {
                label: "ACL4SSR_NoMicrosoft 本地 无微软分流",
                value: "config/ACL4SSR_NoMicrosoft.ini"
              },
              {
                label: "ACL4SSR_WithGFW 本地 GFW 列表",
                value: "config/ACL4SSR_WithGFW.ini"
              }
            ]
          }
```
构建sub-web的docker镜像
```bash
docker build -t subweb-local:latest .
```
创建sub-web的docker-compose.yml
```yaml
version: '3.8'
services:
  sub-web:
    image: 'subweb-local:latest'
    container_name: subweb
    restart: unless-stopped
    ports:
      - '58080:80'
```
启动：
```bash
docker compose up -d
```
## Myurls
短链接服务
```bash
cd /root
git clone https://github.com/CareyWang/MyUrls.git
cd Myurls
```
修改.env
```ini
MYURLS_PORT=8002
MYURLS_DOMAIN=i.abc.com
MYURLS_TTL=180
```
启动：
```bash
docker compose up -d
```
## Nginx相关配置文件
```bash
cd /etc/nginx/sites-enabled
ls
i.abc.com  sub.abc.com  subweb.abc.com
```
- i.abc.com
```yml
upstream i_backend {
    server 127.0.0.1:8002;

    keepalive 128;
}

server {
    listen 80;
    server_name i.abc.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name i.abc.com;

    ssl_certificate /data/i.abc.com.crt;
    ssl_certificate_key /data/i.abc.com.key;
    ssl_trusted_certificate /data/i.abc.com.crt;
    include /etc/nginx/ssl_params;

    access_log /var/log/nginx/i.abc.com_access.log;
    error_log /var/log/nginx/i.abc.com_error.log warn;

    location / {
        proxy_pass http://i_backend;
        proxy_http_version 1.1;
        proxy_redirect off;

        #跨域
        add_header 'Access-Control-Allow-Origin' $http_origin always;
        add_header 'Access-Control-Allow-Headers' $http_access_control_request_headers always;
        add_header 'Access-Control-Allow-Credentials' 'true' always;
        add_header 'Access-Control-Max-Age' 86400 always;
        add_header 'Access-Control-Allow-Methods' 'PUT,GET,POST,DELETE,HEAD' always;
        if ($request_method = 'OPTIONS') {
           return 204;
        }
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port $server_port;
        proxy_set_header X-Nginx-Proxy true;

        # For WebSocket
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
    }
    #解决获取短链接404问题
    location ~ ^/short  {
        proxy_pass http://i_backend;
        #跨域
        add_header 'Access-Control-Allow-Origin' $http_origin always;
        add_header 'Access-Control-Allow-Headers' $http_access_control_request_headers always;
        add_header 'Access-Control-Allow-Credentials' 'true' always;
        add_header 'Access-Control-Max-Age' 86400 always;
        add_header 'Access-Control-Allow-Methods' 'PUT,GET,POST,DELETE,HEAD' always;
         if ($request_method = 'OPTIONS') {
            return 204;
           }
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header REMOTE-HOST $remote_addr;

    }

}
```
- sub.abc.com
```yml
upstream sub_backend {
    server 127.0.0.1:25500;

    keepalive 128;
}

server {
    listen 80;
    server_name sub.abc.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name sub.abc.com;

    ssl_certificate /data/sub.abc.com.crt;
    ssl_certificate_key /data/sub.abc.com.key;
    ssl_trusted_certificate /data/sub.abc.com.crt;
    include /etc/nginx/ssl_params;

    access_log /var/log/nginx/sub.abc.com_access.log;
    error_log /var/log/nginx/sub.abc.com_error.log warn;

    location / {
        proxy_pass http://sub_backend;
        proxy_http_version 1.1;
        proxy_redirect off;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port $server_port;
        proxy_set_header X-Nginx-Proxy true;
        add_header 'Access-Control-Allow-Origin' '*';

        # For WebSocket
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
    }

}
```
-subweb.abc.com
```yml
upstream subweb_backend {
    server 127.0.0.1:58080;

    keepalive 128;
}

server {
    listen 80;
    server_name subweb.abc.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name subweb.abc.com;

    ssl_certificate /data/subweb.abc.com.crt;
    ssl_certificate_key /data/subweb.abc.com.key;
    ssl_trusted_certificate /data/subweb.abc.com.crt;
    include /etc/nginx/ssl_params;

    access_log /var/log/nginx/subweb.abc.com_access.log;
    error_log /var/log/nginx/subweb.abc.com_error.log warn;

    location / {
        proxy_pass http://subweb_backend;
        proxy_http_version 1.1;
        proxy_redirect off;

        # 跨域
        add_header 'Access-Control-Allow-Origin' $http_origin always;
        add_header 'Access-Control-Allow-Headers' $http_access_control_request_headers always;
        add_header 'Access-Control-Max-Age' 86400 always;
        add_header 'Access-Control-Allow-Methods' 'PUT,GET,POST,DELETE,HEAD' always;
        add_header 'Access-Control-Allow-Credentials' 'true' always;
        proxy_ignore_headers X-Accel-Expires Expires Cache-Control Set-Cookie;
        add_header Cache-Control no-store always;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port $server_port;
        proxy_set_header X-Nginx-Proxy true;

        # For WebSocket
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
    }

}
```
## 使用Nginx Proxy Manager
对短链接需要配置 允许 CORS
```yml
location / {
    proxy_pass http://127.0.0.1:8002;  # 或者使用实际的IP和端口
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;

    # 添加 CORS 头
    add_header 'Access-Control-Allow-Origin' 'https://subweb.domainname.com' always;
    add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS' always;
    add_header 'Access-Control-Allow-Headers' 'Authorization, Content-Type, X-Requested-With' always;
    add_header 'Access-Control-Allow-Credentials' 'true' always;

    if ($request_method = 'OPTIONS') {
        return 204;
    }
}
```

## ufw
如果有防火墙，比如ufw，需要放行80 443端口
```bash
ufw allow 80
ufw allow 443
```
## 启动nginx
```bash
systemctl start nginx
```




## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2024-01-14T21:48:38+08:00

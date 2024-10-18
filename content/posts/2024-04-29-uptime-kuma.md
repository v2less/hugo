---
title: "Uptime Kuma"
date: 2024-04-29T02:09:58Z
author: v2less
tags: ["linux"]
draft: false
---
## docker-compose.yml
```yaml
version: '3.3'

services:
  uptime-kuma:
    image: louislam/uptime-kuma
    container_name: uptime-kuma
    restart: always
    volumes:
      - ./data:/app/data
      - /var/run/docker.sock:/var/run/docker.sock
    ports:
      - 5702:3001   # 我设置的访问端口号为5702，可以自行修改端口
```

```bash
docker compose up -d
```
## 添加监控项
### jenkins api
- 登录jenkins，到个人用户配置界面，生成API token
例如： jenkins_url/user/username/configure
token: 11413887085e629903001cd13505677570
生成base64编码值：
```bash
echo -n 'username:11413887085e629903001cd13505677570' | base64
dXNlcm5hbWU6MTE0MTM4ODcwODVlNjI5OTAzMDAxY2QxMzUwNTY3NzU3MAo=
```
- 添加监控项
http选项默认GET，JSON格式的请求头：
```json
{
    "Authorization": "Basic dXNlcm5hbWU6MTE0MTM4ODcwODVlNjI5OTAzMDAxY2QxMzUwNTY3NzU3MAo="
}
```
### kanboard api
- 登录kanboard，设置，应用程序接口
```ini
API 令牌： c2d221450eef78066846cc8f746cfe56e4aa95e29558b79485fbb766d88d
API 端点： https://xxx.com/kanboard/jsonrpc.php
```
- 添加监控项
http选项默认GET，JSON格式的请求头：
```json
{
    "Authorization": "Bearer c2d221450eef78066846cc8f746cfe56e4aa95e29558b79485fbb766d88d"
}
```








## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2024-04-29T02:09:58Z

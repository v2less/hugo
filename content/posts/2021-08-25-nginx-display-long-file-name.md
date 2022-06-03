---
title: "Nginx Display Long File Name"
date: 2021-08-25T09:38:06+08:00
author: v2less
tags: ["linux"]
draft: false
---

## Nginx Fancy Index module
使用ngx-fancyindex替代audoindex模块。
`sudo apt install libnginx-mod-http-fancyindex`
编辑/etc/nginx/sites-enabled/default配置文件:
```ini
 location / {
              # First attempt to serve request as file, then
              # as directory, then fall back to displaying a 404.
                try_files $uri $uri/ =404;
                #autoindex on;
                #autoindex_localtime on;
                #autoindex_exact_size off;
                fancyindex on;              # Enable fancy indexes.
                fancyindex_exact_size off;  # Output human-readable file sizes.
                fancyindex_localtime on;
                fancyindex_name_length 255;
  }
```
然后重启nginx服务:
`sudo systemctl restart nginx`



## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2021-08-25T09:38:06+08:00

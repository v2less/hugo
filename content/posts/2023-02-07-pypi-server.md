---
title: "Pypi Server"
date: 2023-02-07T11:02:17+08:00
author: v2less
tags: ["linux"]
draft: false
---

# 使用pypiserver搭建私有pypi服务器

*pypiserver* 是一个最基本的PyPI服务器实现, 可以用来上传和维护python包. 本文介绍 *pypiserver* 在debian的基本安装, 配置和使用.

# 1. 基本安装和使用

## 1.1 安装和启动

*pypiserver* 可以在Python 2或者Python 3下运行. 使用`pip`就可以安装:

```javascript
pip install pypiserver
```

复制

启动 *pypiserver* 使用以下命令:

```javascript
pypi-server
```

复制

在没有显示指定任何启动参数的时候, *pypiserver* 是使用 *~/packages* 来保存Python包, 同时监听8080端口来提供PyPI服务.

## 1.2 上传Python包

此时, 在创建 *~/packages* 目录后, 可以将Python包上传到此目录下. 比如, 有一个Python项目叫 *demo* , 它的 *setup.py* 文件内容如下:

```javascript
from setuptools import setup

setup(
    name='demo',
    version='0.0.1',
    packages=['demo']
)
```

复制

在项目根目录下执行以下命令来生成Python代码分发包:

```javascript
python setup.py sdist
```

复制

执行完上面这条命令后, 可以在项目下的 *dist* 目录找到分发包 *demo-0.0.1.tar.gz*. 将分发包上传到 *~/packages* 目录下, 接下来就可以访问 *pypiserver* 上的Python包了.

## 1.3 安装 *pypiserver* 上的Python包

在安装和启动 *pypiserver* 后, 可以通过浏览器访问http://localhost:8080可以访问 *pypiserver* 的默认欢迎页

访问http://localhost:8080/simple/demo则可以看到刚上传的*demo-0.0.1.tar.gz*包

### 1.3.1 *pip*

在本地环境中, 可以使用 *pip* 的 *index-url* 参数来访问 *pypiserver* 上的Python包:

```javascript
# pip search -i http://localhost:8080 demo
# pip install -i http://localhost:8080 demo
```

复制

### 1.3.2 *easy_install*

同样也可以使用 *easy_install* 来访问 *pypiserver* :

```javascript
# easy_install -i http://localhost:8080/simple demo
```

## 2. 远程上传项目包

如果希望通过`python setup.py upload`命令将本地项目代码上传到PyPI服务器, 可以通过以下步骤来完成.

### 2.1 无密码上传项目包

默认情况下, *pypiserver* 的上传操作是密码保护的, 不过可以通过以下启动参数来关闭密码保护:

```javascript
pypi-server -P . -a .
```

复制

上述命令中的`-P`参数用来指定密码文件, `-a`用来指定需要密码保护的操作. 当这两个参数同时指定为`.`时, 表示所有的操作都不需要密码保护.

此时, 就可以在Python项目的根目录下, 执行远程安装命令来上传包. 比如在本地项目中, 执行以下命令:

```javascript
python setup.py sdist upload -r http://localhost:8080
```

复制

此时, *upload* 命令仍然会提示输入密码, 此时直接回车确认就可以了.

### 2.2 使用密码保护PyPI源

当希望使用密码来控制Python包的上传操作的时候, 需要使用Apache *htpasswd* 文件.

*pypiserver* 需要 *passlib* 包来读取 *htpasswd* 文件. 使用以下命令来安装 *passlib* :

```bash
pip install passlib
```

复制

要生成 *htpasswd* 文件, 需要安装 *apache2-utils* 工具包. 在Ubuntu上使用以下命令安装:

```bash
apt-get install -y apache2-utils
```

复制

接下来就可以用 *htpasswd* 命令来生成密码文件. 假设密码文件路径为 */root/.pypipasswd* , 第一次生成密码文件的命令如下:

```bash
htpasswd -c /root/.pypipasswd sam
```

复制

上述命令中的最后一个参数`sam`是用户名, 执行命令后, 会提示输入密码.

当需要在已有的密码文件中添加新的用户名和密码时, 不能再使用`-c`参数, 否则会将已有的数据覆盖. 比如, 要在上一步生成的文件里添加一个新用户名 *john* :

```bash
htpasswd /root/.pypipasswd john
```

复制

接下来就可以使用密码文件来控制上传操作了. 当启动 *pypiserver* 时, 通过`-P`参数来指定所要使用的密码文件. 默认情况下, 上传操作会需要密码验证, 如果希望其他操作也需要密码验证, 可以使用`-a`参数. 具体`-a`参数的使用可以查阅*pypiserver*的启动命令帮助, 这里不再展开.

```bash
pypi-server -P /root/.pypipasswd
```

复制

接下来, 在需要上传Python包的系统中, 需要配置Distutils来指定上传操作所需要的用户名和密码.

创建或者修改 *~/.pypirc* 文件, 文件需要以下内容:

```ini
[distutils]
index-servers = localhost

[localhost]
repository: http://localhost:8080
username: sam
password: 123456
```

复制

配置中的`[localhost]` section就是 *pypiserver* 的地址和用户名密码信息. `index-servers`值中的`localhost`就指定了名为`localhost`的section. 接下来, 当我们向名为 *localhost* 或者地址为 http://localhost:8080 的PyPI源上传Python包时, 用户名 *sam* 和密码 *123456* 就会被用来验证操作权限:

```bash
python setup.py sdist upload -r localhost
```

## 3. 其他配置

### 3.1 指定监听端口

默认情况下 *pypiserver* 监听8080端口, 我们可以通过`-p`参数来指定期望的端口:

```javascript
pypi-server -p 9090
```

复制

### 3.2 指定包目录

默认情况下 *pypiserver* 使用*~/packages* 目录来读取和保存Python包. 我们可以使用`-P`参数来修改:

```javascript
pypi-server -P /opt/pypiserver/packages
```

复制

### 3.3 请求转发

当请求的Python包, 在本地 *pypiserver* 上没有找到时, 它会将请求转发到外部PyPI源, 默认为 https://pypi.doubanio.com/simple . 对于国内使用来说, 可以通过 `--fallback-url` 参数将转发目的地址设置为豆瓣源:

```javascript
pypi-server --fallback-url https://pypi.doubanio.com/simple
```

## 4. Docker方式

### 4.1 docker-compose.yml

```yml
version: '2'
services:

  pypiserver:
    image: pypiserver/pypiserver:v1.5.1
    container_name: pypiserver
    volumes:
      - ./packages:/data/packages
      - type: bind
        source: ./auth
        target: /data/auth
    command: --fallback-url https://pypi.tuna.tsinghua.edu.cn/simple -P /data/auth/.htpasswd -a update,download,list --overwrite /data/packages
    ports:
      - 8080:8080
    restart: always
```

解释:

`-a update,download,list` 使用密码保护上传\下载\查询, 当只需要保护上传时, 可改成`-a update`即可.

`--overwrite`表示允许重复/覆盖上传

`--fallback-url`指定外部源,本地没有时使用外部源


### 4.2 nginx配置
```ini
upstream pypiserver {
  server 10.x.x.x:8080;
}
server {
        listen 80;                                      #监听端口
        server_name localhost;                            #监听地址，域名可以有多个，用空格隔开，一般填写域名、IP，可配置阻止其他server_name访问
        root html;                                        #根目录
        index index.php index.htm index.html;             #默认页
        #add_header X-Frame-Options SAMEORIGIN;           #防止点击劫持，DENY：拒绝所有其他页面访问，SAMEORIGIN：只能为同源域名下的页面，ALLOW-FROM：允许frame加载
        #rewrite ^/(.*) /we-dao/fsj-0815/$1 last;         #重写url
#        proxy_redirect 
#        proxy_redirect http://$host/ https://$host:20009/;
#        proxy_set_header Host $host:20009;

        location /pypi/ {
                proxy_pass http://pypiserver/;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            
                # When setting up pypiserver behind other proxy, such as an Nginx instance, remove the below line if the proxy already has similar settings.
                proxy_set_header X-Forwarded-Proto $scheme;
            
                proxy_buffering off;
                proxy_request_buffering off;
        }
        location /packages/ {
                alias /data/packages/; 
        }
}
```
**需要注意的是:**
如果nginx也是用docker起来的, 需要映射下packages目录:
```yml
volumes:
      - /data/app/pypiserver/packages:/data/packages
```

### 4.3 启动 or 停止

启动:

```bash
docker-compose up -d
```

停止:

```bash
docker-compose down
```

### 4.3 构建
```bash
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
cat <<EOF|tee /etc/pip.conf
[global]
index-url = https://mirrors.aliyun.com/pypi/simple/

[install]
trusted-host=mirrors.aliyun.com
EOF
#如果是低版本的python,可以先安装对应的pip
curl -fsSL https://bootstrap.pypa.io/pip/3.5/get-pip.py | python3.5
python3 -m pip install setuptools wheel twine
python3 setup.py check || exit 1
python3 setup.py sdist bdist_wheel || exit 1
```
### 4.4 上传
```bash
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
twine upload dist/* --repository-url http://xxxxx.com/pypi/ -u sam -p sam123
```
### 4.5 安装
```bash
python3 -m pip install --index-url http://xxxxx.com/pypi/simple --trusted-host xxxxx.com pyclip==0.6.0
```





## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2023-02-07T11:02:17+08:00

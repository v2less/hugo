+++
title = "Setup Apt Repos"  # 文章标题
date = 2020-08-01T15:59:59+08:00  # 自动添加日期信息
draft = false  # 设为false可被编译为HTML，true供本地修改
tags = ["Linux"]  # 文章标签，可设置多个，用逗号隔开。Hugo会自动生成标签的子URL

+++

# 自建APT 仓库

## 生成签名用的 GPG KEY

运行命令: `gpg --full-gen-key`

按照提示输入姓名、邮箱，确认，有效期，输入密码，`~/.gnupg/openpgp-revocs.d/`目录下生成`.rev`的key文件，有效期两年。

随机16位密码： `openssl rand -base64 16`

## 生成ASCII格式的Public Key文件

`gpg --output devicepackages@uniontech.com.gpg.key --armor --export devicepackages@uniontech.com `

实际测试，`--output选项须在前`

## 构建软件包

  进入源码仓库文件夹：

  ```bash
  dpkg-buildpackage -us -uc
  ```

## 对deb包进行签名

`apt-get install dpkg-sig`

如果在打包deb之前已经做好了签名key，且软件包的changelog中的姓名、邮箱与生成GPG KEY所用一样，在执行`dpkg-buildpackage`打包时自动签名。

否则，手动签名：`dpkg-sig --sign builder mypackage_0.1.2_amd64.deb`

## Web服务器

- 安装apache2服务器

`sudo apt install apache2`

`sudo mkdir -p /var/www/repos/apt/`

在` */etc/apache2/apache2.conf* ` 添加  `ServerName localhost`

- 添加apt仓库配置文件

sudo vi */etc/apache2/conf.d/repos*

```bashbash
# /etc/apache2/conf.d/repos
# Apache HTTP Server 2.4

<Directory /var/www/repos/ >
        # We want the user to be able to browse the directory manually
        Options Indexes FollowSymLinks Multiviews
        Require all granted
</Directory>

# This syntax supports several repositories, e.g. one for Debian, one for Ubuntu.
# Replace * with debian, if you intend to support one distribution only.
<Directory "/var/www/repos/apt/*/db/">
        Require all denied
</Directory>

<Directory "/var/www/repos/apt/*/conf/">
        Require all denied
</Directory>

<Directory "/var/www/repos/apt/*/incoming/">
        Require all denied
</Directory>
```

- 修改80端口主页指向apt仓库地址：

`sudo vi /etc/apache2/sites-available/000-default.conf`

`DocumentRoot /var/www/repos/apt`


## 创建APT仓库

- 在`/var/www/repos/apt/`创建一个仓库用的文件夹，比如`debian`。在`debian`下再创建一个文件夹`conf`。

- 在`conf`文件夹中创建一个`distributions`文本文件，如下格式：

```bash
Origin: Linux 
Label: debian
Codename: buster
Version: 2019
Update: buster
Architectures: i386 amd64 arm64 mips64el sw_64 source
Components: main
UDebComponents: main
Contents: percomponent nocompatsymlink .bz2
SignWith: yes
Description: debian packages

Origin: Linux 
Label: debian
Codename: buster/sp1
Version: 2019
Update: sp1
Architectures: i386 amd64 arm64 mips64el sw_64 source
Components: main
UDebComponents: main
Contents: percomponent nocompatsymlink .bz2
SignWith: yes
Description: debian packages
```

- `apt-get install reprepro`

`reprepro`会自动创建仓库所需要的结构。

- 创建或更新`distributions`后，执行：`reprepro export `刷新仓库。

- 添加软件包到仓库：

```bash
reprepro --ask-passphrase -Vb . includedeb codename packages.deb
# --aks-passphrase 询问密码，在生成GPG KEY设置的密码
# -V verbose 详细模式，输出详细信息
# -b basedir 
# .  当前目录
# includedeb 添加软件包
# codename 比如eagle, eagle/sp1, eagle/sp2
```

- 删除软件包，指定codename

  `reprepro remove codename packagesname`

- 删除软件代码，指定codename

  `reprepro removedsc codename packagesname`

## 添加key

`wget -O - http://×××/*****.gpg.key | sudo apt-key add -`

## 添加仓库地址到 `/etc/apt/sources.list`

`deb http://192.168.122.1/ buster main`

## 修改仓库优先级

`vi /etc/apt/preferences`

```bash
Package: *
Pin: origin 192.168.122.1
Pin-Priority: 900
```

参考：

1. https://wiki.debian.org/DebianRepository/SetupWithReprepro?action=show&redirect=SettingUpSignedAptRepositoryWithReprepro
2. http://blog.jonliv.es/blog/2011/04/26/creating-your-own-signed-apt-repository-and-debian-packages/


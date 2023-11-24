---
title: "Redmi AX6000 Openwrt 记录"
date: 2023-11-22T13:32:46+08:00
author: v2less
tags: ["openwrt"]
draft: false
---

# Redmi AX6000 Openwrt 记录

## 准备工作

- 红米AX6000，自带固件1.0.67，无需降级，也可以开启ssh。
- Mac/Linux/windows(windows开启本机的telnet功能：控制面板——卸载程序——启用或关闭Windows功能——勾选telnet功能——确定)

## 小米路由官方修复工具

小米路由官方修复工具
[MIWIFIRepairTool.x86.zip](http://bigota.miwifi.com/xiaoqiang/tools/MIWIFIRepairTool.x86.zip)

红米AX6000 RB06官方固件

[miwifi_rb06_firmware_de54d_1.0.67.bin](https://cdn.cnbj1.fds.api.mi-img.com/xiaoqiang/rom/rb06/miwifi_rb06_firmware_de54d_1.0.67.bin)

网线接路由器和电脑，路由器断电，电脑退出杀毒软件，还有Windows的自带Windows Defender防火墙杀毒，关闭电脑防火墙，解压并打开小米路由修复工具，选择官方的rb06固件，网卡选择当前连接路由器的网卡，点下一步，工具会自动配置网卡IP为192.168.31.100/24，配置好后会显示刷机步骤，然后按住路由器RESET插电开机，大概12秒后等到黄灯闪烁后可以松开RESET，等待小米路由修复工具连接路由器开始上传固件，上传完后会刷机，刷机成功后蓝灯闪烁。等待10秒后重新断电插电即可恢复到官方系统。点击退出小米路由修复工具，网卡会自动恢复自动获取的配置。

## 获取token

登陆小米路由器admin，浏览器地址栏stok=后面部分就是token, 这个token是每次登录都会变化，后面都会用到这个token。如果重新登录后，都要重新复制这个token.

## 开启开发者模式

**更改路由器的crash分区，使其进入到开发者模式**

将下面的URL里面的stok=token的token替换成上面获取路由器的token值，然后复制到到浏览器并且按enter打开


```bash
http://192.168.31.1/cgi-bin/luci/;stok=token/api/misystem/set_sys_time?timezone=%20%27%20%3B%20zz%3D%24%28dd%20if%3D%2Fdev%2Fzero%20bs%3D1%20count%3D2%202%3E%2Fdev%2Fnull%29%20%3B%20printf%20%27%A5%5A%25c%25c%27%20%24zz%20%24zz%20%7C%20mtd%20write%20-%20crash%20%3B%20
```

浏览器返回{“code”:0}，表示成功。

**通过浏览器重启路由器**

在浏览器地址栏输入下面的url, 和上面的做法一样，将stok=token的token替换成上面获取路由器的token值


```bash
http://192.168.31.1/cgi-bin/luci/;stok=token/api/misystem/set_sys_time?timezone=%20%27%20%3b%20reboot%20%3b%20
```

## 设置Bdata参数

**设置参数telnet_en、 ssh_en、uart_en**

重启后，要重新获取token, 然后在浏览器地址栏输入下面的url, 将stok=token的token替换成上面获取路由器的token值


```bash
http://192.168.31.1/cgi-bin/luci/;stok=token/api/misystem/set_sys_time?timezone=%20%27%20%3B%20bdata%20set%20telnet_en%3D1%20%3B%20bdata%20set%20ssh_en%3D1%20%3B%20bdata%20set%20uart_en%3D1%20%3B%20bdata%20commit%20%3B%20
```

**重启路由器**

在浏览器地址栏输入下面的url, 和上面的做法一样，将stok=token的token替换成上面获取路由器的token值

```bash
http://192.168.31.1/cgi-bin/luci/;stok=token/api/misystem/set_sys_time?timezone=%20%27%20%3b%20reboot%20%3b%20
```

## 通过telnet开启ssh

在终端输入`telnet 192.168.31.1`, 可以看到Are you ok的界面，就证明telnet成功了。

telnet连接上，输入指令开启ssh并修改密码为admin：

在终端输入`telnet 192.168.31.1`, 可以看到Are you ok的界面，就证明telnet成功了。

telnet连接上，输入指令开启ssh并修改密码为admin：

```bash
bdata set boot_wait=on
bdata commit
nvram set ssh_en=1
nvram set telnet_en=1
nvram set uart_en=1
nvram set boot_wait=on
nvram commit
sed -i 's/channel=.*/channel="debug"/g' /etc/init.d/dropbear
/etc/init.d/dropbear restart
echo -e 'admin\nadmin' | passwd root
```

## 永久开启ssh

开启新窗口，使用ssh登录路由器，输入指令开启ssh并修改密码为admin：

```bash
ssh root@192.168.31.1
```

不过ssh登录的时候如果报下面的错误`no matching host key type found. Their offer: ssh-rsa`, 是因为OpenSSH 7.0以后的版本不再支持ssh-rsa (RSA)算法, 解决方法是手动加上

```bash
# vi ~/.ssh/config
Host redmi
  HostName 192.168.31.1
  User root
  Port 22
  HostKeyAlgorithms +ssh-rsa
  PubkeyAcceptedKeyTypes +ssh-rsa
```

或者

```bash
#  ssh -oHostKeyAlgorithms=+ssh-rsa  root@192.168.31.1
```

从telnet开启的ssh，路由器重启会失效，添加一个开启自动运行的脚本，来实现自动开启ssh。如果恢复出厂设置或重新刷机后需要重新添加.

```bash
mkdir /data/auto_ssh && cd /data/auto_ssh
touch auto_ssh.sh
chmod +x auto_ssh.sh
```

创建auto_ssh.sh文件，使用vi输入下面的内容并保存

```bash
#!/bin/sh

auto_ssh_dir="/data/auto_ssh"
host_key="/etc/dropbear/dropbear_rsa_host_key"
host_key_bk="${auto_ssh_dir}/dropbear_rsa_host_key"

unlock() {
    # Restore the host key.
    [ -f $host_key_bk ] && ln -sf $host_key_bk $host_key

    # Enable telnet, ssh, uart and boot_wait.
    [ "$(nvram get telnet_en)" = 0 ] && nvram set telnet_en=1 && nvram commit
    [ "$(nvram get ssh_en)" = 0 ] && nvram set ssh_en=1 && nvram commit
    [ "$(nvram get uart_en)" = 0 ] && nvram set uart_en=1 && nvram commit
    [ "$(nvram get boot_wait)" = "off" ]  && nvram set boot_wait=on && nvram commit

    [ "`uci -c /usr/share/xiaoqiang get xiaoqiang_version.version.CHANNEL`" != 'stable' ] && {
        uci -c /usr/share/xiaoqiang set xiaoqiang_version.version.CHANNEL='stable' 
        uci -c /usr/share/xiaoqiang commit xiaoqiang_version.version 2>/dev/null
    }

    channel=`/sbin/uci get /usr/share/xiaoqiang/xiaoqiang_version.version.CHANNEL`
    if [ "$channel" = "release" ]; then
        sed -i 's/channel=.*/channel="debug"/g' /etc/init.d/dropbear
    fi

    if [ -z "$(pidof dropbear)" -o -z "$(netstat -ntul | grep :22)" ]; then
        /etc/init.d/dropbear restart 2>/dev/null
        /etc/init.d/dropbear enable
    fi
}

install() {
    # unlock SSH.
    unlock

    # host key is empty, restart dropbear to generate the host key.
    [ -s $host_key ] || /etc/init.d/dropbear restart 2>/dev/null

    # Backup the host key.
    if [ ! -s $host_key_bk ]; then
        i=0
        while [ $i -le 30 ]
        do
            if [ -s $host_key ]; then
                cp -f $host_key $host_key_bk 2>/dev/null
                break
            fi
            let i++
            sleep 1s
        done
    fi

    # Add script to system autostart
    uci set firewall.auto_ssh=include
    uci set firewall.auto_ssh.type='script'
    uci set firewall.auto_ssh.path="${auto_ssh_dir}/auto_ssh.sh"
    uci set firewall.auto_ssh.enabled='1'
    uci commit firewall
    echo -e "\033[32m SSH unlock complete. \033[0m"
}

uninstall() {
    # Remove scripts from system autostart
    uci delete firewall.auto_ssh
    uci commit firewall
    echo -e "\033[33m SSH unlock has been removed. \033[0m"
}

main() {
    [ -z "$1" ] && unlock && return
    case "$1" in
    install)
        install
        ;;
    uninstall)
        uninstall
        ;;
    *)
        echo -e "\033[31m Unknown parameter: $1 \033[0m"
        return 1
        ;;
    esac
}

main "$@"
```

将auto_ssh写入固化

```bash
uci set firewall.auto_ssh=include
uci set firewall.auto_ssh.type='script'
uci set firewall.auto_ssh.path='/data/auto_ssh/auto_ssh.sh'
uci set firewall.auto_ssh.enabled='1'
uci commit firewall
```

## 关闭开发者模式

ssh连接上路由器后，输入指令关闭开发者模式

```bash
mtd erase crash
reboot
```

## 修复时区异常

如果路由器时区异常，ssh连接中路由器后, 输入指令修复时区异常

```bash
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].webtimezone='CST-8'
uci set system.@system[0].timezoneindex='2.84'
uci commit
```

## 注意事项

升级固件后，可能需要通过telnet重新开启ssh. 不过目前我还没遇到过这种情况，在开启ssh后，我是直接将1.60的固件自动升级到1.67，ssh还是开启了，密码也是admin.

## **刷hanwckf大佬的不死uboot**

传送门：https://www.right.com.cn/forum/thread-8265832-1-1.html

**hanwckf大佬uboot地址：**https://github.com/hanwckf/bl-mt798x/releases
下载后解压出来mt7986_redmi_ax6000-fip-fixed-parts-multi-layout.bin就是红米AX6000的uboot
20230902大佬更新了最新红米AX6000支持多分区的uboot，具体使用可以看大佬博客https://cmi.hanwckf.top/p/mt798x-uboot-usage/

1. 不论你现在在什么三方系统下，请先用救砖工具回官方系统后，进telnet解锁ssh

2. 进入ssh界面运行命令
   `cat /proc/mtd`

查看FIP在哪个分区，有的非官方固件在分区4，官方固件在分区5；一定要看好自己的

3. 替换不死文件前，先备份官方引导 fip分区，并自行导出。
   `dd if=/dev/mtd5 of=/tmp/FIP.bin`

4. 将不死uboot传输到路由/tmp目录
5. ssh界面运行命令刷入不死uboot：
   `mtd write /tmp/xxuboot.bin /dev/mtd5`

6. 写入不死完SSH无提示报错;等个5秒直接拔电；电脑以太网卡ipv4地址固定为192.168.31.X（X为2-254任意数字）



7. 断电状态下；先顶住reset孔后插电，观察以太网卡，大约15秒即可松手，目前第一版不死BOOT无LED灯提示



8. 非IE浏览器外的任意高内核版本浏览器，输入192.168.31.1；即可进入uboot的webui界面



刷不死uboot后不支持小米官方救砖工具，需要刷回原厂FIP分区后，才能用小米救砖工具刷回官方固件。

**【110MB大分区uboot版本固件】**
**目前237大佬和****hanwckf大佬的****闭源OP支持uboot(ubi分区110MB)大分区，**[OpenWrt官方](https://downloads.openwrt.org/snapshots/targets/mediatek/filogic/)**、**[X-Wrt](https://downloads.x-wrt.com/rom/)源码则已经更新了ubootmod(ubi分区122.5MB)，为了避免混乱他们舍弃了uboot(ubi分区110MB)的支持，[Lean开源源码](https://github.com/coolsnowwolf/lede)目前还支持110MB大分区固件，大家也可以尝试。

**
强烈推荐237大佬的闭源OP，uboot大分区和官方分区的固件都有：**
**https://www.right.com.cn/forum/thread-8261104-1-1.html**




固件： https://www.right.com.cn/forum/thread-6352752-1-1.html  刷机后，openclash  正在收集数据…，不稳定。

固件：https://www.right.com.cn/forum/thread-8288981-1-1.html  刷机后，openclash 无法更新配置。

固件：https://www.right.com.cn/forum/thread-8285429-1-1.html 插件太多，openclash  正在收集数据…，不稳定。

固件：https://www.right.com.cn/forum/thread-8261104-1-1.html 较稳定，服务只有OP，有Turbo ACC网络加速。




## **从hanwckf大佬的不死uboot刷回官方**

原理参考红米AX6刷回官方固件，就是把uboot还原回原厂uboot（因为没有刷分区表文件，所以没有刷回原厂分区表操作），再用官方修复工具恢复官方固件。
目前只知道237大佬和hanwckf大佬的闭源OP是已解锁FIP的，可以直接刷uboot，如果当前固件不能刷FIP分区，请先刷回闭源OP，再刷回原厂uboot。
建议使用自己机子的FIP备份，其他的我没试过。将自己的原厂FIP备份文件，如mtd5_FIP.bin，上传到tmp文件夹下，然后解锁FIP分区的固件下输入命令刷入：

```bash
md5sum /tmp/mtd5_FIP.bin
mtd write /tmp/mtd5_FIP.bin FIP
mtd verify /tmp/mtd5_FIP.bin FIP
```

注意：写入FIP分区时不能断电、重启，不然就直接变砖，只能上编程器了。
这里和刷不死uboot一样，使用md5sum检查上传到tmp文件夹的原厂uboot文件的md5值和你保存的是否一样，无误后用mtd write将原厂uboot文件写入FIP分区，再用mtd verify对比检查原厂uboot文件是否已写入FIP分区。
注意mtd命令最后的FIP是大写。

对比检查最后输出“Success"说明刷入已成功，可以断电路由器，然后打开小米路由官方修复工具进行修复了。



## 常用软件配置

### OpenClash

- 手动安装

https://github.com/zerolabnet/OpenClash

这个版本 没有 `kmod-inet-diag` 依赖，适用于使用存储库 `kmod-inet-diag` 中没有的版本的用户。

```bash
opkg update
opkg install dnsmasq-full --download-only && opkg remove dnsmasq && opkg install dnsmasq-full --cache . && rm *.ipk
opkg install wget-ssl coreutils-nohup bash iptables curl ca-certificates ipset ip-full iptables-mod-tproxy iptables-mod-extra libcap libcap-bin ruby ruby-yaml kmod-tun unzip luci-compat
cd /tmp
wget https://github.com/zerolabnet/OpenClash/releases/download/v0.45.121-beta/luci-app-openclash_0.45.121-beta_all.ipk
opkg install luci-app-openclash_0.45.121-beta_all.ipk
reboot
```

- 下载mesh内核

https://github.com/vernesong/OpenClash/blob/core/master/meta/clash-linux-arm64.tar.gz

解压后的文件较大，使用upx压缩。

[upx](https://github.com/upx/upx/releases)可以有效地对可执行文件进行压缩，并且压缩后的文件可以直接由系统执行，支持多系统和平台。 使用 UPX 来压缩可执行文件是一种减少发布包大小的有效方式。

```javascript
upx [options] yourfile
```

复制

upx 对文件的默认操作即为压缩，使用上述命令会使用默认参数压缩并替换文件 yourfile。 upx 支持如下可选参数：

- `-1[23456789]`
  ：不同的压缩级别，数值越高压缩率越高，但耗时更长。对于小于 512 KiB 的文件默认使用 `-8`  ，其他的默认为  `-7`	。


  - `--best`：最高压缩级别
  - `--brute`：尝试使用各种压缩方式来获取最高压缩比
  - `--ultra-brute`：尝试使用更多的参数来获取更高的压缩比

- `-o [file]`：将压缩文件保存为 [file]

将压缩后的clash_meta传输到**/etc/openclash/core/clash_meta**



配置OpenClash，订阅一个，并启动。

### Adguard home

- 手动安装 Adguard home

https://github.com/rufengsuixing/luci-app-adguardhome/releases

```bash
opkg install luci-app-adguardhome_1.8-11_all.ipk
reboot
```



- Adguard广告规则

```yml
filters:
  - enabled: true
    url: https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt
    name: AdGuard DNS filter
    id: 1
  - enabled: false
    url: https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt
    name: AdAway Default Blocklist
    id: 2
  - enabled: true
    url: https://ghproxy.com/https://raw.githubusercontent.com/217heidai/adblockfilters/main/rules/EasyList.txt
    name: EasyList
    id: 1700569140
  - enabled: true
    url: https://ghproxy.com/https://raw.githubusercontent.com/217heidai/adblockfilters/main/rules/EasyList_China.txt
    name: EasyList China
    id: 1700569141
  - enabled: true
    url: https://ghproxy.com/https://raw.githubusercontent.com/217heidai/adblockfilters/main/rules/EasyPrivacy.txt
    name: EasyPrivacy
    id: 1700569142
  - enabled: true
    url: https://ghproxy.com/https://raw.githubusercontent.com/217heidai/adblockfilters/main/rules/CJX's_Annoyance_List.txt
    name: CJX's Annoyance List
    id: 1700569144
  - enabled: true
    url: https://ghproxy.com/https://raw.githubusercontent.com/217heidai/adblockfilters/main/rules/SmartTV_Blocklist.txt
    name: SmartTV Blocklist
    id: 1700569145
  - enabled: true
    url: https://ghproxy.com/https://raw.githubusercontent.com/217heidai/adblockfilters/main/rules/1Hosts_(Lite).txt
    name: 1Hosts (Lite)
    id: 1700569146
```

### AdguardHome + OpenClash 配合使用


整体思路：客户端-->dnsmasq-->AdguardHome-->OpenClash-->互联网

- 首先订阅一个服务并启用op，使之能够访问网络
- AdguardHome更新核心，不选择重定向，启用。
- - 打开Adg网页管理页面，如果出现无法登录的情况，可能是使用了快速配置，这个时候去ssh删除配置文件/etc/AdGuardHome.yaml，并重启adg服务：

```bash
chmod 755 /etc/init.d/AdGuardHome
service AdGuardHome restart
```
- - 访问路由器ip:3000/install.html进行向导安装配置，举例设定：网页端口3000，dns端口5353。

- OP设置：

- - 禁用 本地DNS劫持
  - 自定义上游DNS服务器 启用
  - Fallback-Filter 启用
  - dns服务器默认的即可

- Adg设置：

- - 重定向：使用53端口替换dnsmasq
  - 网页管理界面，DNS设置-->上游dns服务器改成OP的地址：`127.0.0.1:7874`
  - 网页管理界面，过滤器，黑名单参考，可以直接在Adg的配置里改：

  ```yml
  filters:
    - enabled: true
      url: https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt
      name: AdGuard DNS filter
      id: 1
    - enabled: false
      url: https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt
      name: AdAway Default Blocklist
      id: 2
    - enabled: true
      url: https://ghproxy.com/https://raw.githubusercontent.com/217heidai/adblockfilters/main/rules/EasyList.txt
      name: EasyList
      id: 1700569140
    - enabled: true
      url: https://ghproxy.com/https://raw.githubusercontent.com/217heidai/adblockfilters/main/rules/EasyList_China.txt
      name: EasyList China
      id: 1700569141
    - enabled: true
      url: https://ghproxy.com/https://raw.githubusercontent.com/217heidai/adblockfilters/main/rules/EasyPrivacy.txt
      name: EasyPrivacy
      id: 1700569142
    - enabled: true
      url: https://ghproxy.com/https://raw.githubusercontent.com/217heidai/adblockfilters/main/rules/CJX's_Annoyance_List.txt
      name: CJX's Annoyance List
      id: 1700569144
    - enabled: true
      url: https://ghproxy.com/https://raw.githubusercontent.com/217heidai/adblockfilters/main/rules/SmartTV_Blocklist.txt
      name: SmartTV Blocklist
      id: 1700569145
    - enabled: true
      url: https://ghproxy.com/https://raw.githubusercontent.com/217heidai/adblockfilters/main/rules/1Hosts_(Lite).txt
      name: 1Hosts (Lite)
      id: 1700569146
  ```

- DHCP/DNS-->

DNS 转发-->odg的dns端口，例如：``127.0.0.1#5353``





## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2023-11-22T13:32:46+08:00

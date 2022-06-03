---
title: "Build Debian Iso"
date: 2021-12-20T13:11:01+08:00
author: v2less
tags: ["linux"]
draft: false
---

## debootstrap构建基本文件系统

debootstrap是debian/ubuntu下的一个工具，用来构建一套基本的系统(根文件系统)。生成的目录符合Linux文件系统标准(FHS)，即包含了/boot、/etc、/bin、/usr等等目录，但它比发行版本的Linux体积小很多，当然功能也没那么强大，因此，只能说是“基本的系统”。 fedora下(centos亦可用)有类似功能的工具：febootstrap。观察这两个工具名称，可以看到debootstrap使用debian前缀“de”，而febootstrap使用fedora前缀“fe”，bootstrap含义为“引导”，并如果做过LFS的话，对它了解会比较多，而在编译gcc编译器时也有涉及到这个概念。不过debootstrap或febootstrap似乎没有表达出“引导”的意思。

安装所需软件包：

```bash
# 新建工作目录 build
$ mkdir ~/build && cd ~/build
# 安装必要依赖 debootstrap就是构建的命令
sudo apt-get -y install qemu qemu-user-static binfmt-support debootstrap squashfs-tools unionfs-fuse xorriso systemd-container reprepro psmisc dosfstools mtools isolinux syslinux
```

使用debootstrap:

```bash
sudo debootstrap --arch [平台] [发行版本代号] [目录]
```

如果是其他发行版，debootstrap默认没有集成对应的codename，需要做一个软链接：

```bash
ln -sf /usr/share/debootstrap/scripts/sid /usr/share/debootstrap/scripts/$codename
```

具体的可以是这样：

```bash
rootfs_root=~/build/rootfs
sudo debootstrap --no-check-gpg --arch amd64 --include wget,apt-transport-https,ca-certificates,dbus,python3,python3-apt stable $rootfs_root 'https://mirrors.ustc.edu.cn/debian/ stable'
```

## chroot安装配置目标系统

通过chroot进入到制作好的文件系统。 [chroot wiki](https%3A%2F%2Fzh.wikipedia.org%2Fwiki%2FChroot)

这里提供一个函数脚本文件，最好不要使用root用户加载此脚本chroot.sh

```bash
#!/bin/bash -x

chroot_do() {
    CHROOT_PATH=$1
    [[ -z ${CHROOT_PATH} ]] && exit 101
    shift
    sudo chroot "${CHROOT_PATH}" /usr/bin/env -i \
        HOME=/root \
        USERNAME=root \
        USER=root \
        LOGNAME=root \
        LC_ALL=C \
        PATH=/sbin:/bin:/usr/bin:/usr/sbin \
        DEBIAN_FRONTEND=noninteractive \
        "$@"
}

postchroot() {
    CHROOT_PATH=$1
    [[ -z ${CHROOT_PATH} ]] && exit 101
    sudo fuser -k "${CHROOT_PATH}"
    sudo chroot "${CHROOT_PATH}" umount /proc/sys/fs/binfmt_misc || true
    sudo chroot "${CHROOT_PATH}" umount /proc
    sudo chroot "${CHROOT_PATH}" umount /sys
    sudo chroot "${CHROOT_PATH}" umount /dev/pts

    sudo rm -rf "${CHROOT_PATH}/tmp/*" "${CHROOT_PATH}/root/.bash_history"
    sudo rm -f "${CHROOT_PATH}/etc/hosts"
    sudo rm -f "${CHROOT_PATH}/etc/hostname"
    sudo rm -f "${CHROOT_PATH}/etc/resolv.conf"
    sudo umount "${CHROOT_PATH}/dev"
    [[ -f "${CHROOT_PATH}/var/lib/dbus/machine-id" ]] && sudo rm -f "${CHROOT_PATH}/var/lib/dbus/machine-id"
    [[ -f "${CHROOT_PATH}/sbin/initctl" ]] && sudo rm -f "${CHROOT_PATH}/sbin/initctl"
    [[ -f "${CHROOT_PATH}/usr/sbin/policy-rc.d" ]] && sudo rm -f "${CHROOT_PATH}/usr/sbin/policy-rc.d"
    sudo chroot "${CHROOT_PATH}" dpkg-divert --rename --remove /sbin/initctl
}

prechroot() {
    set -x
    CHROOT_PATH=$1
    [[ -z ${CHROOT_PATH} ]] && exit 101
    sudo cp /etc/hosts "${CHROOT_PATH}/etc/"
    sudo rm "${CHROOT_PATH}/etc/resolv.conf" -f
    sudo cp /etc/resolv.conf "${CHROOT_PATH}/etc/"
    sudo mount --bind /dev "${CHROOT_PATH}/dev"

    sudo chroot "${CHROOT_PATH}" mount -t proc none /proc
    sudo chroot "${CHROOT_PATH}" mount -t sysfs none /sys
    sudo chroot "${CHROOT_PATH}" mount -t devpts none /dev/pts
    sudo chroot "${CHROOT_PATH}" dbus-uuidgen | sudo tee "${CHROOT_PATH}/var/lib/dbus/machine-id"
    sudo chroot "${CHROOT_PATH}" dpkg-divert --local --rename --add /sbin/initctl
    sudo chroot "${CHROOT_PATH}" ln -s /bin/true /sbin/initctl
    # Try to fix udevd still run problem
    sudo chroot "${CHROOT_PATH}" pkill udevd || true
    #sudo chroot ${CHROOT_PATH} dpkg-divert --local --rename --add /lib/systemd/systemd-udevd

    #echo -e "#!/bin/sh\nexit 101" | sudo tee ${CHROOT_PATH}/lib/systemd/systemd-udevd
    echo -e "#!/bin/sh\\nexit 101" | sudo tee "${CHROOT_PATH}/usr/sbin/policy-rc.d"
    sudo chmod +x "${CHROOT_PATH}/usr/sbin/policy-rc.d"
}

source_if_exist() {
    if [[ "$1" == "-exec" ]]; then
        EXEC="bash"
    else
        EXEC="source"
    fi
    if [ -f "$1" ]; then ${EXEC} "$1"; fi
}

chroot_source_if_exist() {
    BASENAME=$(basename "$1")
    if [[ -f "$1" ]]; then
        sudo cp "$1" "${CHROOT_PATH}/tmp/${BASENAME}"
        sudo chmod +x "${CHROOT_PATH}/tmp/${BASENAME}"
        prechroot "${CHROOT_PATH}"
        chroot_do "${CHROOT_PATH}" /tmp/"${BASENAME}"
        postchroot "${CHROOT_PATH}"
    fi
}

pause() {
    read -n1 -rsp $'Press any key to continue or Ctrl+C to exit...\n'
}

```

加载函数：

```bash
source chroot.sh
```

挂载文件系统：

```bash
prechroot rootfs
```

进入chroot环境：

```bash
# 进行第二步，初始化文件系统，会把一个系统的基础包等全部初始化
$ debootstrap/debootstrap --second-stage
# 初始化好了以后，退出文件系统，再次进入后就显示root了
$ exit
# 再次进入时，不需要执行脚本，使用chroot命令即可，因为ch-mount脚本是为了挂载本机文件与文件系统的关联而已
$ sudo chroot rootfs
#安装软件包、内核、其他配置，此处省略
```

事后卸载文件系统：

```bash
postchroot rootfs
```

## nspawn容器技术替代chroot技术

```bash
sudo systemd-nspawn -D ~/build/rootfs
```

## 缓存grub相关软件包

```bash
#chroot环境中操作
mkdir -p /opt/overlay-mirror/conf
mkdir -p /opt/overlay-mirror/cache
cat <<EOF | tee /opt/overlay-mirror/conf/distributions
Origin: Debian
Label: Overlay
Codename: stable
Version: dummy
Architectures: amd64
Components: main
Description: Debian overlay mirror
EOF
cd /opt/overlay-mirror/cache
apt-get -y download grub-pc grub-pc-bin grub-common grub2-common grub-efi-amd64 grub-efi-amd64-bin grub-efi-amd64-signed mokutil shim shim-signed shim-signed-common shim-unsigned os-prober

cd /opt/overlay-mirror
reprepro includedeb stable cache/*.deb
```

## 生成live压缩文件系统

```bash
mksquashfs $rootfs_root $build_root/live/filesystem.squashfs -comp xz
```

## 生成boot/efi.img

```bash
$ mkdir efi-tmp
#复制内核和initrd文件到efi-tmp文件夹
$ ls efi-tmp
vmlinuz.efi initrd.lz
$ totalsize=$(du -sk efi-temp | cut -f1)
$ blocks=$(echo '(${totalsize} * 21 / 20 + 31) / 32 * 32' | bc)
#创建efi文件
$ mkfs.msdos -C boot/efi.img $blocks
#复制内容到efi文件
$ mcopy -s -v -i boot/efi.img efi-temp/* ::
```

## 生成iso文件

amd64架构：
```bash
xorriso -as mkisofs -o $output_iso_file_name -no-pad -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin -c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e boot/efi.img -no-emul-boot -isohybrid-gpt-basdat -appid 'LiveCD' -publisher 'Debian <http://www.debian.com>' -volid Debian .
```
arm64架构：
```bash
xorriso -as mkisofs -o $output_iso_file_name -J -joliet-long -cache-inodes -e boot/efi.img -no-emul-boot -partition_cyl_align all -appid 'LiveCD' -publisher 'Debian <http://www.debian.com>' -volid Debian .
```

## 解压live文件系统

```bash
unsquashfs -d "${MOUNT_LIVE}" "${MOUNT_BUILD}/live/filesystem.squashfs
```



## 其他

还涉及到isolinux、grub二进制文件、grub菜单等。此处省略。



## 文档信息

---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2021-12-20T13:11:01+08:00

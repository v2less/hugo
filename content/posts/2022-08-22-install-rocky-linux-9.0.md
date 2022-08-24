---
title: "Install Rocky Linux 9"
date: 2022-08-22T13:53:20+08:00
author: v2less
tags: ["linux"]
draft: false
---


## 更好国内源

```bash
sed -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.sjtug.sjtu.edu.cn/rocky|g' \
    -i.bak \
    /etc/yum.repos.d/rocky-*.repo
```
## 安装epel
```bash
sudo dnf install epel-release -y
sudo dnf install util-linux-user fontconfig tar -y
```

## vdo
```bash
dnf install vdo kmod-kvdo
```

创建逻辑卷
```bash
pvcreate /dev/sdb
vgcreate vg-name /dev/sdb
vgdisplay
lvcreate --type vdo \
           --name vdo-name
           --size physical-size
           --virtualsize logical-size \
           vg-name
#逻辑大小差不多是物理大小的十倍

mkfs.xfs /dev/vg-name/vdo-name
mkdir /mnt/vdo
blkid /dev/vg-name/vdo-name
#然后配置挂载信息到/etc/fstab
```

## oh-my-zsh
```bash
#!/bin/bash
install_oh_my_zsh() {
    set -x
    export DEBIAN_FRONTEND=noninteractive
    dnf install -y zsh powerline-fonts curl git fontconfig util-linux-user tar
    cd "$HOME" || exit
    rm -rf "$HOME"/.local/share/fonts
    mkdir -p "$HOME"/.local/share/fonts
    cd "$HOME"/.local/share/fonts || exit
    while true; do
        wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf || true
        wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf || true
        wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf || true
        wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf || true
        fontsnu=$(find "$HOME"/.local/share/fonts/ -name "MesloLGS*" | wc -l)
        if [ "$fontsnu" == "4" ]; then
            break
        fi
    done
    fc-cache -v
    cd "$HOME" || exit
    echo "INFO Now start install zsh:"
    echo "When zsh have been installed,pleast input exit , back to continue run……"
    echo "When zsh have been installed,pleast input exit , back to continue run……"
    sleep 5
    i=0
    while true; do
        i=$((i + 1))
        wget -O - https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | bash - || true
        if [ -f "$HOME"/.oh-my-zsh/oh-my-zsh.sh ]; then
            break
        fi
        if [ $i -gt 30 ]; then
            echo "Check the internet."
            exit 1
        fi
    done
    cp "$HOME"/.oh-my-zsh/templates/zshrc.zsh-template "$HOME"/.zshrc
    while true; do
        if git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME"/.oh-my-zsh/custom/plugins/zsh-autosuggestions; then
            break
        fi
    done
    while true; do
        if git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME"/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting; then
            break
        fi
    done
    while true; do
        if git clone https://github.com/sukkaw/zsh-proxy.git "$HOME"/.oh-my-zsh/custom/plugins/zsh-proxy; then
            break
        fi
    done
    while true; do
        if git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME"/.oh-my-zsh/custom/themes/powerlevel10k; then
            break
        fi
    done
    sed -ri '/^plugins/c plugins=(git zsh-proxy colored-man-pages zsh-autosuggestions zsh-syntax-highlighting)' "$HOME"/.zshrc
    sed -ri '/^#[ *]HIST_STAMPS/c HIST_STAMPS="yyyy-mm-dd"' "$HOME"/.zshrc
    sed -ri '/^ZSH_THEME/c ZSH_THEME="powerlevel10k/powerlevel10k"' "$HOME"/.zshrc
    sed -ri "/^POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true/d" "$HOME"/.zshrc
    sed -ri "\$aPOWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true" "$HOME"/.zshrc
    sudo chsh -s $(which zsh)
}
install_oh_my_zsh
```



## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2022-08-22T13:53:20+08:00

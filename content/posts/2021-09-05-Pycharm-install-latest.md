---
title: "Pycharm Install Latest"
date: 2021-09-05T14:37:36+08:00
author: v2less
tags: ["linux"]
draft: false
---

## 使用脚本安装最新pycharm社区版本

```bash
#!/bin/bash
latest_version=$(wget -O - https://data.services.jetbrains.com/products/releases\?code\=PCP\&latest\=true\&type\=release 2> /dev/null | jq -r '.PCP[]|.version')

install() {
    cd /tmp || exit
    rm -rf pycharm-community-"$latest_version"* || true
    wget https://download.jetbrains.com/python/pycharm-community-"$latest_version".tar.gz
    sleep 3
    tar -xf pycharm-community-"$latest_version".tar.gz || exit
    echo copy to /opt/
    sudo cp -rf pycharm-community-"$latest_version" /opt/
    echo remove download files
    rm -rf pycharm-community-"$latest_version"* || true
    cd /opt/pycharm-community-"$latest_version"/bin || exit
    sleep 3
    echo setup pycharm
    sudo sed -r '/^SED/aexport _JAVA_AWT_WM_NONREPARENTING=1' ./pycharm.sh
    cat << EOF | sudo tee /etc/sysctl.d/notify.conf
fs.inotify.max_user_watches = 524288
EOF

    cat << EOF | sudo tee /usr/bin/pycharm
#! /usr/bin/bash
nohup /usr/lib/gnome-settings-daemon/gsd-xsettings > /dev/null 2>&1 &
export _JAVA_AWT_WM_NONREPARENTING=1
/opt/pycharm-community-"$latest_version"/bin/pycharm.sh
EOF

    sudo chmod a+x /usr/bin/pycharm
    sudo sysctl -p --system
    ./pycharm.sh
}
uninstall() {
    rm -rf "$HOME"/.config/JetBrains
    rm -rf "$HOME"/.java
    rm -rf "$HOME"/.jetbrains
    sudo rm -rf /opt/pycharm-community-"$latest_version"
    sudo rm -rf /usr/local/bin/charm
}

echo "
1. install pycharm $latest_version
2. uninstall pycharm $latest_version
3. exit
"
read -r ipx

case $ipx in
    1)
        install
        echo "pycharm plugins: shell script, save, ansible and so on."
        ;;
    2)
        uninstall
        ;;
    3)
        exit
        ;;
    *) ;;

esac
```

## Pycharm常用设置
- 插件安装： File Watchers
- File->Settings ->Appearance: Size 16 定义界面字体
- File->Settings -> Editor -> Font: Size 24 定义代码字体
- Format code with black
- - File->Settings-> Tools ->External Tools: 添加Black作为格式化python代码的工具
- - Program: `$PyInterpreterDirectory$/python`
- - Arguments: `-m black $FilePath$ -l 120`
- - Working directory: `$ProjectFileDir$`
- Auto Format code on save
- - File ->Settings-> Tools  -> File Watchers: click + to add a new watcher:
- - Name: Black
- - File type: Python
- - Scope: Project Files
- - Program: ~/.local/bin/black
- - Arguments: $FilePath$
- - Output paths to refresh: $FilePath$
- - Working directory: $ProjectFileDir$
- - Uncheck "Auto-save edited files to trigger the watcher"



## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2021-09-05T14:37:36+08:00

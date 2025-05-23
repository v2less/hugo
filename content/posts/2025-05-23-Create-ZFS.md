---
title: "Create ZFS"
date: 2025-05-23T08:27:03+08:00
author: v2less
tags: ["linux"]
draft: false
---

## ZFS
```bash
# 安装 ZFS 支持
sudo apt install zfsutils-linux

# 创建 ZFS RAID-Z1 存储池
sudo zpool create data raidz1 /dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf /dev/sdg

# 如果需要热备，编译用途没必要
sudo zpool create data raidz1 /dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf spare /dev/sdg

# 优化设置
sudo zfs set compression=lz4 data
sudo zfs set atime=off data
sudo zfs set recordsize=128K data
sudo zfs set acltype=posixacl
sudo zfs set atime=off data


# （可选）禁用同步写入加速编译
sudo zfs set sync=disabled data

# 用于编译源码
cd /data
repo init ...

# 设置容量限制
sudo zfs create data/user1
sudo zfs set quota=10G data/user1
sudo zfs list
# 定时进行数据修复
(sudo crontab -l ; echo "0 2 * * 0 /sbin/zpool scrub data") | crontab -

# smart监控
sudo apt install smartmontools

# 测速
fio --name=write --directory=/data --size=1G --rw=write --bs=1M --numjobs=4 --direct=1 --ioengine=libaio

```
## Set user workdir with ACL
```bash
#!/usr/bin/env bash

if ! command -v expect >/dev/null 2>&1; then
  sudo apt install -y expect
fi
if ! command -v setfacl >/dev/null 2>&1; then
  sudo apt install -y acl
fi

admin=admin
username=admin
gerrit_username=username
gerrit_email=username@xxx.com

data_path="/data"
quota_size="3T"
password=$(openssl rand -base64 12)

share_path="$data_path/$username"
smb_conf="/etc/samba/smb.conf"
share_block="\n[$username]\npath = $share_path\navailable = yes\nbrowseable = yes\npublic = yes\nwritable = yes\nvalid users = $username"
ip_address=$(hostname -I | awk '{for(i=1;i<=NF;i++) if ($i !~ /^127\./ && $i !~ /^172\.(1[6-9]|2[0-9]|3[0-1])\./ && $i !~ /^192\.168\./) print $i; exit}')

if ! id "$username" &>/dev/null; then
  echo "🔧 创建系统用户 $username"
  sudo useradd -m -s /bin/bash "$username"
  echo "$username:$password" | sudo chpasswd
else
  echo "ℹ️ 用户 $username 已存在，跳过系统用户创建"
fi
sudo usermod -aG docker $username

echo "Prepare data workdir"
sudo mkdir -p ${data_path}/$username/code
sudo mkdir -p ${data_path}/$username/docker_ssh

echo "Prepare run_gitconfig.sh"
cat <<EOF | sudo tee ${data_path}/$username/code/run_gitconfig.sh
git config --global user.name \"${gerrit_username}\"
git config --global user.email \"${gerrit_email}\"

export REPO_URL='http://10.8.250.193:8888/git-repo.git'

export USE_CCACHE=0
[[ -f /usr/bin/ccache ]] && sudo mv /usr/bin/ccache{,.bak}

git config --global --list
echo \"REPO_URL=\$REPO_URL\"
EOF

echo "Prepare run_docker.sh"

cat <<EOF | sudo tee /home/$username/run_docker.sh
#!/bin/bash
docker pull 10.8.250.192:5000/builder18.04-ccache:latest
mkdir -p /data/$username/.cache
docker run -it --rm -u 1002:1002 \
           --net=host \
            --volume=/$data_path/$username/.cache:/.cache \
            --volume=/etc/localtime:/etc/localtime:ro \
            --volume=/$data_path/$username:/data \
            --volume=/$data_path/$username:/data-ssd \
            --volume=/data-hdd:/data-hdd \
            --volume=/mnt:/mnt \
            --volume=/usr/bin/tig:/usr/bin/tig \
            --volume=/$data_path/$username/docker_ssh:/home/$admin/.ssh \
            10.8.250.192:5000/builder18.04-ccache:latest /bin/bash
EOF
sudo chmod +x /home/$username/run_docker.sh

link_path="/home/$username/ssd"
target_path="$data_path/$username"

# 先检查软链接是否存在且已正确指向目标
if [ -L "$link_path" ]; then
  existing_target=$(readlink "$link_path")
  if [ "$existing_target" = "$target_path" ]; then
    echo "ℹ️ 软链接 $link_path 已正确指向 $target_path，跳过"
  else
    echo "🔄 修复软链接 $link_path -> $target_path"
    sudo unlink "$link_path"
    sudo ln -sf "$target_path" "$link_path"
  fi

# 如果已存在目录或文件（非软链），提示并退出或强制替换
elif [ -e "$link_path" ]; then
  echo "⚠️ 路径 $link_path 已存在（非软链接），请手动检查或确认覆盖"
  # 如果你想强制替换，请取消注释以下两行
  # sudo rm -rf "$link_path"
  # sudo ln -s "$target_path" "$link_path"
else
  echo "🔗 创建软链接 $link_path -> $target_path"
  sudo ln -s "$target_path" "$link_path"
fi

echo "set ACL"
sudo chown -R $admin:$admin /$data_path/$username
sudo setfacl -R -m u:$username:rwx /$data_path/$username/code
sudo setfacl -R -d -m u:$username:rwx /$data_path/$username/code
sudo setfacl -R -x u:$username /$data_path/$username/docker_ssh
sudo setfacl -R -d -x u:$username /$data_path/$username/docker_ssh

if command -v zfs >/dev/null 2>&1; then
    echo "Set quota $data_path/$username"
    zfs_dataset="${data_path/\//}/$username"
    if sudo zfs list "$zfs_dataset" &>/dev/null; then
      echo "ℹ️ ZFS 数据集 $zfs_dataset 已存在，跳过创建"
    else
      echo "🔧 创建 ZFS 数据集 $zfs_dataset"
      sudo zfs create "$zfs_dataset"
    fi
    sudo zfs set quota=$quota_size "$zfs_dataset"
fi

echo "Set samba password"
expect <<EOF
spawn sudo smbpasswd -a $username
expect "New SMB password:"
send "$password\r"
expect "Retype new SMB password:"
send "$password\r"
expect eof
EOF

echo "Set samba share"
# 检查 smb.conf 中是否已有此共享段
if ! grep -q "^\[$username\]" "$smb_conf"; then
  echo -e "$share_block" | sudo tee -a "$smb_conf" >/dev/null
  echo "已添加共享配置到 $smb_conf"
else
  echo "共享 [$username] 已存在，跳过添加"
fi

# 重启 Samba 服务
sudo systemctl restart smbd

echo "✅ 用户 $username 创建成功，Samba 共享目录配置完成：$share_path"
echo "ssh $username@$ip_address"
echo "Password:$password"
```







## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2025-05-23T08:27:03+08:00

---
title: "Create Btrfs"
date: 2025-05-30T17:35:13+08:00
author: v2less
tags: ["linux"]
draft: false
---
## Btrfs
btrfs的一个关键特性：
透明压缩：可以自动压缩文件系统中的数据，减少存储需求。
参考：https://my.oschina.net/emacs_8894804/blog/17529107
## 自动化脚本
```bash
#!/bin/bash
# 自动化部署 RAID5 上的 btrfs 文件系统并启用压缩（zstd）

DEVICE="/dev/sdd"
MOUNT_POINT="/image"
BTRFS_LABEL="image"
FSTAB_BACKUP="/etc/fstab.bak"

echo "===== btrfs 自动部署脚本 ====="

# 1. 检查设备是否存在
if [ ! -b "$DEVICE" ]; then
  echo "错误：设备 $DEVICE 不存在！"
  exit 1
fi

# 2. 安装 btrfs-progs
echo "[+] 安装 btrfs 工具..."
if command -v apt &> /dev/null; then
  sudo apt update && sudo apt install -y btrfs-progs
elif command -v dnf &> /dev/null; then
  sudo dnf install -y btrfs-progs
elif command -v yum &> /dev/null; then
  sudo yum install -y btrfs-progs
else
  echo "不支持的包管理器，请手动安装 btrfs-progs"
  exit 1
fi

# 3. 卸载已挂载设备
if mount | grep -q "$DEVICE"; then
  echo "[!] 设备已挂载，正在卸载..."
  sudo umount "$DEVICE"
fi

# 4. 格式化为 btrfs
echo "[+] 格式化设备为 btrfs..."
sudo mkfs.btrfs -f -L "$BTRFS_LABEL" "$DEVICE"

# 5. 创建挂载目录
echo "[+] 创建挂载目录 $MOUNT_POINT..."
sudo mkdir -p "$MOUNT_POINT"

# 6. 添加 fstab 配置
echo "[+] 配置 /etc/fstab..."
UUID=$(sudo blkid -s UUID -o value "$DEVICE")
MOUNT_OPTIONS="defaults,compress=zstd,autodefrag,noatime"

# 备份原始 fstab
sudo cp /etc/fstab "$FSTAB_BACKUP"

# 移除已有同设备挂载项（防止重复）
sudo sed -i "\|$UUID|d" /etc/fstab

# 添加新行
echo "UUID=$UUID  $MOUNT_POINT  btrfs  $MOUNT_OPTIONS  0 0" | sudo tee -a /etc/fstab

# 7. 挂载
echo "[+] 挂载设备..."
sudo systemctl daemon-reload
sudo mount -a

# 8. 验证
echo "[+] 挂载结果："
mount | grep "$MOUNT_POINT"

echo "[+] 查看空间和压缩信息："
sudo btrfs filesystem df "$MOUNT_POINT"

echo "✅ 部署完成：$DEVICE 已挂载到 $MOUNT_POINT，启用 btrfs + zstd 压缩"
```
## 常用命令
### 查看压缩效果
```bash
sudo apt install btrfs-compsize
sudo compsize /image

Processed 1 file, 2248 regular extents (2248 refs), 0 inline.
Type       Perc     Disk Usage   Uncompressed Referenced
TOTAL       46%      138M         295M         295M
none       100%       19M          19M          19M
zstd        43%      118M         275M         275M
```
### 其他监控命令

```
btrfs scrub status /image
	查看最近 scrub 状态

btrfs filesystem df /image
	查看空间使用

btrfs device stats /image
	查看错误计数

iostat -x /dev/sdX
	查看磁盘 IO 状况

smartctl -a /dev/sdX
	检查硬盘 SMART 状态
```









## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2025-05-30T17:35:13+08:00

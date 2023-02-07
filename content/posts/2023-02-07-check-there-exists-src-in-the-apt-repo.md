---
title: "Check There Exists Src in the Apt Repo"
date: 2023-02-07T11:34:57+08:00
author: v2less
tags: ["linux"]
draft: false
---

## 如何确定apt仓库中没有对应的源码？

```bash
#!/bin/bash
apt update
workdir=$(pwd)
rm -rf out
mkdir out
i=1
degress=12
PKG=${1:-installed}
if [ "installed" == $PKG ]; then
    dpkg-query -W --showformat='${Package} ${Version}\n' > pkg.list
elif [ "all" == $PKG ]; then
    apt-cache search . | sort -d | tee pkg.list
else
    echo "bash $0 installed | all"
    exit 1
fi

cat << 'EOF' | tee /usr/bin/getnosrc
list=$(realpath $1)
PKG=$2
echo $list
workdir=$(dirname $list)
tmpdir=$(mktemp -d -p $workdir)
cd $tmpdir || exit 1
get_info() {
    name=$1
    if [ "installed" == $PKG ]; then
        version=$2
        apt-cache madison ${name} | grep "Packages$" | grep "$version" | head -n1 | tee ${name}.Packages
    elif [ "all" == $PKG ]; then
        apt-cache madison ${name} | grep "Packages$" | tee ${name}.Packages
    fi
    apt-cache madison ${name} | grep "Sources$" | tee ${name}.Sources
    src_name=$(apt-cache madison ${name} | grep "Sources$" | head -n1 | awk -F "|" '{print $1}')
    while read -r line; do
        if [ "all" == $PKG ]; then
            version=$(echo $line | awk -F '|' '{print $2}' | sed 's/^[ \t]*//' | sed 's/[ \t]*$//')
        fi
        if ! grep -q ${version} ${name}.Sources; then
            if ! apt source ${name}=${version}; then
                echo "${line}" | tee -a ${workdir}/no-source.list.tmp
                if [ -z $src_name ]; then
                    echo "NoSRC" $name ${version} | tee -a ${workdir}/no-source-src-name.list.tmp
                else
                    echo ${src_name} ${version} | tee -a ${workdir}/no-source-src-name.list.tmp
                fi
            fi
        fi
    done < ${name}.Packages
    rm ${name}.Packages ${name}.Sources
}

while read -r pkg; do
    pkgname=$(echo $pkg | awk '{print $1}')
    if [ "installed" == $PKG ]; then
        version=$(echo $pkg | awk '{print $2}')
        get_info $pkgname $version
    elif [ "all" == $PKG ]; then
        get_info $pkgname
    fi
done < $list
cd $workdir
rm -rf $tmpdir
rm $list
EOF
chmod +x /usr/bin/getnosrc

cp pkg.list out/
pushd out
split -l 100 pkg.list pkg
rm pkg.list
read -ra lists <<< "pkg*"
for list in ${lists[*]}; do
    i=$((i + 1))
    /usr/bin/getnosrc $list $PKG &
    [ $(expr $i % $degress) -eq 0 ] && wait
done
wait
cat no-source-src-name.list.tmp | sort -u | tee no-source-src-name.list
cat no-source.list.tmp | sort -u | tee no-source.list
rm no-source.list.tmp no-source-src-name.list.tmp
popd

```





## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2023-02-07T11:34:57+08:00

---
title: "Bash Python Cpp Static Check"
date: 2023-02-07T11:46:29+08:00
author: v2less
tags: ["linux"]
draft: false
---

# Bash/Python/CPP 代码格式化及静态分析工具

包括 shfmt、shellcheck、black 、pylint和cppcheck。

## 选取标准

* 面向命令行，可自动化
* 在社区达成了一定共识，具有广泛推荐基础
* 成熟且稳定
* 开发和维护都很活跃

## 工具安装脚本

```bash
function get_latest_release() {
    curl --silent "https://api.github.com/repos/$1/releases/latest" | grep -Po '"tag_name":[ ]*"\K.*?(?=")'
}
function install_cppcheck() {
    sudo apt update
    sudo apt install -y cppcheck
}
function install_check_and_format() {
    # python3
    if [ -f /usr/bin/python ]; then
        sudo rm -f /usr/bin/python
    fi
    if [ -f /usr/bin/python3 ] && [ ! -f /usr/bin/python ]; then
        sudo ln -s /usr/bin/python3 /usr/bin/python
    fi
    #black pylint
    pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple/
    pip3 install -i https://mirrors.ustc.edu.cn/pypi/web/simple pip -U
    pip3 install black pylint lastversion
    #install_shell_check
    ARCH=$(uname -m)
    while [ -z "$shellcheck_version" ]; do
        shellcheck_version=$(get_latest_release "koalaman/shellcheck")
    done
    wget -O - https://github.com/koalaman/shellcheck/releases/download/"$shellcheck_version"/shellcheck-"$shellcheck_version".linux."$ARCH".tar.xz | tar -xJf -
    chmod +x shellcheck-"$shellcheck_version"/shellcheck || true
    sudo mv shellcheck-"$shellcheck_version"/shellcheck /usr/bin/ || true
    rm -rf shellcheck-"$shellcheck_version"
    # shfmt
    case $ARCH in
        x86_64)
            arch=amd64
            ;;
        aarch64)
            arch=arm
            ;;
        mips64)
            arch=mips64el
            ;;
        *) ;;
    esac
    while [ -z "$shfmt_version" ]; do
        shfmt_version=$(get_latest_release "mvdan/sh")
    done
    wget https://github.com/mvdan/sh/releases/download/"$shfmt_version"/shfmt_"$shfmt_version"_linux_"$arch"
    sleep 1
    chmod +x shfmt_"$shfmt_version"_linux_"$arch" || exit
    sudo mv shfmt_"$shfmt_version"_linux_"$arch" /usr/bin/shfmt || exit
}
install_check_and_format
install_cppcheck
```

## Bash

### shfmt：格式化 Shell 脚本 <https://github.com/mvdan/sh>

Shell 解析器、格式化以及解释器，支持 POSIX Shell、Bash 和 mksh。

* 安装：从 <https://github.com/mvdan/sh/releases> 下载对应 CPU 架构的二进制包。
* 用法：shfmt -i 4 -bn -ci -sr -kp -l -w -d .
  * =-i 4= 4 空格缩进
  * =-bn= 允许双目操作符另起一行
  * =-ci= switch 语句也缩进
  * =-sr= 重定向操作符后面保持空格
  * =-kp= 使列对齐
  * =-l= 列出格式化的文件
  * =-w= 将结果写入文件
  * =-d= 显示包含 diff 差异的错误
  * =.= 递归格式化当前目录中的脚本
* 编辑`$HOME/.bashrc` or `$HOME/.zshrc`

```bash
alias shfmt="shfmt -i 4 -bn -ci -sr -kp -l -w -d"
```

* vscode 插件：shell-format
  * 配置：Ctrl+shift+p 输入 setting,选择 user setting,查找 shfmt,编辑配置文件：`"shellformat.flag": "-i 4 -bn -ci -sr -kp"`，修改后手动确认后保存。
  * 使用方法：右键选择 Format document 或者 Ctrl+shift+p 输入 Format document

### shellcheck：Shell 脚本静态分析工具 <https://github.com/koalaman/shellcheck>

针对 bash/sh Shell 脚本给出警告和建议，它能指出语法问题、语义问题以及比较隐含的错误。

* 安装：apt install shellcheck
* 用法：shellcheck -s bash *.sh
  * =-s= 指定使用 bash
  * =*.sh= 检查 .sh 结尾的所有 Shell 脚本
* 编辑`$HOME/.bashrc` or `$HOME/.zshrc`

```bash
alias shellcheck="shellcheck -s bash -x"
```

* 错误对照： [https://github.com/koalaman/shellcheck/wiki](https://github.com/koalaman/shellcheck/wiki)
* 对于检查出来的错误，经确认后是检查工具本身不完美或者你实在不知道怎么改，可以屏蔽对应的检查，在shebang后面加入一行注释行，例如：

```plain
# shellcheck disable=SC2046,SC2086
```

* vscode 插件：shellcheck

## Python

### black：格式化 Python 代码 <https://github.com/psf/black>

完全遵循 Python 官方推荐的 PEP8 格式规范，避免为格式进行无谓争论，省时省力。

* 安装：apt install black or pip3 install black
* 用法：black *.py
  * =*.py= 格式化 .py 结尾的所有 Python 脚本
* vscode:安装 python 插件，并在 setting 搜索并启用“format on save”，搜索 “python formatting provider” ,选择 “black”。
  * 使用方法：Ctrl+s 保存时自动格式化

### pylint：Python 代码静态分析工具 <https://www.pylint.org>

支持代码标准、错误检测以及重构辅助，同时也能创建 UML 图形，且完全可定制。

* 安装：apt install pylint or pip3 install pylint
* 用法：pylint *.py
  * =*.py= 检查 .py 结尾的所有 Python 脚本
* vscode:安装pylint插件

## markdown

### Prettier

vscode markdown 格式化插件,支持 js,css,html 等。

### markdownlint

vscode markdown 语法检查工具。

## cppcheck

* 安装： sudo apt install cppcheck
* 用法

```bash
cppcheck --enable=all --xml-version=2 src/ 2> cppcheck.xml
```

* 转换为html报告

```plain
mkdir -p report
cppcheck-htmlreport --file=cppcheck.xml --source-dir=src --report-dir=report
```

详细参考：[https://wenbo1188.github.io/2017/07/23/cppcheck-manual-chinese/](https://wenbo1188.github.io/2017/07/23/cppcheck-manual-chinese)


## VS使用步骤

确保在 代码提交之前 执行上述工具。

* 执行代码格式化工具：Shell -> shfmt，Python -> black
  vscode:Shell -> 右键 format document, Python -> 保存时格式化。

* 执行静态代码分析工具：Shell -> shellcheck，Python -> pylint
  vscode：Ctrl+Shift+M 打开 Problems 控制台

* 根据工具分析结果纠正代码
* 确认无错误后提交代码

## ShellCheck 常见可忽略错误

* `source common`
  `Not following: common was not specified as input (see shellcheck -x).`

* `source "${CONFIG}"`
  `Can't follow non-constant source. Use a directive to specify location.`

* echo
  echo 后的变量不需要加双引号。

* For 循环
  for 循环的 in 变量不需要加双引号。

```bash
for pkg in ${DEFAULT_PUBLIC_PACKAGES}; do
        echo "${pkg}" | sudo tee -a "${CHROOT_PATH}"/root/packages.list.tmp
done
```

* apt 相关
* apt 相关，包括安装、缓存 deb 包等，不加双引号，否则多个软件包名称会解析为一个整体的字符串。
* dpkg-qurey 选项的参数用单引号，不能用双引号

```bash
dpkg-qurey -W --showformat='${Package}\\t${Status}\\n'
```

## java static check
### 安装docker
```bash
bash <(wget -q -O - https://get.docker.com) --mirror Aliyun
#or
curl -sSL https://get.daocloud.io/docker | sh
```
### 拉取镜像
```bash
docker pull freelxs/java-static-check:latest

```
### 使用checkstyle进行java代码格式规范检查
>CheckStyle 是一种开发工具，可帮助程序员编写符合编码标准的 Java 代码。它使检查 Java 代码的过程自动化，从而使开发者免于完成这项无聊（但重要）的任务。这使得它非常适合想要强制执行编码标准的项目。

>CheckStyle 可以检查源代码的许多方面。它可以发现类设计问题、方法设计问题。它还能够检查代码布局和格式问题。

参考文档：https://checkstyle.sourceforge.io/google_style.html
```bash
cd 到源码目录
docker run --rm -it -w /work -v $(pwd):/work freelxs/java-static-check:latest checktyle -c /opt/rules/google_checks.xml -f xml -o google-checkstyle-report.xml ./*
```
检查结果是：google-checkstyle-report.xml
java项目庞大时，开始的检查文件一般较大，可以使用下面的方法打开：
```bash
xmllint --format largefile.xml | less
```
或者使用图形工具：[glogg](https://glogg.bonnefon.org/download.html)

### 使用PMD进行java代码检查
> 对于PMD名称含义，有个有趣的现象，PMD不存在一个准确的名称，在官网上你可以发现很有有趣的名称 ，比如：Pretty Much Done，Project Meets Deadline等。PMD是一款程序代码检查工具（可以支持多种语言，以Java为例），通过静态分析Java源文件来获知代码错误，也就是说在不运行不编译Java程序的情况下直接扫描Java源文件，报告错误 。该软件功能强大，扫描效率高，是Java程序员debug的好帮手。它附带了许多可以直接使用的规则，利用这些规则可以找出Java源程序的许多问题，比如：

>可能的 Bugs：检查潜在代码错误，如空 try/catch/finally/switch 语句
未使用代码（Dead code）：检查未使用的变量，参数，方法
复杂的表达式：检查不必要的 if 语句，可被 while 替代的 for 循环
重复的代码：检查重复的代码
循环体创建新对象：检查在循环体内实例化新对象
资源关闭：检查 Connect，Result，Statement 等资源使用之后是否被关闭掉
用户还可以自己定义规则，检查Java代码是否符合某些特定的编码规范。例如，你可以编写一个规则，要求PMD找出所有创建Thread对象的操作。


```bash
cd 到源码目录
docker run --rm -it -w /work -v $(pwd):/work freelxs/java-static-check:latest pmd -d ./* -l java -f xml -r pmd-report.xml --rulesets /opt/rules/quickstart.xml

```


## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2023-02-07T11:46:29+08:00

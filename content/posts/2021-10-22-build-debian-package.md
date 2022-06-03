---
title: "Build Debian Package"
date: 2021-10-22T17:18:16+08:00
author: v2less
tags: ["linux"]
draft: false
---

# Debian 软件包制作

参考： https://amefs.net/archives/1953.html

下面分析 debian 目录下其他几个常见的可选文件，然后简单的介绍一下使用 debuild 构建源码包、二进制包的操作。

## debian 目录下的其他文件：

完整的介绍可以参考[此处](https://www.debian.org/doc/manuals/maint-guide/dother.zh-cn.html)，我将在下文详细说明以下几个文件`install`、`source/format`、`patches/*`。

### install

如果你的软件包需要那些标准的 `make install` 没有安装的文件，你可以把文件名和目标路径写入 **install** 文件，它们将被 dh_install 安装。

这个 `install` 文件每行安装一份文件，格式上先是相对于编译目录的文件路径，然后是一个空格，接下来是相对于安装目录的目标目录。例如，假设某个二进制文件 `src/bar`没有被默认安装，则应让 `install` 呈现成这样：

```
src/bar usr/bin
```

这意味着安装这个软件包时，将有一个二进制文件 `/usr/bin/bar`。

当相对路径保持不变的时候，这种 install 文件可以只包含源路径，而不包含空格后的内容。这将会把 debian 文件夹中生成的源码按照原有的结构拷贝。例如 xmlrpc-c 的 `libxmlrpc-core-c3-dev.install`：

```bash
tools/xmlrpc/xmlrpc usr/bin
tools/xmlrpc/xmlrpc.html usr/share/doc/libxmlrpc-core-c3-dev
usr/bin/xmlrpc-c-config
usr/include/xmlrpc-c/*.h
usr/include/xmlrpc.h
usr/include/xmlrpc_abyss.h
usr/include/xmlrpc_cgi.h
usr/include/xmlrpc_client.h
usr/include/xmlrpc_server.h
usr/include/xmlrpc_server_w32httpsys.h
usr/lib/*/libxmlrpc.a
usr/lib/*/libxmlrpc.so
usr/lib/*/libxmlrpc_abyss.a
usr/lib/*/libxmlrpc_abyss.so
usr/lib/*/libxmlrpc_client.a
usr/lib/*/libxmlrpc_client.so
usr/lib/*/libxmlrpc_server.a
usr/lib/*/libxmlrpc_server.so
usr/lib/*/libxmlrpc_server_abyss.a
usr/lib/*/libxmlrpc_server_abyss.so
usr/lib/*/libxmlrpc_server_cgi.a
usr/lib/*/libxmlrpc_server_cgi.so
usr/lib/*/libxmlrpc_util.a
usr/lib/*/libxmlrpc_util.so
usr/lib/*/libxmlrpc_xmlparse.a
usr/lib/*/libxmlrpc_xmlparse.so
usr/lib/*/libxmlrpc_xmltok.a
usr/lib/*/libxmlrpc_xmltok.so
```

可以看到第 1 行的内容是将 xmlrpc 的 cli 以及说明文件 `xmlrpc.html` 放入 `usr/bin` 目录，这将会方便用户调用这个指令。而后续指令由于文件结构与安装目标的文件结构一致，因此省略后面的安装目标目录描述。xmlrpc-c 的 **install** 文件将这个库分割成 `libxmlrpc-c++8v5` `libxmlrpc-c++8-dev` `libxmlrpc-core-c3` `libxmlrpc-core-c3-dev` 和 `xmlrpc-api-utils` 这几个包也在 **control** 文件中被定义过：

```bash
Package: libxmlrpc-c++8-dev
Section: libdevel
Architecture: any
Depends:
 libc6-dev,
 libxmlrpc-c++8v5 (= ${binary:Version}),
 libxmlrpc-core-c3-dev (= ${binary:Version}),
 ${misc:Depends},
Suggests:
 xmlrpc-api-utils,
Conflicts:
 libxmlrpc-c++4-dev,
Breaks:
 libxmlrpc-core-c3-dev (<< 1.33.14-5),
Replaces:
 libxmlrpc-core-c3-dev (<< 1.33.14-5),
...
Package: libxmlrpc-c++8v5
...
Package: libxmlrpc-core-c3-dev
Section: libdevel
...
Package: libxmlrpc-core-c3
...
Package: xmlrpc-api-utils
Section: devel
```

它们分别有着自己的依赖关系，并且在 control 文件中被完整描述。

### source/format

这个文件仅有一行内容，这个内容为 `3.0 (native)` 或者 `3.0 (quilt)`。一般来说我们编译的是一些外来的软件包，因此选择 `3.0 (quilt)`。这里其实就是使用 `quilt` 在解压源代码包时自动应用位于 `debian/patches` 下的补丁，而在你执行完打包作业后，这些补丁将会被自动撤销，不会影响源码本身的完整性。

### patches/*

因为很多源码并不能直接用于生成二进制包，或者有一些功能需要通过一定的补丁才能完成，因此这里存在一个补丁的自动应用机制。这个补丁就是使用 `diff -u` 生成的差分文件，具体生成的方式参考[此处](https://www.ibm.com/developerworks/cn/linux/l-diffp/index.html)。这些补丁将会在打包时随着整个 **debian** 目录 被压缩成 **debian.tar.gz** 。由于 **dpkg-source** 命令可以处理 quilt 格式的补丁数据，而不需要 quilt 软件包，因此不需要在 Build-Depends 中添加 quilt。

`quilt` 对源码的修改维护将被应用到 **-p1** 级别的目录中，因此在自己制作补丁和接受外来补丁的的时候特别要注意文件夹的层级关系。另外，还有一个相关的文件叫做 **debian/patches/series**。 它记录了打补丁的顺序。如果是手写的这个文件，那就需要注意最后的空行必须被保留。

这些补丁一般来源于 debian tracker，ppa 源码包。如果需要自己制作这些补丁，那么一般比较简单的方法是直接使用 diff 工具生成，如果考虑到要符合 debian 规范的话，可以参考[此处](https://www.debian.org/doc/manuals/maint-guide/modify.zh-cn.html) 配置 dquilt 并修改。当我们有一些外来的补丁时也可以通过 `dquilt` 导入：

```bash
$ dpkg-source -x gentoo_0.9.12.dsc
$ cd gentoo-0.9.12
$ dquilt import ../foo.patch
$ dquilt push
$ dquilt refresh
$ dquilt header -e
... describe patch
```

至此，常用的文件就已经介绍完了，接下来的内容就是如何构建源码

------

## 使用 debuild 构建源码：

`debuild` 命令将会进一步自动化 `dpkg-buildpackage` 的构建过程，并且自动使用 `lintian` 命令对生成的文件进行检查以确保符合标准。因此我们看一下手动执行 `dpkg-buildpackage` 和 `lintian` 的流程。

在这里我们以 rclone-browser 为例，它在源码中已经提供了相应的 debian 文件夹，我们要做的只是对这份源码打上几个补丁以适配新版本的 rclone，然后编译。此处略去打补丁的具体操作，我们直接开始构建源码。

### dpkg-buildpackage

在开始构建之前，首先要确保系统中已经安装了：

- `build-essential` 软件包；
- 列于 `Build-Depends` 域的软件包；
- 列于 `Build-Depends-indep` 域的软件包。

然后切换到源代码目录下，执行如下命令：

```bash
$ dpkg-buildpackage -us -uc
```

其中`us` 是 unsigned-source 的缩写，也就是说在生成源码包的时候不会对源码包进行签名。一般来说不上传到 ppa 源的这些包完全可以不签名。`uc` 是 unsigned-changes 的意思，也是同理。特别是如果还没有配置好 gpg key 的时候是没有办法进行签名操作的。后续也可以通过 `debsign` 手动对这些包进行签名。

在执行这个命令的时候，**dpkg-buildpackage** 将会执行如下操作：

1. 设置构建环境的各种变量，这些变量已经有了默认值，可以通过设置来覆盖。
2. 它会检查构建依赖以确保满足 Dependence 写明的关系（可以通过 `-d` 或者 `--no-check-builddeps`）禁用检查。
3. 通常来说这里会运行 `fakeroot debian / rules clean` 对构建树进行清理（可以通过 `-nc` 或者 `--no-pre-clean`）禁用。
4. 这一步将会调用 `dpkg-source -b` 生成源码包和dsc文件，也可以单独允许这一步生成所需文件。
5. 这一步运行 `debian / rules build-target` 然后运行`fakeroot debian/rules binary-target`。
6. 这将会调用 **dpkg-genbuildinfo** 生成 **.buildinfo** 文件。
7. 调用 **dpkg-genchanges** 生成 **.change** 文件。
8. 如果启用了 `-tc` 或者 `--post-clean` 那么将会运行 `fakeroot debian / rules clean` 清理文件。
9. 执行 `dpkg-source --after-build` 。
10. 如果在环境变量 `DEB_CHECK_COMMAND` 指定了命令，或者使用了 `--check-command` ，则使用指定的包检查器检查 **.changes** 文件.
11. 如果没有指定 `uc`、`us`、`ui` 那么就会使用 **gpg2** 或者 **gpg** 签名，在这里则不会执行。
12. 执行结束。

当以上步骤都正确完成后，你就可以在上一层目录看到这样的一些文件：

```bash
../
├── rclone-browser-1.2
├── rclone-browser_1.2_amd64.buildinfo
├── rclone-browser_1.2_amd64.changes
├── rclone-browser_1.2_amd64.deb
├── rclone-browser_1.2.debian.tar.xz
├── rclone-browser_1.2.dsc
├── rclone-browser_1.2.orig.tar.gz
├── rclone-browser-1.2.tar.gz
└── rclone-browser-dbgsym_1.2_amd64.ddeb
```

- `rclone-browser_1.2_amd64.buildinfo` 上文通过 **dpkg-genbuildinfo** 生成的报告，包含了包的依赖，文件指纹等信息。
- `rclone-browser_1.2_amd64.changes` 上文通过 **dpkg-genchanges** 生成的报告，包括了二进制包的修改信息，以及文件指纹。
- `rclone-browser_1.2_amd64.deb` 构建出来的二进制包。
- `rclone-browser_1.2.debian.tar.xz` 对 debian 文件夹中文件的打包。
- `rclone-browser_1.2.dsc` debian 的源码包控制文件。
- `rclone-browser_1.2.orig.tar.gz` 源码包。
- `rclone-browser-dbgsym_1.2_amd64.ddeb` **debug symbols** 也就是说用于调试的 debug 包。

**dpkg-buildpackage** 的工作到这里就结束了。

### lintian

**Lintian** 是一个辅助工具，与 Debian 软件包管理系统 dpkg 结合使用。能检查 Debian 软件包是否存在不符合 debian 规范的错误。

以下是一个例子：

```bash
$ lintian -i -I --show-overrides ../rclone-browser_1.2_amd64.changes | grep -E 'E:|W:|I:'
E: rclone-browser changes: bad-distribution-in-changes-file unstable
W: rclone-browser source: non-native-package-with-native-version
I: rclone-browser source: quilt-patch-missing-description adjust1.4x.patch
W: rclone-browser source: syntax-error-in-dep5-copyright line 10: Continuation line outside a paragraph (maybe line 9 should be " .").
I: rclone-browser source: testsuite-autopkgtest-missing
I: rclone-browser source: debian-watch-file-is-missing
I: rclone-browser: spelling-error-in-binary usr/bin/rclone-browser transfering transferring
E: rclone-browser: extended-description-is-empty
W: rclone-browser: binary-without-manpage usr/bin/rclone-browser
I: rclone-browser: desktop-entry-lacks-keywords-entry usr/share/applications/rclone-browser.desktop
```

- `E:` 代表错误：确定违反了 Debian Policy 或是一个肯定的打包错误。
- `W:` 代表警告：可能违反了 Debian Policy 或是一个可能的打包错误。
- `I:` 代表信息：对于特定打包类别的信息。
- `N:` 代表注释：帮助你调试的详细信息。
- `O:` 代表已覆盖：一个被 `lintian-overrides` 文件覆盖的信息，但由于使用 `--show-overrides` 选项而显示。

我在使用 lintian  检查的时候，使用 grep 过滤了出了一些重要信息，一般来说 Error 和 Warning 级别的提示是需要小心的。含有 Error  级别错误的包是不会被 debian 或者 launchpad ppa  源接受的，需要修正。在这些报错中你完全可以发现各种资源文件的丢失，描述的错误等。对于 Warning  级别的错误通常应该检查警告是否有意义，如果没有意义，那么可以使用 **lintian-overrides** 覆盖这个报警，覆盖的方法可以参考 lintian 的 [manpage](https://lintian.debian.org/manual/index.html)。

到这里，一个完整的 deb 二进制包以及它的源码包就制作完成了。



## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2021-10-22T17:18:16+08:00

---
title: "How to Use Pbuider"
author: v2less
tags: linux
date: 2021-08-17T13:32:49+08:00
draft: false
---

[TOC]
# How to use pbuilder
## 打包基础知识

要打包，首先应该了解其基本原理，这是在不同发行版甚至不同操作系统中都适用的知识。
 说起打包，不可避免地会让人想到编译、链接、安装、复制文件等等关键词。毕竟说到底打包的目的是为了让用户更加方便可靠地获得一个软件，其目的为安装软件，那么其手段也和手工从源代码开始安装软件的做法大同小异。

### 手工安装软件包的流程

如果要手工从源代码开始将这个软件安装到系统中，常见的步骤包括：

1. 获取源代码：一般是从互联网上下载一个压缩包，或者从其它途径（如光盘等）得到。
2. 构建之前的准备：要从源代码得到二进制的可执行程序，一般需要一些工具进行辅助，典型的工具例如编译器、连接器等等。这些工具需要事先准备好，安装在系统中。
3. 进行构建：使用软件原作者提供的构建系统进行构建，编译、链接等环节都在这一步完成。更宽泛地说，这一步从原始的源代码得到我们需要的格式的文件（例如二进制可执行程序）。
4. 测试：如果软件原作者提供了某些测试工具，此时可以使用测试工具对刚刚构建完成的成果进行检验。
5. 安装：这一步通常比较简单，简单到只是复制粘贴而已。我们把构建出来的成果复制放到系统合适的位置，那么安装就完成了。

### 打包者参与时安装软件包的流程

说完了手工安装，我们再考虑打包者存在的场景。此时，我们希望所有的脏活累活都是由~~不知道在世界上哪个地方的~~打包者干完，作为用户，只需要一条命令（或者点一下鼠标）就能好好地安装一个软件包。一键安装，就是这么舒心。我们将原有手工安装的步骤区分成打包者的工作和用户的工作两部分：

#### 打包者的工作

1. 获取源代码：打包者通常需要通过可靠的途径获取源代码，避免源代码的错误与不可靠。理想的情况是软件原作者提供源代码包的散列值进行验证，或者对源代码包进行数字签名。另外，直接将源代码仓库复制一份（例如用Git管理的仓库）也是很理想的方式。
2. 处理源代码：打包者需要对获取到的源代码进行处理，具体包括检查源文件的版权信息、构建系统的情况，并根据具体情景编写打包用的指令和信息。如果发现了源代码中的问题，打包者还需要向上游进行反馈，并考虑在构建时添加这个软件包特有的补丁。这通常是打包者耗费心血最多的地方。
3. 尝试构建软件包：打包者使用刚才编写的指令进行构建并打包。构建已经在上面说明，而打包则是将构建的成果按照一定的关系进行组织、压缩并放入一个特定格式的文件中的过程。如果出错，还需要返回上一步重新调整。
4. 检查软件包：即便软件包成功构建，打包者也需要对其进行检查，确保质量可靠、符合要求。有问题则需要返工重新调整。
5. 发布软件包：打包者在确定软件包适合发布后，会通过某种途径将其向外界发布出去，供用户使用。这种发布途径可能有很多，但常见的是所谓“发行版”提供的集中式发布渠道。
6. 跟踪并修复软件缺陷：即便完成了打包，打包者的工作也没有完成。如果接到了用户的反馈认为这个软件包有问题，打包者还需要进行跟踪调查，检查问题的发生原因，并根据实际情况进行处理，或是向原作者反馈，或是调整自己的打包方式和指令。
7. 跟踪并发布新版本：软件的原作者可能会不时地发布这个软件的新版本。打包者需要跟踪开发流程，并在新版本发布时检查变化，为新版本再次打包并发布。

可以看出，打包者的负担大大加重了。因为打包者是用户和软件开发者之间的桥梁，需要担负沟通、检查、质检等多种任务。

#### 用户的工作

1. 获取软件包：用户使用某些特定的途径获取到打包者的软件包。通常这种途径由特定的“发行版”集中提供。
2. 安装软件包：用户使用安装工具把软件包安装到系统中。

用户的负担大大减轻了，一切都是现成的，只需要“拿来”“用”就行。

### Debian采用的打包基础：Makefile

由于打包的前提条件是一个编译好的软件，所以不得不提一下编译。通常来说，简单的程序源码会带有 `Makefile`，我们可以很容易的直接输入 `make` 来进行编译。略微复杂一点的现代化程序还可能会使用一个叫做 `configure` 的脚本来生成当前系统所需的 `Makefile`。类似的还有 `cmake` 使用的 `CMakeLists.txt`，`cmake` 会直接使用这个文本文件来生成相应的 `Makefile`。另外还有比较常见的工具 `Autotools` ，它使用`configure.ac`，`Makefile.am` 和 `Makefile.in`等特征文件来识别使用 `Autotools` 作为编译系统的源代码。在使用 `Autotools` 生成 `configure` 后，同样运行`configure`得到特定的 `Makefile`。由此可见，在常见的编译系统中，一切的基石就是`Makefile`。

正式开始介绍打包之前，我们必须提及构建系统的基石：`Makefile`。我们来看看维基百科对`Makefile`是如何介绍的：

> A makefile is a file containing a set of directives used with the make build automation tool.

翻译过来，就是说这个文件包含了一系列指导`make`这个构建自动化工具完成其工作的命令。它使用目标（target）组织起工作流程，即为了达成某个目标需要哪些源文件、需要哪些事先完成的目标、完成这个目标需要执行哪些指令，等等。Debian 利用了`Makefile`作为构建的中心，整个构建打包流程就是在执行`Makefile`的过程中完成的。这是一个特殊的文件，其名称为`debian/rules`。
 有一个需要注意的地方：一切`Makefile`中的指令都以一个**制表符**起始。千万不要用空格替换，会出错的。
 关于`Makefile`的普遍编写方式，请参阅其它资料，例如陈皓的经典教程《跟我一起写Makefile》（[原版PDF副本](http://scc.qibebt.cas.cn/docs/linux/base/跟我一起写Makefile-陈皓.pdf)、[重制版](https://github.com/seisman/how-to-write-makefile)）。

>```bash
>git clone https://github.com/seisman/how-to-write-makefile.git
>cd how-to-write-make-file
>pip install -r requirements.txt
>sudo apt install latex-cjk-all 
>make latexpdf
>zathura build/latex/Makefile.pdf&
>```
>
>[tan ctex](https://ctan.org/pkg/ctex) 网站下载 `ctex.zip`，解压到 `/usr/share/texlive/texmf-dist/tex/latex/`

------

## 为Debian打包的基础知识

### Deb包

Debian 的软件包以 .deb 作为后缀，它是一个[Unix](https://zh.wikipedia.org/wiki/Unix)[ar](https://zh.wikipedia.org/wiki/Ar)的标准归档，将包文件信息以及包内容，经过[gzip](https://zh.wikipedia.org/wiki/Gzip)和[tar](https://zh.wikipedia.org/wiki/Tar_(计算机科学))打包而成。通常来说这个包里面含有 `data.tar.*` 实际的软件内容; `control.tar.gz` 记录了包名称，版本号，维护者，需要什么依赖，与什么冲突的信息; `debian-binary` deb 格式版本号码.

对于我们平时在 Debian/Ubuntu 平台编译的软件来说，通常只会通过 make 之类的编译指令生成 deb 包中 `data.tar.*` 的内容，即使我们使用 `checkinstall` 之类的软件打包成 deb 包， 也不会自动填充 `control.tar.gz`，这就会导致这个生成的 deb 包并不是适合分发的形式。这个包在使用例如 dpkg 包管理器的时候，既不会检查依赖，冲突，也不能正确显示软件包的具体信息 (例如 dpkg -l， 你会看到这种软件包上面写着 `Package created with checkinstall 1.6.2` 而不是相应的软件描述)。

我们已经了解到，Debian 决定采用一个`Makefile`文件作为构建的核心，并围绕着这个文件开展工作。下面，我们转向更实际的例子，阐述究竟应该如何完成整个构建工作。

### 源码包的工作目标：`.orig.tar.xz, .debian.tar.xz, .dsc`

在深入具体过程之前，我们不妨先了解一下打包工作的成果应该是什么。正如标题所述，Debian 开发者辛辛苦苦工作的目标是得到这三个文件。广义上讲，它们构成了 Debian 的**源码包**。即，获取了这三个文件，配合工具链，任何一个人都可以从源代码按照标准化的流程进行构建并得到二进制软件包（即`.deb`包）。要深入了解这三个文件的内容，您可以自行查看，或者在下文中所述的 Debian 新维护人员手册中也有对应的章节。
 我们知道了工作目标的外在形式，当然我们也能够认识到工作目标的内在含义。无外乎下面几个：

- 软件开发者（上游）提供的软件源代码。
- 目标软件包的信息。信息包括维护者、依赖关系、版本号、修订历史、等等。
- 构建软件包的指令。大部分在`debian/rules`文件中给出。

在此之后我们仍然需要了解的是，为了得到目标，我们手头有哪些东西可以使用：

- 软件开发者（上游）提供的软件源代码。这毫无疑问。
- 软件开发者提供的构建说明。如果有的话，这将成为你打包工作中的一个重要参考。
- 整个 Debian 为你提供的开发工具。这是打包的重要武器。
- 互联网上的资料，尤其是 Debian 的文档。
- 你脑海中的知识与创造力。

从后者得到前者，便是打包者的工作。

### 打包指令的存储位置：`debian`目录

如上所述，我们需要给出将软件包的各种信息和构建指令。显然，我们需要按照一定的格式给出这些信息和指令。并且将它们和源代码放在一起。简而言之，Debian 决定将所有打包相关的指令和信息分别写入不同的文件中，但这些文件都在一个统一的目录下：`debian/`目录。这个`debian`目录应当在获取到上游提供的源代码后被放置在源代码顶级目录下面。这样的目录关系在构建时不会改变。如果上游已经提供了一个叫做`debian`的目录，那么在打包时会强行删去原目录并将打包使用的目录覆盖，所以不用过于担心。

### 不使用Git的经典教程：Debian 新维护人员手册

无论是想要从零开始学习打包，还是想在 Debian 里维护一个软件包，或者是想成为 Debian 开发者的一员，总有一个必读的文章：[Debian 新维护人员手册](https://www.debian.org/doc/manuals/maint-guide/)。这个手册阐述了基本的打包流程以及经典的构建方式。我们在这里说“经典”，是因为它使用了最基础的工具链进行操作，没有与Git这种代码版本管理工具做整合。即便您打算使用高级的工具来减轻负担（如，使用`git-buildpackage`工具），通读一遍手册全文仍然十分重要。在之后的文字中，我会假定您至少通读了这个手册的全文。

#### 一切的基石：`debian/rules`文件

现在您已经知晓，`debian/rules`文件就是我们前文中所说的那个`Makefile`文件。毫无疑问，这个文件是构建软件包的基石，也是黑科技最容易出现的地方。

需要牢记的是，Debian 打包（构建）的不同环节将会调用这个`Makefile`的不同目标（target）。上文提到的新维护人员手册中的[4.4.1节](https://www.debian.org/doc/manuals/maint-guide/dreq.zh-cn.html#rules)给出了这个`Makefile`**必须实现**的目标。上古时期（debhelper 不存在的时候）这些目标是需要打包者逐个编写的。现在有了`debhelper`，一切都使用黑科技手段大大简化。请见下一节。

#### 历史的印记：`debhelper`

传统上基于`Makefile`目标的打包实在是太累人了。如果不使用任何帮助工具，那么自己需要实现上一节提到的所有目标（target），这便不可避免地要求打包者熟悉上游软件原作者使用的各类构建工具（`Autotools/Autoconf/Automake`、`CMake`、`waf`、`ninja`、纯手写的`Makefile`、`Python`的`setuptools`，还有茫茫多的不同语言的特定构建工具……），而且要求打包者自己将构建好的文件复制组织成软件包的结构，这不可避免地要求打包者写无数行的`install ...`命令（进行文件复制），完全是体力劳动、重复劳动。这样不好。

我们希望能够简化打包流程，让一套帮助工具辅助进行打包。这样的工具可以具有以下特点：

1. 自动处理各类构建工具：`automake/cmake/makefile`，自动识别，不需要打包者重复劳动。
2. 从**命令式**的一条条指令向**声明式**的说明性文字演变。可以的话，只告诉打包工具需要做什么，具体怎么做让打包工具自己去操心。~~没错我就是在说你`PKGBUILD`~~
3. 提供统一接口管理`buildflag`（构建标志）。例如，统一对所有文件启用安全增强的`-fPIC`和`-fPIE`标志。

`debhelper`是 Debian ~~钦点~~最常使用的打包帮助工具。实际上，它已经变成了打包中不可或缺的一部分。如果有空闲，我建议阅读一遍它的手册页：[debhelper(7)](http://man.cx/debhelper(7))。另外一个和它分庭抗礼的帮助工具叫做[cdbs（The Common Debian Build System）](https://blog.hosiet.me/blog/2016/09/15/make-debian-package-with-git-the-canonical-way/build-common.alioth.debian.org/cdbs-doc.html)，然而它随着debhelper新版的开发，包括v7和v9的大变化、尤其是`dh`命令~~（大杀器）~~的引入而逐渐显得有些落伍。对于新的软件包，我只推荐用debhelper。要用9或者以后的版本，可能的话推荐使用v10的新版本新功能。

#### 构建过程

源码包到deb包的过程被称作“构建”（build）。主要的过程如下简述：

1. 分析`debian`目录下的信息，生成`.dsc`文件；

   > 生成.dsc源码文件 
   >
   > 1> `dch -i `按照模板填写 changelog 
   >
   > 2> 生成dsc文件
   >
   > ```bash
   > dpkg-source -b 
   > ```

2. 按顺序调用`debian/rules`文件的各个目标，完成配置（configure）、编译构建（传统上的make步骤）、安装（不会直接安装到系统中，因为Debian提供了`debian/tmp`目录作为`DESTDIR`，专门为下游的安装提供一个目标目录，相当于安装到一个`chroot`目录中）和安装后处理。

3. 根据指令将安装在`debian/tmp`和`.`下面的文件**再次**安装到一个chroot目录中，这个目录是`debian`目录的子目录，目录名称是**需要打包的软件包名称。**

4. 在上一步提到的以软件包名称为目录名的目录下面新建一个`DEBIAN`目录（注意，是**全大写！**），在里面放置一些二进制包的控制文件。主要还是copyright和control文件的经过调整后（例如，自动依赖分析后）的副本，以及一些维护脚本。

5. 调用`dpkg -b`纯粹进行打包（压缩）生成deb包。

6. 调用`dpkg-genchanges`生成`.changes`文件，为后续上传到官方源提供信息。

看起来眼花缭乱，实际上已经被层层封装自动化了。打包者可以不了解其中细节，但是有所了解可以帮助理解，尤其是碰到特殊情况时可以使用工具链中的某些单独的程序完成特别的工作。

#### debian文件夹修改提交

下面便是对`debian/`正常的修改、提交了。注意事项也在前面的工作流程部分讲过。

```
vim debian/control # or some other files
git add debian/*
git commit
# repeat again and again until you are satisfied
dch -i
```

注意一下最后的`dch -i`。这里，我们再次提出一个新小工具：`dch`。它属于`devscripts`软件包的一部分，我推荐你阅读一下它的手册页：[debchange(1)](http://man.he.net/man1/dch)。它可以自动生成、处理符合要求的`changelog`文件，避免手写`changelog`的尴尬。`dch -i`的参数是”增量“的意思，即增量填写软件包新版本的修订信息。有关`changelog`的具体写法，请参考上文提到的新维护人员手册，这里不赘述。


#### 中心问题：如何可靠地从源码包得到deb包？

我们这里说的“可靠”，指的是可重复性，即次次成功（或者次次失败，但这不是我们需要的）且生成的软件包工作效果相同，这是最低目标。我们还有一个终极目标，那就是在任何机器上安装辅助工具，提供相同的源码包，经过一系列工作，应该可以在**任何时间、任何机器**上得到**完全一样**，每个字节都相同的二进制包（deb包）。在最低目标和终极目标之间，我们有宽广的选择空间。最低目标显然必须达到，而最高目标在 Debian 官方2016年秋的工具链中已经接近实现（只剩四个 dpkg 相关的补丁）。

##### 直接开工：`dpkg-buildpackage`和`debuild`

有的人会说：不就是编译么，就算不是 Debian，随便给我一台 Linux 机器我都能手动编译安装！著名的编译安装三部曲，稍微玩过 Linux 的人都知道：

```
./configure
make
[sudo] make install
```

说得不错。上面的三条命令是使用了`autoconf/automake`的软件最常用的编译安装三部曲。第一步搜集信息，生成合适的配置；第二步根据搜集到的信息进行编译；第三步纯粹是文件的复制粘贴。打包其实差不多，只不过环境可控，不会让这些过程影响到系统罢了。

`dpkg-buildpackage`便是最接近原始编译安装的打包工具，虽然它的封装层次已经比较高了。打包构建时，他会直接在当前系统中寻找构建需要的依赖（`Build-Depends`），使用`fakeroot`工具模拟root用户，确保一定的安全性，同时使得打包流程不需要超级用户权限；最终生成可上传至官方的各类文件和源码压缩包、二进制包。除此之外，它在配置、编译步骤中和那些原始的编译安装方式没有太大的区别。这个工具在需要打deb包的非 Debian 开发者中有一定的知名度，因为它可以比较方便地打deb包，又不需要额外的工具和配置。

多说无益，我们现在就上手试试。

首先我们要拿到一份源代码，且这份源代码的顶层目录下有一个子目录叫做`debian`，里面装了写好的打包指令，这就够了。你可以随意去网上下载一份源码，或者用`git`这样的工具克隆一份代码仓库。我们拿`shadowsocks-libev`的源代码举个例子，因为它的`README.md`文件已经完全说明了使用`dpkg-buildpackage`打包的方式，请先进行阅读。在确保当前工作目录在源代码顶级目录下时，打包指令摘抄如下：

```
cd shadowsocks-libev # can be omitted if already finished
sudo apt-get install --no-install-recommends build-essential autoconf libtool libssl-dev \
    gawk debhelper dh-systemd init-system-helpers pkg-config asciidoc xmlto apg libpcre3-dev
dpkg-buildpackage -b -us -uc -i
cd ..
sudo dpkg -i shadowsocks-libev*.deb
```

上面第一行是切换当前工作目录，如果你已经切换完成的话请直接跳过；第二行是使用`apt-get`在**当前系统里安装编译依赖**。具体安装什么，要看`debian/control`文件里对于`Build-Depends`一栏具体填写的内容，当然不同的软件包不一样。第三行是重点，我们在下面解释；第四、第五行只不过是将上一级目录中打包好的`.deb`文件进行安装而已。

`dpkg-buildpackage`工具的命令行选项很重要，我建议你读一遍手册页：[dpkg-buildpackage(1)](http://man7.org/linux/man-pages/man1/dpkg-buildpackage.1.html)，虽然内容写得很凌乱。我们用当前具体的例子解释一下出现的参数：

- -b

  不构建源码包，不使用上游`tarball`，只使用当前目录下已解压缩的源代码构建二进制包。

- -i

  这个参数实际上会原封不动地传给调用的`dpkg-source`工具，其作用是启用内置的一套正则表达式匹配，在处理软件包时忽略特定的内容。例如，**SVN 目录、`.git`目录**等与代码版本管理工具有关的文件。对于使用代码版本管理的源代码，这个参数是非常有用的，基本每次都应该加上。

- -us

  不要对源码包数字签名。不过我们不构建源码包的话，这个参数没什么作用。

- -uc

  不要对自动生成的`.changes`文件数字签名。

就是这样。看起来还是比较清晰的。挑一个项目自己动手试一下吧！

然而你可能已经注意到了，这样的打包工具只是摸到了上面提到的打包最低要求。为什么？因为构建依赖不可控。打包的构建依赖完全决定于当前运行的系统，如果正在运行 Ubuntu 13.10，那么依赖都是按照 Ubuntu 13.10  处理的，没有灵活性。更严重的是，如果打包用户的系统内没有安装构建的依赖，打包就不可能继续。而安装构建依赖又会给那些有洁癖的用户带来麻烦，让整个系统变得越来越臃肿。因此，我们需要继续封装工具，找到一个更有效的解决方案。

首先来说说小的改进。实际上正式打包人员通常不会直接使用`dpkg-buildpackage`的，不仅仅是因为名字太长的原因。有一个稍微高级一点的封装，叫做`debuild`。详细情况，可以查阅其手册页：[debuild(1)](http://manpages.ubuntu.com/manpages/xenial/man1/debuild.1.html)。它只做三件事：

1. 调用`dpkg-buildpackage`打包；
2. 调用`lintian`检查打包错误并提出警告；
3. 调用`debsign`为打包成果进行数字签名。

#### 引入chroot：从`dpkg-buildpackage`到`pbuilder/cowbuilder`

之前说过了，如果直接在当前系统中安装编译依赖会直接影响系统的运行。基于`chroot`的解决方案可以回避这些问题。

回顾一下非`chroot`的解决方案的核心缺陷：

1. 依赖关系来自宿主机，打包依赖决定于宿主机的软件版本；
2. 构建依赖要求在宿主机上安装，污染宿主机的工作环境；

于是下一步我们需要达到以下的目标和做法就很清楚了：

1. 依赖关系不由宿主机确定，人为规定一系列版本。例如，打包时 chroot 环境中已安装的软件永远来自最新的 unstable/sid 发行版。
2. 构建依赖单独安装。例如，在 chroot 环境中安装依赖软件包，不会影响宿主机。

## 源码包到deb包

### 源码包的工作目标：

在类似 launchpad 的软件源中除去 `.deb` 二进制包以外还存在以下文件：`.orig.tar.xz`, `.debian.tar.xz` 和 `.dsc`。这些文件是在构建软件包以后最终得到的。

- `.orig.tar.xz`存储的内容是软件包的源码，这一步可以通过初始化外来软件包来得到。例如：  

```bash
$ cd ~/gentoo
$ wget http://example.org/gentoo-0.9.12.tar.gz
$ tar -xvzf gentoo-0.9.12.tar.gz
$ cd gentoo-0.9.12
$ dh_make -f ../gentoo-0.9.12.tar.gz
```



  这个操作实际上是使用 `dh_make` 按照默认模板生成默认的文件，并且将已有的 tar 包拷贝并且重命名。

```bash
$ cd ~/gentoo ; ls -F
gentoo-0.9.12/
gentoo-0.9.12.tar.gz
gentoo_0.9.12.orig.tar.gz
```

- `.debian.tar.xz` 存储的是软件包的信息以及构建规则。在上一步的操作中你可以看到你的源码目录中还成成了一个 `debian` 文件夹，在这个目录下已经有了很多模板（后文还将详细说明这些文件的用途）。此压缩包就是归档该目录中的文件，在使用 `dpkg-buildpackage` 或者 `debuild` 等命令生成源码包的时候就会得到该归档文件。
- `.dsc`存储的是从 `control` 文件生成的源代码概要，是构成软件打包的重要文件。

值得注意的是，这些操作生成的文件都是以 `${softwarename}_${version}` 的形式出现，也就是说文件夹中用于分割软件名称的 `-` 被替换成了 `_`。

------

### debian 目录中的必须内容：

上面的章节已经又介绍过，在初始化一个外来的软件包以后，在源码目录下会生成一个带有默认模板文件的 `debian` 目录，这个目录中将会存储有软件包的信息（包括维护者，来源，内容等），同时有着构建规则（依赖，编译指令，安装指令，以及打包规则）。下面是自动生成的文件的例子：

```bash
./
├── changelog
├── compat
├── control
├── copyright
├── manpage.1.ex
├── manpage.sgml.ex
├── manpage.xml.ex
├── menu.ex
├── postinst.ex
├── postrm.ex
├── preinst.ex
├── prerm.ex
├── README.Debian
├── README.source
├── rtorrent.cron.d.ex
├── rtorrent.doc-base.EX
├── rtorrent-docs.docs
├── rules
├── source
│   └── format
└── watch.ex
```

在这些文件中有如下必备的文件：`control`，`copyright`，`changelog`，`rules`。下面依次说明这几个文件的作用：

#### control

这个文件包含了很多供 **dpkg**、**dselect**、**apt-get**、**apt-cache**、**aptitude** 等包管理工具进行管理时所使用的许多变量。可以查看 [Debian Policy Manual, 5 “Control files and their fields”](http://www.debian.org/doc/debian-policy/ch-controlfields.html) 的定义。

继续以一个文件为例：

```bash
Source: rtorrent
Section: unknown
Priority: optional
Maintainer: Amefs <efs@amefs.net>
Build-Depends: debhelper (>= 10), autotools-dev
Standards-Version: 4.1.2
Homepage: <insert the upstream URL, if relevant>
#Vcs-Git: https://anonscm.debian.org/git/collab-maint/rtorrent.git
#Vcs-Browser: https://anonscm.debian.org/cgit/collab-maint/rtorrent.git
 
Package: rtorrent
Architecture: any
Depends: ${shlibs:Depends}, ${misc:Depends}
Description: <insert up to 60 chars description>
 <insert long description, indented with spaces>
```

可以看到这里的信息被分成两个部分：一个是构建二进制包相关 ，另一个是安装二进制包相关。

简单解读一下这里面的内容：

- **Source:** 软件名称。
- **Section:** Debian 仓库被分为几个类别：`main` (自由软件)、`non-free` (非自由软件)以及 `contrib` (依赖于非自由软件的自由软件)。也就是平时在 sourcelist 中看到的那些不同的源。在这些大分类下还有根据软件包用途区分的子分类：`admin` 为供系统管理员使用的程序，`devel` 为开发工具，`doc` 为文档，`libs` 为库，`mail` 为电子邮件阅读器或邮件系统守护程序，`net` 为网络应用程序或网络服务守护进程，`x11` 为不属于其他分类的为 X11 程序，等等。以这里的 rtorrent 软件为例，它是一个 p2p 的客户端因此分类就是 `net`。
- **Priority:** 这里虽然还有 `required`、`important` 或 `standard` 等优先级，但是一般这类常规的软件保持 `optional` 即可。
- **Maintainer:** 软件包的维护者，考虑到可能会收到一些 issue 反馈，因此应该正确填写此信息以获取反馈。
- **Build-Depends:** 这里需要添加编译必须的依赖包，有些被 `build-essential`依赖的软件包，如 `gcc` 和 `make` 等，已经会被默认安装而不需再写到此处。但是类似 `bc`，`dh-autoreconf`，`libcurl4-openssl-dev` 之类的编译工具链以及一些必须的库就应该被添加到此处。多个软件包可以通过半角逗号隔开。注：在这里我们是可以指定软件依赖的版本，通过 `=`，`>=` 之类的符号来指定特定版本或者最低版本。
- **Standards-Version:** 这个是 `control` 文件的标准版本，一般来说无需修改。
- **Homepage:** 上游代码的来源
- **Package:** 二进制软件包名称，这个通常来说与源码包一致，但是并非必需，如果你想要分割多个软件包也可以在这里以多个不同名称的 Package 代码块来实现。实际举例：xmlrpc-c 的打包被分为很多个小的软件包，并通过添加 `${Packagename.install}` 实现向这些软件包安装不同的文件。
- **Architecture:** 描述了可以编译本二进制包的体系结构。一般来说这个值是 `any` 或者 `all`。`any` 一般是编译型语言编写的程序生成的二进制，而 `all` 则是脚本型或者文本，图片等二进制包。
- **Depends:** 这个是软件包本身的依赖，一般来说是一些运行库或者依赖的其他软件。当然与 Depends 同级别的还有 `Recommends`、`Suggests`、`Pre-Depends`、`Breaks`、`Conflicts`、`Provides` 和 `Replaces` 等关系。具体可以参考[以下说明](https://www.debian.org/doc/debian-policy/ch-relationships.html#binary-dependencies-depends-recommends-suggests-enhances-pre-depends)。
- **Description:** 软件用途的描述。每行的第一个格应当留空。描述中不应存在空行，如果必须使用空行，则在行中仅放置一个 `.` (半角句点)来近似。同时，长描述后也不应有超过一行的空白。

到此我们就完成了 **control** 文件的修改。

```bash
Source: rtorrent
Section: net
Priority: optional
Maintainer: Amefs <efs@amefs.net>
Build-Depends:
 bc,
 debhelper (>= 9),
 dh-autoreconf,
 libcppunit-dev,
 libcurl4-openssl-dev,
 libncurses5-dev,
 libncursesw5-dev,
 libtorrent-dev (>= 0.13.4),
 libxmlrpc-core-c3-dev,
 pkg-config
Standards-Version: 3.9.6
Vcs-Git: git://git.debian.org/git/collab-maint/rtorrent.git
Vcs-Browser: http://git.debian.org/?p=collab-maint/rtorrent.git
Homepage: https://rakshasa.github.io/rtorrent/
 
Package: rtorrent
Architecture: any
Depends:
 ${misc:Depends},
 ${shlibs:Depends}
Suggests:
 screen | dtach
Description: ncurses BitTorrent client based on LibTorrent from rakshasa
 rtorrent is a BitTorrent client based on LibTorrent.  It uses ncurses
 and aims to be a lean, yet powerful BitTorrent client, with features
 similar to the most complex graphical clients.
 .
 Since it is a terminal application, it can be used with the "screen"/"dtach"
 utility so that the user can conveniently logout from the system while keeping
 the file transfers active.
 .
 Some of the features of rtorrent include:
  * Use an URL or file path to add torrents at runtime
  * Stop/delete/resume torrents
  * Optionally loads/saves/deletes torrents automatically in a session
    directory
  * Safe fast resume support
  * Detailed information about peers and the torrent
  * Support for distributed hash tables (DHT)
  * Support for peer-exchange (PEX)
  * Support for initial seeding (Superseeding)Source: rtorrent``Section: net``Priority: optional``Maintainer: Amefs <efs@amefs.net>``Build-Depends:`` ``bc,`` ``debhelper (>= 9),`` ``dh-autoreconf,`` ``libcppunit-dev,`` ``libcurl4-openssl-dev,`` ``libncurses5-dev,`` ``libncursesw5-dev,`` ``libtorrent-dev (>= 0.13.4),`` ``libxmlrpc-core-c3-dev,`` ``pkg-config``Standards-Version: 3.9.6``Vcs-Git: git://git.debian.org/git/collab-maint/rtorrent.git``Vcs-Browser: http://git.debian.org/?p=collab-maint/rtorrent.git``Homepage: https://rakshasa.github.io/rtorrent/` `Package: rtorrent``Architecture: any``Depends:`` ``${misc:Depends},`` ``${shlibs:Depends}``Suggests:`` ``screen | dtach``Description: ncurses BitTorrent client based on LibTorrent from rakshasa`` ``rtorrent is a BitTorrent client based on LibTorrent. It uses ncurses`` ``and aims to be a lean, yet powerful BitTorrent client, with features`` ``similar to the most complex graphical clients.`` ``.`` ``Since it is a terminal application, it can be used with the "screen"/"dtach"`` ``utility so that the user can conveniently logout from the system while keeping`` ``the file transfers active.`` ``.`` ``Some of the features of rtorrent include:`` ``* Use an URL or file path to add torrents at runtime`` ``* Stop/delete/resume torrents`` ``* Optionally loads/saves/deletes torrents automatically in a session``  ``directory`` ``* Safe fast resume support`` ``* Detailed information about peers and the torrent`` ``* Support for distributed hash tables (DHT)`` ``* Support for peer-exchange (PEX)`` ``* Support for initial seeding (Superseeding)
```

#### copyright

这个文件包含了上游软件的版权以及许可证信息。[Debian Policy Manual, 12.5 “Copyright information”](http://www.debian.org/doc/debian-policy/ch-docs.html#s-copyrightfile) 掌控着它的内容，另外 [DEP-5: Machine-parseable `debian/copyright`](http://dep.debian.net/deps/dep5/) 提供了关于其格式的方针。这个虽然是必须的文件，但是在这里就不详细展开了。

#### changelog

这是一个必须的文件，它的特殊格式在 [Debian Policy Manual, 4.4 “debian/changelog”](http://www.debian.org/doc/debian-policy/ch-source.html#s-dpkgchangelog) 中有详细的描述。这种格式被 **dpkg** 和其他程序用以解析版本号信息、适用的发行版和紧急程度。这个文件可以用来记录你对软件包进行的哪些修改，不同的版本之间有什么区别，建议尽可能正确，详细的填写其中的内容。

还是以一个实际文件为例：

```
libtorrent (0.13.4-1ppa1~18.04) bionic; urgency=medium
 
  * Initial release
 
 -- Amefs <efs@amefs.net>  Fri, 14 Jun 2019 08:09:31 +0000
```

第一行内容是软件名称，版本号，发行版，紧急程度（正常情况下为 medium）

后面几行一般是描述这次更新的具体内容，可多可少。

最后一行则是维护者信息，以及发布这条 changelog 的时间戳。

除了直接编辑这个文件以外，还可以使用 `dch -i` 这将会自动生成一个新的 changelog 条目并且应用预制的信息生成维护者信息以及新的时间戳。

#### rules

这是指导 `dpkg-buildpackage` 构建软件包的 **rules** 文件，这个文件的本质是一个 **Makefile**。这与源码内的 **Makefile** 并不相同，它专门负责指导 `dpkg-buildpackage` 使用源码包中的各种信息构建二进制文件。

每一个 `rules` 文件， 就像其他的 `Makefile` 一样，包含着若干 rules，其中每一个都定义了一个 target 以及其具体 操作。 一个新的 rule 以自己的 target  声明(置于第一列)来起头。 后续的行都以 TAB 字符 (ASCII 9) 来开头，以指示 target 的具体行为。 空行和以井号 `#` 开头的行会被当作注释而被忽略。 在过去，这些 target 是需要手动编写的，但是现在这些任务一般会交给 **debhelper** 来完成。

`dh_make` 给出的默认 rules 文件就是以 **debhelper** 支持的命令生成的最简规则：

```bash
#!/usr/bin/make -f
# See debhelper(7) (uncomment to enable)
# output every command that modifies files on the build system.
#DH_VERBOSE = 1
 
# see FEATURE AREAS in dpkg-buildflags(1)
#export DEB_BUILD_MAINT_OPTIONS = hardening=+all
 
# see ENVIRONMENT in dpkg-buildflags(1)
# package maintainers to append CFLAGS
#export DEB_CFLAGS_MAINT_APPEND  = -Wall -pedantic
# package maintainers to append LDFLAGS
#export DEB_LDFLAGS_MAINT_APPEND = -Wl,--as-needed
 
 
%:
         dh $@ 


```

第 16 和 17 行使用了 pattern rule，以此隐式地完成所有工作。 其中的百分号意味着“任何 targets”， 它会以 target 名称作参数调用单个程序 **dh**。 **dh** 命令是一个包装脚本，它会根据参数执行妥当的 **dh_\*** 程序序列。而我们使用的 **dpkg-buildpackage** 实际会通过执行 debian/rules build-target 以及 fakeroot debian/rules binary-target 来生成二进制并安装打包到一个 deb 文件中。

- `debian/rules clean` 运行了 `dh clean`，实际执行的命令为：

  ```bash
  dh_testdir
  dh_auto_clean
  dh_clean 
  ```

- `debian/rules build` 执行了 `dh build`，实际执行的命令为：

  ```bash
  dh_testdir
  dh_auto_configure
  dh_auto_build
  dh_auto_test
  ```

- `fakeroot debian/rules binary` 执行了 `fakeroot dh binary`，其实际执行的命令为：

  ```bash
  dh_testroot
  dh_prep
  dh_installdirs
  dh_auto_install
  dh_install
  dh_installdocs
  dh_installchangelogs
  dh_installexamples
  dh_installman
  dh_installcatalogs
  dh_installcron
  dh_installdebconf
  dh_installemacsen
  dh_installifupdown
  dh_installinfo
  dh_installinit
  dh_installmenu
  dh_installmime
  dh_installmodules
  dh_installlogcheck
  dh_installlogrotate
  dh_installpam
  dh_installppp
  dh_installudev
  dh_installwm
  dh_installxfonts
  dh_bugfiles
  dh_lintian
  dh_gconf
  dh_icons
  dh_perl
  dh_usrlocal
  dh_link
  dh_compress
  dh_fixperms
  dh_strip
  dh_makeshlibs
  dh_shlibdeps
  dh_installdeb
  dh_gencontrol
  dh_md5sums
  dh_builddeb
  ```

可以看到这里有非常多 **dh_\*** 命令，可以参考 [debhelper 的说明](http://manpages.ubuntu.com/manpages/bionic/man7/debhelper.7.html)。

我们可以通过为 `dh $@` 命令添加各种参数来添加 **dh_python2** 、**dh_quilt_patch**、**dh_dkms** 等命令支持。并且我们可以通过类似如下的参数来覆盖默认的配置。例如：

```bash
#!/usr/bin/make -f
 
%:
    dh $@ --with autoreconf --parallel
 
override_dh_auto_configure:
    dh_auto_configure -- --with-xmlrpc-c --enable-ipv6
```

这是 rtorrent 的 rules。我们简单解读一下，首先在 `dh` 命令初始化的是时候，加入 **autoreconf** 支持，这就会在编译的时候执行 `autoreconf`，这样就会生成一个适用于这个平台的 `configure` 文件。`parallel` 命令将会打开并行编译支持。最后通过 `override_dh_auto_configure` 为 `./configure` 命令添加 `--with-xmlrpc-c --enable-ipv6` 参数。这个过程就与我们在编译安装的时候执行 `autogen.sh`、`./configure --with-xmlrpc-c --enable-ipv6` 的效果相同。根据这个 rules 就可以完成 **Makefile** 的生成，并利用生成的文件构建二进制，最后打包。

对于很多软件包来说，我们并不需要这样一步一步手动生成这些文件。常见的软件包往往已经实现了 debian 化，也就是说在一些软件源中可以找到这些东西，我们只需要下载它们的源码，提取出 `.debian.tar.xz` 中的这些必要文件，就可以按照我们的需求进行定制。



### debian 目录下的其他文件：

完整的介绍可以参考[此处](https://www.debian.org/doc/manuals/maint-guide/dother.zh-cn.html)，我将在下文详细说明以下几个文件`install`、`source/format`、`patches/*`。

#### install

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

#### source/format

这个文件仅有一行内容，这个内容为 `3.0 (native)` 或者 `3.0 (quilt)`。一般来说我们编译的是一些外来的软件包，因此选择 `3.0 (quilt)`。这里其实就是使用 `quilt` 在解压源代码包时自动应用位于 `debian/patches` 下的补丁，而在你执行完打包作业后，这些补丁将会被自动撤销，不会影响源码本身的完整性。

#### patches/*

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

```
$ dpkg-buildpackage -us -uc
```

其中`us` 是 unsigned-source 的缩写，也就是说在生成源码包的时候不会对源码包进行签名。一般来说不上传到 ppa 源的这些包完全可以不签名。`uc` 是 unsigned-changes 的意思，也是同理。特别是如果还没有配置好 gpg key 的时候是没有办法进行签名操作的。后续也可以通过 `debsign` 手动对这些包进行签名。

在执行这个命令的时候，**dpkg-buildpackage** 将会执行如下操作：

1. 设置构建环境的各种变量，这些变量已经有了默认值，可以通过设置来覆盖。
2. 它会检查构建依赖以确保满足 Dependence 写明的关系（可以通过 `-d` 或者 `--no-check-builddeps`）禁用检查。
3. 通常来说这里会运行 `fakeroot debian / rules clean` 对构建树进行清理（可以通过 `-nc` 或者 `--no-pre-clean`）禁用。
4. 这一步将会调用 `dpkg-source -b` 生成源码包。
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



## pbuilder介绍

### 简介

pbuilder(personal Debian package builder)是debian/ubuntu环境下维护debian包的专业工具，能够为每一个deb包创建纯净的编译构建环境，自动解析和安装依赖包，而且不污染宿主系统。 

### 使用pbuilder的流程bootstrap

(1) 使用pbuild create创建纯净的编译构建环境，能够通过参数指定所要模拟的debian环境版本ubuntu

(2) 使用apt-get source下载目标deb包的src包架构

(3) 使用pbuilder build编译目标源码包，参数为src包的dsc文件工具

(4) 回到第(2)步继续编译更多的包 

### pbuilder的主要功能

(1) --create

创建指定debian发行版的编译构建环境，最终会打包为base.tgz。

(2) --update

更新base.tgz。

(3) --build

编译指定的源码包，通过传入dsc-file指定源码包。

(4) --clean

清空BUILDPLACE和APTCACHE中的内容。

(5) --login

chroot(即login)到构建编译环境。须要注意的是，exit后会自动clean，期间用户全部的操做都不会被保存，所以此命令只用于调试目的。

(6) --excute

首先login到编译构建环境，而后执行指定的program。须要在参数中指定目标program的路径，该program会被复制到编译构建环境中执行。

(7) --debuild

在Debian source directory(即解压好的debian源码包)中编译源码包，当前目录中须要存在debian/目录。pbuilder --debuild等价于pdebuild。

### pbuilder的原理

- (1) 相关文件

  pbuilder相关的脚本有/usr/sbin/pbuilder，/usr/lib/pbuilder/*，/usr/bin/pdebuild。

  相关的临时目录是/var/cache/pbuilder。

  pbuilder运行时所需的各类变量如BUILDPLACE, MIRRORSITE,BUILDRESULT, DISTRIBUTION等都定义在配置文件中，这些文件有/etc/pbuilder/*, /usr/share/pbuilder/pbuilderrc,/etc/pbuilderrc, ~/. pbuilderrc。通过pbuilder-loadconfig脚本可知，这些文件的优先级依次升高：/usr/share/pbuilder/pbuilderrc< /etc/pbuilderrc < ~/. pbuilderrc，即前者的配置能够被后者覆盖，最后，全部的参数又均可以通过命令行参数覆盖。 

- (2) pbuilder create命令的实体是pbuilder-createbuildenv。

  它创建一个根目录环境，模拟指定的debian发行版。根目录被打包在BUILDPLACE/base.tar.gz中，以后编译deb包时能够重复使用。

- - (2.1) 该脚本首先创建debian系统的基础根目录并安装基本的deb包，这些实际上是借助debootstrap完成的。根目录环境放在BUILDPLACE中。

能够通过参数定制debootstrap所创建的debian系统，如--arch=ARCH可指定目标体系架构，--include=PACKAGES指定须要额外下载安装的package，--variant=minbase|buildd|fakechroot|scratchbox可指定所使用的bootstrap脚本，不一样的脚本创建的debian环境不一样，主要区别是安装的deb包不一样，默认是minbase，若是要创建编译构建环境，通常选用 buildd。debootstrap目前所支持的debian系统发行版见http://neuro.debian.net/pkgs/debootstrap.html

- - (2.2) 将一些重要的配置文件(hosts, hostname, resolv.conf)复制到目标环境，创建并配置/etc/apt，添加apt keyring到目标环境中。

- - (2.3) chroot到目标环境，挂载运行时所需的目录，如/proc, /dev/, /dev/pts, /selinux及用户指定的须要bind mount的目录。

- - (2.4) 在目标环境中，执行apt-get update，并安装build-essential，dpkg-dev以及其它的packages。

- - (2.5) 卸载以前挂载的运行时目录。

- - (2.6) 将BUILDPLACE打包为base.tgz。

以上各步出现错误时，都会清空BUILDPLACE，避免污染宿主系统。 

- (3) pbuilder build的实体是pbuilder-buildpackage。

  它基于已有的base.tgz，创建临时编译构建环境，并在此环境中编译源码包。

- - (3.1) 该脚本首先解压base.tgz到临时目录BUILDPLACE中，将宿主系统中的重要配置文件复制进去，若是用户指定要覆盖默认的apt源，则从新配置临时环境中的/etc/apt，以后挂载/proc等运行时目录。

- - (3.2) 创建编译时所需的临时目录和文件，如BUILDRESULT,PBUILDER_BUILD_LOGFILE等。

- - (3.3) chroot检查并安装编译源码包所需的依赖包，用户指定的额外包。

    检查并安装依赖包的工做，通过pbuilder-satisfydepends脚本完成。该脚本通过解析dsc文件中的Build-Depends, Build-Depends-Indep, Build-Conflicts,Build-Conflicts-Indep等区域，获得编译目标源码包所需的依赖包和冲突包，利用这些信息，创建了一个空的deb包pbuilder-satisfydepends-dummy，再利用aptitude install安装这个dunmmy包，从而解决了依赖包和冲突包的问题。

- - (3.4) 根据参数中的dsc-file，将源码文件复制到临时环境中(即BUILDPLACE/tmp/buildd)，并修改文件权限，同时若是用户指定了INPUTFILE，则一并复制进去。最后chroot到临时环境，解压源码包。

- - (3.5) 以chroot的方式调用dpkg-buildpackage编译源码包。

- - (3.6) 卸载运行时目录。

- - (3.7) 将编译获得的deb包从BUILDPLACE/tmp/buildd复制到BUILDRESULT，默认是/var/cache/pbuilder/result/。

- - (3.8) 清除BUILDPLACE。



## pbuilder实战

### 基于 pbuilder 的源码构建
#### 初始化环境:

首先安装 pbuilder 以及相关的软件包：

```bash
$ sudo apt-get install cowdancer cowbuilder pbuilder packaging-dev dh-make ubuntu-keyring debian-archive-keyring pigz
```

一般来说可以直接使用 `pbuilder create` 初始化本地 **pbuilder chroot** 系统，但是这不利于多个 chroot 系统的管理。于是我们可以通过添加  **/etc/pbuilderrc**的方式达到自定义 chroot 系统构建的目的，以下是一个示例:

```bash
#!/bin/sh
## define cowbuilder as pbuilder warpper
PDEBUILD_PBUILDER=cowbuilder
 
set -e
 
if [ "$OS" == "debian" ]; then
    MIRRORSITE="http://ftp.de.debian.org/debian/"
    COMPONENTS="main contrib non-free"
    DEBOOTSTRAPOPTS=("${DEBOOTSTRAPOPTS[@]}"
        "--keyring=/usr/share/keyrings/debian-archive-keyring.gpg")
    : ${DIST:="stretch"}
    : ${ARCH:="amd64"}
elif [ "$OS" == "ubuntu" ]; then
    MIRRORSITE="http://de.archive.ubuntu.com/ubuntu/"
    COMPONENTS="main restricted universe multiverse"
    DEBOOTSTRAPOPTS=("${DEBOOTSTRAPOPTS[@]}"
        "--keyring=/usr/share/keyrings/ubuntu-archive-keyring.gpg")
    : ${DIST:="bionic"}
    : ${ARCH:="amd64"}
else
    echo "Unknown OS: $OS"
    exit 1
fi
 
if [ "$DIST" == "" ]; then
    echo "DIST is not set"
    exit 1
fi
 
if [ "$ARCH" == "" ]; then
    echo "ARCH is not set"
    exit 1
fi
 
## define locations
NAME="$OS-$DIST-$ARCH"
USRDISTPATH=/var/cache/pbuilder
DEBOOTSTRAPOPTS=("${DEBOOTSTRAPOPTS[@]}" "--arch=$ARCH")
BASETGZ="$USRDISTPATH/$NAME-base.tgz"
DISTRIBUTION="$DIST"
BUILDRESULT="$USRDISTPATH/$NAME/result"
APTCACHE="$USRDISTPATH/$NAME/aptcache"
BUILDPLACE="$USRDISTPATH/build"
HOOKDIR="$USRDISTPATH/hook.d"
# parallel make
DEBBUILDOPTS=-j$(nproc)
 
# create local repository if it doesn't already exist,
# such as during initial 'pbuilder create'
if [ ! -d $BUILDRESULT ] ; then
        mkdir -p $BUILDRESULT
        chmod g+rwx $BUILDRESULT
fi
if [ ! -e $BUILDRESULT/Packages ] ; then
        touch $BUILDRESULT/Packages
fi
if [ ! -e $BUILDRESULT/Release ] ; then
        cat << EOF > $BUILDRESULT/Release
Archive: $DIST
Component: main
Origin: pbuilder
Label: pbuilder
Architecture: $ARCH
EOF
  
fi
 
# create user script hook
mkdir -p $HOOKDIR
# local result package autoload
if [ -d $BUILDRESULT ] ; then
    export DEPSPATH=$BUILDRESULT
    BINDMOUNTS=$DEPSPATH
    DEBS=`ls $DEPSPATH | grep deb | wc -l`
    if [ ${DEBS} != 0 ] ; then
        OTHERMIRROR="deb [trusted=yes] file://$DEPSPATH ./"
        echo "add $DEPSPATH to source"
        cat > $HOOKDIR/D05deps <<'EOF'
#!/bin/sh
apt-get install --assume-yes apt-utils
( cd "$DEPSPATH"; apt-ftparchive packages . > Packages )
apt-get update
EOF
        chmod +x "${HOOKDIR}/D05deps"
    fi
fi
# failure redirect
cat > $HOOKDIR/C10shell <<'EOF'
#!/bin/sh
 
# invoke shell if build fails.
apt-get install -y --force-yes vim less bash
cd /tmp/buildd/*/debian/..
/bin/bash < /dev/tty > /dev/tty 2> /dev/tty
EOF
chmod +x "${HOOKDIR}/C10shell"
```

简单解释以下上面的脚本：首先在脚本中定义了 debian 和 ubuntu 的 mirror server，没有指定的话，ubuntu 无法下载 debian 的  chroot，反之亦然。接下去是对诸如文件保存位置，文件名称，钩子/缓存位置的设定。通过这些设定，构建出来的 chroot  归档就有比较规整的名字了。再下去是两个构建钩子。第一个钩子能自动载入生成在 **result** 中的 deb 包，外部的预编译二进制包也可以同样的自动被载入；第二个钩子是在编译失败时将 chroot 中的 Terminal 自动转发到现在使用的 Terminal 中。

利用这样的一个配置文件，我们就可以很简单的使用如下指令批量构建 chroot 环境了：

```bash
sudo OS=ubuntu DIST=bionic ARCH=amd64 pbuilder --create; \
sudo OS=ubuntu DIST=xenial ARCH=amd64 pbuilder --create; \
sudo OS=debian DIST=buster ARCH=amd64 pbuilder --create; \
sudo OS=debian DIST=stretch ARCH=amd64 pbuilder --create; \
sudo OS=debian DIST=jessie ARCH=amd64 pbuilder --create
```

Tips: 这里的 ARCH 只要 CPU 指令集支持即可进行编译，也就是说在一台运行 amd64 的系统上完全可以编译 i386 的二进制包，arm 平台也是如此。另一点值得注意的是比如 Scaleway 使用的 **Cavium ThunderX SoCs** 是阉割了 armhf 指令集的，也就是说它只能运行 aarch64 的程序，不可以编译 armhf的二进制包。关于跨构架的编译将在后文说明。

#### 构建简单的二进制包:

`pbuilder` 需要的是由 `dpkg-buildpackage` 生成的 **.orig.tar.gz**、 **.dsc** 和 **.debian.tar.gz**。当然，还有一种形式，是仅有 **.orig.tar.gz** 和 **.dsc**：这种打包方式会将 debian 文件夹也存入压缩包，通常是由一些拥有版本管理能力的自动化打包系统生成的，常见于一些 ppa 的 nightly build。

实际的构建指令非常简单：

```
sudo OS=ubuntu DIST=bionic ARCH=amd64 pbuilder build libtorrent_0.13.6-1build1.dsc
```

在编译完成后，生成的无 GPG 签名的软件包会被以非 root 属主放置于 `/var/cache/pbuilder/$OS-$DIST-$ARCH/result/`。

需要给生成的 **.dsc** 和 **.changes** 文件签名的时候，只需要运行以下指令：

```bash
cd /var/cache/pbuilder/$OS-$DIST-$ARCH/result/
debsign libtorrent_0.13.6-1build1.dsc
```

#### 构建具有本地依赖的二进制包:

当 chroot 系统中的基本依赖可以满足编译条件的时候，一切都非常的简答，但是如果你需要为二进制包添加一个外部的依赖，那么就需要做以下的事：

- 方法一：

  如果说使用上述的 **.pbuilderrc** 那么，内含的钩子函数就会在编译的时候生成 Package 和 Release 信息。这些信息能够指导 apt 包管理器通过 `deb [trusted=yes] file://$DEPSPATH ./` 的形式找到本地的 deb 二进制包并根据 **control** 文件中描述的依赖关系选择性安装。

  你可以通过运行以下指令，在编译前更新源列表：

  `$ sudo OS=ubuntu DIST=bionic ARCH=amd64 pbuilder update --override-config`

  如果依赖仍然没有被载入，那么反复尝试编译和更新源列表即可，通常在 1-2 次更新后就会解决。

- 方法二：

  手动安装依赖。通常情况下在执行完 `build/login` 等指令后 **pbuilder** 的系统会被重置，但是我们可以通过使用以下代码登录到 **chroot** 环境中进行配置并且保存：

  `$ sudo OS=ubuntu DIST=bionic ARCH=amd64 pbuilder --login --save-after-login`

  通过 `^D` (Control-D)离开这个 shell 时环境会被保存。

完成依赖安装后，其余的编译方式与简单的二进制包完全一致。

Tips: 在编译过程中通常需要注意 **control** 文件与 chroot 环境的匹配，并非所有的编译规则都可以同时用在多个 chroot 环境中。另外在出现错误进入 chroot 环境使用的 Terminal 以后也可以再次尝试使用 `dpkg-buildpackage` 命令构建，pbuilder 默认的规则比起 `dpkg-buildpackage` 更加严格，因此有时候会因为一些小问题导致无法完成编译，使用 `dpkg-buildpackage` 则可以绕过这些检查。

------

### 基于 qemu 的 pbuilder 源码构建:

上文提到的编译都是针对同构架硬件的，也就是说 x86/amd64 平台只能编译 x86/amd64 使用的二进制；arm 平台也只能编译它的二进制。在日常使用中，不难知道，arm  平台(特别是现有的 armel/armhf) 性能是非常孱弱的，如果直接使用它们进行 native  编译，需要的时间是很长的，举例来说，Allwinner 的 A83T 在使用多线程编译 transmission  的时候，使用的时间大约是一小时，如果需要针对不同的系统编译，时间也是成倍增加。解决方法实际上也很简单，使用交叉编译工具进行编译，并且使用  qemu 解决指令集翻译问题。在使用一台 4 线程 VPS (实验对象为 Hetzner Cloud VPS)  的情况下，编译时间则只需要20分钟。

注意：这里需要满足 pbuilder 版本 > 0.23 也就是说 Xenial 版本是没办法用来做 qemu 的跨构架编译的。

#### 初始化环境:

qemu 环境的构建非常简单，通常来说不需要自己编译，可以直接通过以下指令就可以安装：

```bash
$ sudo apt-get install qemu binfmt-support qemu-user-static
```

然后就像普通的 pbuilder 构建一样，这里也需要用到一个专用的 **/etc/pbuilderrc**：

```bash
#!/bin/sh
## define cowbuilder as pbuilder warpper
PDEBUILD_PBUILDER=cowbuilder
## must use the apt "satisfydepends" resolver with pbuilder
#  https://wiki.debian.org/CrossCompiling#Building_with_pbuilder
PBUILDERSATISFYDEPENDSCMD="/usr/lib/pbuilder/pbuilder-satisfydepends-apt"
## if pbuilder-satisfydepends-apt not work, try following resolver
#PBUILDERSATISFYDEPENDSCMD="/usr/lib/pbuilder/pbuilder-satisfydepends-experimental"
 
set -e
 
if [ "$OS" == "debian" ]; then
    MIRRORSITE="https://mirror.sjtu.edu.cn/debian/"
    COMPONENTS="main contrib non-free"
    DEBOOTSTRAPOPTS=("${DEBOOTSTRAPOPTS[@]}"
        "--keyring=/usr/share/keyrings/debian-archive-keyring.gpg")
    : ${DIST:="buster"}
    : ${ARCH:="arm64"}
elif [ "$OS" == "uos" ]; then
    MIRRORSITE="http://pools.tech.com/desktop-professional/"
    COMPONENTS="main contrib non-free"
    DEBOOTSTRAPOPTS=(
        '--variant=buildd'
        '--no-check-gpg'
        )
    : ${DIST:="eagle/sp2"}
    : ${ARCH:="arm64"}
elif [ "$OS" == "ubuntu" ]; then
    MIRRORSITE="http://ports.ubuntu.com/"
    COMPONENTS="main restricted universe multiverse"
    DEBOOTSTRAPOPTS=("${DEBOOTSTRAPOPTS[@]}"
        "--keyring=/usr/share/keyrings/ubuntu-archive-keyring.gpg")
    : ${DIST:="focal"}
    : ${ARCH:="armhf"}
elif [ "$OS" == "raspbian" ]; then
    MIRRORSITE="http://mirror.de.leaseweb.net/raspbian/raspbian"
    COMPONENTS="main contrib non-free"
    DEBOOTSTRAPOPTS=("${DEBOOTSTRAPOPTS[@]}"
        "--keyring=/usr/share/keyrings/raspbian-archive-keyring.gpg")
    : ${DIST:="buster"}
    : ${ARCH:="armhf"}
else
    echo "Unknown OS: $OS"
    exit 1
fi
 
if [ "$DIST" == "" ]; then
    echo "DIST is not set"
    exit 1
fi
 
if [ "$ARCH" == "" ]; then
    echo "ARCH is not set"
    exit 1
fi
 
if [ "$ARCH" == "armel" ] && [ "$(dpkg --print-architecture)" != "armel" ]; then
    DEBOOTSTRAP="qemu-debootstrap"
fi
if [ "$ARCH" == "armhf" ] && [ "$(dpkg --print-architecture)" != "armhf" ]; then
    DEBOOTSTRAP="qemu-debootstrap"
fi
if [ "$ARCH" == "aarch64" ] && [ "$(dpkg --print-architecture)" != "aarch64" ]; then
    DEBOOTSTRAP="qemu-debootstrap"
fi
if [ "$ARCH" == "arm64" ] && [ "$(dpkg --print-architecture)" != "arm64" ]; then
    DEBOOTSTRAP="qemu-debootstrap"
fi
 
## define locations
NAME="$OS-$DIST-$ARCH"
USRDISTPATH=/var/cache/pbuilder
DEBOOTSTRAPOPTS=("${DEBOOTSTRAPOPTS[@]}" "--arch=$ARCH")
BASETGZ="$USRDISTPATH/$NAME-base.tgz"
DISTRIBUTION="$DIST"
BUILDRESULT="$USRDISTPATH/$NAME/result"
APTCACHE="$USRDISTPATH/$NAME/aptcache"
BUILDPLACE="$USRDISTPATH/build"
HOOKDIR="$USRDISTPATH/hook.d"
# parallel make
DEBBUILDOPTS=-j$(nproc)
 
# create local repository if it doesn't already exist,
# such as during initial 'pbuilder create'
if [ ! -d $BUILDRESULT ] ; then
        mkdir -p $BUILDRESULT
        chmod g+rwx $BUILDRESULT
fi
if [ ! -e $BUILDRESULT/Packages ] ; then
        touch $BUILDRESULT/Packages
fi
if [ ! -e $BUILDRESULT/Release ] ; then
        cat << EOF > $BUILDRESULT/Release
Archive: $DIST
Component: main
Origin: pbuilder
Label: pbuilder
Architecture: $ARCH
EOF
  
fi
 
# create user script hook
mkdir -p $HOOKDIR
# local result package autoload
if [ -d $BUILDRESULT ] ; then
    export DEPSPATH=$BUILDRESULT
    BINDMOUNTS=$DEPSPATH
    DEBS=`ls $DEPSPATH | grep deb | wc -l`
    if [ ${DEBS} != 0 ] ; then
        OTHERMIRROR="deb [trusted=yes] file://$DEPSPATH ./"
        echo "add $DEPSPATH to source"
        cat > $HOOKDIR/D05deps <<'EOF'
#!/bin/sh
apt-get install --assume-yes apt-utils
( cd "$DEPSPATH"; apt-ftparchive packages . > Packages )
apt-get update
EOF
        chmod +x "${HOOKDIR}/D05deps"
    fi
fi
# failure redirect
cat > $HOOKDIR/C10shell <<'EOF'
#!/bin/sh
 
# invoke shell if build fails.
apt-get install -y --force-yes vim less bash devscripts git pbuilder
cd /tmp/buildd/*/debian/..
/bin/bash < /dev/tty > /dev/tty 2> /dev/tty
EOF
chmod +x "${HOOKDIR}/C10shell"
```

这个配置的主体内容与 native 编译相同，区别在于：

1. 使用了**pbuilder-satisfydepends-apt** 解决依赖关系，有些时候这个包管理器也不能处理好依赖，那么还可以尝试一下 **pbuilder-satisfydepends-experimental**。
2. 使用到的 repo 也与 native 编译不同
3. 使用 **qemu-debootstrap** 部署 chroot 环境。

值得注意的是，如果需要针对 raspbian 做编译，那么应当安装它的密匙串：

```bash
$ wget http://archive.raspbian.org/raspbian/pool/main/r/raspbian-archive-keyring/raspbian-archive-keyring_20120528.2_all.deb``$ sudo dpkg -i raspbian-archive-keyring_20120528.2_all.deb
```

另外，构建Deepin或者UOS，因发行代号并未合入到官方，需要复制buster的codename复制到eagle/sp2

```shell
sudo install -Dvm644 /usr/share/debootstrap/scripts/buster /usr/share/debootstrap/scripts/eagle/sp2
```

我们使用如下命令初始化 chroot：

```bash
sudo OS=ubuntu DIST=bionic ARCH=armhf pbuilder --create; \
sudo OS=uos DIST=eagle/sp2 ARCH=arm64 pbuilder --create --basetgz sp2.tgz
```

#### 构建二进制包:

准备mousepad三个文件：

```bash
mousepad_0.4.1-2.debian.tar.xz
mousepad_0.4.1-2.dsc
mousepad_0.4.1.orig.tar.bz2
```

为了区别一个跨构架的编译，我们需要将编译参数改为如下形式：

```bash
sudo OS=uos DIST=eagle/sp2 ARCH=arm64 pbuilder build --basetgz sp2.tgz --host-arch arm64 mousepad_0.4.1-2.dsc
```

在执行过程中，会启用用户态的 qemu 虚拟机运行编译。构建具有本地依赖的二进制包方法同 native 编译，因此不再赘述。

qemu 由于执行二进制代码的翻译，因此并不会像常见的 KVM 等虚拟机那样高效。但是由于常用的 arm 开发板通常在 CPU 计算能力和 IO 能力方面都与 x86/x64 平台有较大差距，因此这种方法能够确实的提高编译的效率。

#### 使用钩子脚本

```
BINDMOUNTS="/var/cache/pbuilder/result"
```

To use the local file system instead of HTTP, it is necessary to do bind-mounting. **`--bindmounts`** is a command-line option useful for such cases.      

D开头的钩子脚本将在安装构建依赖前执行。

```bash
# cat /var/cache/pbuilder/hooks.d/D10ppa
#!/bin/bash
cat <<EOF |tee /etc/apt/sources.list.d/ppa.list
deb  [trusted=yes] http://aptly.tech.com/pkg/sp2/release-candidate/5oiY55WlLVBhbmd1VzIwMjEtMDUtMjcgMTM6MjY6MDk  unstable main
deb-src  [trusted=yes] http://aptly.tech.com/pkg/sp2/release-candidate/5oiY55WlLVBhbmd1VzIwMjEtMDUtMjcgMTM6MjY6MDk  unstable main
EOF
cat <<EOF | tee /etc/apt/preferences.d/ppa.pref
Package: *
Pin: release o=sp2/release-candidate/5oiY55WlLVBhbmd1VzIwMjEtMDUtMjcgMTM6MjY6MDk unstable,a=unstable,n=unstable,l=sp2/release-candidate/5oiY55WlLVBhbmd1VzIwMjEtMDUtMjcgMTM6MjY6MDk 
unstable,c=main,b=arm64
Pin-Priority: 1001
EOF
/usr/bin/apt-get update
```

 **注意**：必须给予执行权限` sudo chmod +x /var/cache/pbuilder/hooks.d/D10ppa`

```bash
sudo OS=uos DIST=eagle/sp2 ARCH=arm64 pbuilder build --basetgz sp2.tgz --host-arch arm64 mousepad_0.4.1-2.dsc | tee /var/tmp/mousepadbuild.log
```

自日志中可以看到已经执行hooks脚本，使用自定义的配置。

#### 手动配置打包

```bash
sudo OS=uos DIST=eagle/sp2 ARCH=arm64 pbuilder pbuilder --login --basetgz sp2.tgz --save-after-login
# 进入chroot环境，自己可以做些配置
# apt-key add - <<EOF
...public key goes here...
EOF
# apt build-dep [project]
# cd 工程目录 && V=1 debuild -b -nc -uc -us -j8
# logout
```

- 打开第二个终端查看打包结果，可以在打包过程中操作 df -h 查看root挂在点 一般在/var/cache/pbuilder/build/... 目录下，可以找到对应的代码目录，打包以后的deb包在上级目录中

- 打包完成cp到桌面：

```shell
1> cd 到deb包输出目录
2> sudo mkdir -pv results
3> sudo mv *.deb -v results/
4> sudo tar -cvf results.tar.gz results
5> scp results.tar.gz xxx@ip:~/
```

打包完毕！！！

- exit退出，退出以后数据会丢失，慎用！！！



## 参考链接

- [配合Git为Debian系发行版打包的正确方式](https://blog.hosiet.me/blog/2016/09/15/make-debian-package-with-git-the-canonical-way/)
- [Debian 软件包制作小记 (1)](https://amefs.net/archives/1924.html)
- [Debian 软件包制作小记 (2)](https://amefs.net/archives/1953.html)
- [Debian 软件包制作小记 (3)](https://amefs.net/archives/1961.html)
- [pbuilder User's Manual](https://pbuilder-team.pages.debian.net/pbuilder/)


## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2021-08-17

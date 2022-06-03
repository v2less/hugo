---
title: "Writing Shell Script Within Makefile"
date: 2021-08-25T10:03:25+08:00
author: v2less
tags: ["linux"]
draft: false
---

## Tips for writing shell scripts within makefiles[^1]

1. Escape the script's use of `$` by replacing with `$$`
2. Convert the script to work as a single line by inserting `;` between commands
3. If you want to write the script on multiple lines, escape end-of-line with `\`
4. Optionally start with `set -e` to match make's provision to abort on sub-command failure
5. This is totally optional, but you could bracket the script with `()` or `{}` to emphasize the cohesiveness of a multiple line sequence -- that this is not a typical makefile command sequence

Here's an example inspired by the OP:

```sh
mytarget:
    { \
    set -e ;\
    msg="header:" ;\
    for i in $$(seq 1 3) ; do msg="$$msg pre_$${i}_post" ; done ;\
    msg="$$msg :footer" ;\
    echo msg=$$msg ;\
    }
```

使用makefile创建hugo new post的处理：

```bash
validate-create:
        @if [ -z `echo $(TITLE)|sed -E -e 's/[[:blank:]]+/-/g'` ]; then\
           echo "TITLE not set. Pass in TITLE=<title name>"; exit 10;\
   		 fi

.PHONY: new
new: validate-create ## Create a new post in posts folder
        { \
        echo "== Creating new post";\
        output=$$(hugo new posts/`date -u +'%Y-%m-%d-'``echo $${TITLE}|sed -E -e 's/[[:blank:]]+/-/g'`.md 2>&1);\
        filename1=$$(echo "$$output"|awk '{print $$1}');\
        filename2=$$(echo "$$output"|awk '{print $$2}');\
        if [ -f "$$filename1" ]; then \
            filename="$$filename1";\
        elif [ -f "$$filename2" ]; then \
            filename="$$filename2";\
        else \
            echo "Something wrong";\
        fi;\
        typora "$$filename";\
        }
```



## 参考

[^1]: https://stackoverflow.com/questions/10121182/multi-line-bash-commands-in-makefile

## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2021-08-25T10:03:25+08:00

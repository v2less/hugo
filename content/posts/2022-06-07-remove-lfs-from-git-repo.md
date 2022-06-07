---
title: "Remove Lfs From Git Repo"
date: 2022-06-07T18:05:16+08:00
author: v2less
tags: ["git"]
draft: false
---

```bash
git lfs uninstall
rm .gitattributes
touch .gitattributes
git lfs ls-files | sed -r 's/^.{13}//' > files.txt
while read line; do git rm --cached "$line"; done < files.txt
while read line; do git add "$line"; done < files.txt
git add .gitattributes
rm files.txt
git lfs ls-files
rm -rf .git/lfs
git commit -m "unlfs"
```






## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2022-06-07T18:05:16+08:00

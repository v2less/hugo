---
title: "Gpg Generate Key"
date: 2022-06-18T16:09:28+08:00
author: v2less
tags: ["linux"]
draft: false
---

```bash
mkdir mykey
export GNUPGHOME=$(pwd)/mykey
gpg --gen-key

mykey                                                   755
├── openpgp-revocs.d                                    700
│   └── BA00E9417FF61FCEBC5632DC80AF25C0DB8F4A67.rev    600
├── private-keys-v1.d                                   700
│   ├── 70DE0FE1C6CF2C3D99764B3ADF930618E7356DD6.key    600
│   └── FFF9AFFE82705532ED6D3549DF77700B57A0F7C5.key    600
├── pubring.kbx                                         644
├── pubring.kbx~                                        600
└── trustdb.gpg                                         600


#获取文件权限的方法
find mykey -exec stat -c %n" "%a {} \;

```






## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2022-06-18T16:09:28+08:00

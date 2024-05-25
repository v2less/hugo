---
title: "Gerrit Query"
date: 2024-05-25T07:10:58Z
author: v2less
tags: ["linux"]
draft: false
---
## gerrit query 用法
```bash
ssh -p <port> <host> gerrit query
  [--format {TEXT | JSON}]             --结果集返回格式 默认为‘text’格式 开发中基本上采用‘json’格式
  [--current-patch-set]                --结果集中的当前补丁信息
  [--patch-sets | --all-approvals]     --结果集中的所有补丁信息 ‘all-approvals’字段会输出补丁的详细信息 如果该字段与 ‘current-patch-set’连用，当前补丁信息会输出两次
  [--files]                            --提供一个补丁集和他们属性及大小信息的列表，该字段必须与 ‘patch-sets’或‘current-patch-set’连用
  [--comments]                         --提供所有change的comments信息，如果该字段与‘patch-sets’连用，comments信息会包含在每个补丁集信息中
  [--commit-message]                   --提供完整的change提交信息
  [--dependencies]                     --显示补丁的依赖信息
  [--submit-records]                   --显示change的详细提交信息
  [--all-reviewers]                    --显示所有review人员的名字和邮箱信息
  [--start <n> | -S <n>]               --跳过N笔change后，开始返回结果集
  <query>                              --查询的限制信息
  [limit:<n>]                          --限制结果集返回数量
```
## 常用查询命令
```bash
gerrit_branch=$(ssh -p 29418 $gerrit_url gerrit query --current-patch-set change:${gerrit_change_id} | grep "branch:" | awk '{print $2}')
gerrit_change_url=$(ssh -p 29418 $gerrit_url gerrit query --current-patch-set change:${gerrit_change_id} | grep "url:" | awk '{print $2}')
tb_shortIds=$(ssh -p 29418 $gerrit_url gerrit query --no-limit --commit-message --current-patch-set change:${gerrit_change_id} | grep -e "Bugid:" -e "Bug-id:" | awk -F "Bug*id:" '{print $2}'| tail -n1 | sed 's/ //g')
change_ref=$(ssh -p 29418 $gerrit_url gerrit query --current-patch-set change:${change_id} | sed 's/\s*//g' | grep 'ref:ref' | cut -c5-)
long_name=$(ssh -p 29418 $gerrit_url gerrit query --current-patch-set change:${change_id} | sed 's/\s*//g' | grep 'project:' | cut -c9-)
```
## 比对 项目 开发分支与发布分支合并代码近期差异
### gerrit_query_dev.sh
```bash
#!/bin/bash

GERRIT_HOST="admin@host_ip"
QUERY="status:merged (branch:11_S_vendor_dev OR branch:11_T_MSSI_dev)"
LIMIT=500
OFFSET=0
timestamp="2024-05-17"
result=11_dev_merged.json
rm -f $result
touch $result
while : ; do
    RESULTS=$(ssh -p 29418 $GERRIT_HOST gerrit query --format=JSON "$QUERY" after:$timestamp --start=$OFFSET limit:$LIMIT)
    echo "$RESULTS" >> $result

    # Break the loop if there are no more results
    if [[ $RESULTS == *'"moreChanges":true'* ]]; then
      :
    else
        echo "No more results."
        break
    fi

    # Increase the offset for the next batch
    OFFSET=$((OFFSET + LIMIT))
done
sed -i '/.*"moreChanges":.*/d' $result
# 在每行末尾添加逗号，但不包括最后一行
sed -i '$!s/$/,/' $result

# 在第一行前插入一个开方括号
sed -i '1s/^/[/' $result

# 在最后一行末尾添加一个闭方括号
sed -i '$s/$/]/' $result

# 显示标题
cat $result | python3 -c 'import sys, json; data = json.loads(sys.stdin.read()); [print(item["subject"]) for item in data]' | sort -u
```
输出结果保存为dev.txt
### gerrit_query_release.sh
```bash
#!/bin/bash

GERRIT_HOST="admin@host_ip"
QUERY="status:merged (branch:11_S_vendor_release OR branch:11_T_MSSI_release)"
LIMIT=500
OFFSET=0
timestamp="2024-05-17"
result=11_release_merged.json
rm -f $result
touch $result
while : ; do
    RESULTS=$(ssh -p 29418 $GERRIT_HOST gerrit query --format=JSON "$QUERY" after:$timestamp --start=$OFFSET limit:$LIMIT)
    echo "$RESULTS" >> $result

    # Break the loop if there are no more results
    if [[ $RESULTS == *'"moreChanges":true'* ]]; then
      :
    else
        echo "No more results."
        break
    fi

    # Increase the offset for the next batch
    OFFSET=$((OFFSET + LIMIT))
done
sed -i '/.*"moreChanges":.*/d' $result
# 在每行末尾添加逗号，但不包括最后一行
sed -i '$!s/$/,/' $result

# 在第一行前插入一个开方括号
sed -i '1s/^/[/' $result

# 在最后一行末尾添加一个闭方括号
sed -i '$s/$/]/' $result

# 显示标题
cat $result | python3 -c 'import sys, json; data = json.loads(sys.stdin.read()); [print(item["subject"]) for item in data]' | sort -u
```
输出结果保存为release.txt

## 对比标题差异
diff -u dev.txt release.txt
```bash
diff -u0 dev.txt release.txt |grep "^-"
```





## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2024-05-25T07:10:58Z

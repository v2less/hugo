---
title: "Upload Jenkins Build Result to Influxdb"
date: 2025-07-11T09:08:39+08:00
author: v2less
tags: ["linux"]
draft: false
---

## influxdb
```yaml
services:
  jenkins-influxdb:
    container_name: jenkins-influxdb
    image: influxdb:1.8.10
    restart: always
    environment:
      - INFLUXDB_DB=jenkins_metrics
      - INFLUXDB_ADMIN_USER=admin
      - INFLUXDB_ADMIN_PASSWORD=password
      - TZ=Asia/Shanghai
    ports:
      - "8086:8086"
    volumes:
      - ./influxdb/data:/var/lib/influxdb
```

### 修改配置
默认情况下， InfluxDB 的配置是禁用认证策略的，所以先编辑配置文件 influxdb.conf ，把 [http] 下的 auth-enabled 选项设置为 true ，具体如下：
```bash
docker cp jenkins-influxdb:/etc/influxdb/influxdb.conf .
```

```conf
[meta]
  dir = "/var/lib/influxdb/meta"

[data]
  dir = "/var/lib/influxdb/data"
  engine = "tsm1"
  wal-dir = "/var/lib/influxdb/wal"

[http]
  auth-enabled = true
```

在没启用鉴权时，先启动一次数据库，然后创建账号
```bash
docker exec -it jenkins-influxdb /bin/bash

CREATE USER admin WITH PASSWORD 'password' WITH ALL PRIVILEGES;
```
### 使用自定义配置
```yaml
services:
  jenkins-influxdb:
    container_name: jenkins-influxdb
    image: influxdb:1.8.10
    restart: always
    environment:
      - INFLUXDB_DB=jenkins_metrics
      - INFLUXDB_ADMIN_USER=admin
      - INFLUXDB_ADMIN_PASSWORD=password
      - TZ=Asia/Shanghai
    ports:
      - "8086:8086"
    volumes:
      - ./influxdb/data:/var/lib/influxdb
      - ./influxdb/conf/influxdb.conf:/etc/influxdb/influxdb.conf
```

### 登录influxdb
```bash
docker exec -it jenkins-influxdb /bin/bash

influx -username 'admin' -password 'password'

> show databases;
```
### 备份与恢复
对于一个数据库的基本操作，除了增删改查外，我们还经常需要进行数据的迁移与同步，这就涉及到数据的备份与恢复操作。

备份
```bash
docker exec -it my-influxdb /bin/bash
influxd backup -portable -database test -host 102.102.0.114:8086 /opt/influx
```
导出文件
```bash
docker cp my-influxdb:<path-to-backup> <path-to-restore>
```
恢复
```bash
influxd restore -portable <path-to-restore>
```

清空数据
```bash
use jenkins_metrics;
DELETE FROM jenkins_builds;
```

## 推送构建结果到influxDB
### Jenkinsfile
```groovy
env.build_start_time = "${currentBuild.startTimeInMillis}"
env.build_end_time = System.currentTimeMillis()
def startMs = env.build_start_time.toLong()
def endMs = env.build_end_time.toLong()
def duration = endMs - startMs
env.duration_ms = duration.toString()
echo "【jenkins日志】 build_start_time: ${env.build_start_time}"
echo "【jenkins日志】 build_end_time: ${env.build_end_time}"
echo "【jenkins日志】 build duration_ms: ${env.duration_ms}"
	
sh """#!/bin/bash -x
        python3 cmd/push_to_influxdb.py "${env.JOB_NAME}" "${env.PROC_NAME}" "${env.VERSION_TYPE}" "${env.BUILD_URL}" "${env.BUILD_NUMBER}" "${env.BUILD_VERSION}" "${env.time_stamp}" "${env.BUILD_OTA}" "${env.BUILD_SEC}" "${env.BUILD_MODE}" "${env.FAST_DAILY}" "${currentBuild.currentResult}" "${env.duration_ms}" "${env.user_name}" "${env.DOWNLOAD_URL}" "${env.GERRIT_IDS}" "${env.HQ_GERRIT_IDS}" "${params.COMMIT_MSG}"
    """
```
最好的办法还是集成到编译脚本中，方便获取最终的环境变量：
```bash
post_result_to_influxdb() {
    cd "$basedir" || exit 1
    DOWNLOAD_URL=$(cat "${ROOTPATH}_temp/download_url")
    python3 cmd/push_to_influxdb.py "${JOB_NAME}" "${PROC_NAME}" "${VERSION_TYPE}" "${BUILD_URL}" "${BUILD_NUMBER}" "${BUILD_VERSION}" "${START_TIME}" "${BUILD_OTA}" "${BUILD_SEC}" "${BUILD_MODE}" "${FAST_DAILY}" "${BUILD_RESULT}" "${duration_ms}" "${BUILD_USER}" "${DOWNLOAD_URL}" "${GERRIT_IDS}" "${HQ_GERRIT_IDS}" "${COMMIT_MSG}"
}
```

### 推送脚本
```python3
#!/usr/bin/env python3
"""
Send Jenkins build metrics to InfluxDB using line protocol.
"""

import sys
import time
import requests

INFLUX_URL = "http://10.8.250.192:8086/write?db=jenkins_metrics"
USERNAME = "admin"
PASSWORD = "password"

FIELD_KEYS = [
    "JOB_NAME", "PROC_NAME", "VERSION_TYPE", "BUILD_URL", "BUILD_NUMBER",
    "BUILD_VERSION",
    "TIME_STAMP", "BUILD_OTA", "BUILD_SEC", "BUILD_MODE", "FAST_DAILY",
    "STATUS", "DURATION", "BUILD_USER", "DOWNLOAD_URL", "GERRIT_IDS",
    "HQ_GERRIT_IDS", "COMMIT_MSG"
]


# 判断布尔字段
def to_bool_literal(val: str) -> str:
    return "true" if val.strip().lower() == "true" else "false"


def escape_value(val: str) -> str:
    """Escape special characters for InfluxDB field values."""
    if not val:
        return "\"\""
    val = val.replace("\\", "\\\\").replace("\n", "\\n").replace("\"", "\\\"")
    return f"\"{val}\""


def escape_tag_value(val: str) -> str:
    return val.replace(" ", r"\ ").replace(",", r"\,").replace("=", r"\=")


def main():
    """Main entry: process args and send to InfluxDB"""
    args = sys.argv[1:]
    params = dict(zip(FIELD_KEYS, args + [""] * (len(FIELD_KEYS) - len(args))))
    timestamp_ns = int(time.time() * 1e9)

    tag_set = ",".join([
        f"job={escape_tag_value(params['JOB_NAME'] or 'unknown')}",
        f"user={escape_tag_value(params['BUILD_USER'] or 'unknown')}",
        f"proc={escape_tag_value(params['PROC_NAME'] or 'none')}",
        f"type={escape_tag_value(params['VERSION_TYPE'] or 'none')}",
        f"mode={escape_tag_value(params['BUILD_MODE'] or 'remake')}"
    ])

    field_set = ",".join([
        f"status={escape_value(params['STATUS'])}",
        f"duration_sec={int(int(params['DURATION'] or 0) / 1000)}i",
        f"build_number={int(params['BUILD_NUMBER'] or 0)}i",
        f"build_version={escape_value(params['BUILD_VERSION'])}",
        f"build_sec={to_bool_literal(params['BUILD_SEC'])}",
        f"build_ota={to_bool_literal(params['BUILD_OTA'])}",
        f"download_url={escape_value(params['DOWNLOAD_URL'])}",
        f"gerrit_ids={escape_value(params['GERRIT_IDS'])}",
        f"hq_gerrit_ids={escape_value(params['HQ_GERRIT_IDS'])}",
        f"commit_msg={escape_value(params['COMMIT_MSG'])}",
        f"build_url={escape_value(params['BUILD_URL'])}",
        f"time_stamp={escape_value(params['TIME_STAMP'])}",
        f"fast_daily={to_bool_literal(params['FAST_DAILY'])}"
    ])

    line = f"jenkins_builds,{tag_set} {field_set} {timestamp_ns}"

    try:
        response = requests.post(
            INFLUX_URL,
            data=line.encode('utf-8'),
            auth=(USERNAME, PASSWORD),
            timeout=5
        )
        if response.status_code == 204:
            print("[INFO] ✅ Data written to InfluxDB successfully.")
        else:
            print(f"[ERROR] ❌ Failed to write: HTTP {response.status_code}")
            print(response.text)
            sys.exit(1)
    except requests.RequestException as err:
        print(f"[EXCEPTION] ❌ Request failed: {err}")
        sys.exit(1)


if __name__ == "__main__":
    main()

```
  
  
## Grafana
  
### 面板查询
```sql
SELECT * FROM jenkins_builds WHERE time >= ${__from}ms  AND time < ${__to}ms ORDER BY time DESC
```
单位用ms，和数据库的time单位一致，不然查询会失败。

### override
- 对status进行修改，提高辨识度：
```markdown
SUCCESS		✅ Success
FAILED		❌ Failed
ABORTED		⚠️ Aborted
UNSTABLE		⚠️ Unstable
FAILURE		❌ FAILURE
```
- 显示超链接 Data links
```markdown
URL： ${__value.raw}
```



## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2025-07-11T09:08:39+08:00

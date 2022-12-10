---
title: "ChatGPT写脚本"
date: 2022-12-10T21:17:10+08:00
author: v2less
tags: ["linux"]
draft: false
---

## 问题
```text
用python3写一个http服务，可以远程通过curl发送request，让服务器远程执行脚本：
1. 第一个参数和要执行的脚本要进行匹配判断,两者名字并不相同，匹配时不要用if语句，而用更case之类的或者字典的语法；
2. 限制第一个参数有效范围，不同参数将去匹配执行不同的脚本，脚本输出返回给客户端；
3. 脚本接收传递的其他参数，参数个数不固定；
4. curl传递多个参数用连接符&分割，并给出curl发送get请求的示例；
5. 请输出完毕，不要中断。
```

## chatGPT给出的一个方案
```python3
# coding: utf-8
import http.server
import subprocess


# 定义request_handler类，处理请求
class RequestHandler(http.server.BaseHTTPRequestHandler):
    # 处理get请求
    def do_GET(self):
        # 获取请求参数
        params = self.path.split('&')
        # 获取第一个参数
        script_name = params[0].split('=')[1]
        # 定义脚本字典
        scripts = {
            'top': '/usr/local/bin/top_onetime.sh',
            'test2': 'test2.py'
        }
        # 根据第一个参数，获取要执行的脚本
        script = scripts.get(script_name)
        # 如果脚本存在，则执行脚本
        if script:
            cmd = f'{script}'
            # 获取其他参数
            for param in params[1:]:
                cmd += f' {param}'
            # 执行脚本
            output = subprocess.check_output(cmd, shell=True)
            # 返回结果
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(output)
        # 返回请求完毕
        self.send_response(200)


# 启动http服务
httpd = http.server.HTTPServer(('localhost', 8088), RequestHandler)
httpd.serve_forever()

# 客户端发送请求
# curl http://localhost:8088/\?script_name\=top\&param1&param2
```

## 参考：
- 官网： <https://chat.openai.com/chat>
- 用法： <https://github.com/f/awesome-chatgpt-prompts>


## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2022-12-10T21:17:10+08:00

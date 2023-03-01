---
title: "Ansible: Human Readable Output Format"
date: 2022-06-03T16:04:13+08:00
author: v2less
tags: ["linux"]
draft: false
---



By default Ansible sends output of the plays, tasks and module arguments to `STDOUT` in the format that is not suitable for human reading.

Starting from Ansible 2.5, the default output format can be changed to a human-readable using the callback plugin.

This short note shows how to change the default Ansible’s `JSON` output format to the more human-friendly `YAML` format.



## Ansible Output Format

To change the Ansible’s output format you can pass the `ANSIBLE_STDOUT_CALLBACK=yaml` environment variable on the command line or define the `stdout_callback = yaml` in Ansible configuration file.

Run a playbook and get the output in the human-readable format:

```bash
$ ANSIBLE_STDOUT_CALLBACK=yaml ansible-playbook playbook.yml
```

You can also define the `stdout_callback = yaml` in `ansible.cfg`:

```yaml
[defaults]
# Human-readable output
stdout_callback = yaml
bin_ansible_callbacks = True
```



From: https://www.shellhacks.com/ansible-human-readable-output-format/



## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2022-06-03T16:04:13+08:00

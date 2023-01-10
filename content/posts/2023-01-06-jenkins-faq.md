---
title: "enkins Faq"
date: 2023-01-06T16:03:50+08:00
author: v2less
tags: ["linux"]
draft: false
---

## Jenkins插件和任务备份

Step 1: Go to your Jenkins and click on the Manage Jenkins option.

Step 2: Select Jenkins CLI option from the list of available options.

Step 3: Download jenkins-cli.jar.

```bash
wget <your server url>/jnlpJars/jenkins-cli.jar
```

Step 4: Once you have to download the jar you just run below command.
-  list plugins.

```bash
java -jar jenkins-cli.jar -s <your server url> -auth USER:TOKEN list-plugins
```
-  list jobs.
```bash
java -jar jenkins-cli.jar -s <your server url> -auth USER:TOKEN list-jobs
```
这种cli命令方式并不太好用，放弃用于备份，可以使用其列出插件的名字，用于构建新的jenkins docker镜像。

- 备份插件
ThinBackup

## 常见错误

### 无法执行Jenkinsfile

报错信息：

```java
Error when executing always post condition:
groovy.lang.MissingPropertyException: No such property: rootfsBase for class: WorkflowScript
	at org.codehaus.groovy.runtime.ScriptBytecodeAdapter.unwrap(ScriptBytecodeAdapter.java:66)
	at org.codehaus.groovy.runtime.ScriptBytecodeAdapter.getProperty(ScriptBytecodeAdapter.java:471)
	at org.kohsuke.groovy.sandbox.impl.Checker$7.call(Checker.java:355)
	at org.kohsuke.groovy.sandbox.GroovyInterceptor.onGetProperty(GroovyInterceptor.java:68)
	at org.jenkinsci.plugins.scriptsecurity.sandbox.groovy.SandboxInterceptor.onGetProperty(SandboxInterceptor.java:313)
	at org.kohsuke.groovy.sandbox.impl.Checker$7.call(Checker.java:353)
	at org.kohsuke.groovy.sandbox.impl.Checker.checkedGetProperty(Checker.java:357)
	at com.cloudbees.groovy.cps.sandbox.SandboxInvoker.getProperty(SandboxInvoker.java:29)
	at com.cloudbees.groovy.cps.impl.PropertyAccessBlock.rawGet(PropertyAccessBlock.java:20)
	at WorkflowScript.call_ansible(WorkflowScript:47)
	at WorkflowScript.run(WorkflowScript:232)
	at org.jenkinsci.plugins.pipeline.modeldefinition.ModelInterpreter.delegateAndExecute(ModelInterpreter.groovy:137)
	at org.jenkinsci.plugins.pipeline.modeldefinition.ModelInterpreter.runPostConditions(ModelInterpreter.groovy:761)
	at org.jenkinsci.plugins.pipeline.modeldefinition.ModelInterpreter.catchRequiredContextForNode(ModelInterpreter.groovy:395)
	at org.jenkinsci.plugins.pipeline.modeldefinition.ModelInterpreter.catchRequiredContextForNode(ModelInterpreter.groovy:393)
	at org.jenkinsci.plugins.pipeline.modeldefinition.ModelInterpreter.runPostConditions(ModelInterpreter.groovy:760)
	at com.cloudbees.groovy.cps.CpsDefaultGroovyMethods.each(CpsDefaultGroovyMethods:2030)
	at com.cloudbees.groovy.cps.CpsDefaultGroovyMethods.each(CpsDefaultGroovyMethods:2015)
	at com.cloudbees.groovy.cps.CpsDefaultGroovyMethods.each(CpsDefaultGroovyMethods:2056)
	at org.jenkinsci.plugins.pipeline.modeldefinition.ModelInterpreter.runPostConditions(ModelInterpreter.groovy:750)
	at org.jenkinsci.plugins.pipeline.modeldefinition.ModelInterpreter.runPostConditions(ModelInterpreter.groovy)
	at org.jenkinsci.plugins.pipeline.modeldefinition.ModelInterpreter.executePostBuild(ModelInterpreter.groovy:728)
	at ___cps.transform___(Native Method)
	at com.cloudbees.groovy.cps.impl.PropertyishBlock$ContinuationImpl.get(PropertyishBlock.java:74)
	at com.cloudbees.groovy.cps.LValueBlock$GetAdapter.receive(LValueBlock.java:30)
	at com.cloudbees.groovy.cps.impl.PropertyishBlock$ContinuationImpl.fixName(PropertyishBlock.java:66)
	at jdk.internal.reflect.GeneratedMethodAccessor439.invoke(Unknown Source)
	at java.base/jdk.internal.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
	at java.base/java.lang.reflect.Method.invoke(Method.java:566)
	at com.cloudbees.groovy.cps.impl.ContinuationPtr$ContinuationImpl.receive(ContinuationPtr.java:72)
	at com.cloudbees.groovy.cps.impl.ConstantBlock.eval(ConstantBlock.java:21)
	at com.cloudbees.groovy.cps.Next.step(Next.java:83)
	at com.cloudbees.groovy.cps.Continuable$1.call(Continuable.java:174)
	at com.cloudbees.groovy.cps.Continuable$1.call(Continuable.java:163)
	at org.codehaus.groovy.runtime.GroovyCategorySupport$ThreadCategoryInfo.use(GroovyCategorySupport.java:136)
	at org.codehaus.groovy.runtime.GroovyCategorySupport.use(GroovyCategorySupport.java:275)
	at com.cloudbees.groovy.cps.Continuable.run0(Continuable.java:163)
	at org.jenkinsci.plugins.workflow.cps.SandboxContinuable.access$001(SandboxContinuable.java:18)
	at org.jenkinsci.plugins.workflow.cps.SandboxContinuable.run0(SandboxContinuable.java:51)
	at org.jenkinsci.plugins.workflow.cps.CpsThread.runNextChunk(CpsThread.java:187)
	at org.jenkinsci.plugins.workflow.cps.CpsThreadGroup.run(CpsThreadGroup.java:420)
	at org.jenkinsci.plugins.workflow.cps.CpsThreadGroup.access$400(CpsThreadGroup.java:95)
	at org.jenkinsci.plugins.workflow.cps.CpsThreadGroup$2.call(CpsThreadGroup.java:330)
	at org.jenkinsci.plugins.workflow.cps.CpsThreadGroup$2.call(CpsThreadGroup.java:294)
	at org.jenkinsci.plugins.workflow.cps.CpsVmExecutorService$2.call(CpsVmExecutorService.java:67)
	at java.base/java.util.concurrent.FutureTask.run(FutureTask.java:264)
	at hudson.remoting.SingleLaneExecutorService$1.run(SingleLaneExecutorService.java:139)
	at jenkins.util.ContextResettingExecutorService$1.run(ContextResettingExecutorService.java:28)
	at jenkins.security.ImpersonatingExecutorService$1.run(ImpersonatingExecutorService.java:68)
	at java.base/java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:515)
	at java.base/java.util.concurrent.FutureTask.run(FutureTask.java:264)
	at java.base/java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1128)
	at java.base/java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:628)
	at java.base/java.lang.Thread.run(Thread.java:829)

```

构建节点缺少java运行环境

```bash
sudo apt update -y
sudo apt install openjdk-11-jre -y
```





## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2023-01-06T16:03:50+08:00

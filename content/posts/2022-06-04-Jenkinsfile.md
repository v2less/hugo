---
title: "Jenkinsfile"
date: 2022-06-04T22:28:40+08:00
author: v2less
tags: ["jenkins"]
draft: false
---

## Jenkinsfile

```groovy
//根据gerrit传递过来的参数是否存在来设置全局的环境变量
if (env.GERRIT_BRANCH) {
    env.DEFAULT_BRANCH = "${env.GERRIT_BRANCH}"
}
else {
//如果没有env.GERRIT_BRANCH环境变量则使用参数的值,并当参数为空时设置默认的值
    env.DEFAULT_BRANCH = "${params.branch_param}" ?: 'lineage-18.1'
}

//字符串替换
env.BRANCH_PATH = "${env.DEFAULT_BRANCH}".replaceAll('/','_')

String agentTag = "halium-$haliumVersion"
String artifacts = 'halium*'
//根据JOB_NAME中是否包含特定的字符串来判断设置变量
if (env.JOB_NAME.contains("halium9.0")) {
    up_project = "xenial-hybris-android9-rootfs-arm64" + "_" + "${env.JOB_NAME}".split('_').last()
} else if (env.JOB_NAME.contains("halium10.0")) {
    up_project = "xenial-hybris-android9-android10-rootfs-arm64" + "_" + "${env.JOB_NAME}".split('_').last()
} else if (env.JOB_NAME.contains("linux-halium11.0")) {
    up_project = "rootfs-arm64-linux" + "_" + "${env.JOB_NAME}".split('_').last()
} else if (env.JOB_NAME.contains("halium11.0")) {
    up_project = "xenial-hybris-android9-android11-rootfs-arm64" + "_" + "${env.JOB_NAME}".split('_').last()
}


pipeline {
    //agent any
    //agent { label "$agentTag" }
    //使用docker构建
    agent {
        docker {
        //使用双引号,用变量来指定docker镜像
        image "ci-${env.docker_build_ver}-arm64:latest"
        //使用变量来指定label构建用的节点
        label "$agentTag"
        args "--net=host -v /data:/build -u jenkins --privileged --cpus=32 --memory=49152m --entrypoint=''"
        alwaysPull true
        }
    }
    environment {
        CC = 'clang'
        PATH = "/usr/local/tools/bin:$PATH"
        _version = createVersion(BUILD_NUMBER)
    }
    //参数化
    parameters {
        string(
            name: 'branch_param',
            defaultValue: "${DEFAULT_BRANCH}",
            description: """The branch name:
                          lineage-18.1,
                          lineage-17.1"""
        )
        choice(
            choices: ['ONE', 'TWO'],
            name: 'PARAMETER_01'
        )
        booleanParam(
            defaultValue: true,
            description: '',
            name: 'BOOLEAN'
        )
        text(
            defaultValue: '''
                                this is a multi-line
                                string parameter example
                                ''',
            name: 'MULTI-LINE-STRING'
        )
        string(
            defaultValue: 'scriptcrunch',
            name: 'STRING-PARAMETER',
            trim: true
        )
        //mask-passwords插件
        password(name: 'KEY', description: 'Encryption key')
    }
    options {
        //设置在项目打印日志时带上对应时间
        timestamps()
        //保存最近历史构建记录的数量
        buildDiscarder(logRotator(numToKeepStr: '5'))
        //禁止pipeline同时执行 存在抢占资源或调用冲突的场景下，此选项非常有用
        disableConcurrentBuilds()
        //当失败时，指定整个pipeline的重试次数，可以放在stage块中
        retry(4)
        //超时时间，HOURS（小时） SECONDS（秒） MINUTES（分钟）为单位
        timeout(time: 25, unit: 'MINUTES')
    }
    //设置定时任务
   triggers {
      //由上游任务触发
      upstream(upstreamProjects: "${up_project}", threshold: hudson.model.Result.SUCCESS)
      //定时构建
      cron('H 1 * * *')
    }

    stages {
        stage("init") {
            when {
                allOf {
                    anyOf {
                        expression { params.GERRIT_IDS.toString() != '' }
                        expression { params.HQ_GERRIT_IDS.toString() != '' }
                    }
                    expression { params.INIT.toBoolean() }
                }
            }
            steps {
                //copy artifact 插件
                copyArtifacts(projectName: "${JOB_NAME}",
                            selector: lastSuccessful(),
                            optional: true)
                )

                when {
                    branch "master";
                    buildingTag();
                    //conditional buildstep插件
                    expression { return params.CHOICE == 'test'}
                }
                //在声明式pipeline中使用脚本
                script {
                    //jenkins构建任务显示的名字和描述
                    currentBuild.displayName = "${BUILD_ID}"
                    currentBuild.description = "${env.DEFAULT_BRANCH}"
                    def mvnHome = tool 'Maven 3.3.9'
                    //判断是否为类unix系统
                    if (isUnix()) {
                        // just to trigger the integration test without unit testing
                        //sh执行shell命令
                        sh "'${mvnHome}/bin/mvn'  verify -Dunit-tests.skip=true"
                    } else {
                        bat(/"${mvnHome}\bin\mvn" verify -Dunit-tests.skip=true/)
                    }

                }
                sh 'ls'
            }
        }
        stage('Sonar scan result check') {
            steps {
                //让pipeline休眠一段时间,unit（可选）：时间单位，支持的值有NANOSECONDS、MICROSECONDS、MILLISECONDS、SECONDS（默认）、MINUTES、HOURS、DAYS。
                sleep(time: '2', unit:"MINUS")
                timeout(time: 2, unit: 'MINUTES') {
                    retry(3) {
                        script {
                            def qg = waitForQualityGate()
                            if (qg.status != 'OK') {
                                //主动报错，中止当前pipeline
                                error "Pipeline aborted due to quality gate failure: ${qg.status}"
                            }
                        }
                    }
                }
            }
        }
    }
    post {
        // Always runs. And it runs before any of the other post conditions.
        always {
            //归档制品
            archiveArtifacts(artifacts: artifacts, fingerprint: true, onlyIfSuccessful: true, allowEmptyArchive: false)
            // deleteDir是一个无参步骤，删除的是当前工作目录。通常它与dir步骤一起使用，用于删除指定目录下的内容
            deleteDir()
            dir("/var/tmp") {
                deleteDir()
            }
            //安装Workspace Cleanup插件, 清理工作空间
            cleanWs()
        }
        success {
            script {
                if ( user_name ) {
                    echo '成功'
                }
                def downUrl = "${env.job_work_dir}_temp/download_url"
                if (fileExists(downUrl)) {
                    echo "download_url File exists. Reading content..."
                    env.DOWNLOAD_URL = readFile(file: downUrl).trim()
                    String description = "<a href='${env.DOWNLOAD_URL}' target='_blank'>Download</a>"
                    currentBuild.description = "${env.PROC_NAME} " +  "${env.BUILD_VERSION} \n" +
                                                "${env.BUILD_MODE} " + "${env.BUILD_EDITION} \n" +
                                                "${description}"
                    sh """#!/bin/bash -x
                        python3 cmd/robot.py --result Success --proc_name ${env.PROC_NAME} --build_url ${env.BUILD_URL} --version_type ${env.VERSION_TYPE} --time_stamp ${env.time_stamp} --update_app ${env.update_app} --build_user ${env.USER} --job_name ${env.JOB_NAME} --download_url ${env.DOWNLOAD_URL}
                    """
                    sh "rm -f ${downUrl}"
                    echo "download_url File deleted."
                }
            }
            echo "【jenkins日志】 最终结果:成功,工作名:${JOB_NAME},工作号:${BUILD_NUMBER}"
            sendEmail("Successful");
        }
        unstable {
            sendEmail("Unstable");
        }
        failure {
            sendEmail("Failed");
        }
        cleanup {
            echo "【jenkins日志】 处理遗留文件"
            deleteDir()
            cleanWs()
        }
    }
}

def createVersion(String BUILD_NUMBER) {
    return new Date().format('yyMM') + "-${BUILD_NUMBER}"
}
```





## 插件

- green balls

构建成功的状态图表显示绿色

- Periodic Backup

实现Jenkins的备份

- Prometheus

Prometheus是pull模式收集指标数据

- Metrics

可以提供job构建时间和git来源等，以及api.

## 工具

- ansible-role-jenkins

https：//github.com/geerlingguy/ansible-role-jenkins

- prometheus-ansble

https：//github.com/ernestas-poskus/ansible-prometheus

- 将制品交给Nexus管理

需要java环境


## 升级到最新版

```bash
wget http://updates.jenkins-ci.org/download/war/latest/jenkins.war
cp /usr/share/java/jenkins.war jenkins.war.pre
sudo cp jenkins.war /usr/share/java/jenkins.war
sudo systemctl restart jenkins.service
```



## 文档信息
---
- 版权声明：自由转载-非商用-非衍生-保持署名（[创意共享3.0许可证](https://creativecommons.org/licenses/by-nc-nd/3.0/deed.zh)）
- 发表日期： 2022-06-04T22:28:40+08:00

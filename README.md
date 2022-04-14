# v2ray

> 镜像名 `v2ray`

本Docker镜像主要包含了v2ray和supervisor。用于制作很多国内服务器上运行需访问外网服务镜像的基础镜像。

A container’s main running process is the ENTRYPOINT and/or CMD at the end of the Dockerfile. It is generally recommended that you separate areas of concern by using one service per container. That service may fork into multiple processes (for example, Apache web server starts multiple worker processes). It’s ok to have multiple processes, but to get the most benefit out of Docker, avoid one container being responsible for multiple aspects of your overall application. You can connect multiple containers using user-defined networks and shared volumes.

The container’s main process is responsible for managing all processes that it starts. In some cases, the main process isn’t well-designed, and doesn’t handle “reaping” (stopping) child processes gracefully when the container exits. If your process falls into this category, you can use the --init option when you run the container. The --init flag inserts a tiny init-process into the container as the main process, and handles reaping of all processes when the container exits. Handling such processes this way is superior to using a full-fledged init process such as sysvinit, upstart, or systemd to handle process lifecycle within your container.

考虑使用便捷，本项目采用supervisor做进程守护和多进程管理。

### v2ray配置

关于v2ray的配置可以参考 [v2ray.com](https://www.v2ray.com/) 官网描述。本项目默认的配置是我自己的一个私有配置，在有效期内可以一直使用。

目前的配置是默认请求均不走代理，仅指定的域名走代理，配置见: routing -> settings -> rules。

### 基于本镜像做业务服务镜像

> 代理的速度毕竟不高，在日常开发或测试环境可以使用，但在生产环节还是不要用本方式。

#### 自定义业务服务的supervisor配置

```conf
# supervisord.conf

[program:bs]
command=/app/bs --cnf=cnf.json
directory=/app
user=root
autostart=true
autorestart=true
startsecs=3
```

#### 示例Dockerfile

```Dockerfile
# Dockerfile

FROM v2ray:latest

WORKDIR /app

EXPOSE 90

# 拷贝业务服务可执行文件
COPY --from=go-builder /go/bin/bs ./
# 拷贝业务服务配置
COPY configs ./
# 拷贝业务服务supervisor配置
COPY supervisord.conf /etc/supervisor/conf.d/bs.conf

# -n 前台运行
ENTRYPOINT [ "supervisord" ]
CMD [ "-n" ]
```

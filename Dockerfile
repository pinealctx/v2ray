FROM ubuntu:18.04

ENV TZ=Asia/Shanghai

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \ 
    && apt-get install -y supervisor tzdata openssl ca-certificates wget unzip curl \
    && ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    && mkdir -p /var/log/supervisor

WORKDIR /v2ray

RUN wget -O v2ray.zip https://github.com/v2fly/v2ray-core/releases/download/v5.0.3/v2ray-linux-64.zip \
    && unzip v2ray.zip \
    && chmod +x v2ray

COPY config.json /v2ray/config.json

COPY v2ray.conf /etc/supervisor/conf.d/v2ray.conf

ENV http_proxy=http://127.0.0.1:1087 https_proxy=http://127.0.0.1:1087 ALL_PROXY=socks5://127.0.0.1:1080

ENTRYPOINT [ "supervisord" ]
CMD [ "-n" ]
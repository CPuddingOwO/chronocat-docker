# 使用基于Ubuntu 22.04的基础映像
FROM ubuntu:22.04
FROM python:3.10.14-slim

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV VNC_PASSWD=vncpasswd
ENV CC_TAG=v0.2.11
ENV QQ_TAG=QQ_3.2.9_240617_amd64_01.deb

# 安装必要的软件包
RUN apt-get update && apt-get install -y \
    openbox \
    curl \
    unzip \
    x11vnc \
    xvfb \
    fluxbox \
    supervisor \
    libnotify4 \
    libnss3 \
    xdg-utils \
    libsecret-1-0 \
    libgbm1 \
    libasound2 \
    fonts-wqy-zenhei \
    git \
    gnutls-bin \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

#  安装novnc
RUN git config --global http.sslVerify false && git config --global http.postBuffer 1048576000 \
  && cd /opt && git clone https://github.com/novnc/noVNC.git \
  && cd /opt/noVNC/utils && git clone https://github.com/novnc/websockify.git \
  && cp /opt/noVNC/vnc.html /opt/noVNC/index.html \
  && pip install numpy


# 安装Linux QQ
RUN curl -o /root/qq_inst.deb https://dldir1.qq.com/qqfile/qq/QQNT/Linux/${QQ_TAG}

RUN dpkg -i /root/qq_inst.deb \
  && apt-get -f install -y && rm /root/qq_inst.deb

# 安装LiteLoader
# 修改/opt/QQ/resources\app\app_launcher\index.js
RUN git clone --depth 1 https://github.com/LiteLoaderQQNT/LiteLoaderQQNT.git /opt/QQ/resources/app/LiteLoaderQQNT \
    && sed -i "1i\require(\`/opt/QQ/resources/app/LiteLoaderQQNT\`);" /opt/QQ/resources/app/app_launcher/index.js


# 安装chronocat + API + Event 引擎
RUN curl -L -o /tmp/chronocat-llqqnt.zip https://github.com/chrononeko/chronocat/releases/download/${CC_TAG}/chronocat-llqqnt-v0.2.11.zip \
  && mkdir -p /opt/QQ/resources/app/LiteLoaderQQNT/plugins/ \
  && unzip /tmp/chronocat-llqqnt.zip -d /opt/QQ/resources/app/LiteLoaderQQNT/plugins/ \
  && rm /tmp/chronocat-llqqnt.zip \
  && curl -L -o /tmp/chronocat-llqqnt-api.zip https://github.com/chrononeko/chronocat/releases/download/${CC_TAG}/chronocat-llqqnt-engine-chronocat-api-v0.2.11.zip \
  && unzip /tmp/chronocat-llqqnt-api.zip -d /opt/QQ/resources/app/LiteLoaderQQNT/plugins/ \
  && rm /tmp/chronocat-llqqnt-api.zip \
  && curl -L -o /tmp/chronocat-llqqnt-event.zip https://github.com/chrononeko/chronocat/releases/download/${CC_TAG}/chronocat-llqqnt-engine-chronocat-event-v0.2.11.zip \
  && unzip /tmp/chronocat-llqqnt-event.zip -d /opt/QQ/resources/app/LiteLoaderQQNT/plugins/ \
  && rm /tmp/chronocat-llqqnt-event.zip


# 创建必要的目录
RUN mkdir -p ~/.vnc

# 创建启动脚本
RUN echo "#!/bin/bash" > ~/start.sh \
  && echo "rm /tmp/.X1-lock" >> ~/start.sh \
  && echo "Xvfb :1 -screen 0 1280x1024x16 &" >> ~/start.sh \
  && echo "export DISPLAY=:1" >> ~/start.sh \
  && echo "fluxbox &" >> ~/start.sh \
  && echo "x11vnc -display :1 -noxrecord -noxfixes -noxdamage -forever -rfbauth ~/.vnc/passwd &" >> ~/start.sh \
  && echo "nohup /opt/noVNC/utils/novnc_proxy --vnc localhost:5900 --listen 6081 --file-only &" >> ~/start.sh \
  && echo "x11vnc -storepasswd \$VNC_PASSWD ~/.vnc/passwd" >> ~/start.sh \
  && echo "su -c 'qq --no-sandbox' root" >> ~/start.sh \
  && chmod +x ~/start.sh

# 配置supervisor
RUN echo "[supervisord]" > /etc/supervisor/supervisord.conf \
  && echo "nodaemon=true" >> /etc/supervisor/supervisord.conf \
  && echo "[program:x11vnc]" >> /etc/supervisor/supervisord.conf \
  && echo "command=/usr/bin/x11vnc -display :1 -noxrecord -noxfixes -noxdamage -forever -rfbauth ~/.vnc/passwd" >> /etc/supervisor/supervisord.conf

# 设置容器启动时运行的命令
CMD ["/bin/bash", "-c", "/root/start.sh"]


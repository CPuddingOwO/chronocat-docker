# chronocat-docker

本仓库是学习docker的打包与自动化构建，请下载后24小时内删除

## 使用

## 环境变量

> ENV : DEC : DEF
> 
> 变量名 : 描述 : 默认值

CC_TAG : Chronocat VerTAG : v0.2.11

QQ_TAG : QQNT VerTAG : QQ_3.2.9_240617_amd64_01.deb

VNC_PASSWD : VNC Password

## 储存卷

> /root/.chronocat/config/ - Chronocat Config
> 
> /root/.config/QQ - QQ Data 
> 
> /opt/QQ/resources/app/LiteLoaderQQNT/plugins - Liteloader QQNT Plugins 

### 快速运行

```bash
docker run -d --name cpudding/chronocat-docker \
 -e VNC_PASSWD=vncpasswd \
 -p 5500:5500 \
 -p 5900:5900 \
 -p 6081:6081 \
 -v ./CCDocker/config:/root/.chronocat/config \
 -v ./CCDocker/data:/root/.config/QQ \
 -v ./CCDocker/plugins:/opt/QQ/resources/app/LiteLoaderQQNT/plugins \
 cpudding/chronocat-docker
```

or docker-compose.yml

```bash
docker-compose up -d
```

### noVNC登陆

浏览器访问`http://IP:6081`，默认密码是`vncpasswd`

### VNC登陆

使用VNC软件登陆`IP:5900`，默认密码是`vncpasswd`

### 修改VNC密码

```bash
docker exec chronocat-docker sh -c "x11vnc -storepasswd newpasswd /root/.vnc/passwd"
```

其中newpasswd换成你的新密码，立即生效，无需重启容器

## 如何更新

本镜像一般不会只更新chronocat，如果需要只更新chronocat可以使用LiteLoaderQQNT自行更新

1. 更新前请做好数据备份，比如数据固化

2. 删除容器并删除镜像，下面是代码示例

   ```bash
   docker rm -f chronocat-docker && docker rmi cpudding/chronocat-docker
   ```

3. 重新pull最近镜像
4. 
   ```bash
   docker pull cpudding/chronocat-docker
   ```
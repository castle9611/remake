# 人生重开模拟器

<a href="https://discord.gg/U3qrf49NMQ"><img src="https://img.shields.io/discord/883382868427014255?color=%23FEE75C&label=Discord&logo=discord&logoColor=white&style=for-the-badge" /></a>

[English](./README.md) | 简体中文

## 开发环境

包管理: `pnpm`
运行时: `bun`

## 使用

### Linux 一键部署（无需 Docker）

将**本版本部署包**上传到服务器，解压后执行（须包含 `deploy/web` 中已构建的网页）：

```bash
sudo bash deploy.sh
```

完成后访问 `http://服务器IP:8080`。使用其他端口，例如 9000：

```bash
sudo bash deploy.sh 9000
```

- 支持使用 systemd 的 Ubuntu 22.04+、Debian 12+，以及 Rocky/AlmaLinux 9+、Fedora；架构为 x86_64 或 ARM64。
- 部署包已包含构建产物，服务器不下载 Node.js、Bun 或 npm 依赖，不访问 GitHub。仅在 Nginx、curl、ss 缺失时从系统软件源安装；依赖齐全时跳过软件包下载。
- 脚本将 `deploy/web` 发布到 `/var/www/remake`，Nginx 配置为 `/etc/nginx/conf.d/remake.conf`，并设置开机启动。
- 不设置自动更新，不需要一直运行 Node.js/Bun，也不需要数据库。游戏存档保存在浏览器本地；更换域名或端口后浏览器会使用不同存档空间。
- 请在服务器防火墙和云安全组中放行所选 TCP 端口；脚本不会修改防火墙规则。若服务器已有网站，请使用未占用的端口。
- 为避免覆盖现有内容，如果上述发布目录或配置文件已存在，脚本会停止。若部署中途失败，先查看错误并备份已有文件，再清理这两个路径后重新执行。
- 在启用 SELinux 的系统中会将所选端口配置为 HTTP 标签（`http_port_t`）；请为本项目选择独立端口。

常用管理命令：

```bash
sudo nginx -t                     # 检查配置
sudo systemctl status nginx       # 查看服务状态
sudo systemctl reload nginx       # 重载配置（影响此 Nginx 的全部站点）
curl http://127.0.0.1:8080/healthz # 健康检查，返回 ok
```

部署脚本的参数与语法检查：`bash tests/deploy-check.sh`。

### 开发

```bash
pnpm build:data
pnpm dev
```

若修改源码，需要在开发电脑重新构建并更新部署包中的静态文件：

```bash
pnpm build:data
pnpm build:web
cp -R apps/web/dist/. deploy/web/
```

# Remake

<a href="https://discord.gg/U3qrf49NMQ"><img src="https://img.shields.io/discord/883382868427014255?color=%23FEE75C&label=Discord&logo=discord&logoColor=white&style=for-the-badge" /></a>

English | [简体中文](./README-zh_CN.md)

## Environment

Package Manager: `pnpm`
Runtime: `bun`

## Usage

### Linux deployment (no Docker)

Upload this version's deployment package (including the prebuilt `deploy/web`) and run:

```bash
sudo bash deploy.sh        # http://SERVER-IP:8080
# Or choose an unused port:
sudo bash deploy.sh 9000
```

Requires systemd, Ubuntu 22.04+/Debian 12+ or a dnf-based distribution
(Rocky/AlmaLinux 9+, Fedora), and x86_64/ARM64. The script installs missing
system dependencies and publishes prebuilt assets to `/var/www/remake` with
`/etc/nginx/conf.d/remake.conf`. No Node.js, Bun, npm or GitHub downloads are
needed on the server. Existing dependencies skip package installation. Only Nginx is
needed afterwards; it starts at boot. No automatic updates are configured.
Allow the chosen TCP port in your firewall/cloud security group. Existing
deployment paths are never overwritten. Game saves remain in browser storage.
See [the Chinese deployment guide](./README-zh_CN.md) for details and recovery.

### Dev

```bash
pnpm build:data
pnpm dev
```

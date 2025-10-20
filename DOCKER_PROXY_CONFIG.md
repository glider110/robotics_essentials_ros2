# Docker 网络代理配置文档

## 概述
本文档记录了在使用VPN代理环境下配置Docker网络连接的解决方案，主要解决Docker构建时出现的网络超时和TLS握手失败问题。

## 问题描述
在使用Clash等代理工具时，Docker构建可能会遇到以下错误：
- `failed to solve: DeadlineExceeded: failed to fetch oauth token`
- `TLS handshake timeout`
- `dial tcp [IPv6地址]:443: i/o timeout`

## 解决方案

### 1. Docker Daemon 代理配置

**文件路径**: `/etc/systemd/system/docker.service.d/proxy.conf`

```properties
[Service]
Environment="HTTP_PROXY=http://127.0.0.1:7890"
Environment="HTTPS_PROXY=http://127.0.0.1:7890" 
Environment="NO_PROXY=localhost,127.0.0.1,::1"
Environment="GODEBUG=netdns=go"
```

**配置说明**:
- `HTTP_PROXY` & `HTTPS_PROXY`: 设置代理服务器地址（Clash默认端口7890）
- `NO_PROXY`: 指定不使用代理的地址范围
- `GODEBUG=netdns=go`: 强制使用Go的DNS解析器，避免系统DNS解析问题

### 2. Docker Daemon 配置文件

**文件路径**: `/etc/docker/daemon.json`

```json
{
  "dns": ["8.8.8.8", "1.1.1.1"],
  "ipv6": false,
  "ip6tables": false,
  "experimental": false,
  "debug": false
}
```

**配置说明**:
- `dns`: 使用Google DNS (8.8.8.8) 和 Cloudflare DNS (1.1.1.1)
- `ipv6`: 禁用IPv6，避免IPv6连接问题
- `ip6tables`: 禁用IPv6 iptables规则
- `experimental`: 禁用Docker实验性功能
- `debug`: 禁用调试模式

## 部署步骤

### 1. 创建代理配置目录
```bash
sudo mkdir -p /etc/systemd/system/docker.service.d/
```

### 2. 创建代理配置文件
```bash
sudo tee /etc/systemd/system/docker.service.d/proxy.conf > /dev/null << 'EOF'
[Service]
Environment="HTTP_PROXY=http://127.0.0.1:7890"
Environment="HTTPS_PROXY=http://127.0.0.1:7890" 
Environment="NO_PROXY=localhost,127.0.0.1,::1"
Environment="GODEBUG=netdns=go"
EOF
```

### 3. 创建或修改daemon.json配置
```bash
sudo tee /etc/docker/daemon.json > /dev/null << 'EOF'
{
  "dns": ["8.8.8.8", "1.1.1.1"],
  "ipv6": false,
  "ip6tables": false,
  "experimental": false,
  "debug": false
}
EOF
```

### 4. 重新加载并重启Docker服务
```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```

### 5. 验证配置
```bash
# 检查Docker信息中的代理设置
docker info | grep -i proxy

# 测试拉取镜像
docker pull hello-world
```

## 验证方法

### 检查代理配置是否生效
```bash
docker info | grep -i proxy
```

预期输出:
```
HTTP Proxy: http://127.0.0.1:7890
HTTPS Proxy: http://127.0.0.1:7890
No Proxy: localhost,127.0.0.1,::1
```

### 检查Docker服务状态
```bash
sudo systemctl status docker
```

### 测试网络连接
```bash
# 测试小镜像拉取
docker pull hello-world

# 测试项目构建
docker compose up --build -d
```

## 故障排除

### 1. 代理服务检查
确保代理服务正在运行:
```bash
netstat -tlnp | grep 7890
```

### 2. JSON格式验证
验证daemon.json格式正确:
```bash
sudo cat /etc/docker/daemon.json | python3 -m json.tool
```

### 3. 查看Docker错误日志
```bash
sudo journalctl -xeu docker.service --no-pager -n 20
```

### 4. 重置配置
如果配置有问题，可以恢复默认设置:
```bash
# 备份当前配置
sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.backup

# 恢复最小配置
echo '{"dns": ["8.8.8.8", "1.1.1.1"]}' | sudo tee /etc/docker/daemon.json

# 重启服务
sudo systemctl restart docker
```

## 注意事项

1. **代理端口**: 确保代理服务运行在配置的端口（默认7890）
2. **权限**: 所有配置文件修改都需要sudo权限
3. **服务重启**: 每次修改配置后必须重启Docker服务
4. **网络环境**: 此配置适用于使用Clash等代理工具的网络环境
5. **IPv6**: 如果网络环境需要IPv6，请将`"ipv6": false`和`"ip6tables": false`改为`true`

## 相关文件位置

- Docker systemd代理配置: `/etc/systemd/system/docker.service.d/proxy.conf`
- Docker daemon配置: `/etc/docker/daemon.json`
- Docker服务文件: `/lib/systemd/system/docker.service`

## 参考资料

- [Docker官方代理配置文档](https://docs.docker.com/config/daemon/systemd/#httphttps-proxy)
- [Docker Registry Mirror配置](https://docs.docker.com/registry/recipes/mirror/)
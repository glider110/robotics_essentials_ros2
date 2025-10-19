# Docker 容器保存脚本使用说明

## 概述
这些脚本帮助您将当前运行的Docker容器保存为新镜像，避免每次都要重新构建Dockerfile。

## 脚本说明

### 1. `save_container.sh` - 完整功能脚本
**功能：**
- 检查容器运行状态
- 保存容器为新镜像
- 自动创建新的docker-compose配置
- 可选择是否替换原配置文件
- 提供详细的操作提示

**使用方法：**
```bash
cd docker
./save_container.sh
```

### 2. `quick_save.sh` - 快速保存脚本
**功能：**
- 快速保存容器为带时间戳的镜像
- 简单易用，适合日常快照

**使用方法：**
```bash
cd docker
./quick_save.sh
```

## 使用流程

### 首次使用
1. 确保容器正在运行：
   ```bash
   docker compose up -d
   ```

2. 在容器中进行您的配置和安装

3. 运行保存脚本：
   ```bash
   ./save_container.sh
   ```

4. 选择是否替换原docker-compose文件

### 后续使用
保存完成后，下次启动容器时：
```bash
docker compose up -d
```
将直接使用保存的镜像，无需重新构建。

## 注意事项

1. **镜像大小**: 保存的镜像可能比较大，包含了所有安装的软件和配置

2. **存储空间**: 定期清理不需要的镜像：
   ```bash
   docker image prune
   docker rmi <镜像名>
   ```

3. **备份**: 原docker-compose.yaml会被自动备份（如果选择替换）

4. **版本管理**: 可以保存多个版本的镜像，通过不同的标签区分

## 手动操作（了解原理）

如果您想手动执行，可以按以下步骤：

1. 保存容器为镜像：
   ```bash
   docker commit robotics_essentials_ros2 my_saved_image:latest
   ```

2. 修改docker-compose.yaml：
   ```yaml
   services:
     robotics_essentials_ros2:
       image: my_saved_image:latest
       # 注释掉build部分
       # build:
       #   context: ..
       #   dockerfile: docker/Dockerfile
   ```

## 故障排除

**容器未运行错误：**
- 确保先启动容器：`docker compose up -d`

**权限错误：**
- 确保脚本有执行权限：`chmod +x *.sh`

**磁盘空间不足：**
- 清理不需要的镜像和容器：`docker system prune`

## 优势
- ✅ 避免重复构建
- ✅ 保存当前配置状态
- ✅ 快速启动
- ✅ 减少网络下载
- ✅ 一致的环境
# Docker 配置更改说明

## 更改内容

已将 `andino_gz` 包的处理方式从 Docker 内部克隆改为外部挂载：

### 1. Dockerfile 修改
- 移除了内部 git 克隆 `andino_gz` 的代码
- 移除了相关的 git 配置
- 保留了注释说明该包应该从主机的 packages/ 目录挂载

### 2. docker-compose.yaml 修改
- 添加了 packages 目录的挂载配置：
  ```yaml
  - ./packages:/home/user/ros2_ws/src/packages
  ```

### 3. 新增文档
- 在 `packages/README.md` 中添加了包管理说明
- 在主 `README.md` 中添加了设置说明

## 使用方法

1. 首先克隆所需的 `andino_gz` 包：
   ```bash
   cd packages
   git clone --depth 1 https://github.com/Ekumen-OS/andino_gz.git -b 0.1.1
   ```

2. 启动 Docker 容器：
   ```bash
   cd docker
   docker compose up -d
   ```

3. 包会自动挂载到容器内的 `/home/user/ros2_ws/src/packages/` 目录

## 优势

1. **开发便利性**：可以在主机上直接编辑代码，无需重新构建 Docker 镜像
2. **灵活性**：可以轻松切换不同版本的 `andino_gz` 包
3. **构建速度**：Docker 镜像构建更快，因为不需要克隆外部仓库
4. **离线开发**：一旦克隆完成，可以离线开发

## 注意事项

- 确保在首次运行前先克隆 `andino_gz` 包
- 包的更改会直接反映在容器中
- 如果需要重新构建包，在容器内运行 `colcon build`
# Brick X Webapp

Brick X Web 应用，提供用户界面和静态文件服务。

## 🏗️ 架构

### 功能特性
- **Vue.js 前端** - 现代化的单页应用
- **Nginx 服务** - 高性能静态文件服务
- **JWT 验证** - 集成认证服务
- **响应式设计** - 适配各种设备
- **容器化部署** - 完整的 Docker 支持

### 技术栈
- **前端**: Vue.js 3 + Vue CLI
- **服务**: Nginx + Alpine Linux
- **构建**: Node.js 20 + npm
- **容器**: Docker + 多阶段构建
- **端口**: 17100

## 🚀 快速开始

### 构建镜像
```bash
./scripts/build.sh
```

### 启动服务
```bash
./scripts/run.sh start
```

### 检查状态
```bash
./scripts/run.sh status
```

### 查看日志
```bash
./scripts/run.sh logs
```

### 停止服务
```bash
./scripts/run.sh stop
```

## 📋 脚本

### 构建脚本
- **`scripts/build.sh`** - 构建 Docker 镜像
- **`scripts/generate_keys.sh`** - 生成 RSA 密钥对

### 运行脚本
- **`scripts/run.sh`** - 容器生命周期管理

## 🔧 配置

### 环境变量
- `TZ=UTC` - 时区设置

### 端口
- **17100** - HTTP Web 服务端口

### 端点
- `GET /` - 主页
- `GET /js/*` - JavaScript 文件
- `GET /css/*` - CSS 样式文件
- `GET /img/*` - 图片资源

## 🌐 用户界面

### 主页功能
- **登录界面** - 用户认证
- **设备连接** - X 设备连接管理
- **状态显示** - 服务健康状态
- **响应式布局** - 移动端适配

### 页面结构
```
/
├── 登录页面
├── 设备管理
├── 状态监控
└── 设置页面
```

## 🔒 安全

### RSA 密钥
- **公钥**: `public.pem` - 用于 JWT 验证
- **Nginx 配置** - 集成 JWT 验证
- **HTTPS 就绪** - 支持 SSL/TLS

### 认证集成
- 与 auth service 集成
- JWT 令牌验证
- 用户会话管理

## 📊 监控

### 健康检查
```bash
curl http://localhost:17100/
```

### 构建信息
- 版本信息嵌入到镜像中
- 构建时间戳记录
- 环境信息追踪

## 🐛 故障排除

### 常见问题

1. **构建失败**
   ```bash
   # 清理并重新构建
   ./scripts/run.sh clean
   ./scripts/build.sh
   ```

2. **端口被占用**
   ```bash
   # 检查端口使用
   sudo lsof -i :17100
   
   # 停止现有容器
   ./scripts/run.sh stop
   ```

3. **页面无法访问**
   ```bash
   # 检查容器状态
   ./scripts/run.sh status
   
   # 查看日志
   ./scripts/run.sh logs
   ```

### 调试命令
```bash
# 检查容器状态
./scripts/run.sh status

# 查看详细日志
./scripts/run.sh logs -f

# 测试页面访问
curl http://localhost:17100/

# 检查容器详情
docker inspect el-brick-x-webapp
```

## 🎯 最佳实践

1. **先构建再运行** - 确保镜像存在
2. **检查页面访问** - 启动后验证页面正常
3. **监控日志** - 使用 `./scripts/run.sh logs` 查看输出
4. **定期更新密钥** - 定期重新生成 RSA 密钥对
5. **备份配置** - 备份 nginx 配置和密钥文件

## 📞 支持

如有问题或疑问：
1. 检查服务状态: `./scripts/run.sh status`
2. 查看服务日志: `./scripts/run.sh logs`
3. 验证页面访问: 浏览器访问 http://localhost:17100
4. 确认密钥文件: 检查 `public.pem`
5. 测试端点: 使用 curl 测试页面访问 
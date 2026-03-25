# devcontainer 集成详细指南

## 📌 什么是 devcontainer？

devcontainer 是 VS Code 的一个功能，允许你将**开发环境定义为代码**。

**好处**：
- ✓ 团队所有成员获得完全相同的环境
- ✓ Codespaces 启动时自动配置（无需手动运行脚本）
- ✓ 环境配置版本控制 — 可以 git 提交
- ✓ 可重复再现 — 新来的开发者直接获得完整环境

## 🚀 快速设置（5分钟）

### 步骤 1：复制 devcontainer 目录

```bash
# 在项目根目录运行
cp -r codespace-setup/devcontainer/ .devcontainer/
```

现在你的项目有：
```
.devcontainer/
├── devcontainer.json      # VS Code 配置
└── install-gstack.sh      # 自动安装脚本
```

### 步骤 2：提交到 git

```bash
git add .devcontainer/
git commit -m "feat: add devcontainer with gstack setup"
git push
```

### 步骤 3：重建 Codespaces

在 VS Code 中：

1. **打开命令面板**：Cmd+Shift+P (Mac) / Ctrl+Shift+P (Linux/Windows)
2. **搜索**：`Codespaces: Rebuild Container`
3. **选择**并回车
4. **等待** 4-5 分钟

**完成！** gstack 会自动安装。

---

## 📄 文件说明

### devcontainer.json

```json
{
  "name": "gstack",
  "image": "mcr.microsoft.com/devcontainers/universal:2024",
  "postCreateCommand": "bash .devcontainer/install-gstack.sh",
  "customizations": {
    "vscode": {
      "extensions": ["GitHub.copilot"]
    },
    "codespaces": {
      "openFiles": ["README.md"]
    }
  },
  "remoteUser": "codespace"
}
```

**字段解释**：

| 字段 | 用途 | 值 |
|-----|------|-----|
| `name` | 容器名称 | "gstack" |
| `image` | 基础 Docker 镜像 | mcr.microsoft.com/... (包含 Node.js, git, Python 等) |
| `postCreateCommand` | 容器创建后运行的命令 | 运行 gstack 安装脚本 ← **关键** |
| `extensions` | 自动安装的 VS Code 扩展 | GitHub.copilot (可选) |
| `openFiles` | 启动时打开的文件 | README.md (可选) |
| `remoteUser` | 容器内的用户 | "codespace" (Codespaces 默认) |

### install-gstack.sh

与 `codespace-setup/setup.sh` 相同，但适配 devcontainer 环境（路径、权限等）。

---

## 🔧 自定义 devcontainer

### 添加其他初始化命令

编辑 `postCreateCommand` 来运行多个命令：

```json
{
  "postCreateCommand": "bash .devcontainer/install-gstack.sh && npm install && npm run build"
}
```

或使用复合脚本：

```json
{
  "postCreateCommand": "bash .devcontainer/setup-full.sh"
}
```

### 添加系统包

```json
{
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {}
  }
}
```

### 定义环境变量

```json
{
  "remoteEnv": {
    "GSTACK_INSTALL_PATH": "/workspace/.gstack",
    "NODE_ENV": "development"
  }
}
```

### 暴露端口

```json
{
  "forwardPorts": [3000, 5432],
  "portsAttributes": {
    "3000": {
      "label": "Application",
      "onAutoForward": "notify"
    },
    "5432": {
      "label": "Database",
      "onAutoForward": "silent"
    }
  }
}
```

### 挂载卷（持久化数据）

```json
{
  "mounts": [
    "source=${localEnv:HOME}/.ssh,target=/home/codespace/.ssh,readonly"
  ]
}
```

---

## 📊 完整的企业级 devcontainer 示例

```json
{
  "name": "Production Ready",
  
  // 基础环境
  "image": "mcr.microsoft.com/devcontainers/universal:latest",
  
  // 功能模块
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {},
    "ghcr.io/devcontainers/features/github-cli:1": {}
  },
  
  // 自动化设置
  "postCreateCommand": "bash .devcontainer/install-gstack.sh && npm install",
  "postStartCommand": "npm run dev",
  
  // 开发工具
  "customizations": {
    "vscode": {
      "extensions": [
        "GitHub.copilot",
        "ESLint.eslint",
        "Prettier.prettier-vscode",
        "ms-python.python"
      ],
      "settings": {
        "editor.formatOnSave": true,
        "editor.defaultFormatter": "Prettier.prettier-vscode"
      }
    },
    "codespaces": {
      "openFiles": ["README.md", "CONTRIBUTING.md"]
    }
  },
  
  // 端口转发
  "forwardPorts": [3000, 5432, 6379],
  "portsAttributes": {
    "3000": {
      "label": "Web App",
      "onAutoForward": "notify"
    },
    "5432": {
      "label": "PostgreSQL",
      "onAutoForward": "silent"
    }
  },
  
  // 远程用户
  "remoteUser": "codespace",
  
  // 限制资源
  "containerEnv": {
    "NODE_ENV": "development"
  }
}
```

---

## 🔄 工作流程对比

### 不使用 devcontainer

```bash
# 1. 启动 Codespaces
# 2. 等待基础容器加载
# 3. 手动运行
bash codespace-setup/setup.sh
# 4. 等待 4-5 分钟安装完成
```

### 使用 devcontainer（推荐）

```bash
# 1. 启动 Codespaces
# 2. 容器自动构建和配置（包括 gstack）
# 3. 完成！立即开始编码
```

**差异**：devcontainer 的 gstack 安装在后台自动进行，不需要手动干预。

---

## 🐛 devcontainer 故障排查

### 问题 1：devcontainer 构建失败

**症状**：
```
Failed to create container
Could not create container
```

**解决**：

1. 查看构建日志
   - 点击左下角 "Codespaces" 按钮
   - 选择 "View Creation Log"
   - 搜索红色错误信息

2. 常见原因：
   - `postCreateCommand` 脚本有语法错误 → 检查 bash 语法
   - 网络问题 → 重试构建
   - Docker 镜像拉取失败 → 等待网络恢复

3. 修复后重建：
   ```
   Cmd+Shift+P → Codespaces: Rebuild Container
   ```

### 问题 2：devcontainer 构建很慢

**原因**：
- 首次构建需要拉取镜像（~2GB）
- gstack setup 需要下载 Playwright 和依赖
- 网络速度不稳定

**解决**：
- 耐心等待（通常 5-10 分钟首次，后续 2-3 分钟）
- 检查网络连接
- 如果中间失败，重新点击重建

### 问题 3：修改 devcontainer.json 不生效

**症状**：
修改配置后，Codespaces 仍用旧配置

**解决**：
必须重建容器才能应用更改：
```
Cmd+Shift+P → Codespaces: Rebuild Container
```

### 问题 4：gstack 安装失败（在 postCreateCommand 中）

**症状**：
```
postCreateCommand failed
Codespaces failed to create
```

**查看日志**：
```
Cmd+Shift+P → Codespaces: View Creation Log
```

**常见原因**（见 TROUBLESHOOTING.md）：
- Yarn apt 源问题 → 脚本已自动修复
- Playwright 依赖缺失 → 脚本已自动安装
- 网络超时 → 重建时会重试

---

## 📋 devcontainer 最佳实践

### ✅ DO（推荐做的）

1. **版本控制 devcontainer 配置**
   ```bash
   git add .devcontainer/
   git commit -m "chore: update devcontainer config"
   ```

2. **为团队记录 devcontainer 用法**
   ```
   # CONTRIBUTING.md
   ## 开发环境
   
   使用 GitHub Codespaces：
   1. 打开仓库
   2. 点击 "Codespaces" → "Create codespace on main"
   3. 等待自动配置（4-5分钟）
   4. 在 Claude Code 中输入 / 使用 gstack 技能
   ```

3. **定期更新基础镜像版本**
   - 每月检查最新的 `mcr.microsoft.com/devcontainers/universal` 版本

4. **测试 devcontainer 变更**
   - 在本地 Codespaces 上测试后再提交

### ❌ DON'T（不推荐做的）

1. **不要硬编码绝对路径**
   ```json
   // ❌ 错误
   "postCreateCommand": "bash /home/user/project/.devcontainer/setup.sh"
   
   // ✅ 正确
   "postCreateCommand": "bash .devcontainer/setup.sh"
   ```

2. **不要在 devcontainer.json 中放置大量脚本**
   ```json
   // ❌ 差
   "postCreateCommand": "long_bash_script_here..."
   
   // ✅ 好
   "postCreateCommand": "bash .devcontainer/setup.sh"
   // setup.sh 包含所有逻辑
   ```

3. **不要让 postCreateCommand 失败後沉默**
   - 使用 `set -e` 确保错误会中止脚本
   - 添加有意义的错误消息

4. **不要在 devcontainer 中安装重量级 IDE**
   - Codespaces 已包含 VS Code
   - 只安装必要的命令行工具

---

## 🌍 多成员团队设置

### 场景：你的团队有 5 个开发者

**目标**：每个人都用完全相同的开发环境

**步骤**：

1. **在项目仓库中配置 devcontainer**（你现在做的）
   ```bash
   git add .devcontainer/
   git commit -m "feat: add devcontainer with gstack"
   git push origin main
   ```

2. **告诉团队使用 Codespaces**
   ```
   📌 新的开发方式：
   
   不用在本地安装工具了！
   
   1. 打开 GitHub 项目
   2. 点 "Code" → "Codespaces" → "Create codespace"
   3. 等待 5 分钟（自动安装所有工具）
   4. 开始编码 🚀
   
   所有环境自动相同，没有"我这边能跑"问题。
   ```

3. **第一个人创建 Codespaces**
   - 验证一切正常
   - 截图或录屏给团队看

4. **其他人也创建 Codespaces**
   - 他们会获得完全相同的环境
   - gstack 自动装好，可以立即用 `/review` 等技能

---

## 🔐 安全性考虑

### 敏感信息

不要在 devcontainer.json 中放置：
- API keys
- 密码
- 个人令牌

改用：
- GitHub Secrets
- `.env.local` (git 忽略)
- Codespaces 变量设置

### 权限

```json
{
  "remoteUser": "codespace",  // 非 root 用户
  "mounts": [
    // 只读挂载
    "source=${localEnv:HOME}/.ssh,target=/home/codespace/.ssh,readonly"
  ]
}
```

---

## 🚀 下一步

1. ✅ 运行一次完整的 devcontainer 构建
2. ✅ 验证 gstack 自动安装成功
3. ✅ 在 Claude Code 中测试 `/review` 技能
4. ✅ 提交到 git 分享给团队
5. ✅ 更新 CONTRIBUTING.md 说明如何使用

**享受无忧的开发环境！** 🎉

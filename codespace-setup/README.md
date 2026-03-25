# gstack Codespaces 一键安装指南

## 📋 概述

这个目录包含在 GitHub Codespaces 中快速安装和配置 gstack 所需的所有工具和文档。

gstack 是 AI 编程助手框架，提供 27 个专业技能（code review, security audit, QA testing 等）。

## 🚀 快速开始（3步）

### 方案 A：独立脚本（推荐）

在 Codespaces 终端运行一条命令：

```bash
bash codespace-setup/setup.sh
```

**就这样！** 脚本会自动：
- ✓ 安装 Bun 运行时
- ✓ 修复 Yarn apt 源问题
- ✓ 克隆 gstack 仓库到 `~/.claude/skills/gstack`
- ✓ 编译 browse 二进制
- ✓ 生成 27 个技能文档

**安装时间：** ~4-5 分钟

### 方案 B：devcontainer 集成（团队推荐）

如果你的项目有多个开发者，使用 devcontainer 自动化安装：

```bash
# 1. 复制 devcontainer 配置
cp -r codespace-setup/devcontainer/ .devcontainer/

# 2. 在 VS Code 中重建 Codespaces
# Cmd+Shift+P → Codespaces: Rebuild Container

# 3. 等待安装完成（自动）
```

详见 [devcontainer-setup.md](./devcontainer-setup.md)

## ✅ 验证安装成功

```bash
# 1. 检查 browse 二进制（58MB）
ls -lh ~/.claude/skills/gstack/browse/dist/browse

# 2. 检查技能数量（应该 >= 27）
ls ~/.claude/skills/gstack | grep -E "^[a-z-]+$" | wc -l

# 3. 在 Claude Code 中输入 / 查看技能建议
```

## 📖 文档结构

```
codespace-setup/
├── README.md                      # 你在这里
├── setup.sh                       # 一键安装脚本
├── QUICKSTART.md                  # 技能快速开始指南
├── TROUBLESHOOTING.md             # 常见问题解决
├── devcontainer-setup.md          # devcontainer 详细说明
└── devcontainer/
    ├── devcontainer.json          # VS Code devcontainer 配置
    └── install-gstack.sh          # 自动安装脚本
```

## 🎯 常用技能

| 分类 | 技能 | 用途 |
|------|------|------|
| **代码审查** | `/review` | PR 代码审查，找 bug 和改进点 |
| | `/cso` | 安全审计（OWASP Top 10 + STRIDE） |
| | `/codex` | 多 AI 第二意见 |
| **调试** | `/investigate` | 系统根因分析 |
| **设计** | `/design-review` | 设计审计 + 自动修复 |
| | `/plan-design-review` | 设计评估（报告版） |
| **QA** | `/qa` | 浏览器自动化 QA 循环 |
| | `/qa-only` | QA 报告（无代码修改） |
| | `/benchmark` | 性能回归检测 |
| **部署** | `/ship` | 运行测试 → 推送 PR → 合并 |
| | `/land-and-deploy` | 合并 → 部署 → 监控 |
| | `/document-release` | 发布文档自动更新 |
| **计划** | `/office-hours` | YC 办公时间诊断工具 |
| | `/plan-ceo-review` | CEO 级别审查 |
| | `/plan-eng-review` | 架构和边界情况审查 |

## 🔄 常用技能组合

### 场景 1：准备推送 PR

```
/plan-ceo-review
   ↓
/plan-eng-review  
   ↓
/review           
   ↓
/ship             # 自动运行测试 → 推送 PR
```

### 场景 2：修复 Bug

```
/investigate      # 根因分析
   ↓
修改代码
   ↓
/qa               # 自动化浏览器测试
   ↓
/review           # 代码审查
```

### 场景 3：安全发布

```
/cso              # 安全审计
   ↓
/ship             # 发布
   ↓
/document-release # 更新 CHANGELOG
```

## 🛠️ 故障排查

遇到问题？查看 [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)

常见问题速查：

| 问题 | 解决 |
|------|------|
| "bun is required" | 查看 TROUBLESHOOTING.md 问题 1 |
| apt 签名错误 | 查看 TROUBLESHOOTING.md 问题 2 |
| Playwright 失败 | 查看 TROUBLESHOOTING.md 问题 3 |
| 技能不显示 | 查看 TROUBLESHOOTING.md 问题 4 |

## 📁 高级用法

### 自定义脚本

编辑 `codespace-setup/setup.sh` 添加自己的初始化命令：

```bash
# 在最后添加
log_info "运行项目初始化..."
npm install
npm run build
```

### 集成到现有 devcontainer

如果你已有 `.devcontainer/devcontainer.json`，添加一行：

```json
{
  "postCreateCommand": "bash codespace-setup/setup.sh",
  // ... 其他配置
}
```

### 调试脚本

```bash
# 查看详细日志
cat /tmp/gstack-setup.log      # gstack 安装日志
cat /tmp/playwright-install.log # Playwright 安装日志

# 单步跑
cd ~/.claude/skills/gstack
bun install
bun run build
./setup
```

## 🔗 相关资源

- gstack GitHub: https://github.com/withgstack/gstack
- Claude Code 官方文档: https://docs.github.com/en/copilot/using-copilot/
- devcontainer 规范: https://containers.dev/

## 📝 文件说明

### setup.sh
主安装脚本，支持：
- 自动检测和安装 Bun
- 修复 Codespaces 已知的 Yarn apt 源问题
- 克隆/更新 gstack 仓库
- 编译 Playwright 浏览器
- 验证安装成功

### devcontainer.json
VS Code devcontainer 配置，自动在 Codespaces 启动时运行 setup.sh。

### QUICKSTART.md
技能使用快速指南（5 分钟内掌握核心概念）。

### TROUBLESHOOTING.md
常见问题和解决方案的完整列表。

### devcontainer-setup.md
devcontainer 集成的详细说明和高级配置。

## ✨ 下一步

安装完成后：

1. **尝试第一个技能**
   ```
   在 Claude Code 中输入: /review
   ```

2. **阅读 QUICKSTART.md** 了解如何使用 27 个技能

3. **提交到 git**（如果使用 devcontainer）
   ```bash
   git add codespace-setup/ .devcontainer/
   git commit -m "feat: add gstack codespace setup"
   ```

4. **分享给团队** — 别人运行 `bash codespace-setup/setup.sh` 即可获得相同环境

## 💡 提示

- **离线安装？** 脚本会尝试克隆，如果网络不稳定可以手动 `git clone https://github.com/withgstack/gstack.git ~/.claude/skills/gstack`
- **不是 Codespaces？** 脚本也可在本地 Linux/WSL 运行，但 Mac 用户应该用原始 gstack 仓库中的 setup
- **需要帮助？** 查看任意 markdown 文件顶部的"问题"索引

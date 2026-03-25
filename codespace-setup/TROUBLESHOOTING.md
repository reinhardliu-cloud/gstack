# gstack 安装问题排查指南

## 快速查找

| 错误信息 | 问题编号 |
|---------|---------|
| "bun is required but not installed" | [问题 1](#问题-1-bun-未安装) |
| "sudo: bunx: command not found" | [问题 2](#问题-2-sudo-无法找到-bunx) |
| "The repository is not signed" | [问题 3](#问题-3-yarn-apt-源-gpg-签名失败) |
| "Playwright Chromium could not be launched" | [问题 4](#问题-4-playwright-chromium-冲突) |
| "./setup" 脚本失败 | [问题 5](#问题-5-setup-脚本失败) |
| 技能不出现在 Claude Code | [问题 6](#问题-6-技能不显示) |
| "Permission denied" | [问题 7](#问题-7-权限错误) |
| browse 二进制很大 | [问题 8](#问题-8-browse-很大) |

---

## 问题 1: "bun is required but not installed"

### ❌ 症状

```
Error: bun is required but not installed
```

### 🔍 原因

Bun 运行时未安装或不在 PATH 中。脚本依赖 Bun 来编译 gstack。

### ✅ 解决方案

```bash
# 1. 手动安装 Bun
curl -fsSL https://bun.sh/install | bash

# 2. 更新 PATH
export PATH=$PATH:$HOME/.bun/bin

# 3. 验证
bun --version
# 输出: 1.1.xx 或更高

# 4. 重新运行脚本
bash codespace-setup/setup.sh
```

### 💡 为什么会这样？

- Codespaces 默认未预装 Bun（只有 Node.js）
- gstack 用 Bun 作为 JavaScript 运行时和包管理器
- Bun 安装在 `~/.bun/bin`，脚本会自动添加到 PATH

---

## 问题 2: "sudo: bunx: command not found"

### ❌ 症状

```
sudo: bunx: command not found
```

### 🔍 原因

`sudo` 重置了环境变量，导致 Bun 的路径 (`~/.bun/bin`) 丢失。

### ✅ 解决方案

**脚本已自动修复**。如果仍然出现，手动运行：

```bash
# 正确的命令格式（保留 PATH）
sudo env "PATH=$PATH" "$(command -v bunx)" playwright install-deps chromium
```

**关键点**：
- `env "PATH=$PATH"` — 保留用户 PATH
- `"$(command -v bunx)"` — 完整的 bunx 路径

### 💡 总结

Linux/Codespaces 中，很多工具安装在用户目录：
- Bun: `~/.bun/bin/bun`
- Node: `/usr/bin/node`（通常）
- 用 sudo 时要明确保留 PATH

---

## 问题 3: "The repository is not signed" (apt 错误)

### ❌ 症状

```
E: The repository 'https://dl.yarnpkg.com/debian stable InRelease' is not signed.
E: The value 'stable' is invalid for APT::Default-Release as it is not a 
   valid release for any sources in your sources list.
Installation process exited with code: 100
```

### 🔍 原因

Codespaces 预装了 Yarn，但其 apt 源的 GPG 密钥已过期。`apt update` 会扫描所有源，任何一个失败都会导致整个 apt 操作中止。

### ✅ 解决方案

**脚本已自动修复**。如果仍然出现：

```bash
# 1. 禁用 Yarn 源
sudo mv /etc/apt/sources.list.d/yarn.list /etc/apt/sources.list.d/yarn.list.disabled

# 2. 验证
sudo apt-get update
# 应该成功，不再有 Yarn 错误

# 3. 重新运行脚本
bash codespace-setup/setup.sh
```

### 💡 常见的 apt 源问题

```bash
# 查看所有 apt 源
ls /etc/apt/sources.list.d/

# 禁用某个源
sudo mv /etc/apt/sources.list.d/{source}.list{,.disabled}

# 重新启用
sudo mv /etc/apt/sources.list.d/{source}.list{.disabled,}
```

---

## 问题 4: "Playwright Chromium could not be launched"

### ❌ 症状

```
Error: Chromium could not be launched
Playwright was doing a final check for browser dependencies.
System libaries may be missing.
```

### 🔍 原因

Playwright 需要 Chromium 的运行时依赖（libx11, libnss3, libxss1, libasound2 等），但系统未安装或不完整。这与问题 3 通常相关（apt 源失败导致依赖未装）。

### ✅ 解决方案

### 方案 A：重新运行脚本（推荐）

```bash
bash codespace-setup/setup.sh
# 脚本会重新尝试安装依赖
```

### 方案 B：手动安装依赖

```bash
# 1. 确保 apt 可用
sudo apt-get update

# 2. 安装 Playwright 依赖
sudo env "PATH=$PATH" "$(command -v bunx)" playwright install-deps chromium

# 3. 如果仍然失败，手动安装系统包
sudo apt-get install -y \
  libx11-6 libnss3 libxss1 libasound2 libxrandr2 \
  libgconf-2-4 libatk1.0-0 libatk-bridge2.0-0 \
  libcups2 libdrm2 libgbm1 libxdamage1 libxcomposite1

# 4. 重试
cd ~/.claude/skills/gstack
./setup
```

### 方案 C：检查日志

```bash
# 查看详细日志
cat /tmp/playwright-install.log

# 查看完整的 setup 日志
cat /tmp/gstack-setup.log
```

### 💡 深入理解

Playwright 安装分两步：
1. **下载二进制** — Bun 自动做
2. **安装系统依赖** — `playwright install-deps chromium` 通过 apt 安装

如果步骤 1 成功但步骤 2 失败，Chromium 二进制存在但无法运行。

---

## 问题 5: "./setup" 脚本失败

### ❌ 症状

```
Error: ./setup command not found
或
./setup: Permission denied
或
其他 gstack 内部错误
```

### 🔍 原因

多种原因可能导致 gstack setup 失败：
- Bun 依赖未安装 (`bun install` 失败)
- 二进制编译失败
- Playwright 浏览器检查失败（见问题 4）
- 权限问题

### ✅ 诊断步骤

```bash
# 1. 检查 setup 脚本存在且可执行
ls -la ~/.claude/skills/gstack/setup
# 输出: -rwxr-xr-x

# 2. 如果不可执行，修复权限
chmod +x ~/.claude/skills/gstack/setup

# 3. 手动逐步运行
cd ~/.claude/skills/gstack
bun install        # 安装 npm 依赖
bun run build      # 编译二进制和文档
./setup            # 最后的设置

# 4. 查看详细错误
cat /tmp/gstack-setup.log
```

### ✅ 常见的 setup 失败原因

| 原因 | 解决 |
|------|------|
| Bun 依赖失败 | 重新运行 `bun install` |
| 编译失败 | 检查 Node/Bun 版本：`bun --version` |
| Playwright 验证失败 | 见问题 4 |
| 网络中断 | 等待网络后重试 |

---

## 问题 6: 技能不显示

### ❌ 症状

在 Claude Code 中输入 `/` 后，看不到 `/review`, `/cso`, `/qa` 等建议。

### 🔍 原因

SKILL.md 文件未生成或路径不对。

### ✅ 诊断步骤

```bash
# 1. 检查 SKILL.md 文件是否存在
ls ~/.claude/skills/gstack/*/*SKILL.md | head -10
# 应该列出至少 27 个 SKILL.md 文件

# 2. 计数
find ~/.claude/skills/gstack -name "SKILL.md" | wc -l
# 应该 >= 27

# 3. 检查 review 技能
ls -la ~/.claude/skills/gstack/review/SKILL.md
```

### ✅ 解决方案

#### 方案 A：重新生成技能文档

```bash
cd ~/.claude/skills/gstack
bun run gen:skill-docs

# 等待完成，应该看到：
# ✓ Generated SKILL.md files
```

#### 方案 B：重新运行完整 setup

```bash
bash codespace-setup/setup.sh
```

#### 方案 C：手动检查并修复

```bash
# 检查是否在正确位置
ls ~/.claude/skills/gstack/review/SKILL.md

# 如果不存在，重新生成
cd ~/.claude/skills/gstack
bun run build
./setup
```

### 💡 Claude Code 发现技能的方式

1. 扫描 `~/.claude/skills/gstack/` 目录
2. 查找每个子目录下的 `SKILL.md`
3. 解析 SKILL.md 的 frontmatter（头部元数据）
4. 显示在命令建议中

如果 SKILL.md 不存在或格式错误，技能不会显示。

---

## 问题 7: 权限错误

### ❌ 症状

```
Permission denied: ~/.claude/skills/gstack/browse/dist/browse
或
Permission denied: ./setup
```

### ✅ 解决方案

```bash
# 修复 browse 二进制
chmod +x ~/.claude/skills/gstack/browse/dist/browse

# 修复 setup 脚本
chmod +x ~/.claude/skills/gstack/setup

# 修复所有脚本
chmod +x ~/.claude/skills/gstack/bin/*
```

### 💡 为什么会这样？

从 git 克隆的文件可能不执行位，特别是在脚本和二进制上。

---

## 问题 8: browse 很大（58MB）

### ❌ 症状

```
ls -lh ~/.claude/skills/gstack/browse/dist/browse
-rwxr-xr-x  ... 58M browse
```

### ✅ 答案

**这不是问题，这是正常的。**

gstack 包含预编译的 Playwright Chromium 浏览器二进制。58MB 是合理的大小。

**为什么这么大？**
- Playwright 包含完整的 Chromium
- Chromium 本身 ~200MB 解压后，但 gstack 只包含最小运行时
- 二进制包括多个架构支持（但最终只运行符合当前系统的）

**能删除吗？**
不能。`/browse` 技能需要这个二进制来自动化浏览器操作。

---

## 问题 9: 在 Mac 上运行？

### ❌ 注意

gstack 的 codespace-setup 主要优化了 Linux (Codespaces)。

### ✅ Mac 用户应该：

```bash
# 使用原始 gstack setup
cd ~/.claude/skills/gstack
./setup  # 会自动检测 macOS

# Homebrew 通常已预装所需依赖
brew install bun

# 如果需要手动安装 Playwright 依赖（通常不需要）
bunx playwright install-deps chromium
```

**note**: Mac 的 setup 行为略有不同，会跳过一些 Linux 特定的检查。

---

## 问题 10: 网络速度慢或离线？

### ❌ 症状

```
git clone 很慢
apt-get update 超时
下载二进制中断
```

### ✅ 解决方案

#### 方案 A：使用镜像源（如果在中国）

```bash
# 1. 编辑 apt 源
sudo nano /etc/apt/sources.list

# 2. 改为清华源或其他国内镜像

# 3. 更新
sudo apt-get update
```

#### 方案 B：离线模式

```bash
# 如果已下载 gstack，可以跳过克隆
# 编辑脚本中的克隆步骤，改为：
cd ~/.claude/skills/gstack
git pull  # 而不是 git clone
```

#### 方案 C：增加超时时间

```bash
# 某些命令可能超时，添加超时参数
git clone --depth 1 https://github.com/withgstack/gstack.git ~/.claude/skills/gstack
```

---

## 问题 11: 完整重装

如果上面的解决方案都不行，彻底重装：

```bash
# 1. 移除现有安装
rm -rf ~/.claude/skills/gstack

# 2. 禁用 Yarn 源
sudo mv /etc/apt/sources.list.d/yarn.list /etc/apt/sources.list.d/yarn.list.disabled

# 3. 更新 apt
sudo apt-get update

# 4. 重新运行脚本
bash codespace-setup/setup.sh
```

---

## 问题 12: 仍然无法解决？

### 获取帮助

1. **查看日志文件**
   ```bash
   cat /tmp/gstack-setup.log
   cat /tmp/playwright-install.log
   ```

2. **检查系统状态**
   ```bash
   bun --version
   node --version
   git --version
   ```

3. **查看 gstack 仓库状态**
   ```bash
   cd ~/.claude/skills/gstack
   git log --oneline -5
   git status
   ```

4. **报告 Issue**
   - gstack GitHub: https://github.com/withgstack/gstack/issues
   - 包含：错误信息、系统版本、脚本日志

---

## 快速诊断脚本

```bash
#!/bin/bash
echo "=== gstack 诊断 ==="
echo "Bun: $(bun --version)"
echo "Node: $(node --version)"
echo "Git: $(git --version)"
echo ""
echo "gstack 目录: $(ls -d ~/.claude/skills/gstack 2>/dev/null || echo 'NOT FOUND')"
echo "browse 二进制: $(ls -lh ~/.claude/skills/gstack/browse/dist/browse 2>/dev/null | awk '{print $5, $9}' || echo 'NOT FOUND')"
echo "SKILL 文件数: $(find ~/.claude/skills/gstack -name 'SKILL.md' 2>/dev/null | wc -l)"
echo ""
echo "最近日志:"
tail -20 /tmp/gstack-setup.log 2>/dev/null || echo "无日志"
```

保存为 `diagnose.sh`，运行 `bash diagnose.sh` 快速诊断。

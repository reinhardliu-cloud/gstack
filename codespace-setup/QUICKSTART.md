# gstack 快速开始指南（5分钟）

## 第 1 分钟：验证安装

```bash
# 检查 browse 二进制存在
ls -lh ~/.claude/skills/gstack/browse/dist/browse
# 输出：-rwxr-xr-x ... 58M browse

# 检查技能数量
find ~/.claude/skills/gstack -name "SKILL.md" | wc -l
# 输出：应该 >= 27
```

## 第 2 分钟：在 Claude Code 中找到技能

1. **打开 Claude Code** 聊天窗口（VS Code 右下角）
2. **输入** `/` 并按 Tab
3. **看到** `/review`, `/cso`, `/qa`, `/ship` 等建议

## 第 3-4 分钟：尝试第一个技能

### 示例 1：代码审查

```
在任何代码文件上运行：
/review
```

Claude 会：
- ✓ 分析代码结构、逻辑和风格
- ✓ 找出 bug、性能问题、安全风险
- ✓ 提出改进建议
- ✓ 自动修复（如果你同意）

### 示例 2：安全审计

```
在项目上运行：
/cso
```

检查：
- ✓ OWASP Top 10 风险
- ✓ STRIDE 威胁模型
- ✓ 认证/授权问题
- ✓ 数据保护

### 示例 3：QA 自动化

```
在产品上运行：
/qa
```

自动：
- ✓ 打开实时浏览器
- ✓ 运行测试场景
- ✓ 报告 bug
- ✓ 修复代码
- ✓ 重新验证

## 第 5 分钟：学会组合技能

### 组合 1：完整代码审查流程

```
代码 → /plan-ceo-review  （这个改动值得做吗？）
    → /plan-eng-review   （实现方式对吗？）
    → /review            （有 bug 吗？）
    → /ship              （运行测试 + 推送 PR）
```

### 组合 2：快速 bug 修复

```
发现 bug  → /investigate （根因是什么？）
        → 修改代码
        → /qa           （真的修复了吗？）
        → /review       （有其他问题吗？）
```

### 组合 3：整个发布流程

```
功能完成 → /cso              （安全吗？）
       → /ship             （测试 + PR + 合并）
       → /document-release （更新文档）
       → /land-and-deploy  （部署 + 监控）
```

---

## 📚 27 个技能完整列表

### 🔍 代码审查类（3 个）

| 技能 | 用途 | 时间 |
|------|------|------|
| `/review` | PR 代码审查 — 找 bug、性能、安全问题 | 3-5 min |
| `/cso` | 安全审计 — OWASP Top 10 + STRIDE 模型 | 5-10 min |
| `/codex` | 多 AI 审查 — Claude + GPT-4 二意见 | 5-10 min |

**何时用：** 任何代码修改前推送 PR

---

### 🐛 调试类（1 个）

| 技能 | 用途 | 时间 |
|------|------|------|
| `/investigate` | 系统根因分析 — 从错误追溯到源头 | 5-10 min |

**何时用：** 遇到诡异 bug 无从下手

---

### 🎨 设计评审类（2 个）

| 技能 | 用途 | 时间 |
|------|------|------|
| `/design-review` | 设计审计 + 自动修复 | 10-15 min |
| `/plan-design-review` | 设计评估（报告版，无修改） | 10-15 min |

**何时用：** 大型功能前进行可用性评估

---

### ✅ QA 测试类（3 个）

| 技能 | 用途 | 时间 |
|------|------|------|
| `/qa` | 浏览器自动化测试 + 修复 bug | 10-20 min |
| `/qa-only` | QA 报告（无代码修改） | 10-20 min |
| `/benchmark` | 性能回归检测 | 5-10 min |

**何时用：** 发布前完整的功能验证和性能检查

---

### 🚀 部署类（3 个）

| 技能 | 用途 | 时间 |
|------|------|------|
| `/ship` | 运行测试 → 推送 PR → 合并 | 5 min |
| `/land-and-deploy` | 部署到生产 + 监控 | 10 min |
| `/document-release` | 自动更新发布文档和 CHANGELOG | 3-5 min |

**何时用：** 功能完成，准备上线

---

### 📋 规划评审类（4 个）

| 技能 | 用途 | 时间 |
|------|------|------|
| `/office-hours` | YC 创业诊断工具 — 产品策略评估 | 10-15 min |
| `/plan-ceo-review` | CEO 级别审查 — 商业影响评估 | 15 min |
| `/plan-eng-review` | 工程审查 — 架构 + 边界情况 | 10-15 min |
| `/autoplan` | 自动流程 — CEO → 设计 → 工程 | 30 min |

**何时用：** 大型功能规划阶段

---

### 🛠️ 工具类（1 个）

| 技能 | 用途 | 时间 |
|------|------|------|
| `/browse` | 实时浏览器交互 — 手动或脚本化 | 按需 |

**何时用：** 需要自动化某个网站操作

---

### 📊 分析类（3 个）

| 技能 | 用途 | 时间 |
|------|------|------|
| `/retro` | 每周回顾 + 团队统计 | 15-20 min |
| `/benchmark` | 性能基准测试 | 见上表 |
| 其他... | ... | ... |

---

## 🎓 三个层级的使用方式

### 初级：单个技能

```
问题 → 运行一个技能 → 获得建议或修复
```

例如：`/review` 找出代码问题

### 中级：技能组合

```
想要完整的代码审查 → /review + /cso
想要快速修复     → /investigate + /qa
```

### 高级：完整工作流

```
功能开发 → /plan-ceo-review     （值得做吗？）
       → /plan-eng-review     （怎么做？）
       → 写代码
       → /review + /cso       （代码好吗？）
       → /qa                  （能用吗？）
       → /ship                （推送）
       → /document-release    （文档）
```

---

## ⚡ 快速命令参考

```bash
# 检查安装
ls -lh ~/.claude/skills/gstack/browse/dist/browse

# 更新 gstack（如果有新版本）
cd ~/.claude/skills/gstack && git pull

# 重新安装（如有问题）
bash codespace-setup/setup.sh

# 查看某个技能的详细说明
cat ~/.claude/skills/gstack/{skill-name}/SKILL.md
```

---

## 🔥 常见使用场景

### 场景 1："我有个 bug 不知道怎么修"

```
/investigate  → 根因分析
修改代码      → 按照分析修改
/qa           → 验证修复
/review       → 检查有没有其他问题
```

### 场景 2："我要发布一个功能"

```
/plan-ceo-review  → "值得做吗？"
/plan-eng-review  → "怎么做最好？"
写代码            → 按建议实现
/review + /cso    → 代码审查 + 安全审计
/qa               → 功能测试
/ship             → 自动 push PR + merge
/document-release → 更新文档
```

### 场景 3："我想快速审查别人的代码"

```
/review  → 找出问题和改进点
/cso     → 安全检查
approve  → 同意 merge
```

---

## 💡 使用技巧

1. **按顺序运行**
   - 先 `/review`，再 `/cso`，最后 `/qa`
   - 不要倒序，否则会重复修改

2. **读改建议，再确认修改**
   - gstack 会提出改变，让你决定是否采纳
   - 不会强制修改代码

3. **遇到问题查日志**
   - 如果技能失败，看终端输出的错误信息
   - 查看 [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) 中的解决方案

4. **充分利用浏览器自动化**
   - `/qa` 可以真实打开浏览器
   - `/benchmark` 可以检测性能回归
   - `/browse` 可以手动控制浏览器做任意操作

---

## 🎯 下一个目标

- [ ] 在项目上运行 `/review` 一次
- [ ] 尝试 `/cso` 看看安全审计结果
- [ ] 如果有网站，试试 `/qa` 自动化测试
- [ ] 阅读 [README.md](./README.md) 了解完整用法
- [ ] 查看 [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) 了解常见问题

---

**祝你使用愉快！** 🚀

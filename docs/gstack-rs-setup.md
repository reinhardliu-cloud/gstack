# gstack 与 RS Slash 配置指南

## 1. 目的

这份文档解决两件事：

1. 如何在仓库里生成并使用 /rs-xxx 这类 RS alias
2. 如何让一台新主机把 gstack skill 真的安装完整，而不是只“看得到命令”

很多人第一次接入时会遇到同一个误区：

1. .github/prompts/rs-*.prompt.md 只负责让 slash 菜单出现 RS 命令
2. gstack skill 真正运行时，还需要 runtime root

所以，“看得到 /rs-autoplan” 和 “/rs-autoplan 可以稳定运行” 是两件不同的事。

## 2. 目录与映射规则

RS 命令入口：

1. .github/prompts/rs-*.prompt.md

技能来源（脚本自动识别两种布局）：

1. 布局 A（vendored）：.agents/skills/gstack-*/SKILL.md
2. 布局 B（gstack 主仓）：<skill>/SKILL.md，例如 autoplan/SKILL.md

slash 目标规则：

1. 技能目录名为 gstack-xxx 时，映射为 rs-xxx，正文写 Use /gstack-xxx for this task.
2. 技能目录名为 xxx 时，映射为 rs-xxx，正文写 Use /xxx for this task.

## 3. 一键脚本

脚本路径：scripts/generate_rs_prompts.sh

功能：

1. 自动扫描技能目录
2. 自动生成或更新 .github/prompts/rs-*.prompt.md
3. 默认跳过已存在文件
4. 支持 --dry-run 预览
5. 支持 --force 覆盖

## 4. 使用方式

仅创建缺失文件：

```bash
bash scripts/generate_rs_prompts.sh
```

预览不写入：

```bash
bash scripts/generate_rs_prompts.sh --dry-run
```

强制覆盖全部：

```bash
bash scripts/generate_rs_prompts.sh --force
```

## 5. 调用方式

建议只用 slug：

1. /rs-autoplan
2. /rs-review
3. /rs-qa

不建议把显示名当命令词手打。

## 6. 新主机安装模型

对于 Codex 兼容宿主，gstack 有两种标准安装方式。

### 方式 A：用户级安装，最稳

适合这种场景：

1. 你的业务仓库已经 vendored 了 .agents/skills/gstack-* 
2. 你的业务仓库已经有 .github/prompts/rs-*.prompt.md
3. 你只缺 gstack runtime root

安装命令：

```bash
git clone https://github.com/garrytan/gstack.git ~/gstack
cd ~/gstack
./setup --host codex
```

完成后，关键运行资产应落在：

1. ~/.codex/skills/gstack
2. ~/.codex/skills/gstack-*

### 方式 B：仓库级安装，便于项目自包含

适合这种场景：

1. 你希望所有 runtime 资产都跟仓库走
2. 你希望项目内直接有 .agents/skills/gstack

安装命令：

```bash
git clone https://github.com/garrytan/gstack.git .agents/skills/gstack
cd .agents/skills/gstack
./setup --host codex
```

完成后，关键运行资产应落在：

1. .agents/skills/gstack/bin
2. .agents/skills/gstack/browse/dist
3. .agents/skills/gstack/review
4. .agents/skills/gstack/qa

## 7. 为什么有时命令能看到但跑不全

生成 RS prompt 只解决“入口显示”的问题，不自动保证 runtime 完整。

对许多 gstack skill 来说，运行时会查找下面两个位置之一：

1. 仓库内 .agents/skills/gstack
2. 用户级 ~/.codex/skills/gstack

如果仓库只 vendored 了 .agents/skills/gstack-*，但没有 .agents/skills/gstack，也没有 ~/.codex/skills/gstack，就会出现下面这种情况：

1. slash 菜单能看到 /rs-autoplan 或 /gstack-autoplan
2. 实际运行时缺少 bin、browse、review 等 runtime 资产

## 8. 前置依赖

新主机至少要满足：

1. 已安装 Git
2. 已安装 Bun 1.0+
3. 使用支持 SKILL.md 与 .github/prompts 的宿主
4. Windows 额外需要 Node.js

最小检查命令：

```bash
command -v git
command -v bun
```

Windows 额外检查：

```bash
command -v node
```

## 9. 验证清单

检查 prompt：

```bash
find .github/prompts -maxdepth 1 -name "rs-*.prompt.md" | sort
```

检查技能（两种布局都看）：

```bash
find .agents/skills -maxdepth 2 -name "SKILL.md" 2>/dev/null | sort
find . -mindepth 2 -maxdepth 2 -name "SKILL.md" | sort
```

检查 runtime root 是否存在：

```bash
test -f ~/.codex/skills/gstack/SKILL.md || test -f .agents/skills/gstack/SKILL.md
test -x ~/.codex/skills/gstack/bin/gstack-update-check || test -x .agents/skills/gstack/bin/gstack-update-check
test -x ~/.codex/skills/gstack/browse/dist/browse || test -x .agents/skills/gstack/browse/dist/browse
```

## 10. 快速排障

问题：看不到 /rs-autoplan

1. 确认已执行脚本
2. 确认文件在 .github/prompts/
3. 确认 frontmatter 合法
4. 重开聊天会话后再试

问题：输入显示名不稳定

1. 改用 /rs-xxx slug

问题：slash 命令能看到，但运行时报 gstack 资源缺失

1. 先检查 ~/.codex/skills/gstack 是否存在
2. 若没有，再检查仓库内 .agents/skills/gstack 是否存在
3. 两边都没有时，重新执行 ./setup --host codex

## 11. 什么时候该选哪种安装方式

推荐优先级：

1. 用户级安装：最稳，适合大多数新主机
2. 仓库级安装：适合你要做项目自包含或团队分发

如果你的业务仓库已经有一整套 .agents/skills/gstack-* 和 .github/prompts/rs-*，但没有 .agents/skills/gstack，那么最推荐的做法不是重做 prompt，而是先补 runtime root。

## 12. 交付内容

本仓库当前提供：

1. docs/gstack-rs-setup.md
2. docs/gstack-rs-setup.en.md
3. scripts/generate_rs_prompts.sh
4. .github/prompts/rs-*.prompt.md
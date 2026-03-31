# gstack 与 RS Slash 配置指南

## 1. 目的

把 RS 命令映射和一键生成脚本放进 gstack 主仓。下次任何人拉取此仓后，可以快速生成 .github/prompts/rs-*.prompt.md 并直接使用 /rs-xxx。

## 2. 目录与映射规则

RS 命令入口：

1. .github/prompts/rs-*.prompt.md

技能来源（脚本自动识别两种布局）：

1. 布局 A（vendored）：.agents/skills/gstack-*/SKILL.md
2. 布局 B（gstack 主仓）：<skill>/SKILL.md（例如 autoplan/SKILL.md）

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

bash scripts/generate_rs_prompts.sh

预览不写入：

bash scripts/generate_rs_prompts.sh --dry-run

强制覆盖全部：

bash scripts/generate_rs_prompts.sh --force

## 5. 调用方式

建议只用 slug：

1. /rs-autoplan
2. /rs-review
3. /rs-qa

不建议把显示名当命令词手打。

## 6. 验证清单

检查 prompt：

find .github/prompts -maxdepth 1 -name "rs-*.prompt.md" | sort

检查技能（两种布局都看）：

find .agents/skills -maxdepth 2 -name "SKILL.md" 2>/dev/null | sort
find . -mindepth 2 -maxdepth 2 -name "SKILL.md" | sort

## 7. 快速排障

问题：看不到 /rs-autoplan

1. 确认已执行脚本
2. 确认文件在 .github/prompts/
3. 确认 frontmatter 合法
4. 重开聊天会话后再试

问题：输入显示名不稳定

1. 改用 /rs-xxx slug

## 8. 交付内容

本次已写入：

1. docs/gstack-rs-setup.md
2. docs/gstack-rs-setup.en.md
3. scripts/generate_rs_prompts.sh
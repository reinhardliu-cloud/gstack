#!/bin/bash
# gstack Codespaces 一键安装脚本
# 用法: bash codespace-setup/setup.sh

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
  echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
  echo -e "${RED}✗${NC} $1"
}

echo ""
echo "╔════════════════════════════════════════╗"
echo "║   gstack Codespaces 一键安装脚本       ║"
echo "║   安装时间: ~4-5 分钟                  ║"
echo "╚════════════════════════════════════════╝"
echo ""

# ============================================================================
# 步骤 1: 检查并安装 Bun
# ============================================================================
log_info "步骤 1/6: 检查 Bun 运行时..."

if command -v bun &> /dev/null; then
  BUN_VERSION=$(bun --version)
  log_success "Bun 已安装: $BUN_VERSION"
else
  log_info "安装 Bun..."
  curl -fsSL https://bun.sh/install | bash
  export PATH=$PATH:$HOME/.bun/bin
  log_success "Bun 安装完成"
fi

# ============================================================================
# 步骤 2: 修复 Yarn apt 源（已知的 Codespaces 问题）
# ============================================================================
log_info "步骤 2/6: 修复 apt 源配置..."

if [ -f /etc/apt/sources.list.d/yarn.list ]; then
  log_warn "检测到有问题的 Yarn apt 源，禁用中..."
  sudo mv /etc/apt/sources.list.d/yarn.list /etc/apt/sources.list.d/yarn.list.disabled 2>/dev/null || true
  log_success "Yarn apt 源已禁用"
else
  log_success "未检测到 Yarn apt 源问题"
fi

# 更新 apt 索引
log_info "更新 apt 包索引..."
sudo apt-get update -qq 2>&1 | grep -i "error" && log_error "apt update 失败" || true

# ============================================================================
# 步骤 3: 克隆或更新 gstack 仓库
# ============================================================================
log_info "步骤 3/6: 设置 gstack 仓库..."

GSTACK_DIR="$HOME/.claude/skills/gstack"

if [ -d "$GSTACK_DIR" ]; then
  log_info "gstack 目录已存在，更新中..."
  cd "$GSTACK_DIR"
  git pull origin main --quiet 2>/dev/null || log_warn "无法更新（可能离线）"
else
  log_info "克隆 gstack 仓库..."
  git clone https://github.com/withgstack/gstack.git "$GSTACK_DIR" --quiet
  log_success "gstack 仓库已克隆"
fi

cd "$GSTACK_DIR"

# ============================================================================
# 步骤 4: 安装 Playwright 系统依赖
# ============================================================================
log_info "步骤 4/6: 安装 Playwright 系统依赖..."

log_info "这需要 sudo 权限，可能会提示密码..."

if sudo env "PATH=$PATH" "$(command -v bunx)" playwright install-deps chromium 2>&1 | tee /tmp/playwright-install.log; then
  log_success "Playwright 依赖安装完成"
else
  log_error "Playwright 依赖安装失败"
  log_info "查看详细日志: cat /tmp/playwright-install.log"
  exit 1
fi

# ============================================================================
# 步骤 5: 运行 gstack 设置
# ============================================================================
log_info "步骤 5/6: 编译 gstack..."

if ./setup 2>&1 | tee /tmp/gstack-setup.log; then
  log_success "gstack 设置完成"
else
  log_error "gstack 设置失败"
  log_info "查看详细日志: cat /tmp/gstack-setup.log"
  exit 1
fi

# ============================================================================
# 步骤 6: 验证
# ============================================================================
log_info "步骤 6/6: 验证安装..."

# 检查 browse 二进制
if [ -x "$GSTACK_DIR/browse/dist/browse" ]; then
  log_success "browse 二进制已编译"
else
  log_error "browse 二进制不存在或不可执行"
  exit 1
fi

# 检查至少 5 个技能
SKILL_COUNT=$(ls -1 "$GSTACK_DIR" | grep -E "^[a-z-]+$" | wc -l)
if [ "$SKILL_COUNT" -ge 5 ]; then
  log_success "检测到 $SKILL_COUNT 个技能"
else
  log_warn "只检测到 $SKILL_COUNT 个技能（预期 >= 5）"
fi

# ============================================================================
# 完成
# ============================================================================
echo ""
echo "╔════════════════════════════════════════╗"
echo "║   ✓ gstack 安装完成！                  ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "📍 安装位置："
echo "   ~/.claude/skills/gstack/"
echo ""
echo "🚀 下一步："
echo "   1. 在 Claude Code 聊天中输入 /"
echo "   2. 应该看到 /review, /cso, /qa 等技能"
echo "   3. 尝试运行: /review 或 /cso"
echo ""
echo "💡 常用技能组合："
echo "   - 代码评审: /review → /cso (安全审计)"
echo "   - CI/CD: /ship (运行测试 + PR)"
echo "   - QA 循环: /qa (浏览器测试)"
echo ""
echo "📖 了解更多: 查看 codespace-setup/ 中的文档"
echo ""

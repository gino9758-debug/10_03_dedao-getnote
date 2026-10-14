#!/usr/bin/env bash
# 得到大脑连接器一键恢复脚本
# 用途：新对话/环境重置后，一条命令完成 CLI 安装 + 凭证配置 + 连通性自检
# 用法：bash <skill_dir>/scripts/setup.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
CLI_DIR="$SKILL_DIR/cli"
CRED_FILE="$SKILL_DIR/config/credentials.json"

echo "=== 得到大脑连接器 Setup ==="
echo "Skill 目录: $SKILL_DIR"

# 1. 检查凭证
if [ ! -f "$CRED_FILE" ]; then
  echo "❌ 凭证文件不存在: $CRED_FILE"
  echo "   请在 config/credentials.json 中配置 api_key 和 client_id"
  exit 1
fi

API_KEY=$(python3 -c "import json; print(json.load(open('$CRED_FILE'))['api_key'])")
CLIENT_ID=$(python3 -c "import json; print(json.load(open('$CRED_FILE'))['client_id'])")

if [ -z "$API_KEY" ] || [ -z "$CLIENT_ID" ]; then
  echo "❌ 凭证文件中 api_key 或 client_id 为空"
  exit 1
fi
echo "✅ 凭证已读取"

# 2. 安装/检查 CLI
mkdir -p "$CLI_DIR"
cd "$CLI_DIR"

if [ -d "node_modules/@getnote/cli" ]; then
  echo "✅ getnote CLI 已安装"
else
  echo "📦 安装 @getnote/cli ..."
  npm init -y >/dev/null 2>&1
  npm install @getnote/cli axios form-data 2>&1 | tail -3
  echo "✅ CLI 安装完成"
fi

# 3. 配置凭证
echo "🔑 配置 getnote 凭证..."
cd "$CLI_DIR"
npx getnote auth login --api-key "$API_KEY" --client-id "$CLIENT_ID" 2>&1 | grep -v "npm notice" || true

# 4. 自检
echo "🔍 连通性自检..."
DOCTOR_OUTPUT=$(cd "$CLI_DIR" && npx getnote doctor -o json 2>/dev/null)
READY=$(echo "$DOCTOR_OUTPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('ready', False))" 2>/dev/null || echo "false")

if [ "$READY" = "True" ]; then
  echo "✅ 得到大脑连接成功！API 就绪。"
else
  echo "⚠️  自检返回非 ready 状态，详情如下："
  echo "$DOCTOR_OUTPUT" | python3 -c "import json,sys; d=json.load(sys.stdin); print('status:', d.get('status')); print('summary:', d.get('summary')); [print(' -', i.get('message')) for i in d.get('issues',[])]" 2>/dev/null || echo "$DOCTOR_OUTPUT" | head -20
fi

echo ""
echo "=== Setup 完成 ==="
echo "后续使用：bash $SCRIPT_DIR/getnote.sh <命令> <参数>"
echo "例如：bash $SCRIPT_DIR/getnote.sh search '关键词' --limit 5 -o json"

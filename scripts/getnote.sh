#!/usr/bin/env bash
# 得到大脑 CLI 封装脚本
# 用途：自动处理工作目录，透传所有参数给 getnote CLI
# 用法：bash <skill_dir>/scripts/getnote.sh <命令> <参数>
# 示例：
#   bash getnote.sh search "运动袜" --limit 5 -o json
#   bash getnote.sh note <note_id> -o json
#   bash getnote.sh kb <topic_id> --limit 50 -o json
#   bash getnote.sh doctor -o json

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
CLI_DIR="$SKILL_DIR/cli"

# 如果 CLI 未安装，先跑 setup
if [ ! -d "$CLI_DIR/node_modules/@getnote/cli" ]; then
  echo "ℹ️  CLI 未安装，先执行 setup..."
  bash "$SCRIPT_DIR/setup.sh"
fi

# 如果凭证未配置，先跑 setup
if [ ! -f ~/.getnote/config.json ]; then
  echo "ℹ️  凭证未配置，先执行 setup..."
  bash "$SCRIPT_DIR/setup.sh"
fi

cd "$CLI_DIR"
npx getnote "$@"

---
name: dedao-getnote
description: 得到大脑（Get笔记）持久化连接器。封装 @getnote/cli，支持笔记搜索、读取、知识库浏览、录音转写、语义检索等。当用户提到"得到大脑"、"得到笔记"、"getnote"、"搜索笔记"、"读取笔记"、"我的知识库"、"录音转写"、"得到大脑里的素材/文档"，或需要从得到大脑获取内容时使用此 Skill。新对话或环境重置后一键恢复连接，无需重新配置凭证。
---

# 得到大脑连接器

## 快速开始（新对话必做）

环境重置后 `~/.getnote/config.json` 会丢失，先跑一键恢复（`<skill_dir>` 为技能所在目录，任意位置搬迁均可直接使用）：

```bash
bash <skill_dir>/scripts/setup.sh
```

该脚本自动完成：CLI 安装检查 → 凭证写入 → 连通性自检。成功后显示 "得到大脑连接成功！"。

## 环境依赖

- **bash**：脚本为 bash 编写，Windows 上需 Git Bash / WSL / MSYS 环境
- **python3**：用于解析凭证与 JSON 输出
- **node + npm**：getnote CLI 依赖（`cli/node_modules` 已随包附带，如缺失会自动 `npm install`，需网络）

## 日常使用

所有命令通过封装脚本执行（自动处理工作目录和凭证）：

```bash
bash <skill_dir>/scripts/getnote.sh <命令> <参数>
```

### 常用命令

| 操作 | 命令 |
|---|---|
| 全局语义搜索 | `getnote.sh search "关键词" --limit 5 -o json` |
| 最近笔记 | `getnote.sh notes --limit 20 -o json` |
| 笔记详情 | `getnote.sh note <note_id> -o json` |
| 笔记原文 | `getnote.sh note original <note_id>` |
| 录音转写 | `getnote.sh note transcript <note_id>` |
| 录音时间线 | `getnote.sh note timeline <note_id>` |
| 录音待办提取 | `getnote.sh note todos <note_id>` |
| 知识库列表 | `getnote.sh kbs -o json` |
| 知识库内笔记 | `getnote.sh kb <topic_id> --limit 50 -o json` |
| 保存笔记 | `getnote.sh save "文字内容" --tag 标签 -o json` |
| 保存链接 | `getnote.sh save https://example.com --tag 阅读 -o json` |
| 自检 | `getnote.sh doctor -o json` |

### JSON 解析注意

`note` 命令返回结构为 `data.note`（不是 `data` 直接）。解析示例：

```bash
getnote.sh note <note_id> -o json | python3 -c "
import json,sys
note = json.load(sys.stdin)['data']['note']
print(note['title'])
print(note['content'][:500])
"
```

`search` 和 `kb` 命令返回结构为 `data.results` / `data.notes`。

## 知识库映射

19 个知识库的 topic_id 详见 [references/knowledge-bases.md](references/knowledge-bases.md)。

常用：
- 叙事能力/脚本策划 → `LYwkK1BY`
- 电商/供应链 → `yYvO4or0`
- AI组织管理 → `yYv6vdxY`
- 日常工作录音 → `oYp246RJ`

## 凭证管理

凭证存储在 `config/credentials.json`（随 Skill 持久化，环境重置不丢失）。

更换凭证：编辑 `config/credentials.json` 后重跑 `setup.sh`。

**安全提示**：此文件包含 API 密钥，不要提交到公开仓库或分享给他人。

## 文件结构

```
dedao-getnote/
├── SKILL.md                    # 本文件
├── config/
│   └── credentials.json        # API 凭证（持久化）
├── scripts/
│   ├── setup.sh                # 一键安装+配置+自检
│   └── getnote.sh              # CLI 封装（自动处理路径和凭证）
├── references/
│   └── knowledge-bases.md      # 19个知识库 topic_id 映射
└── cli/                        # CLI 安装目录（setup.sh 自动创建）
    └── node_modules/@getnote/cli
```

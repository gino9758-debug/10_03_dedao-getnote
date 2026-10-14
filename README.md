# dedao-getnote

得到大脑（Get笔记）持久化连接器技能（Skill）：封装 @getnote/cli，支持笔记搜索、读取、知识库浏览、录音转写、语义检索等。

## 用途

本仓库为**私有储藏**用途，用于备份和版本管理「dedao-getnote」技能本体（含 CLI 依赖）。

## 技能能力

- 笔记搜索、读取、知识库浏览、语义检索、录音转写
- 封装 `@getnote/cli`，提供 `getnote.sh`、`setup.sh`、`getnote-mcp-http.js` 等工具脚本
- CLI 依赖（`cli/node_modules`）已随包附带，可直接使用

## 目录结构

```
dedao-getnote/
├── SKILL.md                    # 技能主文件
├── cli/                        # getnote CLI 及 node_modules 依赖
├── config/
│   └── credentials.json        # ⚠️ 含 API 密钥，已通过 .gitignore 排除，不入库
├── references/
│   └── knowledge-bases.md      # 知识库说明
└── scripts/
    ├── getnote.sh              # CLI 封装脚本
    ├── setup.sh                # 一键初始化/恢复脚本
    └── getnote-mcp-http.js     # MCP HTTP 服务
```

## 安装方法

将 `dedao-getnote/` 目录放入助手的技能根目录（如 `.user_skills/`），重启会话后技能即可被发现和调用。

## 凭据说明

- API 密钥存放于 `config/credentials.json`，该文件**已被 .gitignore 排除，不会进入 Git 仓库**。
- 新环境部署时需自行放置/恢复该凭据文件（或运行 `setup.sh`）。
- ⚠️ 若凭据文件曾以其他方式外泄，请到得到大脑后台轮换密钥。

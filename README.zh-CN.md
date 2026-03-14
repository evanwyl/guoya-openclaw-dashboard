# OpenClaw Dashboard（中文说明）

OpenClaw Dashboard 是一个面向 OpenClaw 的本地监控面板。
它可以查看会话、用量、成本、日志、系统状态，并提供基础安全登录能力。

## 一键安装（推荐）

```bash
git clone https://github.com/<你的用户名>/openclaw-dashboard.git
cd openclaw-dashboard
NONINTERACTIVE=1 WORKSPACE_DIR=$HOME/clawd OPENCLAW_DIR=$HOME/.openclaw DASHBOARD_PORT=7000 ./install.sh
./run-dashboard.sh
```

启动后访问：

- `http://localhost:7000`

## 适合 OpenClaw 自动配置（无交互）

如果你希望 agent 自动完成安装，请使用：

```bash
NONINTERACTIVE=1 WORKSPACE_DIR=$HOME/clawd OPENCLAW_DIR=$HOME/.openclaw DASHBOARD_PORT=7000 ./install.sh
```

该模式不会询问输入，适合自动化执行。

## 前置要求

- Node.js 18+
- 已安装 OpenClaw
- （可选）`tmux`：用于 Claude usage 抓取
- （可选）`jq`：用于 Docker 页面部分功能

## 手动启动

```bash
export WORKSPACE_DIR=$HOME/clawd
export OPENCLAW_DIR=$HOME/.openclaw
export OPENCLAW_AGENT=main
node server.js
```

## 常用环境变量

- `DASHBOARD_PORT`：面板端口，默认 `7000`
- `WORKSPACE_DIR`：工作目录
- `OPENCLAW_DIR`：OpenClaw 目录，默认 `~/.openclaw`
- `OPENCLAW_AGENT`：默认 `main`
- `DASHBOARD_TOKEN`：找回密码用的恢复令牌
- `DASHBOARD_ALLOW_HTTP=true`：允许非 localhost 明文 HTTP（不推荐公网）

## 主要功能

- 会话历史与搜索
- Claude/Gemini 用量与成本
- 实时消息流（Live Feed）
- Memory/Files 查看与编辑
- 系统状态监控（CPU/RAM/Disk）
- 审计日志与安全页面
- Cron 查看与触发

## 数据与文件位置

- 会话数据：`$OPENCLAW_DIR/agents/$OPENCLAW_AGENT/sessions/`
- Cron：`$OPENCLAW_DIR/cron/jobs.json`
- 健康历史：`$WORKSPACE_DIR/data/health-history.json`
- 认证信息：`$WORKSPACE_DIR/data/credentials.json`
- 审计日志：`$WORKSPACE_DIR/data/audit.log`

## Gemini 脚本

仓库已包含：

- `scripts/scrape-gemini-usage.sh`
- `scripts/parse-gemini-usage.py`

安装脚本会自动复制到你的 workspace `scripts/` 目录（若不存在）。

## 安全提醒

- 默认用于本机/内网，不建议直接暴露公网
- 首次启动请保存 Recovery Token
- 建议开启 MFA
- 生产场景建议配合反向代理与 HTTPS

## 发布者快速检查清单

发布到 GitHub 前建议确认：

- `.gitignore` 已忽略日志与凭据
- 不包含真实密钥、令牌、私密配置
- `install.sh`、`run-dashboard.sh` 可执行
- README 中仓库地址替换为你的账号

## License

MIT（见 `LICENSE`）

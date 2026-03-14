# Guoya OpenClaw Dashboard

OpenClaw 的本地可视化面板，面向已经安装 OpenClaw 的使用场景。

这个仓库当前以单文件前端加 Node.js 后端的方式运行，主要用于查看会话、用量、成本、日志、配置和系统状态。README 内容已按当前代码重新整理，不再沿用上游项目的旧截图和旧版本说明。

## 当前代码包含的功能

- 会话总览与会话详情
- 成本统计与模型维度用量统计
- Claude/Gemini usage 抓取与展示
- Live Feed 实时消息流
- Memory 文件查看
- Key Files/技能文件查看与编辑
- Cron 任务查看、启停和手动触发
- 系统状态、健康历史和响应时间
- 服务状态查看与常用维护操作
- 日志查看
- 用户名密码登录
- Recovery Token 重置密码
- TOTP MFA
- 配置读取与保存
- Docker 信息查看与基础操作
- Tailscale 状态查看
- 通知中心与审计日志

说明：

- 部分页面在前端里默认隐藏，但后端接口和页面结构仍然存在。
- Docker、Tailscale、Claude usage、Gemini usage 等功能依赖本机环境，缺少对应命令时会显示为空或不可用。

## 平台支持

当前仓库提供两套运行方式：

- macOS / Linux：推荐使用 [install.sh](install.sh) 和 [run-dashboard.sh](run-dashboard.sh)
- Windows：推荐使用 [install.ps1](install.ps1) 和 [run-dashboard.ps1](run-dashboard.ps1)

Windows 说明：

- Node.js 服务和前端页面可以运行
- 登录、会话、成本、Memory、Files、基础配置等主要功能可用
- 部分系统级功能依赖 Linux/macOS 命令，在 Windows 下会受限或不可用
- 例如 `systemctl`、`journalctl`、`tmux`、部分 Tailscale 和系统服务控制能力

## 安装方式

### 方式 1：推荐，自动安装

```bash
git clone https://github.com/evanwyl/guoya-openclaw-dashboard.git
cd guoya-openclaw-dashboard
NONINTERACTIVE=1 WORKSPACE_DIR=$HOME/clawd OPENCLAW_DIR=$HOME/.openclaw DASHBOARD_PORT=7000 ./install.sh
./run-dashboard.sh
```

浏览器打开：

```bash
http://localhost:7000
```

### 方式 1B：Windows 安装

在 PowerShell 中执行：

```powershell
git clone https://github.com/evanwyl/guoya-openclaw-dashboard.git
cd guoya-openclaw-dashboard
powershell -ExecutionPolicy Bypass -File .\install.ps1 -NonInteractive
powershell -ExecutionPolicy Bypass -File .\run-dashboard.ps1
```

浏览器打开：

```text
http://localhost:7000
```

### 方式 2：手动启动

```bash
cd guoya-openclaw-dashboard
export WORKSPACE_DIR=$HOME/clawd
export OPENCLAW_DIR=$HOME/.openclaw
export OPENCLAW_AGENT=main
node server.js
```

首次启动后，终端会打印 Recovery Token。请保存好，忘记密码时会用到。

## 运行要求

- Node.js 18 或更高
- 本机已安装 OpenClaw
- `python3`：Claude/Gemini usage 解析脚本需要
- `tmux`：Claude usage 抓取需要
- `jq`：Docker 页面部分命令需要
- `docker`：Docker 页面需要
- `tailscale`：Tailscale 状态页需要

## 常用环境变量

| 变量 | 作用 | 默认值 |
|---|---|---|
| `DASHBOARD_PORT` | 面板端口 | `7000` |
| `WORKSPACE_DIR` | 工作目录 | 当前目录或 `$OPENCLAW_WORKSPACE` |
| `OPENCLAW_DIR` | OpenClaw 目录 | `~/.openclaw` |
| `OPENCLAW_AGENT` | 默认 agent | `main` |
| `DASHBOARD_TOKEN` | 密码找回 token | 自动生成 |
| `DASHBOARD_ALLOW_HTTP` | 允许非 localhost 明文 HTTP | `false` |
| `NONINTERACTIVE` | 安装脚本无交互模式 | `0` |

## 目录说明

- [server.js](server.js)：后端入口与 API
- [index.html](index.html)：前端页面
- [install.sh](install.sh)：安装脚本
- [run-dashboard.sh](run-dashboard.sh)：启动脚本
- [install.ps1](install.ps1)：Windows 安装脚本
- [run-dashboard.ps1](run-dashboard.ps1)：Windows 启动脚本
- [scripts/scrape-claude-usage.sh](scripts/scrape-claude-usage.sh)：Claude usage 抓取
- [scripts/parse-claude-usage.py](scripts/parse-claude-usage.py)：Claude usage 解析
- [scripts/scrape-gemini-usage.sh](scripts/scrape-gemini-usage.sh)：Gemini usage 抓取
- [scripts/parse-gemini-usage.py](scripts/parse-gemini-usage.py)：Gemini usage 解析

## 数据来源

面板主要读取以下位置的数据：

- `$OPENCLAW_DIR/agents/$OPENCLAW_AGENT/sessions/`
- `$OPENCLAW_DIR/cron/jobs.json`
- `$WORKSPACE_DIR/MEMORY.md`
- `$WORKSPACE_DIR/HEARTBEAT.md`
- `$WORKSPACE_DIR/memory/*.md`
- `$WORKSPACE_DIR/data/*.json`

## 安全说明

- 默认更适合本机或内网使用，不建议直接裸露到公网
- 已包含登录、会话校验、MFA、基础限流和审计日志
- 如果需要外网访问，建议放在反向代理和 HTTPS 后面

## 当前文档状态

- README 已移除上游仓库遗留截图
- 功能描述按当前代码重新整理
- `RELEASE_NOTES.md` 已改为本仓库自己的发布说明

## License

MIT，见 [LICENSE](LICENSE)

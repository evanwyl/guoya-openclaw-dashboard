# Release Notes

## v0.1.0 - 2026-03-14

这是当前仓库作为独立项目整理后的首个公开版本说明，不再沿用上游项目的旧版本号和旧发布记录。

### 本次整理内容

- README 改为基于当前代码重新描述
- 移除上游仓库遗留截图展示
- 增加中文说明与更适合本仓库的安装方式
- 安装脚本支持 `NONINTERACTIVE=1`
- 补齐 Gemini usage 抓取和解析脚本
- 修正 OpenClaw 配置文件路径说明
- 保留当前代码中的认证、MFA、配置编辑、Docker、日志、Cron、会话、用量和成本相关能力

### 当前版本重点

- 可通过 `install.sh` 进行安装
- 可通过 `run-dashboard.sh` 或 `node server.js` 启动
- 支持 OpenClaw 会话、成本、用量、Memory、Files、Cron、日志和系统状态查看
- 支持登录、重置密码和 TOTP MFA
- 支持本地环境下的 Docker、Tailscale、配置编辑和审计通知

### 说明

- 某些功能依赖宿主机环境，例如 `docker`、`tailscale`、`tmux`、`jq`
- 部分页面虽然在代码中存在，但前端默认可能隐藏
- 后续如果出现你自己的正式发布版本，可以继续从 `v0.1.1`、`v0.2.0` 或 `v1.0.0` 开始维护

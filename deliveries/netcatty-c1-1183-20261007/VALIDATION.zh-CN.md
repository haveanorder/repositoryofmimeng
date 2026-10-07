# 实际验证范围（2026-10-07）

**Windows x64 实际运行验收通过。** 使用官方 Netcatty 1.1.83 发布文件，在 GitHub Actions 的 Windows runner 上应用本目录的程序资源补丁。完整作业：[37603159259](https://github.com/haveanorder/repositoryofmimeng/actions/runs/37603159259)。验收源码/补丁提交：`628987bace3fa1497effdc714203b1967a00fa0f`。最终 ZIP 仅补入本说明等文档；程序资源、manifest 和 PowerShell 脚本与该验收相同。

## Windows 已通过

| 项目 | 实际检查 |
|---|---|
| 原程序启动 | 官方 Netcatty.exe，ProductVersion 1.1.83.0，隔离用户数据目录 |
| 补丁入口 | Windows 自带 PowerShell 5；检查、备份、应用、回滚；安装路径与 CLI 路径含空格 |
| 数据保留 | 官方程序先写入测试主机、密钥、聊天、既有 Codex 配置和字号；补丁后及回滚后均读取成功 |
| 凭据兼容 | 原 DPAPI 密文在补丁后及回滚后解密成功；三个新 Agent 保存的可选密钥均为 enc:v1 密文 |
| 实际版本 | OMP 18.5.1 Windows 官方 exe；Pi 1.0.3 Windows 官方 exe 的 cmd 包装入口及 npm cmd；DSH CLI 0.2.0-rc.2 全局 npm cmd |
| 设置 → 进程 | 实际打开三个设置卡片，填写路径/工作目录/模型，通过真实 CLI 测试模型连接并保存 |
| 侧栏 → AgentRuntime | 实际选择三个 Agent，发送消息并看到 CLI 的流式回复与原生状态 |
| Netcatty MCP | 两个实际本地 PTY；仅授权终端可见；审批后执行 echo 命令；拒绝后不执行 |
| 交互 | OMP/Pi 受控扩展提问，DSH ask_user_question，通过既有交互渠道回答 |
| 停止 | 等待 MCP 审批时停止；随后发送的批准未执行命令 |
| 恢复 | 关闭原生进程后，用 Netcatty 保存的外部 SDK 会话身份重启；恢复后的实际模型请求包含此前历史 |
| 回滚 | app.asar 恢复为官方原始哈希，Netcatty.exe 内容不变；原程序再次启动，测试数据及凭据保留 |

Windows 安装目录自动识别/图形目录选择入口已提供；CI 使用明确目录参数，未在 CI 中操作用户实际的安装注册表或目录选择对话框。用户电脑上既有 pi.cmd 的内容没有远程读取；已覆盖独立 exe 包装与 npm 两种常见入口，仍需按 START 中短步骤检查本机入口。

## Linux 与构建检查

三个实际版本也完成 Linux CLI 启动、流式收发、本地工作区工具批准/拒绝、交互、一次原生恢复与停止。在打包后的 Electron 42.3.3 + Xvfb 上完成设置保存、侧栏 AgentRuntime、Netcatty MCP 范围、本地终端命令、审批/停止等检查。Linux 测试使用隔离配置；DSH 本地工作区工具测试明确设置测试权限模式以适应云容器，该覆盖不进入产品配置。

`npm ci`/postinstall、`npm run lint`、`npm run build` 和 `npm run pack:dir` 通过。执行了驱动注册、RPC 解码、CLI/发现、SDK handler/adapter 和会话身份相关的聚焦回归；未反复执行整仓上万项测试。

额外执行的 `tsc --noEmit` 未通过：官方原始源码与本补丁各报告同样的 731 项诊断，忽略源码根目录和行号后的诊断集合相同，没有新增诊断。记录在 `validation/types-comparison.json`；因此不宣称全仓类型检查通过。

资源比较另确认：8777 个无关 packed 文件保持原内容，1114 个原有 unpacked 文件复用不变，原 Netcatty.exe 不进入补丁 payload。这些哈希检查用于说明补丁范围；实际运行结论来自上述 Windows/CLI 验收。

## 明确的剩余限制

- 模型请求来自**本地可控 HTTP 模型服务**，真实 OMP/Pi/DSH CLI 负责启动、协议、工具、MCP 和持久化；没有使用真实云模型凭据，不能据此宣称云模型认证或输出质量已验证。
- MCP 命令在实际本地 PTY 执行；未连接真实 SSH/SFTP 服务端。用户本机安装、主机和 Agent 认证文件从未被远程覆盖或读取。
- 原有 Codex/Claude 接入代码和数据结构保留；验证了既有 Codex 配置保留，没有调用它们的云模型。
- 当前三个接入接受文本提示。附件请发送路径，交给 Agent 已有工具或 Netcatty MCP 读取；OMP/Pi 自定义扩展的任意复杂 TUI 不在本次范围。
- 补丁适用于官方 1.1.83 Windows x64 资源。后续官方应用更新可能覆盖补丁；不要向其他版本强行应用。补丁未新增代码签名，不是上游官方发行版。

安装、配置和本机短验收见 START.zh-CN.md；具体实现及复现见 TECHNICAL.zh-CN.md。Windows 验收要点与日志保存在 validation/。

# Netcatty 方案 C 工作记录

整理日期：2026-10-05。此文依据当前源代码、构建产物及保存的执行日志整理，不是完整聊天记录导出。

## 工作位置与范围

- 实际 checkout：`/workspace/Netcatty`；分支 `work`；HEAD／补丁基线 `de6d1a28ba577358d4bb03ae78ba32f9b87050c0`。
- 源代码改动仍在该 checkout，未创建工作树、推送、合并或发布 release。
- 本任务负责方案 C：OMP 原生 RPC、Pi RPC 与受控扩展、DSH 专用 profile 和内部服务桥接。
- 方案 D（通用 ACP）由另一个独立云环境负责，本环境没有取得其交付文件。本包不能被称为 C+D 合并版本。

## 实施阶段

1. 复用既有 Node 24、依赖、Electron 和 PTY 环境，核对仓库与 AGENTS.md；没有重复运行完整 onboarding 或一万多项测试。
2. 从官方资源准备实际引擎。OMP 设计快照 18.6.2 无可用目标发行包，最终使用可运行且带原生组件的 18.6.1；Pi 为 1.0.2，DSH 为 0.2.1-alpha.1。
3. 优先验证 DSH 内部服务入口，以专用 profile 加薄桥接复用 Session、Agent、审批、问题、计划和 Jobs，未重写 agent loop。
4. 实现 OMP 独立协议处理，包括 ready、v2 分块、session_settled、MCP 宿主回调与子任务操作。Pi 采用原生 RPC、受控扩展和动态 MCP 注册。
5. 将三类驱动接入既有 AgentRuntime、MCP、审批、stopAgentTurn、原生会话恢复与退出清理。区分本机工作区工具和远程 MCP 范围。
6. 完善设置页、版本检查、模型显示、密钥移除、交互卡、计划审核、任务输出与操作。77 个新增翻译键覆盖英文、简体中文、繁体中文。
7. 用真实官方 CLI 和明确标注的本地可控模型服务验证流程；再运行真实 Electron、MCP、本地 PTY 及中文界面验证。
8. 编译 Windows 原生模块并生成 x64 安装版、便携版和 ZIP。完成校验并保存源码 ZIP、完整补丁、说明、截图和验证日志。
9. 为无法下载工作区链接的情况准备 Google Drive 上传。当前运行实例未收到授权凭据，上传尚未发生；打包、工作记录整理与可再生缓存清理已独立执行。

## Windows 构建记录

- 预览版：`0.0.0-c1.20261005`，产品名 `Netcatty C1`，App ID `com.netcatty.native-c1`。
- Electron 42.3.3；xwin 0.10.0；Microsoft SDK 10.0.26100、CRT 14.44.35220；LLVM/LLD 19.1.7。
- 从原项目源码编译 Windows Hello、带补丁的 ConPTY、conpty_console_list 和 windows_process_tree；复用官方 Windows 原生预构建依赖。
- Linux 云环境中的 Wine 试验未能完成引导程序运行。最终采用 electron-builder 26.15.2 自带、已用于 macOS 的 UninstallerReader 提取 NSIS 卸载程序，保留标准安装脚本。
- 最终成功构建不依赖 Wine 或 Docker。相关失败试验环境可清理，编译器、SDK、Windows staging 依赖及本机开发依赖保留。
- 修正 Pi 的 npm shim 入口定位，不通过其受 exports 限制的 package.json 解析。实际安装的 Pi/DSH 入口已运行版本检查。
- Windows 文件未签名，未在真实 Windows 桌面执行，不将 PE／归档校验称为 Windows 实机验证。

## 验证与限制

详细验收见 C1/VALIDATION.md 和 C1/TECHNICAL.md；附带的 validation、windows 日志保存最终相关证据。

通过：真实 CLI 中文收发、工具调用、批准／拒绝、停止、恢复；OMP 子任务取消；Pi 扩展问答；DSH 问题、计划、任务、延迟答复；Electron MCP/PTY 范围与迟到审批保护；中文前端；必要回归、lint、Vite build、Linux 打包及 Windows 归档校验。

限制：没有真实云模型凭据、SSH/SFTP 服务端或真实 Windows/macOS 桌面验证；全仓库 TypeScript 检查仍有基线错误；三类引擎的任意第三方 TUI/扩展不保证兼容。未取得 D 版源码、补丁或验证结果。

## 文件保管与传输

C1 交付文件的内部 manifest 和 SHA256SUMS 保持原样。总交付 ZIP 追加本工作记录后会重新生成外部 SHA256。

Google Drive 上传需当前运行实例实际获得 NETCATTY_DRIVE_ACCESS_TOKEN。只通过指定 Google API 域名使用该凭据；不将凭据、浏览器 profile、Agent auth 文件打入交付包。上传后应核对远端大小与哈希，再提供账户内文件链接。

# Netcatty 方案 C 云端交付

预览版本：`0.0.0-c1.20261005`。本目录保存交付说明与工作记录，大文件位于本仓库的 [Release](https://github.com/haveanorder/repositoryofmimeng/releases/tag/netcatty-c1-20261005) 附件。

## 下载

| 文件 | 内容 | 大小 |
|---|---|---:|
| [完整交付包](https://github.com/haveanorder/repositoryofmimeng/releases/download/netcatty-c1-20261005/Netcatty-C1-Delivery-With-Worklog-20261005.zip) | `Netcatty-C1-Delivery-With-Worklog-20261005.zip` | 463.84 MiB |
| [Windows x64 安装版](https://github.com/haveanorder/repositoryofmimeng/releases/download/netcatty-c1-20261005/Netcatty-C1-Windows-x64-Setup.exe) | `Netcatty-C1-Windows-x64-Setup.exe` | 132.19 MiB |
| [Windows x64 便携版](https://github.com/haveanorder/repositoryofmimeng/releases/download/netcatty-c1-20261005/Netcatty-C1-Windows-x64-Portable.exe) | `Netcatty-C1-Windows-x64-Portable.exe` | 131.96 MiB |
| [完整源码](https://github.com/haveanorder/repositoryofmimeng/releases/download/netcatty-c1-20261005/Netcatty-C1-Source.zip) | `Netcatty-C1-Source.zip` | 17.55 MiB |
| [工作记录包](https://github.com/haveanorder/repositoryofmimeng/releases/download/netcatty-c1-20261005/Netcatty-C1-Work-Records-20261005.zip) | `Netcatty-C1-Work-Records-20261005.zip` | 0.26 MiB |

[SHA256 校验文件](SHA256SUMS.txt)；下载后可在 PowerShell 用 `Get-FileHash -Algorithm SHA256 文件路径` 核对。

## 实现与启动

- OMP **18.6.1** 原生 RPC；Pi **1.0.2** RPC 与受控扩展；DSH **0.2.1-alpha.1** 专用 profile 与内部服务桥接。
- 包含设置、真实 CLI 启动、消息与工具事件、Netcatty MCP、审批、停止、原生会话恢复，以及相应的子任务／扩展交互／计划审核与任务呈现。
- 新增界面支持英文、简体中文、繁体中文；本机工具与远程 MCP 范围分开配置。
- 安装与引擎准备请读 [中文启动说明](START.zh-CN.md)，技术边界见 [TECHNICAL.md](TECHNICAL.md)。应用安装包不内置全部 Agent CLI 和模型凭据，需按说明安装引擎。
- 完整交付包中另含 Windows x64 ZIP、原始补丁、截图、验证日志及 ChatGPT 项目交接 Markdown。

## 验证范围

真实官方 CLI + 明确标注的本地可控模型服务、真实 Electron/MCP/本地 PTY、审批／停止／恢复、中文界面、必要回归、lint/build 和打包已验证。见 [验证记录](VALIDATION.md)。

Windows 文件未签名；尚未验证真实 Windows/macOS 桌面、真实云模型、SSH/SFTP 服务端或 Windows Hello 生物认证。全仓库 TypeScript 检查仍有基线错误。不能将归档或 PE 校验视为 Windows 实机测试。

## 工作记录与 D 版状态

- [实施工作记录](WORKLOG.zh-CN.md)
- [云工作区清理记录](CLEANUP.zh-CN.md)：实际释放约 2.47 GiB，源码、交付物、引擎与编译资源保留。
- [D 版交付状态](D-DELIVERY-STATUS.zh-CN.md)：D 版位于另一个独立环境，尚未取得其文件。本交付仅包含 C 版，不能称为 C/D 合并版。

工作记录包保留整理时的检查快照，其中 Google Drive 凭据未生效的记录属于传输过程历史；用户随后指定本 GitHub 仓库作为交付位置。

Netcatty 源码来自 haveanorder/Netcatty，补丁基线为 `de6d1a28ba577358d4bb03ae78ba32f9b87050c0`。源码 ZIP 保留原项目许可证与第三方声明，具体许可按各自文件适用。

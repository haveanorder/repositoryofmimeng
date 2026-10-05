# Netcatty 方案 C 云端交付

预览版本：`0.0.0-c1.20261005`。Windows 程序、完整源码、补丁、启动说明、截图、工作记录与验证日志均已整理到本仓库。

## 下载与 Windows 安装

1. **[下载完整交付仓库 ZIP](https://github.com/haveanorder/repositoryofmimeng/archive/refs/tags/netcatty-c1-20261005.zip)**，约 485 MiB。GitHub Release 页面中的 **Source code (zip)** 也是同一个包；本仓库的 ZIP 已包含实际交付分卷，并非只有源码。
2. 将下载的 ZIP 整个解压，进入 `deliveries/netcatty-c1-20261005/package`。
3. 双击 **`Merge-Netcatty.cmd`**，等待显示 `Complete. SHA256 verified.`。脚本把 20 个分卷还原为 `Netcatty-C1-Delivery-With-Worklog-20261005.zip`（463.84 MiB），并核对 SHA256。
4. 解压还原的 ZIP，进入 `C1`，运行 **`Netcatty-C1-Windows-x64-Setup.exe`**；也可选择 Portable.exe 便携版或 Windows-x64.zip。

保留全部分卷在同一个目录；不要单独解压 part 文件。合并脚本只还原 ZIP 和校验，不自动运行安装程序。Linux/macOS 合并命令见 [分卷说明](package/README.zh-CN.md)。

只需要部分资料时可直接下载：

- [完整源码 ZIP（17.55 MiB）](https://github.com/haveanorder/repositoryofmimeng/raw/refs/heads/main/deliveries/netcatty-c1-20261005/Netcatty-C1-Source.zip)
- [工作记录 ZIP（约 270 KiB）](https://github.com/haveanorder/repositoryofmimeng/raw/refs/heads/main/deliveries/netcatty-c1-20261005/Netcatty-C1-Work-Records-20261005.zip)
- [源码补丁](Netcatty-C1-Changes.patch)、[SHA256 校验值](SHA256SUMS.txt)、[分卷清单与校验值](package/parts.json)

## 实现与启动

- OMP **18.6.1** 原生 RPC；Pi **1.0.2** RPC 与受控扩展；DSH **0.2.1-alpha.1** 专用 profile 与内部服务桥接。
- 包含设置、真实 CLI 启动、消息与工具事件、Netcatty MCP、审批、停止、原生会话恢复，以及相应的子任务／扩展交互／计划审核与任务呈现。
- 新增界面支持英文、简体中文、繁体中文；本机工具与远程 MCP 范围分开配置。
- 安装与引擎准备请读 [中文启动说明](START.zh-CN.md)，技术边界见 [TECHNICAL.md](TECHNICAL.md)。应用安装包不内置全部 Agent CLI 和模型凭据，需按说明安装引擎。

## 验证范围

真实官方 CLI + 明确标注的本地可控模型服务、真实 Electron/MCP/本地 PTY、审批／停止／恢复、中文界面、必要回归、lint/build 和打包已验证。见 [验证记录](VALIDATION.md)。

Windows 文件未签名；尚未验证真实 Windows/macOS 桌面、真实云模型、SSH/SFTP 服务端或 Windows Hello 生物认证。全仓库 TypeScript 检查仍有基线错误。不能将归档或 PE 校验视为 Windows 实机测试。

## 工作记录与 D 版状态

- [实施工作记录](WORKLOG.zh-CN.md)
- [云工作区清理记录](CLEANUP.zh-CN.md)：清理阶段实际释放约 2.47 GiB，源码、交付物、引擎与编译资源保留。之后本 GitHub 交付副本会占用一定空间。
- [D 版交付状态](D-DELIVERY-STATUS.zh-CN.md)：D 版位于另一个独立环境，尚未取得其文件。本交付仅包含 C 版，不能称为 C/D 合并版。

工作记录包保留整理时的检查快照，其中 Google Drive 凭据未生效的记录属于传输过程历史；用户随后指定本 GitHub 仓库作为交付位置。此环境的 Release 二进制附件接口返回 Content-Length 错误，因此完整程序通过已校验的 Git 分卷交付。

Netcatty 源码来自 haveanorder/Netcatty，补丁基线为 `de6d1a28ba577358d4bb03ae78ba32f9b87050c0`。源码 ZIP 保留原项目许可证与第三方声明，具体许可按各自文件适用。

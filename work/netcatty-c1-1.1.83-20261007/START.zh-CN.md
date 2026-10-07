# Netcatty 1.1.83 C1 功能补丁

目标是现有 Netcatty 1.1.83 Windows x64 安装。基线源码为官方 v1.1.83（d7a0c8ed8d238dcf1c82d786da53037a1f1496b1），应用身份、Netcatty.exe、用户配置目录保持原版。此补丁不是上游官方签名发行版。

本目录为开发与验收资源。只有全部验收完成后的 accepted 包可以应用，acceptance-pending 包会拒绝应用。不要把源码工作分支当作完成交付。

完成包解压后运行 check.cmd；自动定位失败时指定安装目录，例如 check.cmd -InstallDir "安装目录"。关闭 Netcatty 后运行 apply.cmd（同样支持 -InstallDir）。安装目录需要管理员写入权限时，以管理员身份运行。运行 rollback.cmd 可恢复最后一次备份。不要在 Netcatty 正在运行时应用或回滚。

补丁仅更新应用资源，备份保存在安装目录 Netcatty-C1-Backups；不修改 Agent 安装、认证或 Netcatty 用户配置。仍通过原快捷方式启动。

设置 → AI → Agents：可自动发现或填写 OMP/Pi/DSH 的 exe/cmd 路径，保存工作目录、附加参数（JSON 字符串数组）、可选模型 provider/model 和环境变量。模型留空沿用 CLI 配置。检查会启动 CLI 完成协议握手，但不发送收费模型请求，也不代表模型认证成功。检查保存后在聊天侧栏选择对应 Agent。

实际兼容目标：OMP 18.5.1、Pi 1.0.3、DSH CLI 0.2.0-rc.2。不要求另装旧 C1 所用版本。不使用固定用户名或盘符。

验收使用隔离配置和本地可控模型服务，不使用用户密钥。Windows runner 的启动、收发、审批、停止、恢复、MCP 和应用/回滚结果以对应 GitHub Actions 日志为准；不能将构建或哈希相同视为用户 Windows 机器验收。用户实机最后检查：原主机/密钥/设置仍在；三个 Agent 逐一连接并发送消息；执行一次审批与停止；重开一次会话。

当前未有可核实的模型/推理强度运行标识，因此没有宣称 GPT-6.1-Sol、Max 已指定。

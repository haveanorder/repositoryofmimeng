# Netcatty 1.1.83 → C1 Windows x64 程序补丁

这是供已安装程序使用的离线差分补丁，基准为 **官方 Netcatty 1.1.83 Windows x64**。
更新结果为本次 **Netcatty C1 0.0.0-c1.20261005.2** 预览版，包含方案 C 和该源码基线相对于 1.1.83 的其他变化，不是只向 1.1.83 添加三个插件。

补丁复用原程序中的相同字节，下载量约 15 MB。它不下载模型，不改全局 Agent 安装，不导入原正式版配置。
原程序文件会备份到安装目录内的 `.netcatty-c1-1.1.83-backup`，直到回退成功才删除备份。

## 应用

1. 准备 Node.js 24，将本补丁 ZIP 解压到安装目录之外。保留约 1.5 GB 空闲空间供准备文件和备份。
2. 退出 Netcatty 的所有窗口及托盘进程。在补丁目录打开 PowerShell。
3. 先检查，再应用。下面是通常的安装位置；如果安装到了其他目录，替换为实际包含 `Netcatty.exe` 的文件夹。

```powershell
node .\windows-patch.cjs "$env:LOCALAPPDATA\Programs\Netcatty" check
node .\windows-patch.cjs "$env:LOCALAPPDATA\Programs\Netcatty" apply
```

`check` 只检查。所有基准程序文件必须匹配官方版本，补丁才会应用；不匹配时没有“强制覆盖”选项。
如果安装在 Program Files，需要在有该目录写权限的 PowerShell 中运行。
不要把补丁应用到 Portable.exe 的临时解压目录。原目录有 `data` 便携配置时，请用完整 C1 包在独立目录运行。

成功后仍通过原来的快捷方式或 `Netcatty.exe` 启动，进入的是 **Netcatty C1**。
C1 默认使用 `%APPDATA%\netcatty-c1`，原来的 `%APPDATA%\netcatty` 保留。首次看到空配置不代表主机、密钥或聊天被删除。
补丁保留原安装器的快捷方式和卸载器文件；它没有新增一条 C1 安装记录。

就地试用期间，SSH/Telnet 和右键菜单会按 C1 的独立设置处理。若希望正式版的启动方式和系统关联也完全独立，请使用 [完整 C1 共存包](https://github.com/haveanorder/repositoryofmimeng/releases/tag/netcatty-c1-20261005-r3)。

## 回退

退出 C1，包括托盘进程，回到补丁目录运行：

```powershell
node .\windows-patch.cjs "$env:LOCALAPPDATA\Programs\Netcatty" rollback
```

脚本核对备份并恢复原程序文件。再次打开后回到 1.1.83 及其原有配置。
如果协议或右键关联尚未恢复，可到正式版设置中重新开启。C1 试用期间保存的独立配置仍保留。
试用期间请保留补丁目录和程序备份；不要手工删备份，也不要先在原目录安装另一个版本再回退。

## 三个 Agent

本补丁与完整 C1 包使用相同的驱动，已验证 OMP **18.6.1**、Pi **1.0.2**、DSH **CLI 0.2.1-alpha.1**。
用户已有 OMP 18.5.1、Pi 1.0.3、DSH Desktop 0.2.0-rc.2 均可保留；本补丁没有将这些版本标记为兼容，也不会修改它们。
已有 Desktop 不代表存在桥接所需 CLI。

独立安装和配置隔离见包内 `EXISTING-INSTALLATIONS.zh-CN.md`。
本补丁也附带同一份官方引擎安装脚本；需要已验证 CLI 时，在补丁目录运行：

```powershell
node .\scripts\install-native-agents.cjs "$env:USERPROFILE\.netcatty-native"
```

此步骤需要访问官方 GitHub Release 和 npm。它不改全局 npm 或 PATH；随后按共存说明为三种引擎设置独立的配置目录，并在 C1 设置中填写脚本输出的路径。

## 验证与文件

- 以官方 1.1.83 Windows 程序为输入，在 Linux / Node.js 24 中实际执行检查、应用和回退。
- 更新后全部 997 个目标文件与 C1 的 Windows 构建逐一匹配，回退后 1144 个原文件逐一匹配。
- 官方 1.1.83 安装程序内的 1144 个基准文件与 ZIP 版一致；安装程序另带的 `resources/elevate.exe` 保留。
- 清单外的附加文件保留；被修改的基准程序文件会在写入前被拒绝。
- 构建资源与归档验证不能代替 Windows 实机验证。本预览未签名，尚未实际验证 Windows 安装、权限提升、运行中进程检查和桌面启动。

`manifest.json` 记录原版本、完整文件哈希、变更路径及差分范围；`VALIDATION.json` 和 `SHA256SUMS.txt` 提供验证结果与校验值。
回退范围是程序文件；补丁不操作模型服务、远程主机或 Agent 会话。

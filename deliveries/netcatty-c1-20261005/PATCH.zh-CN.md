# Netcatty C1 独立源码补丁包

此包用于 Netcatty **源码仓库**，不直接覆盖已经安装的 Netcatty.exe 或 app.asar。
它包含方案 C 完整改动、检查/应用/回退脚本及校验值，不需要下载约 480 MiB 的完整 Windows 交付包。

基线：haveanorder/Netcatty 的 `de6d1a28ba577358d4bb03ae78ba32f9b87050c0`。
内容：OMP 原生 RPC、Pi RPC 与受控扩展、DSH 专用桥接、设置与交互界面、中英繁体翻译，以及 C1 共存修订。
补丁不包含依赖、编译好的程序或 Agent CLI。

## 应用和回退

准备 Git 和 Node.js 24。在解压后的补丁目录打开 PowerShell：

```powershell
node .\apply-patch.cjs "D:\Code\Netcatty" check
node .\apply-patch.cjs "D:\Code\Netcatty" apply
```

将路径换成准确基线的源码仓库根目录。`check` 只检查，`apply` 先检查再写入。
脚本不会切换分支、重置修改或自动安装依赖；冲突或基线不同会停止。
不要将路径指向 Program Files 中的已安装程序，也不要对现有工作使用 `git reset --hard`。

如果没有基线源码，可以在一个新目录准备：

```powershell
git clone https://github.com/haveanorder/Netcatty.git Netcatty-C1-Source
git -C Netcatty-C1-Source checkout --detach de6d1a28ba577358d4bb03ae78ba32f9b87050c0
node .\apply-patch.cjs ".\Netcatty-C1-Source" apply
```

回退未继续改动的补丁：

```powershell
node .\apply-patch.cjs "D:\Code\Netcatty" revert
```

回退也会先做反向检查；若后来修改了相关代码并产生冲突，请先自行保存改动。
回退只改变源码，不卸载程序，不删除聊天、主机或 Agent 配置。

## 编译和已有 Agent

应用成功后，源码中的 `docs/native-agents-c.zh-CN.md` 包含启动与构建说明。
开发运行使用 `npm install`、`npm run build`、`npm start`。
Windows 本机编译还需 MSVC C++ 工具链，再运行 `npm run pack:win-x64`。
这个标准打包命令沿用正式版应用标识；希望与正式版并存时，优先使用本次已构建的 **Netcatty C1 共存预览包**。
`scripts/windows-cross.config.cjs` 用于云端已准备的交叉编译环境，不是可直接用于任意 Windows 电脑的构建配置。

当前验证的引擎为 OMP 18.6.1、Pi 1.0.2、DSH CLI 0.2.1-alpha.1。
用户现有 OMP 18.5.1、Pi 1.0.3、DSH Desktop 0.2.0-rc.2 可以保留；本补丁没有将它们标记为已兼容。
需要已验证 CLI 时，在源码中运行独立安装脚本，并按共存说明设置独立的 Agent 配置目录。

- [完整 Windows 交付与说明](https://github.com/haveanorder/repositoryofmimeng/tree/main/deliveries/netcatty-c1-20261005)
- [已有安装与配置隔离](https://github.com/haveanorder/repositoryofmimeng/blob/main/deliveries/netcatty-c1-20261005/EXISTING-INSTALLATIONS.zh-CN.md)

## 验证范围

补丁已在独立 Git 索引上从准确基线应用，所得文件逐一与交付源码核对，再反向还原到完全相同的基线树；不改动当前工作目录。
脚本完成 Node.js 语法检查，ZIP 完整性和 SHA256 已核验。Windows CMD 启动器尚未在 Windows 真机运行。
如需更新已安装的官方 Netcatty 1.1.83 Windows x64，请使用另行提供的 Windows 程序补丁；这份源码补丁不能直接用于安装目录。

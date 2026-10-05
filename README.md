# repositoryofmimeng
The first repository of mimeng

## Netcatty 方案 C（2026-10-05）

**[下载完整交付 ZIP（含 Windows 程序）](https://github.com/haveanorder/repositoryofmimeng/archive/refs/tags/netcatty-c1-20261005-r3.zip)** · [安装与合并步骤](deliveries/netcatty-c1-20261005/README.zh-CN.md) · [Release 页面](https://github.com/haveanorder/repositoryofmimeng/releases/tag/netcatty-c1-20261005-r3)

下载后先解压，进入 `deliveries/netcatty-c1-20261005/package`，双击 `Merge-Netcatty.cmd` 还原并校验完整交付包，再从其中的 `C1` 目录运行 Windows 安装程序。

OMP 原生 RPC、Pi RPC／受控扩展、DeepSeek Harness 专用桥接；支持英／简中／繁中。Windows x64 为未签名预览版。D 版文件尚未取得，未包含在此交付中。

另提供 **[独立源码补丁包（约 65 KiB）](https://github.com/haveanorder/repositoryofmimeng/raw/refs/heads/main/deliveries/netcatty-c1-20261005/Netcatty-C1-Source-Patch-20261005.zip)**，含检查、应用和回退脚本；[使用说明](deliveries/netcatty-c1-20261005/PATCH.zh-CN.md)。它用于准确基线的源码，不直接覆盖已安装的 Windows 程序。

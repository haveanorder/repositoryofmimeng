# Netcatty 1.1.83 · C1 Windows x64 功能补丁

在官方 1.1.83 上接入已有 **OMP 18.5.1 / Pi 1.0.3 / DSH CLI 0.2.0-rc.2**。保持原 Netcatty.exe、启动入口、应用身份和用户数据目录，提供设置页自配置与真实原生 Agent/MCP 链路。

**[下载发布资产](https://github.com/haveanorder/repositoryofmimeng/releases/tag/netcatty-c1-1183-20261007)**。普通用户下载 `Netcatty-1.1.83-C1-Windows-x64-Patch.zip`，解压后双击 `Patch-Netcatty.cmd`；无需为打补丁安装 Node 或开发工具。

- [应用、配置三个 Agent、回滚及短验收](START.zh-CN.md)
- [实际验证与剩余限制](VALIDATION.zh-CN.md)
- [基准、实现与源码复现](TECHNICAL.zh-CN.md)
- [补丁清单与原始/目标资源哈希](manifest.json)
- [验证日志](validation/) · [Windows 成功验收作业](https://github.com/haveanorder/repositoryofmimeng/actions/runs/37603159259)

本目录另提供完整 1.1.83 补丁源码 ZIP、相对于官方源码的 Changes.patch 和 SHA256SUMS.txt。旧 C1 交付、旧标签与其他项目文件保留。

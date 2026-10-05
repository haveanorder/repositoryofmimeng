# 已有 Netcatty 与 Agent 的使用方式

保留现有正式版及全局 Agent，不需要先卸载或降级。本次 C1 是增加方案 C 接入的独立预览版，已有正式版不会因为下载源码就自动获得这些功能。

共存修订版本：0.0.0-c1.20261005.2。使用独立应用包名 netcatty-c1，默认数据目录为 %APPDATA%\netcatty-c1；安装时不注册正式版的右键菜单与 URL 协议，新配置默认不接管 SSH/Telnet。不会自动复制正式版主机与聊天配置。

先在 PowerShell 核对 omp --version、pi --version、dsh --version，以及 Netcatty 关于页面中的版本。OMP 18.6.1、Pi 1.0.2、DSH 0.2.1-alpha.1 可直接在 C1 设置里填写现有 CLI 路径。其他版本需实际核对协议后再支持，不能默认“最新版”兼容。

如需独立安装已验证版本，可从源码目录运行 node scripts/install-native-agents.cjs "$env:USERPROFILE\.netcatty-native"，它使用独立目录，不改全局 npm 安装和 PATH。不要先执行 npm install -g 降级现有 Agent。

旧首发包只有独立应用显示名与安装标识，不足以保证默认 Electron 数据目录隔离。建议使用修订版；若暂用旧便携版，放入独立文件夹，并在启动前于旁边新建 data 目录。

本次仅做相关 deepLink/portableData 测试、修改文件 lint、真实 Electron 数据目录探针、Windows 重新打包与资源/归档核验。未声称已完成真实 Windows 桌面测试。

## 本次报告的已有版本

| 已有软件 | C1 当前处理方式 |
|---|---|
| OMP 18.5.1 | 保留；C1 已验证版本是 18.6.1，可独立安装供 C1 使用。 |
| Pi 1.0.3 | 保留；C1 当前仍验证 1.0.2，不直接放宽协议版本检查。 |
| DSH Desktop 0.2.0-rc.2 | 保留桌面版；此版本号不能确认可用的 CLI。C1 需要独立的 @deepseek-ai/dsh 0.2.1-alpha.1 CLI。 |

在正式适配前，不将这些版本标记为已经兼容。已安装的 Netcatty 正式版不会自动获得本次 C1 代码；C1 可并列试用。

## 同时隔离 Agent 的配置和会话

独立安装目录只隔离程序文件，不会自动隔离 Agent 默认的配置和会话目录。使用不同版本并行试用时，在 C1 各 Agent 卡片的“高级 → 环境变量（JSON）”中设置下面的独立目录；把 `<你的用户名>` 换成真实 Windows 用户目录名。不要将 `%USERPROFILE%` 字面量放进 JSON，子进程环境不会自动展开它。

OMP：
```json
{"PI_CONFIG_DIR":".netcatty-c1-omp","PI_CODING_AGENT_DIR":"C:/Users/<你的用户名>/.netcatty-native/profiles/omp"}
```

Pi：
```json
{"PI_CODING_AGENT_DIR":"C:/Users/<你的用户名>/.netcatty-native/profiles/pi"}
```

DSH CLI：
```json
{"DSH_HOME":"C:/Users/<你的用户名>/.netcatty-native/profiles/dsh"}
```

独立目录初次没有原有登录、模型和会话配置，这是预期行为；在 C1 中填写所需模型及密钥，或在这个独立 profile 中完成登录。无需搬动现有 Agent 的配置目录。

对于本次已有安装，请使用源码中的独立安装脚本；不要执行设置卡片里可见的全局 `npm install -g` 示例，以免改变原全局版本。

## Netcatty 本体版本补充

用户已确认现有 Netcatty 为 1.1.83。可保留正式版并独立运行完整 C1 包，也可使用单独的 Windows 1.1.83 程序补丁，将原程序文件备份后更新为 C1。两种方式均默认使用独立 C1 配置；源码补丁适用于 de6d1a2 源码基线。详见 WINDOWS-PATCH-1.1.83.zh-CN.md。

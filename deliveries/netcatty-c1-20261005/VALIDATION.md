# 验证记录（2026-10-05）

- 真实官方引擎：OMP 18.6.1、Pi 1.0.2、DSH 0.2.1-alpha.1。
- 模型服务：明确标注的本地可控 HTTP 服务；未使用真实云模型凭据。
- CLI：收发、中文流、真实本机工具审批与拒绝、原生恢复、停止通过；OMP 子任务取消、Pi 扩展问答、DSH 问题/计划/任务/延迟答复通过。
- Electron：三种引擎均通过真实 MCP 与本地 PTY 流程；只向聊天授权的 A 暴露工具范围，B 不暴露；等待审批时停止后，迟到批准不会执行。
- 前端：实际中文窗口检查保存 DSH，恢复中断会话、显示配置模型、进入计划模式、审核批准并继续回答；截图随包附带。77 个新增翻译键在 en、zh-CN、zh-TW 中一致。
- 退出：真实等待模型的 DSH 会话随应用退出回收；沿用既有退出保护与 stopAgentTurn。
- 回归：112 项原有针对性检查通过；另通过原生帧解析、5 项退出保护及 Windows npm shim 的 Pi 隐藏 manifest 回归。没有跑全量一万多项测试。
- lint：0 错误，8 项基线警告；新增 Windows shim 文件 lint 通过。
- 前端生产构建、Linux pack:dir 和最终资源重打包通过。全仓库 tsc 仍有基线错误；新增原生文件无报告错误。
- Windows：x64 应用、Windows Hello、ConPTY 补丁与进程树模块 PE 校验通过。最终 Windows 和 Linux 包中的 main、CLI 定位、DSH 驱动、桥接与源文件一致。
- NSIS 安装程序、便携程序：7-Zip 完整性检查通过；Windows ZIP 和源码 ZIP 的 CRC 检查通过。
- 补丁：相对基线 de6d1a28ba577358d4bb03ae78ba32f9b87050c0 生成，反向检查与当前源码一致。

尚未验证：真实 Windows/macOS 桌面、真实云模型、SSH/SFTP 服务端、Windows Hello 生物认证和跨版本引擎升级。Windows 构建未签名。

所有构建均未推送、合并或发布 GitHub release。

## 共存修订版 0.0.0-c1.20261005.1

- 修正 Electron 包名为 netcatty-c1；实际 Electron 探针确认默认数据目录与 netcatty 不同，Windows 包内元数据与源码一致。
- 预览安装不注册正式版 Explorer 菜单和 URL 协议；新配置默认不接管 SSH/Telnet，显式保存的开关仍优先。
- 原有 deepLink 与 portableData 两个相关测试文件通过；修改文件 lint 无错误。
- Windows 三种产物重新生成，ZIP CRC 和已修改主进程文件一致性检查通过。
- 仍未在真实 Windows 桌面验证；Agent 最新版兼容性需先取得用户版本号，保留已验证版本约束。

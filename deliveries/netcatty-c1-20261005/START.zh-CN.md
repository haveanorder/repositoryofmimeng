# 方案 C：启动与交付说明

基于 `/workspace/Netcatty` 的 `de6d1a28ba577358d4bb03ae78ba32f9b87050c0` 实现。
本次只实现方案 C，不包含其他聊天的 ACP 方案 D，也不依赖 Netcatty 内部预览插件平台。

## 启动

1. **已经安装 Agent 时，先复用现有 CLI。** 运行 `omp --version`、`pi --version`、`dsh --version` 核对下表版本；匹配时直接进入下一步，在设置中填写现有 CLI 路径，无需重复安装。版本更高不代表与本预览桥接兼容，不要降级或覆盖全局安装。

   只有需要另装已验证版本时，安装 Node.js 24，解压源码包，在其目录运行：

   ```powershell
   node scripts/install-native-agents.cjs "$env:USERPROFILE\.netcatty-native"
   ```

   安装脚本将引擎放入独立目录，不执行全局 npm 安装，也不改 PATH。它下载 OMP 官方独立程序并核验 SHA256，同时安装指定版本的 Pi 和 DSH。
   完成后会输出三个 CLI 路径，并保存到安装目录的 `engines.json`。
   引擎单独安装，不包含在 Netcatty 安装包内。

2. 启动 Windows 安装版或便携版。在 **设置 → AI → Agent** 中填写 CLI 路径、
   本机工作目录和 `provider/model`。沿用 CLI 已有登录配置，或填写密钥。
   DSH 默认模型为 `deepseek-official/deepseek-flash`。
3. 选择工具范围并点击 **检查 CLI 并保存**。
4. 打开已连接终端的 AI 侧栏，选择 Oh My Pi、Pi 或 DeepSeek Harness，即可聊天。

源码开发启动：`npm install`、`npm run build`、`npm start`。
已有云环境使用 `/workspace/.netcatty-setup/env.sh`，无需重新安装依赖。

| 引擎 | 本次实际版本 | 接入方式 |
| --- | --- | --- |
| Oh My Pi | 18.6.1 | 原生 RPC UI、独立程序内置原生组件 |
| Pi | 1.0.2 | 原生 RPC、受控扩展与官方 MCP 扩展 |
| DeepSeek Harness | 0.2.1-alpha.1 | 专用 `netcatty-c1` profile、内部服务薄桥接 |

设计快照中的 OMP 18.6.2 发行包不可获得，因此使用实际可运行的官方相邻版本 18.6.1；
驱动按该版本源码协议实现。版本不匹配时会明确报错。

## 功能与界面

- 三者均接入现有聊天、工具事件、用量、MCP 范围与审批、停止和原生会话恢复。
- OMP 提供子 Agent 状态、记录读取、发消息和单任务停止。
- Pi 提供输入、选择、确认、编辑器及文本状态组件；可用 `/netcatty-check` 检查扩展交互。
- DSH 提供普通及延迟提问、计划模式与计划审核、待办记录、后台任务输出和停止。
- 新增设置和交互文案支持英文、简体中文、繁体中文；其他语言回退英文。
  模型生成的正文和问题保留原文。
- 设置中可清除已保存的 API 密钥；侧栏显示配置的模型；退出应用时等待原生进程清理。

**工具范围：** 本机工具操作运行 Agent 的机器，不会因选择 SSH 主机而自动改为远程执行。
默认只开放 Netcatty 已连接终端工具。本机工具需单独开启并逐次审批；远程 Auto 不会
自动授权本机工具。计划批准和普通问题回答不会产生工具执行授权。

## Windows 交付

本次预览版本为 `0.0.0-c1.20261005.1`，应用名称 **Netcatty C1**，提供 x64 安装程序、
便携程序与解压运行 ZIP。使用独立应用标识与包名 `netcatty-c1`，默认用户数据目录为 `%APPDATA%\netcatty-c1`；不自动导入正式版配置，不注册安装右键菜单，首次启动不接管 SSH/Telnet 协议。未进行代码签名，已交付至用户指定 GitHub 仓库。

Windows Hello、ConPTY 补丁和进程树模块从源码交叉编译；其他平台依赖使用官方发行资源。
完整工具版本和复现方法见 [英文技术记录](native-agents-c.md#windows-cross-build-notes)。
Windows 本机源码构建仍使用 `npm run pack:win-x64`，需现有 MSVC 构建工具。

如需使用旧的首发便携版，请将它放在独立文件夹，启动前在旁边新建 `data` 文件夹，以启用已有便携数据目录支持。不要用首发安装版覆盖日常配置；推荐使用修订版。

## 验证与限制

已使用**真实官方 CLI + 明确标注的本地可控模型服务**验证三种引擎的收发、审批、停止、
恢复及专属交互。实际 Linux Electron 与本地 PTY 测试覆盖了会话 A/B 范围、拒绝与批准、
等待审批时停止、迟到的批准不执行。中文界面完成了检查保存、恢复聊天和计划审核。

生产构建、lint、Linux 打包通过；112 项有针对性的原有回归检查通过，另检查了原生帧解析、
退出保护和翻译键一致性。未重新运行完整的一万多项基线测试。全仓库 TypeScript 检查仍有
基线错误；新增原生文件没有报告类型错误。

尚未验证真实云模型、真实 SSH/SFTP 服务端以及 Windows/macOS 桌面实际运行。
Windows 编译与资源检查通过不等于 Windows Hello、ConPTY、安装卸载和三种 CLI 已在真机验证。
原生模型目录选择器、会话分支浏览、任意 TUI 自定义组件和附件消息尚未实现。
OMP 无界面子 Agent 的本机工具确认请求会被拒绝。
延迟问题后的回复保存在 DSH 原生日志及当前实时面板，尚未复制到 Netcatty 持久聊天正文。

## 保存到 ChatGPT 项目

源码、补丁、构建产物和校验清单保存在当前云工作区的 `/workspace/deliverables/netcatty-c1/`。
本会话的工具没有直接写入 ChatGPT 项目文件区的接口，不能声称已经上传。
下载后可通过项目的“添加文件”导入本说明与源码；较大的 Windows 安装程序可能受项目文件类型或大小限制。

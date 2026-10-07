# 实现与源码

基准：`binaricat/Netcatty` 的 v1.1.83 标签指向源码提交 `d7a0c8ed8d238dcf1c82d786da53037a1f1496b1`。官方 Windows x64 ZIP 为 `Netcatty-1.1.83-win-x64.zip`，ProductVersion 为 1.1.83.0，Electron 为 42.3.3。完整来源和原始/目标哈希记录在 manifest.json。

恢复来源：旧 C1 的 Source.zip、Changes.patch、Work-Records 和交付记录。仅移植 Agent 驱动、设置、侧栏交互、MCP/会话/停止接入；没有用旧预览的较新源码替换官方基线。官方 appId `com.netcatty.app`、应用名称、Deep Link 默认设置与正常用户数据路径保留。只将源码的开发版本占位值 0.0.0 标记为构建版本 1.1.83，并添加独立的补丁标识。

## 实际版本接口

| Agent | 首要版本 | 实际接入 |
|---|---|---|
| OMP | 18.5.1 | `--mode rpc-ui`，协商 RPC v2；复用 chunk 解码、host tools、交互与会话文件 |
| Pi | 1.0.3 | `--mode rpc`，JSONL；受控扩展及内置 `builtin:mcp` |
| DSH CLI | 0.2.0-rc.2 | 既有 `sdk` profile + 临时 `--patch`；随补丁提供的 Cordis bridge 连接真实 DSH Agent、持久化、提问与模型服务 |

OMP/Pi 不自动加载第三方扩展，用户可以在设置中明确加入信任的扩展。DSH 不建立另一套 Agent 服务或网关，不写入固定示例 Provider；桥接插件从真正的 DSH npm 包解析依赖，兼容 Windows 全局 npm 布局。Windows exe/cmd/bat 入口保留自身运行时启动方式，版本探测和 RPC 使用同一准备后的启动参数。额外启动参数保存在当前 Agent 配置中，不替换 CLI 认证文件。

三个 Agent 使用既有外部 SDK 注册表、AgentRuntime、消息/工具事件、按聊天范围注入的 Netcatty MCP、审批桥和 stopAgentTurn。原生 session id 作为可恢复的外部会话身份保存；改变工作目录或引擎后需要新聊天。设置检查会真实启动 RPC，模型测试会通过 CLI 发起一次请求。模型留空时继承 CLI 选择，DSH 继承 `agentDefaultModel.currentSelection()`。

新增字段位于既有 ExternalAgentConfig 的 nativeOptions 中；既有存储键与其他 Agent 记录保持可读。不需要清空配置或运行独立数据迁移。API 密钥复用 secureFieldAdapter/Windows safeStorage；敏感环境字段加密保存，诊断中屏蔽已知环境密钥值。

## Windows 资源覆盖

应用资源基于官方发布包重新打包，renderer 来自 v1.1.83 上的生产构建；其余 Windows 运行时、依赖和原生模块来自官方发布包。构建脚本逐一比较官方 unpacked 文件，1114 个原有文件保持原内容并复用，只有 sdkSessionIdentity.cjs 需要覆盖，另增加受控扩展和 DSH 桥。

覆盖清单共 4 个文件：app.asar、sdkSessionIdentity.cjs、controlled.mjs 和 bridge.mjs。Netcatty.exe 不进入 payload。Windows 自带 PowerShell 5 入口完成目录识别/选择、版本与架构检查、资源哈希、原文件备份、应用与回滚。中文脚本在 ZIP 中带 UTF-8 BOM；CMD 使用相对目录引用，安装或解压路径可含空格。运行中的 Netcatty 会阻止应用和回滚。

## 复现

普通用户只需要补丁 ZIP，按 START.zh-CN.md 操作。开发者可下载完整源码 ZIP，或者在官方 v1.1.83 源码上应用 Changes.patch。使用 Node 24，执行 `npm ci`、`npm run lint`、`npm run build`；Linux 打包检查执行 `npm run pack:dir`。

要复现相同 Windows 资源补丁，下载官方 Windows ZIP并解压，在源码根目录执行：

```text
node scripts/build-1183-patch.mjs <官方Windows目录> <输出目录>
```

该脚本保留官方 unpacked 布局并检查依赖未变。输出 payload 与 manifest；安装脚本为 scripts/windows-1183-patch.ps1。GitHub 的 `netcatty-c1-1183-patch-verification.yml` 使用交付的源码与补丁 ZIP，在隔离 Windows 实例上运行验收。旧交付和旧标签均保留。

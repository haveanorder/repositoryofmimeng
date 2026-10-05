# Native agents (scheme C)

[中文启动与交付说明](native-agents-c.zh-CN.md)

Implemented against Netcatty `de6d1a28ba577358d4bb03ae78ba32f9b87050c0`.
This integration uses the existing AgentRuntime, MCP capability catalog,
approval UI and `stopAgentTurn()`. It does not use ACP or Netcatty's preview
plugin host.

## Install and start

Use Node 24 (Pi requires at least Node 22.19). From the repository:

```sh
node scripts/install-native-agents.cjs /absolute/path/to/native-engines
npm run build
npm start
```

The installer downloads OMP's official standalone binary, verifies its official
SHA256SUMS, and installs the two pinned npm CLIs under `runtime/`. It prints the
executable paths and saves `engines.json`. Engines remain outside the application
bundle. No Bun install or separate OMP native-addon build is needed with the
standalone release.

| Engine | Verified version | Official resource |
| --- | --- | --- |
| Oh My Pi | **18.6.1** | [Standalone release](https://github.com/can1357/oh-my-pi/releases/tag/v18.6.1) |
| Pi | **1.0.2** | `@earendil-works/pi-coding-agent@1.0.2` |
| DeepSeek Harness | **0.2.1-alpha.1** | `@deepseek-ai/dsh@0.2.1-alpha.1` |

OMP 18.6.2 from the design snapshot was unavailable from npm/releases during this
implementation. The adjacent official 18.6.1 standalone release actually runs
with its native components. Its own RPC source/docs were checked and used.
Both the settings check and process launcher reject unverified engine versions.

1. Open **Settings > AI > Agents**, locate the engine and enter its executable
   path and an absolute local working directory.
2. Set `provider/model`, or leave it empty to use the CLI default. DSH defaults
   to `deepseek-official/deepseek-flash`. Existing engine credentials/configuration
   are inherited. The optional API key field uses Netcatty's encrypted field
   storage; the separate environment JSON is ordinary agent configuration.
3. Choose **Netcatty connected terminals only**, or explicitly enable local workspace
   tools with approval. Click **Check CLI and save**.
4. Open a terminal's AI Chat side panel and select the saved agent. Native
   integrations always inject scoped Netcatty MCP, including when the global
   tool preference is Skills. Other agent integrations retain their own mode.

This cloud checkout already has working resources:

```sh
cd /workspace/Netcatty
source /workspace/.netcatty-setup/env.sh
# Existing executable paths:
# /workspace/.netcatty-native/bin/omp
# /workspace/.netcatty-native/runtime/node_modules/.bin/pi
# /workspace/.netcatty-native/runtime/node_modules/.bin/dsh
DISPLAY=:99 NETCATTY_NO_SANDBOX=1 npm start
```

The last command assumes the cloud's Xvfb display :99 is running; it is only a
container desktop launch setting. The saved environment and dependencies are
reused. CLI processes and display servers may need restarting after a snapshot.

## Implemented behavior

- One native process per active chat, text/thinking/tool/usage events in the
  existing transcript, and a persistent per-chat channel for questions, widgets
  and tasks. Configuration changes restart the process through native resume.
- OMP uses `rpc-ui`, its v2 chunk decoder, host tools forwarded to actual
  Netcatty MCP, dynamic MCP tool-list refresh, `session_settled`, subagent
  progress, output reading, steering and individual cancellation.
- Pi uses RPC plus a controlled extension and explicit official `builtin:mcp`.
  User extension discovery is disabled; additional trusted paths are opt-in.
  Input/select/confirm/editor questions and text widgets/status are rendered.
  `/netcatty-check` exercises an extension input dialog and widget.
- DSH starts its dedicated `netcatty-c1` profile from official `sdk`, replacing
  the SDK wire server with `packages/netcatty-dsh-bridge/bridge.mjs`. The plugin
  calls native Agents, Jobs, UserQuestions, PlanMode and approval services. The
  engine retains ownership of the loop, persistence and model requests.
- DSH supports streamed text, ordinary and timed questions, late answers,
  enter/leave plan mode, plan review, todo events and background job
  status/output/cancellation. Jobs and agent inboxes are included when settling.
  Bridge completion identifies its turn so a late event cannot finish a newer
  message. Follow-up text after a timed question appears in the native panel.
- Stop all goes through `stopAgentTurn()`, cancels scoped Netcatty executions
  and approvals, clears native input/work, and closes the owned process tree.
  The next message resumes the saved native session. Restoring a conversation
  does not restart previously running shell/remote tasks.
- Resume identities bind engine, verified version, workspace and native ID.
  A version/workspace change requires a new chat; native logs are not rewritten.
- Native settings and controls use the existing i18n system: English, Simplified
  Chinese and Traditional Chinese (77 new keys). Other locales use English
  fallback. Engine-generated questions/output remain in their original language.
- The settings card can remove its encrypted API key without touching CLI
  credentials. Chat shows the configured model. Plan review has explicit choices,
  plan mode reflects native committed/pending state, and task output is readable
  text. DSH todo updates reuse the existing persisted plan-activity component.
- App quit awaits native process shutdown inside the existing dirty-editor and
  plugin shutdown guard. No separate quit interception was added.

Local engine tools run on the machine running Netcatty. A selected SSH terminal
does not relocate them. Local tool approval is separate from MCP approval;
remote Auto never grants local access, and Observer blocks local tools. Native
question/plan answers do not create execution grants. OMP/Pi extension hooks are
not an OS sandbox; explicitly added extension code has the CLI's own permissions.
OMP's headless subagents cannot display local confirmation dialogs and their
local tool requests are denied. Netcatty tools still use the existing MCP scope
and permission checks.

## Validation and remaining limits

Validation uses **real official CLI processes** with an explicitly local,
deterministic HTTP model service (`scripts/native-model-service.cjs`). No cloud
model claim is made. The local service is test code, not an application gateway.

```sh
NETCATTY_NATIVE_RUNTIME=/path/to/native-engines node scripts/native-agents.live.cjs
# Start an isolated Electron instance with --remote-debugging-port=9222 first:
NETCATTY_NATIVE_RUNTIME=/path/to/native-engines node scripts/native-agents.electron.live.cjs
```

`NATIVE_ENGINES=dsh,pi,omp` can limit either script. The CLI smoke covers streaming,
native history after process restart, real local tool execution, approve/deny,
extension dialogs, DSH plan/jobs/timed follow-up, OMP subagent cancellation and
interrupting model output. The Electron smoke covers preload/main IPC, actual
Netcatty MCP, two local PTYs with only A in the chat scope, deny/approve and stop
while waiting for approval. Test artifacts stay under the supplied runtime
directory, outside application state.

Stage checkpoints (2026-10-05):

- Official engines installed and version-checked; DSH service bridge proven.
- All three CLI/MCP/local-PTY paths passed, including scoped targets and
  approvals. DSH/Pi/OMP dedicated interaction checks passed.
- Actual Electron settings saved DSH; the existing sidebar AgentRuntime sent
  messages, displayed tool events/questions, accepted an answer and stopped
  generation through Stop all.
- Chinese Electron settings checked/saved the actual CLI. The UI resumed an
  interrupted session, showed the configured model, entered plan mode, rendered
  the plan review and submitted approval. A real held-model session was cleaned
  up on app quit. Final packaged DSH MCP/approval/PTY checks passed again.
- Focused regression checks cover the registry, stream routing, Codex/Claude
  adapters, preload, identity and stop paths: 112 assertions/tests passed.
  Lint has zero errors and eight existing warnings. Production build passed.
  Full repository `tsc --noEmit` still reports baseline errors (including the
  pre-existing self-closing SettingsAnchor); new native files have no reported
  TypeScript errors. The full 10k+ test suite was intentionally not run.
- Final Linux `npm run pack:dir` passed; ASAR metadata and unpacked bridge/extension
  files were checked against source. Windows x64 binaries were cross-compiled
  and packaged as a separate `Netcatty C1` preview (see the Chinese guide below).

Remaining boundaries:

- No real cloud-model, SSH/SFTP-server, Windows or macOS desktop validation in
  this Linux container. The Windows package is unsigned. Cross-compilation and
  PE/resource checks do not replace testing installation, Windows Hello,
  ConPTY and the three CLI process trees on an actual Windows machine.
- Models are configured in the settings card/CLI; a live native model catalog,
  branch/fork browser and arbitrary TUI/custom-extension components are not
  included. This first version accepts text; attachments report a clear error.
- Native task/widget details are live panel state. Timed follow-up replies are
  retained by DSH's native log but are not copied into the saved Netcatty message
  transcript; reopening Netcatty does not restore that panel text.
- Fixed-version resume is verified. Engine upgrades/cross-version migration,
  headless OMP local-tool approval and arbitrary third-party extensions need
  separate implementation/validation before being advertised.

No GitHub push, merge or release publication is part of this work.

## Windows cross-build notes

Normal Windows source builds still use `npm run pack:win-x64` and the existing
MSVC setup. This cloud build keeps all Windows native files in a staging copy;
the checkout's Linux native modules remain usable.

Toolchain: LLVM/LLD 19.1.7, xwin 0.10.0, Microsoft Windows SDK 10.0.26100,
MSVC CRT 14.44.35220 from the xwin VS 17 manifest, Electron 42.3.3 `win-x64/node.lib`, and
Node 24.19 N-API headers. `scripts/build-native-win-cross.cjs` compiles the
Windows Hello helper, patched `conpty`, `conpty_console_list`, and
`windows_process_tree`. Addons include node-gyp's delay-load hook, which allows
Electron's renamed executable to supply the Node API. Static CRT linkage avoids
requiring a separate Visual C++ redistributable for these compiled components.

The staging copy also uses official SQLite 5.1.7 N-API v6 Windows binaries,
node-pty 1.1.0 WinPTY/ConPTY support files, SerialPort's Windows N-API prebuild,
Cursor SDK Windows 1.0.18, MoshCatty 0.1.8 and ET 6.2.10-1. Linux build directories
are removed from the staged node-pty, SerialPort and SQLite packages.

```sh
# Point these at the prepared official toolchain and headers:
export XWIN_ROOT=/path/to/xwin-sdk
export LLVM_ROOT=/path/to/llvm/bin
export NODE_HEADERS=/path/to/node-24/include/node
export ELECTRON_NODE_LIB=/path/to/electron-42.3.3-win-x64/node.lib
node scripts/build-native-win-cross.cjs /path/to/windows-native
# In the staging copy, after copying Windows payloads to their package locations:
npm_config_arch=x64 npx electron-builder --config scripts/windows-cross.config.cjs --win --x64 --publish=never
```

The cross config verifies PE architecture, disables redundant native rebuilding,
and checks the packaged patched ConPTY bytes. It uses electron-builder 26.15.2's
official `UninstallerReader` (also used by its macOS path) to extract the NSIS
generated uninstaller. This avoids running the bootstrap through Wine in this
cloud environment; the standard NSIS installer script is retained. This config
is for the unsigned preview build only.

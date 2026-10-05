# 工作区清理记录

清理前先校验 C1 全部交付文件的 SHA256，以及 Windows ZIP 中 997 个文件与解包目录的大小、CRC；额外的 NSIS elevate.exe 已单独保留。

| 已清理位置 | 占用 MiB |
|---|---:|
| `/workspace/.netcatty-setup/npm-cache/_cacache` | 1231.1 |
| `/workspace/.netcatty-setup/cache/electron-builder/wine@1.0.1` | 188.3 |
| `/workspace/.netcatty-native/windows/sysroot/usr/lib/x86_64-linux-gnu/wine` | 716.5 |
| `/workspace/.netcatty-native/windows/sysroot/usr/share/wine` | 11.2 |
| `/workspace/.netcatty-native/windows/stage/release` | 944.8 |
| `/workspace/.netcatty-setup/apt/cache/archives/*.deb` | 227.3 |

清理目标原占用合计：3.24 GiB。
文件系统可用空间：9.25 → 11.72 GiB。

保留：当前源码及 Git 修改、全部 C1 交付文件、官方引擎与源码、Linux 应用及依赖、Windows staging 源码与依赖、LLVM/xwin SDK 和已编译原生模块。

删除的是 npm/apt 下载缓存、未采用的 Wine 试验组件和已核对的重复 Windows 构建输出。再次构建可能重新下载缓存，Windows 输出可使用保留的 staging 与编译资源重建。

Google Drive 上传尚未完成；全部交付文件仍保留在本地。未删除另一台环境的 D 版文件，也没有访问其环境。

windows/unpacked-extra/resources/elevate.exe 是 NSIS 构建在 ZIP 生成后加入的官方辅助程序；作为构建记录保留，不是另一个安装入口。


## 补丁交付后的清理（2026-10-05）

已在完整包公开下载及补丁应用/回退验证之后，删除版本对比、安装器提取与补丁测试副本，以及哈希匹配的重复构建产物，共 2.58 GiB；另已删除公开下载验证副本约 0.94 GiB。这是本次补充阶段删除的可再生文件体积，不等同于整个会话的净空间收益。源码、完整交付、两个补丁、官方 1.1.83 原始 ZIP、引擎、SDK/编译器及 Windows 编译依赖保留。

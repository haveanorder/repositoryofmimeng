# 完整交付包分卷

本目录包含完整 ZIP 的 20 个连续分卷，每卷最大 24 MiB，以符合 GitHub 普通文件大小限制。

Windows：先将仓库 ZIP 整个解压，进入本目录，双击 `Merge-Netcatty.cmd`。它按编号合并所有分卷并核对 SHA256。成功后再解压生成的 `Netcatty-C1-Delivery-With-Worklog-20261005.zip`，进入 `C1`，运行 Setup.exe 安装程序。

请不要单独解压某个 part 文件；保留全部 part 在同一个目录。脚本只合并文件和校验，不会自动运行安装程序。

Linux/macOS：在本目录执行 `cat Netcatty-C1-Delivery-With-Worklog-20261005.zip.part* > Netcatty-C1-Delivery-With-Worklog-20261005.zip`，再用 `sha256sum` 或 `shasum -a 256` 核对 `parts.json` 中的 archiveSha256。

原包 SHA256：`aabe9f4971464f38eb92e19adf7dda3e57d2137a7ff29210e386e0b44eb1cce5`。

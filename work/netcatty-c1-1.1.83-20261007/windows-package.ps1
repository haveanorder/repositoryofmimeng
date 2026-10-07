$ErrorActionPreference='Stop'
$work=Join-Path $env:GITHUB_WORKSPACE 'work/netcatty-c1-1.1.83-20261007'
Invoke-WebRequest https://github.com/binaricat/Netcatty/releases/download/v1.1.83/Netcatty-1.1.83-win-x64.zip -OutFile official.zip
Expand-Archive official.zip official
node "$work/assemble.mjs" app official patch-output
if ($LASTEXITCODE) { throw 'resource assembly failed' }
Copy-Item "$work/Patch.ps1","$work/START.zh-CN.md","$work/Source.patch" patch-output
foreach ($action in @('check','apply','rollback')) {
  "@echo off`r`npowershell.exe -NoProfile -ExecutionPolicy Bypass -File `"%~dp0Patch.ps1`" -Action $action %*`r`npause`r`n" | Set-Content "patch-output/$action.cmd" -Encoding ascii
}
# Apply only to a disposable copy of the official build, never to a user install.
Copy-Item official trial -Recurse
$manifest = Get-Content patch-output/manifest.json -Raw | ConvertFrom-Json -AsHashtable
$manifest.status='accepted'
$manifest | ConvertTo-Json -Depth 8 | Set-Content patch-output/manifest.json -Encoding utf8
& patch-output/Patch.ps1 -Action check -InstallDir trial
& patch-output/Patch.ps1 -Action apply -InstallDir trial
foreach ($file in $manifest.files) {
  if ((Get-FileHash (Join-Path trial $file.path) -Algorithm SHA256).Hash.ToLowerInvariant() -ne $file.after) { throw 'apply verification failed' }
}
& patch-output/Patch.ps1 -Action rollback -InstallDir trial
foreach ($file in $manifest.files) {
  $target=Join-Path trial $file.path
  if ($null -eq $file.before) { if (Test-Path $target) { throw 'new resource left after rollback' } }
  elseif ((Get-FileHash $target -Algorithm SHA256).Hash.ToLowerInvariant() -ne $file.before) { throw 'rollback verification failed' }
}
# Test the original official EXE with the new application resources.
Copy-Item patch-output/payload/resources/app.asar trial/resources/app.asar -Force
Copy-Item patch-output/payload/resources/app.asar.unpacked/* trial/resources/app.asar.unpacked -Recurse -Force
$profile=Join-Path $env:RUNNER_TEMP 'netcatty-c1-1183-acceptance-profile'
$process=Start-Process trial/Netcatty.exe -ArgumentList @('--disable-gpu','--remote-debugging-port=9222',"--user-data-dir=$profile") -PassThru -RedirectStandardOutput electron.out.log -RedirectStandardError electron.err.log
try {
  $ready=$false
  for ($attempt=0; $attempt -lt 60; $attempt++) {
    try { $pages=Invoke-RestMethod http://127.0.0.1:9222/json/list; if ($pages | Where-Object { $_.type -eq 'page' -and $_.url -like 'app://netcatty/*' }) { $ready=$true; break } } catch {}
    Start-Sleep -Milliseconds 500
  }
  if (-not $ready) { throw 'patched Netcatty did not start' }
  Push-Location app
  node scripts/native-agents.electron.live.cjs 2>&1 | Tee-Object -FilePath ../electron-mcp-acceptance.log
  if ($LASTEXITCODE) { throw 'Electron and MCP acceptance failed' }
  Pop-Location
} finally { Get-Process Netcatty -ErrorAction SilentlyContinue | Stop-Process -Force }
# Only a successful acceptance can produce an applicable package.
$manifest.validation=@{ platform='GitHub Actions Windows x64'; cliVersions=@{omp='18.5.1'; pi='1.0.3'; dsh='0.2.0-rc.2'}; modelService='local controlled service'; runUrl="https://github.com/$env:GITHUB_REPOSITORY/actions/runs/$env:GITHUB_RUN_ID" }
$manifest | ConvertTo-Json -Depth 8 | Set-Content patch-output/manifest.json -Encoding utf8
$readme=Get-Content patch-output/START.zh-CN.md -Raw -Encoding utf8
$readme=$readme -replace '本目录为开发与验收资源。只有全部验收完成后的 accepted 包可以应用，acceptance-pending 包会拒绝应用。不要把源码工作分支当作完成交付。', '此包已通过 GitHub Actions Windows x64 验收：三个目标 CLI 的真实收发、工具/MCP、交互、审批、停止、恢复，以及原版 EXE 加补丁资源启动、补丁应用与回滚。模型服务为本地可控服务，未使用或验证用户账户凭据。用户机器的原配置与实际账户仍需按末尾步骤确认。'
$readme += "`n`n本次 Windows 验收日志：https://github.com/$env:GITHUB_REPOSITORY/actions/runs/$env:GITHUB_RUN_ID`nDSH 默认在现有 sdk 配置上叠加 Netcatty 连接。使用自定义 SDK profile 时，可在设置中的环境变量 JSON 保存 NETCATTY_DSH_PROFILE；不修改该 profile 的配置文件。`n"
$readme | Set-Content patch-output/START.zh-CN.md -Encoding utf8
Copy-Item patch-output/Source.patch Netcatty-1.1.83-C1-Source.patch
Copy-Item patch-output/START.zh-CN.md START.zh-CN.md
Remove-Item patch-output/staging -Recurse -Force
Compress-Archive patch-output/* Netcatty-1.1.83-C1-Function-Patch-20261007.zip -CompressionLevel Optimal
Get-FileHash Netcatty-1.1.83-C1-Function-Patch-20261007.zip -Algorithm SHA256 | Format-List | Out-File SHA256SUMS.txt

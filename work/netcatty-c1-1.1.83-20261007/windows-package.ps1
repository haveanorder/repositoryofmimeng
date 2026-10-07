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
$manifest = Get-Content patch-output/manifest.json -Raw | ConvertFrom-Json
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
    try { Invoke-RestMethod http://127.0.0.1:9222/json/list | Out-Null; $ready=$true; break } catch { Start-Sleep -Milliseconds 500 }
  }
  if (-not $ready) { throw 'patched Netcatty did not start' }
  Push-Location app
  node scripts/native-agents.electron.live.cjs 2>&1 | Tee-Object -FilePath ../electron-mcp-acceptance.log
  if ($LASTEXITCODE) { throw 'Electron and MCP acceptance failed' }
  Pop-Location
} finally { Get-Process Netcatty -ErrorAction SilentlyContinue | Stop-Process -Force }
# Only a successful acceptance can produce an applicable package.
Remove-Item patch-output/staging -Recurse -Force
Compress-Archive patch-output/* Netcatty-1.1.83-C1-Function-Patch-20261007.zip -CompressionLevel Optimal
Get-FileHash Netcatty-1.1.83-C1-Function-Patch-20261007.zip -Algorithm SHA256 | Format-List | Out-File SHA256SUMS.txt

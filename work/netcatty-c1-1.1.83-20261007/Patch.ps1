param([ValidateSet('check','apply','rollback')][string]$Action='check', [string]$InstallDir)
$ErrorActionPreference='Stop'
if (-not $InstallDir) {
  $paths = @()
  foreach ($root in @('HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*')) {
    Get-ItemProperty $root -ErrorAction SilentlyContinue | Where-Object {$_.DisplayName -eq 'Netcatty'} | ForEach-Object {
      if ($_.InstallLocation) { $paths += $_.InstallLocation }
      if ($_.DisplayIcon) { $paths += Split-Path ($_.DisplayIcon.Trim('"') -replace ',\d+$','') }
    }
  }
  if ($env:LOCALAPPDATA) { $paths += Join-Path $env:LOCALAPPDATA 'Programs\Netcatty' }
  $InstallDir = $paths | Select-Object -Unique | Where-Object {Test-Path (Join-Path $_ 'Netcatty.exe')} | Select-Object -First 1
  if (-not $InstallDir) { $InstallDir = Read-Host 'Netcatty installation directory' }
}
$InstallDir = (Resolve-Path -LiteralPath $InstallDir).Path
$exe = Join-Path $InstallDir 'Netcatty.exe'
if (-not (Test-Path $exe)) { throw 'Netcatty.exe not found' }
if ((Get-Item $exe).VersionInfo.FileVersion -ne '1.1.83') { throw 'This patch requires Netcatty 1.1.83 Windows x64' }
$manifest = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot 'manifest.json') | ConvertFrom-Json
function HashOf([string]$file) { if (Test-Path -LiteralPath $file) { (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToLowerInvariant() } else { $null } }
$backupRoot = Join-Path $InstallDir 'Netcatty-C1-Backups'
if ($Action -eq 'rollback') {
  $backup = Get-ChildItem -LiteralPath $backupRoot -Directory | Sort-Object Name -Descending | Select-Object -First 1
  if (-not $backup) { throw 'No backup found' }
  $saved = Get-Content -Raw -LiteralPath (Join-Path $backup.FullName 'manifest.json') | ConvertFrom-Json
  if (Get-Process Netcatty -ErrorAction SilentlyContinue) { throw 'Close Netcatty before rollback' }
  foreach ($file in $saved.files) {
    if ((HashOf (Join-Path $InstallDir $file.path)) -ne $file.after) { throw ('File changed since patch: ' + $file.path) }
  }
  foreach ($file in $saved.files) {
    $target = Join-Path $InstallDir $file.path
    if ($null -eq $file.before) { Remove-Item -LiteralPath $target }
    else { Copy-Item -LiteralPath (Join-Path $backup.FullName $file.path) -Destination $target -Force }
  }
  Write-Host 'Rollback complete. Start Netcatty from your existing shortcut.'
  exit 0
}
foreach ($file in $manifest.files) {
  if ((HashOf (Join-Path $InstallDir $file.path)) -ne $file.before) { throw ('Installed resource differs from official 1.1.83: ' + $file.path) }
  if ((HashOf (Join-Path $PSScriptRoot ('payload\' + $file.path))) -ne $file.after) { throw ('Patch resource check failed: ' + $file.path) }
}
Write-Host ('Check passed: ' + $InstallDir)
if ($Action -eq 'check') { exit 0 }
if ($manifest.status -ne 'accepted') { throw 'Acceptance is incomplete. This working package is not released for application.' }
if (Get-Process Netcatty -ErrorAction SilentlyContinue) { throw 'Close Netcatty before applying the patch' }
$backup = Join-Path $backupRoot (Get-Date -Format 'yyyyMMdd-HHmmss')
New-Item -ItemType Directory -Path $backup | Out-Null
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'manifest.json') -Destination $backup
foreach ($file in $manifest.files) {
  if ($null -ne $file.before) {
    $saved = Join-Path $backup $file.path
    New-Item -ItemType Directory -Force -Path (Split-Path $saved) | Out-Null
    Copy-Item -LiteralPath (Join-Path $InstallDir $file.path) -Destination $saved
  }
}
try {
  foreach ($file in $manifest.files) {
    $target = Join-Path $InstallDir $file.path
    New-Item -ItemType Directory -Force -Path (Split-Path $target) | Out-Null
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot ('payload\' + $file.path)) -Destination $target -Force
  }
} catch {
  foreach ($file in $manifest.files) {
    $target = Join-Path $InstallDir $file.path
    if ($null -eq $file.before) { Remove-Item -LiteralPath $target -ErrorAction SilentlyContinue }
    else { Copy-Item -LiteralPath (Join-Path $backup $file.path) -Destination $target -Force }
  }
  throw
}
Write-Host 'Patch applied. Start Netcatty from your existing shortcut. User data is retained.'

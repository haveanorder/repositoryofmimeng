@echo off
setlocal
pushd "%~dp0"
if exist "Netcatty-C1-Delivery-With-Worklog-20261005.zip" (
  echo Output already exists. Rename or move it before assembling again.
  pause
  exit /b 1
)
copy /b "Netcatty-C1-Delivery-With-Worklog-20261005.zip.part01"+"Netcatty-C1-Delivery-With-Worklog-20261005.zip.part02"+"Netcatty-C1-Delivery-With-Worklog-20261005.zip.part03"+"Netcatty-C1-Delivery-With-Worklog-20261005.zip.part04"+"Netcatty-C1-Delivery-With-Worklog-20261005.zip.part05"+"Netcatty-C1-Delivery-With-Worklog-20261005.zip.part06"+"Netcatty-C1-Delivery-With-Worklog-20261005.zip.part07"+"Netcatty-C1-Delivery-With-Worklog-20261005.zip.part08"+"Netcatty-C1-Delivery-With-Worklog-20261005.zip.part09"+"Netcatty-C1-Delivery-With-Worklog-20261005.zip.part10"+"Netcatty-C1-Delivery-With-Worklog-20261005.zip.part11"+"Netcatty-C1-Delivery-With-Worklog-20261005.zip.part12"+"Netcatty-C1-Delivery-With-Worklog-20261005.zip.part13"+"Netcatty-C1-Delivery-With-Worklog-20261005.zip.part14"+"Netcatty-C1-Delivery-With-Worklog-20261005.zip.part15"+"Netcatty-C1-Delivery-With-Worklog-20261005.zip.part16"+"Netcatty-C1-Delivery-With-Worklog-20261005.zip.part17"+"Netcatty-C1-Delivery-With-Worklog-20261005.zip.part18"+"Netcatty-C1-Delivery-With-Worklog-20261005.zip.part19"+"Netcatty-C1-Delivery-With-Worklog-20261005.zip.part20" "Netcatty-C1-Delivery-With-Worklog-20261005.zip"
if errorlevel 1 goto failed
powershell -NoProfile -Command "if ((Get-FileHash -LiteralPath 'Netcatty-C1-Delivery-With-Worklog-20261005.zip' -Algorithm SHA256).Hash -ne '0cca164581a62c9c4183e592ff626b2cba40e32ce1165385139618511a4e5e4c') { Write-Error 'SHA256 mismatch'; exit 1 }"
if errorlevel 1 goto failed
echo Complete. SHA256 verified. Extract the resulting ZIP to find the installer and source.
popd
pause
exit /b 0
:failed
echo Assembly or checksum verification failed. Keep all part files together and download any missing files.
popd
pause
exit /b 1

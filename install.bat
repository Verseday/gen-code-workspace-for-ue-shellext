@echo off
chcp 65001 > nul

REM 移動先パスを設定
set DEST_DIR=C:\Program Files (x86)\Epic Games\Launcher\Engine\Binaries\Win64
set SCRIPT_NAME=GenerateCodeWorkspace.ps1
set DEST_PATH=%DEST_DIR%\%SCRIPT_NAME%

REM PowerShellでファイルを移動（上書き許可）
powershell -Command "Copy-Item -Path '%~dp0%SCRIPT_NAME%' -Destination '%DEST_DIR%' -Force"

REM レジストリ登録用のパスを設定
set SCRIPT=%DEST_PATH%
reg add "HKCR\Unreal.ProjectFile\shell\GenerateCodeWorkspace" /ve /d "Generate .code-workspace file" /f
reg add "HKCR\Unreal.ProjectFile\shell\GenerateCodeWorkspace\command" /ve /d "powershell -ExecutionPolicy Bypass -File \"%SCRIPT%\" \"%%1\"" /f
echo Context menu installed successfully.
pause

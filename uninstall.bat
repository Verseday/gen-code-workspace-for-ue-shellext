@echo off
chcp 65001 > nul
reg delete "HKCR\Unreal.ProjectFile\shell\GenerateCodeWorkspace" /f

REM インストール先のスクリプトを削除
set SCRIPT_PATH="C:\Program Files (x86)\Epic Games\Launcher\Engine\Binaries\Win64\GenerateCodeWorkspace.ps1"
powershell -Command "if (Test-Path %SCRIPT_PATH%) { Remove-Item %SCRIPT_PATH% -Force }"

echo Context menu uninstalled successfully.
pause

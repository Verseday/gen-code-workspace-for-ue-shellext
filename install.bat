@echo off
chcp 65001 > nul
set SCRIPT=%~dp0GenerateCodeWorkspace.ps1
reg add "HKCR\Unreal.ProjectFile\shell\GenerateCodeWorkspace" /ve /d "Generate .code-workspace file" /f
reg add "HKCR\Unreal.ProjectFile\shell\GenerateCodeWorkspace\command" /ve /d "powershell -ExecutionPolicy Bypass -File \"%SCRIPT%\" \"%%1\"" /f
echo Context menu installed successfully.
pause

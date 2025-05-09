@echo off
chcp 65001 > nul
reg delete "HKCR\Unreal.ProjectFile\shell\GenerateCodeWorkspace" /f
echo Context menu uninstalled successfully.
pause

param(
    [string]$uprojectPath
)

$unrealEngineRoot = "C:\\Program Files\\Epic Games\\UE_5.5"
$ubtPath = Join-Path $unrealEngineRoot "Engine\\Binaries\\DotNET\\UnrealBuildTool\\UnrealBuildTool.exe"
$uprojectDir = Split-Path -Parent $uprojectPath

# コマンド組み立て
$arguments = "-projectfiles -project=`"$uprojectPath`" -game -engine -vscode"

# UnrealBuildTool.exe をuprojectのディレクトリで実行
$process = Start-Process -FilePath $ubtPath -ArgumentList $arguments -WorkingDirectory $uprojectDir -NoNewWindow -Wait -PassThru

if ($process.ExitCode -eq 0) {
    Write-Host ".code-workspace file generated successfully."
} else {
    Write-Host "Failed to generate .code-workspace file. ExitCode: $($process.ExitCode)"
}
Write-Host "Command: $ubtPath $arguments"
Read-Host "Press Enter to close"

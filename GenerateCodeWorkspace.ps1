param(
    [string]$uprojectPath
)

# uprojectファイルからEngineAssociationを取得
$uprojectJson = Get-Content $uprojectPath | ConvertFrom-Json
$engineAssoc = $uprojectJson.EngineAssociation

# レジストリからインストール済みUnreal Engineの一覧を取得
$regBase = "Registry::HKEY_LOCAL_MACHINE\\SOFTWARE\\EpicGames\\Unreal Engine"
$engineKeys = Get-ChildItem -Path $regBase -ErrorAction SilentlyContinue

# EngineAssociation値とキー名の両方向で部分一致するものを探す
$found = $false
foreach ($key in $engineKeys) {
    if ($key.PSChildName -like "*$engineAssoc*" -or $engineAssoc -like "*$($key.PSChildName)*") {
        $installDir = (Get-ItemProperty -Path $key.PSPath).InstalledDirectory
        $found = $true
        break
    }
}

if (-not $found -or -not $installDir) {
    # レジストリで見つからなければ LauncherInstalled.dat を検索
    $launcherDat = 'C:\ProgramData\Epic\UnrealEngineLauncher\LauncherInstalled.dat'
    if (Test-Path $launcherDat) {
        $launcherJson = Get-Content $launcherDat | ConvertFrom-Json
        foreach ($installation in $launcherJson.InstallationList) {
            if ($installation.AppName -like "*$engineAssoc*" -or $engineAssoc -like "*$($installation.AppName)*") {
                $installDir = $installation.InstallLocation
                $found = $true
                break
            }
        }
    }
}

if (-not $found -or -not $installDir) {
    Write-Host "Unreal Engine install path not found for EngineAssociation: $engineAssoc"
    Write-Host "Registry keys found:"
    foreach ($key in $engineKeys) {
        Write-Host "  " $key.PSChildName
    }
    Write-Host "Also checked LauncherInstalled.dat"
    Read-Host "Press Enter to close"
    exit 1
}

$ubtPath = Join-Path $installDir "Engine\\Binaries\\DotNET\\UnrealBuildTool\\UnrealBuildTool.exe"
$uprojectDir = Split-Path -Parent $uprojectPath
$arguments = "-projectfiles -project=`"$uprojectPath`" -game -engine -vscode"

# UnrealBuildTool.exe の存在確認
if (-not (Test-Path $ubtPath)) {
    Write-Host "UnrealBuildTool.exe not found: $ubtPath"
    Read-Host "Press Enter to close"
    exit 1
}

# コマンド実行
$process = Start-Process -FilePath $ubtPath -ArgumentList $arguments -WorkingDirectory $uprojectDir -NoNewWindow -Wait -PassThru

if ($process.ExitCode -eq 0) {
    Write-Host ".code-workspace file generated successfully."
    
    # c_cpp_properties.json を編集して includePath を追加する
    $cppPropertiesPath = Join-Path $uprojectDir ".vscode\c_cpp_properties.json"
    
    if (Test-Path $cppPropertiesPath) {
        Write-Host "Modifying c_cpp_properties.json to add includePath..."
        
        # JSONファイルを読み込む
        $cppProperties = Get-Content $cppPropertiesPath -Raw | ConvertFrom-Json
        
        # includePathを追加する配列を定義（シングルクォートで変数展開を防ぐ）
        $includePathsToAdd = @(
            '${workspaceFolder}\Intermediate\**',
            '${workspaceFolder}\Plugins\**',
            '${workspaceFolder}\Source\**'
        )
        
        # 各configurationにincludePathを追加
        foreach ($config in $cppProperties.configurations) {
            # 既存のincludePathがあれば保持し、なければ新規作成
            if (-not $config.PSObject.Properties.Name.Contains("includePath")) {
                Add-Member -InputObject $config -MemberType NoteProperty -Name "includePath" -Value $includePathsToAdd
            } else {
                # 既存のincludePathがある場合は、重複を避けて追加
                $existingPaths = $config.includePath
                foreach ($path in $includePathsToAdd) {
                    if ($existingPaths -notcontains $path) {
                        $existingPaths += $path
                    }
                }
                $config.includePath = $existingPaths
            }
        }
        
        # 変更を保存
        $cppProperties | ConvertTo-Json -Depth 10 | Set-Content $cppPropertiesPath
        Write-Host "Successfully added includePath to c_cpp_properties.json"
    } else {
        Write-Host "Warning: c_cpp_properties.json not found at $cppPropertiesPath"
    }
} else {
    Write-Host "Failed to generate .code-workspace file. ExitCode: $($process.ExitCode)"
}
Write-Host "Command: $ubtPath $arguments"
Read-Host "Press Enter to close"

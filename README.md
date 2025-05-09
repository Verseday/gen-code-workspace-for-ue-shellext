# GenerateCodeWorkspace シェル拡張

## 概要
Unreal Engine の `.uproject` ファイルを右クリックして `.code-workspace` ファイルを自動生成する PowerShell スクリプトとコンテキストメニュー登録バッチファイルです。

## 前提条件
- Windows OS
- Unreal Engine がレジストリまたは `C:\ProgramData\Epic\UnrealEngineLauncher\LauncherInstalled.dat` に登録されていること
- PowerShell 実行ポリシーが `Bypass` を許可していること

## ファイル構成
- **GenerateCodeWorkspace.ps1**  
  `.uproject` から EngineAssociation を取得し、UnrealBuildTool を実行して VSCode 用ワークスペースを生成
- **install.bat**  
  レジストリにコンテキストメニュー「Generate .code-workspace file」を追加
- **uninstall.bat**  
  上記コンテキストメニューをレジストリから削除

## インストール
1. 管理者権限で `install.bat` を実行
2. `.uproject` ファイルを右クリックするとメニュー項目が表示されます

## アンインストール
1. 管理者権限で `uninstall.bat` を実行

## 使い方
1. 対象の `.uproject` ファイルを右クリック
2. 「Generate .code-workspace file」を選択
3. PowerShell ウィンドウが開き、処理が正常終了するとプロジェクトフォルダに `.code-workspace` ファイルが生成されます
4. VSCode から生成されたワークスペースを開いて作業を開始してください

## トラブルシューティング
- エンジンのインストールパスが検出できない場合は、PowerShell ウィンドウのエラーメッセージを確認し、Registry または LauncherInstalled.dat の登録状況を見直してください
- 実行ポリシーのエラーが出る場合は、管理者権限で PowerShell を開き `Set-ExecutionPolicy Bypass` を実行してください

## ライセンス
MIT License

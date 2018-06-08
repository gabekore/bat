'**************************************************
' ディレクトリをzipファイルにする
' 
' ◆期待する引数
'   1個目：対象ディレクトリ（フルパスで）
'          サンプル→ C:\hoge\fuga
'   2個目：zipファイル名（フルパスで）
'          サンプル→ C:\hoge\fuga.zip
' ◆注意
'   引数のディレクトリ存在チェックはやってないよ
' 
' ◆実行方法
'   > cscript MakeZip.vbs  param1  param2
' 
' ◆！！重要！！
'   システムファイル等を圧縮してくれないファイルがあるかも知れない
'   使用に際してはよく確認すること
' 
' カスタマイズするなら「★」マークの部分を変更するべし
'**************************************************
Option Explicit


'**************************************************
' 
' ★定数
' 
'**************************************************
Dim COMP_END_WAIT_MSEC
COMP_END_WAIT_MSEC = 3000


'**************************************************
' 
' 変数
' 
'**************************************************
Dim str
Dim Shell
Dim Fso
Dim WshShell
Dim objFolder
Dim Handle
Dim EmptyData
Dim strTargetZipFile
Dim objTargetFolder
Dim SINK
Dim objWMIService
Dim sv_counter
Dim counter
Dim ZipFile


'--------------------------------------------------
' cscriptで実行しているかの確認
'--------------------------------------------------
str = WScript.FullName
str = Right(str, 11)
str = Ucase(str)

if str <> "CSCRIPT.EXE" then
	Wscript.Echo "cscript.exeで実行してください"
	Wscript.Quit
end if


'--------------------------------------------------
' 引数があるかどうかを確認
'--------------------------------------------------
if WScript.Arguments.Count <> 2 then
	WScript.echo("error : Argument counts are invalid.")
	WScript.Quit(-1)
end if

' 引数を取得
objFolder = WScript.Arguments(0)
ZipFile   = WScript.Arguments(1)


'**************************************************
' 
' 本処理
' 
'**************************************************
'--------------------------------------------------
' 必要な基本オブジェクト
'--------------------------------------------------
Set Shell    = WScript.CreateObject("Shell.Application")
Set Fso      = WScript.CreateObject("Scripting.FileSystemObject")
Set WshShell = WScript.CreateObject("WScript.Shell")


'--------------------------------------------------
' 空のzip書庫作成
'--------------------------------------------------
Set Handle = Fso.CreateTextFile(ZipFile, True)
EmptyData = Chr(&H50) & Chr(&H4B) & Chr(&H5) & Chr(&H6)
EmptyData = EmptyData & String(18, Chr(0))

Handle.Write EmptyData
Handle.Close


'--------------------------------------------------
' 圧縮
'--------------------------------------------------
Set objTargetFolder = Shell.NameSpace(ZipFile)


'--------------------------------------------------
' 非同期の圧縮処理
'--------------------------------------------------
Call objTargetFolder.CopyHere(objFolder, 0)


'--------------------------------------------------
' WMI非同期イベントの監視
'--------------------------------------------------
Set SINK = WScript.CreateObject("WbemScripting.SWbemSink", "SINK_")
Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")
objWMIService.ExecNotificationQueryAsync  SINK, _
                                          "SELECT "                                      & _
                                          "  *    "                                      & _
                                          "FROM   "                                      & _
                                          "  __InstanceOperationEvent WITHIN 1 "         & _
                                          "WHERE "                                       & _
                                          "  TargetInstance ISA 'Win32_Process' "        & _
                                          "  AND TargetInstance.Name = 'explorer.exe' "

Wscript.Echo "ZIP保存処理を開始します（=> 終了するまで何も触らないでください）"


'--------------------------------------------------
' 圧縮処理が終了したか3秒毎に判断する
'--------------------------------------------------
Do
	sv_counter = counter
	WScript.Sleep COMP_END_WAIT_MSEC
	if sv_counter = counter then
		Wscript.Echo "処理を終了します"
		Wscript.Quit
	end if
Loop


'==================================================
' explorer.exeの動作中に呼び出される
'==================================================
Sub SINK_OnObjectReady(objLatestEvent, objAsyncContext)
	counter = counter + 1
	Wscript.Echo "... 処理中：" & objLatestEvent.TargetInstance.Name
End Sub


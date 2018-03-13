rem ********************************************
rem  File Copy to Network
rem    ◆期待する引数：
rem      %1：コピーしたいファイル（←ドラッグ＆ドロップ）
rem          1個だけを想定
rem    ※コピー先のネットワークは固定
rem ********************************************

@echo off

rem 本batの起動ディレクトリをカレントディレクトリにする
cd /d %~dp0

rem コピーしたいファイルのフルパス
set TARGET_FILE=%1
rem コピーしたいファイル名＋拡張子のみ
set TARGET_FILE_NAME=%~n1%~x1

set YYMMDD=%date:~2,2%%date:~5,2%%date:~8,2%

set NETWORKDRIVE=X:

set NET_USE_CMD=net use %NETWORKDRIVE%

rem /Y オプションは上書き確認
set COPY_CMD=copy /Y %TARGET_FILE% %NETWORKDRIVE%\.

rem 処理実行
call :NETUSE_AND_COPY \\NETWORK-MACHINE1\Hoge\Fuga\
call :NETUSE_AND_COPY \\NETWORK-MACHINE2\Hoge\Fuga\
call :NETUSE_AND_COPY \\NETWORK-MACHINE3\Hoge\Fuga\

exit /b 0

rem ********************************************
rem  サブルーチン：NETUSE_AND_COPY
rem    ◆期待する引数：
rem      %1：コピー先のパス
rem    ◆処理順序：
rem      １．ネットワークドライブを作る
rem      ２．サーバーのファイルをbkup（初回のみ）
rem          bkupファイルが無いときだけ実行
rem          あるならやらない
rem          バックアップファイルは「.yymmdd」を付与
rem      ３．copyする
rem      ４．ネットワークドライブを削除
rem ********************************************
:NETUSE_AND_COPY

rem １．
%NET_USE_CMD% %1

rem ２．
set SERVER_FILE=%NETWORKDRIVE%\%TARGET_FILE_NAME%
if not exist %SERVER_FILE%.%YYMMDD% (
    copy %SERVER_FILE% %SERVER_FILE%.%YYMMDD% 
)

rem ３．
%COPY_CMD%

rem ４．
%NET_USE_CMD% /delete

exit /b 0

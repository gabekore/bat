rem ********************************************
rem  Password Copy And Remote
rem  １．パスワードをクリップボードに入れる
rem  ２．リモートログイン起動
rem  ※パスワードをどうしても保存してくれないマシンで使う
rem ********************************************

@echo off

rem 本batの起動ディレクトリをカレントディレクトリにする
cd /d %~dp0

rem ★passwordを変更
set /P<NUL="password"|CLIP

rem ★IP-ADDRESSを変更
start C:\Windows\System32\mstsc.exe /v:"IP-ADDRESS"

exit /b 0

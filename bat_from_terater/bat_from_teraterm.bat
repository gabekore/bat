rem ********************************************
rem  bat_from_teraterm
rem    ◆概要
rem      １．サーバーAに、FTPでput
rem          →今日の日付のフォルダが無ければ作成
rem      ２．サーバーAにteratermでログイン
rem      ３．サーバーAからサーバーBにリモートログイン
rem      ４．サーバーBに今日の日付のフォルダ作成
rem      ５．
rem    ◆使い方
rem      サーバーへ送りたいファイルをドラッグ＆ドロップする
rem    ◆期待する引数：
rem      %1：コピーしたいファイル（←ドラッグ＆ドロップ）
rem          1個だけを想定
rem    ◆前提条件
rem      拡張子ttlがttpmacro.exeに関連付けられていることが望ましいかも
rem    ◆注意
rem      動作確認したものを紙に印刷してそれを見ながら再度打ちました
rem      その際、多少コードを変更していますが動作確認してません
rem      変な不具合あるかも知れません
rem ********************************************

@echo off

rem 本batの起動ディレクトリをカレントディレクトリにする
cd /d %~dp0

rem ********************************************
rem  変数（必要に応じて変更）
rem ********************************************
set FTPSERVER=ftpserver
set ID=hoge
set PASS=fuga
set FTPTEXT=ftp.txt
set FTPHOME=/hoge/fuga/
set TODAYFOLDER=%date:~2,2%%date:~5,2%%date:~8,2%
rem コピーしたいファイル名＋拡張子のみ
set PUTTARGET=%~n1%~x1


rem ********************************************
rem  FTPの接続情報テキストを作成
rem ********************************************
rem 存在しない場合はエラーになるけど、別に問題なし
del %FTPTEXT%

echo open %FTPSERVER% >> %FTPTEXT%
rem IDとパスワードは空白入れたらダメ
echo %ID%>> %FTPTEXT%
echo %PASS%>> %FTPTEXT%

rem binモードにする（必要なければ外す）
echo bin >> %FTPTEXT%

rem ★今日のフォルダに移動する★
rem 今日のフォルダは絶対にあるという前提
rem 不要ならこのコードを削除すればいい
echo cd %FTPHOME% >> %FTPTEXT%

rem 既に存在していてもmkdirする、エラーになるだろうけど無視
echo mkdir %TODAYFOLDER% >> %FTPTEXT%

rem 一応一覧出しておく
echo ls >> %FTPTEXT%

rem ドラッグ＆ドロップしたファイルをFTPへputする
echo put %PUTTARGET% >> %FTPTEXT%

rem FTP終了
echo bye >> %FTPTEXT%


rem ********************************************
rem  FTP接続
rem ********************************************
ftp -i -s:%FTPTEXT%

rem ********************************************
rem  FTPの接続情報テキストを削除
rem ********************************************
del %FTPTEXT%

rem ********************************************
rem  サーバー1にteratermでログインし、
rem  サーバー2へリモートコピーする
rem ********************************************
set TERA_MACROFILE=teramacro.ttl
rem --------------------------------------------
rem  サーバー1
rem --------------------------------------------
set SVR1_HOSTADDR='server1'
set SVR1_USERNAME='username1'
set SVR1_PASSWORD='password1'
rem シングルクォーテーション必要
set SVR1_PROMPT='PROMPT1#'

rem --------------------------------------------
rem  サーバー2
rem --------------------------------------------
set SVR2_HOSTADDR='server2'
set SVR2_USERNAME='username2'
set SVR2_PASSWORD='password2'
rem シングルクォーテーション必要
set SVR2_PROMPT='PROMPT2#'

rem 存在しない場合はエラーになるけど、別に問題なし
del %TERA_MACROFILE%

rem telnetの接続先
echo HOSTADDR = %SVR1_HOSTADDR%
echo USERNAME = %SVR1_USERNAME%
echo PASSWORD = %SVR1_PASSWORD%

echo COMMAND = HOSTADDR
echo strconcat COMMAND ':23 /NOSSH /T=1'
echo connect COMMAND
echo wait 'user name:'
echo sendln USERNAME
echo wait 'password:'
echo sendln PASSWORD

rem サーバー1での処理
echo wait SVR1_PROMPT >> %TERA_MACROFILE%
echo sendln 'cd %FTPHOME%' >> %TERA_MACROFILE%

echo wait SVR1_PROMPT >> %TERA_MACROFILE%
echo sendln 'ls -la' >> %TERA_MACROFILE%

echo wait SVR1_PROMPT >> %TERA_MACROFILE%
echo sendln 'rlogin %SVR2_HOSTADDR%' >> %TERA_MACROFILE%

rem サーバー2での処理
echo wait SVR2_PROMPT >> %TERA_MACROFILE%
echo sendln 'cd %FTPHOME%' >> %TERA_MACROFILE%

echo wait SVR2_PROMPT >> %TERA_MACROFILE%
echo sendln 'ls -la' >> %TERA_MACROFILE%

rem 既に存在していてもmkdirする、エラーになるだろうけど無視
echo wait SVR2_PROMPT >> %TERA_MACROFILE%
echo sendln 'mkdir %TODAYFOLDER%' >> %TERA_MACROFILE%

echo wait SVR2_PROMPT >> %TERA_MACROFILE%
echo sendln 'exit' >> %TERA_MACROFILE%

rem サーバー1での処理（2回目）
echo wait SVR1_PROMPT >> %TERA_MACROFILE%
echo sendln 'cd %TODAYFOLDER%' >> %TERA_MACROFILE%

echo wait SVR1_PROMPT >> %TERA_MACROFILE%
echo sendln 'rcp %PUTTARGET% %SVR2_HOSTADDR%:%FTPHOME%%TODAYFOLDER%/.' >> %TERA_MACROFILE%

echo wait SVR1_PROMPT >> %TERA_MACROFILE%
echo sendln 'exit' >> %TERA_MACROFILE%

echo end >> %TERA_MACROFILE%

rem startじゃないと動かない
rem TODO：ttpmacro.exeをstartしなくても、%TERA_MACROFILE%だけでも良いのかも？
start "c:Program Files\teraterm\ttpmacro.exe" %TERA_MACROFILE%

rem startは処理終了を待たないのですぐにdelするワケにはいかない
rem 泣く泣くpauseしている、本当はpauseなんてしたくない！
pause

rem teratermマクロ削除
del %TERA_MACROFILE%

exit /b 0

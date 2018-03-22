rem ********************************************
rem  bat_from_teraterm
rem    ◆概要
rem      １．サーバーAに、FTPでput
rem          →今日の日付のフォルダが無ければ作成
rem      ２．サーバーAにteratermでログイン
rem      ３．サーバーAからサーバーBにリモートログイン
rem      ４．サーバーBに今日の日付のフォルダ作成
rem      ５．サーバーAからサーバーBへリモートコピー
rem    ◆使い方
rem      サーバーへ送りたいファイルをドラッグ＆ドロップする
rem    ◆期待する引数：
rem      %1：コピーしたいファイル（←ドラッグ＆ドロップ）
rem          1個だけを想定
rem    ◆前提条件
rem      拡張子ttlがttpmacro.exeに関連付けられていることが望ましいかも
rem      サーバー1とサーバー2のディレクトリ構成は同じとする
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
rem --------------------------------------------
rem  全サーバー共通
rem    %MYHOME%%TODAYFOLDER%がこのbatの処理場所になる
rem --------------------------------------------
rem /からのフルパス、最後は/で終わること
set MYHOME=/hoge/fuga/
set TODAYFOLDER=%date:~2,2%%date:~5,2%%date:~8,2%
rem コピーしたいファイル名＋拡張子のみ
set PUTTARGET=%~n1%~x1
rem --------------------------------------------
rem  FTPサーバー情報（＝サーバー1）
rem --------------------------------------------
set FTPTEXT=ftp.txt
set FTPSERVER=ftpserver
set ID=ftpid
set PASS=ftppass
rem --------------------------------------------
rem  telnetサーバー1情報（=FTPサーバー）
rem --------------------------------------------
set TERA_MACROFILE=teramacro.ttl
set SVR1_HOSTADDR='server1'
set SVR1_USERNAME='username1'
set SVR1_PASSWORD='password1'
rem シングルクォーテーション必要
set SVR1_PROMPT='PROMPT1#'
rem --------------------------------------------
rem  telnetサーバー2情報
rem --------------------------------------------
set SVR2_HOSTADDR='server2'
rem 本batでは未使用だが、必要があれば使用する
set SVR2_USERNAME='username2'
rem 本batでは未使用だが、必要があれば使用する
set SVR2_PASSWORD='password2'
rem シングルクォーテーション必要
set SVR2_PROMPT='PROMPT2#'

rem ********************************************
rem  FTPの接続情報テキストを作成
rem ********************************************
rem 存在しない場合はエラーになるけど、別に問題なし
del %FTPTEXT%

rem 接続先
echo open %FTPSERVER% >> %FTPTEXT%

rem IDとパスワードは空白入れたらダメ
echo %ID%>> %FTPTEXT%
echo %PASS%>> %FTPTEXT%

rem binモードにする（必要なければ外す）
echo bin >> %FTPTEXT%

rem ひとまずMYHOMEに移動
echo cd %MYHOME% >> %FTPTEXT%

rem 既に存在していてもmkdirする、エラーになるだろうけど無視
echo mkdir %TODAYFOLDER% >> %FTPTEXT%
echo cd %TODAYFOLDER% >> %FTPTEXT%

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
rem 存在しない場合はエラーになるけど、別に問題なし
del %TERA_MACROFILE%

rem ********************************************
rem  teratermの接続マクロファイルを作成
rem ********************************************
rem teratermの接続マクロファイル内の変数
echo HOSTADDR = %SVR1_HOSTADDR% >> %TERA_MACROFILE%
echo USERNAME = %SVR1_USERNAME% >> %TERA_MACROFILE%
echo PASSWORD = %SVR1_PASSWORD% >> %TERA_MACROFILE%
rem 接続コマンド作成
echo COMMAND = HOSTADDR >> %TERA_MACROFILE%
echo strconcat COMMAND ':23 /NOSSH /T=1' >> %TERA_MACROFILE%
rem 接続＆ユーザーIDとパスワード入力
rem サーバーによってwaitするプロンプト名が違うなら変更すればいい
echo connect COMMAND >> %TERA_MACROFILE%
echo wait 'user name:' >> %TERA_MACROFILE%
echo sendln USERNAME >> %TERA_MACROFILE%
echo wait 'password:' >> %TERA_MACROFILE%
echo sendln PASSWORD >> %TERA_MACROFILE%
rem --------------------------------------------
rem サーバー1での処理
rem --------------------------------------------
rem 接続できたら、MYHOMEへ移動
echo wait SVR1_PROMPT >> %TERA_MACROFILE%
echo sendln 'cd %MYHOME%' >> %TERA_MACROFILE%
rem 一応一覧出しておく
echo wait SVR1_PROMPT >> %TERA_MACROFILE%
echo sendln 'ls -la' >> %TERA_MACROFILE%
rem サーバー2へリモートログインする
echo wait SVR1_PROMPT >> %TERA_MACROFILE%
echo sendln 'rlogin %SVR2_HOSTADDR%' >> %TERA_MACROFILE%
rem --------------------------------------------
rem サーバー2での処理
rem --------------------------------------------
rem 接続できたら、MYHOMEへ移動
echo wait SVR2_PROMPT >> %TERA_MACROFILE%
echo sendln 'cd %MYHOME%' >> %TERA_MACROFILE%
rem 一応一覧出しておく
echo wait SVR2_PROMPT >> %TERA_MACROFILE%
echo sendln 'ls -la' >> %TERA_MACROFILE%
rem 今日のフォルダを作成する
rem 既に存在していてもmkdirする、エラーになるだろうけど無視
echo wait SVR2_PROMPT >> %TERA_MACROFILE%
echo sendln 'mkdir %TODAYFOLDER%' >> %TERA_MACROFILE%
rem 今日のフォルダさえ作ればexit
echo wait SVR2_PROMPT >> %TERA_MACROFILE%
echo sendln 'exit' >> %TERA_MACROFILE%
rem --------------------------------------------
rem サーバー1での処理（2回目）
rem --------------------------------------------
rem カレントディレクトリはMYHOMEのままのはずなので、
rem 今日のフォルダにcdする
rem ※今日のフォルダはFTP-put時にやっている
echo wait SVR1_PROMPT >> %TERA_MACROFILE%
echo sendln 'cd %TODAYFOLDER%' >> %TERA_MACROFILE%
rem サーバー2へリモートコピー
echo wait SVR1_PROMPT >> %TERA_MACROFILE%
echo sendln 'rcp %PUTTARGET% %SVR2_HOSTADDR%:%MYHOME%%TODAYFOLDER%/.' >> %TERA_MACROFILE%
rem コピーさえ終わればexit
echo wait SVR1_PROMPT >> %TERA_MACROFILE%
echo sendln 'exit' >> %TERA_MACROFILE%
rem --------------------------------------------
rem  teratermマクロの終了コマンド
rem --------------------------------------------
echo end >> %TERA_MACROFILE%


rem ********************************************
rem  teratermマクロ実行
rem ********************************************
%TERA_MACROFILE%

rem teratermマクロ削除
del %TERA_MACROFILE%

exit /b 0

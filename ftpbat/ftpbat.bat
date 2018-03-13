rem ********************************************
rem  FTP接続bat
rem    ・FTPの接続情報テキストを作成→接続→削除
rem    ・FTPサーバーに今日のフォルダ（yymmdd）があるという前提で、そこにcdする
rem    ・binモード
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
set TODAYFOLDER=/hoge/fuga/%date:~2,2%%date:~5,2%%date:~8,2%

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
echo cd %TODAYFOLDER% >> %FTPTEXT%

rem 一応一覧出しておく
echo ls >> %FTPTEXT%

rem ********************************************
rem  FTP接続
rem ********************************************
ftp -i -s:%FTPTEXT%

rem ********************************************
rem  FTPの接続情報テキストを削除
rem ********************************************
del %FTPTEXT%

exit /b 0

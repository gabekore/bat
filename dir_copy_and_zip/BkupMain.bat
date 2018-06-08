@echo off

REM **************************************************
REM サーバーからローカルへコピーしてzipにするbat
REM 
REM カスタマイズするなら「★」マークの部分を変更するべし
REM **************************************************

cd /d %~dp0

REM 遅延環境変数の有効化
setlocal ENABLEDELAYEDEXPANSION


REM **************************************************
REM 
REM 変数及び定数
REM 
REM **************************************************
REM ==================================================
REM 本日日付と時刻
REM ==================================================
set TODAY_STR=%date:~2,2%%date:~5,2%%date:~8,2%
set time_temp=%time: =0%
set TIME_STR=%time_temp:~0,2%%time_temp:~3,2%%time_temp:~6,2%

REM ==================================================
REM ★擬似的な配列
REM %SERVER_UNC%の中にあるフォルダ名を書く
REM 
REM アンダーバーの後ろの数字は配列の添字と思ってください
REM batに配列は無いので、擬似的に配列っぽいものを実現している
REM 
REM 擬似的なFOREACHで処理しているので、気にせず増減してOK
REM 但し要素番号は連続したものにしてね
REM ==================================================
set FOLDER[0]=folder0
set FOLDER[1]=folder1
set FOLDER[2]=folder2

REM 事前チェック
call set it=%%FOLDER[0]%%
if not defined it (
	echo バックアップ対象が設定されていないため終了します
	exit /b 0
)


REM ==================================================
REM ★ワーキングディレクトリ
REM ・サーバーからコピーするフォルダを置くところ
REM ・zipファイルを置くところ
REM 
REM サンプル→ C:\fuga\hoge\
REM ==================================================
rem ★work_folderの最後には\マークを付けない
set work_folder=work_fol
rem ★WORKING_DIRの最後には\マークを付ける
set WORKING_DIR=%~dp0%work_folder%\%TODAY_STR%\
echo %WORKING_DIR%

if not exist %WORKING_DIR% (
	echo ワーキングディレクトリは存在しないので作成します
	mkdir %WORKING_DIR%
) else (
	REM どこに接続されているかわからないので一旦切断する
	echo ワーキングディレクトリは存在する
)


REM ==================================================
REM ネットワークドライブ関係の変数
REM Xドライブ
REM ==================================================
REM ★ドライブレター
set NETWORKDRIVE=x:
REM ★サーバー
set SERVER_UNC=\\servername\hoge\fuga

set NET_USE_CMD=net use %NETWORKDRIVE%
set NETWORKDRIVE_CREATE=%NET_USE_CMD% %SERVER_UNC%
set NETWORKDRIVE_DELETE=%NET_USE_CMD% /delete /y


REM ==================================================
REM ★VBSプログラム（zipにしてくれるやつ）
REM ==================================================
set VBS_FILE=cscript MakeZip.vbs


REM ==================================================
REM ★タイムアウト
REM ==================================================
set TIMEOUT_SEC=5




REM **************************************************
REM 
REM 本処理
REM 
REM **************************************************
REM ==================================================
REM ネットワークドライブが存在していたら切断する
REM ==================================================
if not exist %NETWORKDRIVE% (
	echo ネットワークドライブは存在しない
) else (
	REM どこに接続されているか分からないので一旦切断する
	echo ネットワークドライブは存在するので一旦強制的に切断します
	%NETWORKDRIVE_DELETE%
)


REM ==================================================
REM ネットワークドライブ接続
REM ==================================================
echo ネットワークドライブを接続します
%NETWORKDRIVE_CREATE%


REM ==================================================
REM バックアップ処理をする
REM ==================================================
REM FOLDER配列っぽいものででFOREACHっぽい処理をする
REM ※batにはFOREACHの命令は無いので擬似的なもの

REM --------------------------------------------------
REM サーバーからローカルへコピー
REM --------------------------------------------------
set i=0
:FOREACH_COPY
call set it=%%FOLDER[!i!]%%
if defined it (
	echo %NETWORKDRIVE%\!it!
	
	REM サーバーからローカルへコピー
	set XCOPY_CMD=xcopy /s /e /i /h /k /q %NETWORKDRIVE%\!it!  %WORKING_DIR%!it!
	echo %XCOPY_CMD%
	call %XCOPY_CMD%
	
	REM 次の要素へ移動
	set /A i+=1
	goto :FOREACH_COPY
)


REM --------------------------------------------------
REM コピーの終了を検知することができないので、数秒待つことにする
REM ※コピー元／先のサイズを比較すれば終了が分かる思うが、
REM   面倒なので数秒待つだけにする
REM --------------------------------------------------
timeout /t %TIMEOUT_SEC% /nobreak


REM --------------------------------------------------
REM ZIP化
REM --------------------------------------------------
set i=0
:FOREACH_ZIP
call set it=%%FOLDER[!i!]%%
if defined it (
	echo !it!
	
	REM vbsでzipにする
	set PARAM1=%WORKING_DIR%!it!
	set PARAM2=!PARAM1!_%TODAY_STR%_%TIME_STR%.zip
	set ZIP_CMD=%VBS_FILE%  !PARAM1!  !PARAM2!
	echo %ZIP_CMD%
	call %ZIP_CMD%
	
	REM 次の要素へ移動
	set /A i+=1
	goto :FOREACH_ZIP
)


REM ==================================================
REM ネットワークドライブ切断
REM ==================================================
%NETWORKDRIVE_DELETE%


REM ==================================================
REM 後始末処理
REM ==================================================
REM --------------------------------------------------
REM ローカルにコピーしたフォルダを削除する
REM --------------------------------------------------
set i=0
:FOREACH_RMDIR
call set it=%%FOLDER[!i!]%%
if defined it (
	echo !it!
	
	REM ローカルにコピーしたフォルダを削除する
	set PARAM1=%WORKING_DIR%!it!
	set RMDIR_CMD=rmdir /s /q  !PARAM1!
	echo %RMDIR_CMD%
	call %RMDIR_CMD%
	
	REM 次の要素へ移動
	set /A i+=1
	goto :FOREACH_RMDIR
)


REM ==================================================
REM 終了
REM ==================================================
exit /b 0


'**************************************************
' �f�B���N�g����zip�t�@�C���ɂ���
' 
' �����҂������
'   1�ځF�Ώۃf�B���N�g���i�t���p�X�Łj
'          �T���v���� C:\hoge\fuga
'   2�ځFzip�t�@�C�����i�t���p�X�Łj
'          �T���v���� C:\hoge\fuga.zip
' ������
'   �����̃f�B���N�g�����݃`�F�b�N�͂���ĂȂ���
' 
' �����s���@
'   > cscript MakeZip.vbs  param1  param2
' 
' ���I�I�d�v�I�I
'   �V�X�e���t�@�C���������k���Ă���Ȃ��t�@�C�������邩���m��Ȃ�
'   �g�p�ɍۂ��Ă͂悭�m�F���邱��
' 
' �J�X�^�}�C�Y����Ȃ�u���v�}�[�N�̕�����ύX����ׂ�
'**************************************************
Option Explicit


'**************************************************
' 
' ���萔
' 
'**************************************************
Dim COMP_END_WAIT_MSEC
COMP_END_WAIT_MSEC = 3000


'**************************************************
' 
' �ϐ�
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
' cscript�Ŏ��s���Ă��邩�̊m�F
'--------------------------------------------------
str = WScript.FullName
str = Right(str, 11)
str = Ucase(str)

if str <> "CSCRIPT.EXE" then
	Wscript.Echo "cscript.exe�Ŏ��s���Ă�������"
	Wscript.Quit
end if


'--------------------------------------------------
' ���������邩�ǂ������m�F
'--------------------------------------------------
if WScript.Arguments.Count <> 2 then
	WScript.echo("error : Argument counts are invalid.")
	WScript.Quit(-1)
end if

' �������擾
objFolder = WScript.Arguments(0)
ZipFile   = WScript.Arguments(1)


'**************************************************
' 
' �{����
' 
'**************************************************
'--------------------------------------------------
' �K�v�Ȋ�{�I�u�W�F�N�g
'--------------------------------------------------
Set Shell    = WScript.CreateObject("Shell.Application")
Set Fso      = WScript.CreateObject("Scripting.FileSystemObject")
Set WshShell = WScript.CreateObject("WScript.Shell")


'--------------------------------------------------
' ���zip���ɍ쐬
'--------------------------------------------------
Set Handle = Fso.CreateTextFile(ZipFile, True)
EmptyData = Chr(&H50) & Chr(&H4B) & Chr(&H5) & Chr(&H6)
EmptyData = EmptyData & String(18, Chr(0))

Handle.Write EmptyData
Handle.Close


'--------------------------------------------------
' ���k
'--------------------------------------------------
Set objTargetFolder = Shell.NameSpace(ZipFile)


'--------------------------------------------------
' �񓯊��̈��k����
'--------------------------------------------------
Call objTargetFolder.CopyHere(objFolder, 0)


'--------------------------------------------------
' WMI�񓯊��C�x���g�̊Ď�
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

Wscript.Echo "ZIP�ۑ��������J�n���܂��i=> �I������܂ŉ����G��Ȃ��ł��������j"


'--------------------------------------------------
' ���k�������I��������3�b���ɔ��f����
'--------------------------------------------------
Do
	sv_counter = counter
	WScript.Sleep COMP_END_WAIT_MSEC
	if sv_counter = counter then
		Wscript.Echo "�������I�����܂�"
		Wscript.Quit
	end if
Loop


'==================================================
' explorer.exe�̓��쒆�ɌĂяo�����
'==================================================
Sub SINK_OnObjectReady(objLatestEvent, objAsyncContext)
	counter = counter + 1
	Wscript.Echo "... �������F" & objLatestEvent.TargetInstance.Name
End Sub


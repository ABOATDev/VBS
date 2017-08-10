'====================================================================================================================================================================================
'Auteur : Brughes.
'Note : vous pouvez �couter/t�l�charger ma musique en open source : http://soundcloud.com/cyberflaneur ou http://www.jamendo.com/fr/artist/Brughes
'Description : signe un script avec une cl� valide en ouvrant une bo�te de dialogue pointant sur le script � signer.
'====================================================================================================================================================================================

Option Explicit

Dim WshShell, objDialog, strFile, strComputer, KeyName
strComputer = "."

'Quitter si le script est d�j� lanc�
If AppPrevInstance() = True Then TerminateApp()

'Saisie du nom de la cl�
KeyName = InputBox("Entrez le nom du certificat de signature : ", "Signer un vbscript")
If KeyName = "" Then TerminateApp()

'Ouvrir une bo�te de dialogue pointant sur le script � signer
Set objDialog = CreateObject("UserAccounts.CommonDialog")
objDialog.Filter = "Vbscript|*.vbs;*.vbe"
objDialog.FilterIndex = 1
objDialog.Flags = 0
Set WshShell = WScript.CreateObject("WScript.Shell")
objDialog.InitialDir = WshShell.CurrentDirectory 'WshShell.SpecialFolders("Desktop")
If objDialog.ShowOpen Then
        strFile = objDialog.FileName
Else
        TerminateApp()
End If

SignScript strFile, KeyName

'Effacer les objets en m�moire et quitter
TerminateApp()


'====================================================================================================================================================================================
'Fonctions et proc�dures
'====================================================================================================================================================================================

Function AppPrevInstance()
'V�rifier si un script portant le m�me nom que le pr�sent script est d�j� lanc�
        Dim objWMIService, colScript, objScript, RunningScriptName, Counter
        Counter = 0
        Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
        Set colScript = objWMIService.ExecQuery("SELECT * FROM Win32_Process WHERE Name = 'Wscript.exe' OR Name = 'Cscript.exe'")
        For Each objScript In colScript
                RunningScriptName = Mid(objScript.CommandLine, InstrRev(objScript.CommandLine, "\", -1, 1) + 1, Len(objScript.CommandLine) - InstrRev(objScript.CommandLine, "\", -1, 1) - 2)
                If WScript.ScriptName = RunningScriptName Then Counter = Counter + 1
		Wscript.Sleep 100
        Next
        If  Counter > 1 Then
                AppPrevInstance = True
        Else
                AppPrevInstance = False
        End If
        Set colScript = Nothing
        Set objWMIService = Nothing
End Function

Sub TerminateApp()
'Effacer les objets en m�moire et quitter
        Set WshShell = Nothing
        Set objDialog = Nothing
        WScript.Quit
End Sub

Sub SignScript(ByVal strScriptFile, ByVal Key)
        Dim objSigner
        On Error Resume Next
        Set objSigner = WScript.CreateObject("Scripting.Signer")
        objSigner.SignFile strScriptFile, Key, "my"
        If Err.Number = -2146885620 Then MsgBox "    Le certificat n'existe pas.             ", 64, "Signer un vbscript"
        Err.Clear
        On Error Goto 0
        Set objSigner = Nothing
End Sub


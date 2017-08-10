'============================================================================================
'Test de la connexion r�seau.
'
'Auteur : Brughes
'Vous pouvez �couter/t�l�charger ma musique en open source : http://soundcloud.com/cyberflaneur ou http://www.jamendo.com/fr/artist/Brughes
'============================================================================================

Option Explicit

Dim Ret, strComputer

strComputer = "."

'Quitter si le script est d�j� lanc�.
If AppPrevInstance() = True Then TerminateApp()

'Ex�cuter la commande ping sous une fen�tre DOS cach�e et r�cup�rer la r�ponse
Ret = CmdStdOut("ping -n 3 -w 1000 84.96.226.210")

If Instr(1, Ret, "R�ponse", 1) <> 0 Then
	Wscript.Echo "La connexion r�seau est pr�sente. "
Else
	Wscript.Echo "La connexion r�seau est absente.  "
End If

'Supprimer les objets en m�moire et quitter
TerminateApp()


'=======================================================================================================
'Fonctions et proc�dures.
'=======================================================================================================

Function AppPrevInstance()
'V�rifie si un script portant le m�me nom que le pr�sent script est d�j� lanc�
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

        'Efface les objets en m�moire
        Set colScript = Nothing
        Set objWMIService = Nothing
End Function

Sub TerminateApp()
'Quitte
	WScript.Quit
End Sub

Function CmdStdOut(ByVal CmdLine)
'Renvoie la sortie StdOut d'une commande de la console DOS
	Dim OutF, WshShell, fOut, sCmd, fso

	Set fso = CreateObject("Scripting.FileSystemObject")
	Set WshShell = WScript.CreateObject("WScript.Shell")

        fOut = WshShell.ExpandEnvironmentStrings("%TEMP%") & "\" & fso.GetTempName
	sCmd = "%COMSPEC% /c " & CmdLine & " >" & fOut
	WshShell.Run sCmd, 0, True
	
        If fso.FileExists(fOut) Then
		If fso.GetFile(fOut).Size > 0 Then
			Set OutF = fso.OpenTextFile(fOut)
			CmdStdOut = OutF.Readall
			OutF.Close
			Set OutF = Nothing
		End If
		fso.DeleteFile(fOut)
	End If

	Set WshShell = Nothing
	Set fso = Nothing
End Function

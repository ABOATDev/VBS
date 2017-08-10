'====================================================================================================================================================================================
'Efface les fichiers stock�s sur le disque par Internet Explorer
'Auteur : Brughes
'
'Vous pouvez �couter/t�l�charger ma musique en open source : http://soundcloud.com/cyberflaneur ou http://www.jamendo.com/fr/artist/Brughes
'====================================================================================================================================================================================

Option Explicit

Dim WsShell, Param, strComputer

strComputer = "."

'Quitter si le script est d�j� lanc�.
If AppPrevInstance() = True Then TerminateApp()

Set WsShell = CreateObject("Wscript.Shell")

Param = 0

'Effacer l'historique
Param = Param + 1

'Effacer les Cookies
Param = Param + 2

'Effacer les fichiers Internet temporaires
Param = Param + 8

'Effacer les donn�es des formulaires
'Param = Param + 16

'Effacer les mots de passe
'Param = Param + 32

'Effacer l'historique de navigation y compris l'historique des compl�ments
Param = Param + 193

'Effacer compl�tement l'historique de navigation
Param = Param + 255

'Effacer le cheminement
'Param = Param + 2048

'Tout effacer y compris les fichiers et les param�tres des compl�ments
'Param = Param + 4351

'Pr�server les favoris
'Param = Param + 8192

'Effacer les fichiers t�l�charg�s (downloaded Files)
Param = Param + 16384

'Tout effacer
'Param = Param + 22783

On Error Resume Next

WsShell.Run "Rundll32.exe InetCpl.cpl,ClearMyTracksByProcess " & Param, 0, True

On Error Goto 0

'Supprimer les objets en m�moire et quitter
TerminateApp()


'====================================================================================================================================================================================
'Fonctions et proc�dures.
'====================================================================================================================================================================================

Sub TerminateApp()
'Supprime les objets en m�moire et quitte
        Set WsShell = Nothing
	WScript.Quit
End Sub

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


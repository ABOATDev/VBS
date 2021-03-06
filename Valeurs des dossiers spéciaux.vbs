'Liste les noms des dossiers sp�ciaux de Windows ainsi que les identifiants num�riques associ�s

'Option Explicit

'Dim strComputer, sMsg, sNameSpace, dNameSpaces

strComputer = "."
sMsg = ""

'Quitter si le script est d�j� lanc�
If AppPrevInstance() = True Then TerminateApp()

Set dNameSpaces = GetNameSpaces() 


For Each sNameSpace In SortNet(dNameSpaces.Keys)
        If sNameSpace = "Connexions r�seau" Then
                sMsg = sMsg & sNameSpace & ":" & vbTab & dNameSpaces(sNameSpace) & vbCrLf
        ElseIf sNameSpace = "WINDOWS" Then
                sMsg = sMsg & sNameSpace & ":" & vbTab & vbTab & dNameSpaces(sNameSpace) & vbCrLf
        ElseIf sNameSpace = "Domicile" Then
                sMsg = sMsg & sNameSpace & ":" & vbTab & vbTab & vbTab & dNameSpaces(sNameSpace) & vbCrLf
        ElseIf sNameSpace = "Corbeille" Then
                sMsg = sMsg & sNameSpace & ":" & vbTab & vbTab & vbTab & dNameSpaces(sNameSpace) & vbCrLf
        ElseIf 1 < Len(sNameSpace) And Len(sNameSpace) <= 7 Then
	       sMsg = sMsg & sNameSpace & ":" & vbTab & vbTab & vbTab & dNameSpaces(sNameSpace) & vbCrLf
        ElseIf 7 < Len(sNameSpace) And Len(sNameSpace) <= 17 Then
	       sMsg = sMsg & sNameSpace & ":" & vbTab & vbTab & dNameSpaces(sNameSpace) & vbCrLf
        ElseIf 17 < Len(sNameSpace) And Len(sNameSpace) < 30 Then
	       sMsg = sMsg & sNameSpace & ":" & vbTab & dNameSpaces(sNameSpace) & vbCrLf
        End If
Next

MsgBox "NameSpace Count = " & UBound(dNameSpaces.Keys) + 1 & "                           " & vbCrLf & vbCrLf & sMsg

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
        Set dNameSpaces = Nothing
        Set sNameSpace = Nothing
        WScript.Quit
End Sub

Function GetNameSpaces()
'Renvoie un dictionnaire contenant les noms des dossiers sp�ciaux et les nombres associ�s
	Dim dNameSpaces, dNameSpaces2, oShApp, oShFolder, sNameSpace

	Set dNameSpaces = CreateObject("scripting.dictionary")
	dNameSpaces.comparemode = vbTextCompare

	Set dNameSpaces2 = CreateObject("scripting.dictionary")
	dNameSpaces2.comparemode = vbTextCompare

	Set oShApp = CreateObject("Shell.Application")

	On Error Resume Next

	For i = 0 To 100
		Set oShFolder = oShApp.NameSpace(i) 
		dNameSpaces(oShFolder.Title) = dNameSpaces(oShFolder.Title) & i & " "
	Next

	On Error Goto 0

	For Each sNameSpace In SortNet(dNameSpaces.Keys)
		dNameSpaces2(sNameSpace) = Replace(Trim(dNameSpaces(sNameSpace)), " ", ",")
	Next

	Set GetNameSpaces = dNameSpaces2
End Function

Function SortNet(a1DArray)
	Dim i
	With CreateObject ("System.Collections.ArrayList")
		For i = 0 To UBound(a1DArray)
			.Add a1DArray(i)
		Next
		.Sort()
		SortNet = .ToArray
	End With
End Function 
    
 
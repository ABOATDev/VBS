'*** Choix du cr�� ou supprimer  ***
choix = InputBox ("Voulez vous cr�er un dossier ou le supprimer ?" & vbCr & vbCr & vbCr & "1 = Cr�er" &vbCr & "2 = Supprimer","Cr�er ou Supprimer un dossier ?","1") 

'*** Choix du r�pertoire ***
Const RETURNONLYFSDIRS = &H1 
  
Set oShell = CreateObject("Shell.Application") 
Set oFolder = oShell.BrowseForFolder(&H0&, "Choisir un r�pertoire", RETURNONLYFSDIRS, "c:\") 
If oFolder is Nothing Then  
	MsgBox "Aucun dossier choissi !",vbCritical 
Else 
  Set oFolderItem = oFolder.Self
  nomdudossier = oFolderItem.path 
End If 
Set oFolderItem = Nothing 
Set oFolder = Nothing 
Set oShell = Nothing

If choix = "1" Then
'Choix cr�er

'*** Exercution code cmd ***
Set WS = CreateObject("WScript.Shell")
Command = "cmd /C md " & nomdudossier & "\con\"
Result = Ws.Run(Command,0,True)

If Result = "0" Then 
MsgBox "La cr�ation ou la suppression c'est exercut� avec succ�s.", vbInformation, "SUCCES"
Else
MsgBox "Erreur fatal lors de cr�ation ou la suppression du dossier.", vbError, "ERREUR"
End If 

ElseIf choix = "2" Then
'Choix supprimer

'*** Exercution code cmd ***
Set WS = CreateObject("WScript.Shell")
Command = "cmd /C rd " & nomdudossier & "\"
Result = Ws.Run(Command,0,True)

If Result = "0" Then 
MsgBox "La cr�ation ou la suppression c'est exercut� avec succ�s.", vbInformation, "SUCCES"
Else
MsgBox "Erreur fatal lors de cr�ation ou la suppression du dossier.", vbError, "ERREUR"
End If 

Else
'Autre choix 
MsgBox "Demande incomprise, l'application va quitter"
WScript.Quit ()
End If 
Option Explicit
'D�claration des variables globales
Dim Titre,MaChaine,fso,ws,LogFile,ChaineCrypt
'Titre du Script
Titre = "Cryptage d'une cha�ne de caract�res by Hackoo"
Set fso = CreateObject("Scripting.FileSystemObject")
Set ws = CreateObject("Wscript.Shell")
'Nom du fichier qui va stocker le r�sultat
LogFile = Left(Wscript.ScriptFullName,InstrRev(Wscript.ScriptFullName, ".")) & "txt"
if fso.FileExists(LogFile) Then 'Si le fichier LogFile existe 
    fso.DeleteFile LogFile 'alors on le supprime
end If
'La bo�te de saisie de la cha�ne de caract�res
MaChaine = InputBox("Taper votre cha�ne ou bien une phrase pour la crypter",Titre,"ABOAT dans www.developpez.com")
'Si la Cha�ne est vide ou bien on ne tape rien dans l'inputbox,alors on quitte le script
If MaChaine = "" Then Wscript.Quit 
ChaineCrypt = Crypt(MaChaine,"2015")
MsgBox DblQuote(MaChaine) &" est transform�e en "& VbCrlF & VbCrlF & DblQuote(ChaineCrypt),Vbinformation,Titre
Call WriteLog(ChaineCrypt,LogFile)
ws.run LogFile
'************************************************************************
Function Crypt(text,key) 
Dim i,a
For i = 1 to len(text)
      a = i mod len(key)
      if a = 0 then a = len(key)
      Crypt = Crypt & chr(asc(mid(key,a,1)) XOR asc(mid(text,i,1)))
Next
End Function
'*****************************************************************
'Fonction pour ajouter des guillemets dans une variable
Function DblQuote(Str)
    DblQuote = Chr(34) & Str & Chr(34)
End Function
'*****************************************************************
'Fonction pour �crire le r�sultat dans un fichier texte
Sub WriteLog(strText,LogFile)
    Dim fs,ts 
    Const ForAppending = 8
    Set fs = CreateObject("Scripting.FileSystemObject")
    Set ts = fs.OpenTextFile(LogFile,ForAppending,True)
    ts.WriteLine strText
    ts.Close
End Sub
'*****************************************************************
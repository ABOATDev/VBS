'----------------------------NumSerie_Usb.vbs------------------------------
'Tester et v�rifier si votre cl� USB est connect� ou non, 
'si cette derni�re est connect�e alors le script nous donne son N� de S�rie.
'� Hackoo
'--------------------------------------------------------------------------
  Sub NumSerie_Usb()
  Dim NumSerie
  'Retrouver la cl� Usb et son num�ro de s�rie
  Set fso = CreateObject("Scripting.FileSystemObject")
  For Each Drive In fso.Drives
  If Drive.IsReady Then
  If Drive.DriveType=1 Then
  NumSerie=fso.Drives(Drive + "\").SerialNumber
  MsgBox "La Cl� Usb ins�r� a comme Num� de S�rie "&NumSerie,64,"V�rification Cl� Usb � Hackoo"
  end if
  End If
  Next
  End Sub
 
'------------------------------checkUSB----------------------------
Sub checkUSB
strComputer = "."
On Error Resume Next
Set WshShell = CreateObject("Wscript.Shell")
beep = chr(007)
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
Set colItems = objWMIService.ExecQuery("Select * from Win32_DiskDrive WHERE InterfaceType='USB'",,48)
intCount = 0
For Each drive In colItems
    If drive.mediaType <> "" Then
        intCount = intCount + 1
    End If
Next
If intCount > 0 Then
    MsgBox "Votre Cl� USB Personnelle est bien Connect�e !",64,"Flash Drive Check � Hackoo!"
	Call NumSerie_Usb() ' Appelle a la proc�dure NumSerie_Usb()
else
	WshShell.Run "cmd /c @echo " & beep, 0
	wscript.sleep 1000
	MsgBox "Votre Cl� USB Personnelle n'est pas Connect�e ",48,"Flash Drive Check � Hackoo !"
End If
End Sub
'---------------------------Fin du checkUSB----------------------------
Call checkUSB ' Appelle a la proc�dure checkUSB
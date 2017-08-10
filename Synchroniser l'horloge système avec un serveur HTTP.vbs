'Synchronisation de l'horloge de l'ordinateur � la seconde pr�s avec un serveur HTTP.
'Auteur : Brughes
'Vous pouvez �couter/t�l�charger ma musique en open source : http://soundcloud.com/cyberflaneur ou http://www.jamendo.com/fr/artist/Brughes

Option Explicit
Dim whShell, strTitle, BtnCode, HTTP, n, TimeCheck, LocalDate, Lag, GMTTime, TimeServer, TimeServerName, RemoteDate, Diff, NewNow, NewDate, NewTime, dDiff, sDiff, TimeMsg, DateMsg, TimeOffset, HexVal

strTitle = "Ajuster l'horloge"
Set whShell = CreateObject("WScript.Shell")
Set HTTP = CreateObject("microsoft.xmlhttp")

'V�rifier la compatibilit� du syst�me
On Error Resume Next
If Err.Number <> 0 Then
	BtnCode = whShell.Popup("Traitement interrompu" & vbcrlf & vbcrlf & "Internet Explorer n'est pas disponible.", 5, strTitle, 64)
	Set whShell = Nothing
	Set HTTP = Nothing
	Err.Clear
	On Error GoTo 0
	WScript.Quit
End If
On Error GoTo 0

'Lecture dans le registre de la valeur hexad�cimale du d�calage du fuseau horaire
TimeOffset = whShell.RegRead("HKLM\SYSTEM\CurrentControlSet\" & "Control\TimeZoneInformation\ActiveTimeBias")

'Calcule la valeur hexad�cimale du d�calage du fuseau horaire
HexVal = Hex(TimeOffset)

'Conversion en minutes du d�calage du fuseau horaire
TimeOffset = - CLng("&H" & HexVal)

'Obtient le temps depuis le serveur USNO en effectuant 5 tentatives
TimeServer = "http://tycho.usno.navy.mil/cgi-bin/timer.pl" & Now()
TimeServerName = "USNO"
On Error Resume Next
Err.Clear
HTTP.Open "GET", TimeServer, False
HTTP.Send
If Err.Number <> 0 Then
	'Utilise le serveur de secours NIST
	TimeServer = "http://www.nist.gov/"
	TimeServerName = "NIST"
	Err.Clear
End If
On Error GoTo 0

For n = 0 to 4
	HTTP.Open "GET", TimeServer, False
	'V�rifie que les serveurs r�pondent
	TimeCheck = Now
	On Error Resume Next
	HTTP.Send
	If Err.Number <> 0 Then
		If Err.Number =  -2146697211 Then
			MsgBox "Les 2 serveurs d'horloge atomique sont invalides"
		Else
			MsgBox "Erreur inconnue, " & Err.Number
		End If
		Set whShell = Nothing
		Set HTTP = Nothing
		Err.Clear
		On Error GoTo 0
		Wscript.Quit
	End If
	On Error GoTo 0
	LocalDate = Now
	Lag = DateDiff("s", TimeCheck, LocalDate)

	'Lecture de la date dans l'ent�te
	GMTTime = HTTP.GetResponseHeader("Date")

	'Conversion  de la date obtenue au format de date fran�aise
	GMTTime = Right(GMTTime, Len(GMTTime) - 5)
	GMTTime = Left(GMTTime, Len(GMTTime) - 3)
	GMTTime = Trim(GMTTime)
	GMTTime = Replace(GMTTime, " Jan ", "/01/")
	GMTTime = Replace(GMTTime, " Feb ", "/02/")
	GMTTime = Replace(GMTTime, " Mar ", "/03/")
	GMTTime = Replace(GMTTime, " Apr ", "/04/")
	GMTTime = Replace(GMTTime, " May ", "/05/")
	GMTTime = Replace(GMTTime, " Jun ", "/06/")
	GMTTime = Replace(GMTTime, " Jul ", "/07/")
	GMTTime = Replace(GMTTime, " Aug ", "/08/")
	GMTTime = Replace(GMTTime, " Sep ", "/09/")
	GMTTime = Replace(GMTTime, " Oct ", "/10/")
	GMTTime = Replace(GMTTime, " Nov ", "/11/")
	GMTTime = Replace(GMTTime, " Dec ", "/12/")
        
	'Si moins de 2 secondes d'�cart, le r�sultat est exploitable
	If Lag < 2 Then Exit For
	WScript.Sleep 100
Next

'Si l'�cart est trop important apr�s 5 tentatives, quitter 
If Lag > 2  then
	BtnCode = whShell.Popup("Impossible d'�tablir une connexion viable avec les serveurs d'horloge atomique." & vbcrlf & vbcrlf & "Essayez plus tard.", 5, strTitle, 64)
	Set whShell = Nothing
	Set HTTP = Nothing
	Wscript.Quit
End If

'Ajoute le d�calage de fuseau horaire au temps GMT renvoy� par le serveur
RemoteDate = DateAdd("n", Timeoffset, GMTTime)

'Calcule la diff�rence en secondes entre la date locale et celle obtenue
Diff = DateDiff("s", LocalDate, RemoteDate)

'Ajuster la date avec la diff�rence et l'�cart
NewNow = DateAdd("s", Diff + Lag, Now)

'Extrait la date et calcule la diff�rence
NewDate = FormatDateTime(DateValue(NewNow))
dDiff = DateDiff("d", Date, NewDate)

'Extrait l'heure
NewTime = TimeValue(NewNow)

'Conversion de l'heure au format 24h pour des raisons de compatibilit�
NewTime = Right(0 & Hour(NewTime), 2) & ":" & Right(0 & Minute(NewTime), 2) & ":" & Right(0 & Second(NewTime), 2)

'Calcule la diff�rence de temps
sDiff = DateDiff("s", Time, NewTime)

'Si le d�calage est de plus d'une seconde, ajuster l'heure locale
If -2 < sDiff And sDiff < 2 Then
	TimeMsg = "Le syst�me est pr�cis � 1 seconde pr�s. L'heure n'a pas �t� chang�e."
Else
	'Utiliser une commande de temps DOS dans une fen�tre invisible.
	whShell.Run "%comspec% /c time " & NewTime, 0
	TimeMsg = "L'heure �tait d�cal�e de " & sdiff & " secondes et a �t� chang�e � " & CDate(NewTime)
End If

'Mettre � jour la date si elle est d�cal�e
If dDiff <> 0 Then
	whShell.Run "%comspec% /c date " & NewDate, 0
	DateMsg = "Date d�pass�e de " & ddiff & " jours. Date du syst�me chang�e � " & FormatDateTime(NewDate,1) & vbcrlf & vbcrlf
Else
	DateMsg = ""
End If

'Afficher les changements
BtnCode = whShell.Popup("Synchronisation de l'horloge en utilisant le serveur " & TimeServerName & vbcrlf & vbcrlf & DateMsg & TimeMsg, 5, strTitle, 64)

Set whShell = Nothing
Set HTTP = Nothing

WScript.Quit

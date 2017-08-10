'=============================================================================================
'Description :
'D�fragmente en priorit� basse tous les disques durs sans que rien ne soit visible et sans intervention de l'utilisateur.
'Une d�fragmentation pouss�e est obtenue par it�rations.
'Le code calcul, par diff�rentiation, le temps �coul� entre deux d�fragmentations successives.
'Ceci rend le code ind�pendant de la vitesse d'ex�cution du PC et des performances des disques durs.
'Optimise �galement le Prefetch.
'Ceci permet de d�fragmenter r�guli�rement en lan�ant ce script par le planificateur des t�ches.
'
'Commentaires :
'Il faut qu'il y ait au moins 15% d'espace libre pour r�aliser la d�fragmentation dans de bonnes conditions.
'Cet espace est utilis� comme zone de transit pour les fichiers d�plac�s.
'En de�a de ce seuil, la d�fragmentation risque d'�tre longue et incompl�te.
'Les lecteurs � m�moire Flash ne doivent jamais �tre d�fragment�s car leur nombre d'�criture est limit�.
'
'Microsoft conseille de d�fragmenter un disque dur si le taux de fragmentation est sup�rieur � 10%.
'Un taux de fragmentation de moins de 10 % est en principe pas g�nant. Cependant, les performances des disques sont notablement moindres !
'Depuis Windows Vista, la fragmentation atteint rarement un seuil g�nant car un utilitaire inclus d�fragmente automatiquement, par d�faut, tous les mercredis � 1 heure du matin.
'Sous XP cet fonctionnalit� n'est pas impl�ment�e. Il est donc int�ressant de conna�tre le taux de fragmentation des disques et de d�fragmenter r�guli�rement.
'
'Auteur : Brughes
'Vous pouvez �couter/t�l�charger ma musique en open source : http://soundcloud.com/cyberflaneur ou http://www.jamendo.com/fr/artist/Brughes
'=============================================================================================

Option Explicit

Const DriveTypeFixed = 2
Dim WshShell, fso, d, dc, Return, X, I, Time0, Time1, ElapsedSecond, ElapsedSecond1, ElapsedSecond2, Counter

Set WshShell = WScript.CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
Set dc = fso.Drives

'D�fragmente les disques durs
X = 0
For Each d in dc
	If d.DriveType = DriveTypeFixed Then
		X = X + 1 : Counter = 0 : ElapsedSecond1 = 0 : ElapsedSecond2 = 0

		'Boucle d'it�rations jusqu'� ce que le temps de d�fragmentation des disques soit inf�rieur � 10 secondes avec une limite de 8 it�rations
		Do While Counter < 8
			Counter = Counter + 1

			'M�morise le temps initial converti en secondes
			Time0 = Now : Time0 = Second(Time0) + Minute(Time0) * 60 + Hour(Time0) * 3600

			'Lance Defrag de mani�re invisible
			RunDefrag d, "-f"

			'Si une erreur est survenue quitter la boucle pour passer � la d�fragmentation du disque suivant
			If Return <> 0 Then Exit Do

			'M�morise le temps final converti en secondes
			Time1 = Now : Time1 = Second(Time1) + Minute(Time1) * 60 + Hour(Time1) * 3600

			'Calcul du temp �coul� en secondes
			If Time1 >= Time0 Then
				ElapsedSecond = Time1 - Time0
			Else
				'D�tecter le passage � minuit
				ElapsedSecond = 24 * 3600 - Time0 + Time1
			End If

			'Calcul de la diff�rence de temps des deux derni�res d�fragmentations
			If ElapsedSecond1 <> 0 Then
				ElapsedSecond2 = ElapsedSecond 'temps �coul� le plus r�cent
			Else
				ElapsedSecond1 = ElapsedSecond 'temps �coul� le plus ancien
			End If

			If ElapsedSecond2 <> 0 And ElapsedSecond1 <> 0 Then
				ElapsedSecond = ElapsedSecond1 - ElapsedSecond2  'temps �coul� le plus ancien - temps �coul� le plus r�cent
				ElapsedSecond1 = ElapsedSecond2
				ElapsedSecond2 = 0
			End If

			If Abs(ElapsedSecond) < 10 Then Exit Do

			Wscript.Sleep 100
		Loop
	End If
	Wscript.Sleep 100
Next

'D�fragmente le boot si ce n'est pas r�alis� par la d�fragmentation classique
DefragBoot

'Force la mise � jour de Layout.ini utilis� par le prefetch et la d�fragmentation du boot
UpDateLayout

'Supprimer les objets en m�moire et quitter
Set dc = Nothing
Set fso = Nothing
Set WshShell = Nothing

WScript.Quit


Function IsProcessRunning(ByVal strProcessName)
'D�tecter si strProcessName est en cours d'ex�cution

	Const strComputer = "."
	Dim objWMIService, objProcess, colProcess

	Set objWMIService = GetObject("winmgmts:" &"{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
	Set colProcess = objWMIService.ExecQuery ("Select * from Win32_Process")

	IsProcessRunning = False
	For Each objProcess In colProcess
		If objProcess.Name = strProcessName Then IsProcessRunning = True
		Wscript.Sleep 100
	Next

	Set objWMIService = Nothing
	Set colProcess = Nothing

End Function

Function WaitUntilProcessEnds(ByVal strProcessName)
'Boucle d'attente si strProcessName est en cours d'ex�cution

	Do While IsProcessRunning(strProcessName) = True
		Wscript.Sleep 100
	Loop

	WaitUntilProcessEnds = True

End Function

Sub RunDefrag(ByVal strDrive, ByVal strOption)
'Cr�e un process Defrag en priorit� basse sur l'ordinateur local

	Dim objWMIService, objConfig, objStartup, objProcess, intProcessID, strCommand, Return
	Const SW_HIDE = 0
	Const strComputer = "."
	Const IDLE_PROCESS = 64

	Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
	Set objStartup = objWMIService.Get("Win32_ProcessStartup")

	'Cr�e la cha�ne de commande dfrgntfs.exe
	strCommand = "dfrgntfs.exe -Embedding"

	'Configure dfrgntfs.exe en priorit� basse avec une fen�tre cach�e
	Set objConfig = objStartup.SpawnInstance_
	objConfig.ShowWindow = SW_HIDE
	objConfig.PriorityClass = IDLE_PROCESS

	'Cr�e le process dfrgntfs.exe
	Set objProcess = objWMIService.Get("Win32_Process")
	Return = objProcess.Create(strCommand, Null, objConfig, intProcessID)

	'Attendre que le process dfrgntfs.exe soit lanc�
	IsProcessRunning("dfrgntfs.exe")

	'Cr�e la cha�ne de commande defrag.exe pour le lecteur strDrive avec le param�tre strOption
	strCommand = "defrag.exe " & strDrive & " " & Trim(strOption)

	'Configure defrag.exe en priorit� basse avec une fen�tre cach�e
	Set objConfig = objStartup.SpawnInstance_
	objConfig.ShowWindow = SW_HIDE
	objConfig.PriorityClass = IDLE_PROCESS

	'Cr�e le process defrag.exe
	Set objProcess = objWMIService.Get("Win32_Process")
	Return = objProcess.Create(strCommand, Null, objConfig, intProcessID)

	'Attendre que le process defrag.exe soit lanc�
	IsProcessRunning("defrag.exe")

	'Attendre que le process defrag.exe soit arr�t�
	WaitUntilProcessEnds("defrag.exe")

	Set objWMIService = Nothing
	Set objStartup = Nothing
	Set objConfig = Nothing
	Set objProcess = Nothing

End Sub

Sub DefragBoot()
'Une d�fragmentation normale d�fragmente le boot si la valeur Enable = Y pour cl� HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction
'Ceci force donc la d�fragmentation du boot si la valeur Enable = N pour cl� HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction

	On Error Resume Next
	Err.Clear

	'V�rifie si la d�fragmentation automatique du boot est d�sactiv�e
	If WshShell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction\Enable") <> "Y" Then
		If Err.Number = 0 Then

			'D�tecter si defrag.exe est en cours d'ex�cution avant de poursuivre
			WaitUntilProcessEnds("defrag.exe")

			'D�fragmente le Boot
			RunDefrag WshShell.ExpandEnvironmentStrings("%HOMEDRIVE%"), "-b"

		End If
	Else
		Err.Clear
	End If

	On Error Goto 0

End Sub

Sub UpDateLayout()
'Lance le processus d'optimisation du disque et �galement les processus qui sont lanc�s lorsque la machine est inactive si la sous cl� "Enable" de la cl� HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction a la valeur Y.
'Il ne s'agit pas d'une d�fragmentation compl�te mais d'une optimisation de la zone de boot pour acc�l�rer le temps de d�marrage et le temps d'acc�s au disque.
'Ceci force la mise � jour de Layout.ini utilis� par le prefetch � condition que Layout.ini ait �t� cr�� et la d�fragmentation imm�diate du boot.

	On Error Resume Next
	Err.Clear

	'V�rifie si Layout a �t� cr��
	If WshShell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction\OptimizeComplete") = "Yes" Then
		If Err.Number = 0 Then

			'V�rifie si le processus d'optimisation est d�sactiv�. Il est inutile de le lancer si il est d�j� activ� car Windows le lancera automatiquement.
			If WshShell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction\Enable") <> "Y" Then
				If Err.Number = 0 Then

					'D�tecter si Defrag.exe est en cours d'ex�cution avant de poursuivre
					WaitUntilProcessEnds("defrag.exe")

					'La d�fragmentation du boot s'effectue tous les 3 jours et n�cessite un red�marrage. Ceci force la mise � jour de Layout.ini utilis� par le prefetch. Sinon, il faut attendre 3 jours et red�marrer la machine.
					Return = WshShell.Run("Rundll32.exe advapi32.dll,ProcessIdleTasks", 0, True)

				Else
					Err.Clear
				End If
			End If
		Else
			Err.Clear
		End If
	End If

	On Error Goto 0

End Sub

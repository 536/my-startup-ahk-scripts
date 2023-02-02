#SingleInstance, Force
#NoTrayIcon

#z::
    If Not WinExist("ahk_class EVERYTHING")
        Run % "everything"
    WinActivate, ahk_class EVERYTHING
Return

#If WinActive("ahk_class EVERYTHING")
^l::
ControlFocus, Edit1, ahk_class EVERYTHING
Send, ^a
Return
!Enter::
    ControlGetText, command, Edit1
    Run, % A_ComSpec " /K cd /d " A_Desktop " && cls && " command
Return
#If

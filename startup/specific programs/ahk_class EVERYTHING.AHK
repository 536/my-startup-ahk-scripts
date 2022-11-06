#SingleInstance, Force
#NoTrayIcon

EnvGet, EVERYTHING, EVERYTHING

#z::
    If Not WinExist("ahk_class EVERYTHING")
        Run % EVERYTHING
    WinActivate, ahk_class EVERYTHING
Return

#If WinActive("ahk_class EVERYTHING")
    ^l::ControlFocus, Edit1, ahk_class EVERYTHING
!Enter::
    ControlGetText, command, Edit1
    Run, % A_ComSpec " /K cd /d " A_Desktop " && cls && " command
Return
#If

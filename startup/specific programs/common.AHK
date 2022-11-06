#SingleInstance, Force
#NoTrayIcon

GroupAdd, advanced_editors, ahk_exe Code.exe
GroupAdd, advanced_editors, ahk_exe sublime_text.exe
GroupAdd, advanced_editors, ahk_exe pycharm64.exe
GroupAdd, advanced_editors, ahk_exe webstorm64.exe
GroupAdd, advanced_editors, ahk_exe jetbrains_client64.exe
GroupAdd, advanced_editors, ahk_exe Feishu.exe

#If Not WinActive("ahk_group advanced_editors")
    ^Enter::
        Send, {End}{Enter}
        Return
    ^+Enter::
        Send, {Home}{Enter}{Left}
        Return
    ^+d::
        Send, {Home}+{End}
        Send, ^c
        Send, {End}{Enter}
        Send, ^v
        Send, {End}
        Return
    ^+k::
        Send, {Home}+{End}{BackSpace 2}{Right}{End}
        Return
    ^k::
        ErrorLevel := 0
        Hotkey, ^u, Label_Contrl_k_u, On
        Hotkey, ^l, Label_Contrl_k_l, On
        Return
#If

Label_Contrl_k_u:
    ClipboardAll_ := ClipboardAll
    If Not ErrorLevel And (A_PriorHotkey = "^k") {
        Send, ^c
        ClipWait, 0.8, 0
        If Not ErrorLevel {
            SendInput % StrReplace(Format("{:U}", Clipboard), "`r`n", "`n")
        }
    }
    Hotkey, ^u, Off
    Clipboard := ClipboardAll_
    ClipboardAll_ =
    Return
Label_Contrl_k_l:
    ClipboardAll_ := ClipboardAll
    If Not ErrorLevel And (A_PriorHotkey = "^k") {
        Send, ^c
        ClipWait, 0.8, 0
        If Not ErrorLevel {
            SendInput % StrReplace(Format("{:L}", Clipboard), "`r`n", "`n")
        }
    }
    Hotkey, ^l, Off
    Clipboard := ClipboardAll_
    ClipboardAll_ =
    Return

; HELPFILES := {"AutoHotkey.chm": "C:\\Program Files\\AutoHotkey\\AutoHotkey.chm"}

; For k, v in HELPFILES
; {
;     Label := Func("GetHelp").Bind(v, StrReplace(A_Args[1], "#", "_"))
;     Menu, Help, Add, % k, % Label
;     Menu, Help, Icon, % k, %A_WinDir%\hh.exe
; }
; Menu, Help, Show

GetHelp(GetHelpFile(), KeyWord:=A_Args[1])
Return

GetHelpFile() {
    SplitPath, A_AhkPath, , OutDir
    Return OutDir "\AutoHotkey.chm"
}

GetHelp(HelpFile, KeyWord) {
    Run, %HelpFile%, , Max, ID
    WinActivate, % "ahk_id " ID
    Sleep, 200
    Send, !s
    SendInput, {Raw}%KeyWord%
    Sleep, 100
    Send, {Enter}
    Send, {Enter}
}

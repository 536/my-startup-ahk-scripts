#SingleInstance, Force
#NoTrayIcon

;-------------------------------------------------------------------------------
^Space::WinSet, AlwaysOnTop, Toggle, A
;-------------------------------------------------------------------------------
^#c::Run, % A_ComSpec " /K cd /d " CurrentFolder(), , UseErrorLevel
^+#c::Run, % "*Runas " A_ComSpec " /K cd /d " CurrentFolder(), , UseErrorLevel
^#p::Run, % A_ComSpec " /K cd /d " CurrentFolder() " && Powershell", , UseErrorLevel
^+#p::Run, % "*Runas " A_ComSpec " /K cd /d " CurrentFolder() " && Powershell", , UseErrorLevel
;-------------------------------------------------------------------------------
^+#z::Run Explorer shell:::{ED7BA470-8E54-465E-825C-99712043E01C} ; all tasks
;-------------------------------------------------------------------------------
; ^#Left::Send, {Media_Prev} ; conflict with switching virtual desktop
; ^#Right::Send, {Media_Next} ; conflict with switching virtual desktop
;-------------------------------------------------------------------------------
^#!Up::Send, {Volume_Up}
^#!Down::Send, {Volume_Down}
^#!Left::Send, {Media_Prev}
^#!Right::Send, {Media_Next}
^#!Space::Send, {Media_Play_Pause}
^#!Enter::Send, {Media_Stop}
;-------------------------------------------------------------------------------
^+#Up::system_SetScreenBrightness(5)
^+#Down::system_SetScreenBrightness(-5)
;-------------------------------------------------------------------------------
#`::SwitchToSimilarWindow()
;===============================================================================
CurrentFolder(hWnd=0) {
    If hWnd||(hWnd:=WinExist("ahk_class CabinetWClass"))||(hWnd:=WinExist("ahk_class ExploreWClass"))
    {
        shell := ComObjCreate("Shell.Application")
        Loop, % shell.Windows.Count
            If ( (win := shell.Windows.Item(A_Index-1)).hWnd = hWnd )
            Break
        Return win.Document.Folder.Self.Path
    }
    Return "D:\"
}
SwitchToSimilarWindow() {
    MouseGetPos, , , mouse_id
    WinGetClass, mouse_class, % "ahk_id " mouse_id
    WinGet, mouse_exe, ProcessName, % "ahk_id " mouse_id

    ids := []
    titles := []
    WinGet, id, List,,, Program Manager
    Loop, %id%
    {
        this_id := id%A_Index%
        WinGet, this_exe, ProcessName, % "ahk_id " this_id
        WinGetClass, this_class, % "ahk_id " this_id
        WinGetTitle, this_title, % "ahk_id " this_id
        If (this_class = mouse_class and this_exe = mouse_exe)
        {
            ids.push(this_id)
            titles.push(this_title)
        }
    }
    index := ShowToolTip(mouse_exe, mouse_class, titles)

    key := RegExReplace(A_ThisHotKey, "[\*\~\$\#\+\!\^( UP)]")
    Loop
    {
        If !GetKeyState("LWin", "P")
        {
            ; ToolTip, % "ahk_id " ids[index] . "`n" . titles[index], 0, 300, 5
            WinActivate, % "ahk_id " ids[index]
            ToolTip
            Break
        }

        KeyWait %key%
        KeyWait %key%, D T0.2
        If !(ErrorLevel)
            index := ShowToolTip(mouse_exe, mouse_class, titles, index)
    }
}
ShowToolTip(mouse_exe, mouse_class, titles, index=1) {
    index += 1
    index := (index > titles.MaxIndex())?(index - titles.MaxIndex()):index
    ; ToolTip, % index, 0, 0, 2
    _title := mouse_exe . "`n"
    For i, title in titles
    {
        If (i = index)
            _title .= ">"
        _title .= "`t" . title . "`n"
    }
    ToolTip, % _title, , , 1
    return index
}

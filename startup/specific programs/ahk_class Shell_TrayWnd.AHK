#SingleInstance, Force
#NoTrayIcon

#If MouseIsOver("Shell_TrayWnd", "Windows.UI.Composition.DesktopWindowContentBridge2")
    ~LButton::
        hits := KeyHits()
        If (hits = 2) {
            ComObjCreate("Shell.Application").WindowSwitcher()
        }
        Return
    WheelUp::Send, {AltDown}{Esc}{AltUp}
    WheelDown::Send, {AltDown}+{Esc}{AltUp}
#If

MouseIsOver(class,control="") {
    MouseGetPos, , , MouseOverWinID, MouseOverControl
    WinGetClass, MouseOverWinClass, % "ahk_id " MouseOverWinID
    If ((MouseOverWinClass = class) && ((MouseOverControl = control) || !control))
        Return True
}

KeyHits(timeout = 0.2) {
    key := RegExReplace(A_ThisHotKey, "[\*\~\$\#\+\!\^( UP)]")
    Loop {
        KeyWait %key%
        KeyWait %key%, DT%timeout%
        If (ErrorLevel)
            Return A_Index
    }
}

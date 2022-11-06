#SingleInstance, Force
#NoTrayIcon

#If WinActive("Photo_Lightweight_Viewer") && MouseIsOver("Photo_Lightweight_Viewer","Photos_PhotoCanvas1")
    WheelUp::Send, {Left}
    WheelDown::Send, {Right}
    MButton::Send, !{F4}
    Esc::Send, !{F4}
#If

MouseIsOver(class,control="") {
    MouseGetPos, , , MouseOverWinID, MouseOverControl
    WinGetClass, MouseOverWinClass, % "ahk_id " MouseOverWinID
    If ((MouseOverWinClass = class) && ((MouseOverControl = control) || !control))
        Return True
}

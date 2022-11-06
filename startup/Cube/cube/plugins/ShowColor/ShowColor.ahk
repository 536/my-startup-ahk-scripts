#NoEnv
#SingleInstance, Off ; Can show More than one process.
#NoTrayIcon ; Don't show the menu tray icon.
CoordMode, Mouse, Client

Global color := A_Args[1] ; Get color form transfered parameter.
Global Transparent := 255

If not RegExMatch(Color, "i)^(0x|#)?([a-f0-9]){6}$")
{
    If RegExMatch(Clipboard, "i)^(0x|#)?([a-f0-9]){6}$")
        Color := Clipboard
    Else
        Gosub, getcolor ; When %1% and Clipboard don't satisfy the format, get it from user input.
}
Gosub, ShowGUI ; Show a GUI window of #color.

OnMessage(0x201, "WM_LBUTTONDOWN")   ; Listening to the LButton Down event.
; OnMessage(0x202, "WM_LBUTTONUP")     ; Listening to the LButton Up event.
OnMessage(0x203, "WM_LBUTTONDBLCLK") ; Listening to the LButton DoubleClick event.
OnMessage(0x205, "WM_RBUTTONDOWN")   ; Listening to the RButton Down event.
OnMessage(0x206, "WM_RBUTTONDBLCLK") ; Listening to the RButton DoubleClick event.
OnMessage(0x207, "WM_MBUTTONDOWN")   ; Listening to the MButton Down event.
OnMessage(0x20A, "WM_MOUSEWHEEL")    ; Listening to the WM_MOUSEWHEEL event.
Return

WM_LBUTTONDOWN() {
    SendMessage, 0xA1, 2
}
WM_LBUTTONDBLCLK() {
    Gui, -AlwaysOnTop ; Avoid block the inputbox.
    color1 := color
    Gosub, getcolor
    If (color1 != color)
    {
        Gui, Color, % color
    }
    Gui, +AlwaysOnTop ; Avoid block the inputbox.
}
WM_RBUTTONDOWN() {
    MouseGetPos, , , id
    Clipboard := color ; Give color to clipboard.
    If (Clipboard = color)
    {
        WinActivate, % "ahk_id " id
        ToolTip, % "Color: " Clipboard, 0, 0
        SetTimer, Label_RemoveToolTip, 1000
    }
    ToolTip
}
WM_RBUTTONDBLCLK() {
    WinGet, ExStyle, ExStyle
    if (ExStyle & 0x08000000)
        Gui +Resize -E0x08000000
    Else
        Gui -Resize +E0x08000000
}
WM_MBUTTONDOWN() {
    ExitApp
}
WM_MOUSEWHEEL(wParam, lParam) {
    MouseGetPos, , , id
    WinGet, Transparent, Transparent, % "ahk_id " id
    If Not Transparent
        Transparent := 250
    ; wheelUp
    If (wParam = 0x780000)
    {
        setTransparent(id,Transparent+5)
        If (Transparent = 255)
            WinSet, Transparent, Off, ahk_id %id%
    }
    ; wheelDown
    Else If (wParam = 0xff880000)
    {
        If (Transparent < 10)
            Transparent := 10

        setTransparent(id,Transparent-5)
    }
    Else
        Msgbox % "Unknown wParam: " wParam
}
setTransparent(id,Transparent) {
    WinSet, Transparent, % Transparent, % "ahk_id " id
    WinGet, Transparent, Transparent, % "ahk_id " id
    WinActivate, % "ahk_id " id
    ToolTip Translucency:`t%Transparent%, 0, 0
    SetTimer, Label_RemoveToolTip, 3000
}

ShowGUI:
    Gui, +AlwaysOnTop +E0x08000000 -Caption +ToolWindow +OwnDialogs
    RegExMatch(color, "i)([a-f0-9]){6}",color)
    Gui, Color, % color
    Gui, Show, w160 h90
    Return

getcolor:
    ; Default color value "2093ff".
    InputBox, color,, % "Please input a color value!", , , , , , , , % color?color:"2093ff"
    ; If the input value doesn't match the format, get it again.
    If ErrorLevel
        Return
    If not RegExMatch(color, "i)^(0x|#)?([a-f0-9]){6}$") {
        Gosub, getcolor
    }
    Return

Label_RemoveToolTip:
    SetTimer, % A_ThisLabel, Off
    ToolTip
    Return

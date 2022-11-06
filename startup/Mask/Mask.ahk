#NoTrayIcon
#NoEnv
#SingleInstance force

global WIN := GUI_show("wallpaper.jpg")
Return

GUI_show(p, t=10) {
    If FileExist(p)
    {
        Gui Destroy
        Gui Margin, 0, 0
        Gui +AlwaysOnTop +Owner -Caption +ToolWindow -DPIScale +OwnDialogs +HwndWIN +E0x08000000 +E0x20

        Try
        {
            If FileExist(p)
                Gui Add, Picture, W%A_ScreenWidth% H%A_ScreenHeight% Center, % p
            Else If RegExMatch(p, "^#?([a-fA-F0-9]{6}|[a-fA-F0-9]{3})$")
                Gui Color, % SubStr(p, -5)
            Else
                Throw
        }
        Catch
        {
            TrayTip, , % "Falied creating GUI.", 3000, 3
            ExitApp, -1
        }

        TrayTip, % A_ScriptName, % "Enjoy it!", 3000, 1
        Gui Show, W1 H1
        WinSet, Transparent, % t, % "ahk_id " WIN
        Gui Show, W%A_ScreenWidth% H%A_ScreenHeight% X0 Y0
        Return WIN
    }
}
Transparency_plus(win, step) {
    WinGet, vTransparent, Transparent, % "ahk_id " win
    If Not vTransparent
        vTransparent := 255
    If (vTransparent >= 255 - step)
    {
        WinSet, Transparent, Off, % "ahk_id " win
        Return 255
    }
    Else
    {
        vTransparent += step
        WinSet, Transparent, % vTransparent, % "ahk_id " win
        Return vTransparent
    }
}
Transparency_minus(win, step) {
    WinGet, vTransparent, Transparent, % "ahk_id " win
    If Not vTransparent
        vTransparent := 255
    If (vTransparent <= step)
    {
        WinSet, Transparent, % step, % "ahk_id " win
        Return step
    }
    Else
    {
        vTransparent -= step
        WinSet, Transparent, % vTransparent, % "ahk_id " win
        Return vTransparent
    }
}

WM_LBUTTONDOWN() {
    static ____ = OnMessage(0x201, "WM_LBUTTONDOWN")
    SendMessage, 0xA1, 2
}
WM_LBUTTONDBLCLK() {
    static ____ = OnMessage(0x203, "WM_LBUTTONDBLCLK")
    global LB_RESIZE
    If LB_RESIZE
        Gui -Resize
    Else
        Gui +Resize
    LB_RESIZE := !LB_RESIZE
}
WM_MBUTTONDOWN() {
    static ____ = OnMessage(0x207, "WM_MBUTTONDOWN")
    TrayTip, , % A_ScriptName . " exit!", 3000, 2
    ExitApp, 0
}
WM_MOUSEWHEEL(wParam, lParam) {
    static ____ = OnMessage(0x20A, "WM_MOUSEWHEEL")
    If (wParam == 0x780000) ; wheelUp
        Transparency_plus(WIN, 5)
    Else If (wParam == 0xff880000) ; wheelDown
        Transparency_minus(WIN, 5)
}
GuiDropFiles(GuiHwnd, FileArray, CtrlHwnd, X, Y) {
    for i, file in FileArray
        GUI_show(file, A_Args[2])
}

^F11::WinSet, ExStyle, ^0x20, % "ahk_id " WIN

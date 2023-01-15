#NoEnv
#NoTrayIcon
#SingleInstance force

global WIN := show(A_Args[1])
Return

show(p, trans=30) {
    Gui Destroy
    Gui Margin, 0, 0
    Gui +AlwaysOnTop +Owner -Caption +ToolWindow -DPIScale +OwnDialogs +HwndID +E0x08000000 +E0x20

    If FileExist(p)
        Gui Add, Picture, W%A_ScreenWidth% H%A_ScreenHeight% Center, % p
    Else If RegExMatch(p, "^#?([a-fA-F0-9]{6}|[a-fA-F0-9]{3})$")
        Gui Color, % SubStr(p, -5)
    Else
        ExitApp, -1

    Gui Show, W1 H1
    WinSet, Transparent, % trans, % "ahk_id " ID
    Gui Show, W%A_ScreenWidth% H%A_ScreenHeight% X0 Y0
    Return ID
}

WM_LBUTTONDOWN() {
    static ____ = OnMessage(0x201, "WM_LBUTTONDOWN")
    SendMessage, 0xA1, 2
}
; WM_LBUTTONDBLCLK() {
;     static ____ = OnMessage(0x203, "WM_LBUTTONDBLCLK")
; }
WM_MBUTTONDOWN() {
    static ____ = OnMessage(0x207, "WM_MBUTTONDOWN")
    ExitApp, 0
}
WM_MOUSEWHEEL(wParam, lParam) {
    static ____ = OnMessage(0x20A, "WM_MOUSEWHEEL")
    static STEP = 5

    WinGet, vTransparent, Transparent, % "ahk_id " WIN
    If Not vTransparent
        vTransparent := 255

    If (wParam == 0x780000) ; wheelUp
    {
        If (vTransparent >= 255 - STEP)
            WinSet, Transparent, Off, % "ahk_id " WIN
        Else
            vTransparent += STEP
    }
    Else If (wParam == 0xff880000) ; wheelDown
    {
        If (vTransparent <= STEP)
            WinSet, Transparent, % STEP, % "ahk_id " WIN
        Else
            vTransparent -= STEP
    }
    WinSet, Transparent, % vTransparent, % "ahk_id " WIN
}

^F11::WinSet, ExStyle, ^0x20, % "ahk_id " WIN

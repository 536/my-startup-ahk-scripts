#NoEnv
#SingleInstance, force
#NoTrayIcon

SetWinDelay, -1
DetectHiddenWindows, Off
CoordMode, Mouse

~LButton & RButton::
    If WinActive("ahk_class WorkerW") ; except desktop
        Return
    If WinActive("Windows.UI.Core.CoreWindow","") ; except start menu
        Return

    MouseGetPos, M_O_x, M_O_y, Win ; get mouse origin position
    WinGetPos, W_O_x, W_O_y,,, % "ahk_id " Win ; get window origin position

    WinGet, min_max_state, MinMax, % "ahk_id " Win
    If min_max_state = 0 ; only when the window is neither minimized nor maximized.
        SetTimer, WinMove, 10 ; moving
Return

WinMove:
    If !GetKeyState("LButton", "P") ; LButton released, finish moving
    {
        SetTimer, WinMove, Off
        Return
    }
    If GetKeyState("Escape", "P") ; Escape pressed, move back to origin position
    {
        SetTimer, WinMove, Off
        WinMove, % "ahk_id " Win,, %W_O_x%, %W_O_y%
        Return
    }

    MouseGetPos, M_F_x, M_F_y
    WinGetPos, W_F_x, W_F_y,,, % "ahk_id " Win
    WinMove, % "ahk_id " Win,, W_F_x + M_F_x - M_O_x, W_F_y + M_F_y - M_O_y
    M_O_x := M_F_x ; refresh mouse position
    M_O_y := M_F_y
Return

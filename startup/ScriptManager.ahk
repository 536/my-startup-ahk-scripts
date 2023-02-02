#NoEnv
#SingleInstance force
DetectHiddenWindows On
SetTitleMatchMode RegEx

Menu, Tray, UseErrorLevel
Menu, Tray, Icon, imageres.dll,307

Loop, Parse, % "Path||Edit|Reload||Pause|Suspend||Exit||History|Variables|HotKeys|Info", |
{
    Menu, LV_Menu, Add, % A_LoopField, MenuHandler
    If (A_LoopField == "Path")
        Menu, LV_Menu, Icon, % A_LoopField, imageres.dll,266
    If (A_LoopField == "Edit")
    {
        RegRead, EDOTOR, % "HKCR\AutoHotkeyScript\Shell\Edit\Command"
        Menu, LV_Menu, Icon, % A_LoopField, % Substr(RegExReplace(EDOTOR, "\.exe.*$", ".exe"), 2)
    }
    If (A_LoopField == "Reload")
        Menu, LV_Menu, Icon, % A_LoopField
    If (A_LoopField == "Suspend")
        Menu, LV_Menu, Icon, % A_LoopField
    If (A_LoopField == "Pause")
        Menu, LV_Menu, Icon, % A_LoopField
    If (A_LoopField == "Exit")
        Menu, LV_Menu, Icon, % A_LoopField, imageres.dll,162
    If (A_LoopField == "Info")
        Menu, LV_Menu, Icon, % A_LoopField, imageres.dll,77
}
SetTimer, Label_LV_REFRESH, 500
OnMessage(0x404, "AHK_NOTIFYICON")
Return

ShowGUI:
    Gui +OwnDialogs +HwndHWND -DPIScale +Resize -MinimizeBox
    Gui Margin, 0, 0
    Gui Font, , Consolas
    Gui Add, ListView, Grid vListview gLV_Event, HWND|PID|Pause|Suspend|ScriptFullPath
    Gui Show, w1300 h450 Center
    ListViewInfo :=
Return

Label_LV_REFRESH:
    If Not WinExist("ahk_id " HWND)
        Return

    ProcessInfo := GetProcessInfo()
    If IsStateChanged(ProcessInfo, ListViewInfo)
    {
        ListViewInfo := ProcessInfo
        LV_COUNT := LV_GetCount()
        GuiControl, -Redraw, MyListView ; 在加载时禁用重绘来提升性能.
        LV_Delete() ; 清空
        Loop % ListViewInfo.MaxIndex()
        {
            Info := ListViewInfo[A_Index]
            LV_Add("", Info["HWND"], Info["PID"], Info["State"]["Pause"], Info["State"]["Suspend"], Info["ScriptFullPath"])
        }
        LV_ModifyCol(1, "AutoHdr")
        LV_ModifyCol(2, "AutoHdr")
        LV_ModifyCol(3, "AutoHdr")
        LV_ModifyCol(4, "AutoHdr")
        LV_ModifyCol(5, "Auto")
        GuiControl, +Redraw, MyListView ; 重新启用重绘 (上面把它禁用了).
    }
Return

LV_Event:
    If A_EventInfo
    {
        If (A_GuiEvent == "DoubleClick")
            MenuHandler(ItemName := "Exit")
        Else If (A_GuiEvent == "RightClick")
            Menu, LV_Menu, Show
    }
Return

GuiSize:
    GuiControl, Move, ListView, W%A_GuiWidth% H%A_GuiHeight%
Return

GuiClose:
GuiEscape:
    Gui, Destroy
Return

GetSelectedIDS(IDIndex := 1) {
    RowNumber := 0
    IDList := []
    Loop
    {
        RowNumber := LV_GetNext(RowNumber)
        If Not RowNumber
            Break
        LV_GetText(ID, RowNumber, IDIndex)
        IDList[A_Index] := ID
    }
Return IDList
}

MenuHandler(ItemName := "", ItemPos := "", MenuName := "") {
    Static cmd := { Reload : 65303
        , Suspend : 65305
        , Pause : 65306
        , Exit : 65307
        , Edit : 65401
        , History : 65406
        , Variables : 65407
        , HotKeys : 65408
    , Info : 65409 }

    SelectedIDS := GetSelectedIDS()
    Loop % SelectedIDS.MaxIndex()
    {
        this_id := SelectedIDS[A_Index]
        If Not WinExist("ahk_id " this_id)
        {
            MsgBox, 262192, , % "ahk_id " this_id " doesn't exist!"
            Return
        }
        If (ItemName == "Path")
        {
            global ListViewInfo
            For k, v in ListViewInfo
            {
                If (v["HWND"] == this_id)
                {
                    SplitPath, % v["ScriptFullPath"], , OutDir
                    Run % OutDir
                    Break
                }
            }
        }
        Else
            SendMessage, 0x111, % cmd[ItemName], , , % " ahk_id " this_id
    }
}

GuiContextMenu(GuiHwnd, CtrlHwnd) {
    If LV_GetNext()
        Menu, LV_Menu, Show
}

GetScriptState(HWND) {
    static ID_FILE_PAUSE := 65403
    static ID_FILE_SUSPEND := 65404

    static WM_ENTERMENULOOP := 0x211
    static WM_EXITMENULOOP := 0x212
    SendMessage WM_ENTERMENULOOP, ,,, % "ahk_id " HWND
    SendMessage WM_EXITMENULOOP, ,,, % "ahk_id " HWND

    mainMenu := DllCall("GetMenu", "ptr", HWND)
    fileMenu := DllCall("GetSubMenu", "ptr", mainMenu, "int", 0)
    STATE_PAUSE := DllCall("GetMenuState", "ptr", fileMenu, "uint", ID_FILE_PAUSE, "uint", 0)
    If (STATE_PAUSE == -1)
        Return -1
    STATE_PAUSE := STATE_PAUSE >> 3 & 1
    STATE_SUSPEND := DllCall("GetMenuState", "ptr", fileMenu, "uint", ID_FILE_SUSPEND, "uint", 0)
    STATE_SUSPEND := STATE_SUSPEND >> 3 & 1
    DllCall("CloseHandle", "ptr", fileMenu)
    DllCall("CloseHandle", "ptr", mainMenu)
Return {"Suspend": STATE_SUSPEND, "Pause": STATE_PAUSE}
}

IsStateChanged(ProcessInfo, ListViewInfo) {
    If (ProcessInfo.Length() != ListViewInfo.Length())
        Return True
    Else
    {
        For index, l_v in ListViewInfo
        {
            StateChanged := True
            For index, p_v in ProcessInfo
            {
                If (l_v["PID"] == p_v["PID"])
                    And (l_v["State"]["Suspend"] == p_v["State"]["Suspend"])
                And (l_v["State"]["Pause"] == p_v["State"]["Pause"])
                {
                    StateChanged := False
                    Break
                }
            }
            If StateChanged
                Return True
        }
    }
Return False
}

GetProcessInfo() {
    ProcessInfo := []
    WinGet, id, List, % "i)^(\w:.+\.ahk)\s\-\sAutoHotkey\sv[\d\.]+$"
    Loop, %id%
    {
        this_id := id%A_Index%
        If (this_id = A_ScriptHwnd)
            Continue
        WinGet, this_pid, PID, % "ahk_id " this_id
        WinGetTitle, this_title, % "ahk_id " this_id
        If RegExMatch(this_title, "i)^(\w:.+\.ahk)\s\-\sAutoHotkey\sv[\d\.]+$", ScriptFullPath)
        {
            ProcessInfo.Push({"State": GetScriptState(this_id)
                , "HWND": "0x" . Format("{:U}", SubStr(this_id, 3))
                , "PID": this_pid
            , "ScriptFullPath": ScriptFullPath1})
        }
    }
Return ProcessInfo
}

AHK_NOTIFYICON(wParam, lParam) {
    Static WM_USER = 0x0400 ; https://docs.microsoft.com/en-us/windows/win32/winmsg/wm-user
    Static WM_LBUTTONUP = 0x202
    Static _______ := OnMessage(WM_USER + 4, "AHK_NOTIFYICON")
    If (lParam = WM_LBUTTONUP)
        show()
}

show() {
    global HWND
    If WinExist("ahk_id " HWND)
        Gui, Destroy
    Else
        Gosub, ShowGUI
}

; #`::show()

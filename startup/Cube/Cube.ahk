#Include, .\cube\settings.ahk
#NoTrayIcon
#Persistent
#SingleInstance, force

SetWorkingDir % A_ScriptDir
SetCapsLockState, AlwaysOff
Menu, Tray, NoStandard
Menu, Menu, UseErrorLevel

SplitPath, A_ScriptFullPath, CubeFileName, CubeDir, CubeExtension, CubeNameNoExt, CubeDrive
global CubeFileName, CubeDir, CubeExtension, CubeNameNoExt, CubeDrive
global CubePathIcons := A_ScriptDir . "\" . CubeNameNoExt . "\icons\"
global CubePathMenus := A_ScriptDir . "\" . CubeNameNoExt . "\menus\"
global CubePathPlugins := A_ScriptDir . "\" . CubeNameNoExt . "\plugins\"
global Cube_Bases, Cube_Ext, Cube_RE, Cube_Translations
global Cube, CubeTypes
global CubeAutoClip
global CubeIcon
global CubeIconSize := A_ScreenDPI / 6

Gosub, Label_SetAuto
Gosub, Label_CreateMenu_RE
Gosub, Label_CreateMenu_Ext
Gosub, Label_CreateMenu_Bases
Return

Label_SetAuto:
    CubeAutoClip := !CubeAutoClip
    CubeIcon := CubePathIcons . (CubeAutoClip?"on":"off") ".png"
    Menu, Tray, Icon, % CubeIcon, , % CubeIconSize
Return

Label_CreateMenu_RE:
    For REType, Regulations in Cube_RE
    {
        For Index, Line in IniRead(GetMenuPath("RE\" . REType))
        {
            Label := Func("Cube_Run").Bind(Line[2])
            Menu, % REType, Add, % Line[1], % Label
            Menu, % REType, Icon, % Line[1], % GetIcon(Line), , % CubeIconSize
        }
    }
Return

Label_CreateMenu_Ext:
    For Extension, ExtensionTypes in Cube_Ext
    {
        For Index, Line in IniRead(GetMenuPath("Ext\" . Extension))
        {
            Label := Func("Cube_Run").Bind(Line[2])
            Menu, % Extension, Add, % Line[1], % Label
            Menu, % Extension, Icon, % Line[1], % GetIcon(Line), , % CubeIconSize
        }

        For Index, ExtensionType in ExtensionTypes
        {
            If (DllCall("GetMenuItemCount", "ptr", MenuGetHandle(ExtensionType)) < 1)
            {
                For Index, Line in IniRead(GetMenuPath(ExtensionType))
                {
                    Label := Func("Cube_Run").Bind(Line[2])
                    Menu, % ExtensionType, Add, % Line[1], % Label
                    Menu, % ExtensionType, Icon, % Line[1], % GetIcon(Line), , % CubeIconSize
                }
            }
        }
    }
Return

Label_CreateMenu_Bases:
    For Index, Base in Cube_Bases
    {
        For Index, Line in IniRead(GetMenuPath(Base))
        {
            Label := Func("Cube_Run").Bind(Line[2])
            Menu, % Base, Add, % Line[1], % Label
            If Line[1]
                Menu, % Base, Icon, % Line[1], % GetIcon(Line), , % CubeIconSize
        }
    }
Return

IniRead(ini, section:="Cube") {
    Commands := []
    IniRead, SectionContents, % ini, % section
    Loop, parse, SectionContents, `n, `r ; 在 `r 之前指定 `n, 这样可以同时支持对 Windows 和 Unix 文件的解析.
    {
        Commands.push(StrSplit(A_LoopField, "=", 1))
    }
Return Commands
}

Cube_Run(IniValue, ItemName, ItemPos, MenuName) {
    If GetKeyState("Ctrl", "P")
    {
        Run, % "Edit " GetPluginPath(IniValue)
        Return
    }
    Else
    {
        For k, v in Cube_URL
        {
            If (k = IniValue)
            {
                Run, % StrReplace(v, "%s", Cube)
                Return
            }
        }
    }
    SplitPath, % GetPluginPath(IniValue), OutFileName, OutDir
    Run, % GetPluginPath(IniValue), % OutDir, UseErrorLevel, OutputVarPID
    ; If (ErrorLevel = 0)
    ; {
    ;     VarSetCapacity(CubeStruct, 3*A_PtrSize, 0)
    ;     CubeInBytes := (StrLen(Cube)+1)*(A_IsUnicode?2:1)
    ;     NumPut(CubeInBytes, CubeStruct, A_PtrSize)
    ;     NumPut(&Cube, CubeStruct, 2*A_PtrSize)
    ;     static WM_COPYDATA := 0x004A
    ;     WinWait, % "ahk_pid " OutputVarPID
    ;     SendMessage, WM_COPYDATA, 0, &CubeStruct,, % "ahk_pid " OutputVarPID
    ; }
}

GetPluginPath(PluginName) {
    If FileExist(CubePathPlugins . PluginName . "\" . PluginName . ".ahk")
        Return """" CubePathPlugins . PluginName . "\" . PluginName . ".ahk"""
}
GetMenuPath(Type) {
Return CubePathMenus . Type . ".ini"
}
GetIcon(icon) {
    If (icon = ".ico")
        Return Cube
    Else If FileExist(CubePathPlugins . icon[2] . "\" . icon[2] . ".ico")
        Return CubePathPlugins . icon[2] . "\" . icon[2] . ".ico"
    Else If FileExist(CubePathIcons . "\menus\" . icon . ".ico")
        Return CubePathIcons . "\menus\" . icon . ".ico"
    Else If FileExist(CubePathIcons . "\urls\" . icon[2] . ".ico")
        Return CubePathIcons . "\urls\" . icon[2] . ".ico"
    Else If FileExist(CubePathIcons . "\urls\" . icon[2] . ".png")
        Return CubePathIcons . "\urls\" . icon[2] . ".png"
    Else
    {
        VarSetCapacity(FileInfo, FileSize:=A_PtrSize + 688) ;为 SHFILEINFOW 结构体申请内存.
        If DllCall("shell32\SHGetFileInfoW", "Wstr", Cube, "UInt", 0, "Ptr", &FileInfo, "UInt", FileSize, "UInt", 0x110)
            Return % "HICON:" NumGet(FileInfo, 0, "Ptr")
    }
}

CapsLock Up::
    If CubeAutoClip
    {
        Clipboard := ""
        Send, ^c
        ClipWait, 0.5, 0
        If Not ErrorLevel
            Gosub, Label_ShowMenu
    }
    else
        Gosub, Label_ShowMenu
Return
+CapsLock::Gosub, Label_SetAuto
^CapsLock::SetCapsLockState % !GetKeyState("CapsLock", "T")

Label_ShowMenu:
    If (Cube != Trim(Clipboard, " `t`n"))
    {
        Cube := Trim(Clipboard, " `t`n")
        GetCubeTypes()
    }
    Menu, Menu, Show
Return

GetCubeTypes() {
    CubeTypes := []
    If Not Cube
        Return
    Else If DllCall("IsClipboardFormatAvailable", "UInt", 15) ; file
    {
        CubeTypes.push("FILE")
        If InStr(FileExist(Cube), "D")
        {
            CubeTypes.push(RegExMatch(Cube,"^.:\\$") ? "DRIVE":"FOLDER")
            Return OrganizeMenu()
        }
        If InStr(Cube, "`n")
        {
            CubeTypes.push("FILES")
            Return OrganizeMenu()
        }
        SplitPath, Cube, , , OutExtension
        If OutExtension
        {
            For Extension, ExtensionTypes in Cube_Ext
            {
                If ("." OutExtension = Extension)
                {
                    CubeTypes.push(Extension)
                    For Index, ExtensionType in ExtensionTypes
                        CubeTypes.push(ExtensionType)
                    Return OrganizeMenu()
                }
            }
        }
        Return OrganizeMenu()
    }
    Else If DllCall("IsClipboardFormatAvailable", "UInt", 1) ; text
    {
        CubeTypes.push("TEXT")
        If InStr(Cube, "`n")
        {
            CubeTypes.push("TEXTS")
            Return OrganizeMenu()
        }
        For REType, Regulations in Cube_RE
        {
            For Index, Regulation in Regulations
            {
                If RegExMatch(Cube, Regulation)
                {
                    CubeTypes.push(REType)
                    Return OrganizeMenu()
                }
            }
        }
        Return OrganizeMenu()
    }
}

OrganizeMenu() {
    Menu, Menu, Add
    Menu, Menu, DeleteAll
    FirstMenuName := (StrLen(Cube) > 17)?SubStr(Cube, 1, 17) . "...":Cube
    Menu, Menu, Add, % FirstMenuName, OnExit
    Menu, Menu, Disable, % FirstMenuName
    Menu, Menu, Icon, % FirstMenuName, % CubeIcon, , % CubeIconSize
    Menu, Menu, Add
    For Index, CubeType in CubeTypes
    {
        MenuItemName := Cube_Translations[CubeType]
        MenuItemName := MenuItemName?MenuItemName:CubeType
        Menu, Menu, Add, % MenuItemName, % ":" CubeType
        Menu, Menu, Icon, % MenuItemName, % GetIcon(CubeType), , % CubeIconSize
        If (Index != CubeTypes.Length())
            Menu, Menu, Add
    }
}

AHK_NOTIFYICON(wParam, lParam) {
    Static WM_USER = 0x0400
    Static WM_LBUTTONUP = 0x0202
    Static WM_RBUTTONUP = 0x0205
    Static WM_MBUTTONUP = 0x0208
    Static _______ := OnMessage(WM_USER + 4, "AHK_NOTIFYICON")
    If (lParam = WM_LBUTTONUP)
        Run, % CubeDir
    Else If (lParam = WM_RBUTTONUP)
        Gosub, Label_SetAuto
    Else If (lParam = WM_MBUTTONUP)
        Reload
}

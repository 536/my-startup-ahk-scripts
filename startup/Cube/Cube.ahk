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
global Cube_Bases, Cube_Ext, Cube_RE
global Cube, CubeTypes
global CubeAutoClip
global CubeIcon
global CubeIconSize := A_ScreenDPI / 6

MenuState()
InitMenuRe()
InitMenuExt()
InitMenuBases()

OnClipboardChange("ShowMenu")
Return

MenuState() {
    CubeAutoClip := !CubeAutoClip
    CubeIcon := CubePathIcons . (CubeAutoClip?"on":"off") ".png"
    Menu, Tray, Icon, % CubeIcon, , % CubeIconSize
}

InitMenuRe() {
    For REType, Regulations in Cube_RE
    {
        For Index, Line in IniRead(GetMenuPath("RE\" . REType))
        {
            Label := Func("CubeRun").Bind(Line[2])
            Menu, % REType, Add, % Line[1], % Label
            Menu, % REType, Icon, % Line[1], % GetIcon(Line), , % CubeIconSize
        }
    }
}

InitMenuExt() {
    For Extension, ExtensionTypes in Cube_Ext
    {
        For Index, Line in IniRead(GetMenuPath("Ext\" . Extension))
        {
            Label := Func("CubeRun").Bind(Line[2])
            Menu, % Extension, Add, % Line[1], % Label
            Menu, % Extension, Icon, % Line[1], % GetIcon(Line), , % CubeIconSize
        }

        For Index, ExtensionType in ExtensionTypes
        {
            If (DllCall("GetMenuItemCount", "ptr", MenuGetHandle(ExtensionType)) < 1)
            {
                For Index, Line in IniRead(GetMenuPath(ExtensionType))
                {
                    Label := Func("CubeRun").Bind(Line[2])
                    Menu, % ExtensionType, Add, % Line[1], % Label
                    Menu, % ExtensionType, Icon, % Line[1], % GetIcon(Line), , % CubeIconSize
                }
            }
        }
    }
}

InitMenuBases() {
    For Index, Base in Cube_Bases
    {
        For Index, Line in IniRead(GetMenuPath(Base))
        {
            Label := Func("CubeRun").Bind(Line[2])
            Menu, % Base, Add, % Line[1], % Label
            If Line[1]
                Menu, % Base, Icon, % Line[1], % GetIcon(Line), , % CubeIconSize
        }
    }
}

IniRead(ini, section:="Cube") {
    Commands := []
    IniRead, SectionContents, % ini, % section
    Loop, parse, SectionContents, `n, `r ; 在 `r 之前指定 `n, 这样可以同时支持对 Windows 和 Unix 文件的解析.
    {
        Commands.push(StrSplit(A_LoopField, "=", 1))
    }
    Return Commands
}
CubeRun(IniValue, ItemName, ItemPos, MenuName) {
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
GetCubeTypes() {
    CubeTypes := []
    If DllCall("IsClipboardFormatAvailable", "UInt", 15) ; file
    {
        If InStr(FileExist(Cube), "D")
            CubeTypes.push("FOLDER")
        CubeTypes.push("FILE")
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
                }
            }
        }
    }

    CubeTypes.push("TEXT")
    If DllCall("IsClipboardFormatAvailable", "UInt", 1) ; text
    {
        For REType, Regulations in Cube_RE
        {
            For Index, Regulation in Regulations
            {
                If RegExMatch(Cube, Regulation)
                    CubeTypes.push(REType)
            }
        }
    }
    Return OrganizeMenu()
}

OrganizeMenu() {
    Menu, Menu, Add
    Menu, Menu, DeleteAll
    For Index, CubeType in CubeTypes
    {
        MenuItemName := (StrLen(Cube) > 17)?"..." . SubStr(Cube, -16, 17):Cube
        MenuItemName := "[" . CubeType . "]`t" . MenuItemName
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
        MenuState()
    Else If (lParam = WM_MBUTTONUP)
        Reload
}

ShowMenu() {
    If GetKeyState("CapsLock", "P")
    {
        If (Cube != Trim(Clipboard, " `t`n"))
        {
            Cube := Trim(Clipboard, " `t`n")
            GetCubeTypes()
        }
        Menu, Menu, Show
    }
}

~CapsLock::^c
+CapsLock::MenuState()
^CapsLock::SetCapsLockState % !GetKeyState("CapsLock", "T")

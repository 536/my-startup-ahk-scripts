#NoEnv
#SingleInstance, force

SetWorkingDir % A_ScriptDir
SetCapsLockState, AlwaysOff

Menu, Tray, NoMainWindow
Menu, Tray, Icon, % "icons\images.dll\imageres-234.ico"
Menu, MainMenu, UseErrorLevel

Global Cube, CubeBefore
Global Settings := IniReadSections("settings.ini")
Return
;===============================================================================
class Config
{
    __New(Ini)
    {
        this.Ini := Ini

        this.sections := {}
        IniRead, OutputVarSectionNames, % this.Ini
        this.SectionNames := StrSplit(OutputVarSectionNames, "`n")
        For _, SectionName in this.SectionNames
        {
            IniRead, Section, % this.Ini, % this.SectionName
            this.sections[this.SectionName] := StrSplit(Section, "`n")
        }
    }

    ReadArrayValue(Section)
    {
        Array := {}
        For _, Line in this.sections[Section]
        {
            KeyValue := StrSplit(Line, "=", 1)
            If !(Array.HasKey(KeyValue[1]))
            {
                Array[KeyValue[1]] := []
            }
            Array[KeyValue[1]].Push(KeyValue[2])
        }
        Return Array
    }
}
;===============================================================================
TrayIconMessage(wParam, lParam) {
    Static WM_USER = 0x0400
    Static WM_LBUTTONUP = 0x0202
    Static WM_RBUTTONUP = 0x0205
    Static WM_MBUTTONUP = 0x0208
    static ____________ = OnMessage(WM_USER + 4, "TrayIconMessage")
    If (lParam = WM_LBUTTONUP) {
        SplitPath, % A_ScriptFullPath, , OutDir
        Run, % OutDir
    } Else If (lParam = WM_MBUTTONUP) {
        Reload
    }
}
;===============================================================================
IniReadSections(IniFile) {
    Sections := {}
    IniRead, OutputVarSectionNames, % IniFile
    SectionNames := StrSplit(OutputVarSectionNames, "`n")
    For _, SectionName in SectionNames
    {
        IniRead, Section, % IniFile, % SectionName
        Sections[SectionName] := StrSplit(Section, "`n")
    }

    Return {Sections: Sections, SectionNames: SectionNames}
}
IniReadArrayValue(section) {
    Array := {}
    For _, Line in Settings.Sections[section]
    {
        KeyValue := StrSplit(Line, "=", 1)
        If !(Array.HasKey(KeyValue[1]))
        {
            Array[KeyValue[1]] := []
        }
        Array[KeyValue[1]].Push(KeyValue[2])
    }
    Return Array
}
;===============================================================================
MenuCreate()
{
    For _, SectionName in Settings.SectionNames
    {
        If RegExMatch(SectionName, "^Menu\.(\w+(\.)?)+")
        {
            Menu, % SectionName, Add
            Menu, % SectionName, DeleteAll
            SubMenu := false
            For _, Line in Settings.Sections[SectionName]
            {
                KeyValue := StrSplit(Line, "=", 1)
                If (SubStr(KeyValue[1], 1, 1) = ">")
                {
                    MenuName := SubStr(KeyValue[1], 2)
                    If MenuName
                    {
                        If KeyValue[2]
                        {
                            Label := Func("MenuRun").Bind(KeyValue[2])
                            Menu, % SectionName SubMenu, Add, % MenuName, % Label
                            Menu, % SectionName SubMenu, Icon, % MenuName, % GetPluginIcon(KeyValue[2])
                        }
                        Else
                        {
                            SubMenu := KeyValue[1]
                        }
                    }
                    Else
                    {
                        Menu, % SectionName SubMenu, Add
                    }
                }
                Else
                {
                    If SubMenu
                    {
                        Menu, % SectionName, Add, % SubStr(SubMenu, 2), % ":" SectionName SubMenu
                    }
                    SubMenu := false
                    Label := Func("MenuRun").Bind(KeyValue[2])
                    ; SectionName: Menu.Folder
                    ; KeyValue[1]: Edit by &SublimeText
                    ; KeyValue[2]: [SublimeText]([sublime_text.ico])?...
                    Menu, % SectionName, Add, % KeyValue[1], % Label
                    Menu, % SectionName, Icon, % KeyValue[1], % GetPluginIcon(KeyValue[2])
                }
            }
        }
    }
}
MenuRun(IniValue, ItemName, ItemPos, MenuName) {
    ; MsgBox % "IniValue: " IniValue "`nItemName: " ItemName "`nItemPos: " ItemPos "`nMenuName: " MenuName
    ; IniValue: [AHKHelp]([AHKHelp.ico])?...
    ; ItemName: AHK &Help
    ; ItemPos: 3
    ; MenuName: Menu.Text
    If RegExMatch(IniValue, "O)^\[(?<NAME>.+?)\](\[(?<ICON>.+?)\])?(?<PARAMETER>.+)?$", Out)
    {
        EnvGet, PathExt, PATHEXT
        PathExt := StrSplit(PathExt ";.AHK", ";")
        For i, Ext in PathExt
        {
            PluginPath := A_ScriptDir "\plugins\" Out["NAME"] "\" Out["NAME"] Ext
            If FileExist(PluginPath)
            {
                OutPluginDir := A_ScriptDir "\plugins\" Out["NAME"]

                If GetKeyState("Shift", "P") {
                    Run, % "*RunAs " PluginPath " " Out["PARAMETER"] " " Cube, % OutPluginDir, UseErrorLevel
                } Else If GetKeyState("Ctrl", "P") {
                    Run, % "Edit " PluginPath, % OutPluginDir, UseErrorLevel
                } Else {
                    Run, % PluginPath " " Out["PARAMETER"] " " Cube, % OutPluginDir, UseErrorLevel
                }
                Break
            }
        }
    }
}
MenuShow() {
    If (Cube != CubeBefore)
    {
        CubeBefore := Cube

        Menu, MainMenu, Add
        Menu, MainMenu, DeleteAll
        MenuItemName := (StrLen(Cube) > 30)?SubStr(Cube, 1, 27) "...":Cube
        Menu, MainMenu, Add, % MenuItemName, MenuShow
        Menu, MainMenu, Icon, % MenuItemName, % "icons\images.dll\imageres-234.ico"
        For Index, cType in GetTypes()
        {
            Menu, MainMenu, Add
            Menu, MainMenu, Add, % cType, % ":" cType
            If RegExMatch(cType, "^Menu\.Folder(\.\w+)*$") {
                Menu, MainMenu, Icon, % cType, % "icons\images.dll\imageres-265.ico"
            } Else If RegExMatch(cType, "^Menu\.File(\.\w+)*$") {
                Menu, MainMenu, Icon, % cType, % GetFileIcon(Cube), , % A_ScreenDPI / 6
            } Else If RegExMatch(cType, "^Menu\.Text(\.\w+)*$") {
                Menu, MainMenu, Icon, % cType, % "icons\images.dll\imageres-247.ico"
            }
        }
    }
    Menu, MainMenu, Show
}
;===============================================================================
GetTypes() {
    _Types := []
    If Cube
    {
        _FileExist := FileExist(Cube)
        If _FileExist
        {
            If InStr(FileExist(Cube), "D")
            {
                _Types.push("Menu.Folder")
            }
            _Types.push("Menu.File")
        }

        For REType, REs in IniReadArrayValue("RegularExpression")
        {
            For _, RE in REs
            {
                If RegExMatch(Cube, RE)
                {
                    _Types.push(REType)
                    Break
                }
            }
        }
        _Types.push("Menu.Text")
    }
    return _Types
}
;===============================================================================
GetFileIcon(File) {
    VarSetCapacity(FileInfo, FileSize:=A_PtrSize + 688)
    If DllCall("shell32\SHGetFileInfoW", "Wstr", File, "UInt", 0, "Ptr", &FileInfo, "UInt", FileSize, "UInt", 0x110)
    {
        Return % "HICON:" NumGet(FileInfo, 0, "Ptr")
    }
    Return A_AhkPath
}
GetPluginIcon(MenuName) {
    RegExMatch(MenuName, "O)^\[(?<NAME>.+?)\](\[(?<ICON>.+?)\])?(?<PARAMETER>.+)?$", Out)
    If Out["ICON"] {
        Icon := A_ScriptDir "\icons\" Out["ICON"]
        ; msgbox % Icon
        If FileExist(Icon)
        {
            Return Icon
        }
        Return Out["ICON"]
    }
    PluginPath := A_ScriptDir "\plugins\" Out["NAME"]
    For Key, Value in [".ico", ".png", ".exe"]
    {
        Icon := PluginPath "\" Out["NAME"] Value
        ; msgbox % Icon
        If FileExist(Icon)
        {
            Return Icon
        }
    }
}
;===============================================================================
CapsLockPressed() {
    ClipBoardBak := ClipboardAll
    Clipboard := ""
    Send ^c
    ClipWait, 0.5, 1
    Cube := Trim(Clipboard)
    Clipboard := ClipBoardBak

    If Not ErrorLevel
    {
        MenuCreate()
        MenuShow()
    }
}
CapsLockSwitched() {
    If GetKeyState("CapsLock", "T") {
        SetCapsLockState, AlwaysOff
    } Else {
        SetCapsLockState, AlwaysOn
    }
}
;===============================================================================
~CapsLock::CapsLockPressed()
^CapsLock::CapsLockSwitched()

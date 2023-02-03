#NoEnv
#SingleInstance, force

SetWorkingDir % A_ScriptDir
SetCapsLockState, AlwaysOff

Menu, Tray, NoMainWindow
Menu, Tray, Icon, % "icons\images.dll\imageres-234.ico"
Menu, MainMenu, UseErrorLevel

Global MyClipBoard
Return
;===============================================================================
class IniConfig
{
    __New(Ini)
    {
        this.Ini := Ini

        this.Sections := {}
        IniRead, OutputVarSectionNames, % this.Ini
        this.SectionNames := StrSplit(OutputVarSectionNames, "`n")
        For _, SectionName in this.SectionNames
        {
            IniRead, Section, % this.Ini, % SectionName
            this.Sections[SectionName] := StrSplit(Section, "`n")
        }
    }

    ReadArrayValue(Section)
    {
        Array := {}
        For _, Line in this.Sections[Section]
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
MenuShow(Config) {
    Menu, MainMenu, Add
    Menu, MainMenu, DeleteAll
    MenuItemName := (StrLen(MyClipBoard) > 30)?SubStr(MyClipBoard, 1, 27) "...":MyClipBoard
    Menu, MainMenu, Add, % MenuItemName, MenuShow
    Menu, MainMenu, Icon, % MenuItemName, % "icons\images.dll\imageres-234.ico"
    For Index, cType in GetTypes(Config)
    {
        Menu, MainMenu, Add
        Menu, MainMenu, Add, % cType, % ":" cType
        If RegExMatch(cType, "^Menu\.Folder(\.\w+)*$") {
            Menu, MainMenu, Icon, % cType, % "icons\images.dll\imageres-265.ico"
        } Else If RegExMatch(cType, "^Menu\.File(\.\w+)*$") {
            Menu, MainMenu, Icon, % cType, % GetFileIcon(MyClipBoard), , % A_ScreenDPI / 6
        } Else If RegExMatch(cType, "^Menu\.Text(\.\w+)*$") {
            Menu, MainMenu, Icon, % cType, % "icons\images.dll\imageres-247.ico"
        }
    }
    Menu, MainMenu, Show
}
MenuCreate(Config)
{
    For _, SectionName in Config.SectionNames
    {
        If RegExMatch(SectionName, "^Menu\.(\w+(\.)?)+")
        {
            Menu, % SectionName, Add
            Menu, % SectionName, DeleteAll
            SubMenuLine :=
            For _, Line in Config.Sections[SectionName]
            {
                MenuLine := StrSplit(Line, "=", 1)
                If (SubStr(MenuLine[1], 1, 1) = ">")
                {
                    If SubMenuLine
                    {
                        MenuName := SubStr(MenuLine[1], 2)
                        Label := Func("MenuRun").Bind(MenuLine[2])
                        Menu, % SectionName SubMenuLine[1], Add, % MenuName, % Label
                        Menu, % SectionName SubMenuLine[1], Icon, % MenuName, % GetPluginIcon(MenuLine[2])
                    }
                    Else
                    {
                        SubMenuLine := MenuLine
                        Menu, % SectionName SubMenuLine[1], Add
                        Menu, % SectionName SubMenuLine[1], DeleteAll
                    }
                }
                Else
                {
                    If SubMenuLine
                    {
                        Menu, % SectionName, Add, % SubStr(SubMenuLine[1], 2), % ":" SectionName SubMenuLine[1]
                        If RegExMatch(SubMenuLine[2], "O)^\[(?<NAME>.*?)\](\[(?<ICON>.+?)\])?(?<PARAMETER>.+)?$", Out)
                        {
                            Menu, % SectionName, Icon, % SubStr(SubMenuLine[1], 2), % Out["ICON"]
                        }
                    }
                    SubMenuLine :=
                    Label := Func("MenuRun").Bind(MenuLine[2])
                    ; SectionName: Menu.Folder
                    ; MenuLine[1]: Edit by &SublimeText
                    ; MenuLine[2]: [SublimeText]([sublime_text.ico])?...
                    Menu, % SectionName, Add, % MenuLine[1], % Label
                    Menu, % SectionName, Icon, % MenuLine[1], % GetPluginIcon(MenuLine[2])
                }
            }
        }
    }
}
MenuRun(IniValue, ItemName, ItemPos, MenuName) {
    ; IniValue: [AHKHelp]([AHKHelp.ico])?...
    ; ItemName: AHK &Help
    ; ItemPos: 3
    ; MenuName: Menu.Text
    If RegExMatch(IniValue, "O)^\[(?<NAME>.*?)\](\[(?<ICON>.+?)\])?(?<PARAMETER>.+)?$", Out)
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
                    Run, % "*RunAs " PluginPath " " Out["PARAMETER"] " " MyClipBoard, % OutPluginDir, UseErrorLevel
                } Else If GetKeyState("Ctrl", "P") {
                    Run, % "Edit " PluginPath, % OutPluginDir, UseErrorLevel
                } Else {
                    Run, % PluginPath " " Out["PARAMETER"] " " MyClipBoard, % OutPluginDir, UseErrorLevel
                }
                Break
            }
        }
    }
}
;===============================================================================
GetTypes(Config) {
    _Types := []
    If MyClipBoard
    {
        _FileExist := FileExist(MyClipBoard)
        If _FileExist
        {
            If InStr(FileExist(MyClipBoard), "D")
            {
                _Types.push("Menu.Folder")
            }
            _Types.push("Menu.File")
        }

        For REType, REs in Config.ReadArrayValue("RegularExpression")
        {
            For _, RE in REs
            {
                If RegExMatch(MyClipBoard, RE)
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
    RegExMatch(MenuName, "O)^\[(?<NAME>.*?)\](\[(?<ICON>.+?)\])?(?<PARAMETER>.+)?$", Out)
    If Out["ICON"] {
        Return Out["ICON"]
    }
    PluginPath := A_ScriptDir "\plugins\" Out["NAME"]
    For Key, Value in [".ico", ".png", ".exe"]
    {
        Icon := PluginPath "\" Out["NAME"] Value
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
    MyClipBoard := Trim(Clipboard)
    Clipboard := ClipBoardBak

    If Not ErrorLevel And MyClipBoard
    {
        Config := new IniConfig("settings.ini")
        MenuCreate(Config)
        MenuShow(Config)
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

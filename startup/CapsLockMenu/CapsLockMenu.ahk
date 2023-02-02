#NoEnv
#SingleInstance, force

SetWorkingDir % A_ScriptDir
SetCapsLockState, AlwaysOff
; Menu, Tray, NoStandard
Menu, MainMenu, UseErrorLevel
Menu, Tray, NoMainWindow
Menu, Tray, Icon, % "icons\images.dll\imageres-234.ico"

global Cube, CubeBefore

Global Settings := IniReadSections("settings.ini")
Global RegularExpression := IniReadArrayValue("Variable.RegularExpression")
Return
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
            For _, Line in Settings.Sections[SectionName]
            {
                KeyValue := StrSplit(Line, "=", 1)
                Label := Func("MenuRun").Bind(KeyValue[2])
                ; SectionName: Menu.Folder
                ; KeyValue[1]: Edit by &SublimeText
                ; KeyValue[2]: [SublimeText]
                RegExMatch(KeyValue[2], "O)^\[(?<PLUGIN>.+)\](?<PARAMETER>.+)?", Out)
                Menu, % SectionName, Add, % KeyValue[1], % Label
                Menu, % SectionName, Icon, % KeyValue[1], % GetPluginIcon(Out["PLUGIN"])
            }
        }
    }
}
MenuRun(IniValue, ItemName, ItemPos, MenuName) {
    ; MsgBox % "IniValue: " IniValue "`nItemName: " ItemName "`nItemPos: " ItemPos "`nMenuName: " MenuName
    ; IniValue: [Plugin]AHKHelp
    ; ItemName: AHK &Help
    ; ItemPos: 3
    ; MenuName: Menu.Text
    If RegExMatch(IniValue, "O)^\[(?<PLUGIN>.+)\](?<PARAMETER>.+)?", Out)
    {
        EnvGet, PathExt, PATHEXT
        For i, Ext in StrSplit(PathExt, ";")
        {
            PluginPath := A_ScriptDir "\plugins\" Out["PLUGIN"] "\" Out["PLUGIN"] Ext
            If FileExist(PluginPath)
            {
                OutPluginDir := A_ScriptDir "\plugins\" Out["PLUGIN"]

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
        MenuItemName := (StrLen(Cube) > 50)?SubStr(Cube, 1, 47) "...":Cube
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

        SplitPath, Cube, , , OutExtension
        For _, SectionName in Settings.SectionNames
        {
            If (SectionName = "Menu.File.Extension." OutExtension)
            {
                _Types.push(SectionName)
                Break
            }
        }

        For REType, REs in RegularExpression
        {
            For _, RE in REs
            {
                If RegExMatch(Cube, RE)
                {
                    _Types.push("Menu.Text.RegularExpression." REType)
                    Break
                }
            }
        }
        _Types.push("Menu.Text")
    }
    return _Types
}
;===============================================================================
GetFolderIcon(Folder) {
    Return % "imageres.dll,204"
}
GetFileIcon(File) {
    VarSetCapacity(FileInfo, FileSize:=A_PtrSize + 688)
    If DllCall("shell32\SHGetFileInfoW", "Wstr", File, "UInt", 0, "Ptr", &FileInfo, "UInt", FileSize, "UInt", 0x110)
    {
        Return % "HICON:" NumGet(FileInfo, 0, "Ptr")
    }
    Return GetFileIcon(A_AhkPath)
}
GetPluginIcon(PluginName) {
    PluginPath := A_ScriptDir "\plugins\" PluginName
    For Key, Value in [".ico", ".png"]
    {
        Icon := PluginPath "\" PluginName Value
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

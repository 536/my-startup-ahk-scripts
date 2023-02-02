; HELPFILES := {"AutoHotkey.chm": "C:\\Program Files\\AutoHotkey\\AutoHotkey.chm"}

; For k, v in HELPFILES
; {
;     Label := Func("GetHelp").Bind(v, StrReplace(A_Args[1], "#", "_"))
;     Menu, Help, Add, % k, % Label
;     Menu, Help, Icon, % k, %A_WinDir%\hh.exe
; }
; Menu, Help, Show

GetHelp(GetHelpFile(), keyword:=StrReplace(A_Args[1], "#", "_"))
Return

GetHelpFile() {
    SplitPath, A_AhkPath, , OutDir
    Return OutDir "\AutoHotkey.chm"
}

GetHelp(helpfile, keyword) {
    KEYWORDS := "Block;BlockInput;Break;Catch;Click;ClipWait;ComObjActive;ComObjArray;ComObjConnect;ComObjCreate;ComObjError;ComObjFlags;ComObjGet;ComObjQuery;ComObjType;ComObjValue;Continue;Control;ControlClick;ControlFocus;ControlGet;ControlGetFocus;ControlGetPos;ControlGetText;ControlMove;ControlSend;ControlSetText;CoordMode;Critical;DetectHiddenText;DetectHiddenWindows;DllCall;Drive;DriveGet;DriveSpaceFree;Edit;Else;EnvAdd;EnvDiv;EnvGet;EnvMult;EnvSet;EnvSub;EnvUpdate;Exit;ExitApp;FileAppend;FileCopy;FileCopyDir;FileCreateDir;FileCreateShortcut;FileDelete;FileEncoding;FileGetAttrib;FileGetShortcut;FileGetSize;FileGetTime;FileGetVersion;FileInstall;FileMove;FileMoveDir;FileOpen;FileRead;FileReadLine;FileRecycle;FileRecycleEmpty;FileRemoveDir;FileSelectFile;FileSelectFolder;FileSetAttrib;FileSetTime;For;FormatTime;GetKeyState;Gosub;Goto;GroupActivate;GroupAdd;GroupClose;GroupDeactivate;Gui;GuiControl;GuiControlGet;GuiControls;Hotkey;IfBetween;IfEqual;IfExist;IfExpression;IfIn;IfInString;IfIs;IfMsgBox;IfWinActive;IfWinExist;ImageSearch;index;IniDelete;IniRead;IniWrite;Input;InputBox;KeyHistory;KeyWait;ListHotkeys;ListLines;ListVars;ListView;Loop;LoopFile;LoopParse;LoopReadFile;LoopReg;Menu;MouseClick;MouseClickDrag;MouseGetPos;MouseMove;MsgBox;ObjAddRef;OnExit;OnMessage;OutputDebug;Pause;PixelGetColor;PixelSearch;PostMessage;Process;Progress;Random;RegDelete;RegExMatch;RegExReplace;RegisterCallback;RegRead;RegWrite;Reload;Return;Run;RunAs;Send;SendLevel;SendMode;SetBatchLines;SetControlDelay;SetDefaultMouseSpeed;SetEnv;SetExpression;SetFormat;SetKeyDelay;SetMouseDelay;SetNumScrollCapsLockState;SetRegView;SetStoreCapslockMode;SetTimer;SetTitleMatchMode;SetWinDelay;SetWorkingDir;Shutdown;Sleep;Sort;SoundBeep;SoundGet;SoundGetWaveVolume;SoundPlay;SoundSet;SoundSetWaveVolume;SplashTextOn;SplitPath;StatusBarGetText;StatusBarWait;StringCaseSense;StringGetPos;StringLeft;StringLen;StringLower;StringMid;StringReplace;StringSplit;StringTrimLeft;StrPutGet;Suspend;SysGet;Thread;Throw;ToolTip;Transform;TrayTip;TreeView;Trim;Try;Until;URLDownloadToFile;VarSetCapacity;While;WinActivate;WinActivateBottom;WinClose;WinGet;WinGetActiveStats;WinGetActiveTitle;WinGetClass;WinGetPos;WinGetText;WinGetTitle;WinHide;WinKill;WinMaximize;WinMenuSelectItem;WinMinimize;WinMinimizeAll;WinMove;WinRestore;WinSet;WinSetTitle;WinShow;WinWait;WinWaitActive;WinWaitClose;#AllowSameLineComments;#ClipboardTimeout;#CommentFlag;#ErrorStdOut;#EscapeChar;#HotkeyInterval;#HotkeyModifierTimeout;#Hotstring;#If;#IfTimeout;#IfWinActive;#Include;#InputLevel;#InstallKeybdHook;#InstallMouseHook;#KeyHistory;#MaxHotkeysPerInterval;#MaxMem;#MaxThreads;#MaxThreadsBuffer;#MaxThreadsPerHotkey;#MenuMaskKey;#NoEnv;#NoTrayIcon;#Persistent;#SingleInstance;#UseHook;#Warn;#WinActivateForce"
    If RegExMatch(KEYWORDS,"i)(^|;)" keyword "($|;)") ; 若加上 # 前缀是否存在？
    {
        Transform, ThisUrl, DeRef, mk:@MSITStore:%helpfile%::/docs/commands/%keyword%.htm
        Run, %A_WinDir%\hh.exe %ThisUrl%, , Max
    }
    Else
    {
        Critical
        Run, %helpfile%, , Max, id
        WinActivate, % "ahk_id " id
        Sleep, 300
        Send, !s
        SendInput, %keyword%
        Send, {Enter}
    }
}

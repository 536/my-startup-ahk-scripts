#Include, .\cube\settings.ahk

If WinExist("ahk_class RegEdit_RegEdit")
{
    If A_IsAdmin
    {
        PostMessage, 0x112, 0xF060,,, ahk_class RegEdit_RegEdit
        Sleep, 500
        Gosub, Label_LocateInRegedit
    }
    Else
        Run, *RunAs %A_ScriptFullPath%
}
Else
    Gosub, Label_LocateInRegedit
Return

Label_LocateInRegedit:
    RegWrite, REG_SZ, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit, LastKey, % Clipboard
    Run, regedit
Return

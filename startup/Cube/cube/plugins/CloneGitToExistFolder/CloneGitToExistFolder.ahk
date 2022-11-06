#Include, .\cube\settings.ahk

title := "Manually choose a folder..."
Menu, % A_ScriptName, Add, % title, Manually
Menu, % A_ScriptName, Icon, % title, % A_AhkPath
Menu, % A_ScriptName, Add

ListOfExplorer := {}
WinGet, IDS, List, ahk_class CabinetWClass
If (IDS == 0)
    Return
Loop % IDS
{
    loop_id := IDS%A_Index%
    WinGetTitle, title, % "ahk_id " loop_id
    If title
    {
        ListOfExplorer[title] := loop_id
        Menu, % A_ScriptName, Add, % title, Label_Clone
        Menu, % A_ScriptName, Icon, % title, imageres.dll,4
    }
}
Menu, % A_ScriptName, Show
Return

Manually:
    FileSelectFolder, folder, ::{20d04fe0-3aea-1069-a2d8-08002b30309d}, 3 ; My Computer. select a folder and provides both an edit field and a "make new folder" button.
    if folder =
        MsgBox, , , You didn't select a folder., 3 ; exit after 3s
    else
        git_clone(Clipboard, folder)
Return

Label_Clone:
    WinActivate % "ahk_id " ListOfExplorer[A_ThisMenuItem]
    ControlGetText, folder, ToolbarWindow323, % "ahk_id " ListOfExplorer[A_ThisMenuItem]
    RegExMatch(folder, "(\w:.*$)", folder)
    git_clone(Clipboard, folder)
Return

git_clone(url, folder) {
    Run % "cmd /K cd /d """ folder """ && git clone " url
}

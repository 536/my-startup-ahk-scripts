#Include, .\cube\settings.ahk

FileList := StrSplit(Clipboard, "`n")
MsgBox % Cube_EXE.BCompare
If (FileList.Length() = 2)
{
    Run, % """" Cube_EXE.BCompare """ """ Trim(FileList[1], "`r") """ """ FileList[2] """"
}

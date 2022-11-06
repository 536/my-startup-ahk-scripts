#Include, .\cube\settings.ahk

For index, file in StrSplit(Clipboard, "`n")
{
    If FileExist(file)
    {
        Run, % """" Cube_EXE.VSCode """ """ file """"
    }
}

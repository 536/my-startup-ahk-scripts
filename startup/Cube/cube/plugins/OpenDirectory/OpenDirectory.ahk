#Include, .\cube\settings.ahk

If (FileExist(Clipboard) = "D")
    Run, % Clipboard
Else If FileExist(Clipboard)
{
    SplitPath, Clipboard, , OutDir
    Run, % OutDir
}

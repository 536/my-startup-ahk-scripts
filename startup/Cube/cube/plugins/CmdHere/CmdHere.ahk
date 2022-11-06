#Include, .\cube\settings.ahk

If (FileExist(Clipboard)="D")
    Run, % A_ComSpec " /k cd /d """ Clipboard """ && dir"
Else If (FileExist(Clipboard))
{
    SplitPath, Clipboard, OutFileName, OutDir
    Run, % A_ComSpec " /k cd /d """ OutDir """ && dir"
}

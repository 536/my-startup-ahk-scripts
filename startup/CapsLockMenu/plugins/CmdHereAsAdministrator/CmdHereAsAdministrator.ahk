#Include, .\cube\settings.ahk

If (FileExist(Clipboard)="D")
    Run, % "*RunAs " A_ComSpec " /k cd /d """ Clipboard """ && dir"
Else If (FileExist(Clipboard))
{
    SplitPath, Clipboard, OutFileName, OutDir
    Run, % "*RunAs " A_ComSpec " /k cd /d """ OutDir """ && dir"
}

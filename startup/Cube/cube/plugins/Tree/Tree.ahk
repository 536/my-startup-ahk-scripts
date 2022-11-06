#Include, .\cube\settings.ahk

If (FileExist(Clipboard)="D")
    Run, % A_ComSpec " /k cd /d """ Clipboard """ && tree /f """ Clipboard """"
Else If (FileExist(Clipboard)!="D")
{
    SplitPath, Clipboard, OutFileName, OutDir
    Run, % A_ComSpec " /k cd /d """ OutDir """ && tree /f """ OutDir """"
}

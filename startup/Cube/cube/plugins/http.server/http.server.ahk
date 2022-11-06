#Include, .\cube\settings.ahk

If (FileExist(Clipboard)="D")
    Run, % A_ComSpec " /c cd /d """ Clipboard """ && ipconfig && python -m http.server"
Else If (FileExist(Clipboard)!="D")
{
    SplitPath, Clipboard, OutFileName, OutDir
    Run, % A_ComSpec " /c cd /d """ OutDir """ && ipconfig && python -m http.server"
}

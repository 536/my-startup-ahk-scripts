#Include, .\cube\settings.ahk

If (FileExist(Clipboard)="D")
{
    MsgBox, % Clipboard
    Run, % A_ComSpec " /c cd /d """ Clipboard """ && browser-sync start --server --files ""**"""
}
Else If (FileExist(Clipboard)!="D")
{
    SplitPath, Clipboard, OutFileName, OutDir,,, OutDrive
    If (OutDir = OutDrive)
        Run, % A_ComSpec " /c cd /d """ OutDir "\"" && browser-sync start --server --files """ OutFileName """"
    Else
        Run, % A_ComSpec " /c cd /d """ OutDir """ && browser-sync start --server --files """ OutFileName """"
}

#Include, .\cube\settings.ahk

If (FileExist(Clipboard))
{
    SplitPath, Clipboard, OutFileName, OutDir, OutExtension, , OutDrive
    If (OutDir = OutDrive)
        OutDir := OutDir "\"
    If (OutExtension = "exe")
        Run, % "*RunAs " A_ComSpec " /k cd /d """ OutDir """ && " OutFileName
}

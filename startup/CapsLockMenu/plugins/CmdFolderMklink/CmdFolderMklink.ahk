#Include, .\cube\settings.ahk

SplitPath, Clipboard, OutFileName, OutDir
FileSelectFolder, TargetDir, % "*" OutDir, 0
If TargetDir
{
    InputBox, TargetFileName, , % "Choose a link name:", , , , , , , , % OutFileName
    If TargetFileName
    {
        Run, % "*RunAs " A_ComSpec " /c cd /d """ TargetDir """ && mklink /d """ TargetFileName """ """ Clipboard """"
    }
}

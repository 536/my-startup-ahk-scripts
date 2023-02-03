SplitPath, % A_Args[1], OutFileName, OutDir
FileSelectFolder, TargetDir, % "*" OutDir, 0
If TargetDir
{
    InputBox, TargetFileName, , % "Choose a link name:", , , , , , , , % OutFileName
    If TargetFileName
    {
        Run, % "*RunAs " A_ComSpec " /c cd /d """ TargetDir """ && mklink /d """ TargetFileName """ """ A_Args[1] """"
    }
}

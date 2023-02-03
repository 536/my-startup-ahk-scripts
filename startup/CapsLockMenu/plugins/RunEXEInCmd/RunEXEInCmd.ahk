If (FileExist(A_Args[1]))
{
    SplitPath, % A_Args[1], OutFileName, OutDir, OutExtension, , OutDrive
    If (OutDir = OutDrive)
        OutDir := OutDir "\"
    If (OutExtension = "exe")
        Run, % A_ComSpec " /k cd /d """ OutDir """ && " OutFileName
}

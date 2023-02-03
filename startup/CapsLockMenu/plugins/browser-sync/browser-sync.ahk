If (FileExist(A_Args[1])="D")
{
    Run, % A_ComSpec " /c cd /d """ A_Args[1] """ && browser-sync start --server --files ""**"""
}
Else If (FileExist(A_Args[1])!="D")
{
    SplitPath, % A_Args[1], OutFileName, OutDir,,, OutDrive
    If (OutDir = OutDrive)
        Run, % A_ComSpec " /c cd /d """ OutDir "\"" && browser-sync start --server --files """ OutFileName """"
    Else
        Run, % A_ComSpec " /c cd /d """ OutDir """ && browser-sync start --server --files """ OutFileName """"
}

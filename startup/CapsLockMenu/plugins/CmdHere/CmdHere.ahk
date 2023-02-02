If (FileExist(A_Args[1])="D")
    Run, % A_ComSpec " /k cd /d """ A_Args[1] """ && dir"
Else If (FileExist(A_Args[1]))
{
    SplitPath, % A_Args[1], OutFileName, OutDir
    Run, % A_ComSpec " /k cd /d """ OutDir """ && dir"
}

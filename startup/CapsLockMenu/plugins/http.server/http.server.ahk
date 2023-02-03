If (FileExist(A_Args[1])="D")
    Run, % A_ComSpec " /c cd /d """ A_Args[1] """ && ipconfig && python -m http.server"
Else If (FileExist(A_Args[1])!="D")
{
    SplitPath, % A_Args[1], OutFileName, OutDir
    Run, % A_ComSpec " /c cd /d """ OutDir """ && ipconfig && python -m http.server"
}

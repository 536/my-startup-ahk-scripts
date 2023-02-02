If InStr(FileExist(A_Args[1]), "D")
{
    SplitPath, % A_Args[1], , OutDir
    FileMoveDir, % A_Args[1], % OutDir, 2
    if ErrorLevel
        MsgBox, % "Failed to disassemble this folder!"
}

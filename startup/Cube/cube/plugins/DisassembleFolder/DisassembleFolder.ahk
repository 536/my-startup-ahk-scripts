#Include, .\cube\settings.ahk

If InStr(FileExist(Clipboard), "D")
{
    SplitPath, Clipboard, , OutDir
    FileMoveDir, %Clipboard%, %OutDir%, 2
    if ErrorLevel
        MsgBox, % "Failed to disassemble this folder!"
}

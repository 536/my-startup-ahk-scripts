FileList := StrSplit(A_Args[1], "`r`n")
If (FileList.Length() = 2)
{
    exec := "%SOFTWARE%\BCompare\BCompare.exe"
    Run, % """" exec """ """ FileList[1] """ """ FileList[2] """"
}

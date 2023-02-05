#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

SplitPath, A_ScriptFullPath, , , , ScriptNameNoExt

LoopRun(A_ScriptDir . "\" . ScriptNameNoExt)
Return

LoopRun(start) {
    SplitPath, start, , startDir, , startNameNoExt
    ahk := start . "\" . startNameNoExt . ".ahk"
    If FileExist(ahk)
    {
        Run(ahk)
        Return
    }

    Loop, Files, % start . "\*", D
    {
        SplitPath, A_LoopFileLongPath, , , , LoopFileNameNoExt
        If (LoopFileNameNoExt != "lib")
            LoopRun(A_LoopFileLongPath)
    }

    Loop, Files, % start . "\*.ahk", F
    {
        Run(A_LoopFileLongPath)
    }
}

Run(ahk) {
    SplitPath, ahk, , ahkDir, , ahkNameNoExt
    cli := ahkDir . "\" . ahkNameNoExt . ".cli"
    If FileExist(cli)
    {
        FileReadLine, params, % cli, 1
        Run % ahk " " params, % ahkDir
    }
    Else
    {
        Run % ahk, % ahkDir
    }
}

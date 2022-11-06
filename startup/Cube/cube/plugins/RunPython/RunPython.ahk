#Include, .\cube\settings.ahk

SplitPath, Clipboard, OutFileName, OutDir, , , OutDrive
If FileExist(OutDir "\venv")
{
    Run, % A_ComSpec " /k cd /d """ OutDir """ && venv\Scripts\activate && python """ OutFileName """"
    Return
}

Menu, Python, UseErrorLevel

PythonList := StrSplit(StdoutToVar_CreateProcess("where python"), "`n")
For Index, Value in PythonList
{
    If Value
    {
        Label := Func("RunPython").Bind(Value)
        Menu, Python, Add, % value, % Label
        Menu, Python, Icon, % value, python.exe, 1
    }
}
Menu, Python, Show
Return

RunPython(Interpreter) {
    SplitPath, Clipboard, OutFileName, OutDir, , , OutDrive
    If (OutDir = OutDrive)
        OutDir := OutDir "\"
    Run, % A_ComSpec " /k cd /d """ OutDir """ && """ Interpreter """ """ OutFileName """"
}

StdoutToVar_CreateProcess(sCmd, sEncoding:="CP858", sDir:="", ByRef nExitCode:=0) {
    DllCall( "CreatePipe", PtrP,hStdOutRd, PtrP,hStdOutWr, Ptr,0, UInt,0 )
    DllCall( "SetHandleInformation", Ptr,hStdOutWr, UInt,1, UInt,1 )

    VarSetCapacity( pi, (A_PtrSize == 4) ? 16 : 24, 0 )
    siSz := VarSetCapacity( si, (A_PtrSize == 4) ? 68 : 104, 0 )
    NumPut( siSz, si, 0, "UInt" )
    NumPut( 0x100, si, (A_PtrSize == 4) ? 44 : 60, "UInt" )
    NumPut( hStdInRd, si, (A_PtrSize == 4) ? 56 : 80, "Ptr" )
    NumPut( hStdOutWr, si, (A_PtrSize == 4) ? 60 : 88, "Ptr" )
    NumPut( hStdOutWr, si, (A_PtrSize == 4) ? 64 : 96, "Ptr" )

    if ( !DllCall( "CreateProcess", Ptr,0, Ptr,&sCmd, Ptr,0, Ptr,0, Int,True, UInt,0x08000000
        , Ptr,0, Ptr,sDir?&sDir:0, Ptr,&si, Ptr,&pi ) )
    return ""
    , DllCall( "CloseHandle", Ptr,hStdOutWr )
    , DllCall( "CloseHandle", Ptr,hStdOutRd )

    DllCall( "CloseHandle", Ptr,hStdOutWr ) ; The write pipe must be closed before Reading the stdout.
    VarSetCapacity(sTemp, 4095)
    while ( DllCall( "ReadFile", Ptr,hStdOutRd, Ptr,&sTemp, UInt,4095, PtrP,nSize, Ptr,0 ) )
        sOutput .= StrGet(&sTemp, nSize, sEncoding)

    DllCall( "GetExitCodeProcess", Ptr,NumGet(pi,0), UIntP,nExitCode )
    DllCall( "CloseHandle", Ptr,NumGet(pi,0) )
    DllCall( "CloseHandle", Ptr,NumGet(pi,A_PtrSize) )
    DllCall( "CloseHandle", Ptr,hStdOutRd )
    return sOutput
}

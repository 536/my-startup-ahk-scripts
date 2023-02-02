exec := A_WinDir "\notepad.exe"
Run, % A_ComSpec " /C " exec " """ A_Args[1] """", , Hide

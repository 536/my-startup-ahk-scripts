exec := "C:\Windows\System32\OpenWith.exe"
Run, % A_ComSpec " /C " exec " """ A_Args[1] """", , Hide

exec := "%SOFTWARE%\Everything\Everything.exe -s"
Run, % A_ComSpec " /C " exec " """ A_Args[1] """", , Hide

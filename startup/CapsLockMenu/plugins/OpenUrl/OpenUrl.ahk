If RegExMatch(A_Args[1], "^http(s)://.*")
{
    Run, % A_Args[1]
}
Else{
    Run, % "http://" A_Args[1]
}

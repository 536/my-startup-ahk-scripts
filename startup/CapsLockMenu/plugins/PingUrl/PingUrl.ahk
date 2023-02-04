If RegExMatch(A_Args[1], "O)^(http(s)?://)?(?<DOMAIN>(\w+\.)?\w+\.\w+)(\/.*)?$", Out)
{
    Run, % A_ComSpec " /C ping.exe " Out["DOMAIN"] " -t"
}

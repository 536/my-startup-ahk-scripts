#Include .\cube\lib\JSON.ahk

Try
{
    _ := JSON.Load(FileOpen("cube.json", "r", "CP936").Read())
}
Catch
{
    MsgBox, 4096, % A_ScriptName, % "Failed to load settings in cube.json!"
    ExitApp, 1
}

global Cube_Bases := _.type
global Cube_Ext := _.extension
global Cube_RE := _.regex
global Cube_Translations := _.transtation
global Cube_EXE := _.exe
global Cube_URL := _.url

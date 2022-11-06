# Cube

A handy [AutoHotKey](https://github.com/Lexikos/AutoHotkey_L) script acts like [Candy](https://github.com/Hoekey/Candy)

## Add A Plugin

1. Create Plugin Folder

    ```txt
    -Cube
        -cube
            -plugins
                -<PluginName>
                    <PluginName>.ahk
                    [<PluginName>.ico]
    ```

2. \<PluginName\>.ahk

    ```autohotkey
    #Include, .\cube\Settings.ahk ; At First Line

    ; Then use Cube in <PluginName>.ahk
    ; It will be nice if the plugin checks the variable "Clipboard"
    ```

3. Add MenuName and PluginName in config file like `cube\menus\FILE.ini`

    ```ini
    [Cube]
    ...
    <MenuName>       =<PluginName>
    ```

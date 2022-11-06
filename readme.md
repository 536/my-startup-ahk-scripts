# 开机启动的AHK脚本

## 功能

### [WinMove.ahk](./startup/WinMove.ahk)

任意窗口（不是最大化的），按住鼠标左键+右键来移动窗口（就像抓住窗口一样）

### [OnePixel.ahk](./startup/OnePixel.ahk)

当鼠标左键为按下状态时，按`w` `a` `s` `d`键将会往对应方向移动鼠标1个像素

### [HotStrings.ahk](./startup/HotStrings.ahk)

将一些经常打错的拼音自动纠正，或者实现一些短语的简写

### [HotKeys.ahk](./startup/HotKeys.ahk)

一些常见的快捷键

|快捷键|功能|
|:---:|----|
|窗口控制|
|`ctrl+space`|（取消）置顶当前窗口|
|命令行|
|`ctrl+win+c`|新建cmd窗口，起始目录为当前打开的第一个资源管理器窗口（不存在则为D:\—）|
|`ctrl+shift+win+c`|以管理员权限新建cmd窗口，起始目录为当前打开的第一个资源管理器窗口（不存在则为D:\—）|
|`ctrl+win+p`|新建powershell窗口，起始目录为当前打开的第一个资源管理器窗口（不存在则为D:\—）|
|`ctrl+shift+win+p`|以管理员权限新建powershell窗口，起始目录为当前打开的第一个资源管理器窗口（不存在则为D:\—）|
|`ctrl+shift+win+z`|打开控制面板“上帝模式”|
|媒体|
|`ctrl+win+↑`|音量+|
|`ctrl+win+↓`|音量-|
|`ctrl+win+←`|前一首|
|`ctrl+win+→`|后一首|
|`ctrl+win+space`|暂停|
|`ctrl+win+enter`|停止|
|屏幕亮度|
|`ctrl+shift+win+↑`|屏幕亮度+5%|
|`ctrl+shift+win+↓`|屏幕亮度-5%|
|按键替换|
|`RWin`|替换为`AppsKey`|
|按键组合替换|
|按下`；`/`;`后立即按下`space`|`;`和一个空格|
|连续两次按下`；`/`;`后立即按下`space`|两个`;`|
|按下`：`/`:`后立即按下`space`|`:`和一个空格|
|连续两次按下`：`/`:`后立即按下`space`|两个`:`|
|连续两次按下`‘`/`'`后立即按下`space`|两个`'`|
|连续三次按下`‘`/`'`后立即按下`space`|`"""\n"""`|
|连续两次按下`“`/`"`后立即按下`space`|两个`"`|
|连续三次按下`“`/`"`后立即按下`space`|`"""\n"""`|

TODO: 扩张更多实用的按键功能

### [ScriptManager.ahk](./startup/ScriptManager.ahk)

AHK脚本管理器

### specific programs\ `*.ahk`

```txtfile
common.AHK

在非常见编辑器窗口中，使用以下快捷键

    ctrl+enter
    在当前行下一行创建新行

    ctrl+shift+enter
    在当前行上一行创建新行

    ctrl+shift+d
    复制当前行

    ctrl+shift+k
    删除当前行

    ctrl+k, u
    讲所选内容转换为大写

    ctrl+k, l
    讲所选内容转换为小写

ahk_* *.ahk

在专门的程序中设定一些快捷键
```

### [ClipBoardMonitor.ahk](./startup/ClipBoardMonitor/ClipBoardMonitor.ahk)

剪切板内容监控，复制时显示提示，文本保存为txt，图片保存为png

### [Cube.ahk](./startup/Cube/Cube.ahk)

类似candy通过`capslock`键选择文本或者文件，弹出相应菜单

### [Mask.ahk](./startup/Mask/Mask.ahk)

使用一张图片作为半透明的全屏水印

## 使用

将[startup.ahk](startup.ahk)设置为开机自启动即可自动运行以上所有脚本

## 脚本启动规则

+ 从startup目录开始递归所有子文件夹

+ 在所有名称不是`lib`的文件夹中，如果包含与文件夹同名的ahk脚本则只执行这一个，否则执行所有的ahk脚本

+ 如果所执行的脚本所在文件夹存在同名的`.cli`文件，将读取其首行作为ahk脚本的参数

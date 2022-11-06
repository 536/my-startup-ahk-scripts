#SingleInstance, Force
#NoTrayIcon

#If GetKeyState("LButton", "P")
    w::MouseMove, 0, -1, , R
    a::MouseMove, -1, 0, , R
    s::MouseMove, 0, 1, , R
    d::MouseMove, 1, 0, , R
#If

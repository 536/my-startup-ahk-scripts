#SingleInstance, Force
#NoTrayIcon

#If WinActive("ahk_class TPLSQLDevForm")
    ~F7::
        Send ^v
        Send ^a
        Return
    :*:select1::
        Send, select t.*,rowid from%A_Space%
        Return
    :*:todate::
        send,to_date('','YYYY-MM-DD HH24:MI:SS')
        send,{left 26}
        Return
    :*:tochar::
        send, to_char()
        send, {left 1}
        Return
    :*:tonumber::
        send, to_number()
        send, {left 1}
        Return
#If

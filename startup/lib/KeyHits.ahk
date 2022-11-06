KeyHits(timeout = 0.2) {
    key := RegExReplace(A_ThisHotKey, "[\*\~\$\#\+\!\^( UP)]")
    Loop {
        KeyWait %key%
        KeyWait %key%, DT%timeout%
        If (ErrorLevel)
            Return A_Index
    }
}

#NoTrayIcon
#Persistent
#SingleInstance, force

SetWorkingDir % A_ScriptDir
CoordMode, ToolTip, Screen

; will only show the top %CharacterCount% characters
Global CharacterCount := 300
Global TEXTS_dir := A_WorkingDir "\cache\texts\"

OnClipboardChange("ClipChanged")
Return

ClipChanged(Type) {
    ; Contains one of the following values:
    ; 0 if the clipboard is now empty;
    ; 1 if it contains something that can be expressed as text (this includes files copied from an Explorer window);
    ; 2 if it contains something entirely non-text such as a picture.
    Try {
        If (Type = 1)
        {
            s := SubStr(Clipboard, 1, CharacterCount)
            ToolTip % "[INFO] " StrLen(ClipBoard) " characters copied!`n" s
            If FileExist(TEXTS_dir)
                FileAppend % Clipboard, % TEXTS_dir . A_Now . ".txt"
        }
    }
    Catch e {
        ToolTip % "[ERROR] "
    }

    SetTimer, ToolTip, -800 ; show a ToolTip for at least 800ms
}

ToolTip:
    ToolTip
Return

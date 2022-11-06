#SingleInstance, Force
#NoTrayIcon

#If MouseIsOver("Shell_TrayWnd","MSTaskListWClass1")
    ~LButton::
        hits := KeyHits()
        If (hits = 2) {
            ComObjCreate("Shell.Application").WindowSwitcher()
        }
        Return
    WheelUp::Send, {AltDown}{Esc}{AltUp}
    WheelDown::Send, {AltDown}+{Esc}{AltUp}
#If MouseIsOver("Shell_TrayWnd","NetSpeedMonitorToolbar1")
#If MouseIsOver("Shell_TrayWnd","TrayClockWClass1")
    WheelUp::Send {Volume_Up}
    WheelDown::Send {Volume_Down}
    ^WheelUp::SetScreenBrightness(1)
    ^WheelDown::SetScreenBrightness(-1)
    RButton::Run, C:\Windows\System32\SndVol.exe
    MButton::Run, ::{645ff040-5081-101b-9f08-00aa002f954e} ; recyle bin
#If

SetScreenBrightness(step) {
	VarSetCapacity(SupportedBrightness, 256, 0)
	VarSetCapacity(SupportedBrightnessSize, 4, 0)
	VarSetCapacity(BrightnessSize, 4, 0)
	VarSetCapacity(Brightness, 3, 0)

	hLCD := DllCall("CreateFile"
		, Str, "\\.\LCD"
		, UInt, 0x80000000 | 0x40000000 ;Read | Write
		, UInt, 0x1 | 0x2  ; File Read | File Write
		, UInt, 0
		, UInt, 0x3  ; open any existing file
		, UInt, 0
		, UInt, 0)

	if hLCD != -1
	{
		DevVideo := 0x00000023, BuffMethod := 0, Fileacces := 0
		NumPut(0x03, Brightness, 0, "UChar")   ; 0x01 = Set AC, 0x02 = Set DC, 0x03 = Set both
		NumPut(0x00, Brightness, 1, "UChar")      ; The AC brightness level
		NumPut(0x00, Brightness, 2, "UChar")      ; The DC brightness level
		DllCall("DeviceIoControl"
			, UInt, hLCD
			, UInt, (DevVideo<<16 | 0x126<<2 | BuffMethod<<14 | Fileacces) ; IOCTL_VIDEO_QUERY_DISPLAY_BRIGHTNESS
			, UInt, 0
			, UInt, 0
			, UInt, &Brightness
			, UInt, 3
			, UInt, &BrightnessSize
			, UInt, 0)

		DllCall("DeviceIoControl"
			, UInt, hLCD
			, UInt, (DevVideo<<16 | 0x125<<2 | BuffMethod<<14 | Fileacces) ; IOCTL_VIDEO_QUERY_SUPPORTED_BRIGHTNESS
			, UInt, 0
			, UInt, 0
			, UInt, &SupportedBrightness
			, UInt, 256
			, UInt, &SupportedBrightnessSize
			, UInt, 0)

		ACBrightness := NumGet(Brightness, 1, "UChar")
		ACIndex := 0
		DCBrightness := NumGet(Brightness, 2, "UChar")
		DCIndex := 0
		BufferSize := NumGet(SupportedBrightnessSize, 0, "UInt")
		MaxIndex := BufferSize-1

		Loop, %BufferSize%
		{
			ThisIndex := A_Index-1
			ThisBrightness := NumGet(SupportedBrightness, ThisIndex, "UChar")
			if ACBrightness = %ThisBrightness%
				ACIndex := ThisIndex
			if DCBrightness = %ThisBrightness%
				DCIndex := ThisIndex
		}

		if DCIndex >= %ACIndex%
			BrightnessIndex := DCIndex
		else
			BrightnessIndex := ACIndex

		BrightnessIndex += step

		if BrightnessIndex > %MaxIndex%
			BrightnessIndex := MaxIndex

		if BrightnessIndex < 0
			BrightnessIndex := 0

		NewBrightness := NumGet(SupportedBrightness, BrightnessIndex, "UChar")

		NumPut(0x03, Brightness, 0, "UChar")   ; 0x01 = Set AC, 0x02 = Set DC, 0x03 = Set both
        NumPut(NewBrightness, Brightness, 1, "UChar")      ; The AC brightness level
        NumPut(NewBrightness, Brightness, 2, "UChar")      ; The DC brightness level

		DllCall("DeviceIoControl"
			, UInt, hLCD
			, UInt, (DevVideo<<16 | 0x127<<2 | BuffMethod<<14 | Fileacces) ; IOCTL_VIDEO_SET_DISPLAY_BRIGHTNESS
			, UInt, &Brightness
			, UInt, 3
			, UInt, 0
			, UInt, 0
			, UInt, 0
			, Uint, 0)

		DllCall("CloseHandle", UInt, hLCD)

		Return BrightnessIndex
	}
}

MouseIsOver(class,control="") {
    MouseGetPos, , , MouseOverWinID, MouseOverControl
    WinGetClass, MouseOverWinClass, % "ahk_id " MouseOverWinID
    If ((MouseOverWinClass = class) && ((MouseOverControl = control) || !control))
        Return True
}

KeyHits(timeout = 0.2) {
    key := RegExReplace(A_ThisHotKey, "[\*\~\$\#\+\!\^( UP)]")
    Loop {
        KeyWait %key%
        KeyWait %key%, DT%timeout%
        If (ErrorLevel)
            Return A_Index
    }
}

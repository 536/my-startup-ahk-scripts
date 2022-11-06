#NoTrayIcon
; Easy Access to Currently Opened Folders
; Original author: Savage
; Fork by Leeroy
; Invoke a menu of currently opened folders when you click
; the middle mouse button inside Open / Save as dialogs or
; Console (command prompt) windows. Select one of these
; locations and the script will navigate there.

; CONFIG: CHOOSE A DIFFERENT HOTKEY
; You could also use a modified mouse button (such as ^MButton) or
; a keyboard hotkey. In the case of MButton, the tilde (~) prefix
; is used so that MButton's normal functionality is not lost when
; you click in other window types, such as a browser.

; Middle-click like original script by Savage
f_Hotkey = ~MButton
; Ctrl+G like in Listary
f_HotkeyCombo = ~^g

; END OF CONFIGURATION SECTION
; Do not make changes below this point unless you want to change
; the basic functionality of the script.

#SingleInstance, force ; Needed since the hotkey is dynamically created.

; Auto-execute section.
Hotkey, %f_Hotkey%, f_DisplayMenu
Hotkey, %f_HotkeyCombo%, f_DisplayMenu
return


; Navigate to the chosen path
f_Navigate:
; Set destination path to be the selected menu item
f_path = %A_ThisMenuItem%

if f_path =
  return

if f_class = #32770 ; It's a dialog.
{
  ; Activate the window so that if the user is middle-clicking
  ; outside the dialog, subsequent clicks will also work:
  WinActivate ahk_id %f_window_id%
  ; Alt+D to convert Address bar from breadcrumbs to editbox
  Send !{d}
  ; Wait for focus
  Sleep 50
  ; The control that's focused after Alt+D is thus the address bar
  ControlGetFocus, addressbar, a
  ; Put in the chosen path
  ControlSetText %addressbar%, % f_path, a
  ; Go there
  ControlSend %addressbar%, {Enter}, a
  ; Return focus to filename field
  ControlFocus Edit1, a
  return
}
; In a console window, pushd to that directory
else if f_class = ConsoleWindowClass
{
  ; Because sometimes the mclick deactivates it.
  WinActivate, ahk_id %f_window_id%
  ; This will be in effect only for the duration of this thread.
  SetKeyDelay, 0
  ; Clear existing text from prompt and send pushd command
  Send, {Esc}pushd %f_path%{Enter}
  return
}
return


RemoveToolTip:
SetTimer, RemoveToolTip, Off
ToolTip
return

; Display the menu
f_DisplayMenu:
; Get active window identifiers for use in f_Navigate
WinGet, f_window_id, ID, a
WinGetClass, f_class, a
; Don't display menu unless it's a dialog or console window
if f_class not in #32770,ConsoleWindowClass
  return
; Otherwise, put together the menu
GetCurrentPaths() {
  For pwb in ComObjCreate("Shell.Application").Windows
  ; Exclude special locations like Computer, Recycle Bin, Search Results
  If InStr(pwb.FullName, "explorer.exe") && InStr(pwb.LocationURL, "file:///")
  {
    ; Get paths of currently opened Explorer windows
    Menu, CurrentLocations, Add, % pwb.document.folder.self.path, f_Navigate
    ; Same default folder icon for all
    Menu, CurrentLocations, Icon, % pwb.document.folder.self.path, %A_WinDir%\system32\imageres.dll, 4
  }
}
; Get current paths and build menu with them
GetCurrentPaths()
; Don't halt the show if there are no paths and the menu is empty
Menu, CurrentLocations, UseErrorLevel
; Present the menu
Menu, CurrentLocations, Show
; If it doesn't exist show reassuring tooltip
If ErrorLevel
{
  ; Oh! Look at that taskbar. It's empty.
  ToolTip, No folders open
  SetTimer, RemoveToolTip, 1000
}
; Destroy the menu so it doesn't remember previously opened windows
Menu, CurrentLocations, Delete
return

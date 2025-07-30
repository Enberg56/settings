#Requires AutoHotkey v2

global lastMouseClickTime := 0

myGui := Gui()
myGui.Show("Hide")
hWnd := myGui.Hwnd

DllCall("RegisterShellHookWindow", "Ptr", hWnd)
msgNum := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK", "UInt")

OnMessage(msgNum, OnShellMessage)

; Use hotkeys instead of message handling for mouse clicks
*~LButton::
{
    global lastMouseClickTime
    lastMouseClickTime := A_TickCount
}

*~RButton::
{
    global lastMouseClickTime
    lastMouseClickTime := A_TickCount
}

*~MButton::
{
    global lastMouseClickTime
    lastMouseClickTime := A_TickCount
}

OnShellMessage(wParam, lParam, msg, hwnd) {
    global lastMouseClickTime
    try {
        if (wParam = 4 || wParam = 32772) { ; HSHELL_WINDOWACTIVATED | HSHELL_RUDEAPPACTIVATED
            ; Check if left mouse button is down (ignore when dragging)
            mouseDown := GetKeyState("LButton", "P")
            if (!mouseDown && A_TickCount - lastMouseClickTime > 500) {
                Sleep 10
                if WinExist("A") {
                    WinGetPos(&wx, &wy, &ww, &wh, "A")
                    if !IsSet(wx) || !IsSet(wy) || !IsSet(ww) || !IsSet(wh)
                        wx := wy := 100, ww := wh := 100
                    
                    ; Center the cursor (like your version) or use original positioning
                    mx := Round(wx + ww / 2)
                    my := Round(wy + wh / 2)
                    
                    ; Original script positioned at upper right corner:
                    ; mx := Round(wx + ww * 0.85)
                    ; my := Round(wy + wh * 0.35)
                    
                    DllCall("SetCursorPos", "int", mx, "int", my)
                }
            }
        }
    }
    catch as e {
        ; do nothing
    }
}

Persistent

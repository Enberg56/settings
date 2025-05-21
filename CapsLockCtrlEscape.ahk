#Requires AutoHotkey v2.0

; --- CapsLock to Control and Esc ---
*Capslock:: {
    Send("{Blind}{LControl down}")
}
*Capslock up:: {
    Send("{Blind}{LControl up}")
    if (A_PriorKey = "CapsLock") {
        Send("{Esc}")
    }
}

ToggleCaps() {
    if GetKeyState("CapsLock", "T") {
        SetCapsLockState("Off")
    } else {
        SetCapsLockState("On")
    }
}
LShift & RShift::ToggleCaps()
RShift & LShift::ToggleCaps()

; --- SpaceFN Layer ---
global SpaceHeld := false

Space:: {
    global SpaceHeld
    SetTimer(CheckSpaceHold, 200)
}
Space Up:: {
    global SpaceHeld
    if SpaceHeld {
        SpaceHeld := false
    } else {
        Send("{Space}")
    }
    SetTimer(CheckSpaceHold, 0)
}
CheckSpaceHold() {
    global SpaceHeld
    SpaceHeld := true
}
#Space:: {
    global SpaceHeld
    SetTimer(CheckSpaceHold, 0)
    SpaceHeld := false
    Send("{LWin Down}{Space}{LWin Up}")
}
#HotIf SpaceHeld
h::Send("{Blind}{Left}")
j::Send("{Blind}{Down}")
k::Send("{Blind}{Up}")
l::Send("{Blind}{Right}")
#HotIf

>+Space::Send("{Up}")
>+f::Send("{Left}")
>+j::Send("{Right}")

; --- Autoshift for number row and specified symbols only ---

; Number row
for k in ["1","2","3","4","5","6","7","8","9","0"] {
    Hotkey("*" k, AutoShiftHandler)
}

; Symbol keys using scan codes (US QWERTY)
; , . / \ ' [ ] = - `
; SC033 = ,   SC034 = .   SC035 = /   SC02B = \   SC028 = '   SC01A = [   SC01B = ]   SC00D = =   SC00C = -   SC029 = `
global symbolMap := Map(
    "SC033", ",",
    "SC034", ".",
    "SC035", "/",
    "SC02B", "\\",
    "SC028", "'",
    "SC01A", "[",
    "SC01B", "]",
    "SC00D", "=",
    "SC00C", "-",
    "SC029", "``" ; double backtick for literal `
)

for sc, char in symbolMap {
    Hotkey("*" sc, AutoShiftSymbolHandler)
}

AutoShiftHandler(*) {
    ; Don't trigger if Ctrl, Alt, Win, or Shift is held
    if GetKeyState("Ctrl", "P") || GetKeyState("Alt", "P") || GetKeyState("LWin", "P") || GetKeyState("RWin", "P") || GetKeyState("Shift", "P") {
        key := SubStr(A_ThisHotkey, 2)
        Send("{Blind}" key)
        return
    }

    key := SubStr(A_ThisHotkey, 2) ; Remove the '*' prefix

    if WaitForKeyRelease(key, 175) {
        Send("+" key) ; Shifted
    } else {
        Send(key)     ; Normal
    }
    return
}

AutoShiftSymbolHandler(*) {
    if GetKeyState("Ctrl", "P") || GetKeyState("Alt", "P") || GetKeyState("LWin", "P") || GetKeyState("RWin", "P") || GetKeyState("Shift", "P") {
        sc := RegExReplace(A_ThisHotkey, "^\*")
        global symbolMap
        sendKey := symbolMap[sc]
        Send("{Blind}" sendKey)
        return
    }

    sc := RegExReplace(A_ThisHotkey, "^\*")
    global symbolMap
    sendKey := symbolMap[sc]

    if WaitForKeyRelease(sc, 175) {
        Send("+" sendKey) ; Shifted
    } else {
        Send(sendKey)     ; Normal
    }
    return
}

WaitForKeyRelease(key, timeoutMs) {
    start := A_TickCount
    while GetKeyState(key, "P") {
        if (A_TickCount - start > timeoutMs)
            return true ; held
        Sleep(10)
    }
    return false ; tapped
}

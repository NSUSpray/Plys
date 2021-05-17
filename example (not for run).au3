; It was

func BaseMap(const $k)
    local const $key = IsDeclared("k") ? _
        ($k=0x0473 ? "!{F4}" : $k) : @HotKeyPressed
    local const $index = _
        _ArrayBinarySearch($BASE_KEYMAP, $key, 1, 0, 1)
    if $index = -1 then return False
    
    local const $action = $BASE_KEYMAP[$index][0]
    HotKeysSet($BASE_KEYMAP)
    switch $action
        case "RestartProcess"
            Python_Interact("restart_autoit")
        case "SwitchHelp"
            SwitchHelp()
        case else
            Components_Perform("", $action)
    endswitch
    HotKeysSet($BASE_KEYMAP, FuncName(BaseMap))
    return True
endfunc


; and it became

func BaseMap(k)
    const key = IsDeclared("k") ? _
        (k=0x0473 ? "!{F4}" : k) : @HotKeyPressed
    const index = _
        BinSearch(BASE_KEYMAP, key, 1, 0, 1)
    if index = -1 then return False
    
    const action = BASE_KEYMAP[index][0]
    HotKeysSet(BASE_KEYMAP)
    switch action
        case "RestartProcess"
            Python:Interact("restart_autoit")
        case "SwitchHelp"
            SwitchHelp()
        case else
            Components:Perform("", action)
    HotKeysSet(BASE_KEYMAP, FuncName(BaseMap))
    return True

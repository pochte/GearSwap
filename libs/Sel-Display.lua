-- Job State Display
-- Originally written by Talym, modified by Selindrile.
-- Personal modifications and safety fixes.
-- Creates a customizable visual job state display for states managed by Modes.lua.
--
-- Include in get_sets(), user_setup(), or a custom include file.
--
-- Default supported modal states:
-- OffenseMode, DefenseMode, HybridMode, IdleMode, WeaponskillMode,
-- CastingMode, MainStep, AltStep, TreasureMode, TotalHaste, DelayReduction
--
-- Additional modal states can be supported by defining a label in labels below.
-- Boolean states are displayed automatically when enabled.
-- Internal state
local stateList = {}
local stateBool = {}
-- Helper functions
local function get_state(name)
    if not state or not name then
        return nil
    end
    return state[name]
end
local function get_value(name, default)
    local s = get_state(name)
    if not s then
        return default
    end
    if type(s) == 'table' then
        if s.value ~= nil then
            return s.value
        end
        if s.current ~= nil then
            return s.current
        end
    end
    return s
end
local function get_current(name, default)
    local s = get_state(name)
    if not s then
        return default
    end
    if type(s) == 'table' then
        return s.current or s.value or default
    end
    return s
end
local function is_enabled(name)
    local value = get_value(name, false)
    return value == true
end
local function append(text)
    if stateBox and text then
        stateBox:append(tostring(text))
    end
end
local function color(clr, name)
    return clr[name] or clr.w
end
local function safe_string(value, default)
    if value == nil then
        return default or ''
    end
    return tostring(value)
end
-- Initialize display
function init_job_states(job_bools, job_modes)
    stateList = job_modes or {}
    stateBool = job_bools or {}
    if stateBox then
        stateBox:destroy()
        stateBox = nil
    end
    local settings = windower.get_windower_settings()
    local x, y
    if settings.ui_x_res == 1920 and settings.ui_y_res == 1080 then
        x = settings.ui_x_res - 1917
        y = settings.ui_y_res - 18
    else
        x = 0
        y = settings.ui_y_res - 17
    end
    if displayx ~= nil then
        x = displayx
    end
    if displayy ~= nil then
        y = displayy
    end
    local font = displayfont or 'Arial'
    local size = displaysize or 12
    local bold = displaybold
    local bg = displaybg or 0
    local strokewidth = displaystroke or 2
    local stroketransparency = displaytransparancy or 192
    if bold == nil then
        bold = true
    end
    stateBox = texts.new()
    stateBox:pos(x, y)
    stateBox:font(font)
    stateBox:size(size)
    stateBox:bold(bold)
    stateBox:bg_alpha(bg)
    stateBox:right_justified(false)
    stateBox:stroke_width(strokewidth)
    stateBox:stroke_transparency(stroketransparency)
    update_job_states()
end
-- Update display
-- Call from state_change(), job_state_change(), etc.
function update_job_states()
    if not stateBox then
        return
    end
    -- Hide the display when disabled.
    if get_value('DisplayMode', true) == false then
        stateBox:hide()
        return
    end
    -- Colors
    local clr = {
        h = '\\cs(255,192,0)',       -- Highlight
        w = '\\cs(255,255,255)',     -- White
        n = '\\cs(192,192,192)',     -- Neutral
        s = '\\cs(96,96,96)',        -- Inactive
        Fire = '\\cs(255,80,80)',
        Ice = '\\cs(140,160,255)',
        Wind = '\\cs(110,255,110)',
        Earth = '\\cs(220,214,110)',
        Lightning = '\\cs(190,90,190)',
        Water = '\\cs(110,110,255)',
        Light = '\\cs(255,255,155)',
        Dark = '\\cs(90,90,90)',
    }
    if state.DisplayColors then
        clr = state.DisplayColors
    end
    -- Labels
    local labels = {
        Weapons = 'Weapons',
        MainWeapon = 'Main Weapon',
        OffWeapon = 'Off Weapon',
        RangedWeapon = 'Ranged Weapon',
        OffenseMode = 'Offense',
        RangedMode = 'Ranged',
        DefenseMode = 'Defense',
        HybridMode = 'Hybrid',
        IdleMode = 'Idle',
        Passive = 'Passive',
        PetMode = 'Pet Mode',
        AutoManawell = 'Auto Manawell',
        WeaponskillMode = 'Weaponskill',
        CastingMode = 'Casting',
        MainStep = 'Main Step',
        AltStep = 'Alt Step',
        TreasureMode = 'Treasure',
        AutoBuffMode = 'Auto Buff',
        TotalHaste = 'Haste',
        DelayReduction = 'Delay',
        LearningMode = 'Learning',
        ElementalWheel = 'Elemental Wheel',
        MagicBurstMode = 'Magic Burst',
        SkillChainMode = 'Skillchain',
        RecoverMode = 'Recover MP',
        ElementalMode = 'Element',
        ExtraSongsMode = 'Songs',
        AutoStunMode = 'Auto Stun',
        LuzafRing = "Luzaf's Ring",
        AutoDefenseMode = 'Auto Defense',
        AutoTrustMode = 'Auto Trust',
        JugMode = 'Pet',
        RewardMode = 'Reward',
        AutoNukeMode = 'Auto Nuke',
        AutoSongMode = 'Auto Song',
        AutoJumpMode = 'Auto Jump',
        AutoWSMode = 'Auto WS',
        AutoShadowMode = 'Auto Shadows',
        AutoFoodMode = 'Auto Food',
        RngHelper = 'RngHelper',
        Capacity = 'Capacity',
        AutoTankMode = 'Auto Tank',
        CompensatorMode = 'Compensator',
        DrainSwapWeaponMode = 'Drain Swap',
        AutoRuneMode = 'Auto Rune',
        AutoSambaMode = 'Auto Samba',
        PhysicalDefenseMode = 'Physical Defense',
        MagicalDefenseMode = 'Magical Defense',
        ResistDefenseMode = 'Resist Defense',
        RuneElement = 'Rune Element',
        AutoReadyMode = 'Auto Ready',
        AutoPuppetMode = 'Auto Puppet',
        AutoRepairMode = 'Auto Repair',
        PactSpamMode = 'Pact Spam',
        PetWSGear = 'Pet WS Gear',
        DanceStance = 'Dance Stance',
        Stance = 'Stance',
    }
    local info = {}
    local orig = {}
    local spc = '    '
    stateBox:clear()
    append('   ')
    -- Boolean states
    for _, name in ipairs(stateBool) do
        local value = get_value(name, false)
        -- Only display enabled boolean states.
        if value == true then
            if name == 'AutoWSMode' then
                local ranged = is_enabled('RngHelper')
                local ws = ranged and rangedautows or autows
                local tp = ranged and rangedautowstp or autowstp
                append(string.format(
                    '%sAuto WS: %s: %s%s',
                    clr.h,
                    safe_string(ws, 'Unknown'),
                    safe_string(tp, 'Unknown'),
                    clr.n
                ))
                append(spc)
            elseif name == 'AutoDefenseMode' then
                local defense = 'Auto Defense'
                if is_enabled('TankAutoDefense') then
                    defense = 'Auto Defense: Tank'
                end
                append(clr.h .. defense .. clr.n)
                append(spc)
            else
                local label = labels[name] or name
                append(clr.h .. label .. clr.n)
                append(spc)
            end
        end
    end
    append(clr.w)
    -- Modal states
    for _, name in ipairs(stateList) do
        local value = get_value(name)
        local current = get_current(name)
        local default = nil
        if name == 'TotalHaste' or name == 'DelayReduction' then
            info[name] = safe_string(value, '0') .. '%'
            orig[name] = '0%'
        else
            info[name] = safe_string(current)
            local s = get_state(name)
            if type(s) == 'table' then
                default = s[1]
            end
            orig[name] = safe_string(default, '')
        end
        if info[name] ~= orig[name] then
            info[name] = clr.h .. info[name] .. clr.n
        end
        -- Auto Buff
        if name == 'AutoBuffMode' then
            if value and value ~= 'Off' then
                if player.main_job == 'GEO' then
                    append(string.format(
                        '%sAuto Buff: Indi-%s Geo-%s%s  ',
                        clr.h,
                        safe_string(autoindi, 'None'),
                        safe_string(autogeo, 'None'),
                        clr.n
                    ))
                    if autoentrust and autoentrust ~= 'None' then
                        append(string.format(
                            '%sAuto Entrust: %s  Entrustee: %s%s  ',
                            clr.h,
                            safe_string(autoentrust),
                            safe_string(autoentrustee, 'None'),
                            clr.n
                        ))
                    end
                end
                append(string.format(
                    '%sAuto Buff: %s%s',
                    clr.w,
                    clr.h,
                    safe_string(value)
                ))
                append(spc)
            end
        -- Ranged mode
        elseif name == 'RangedMode' then
            append(string.format(
                '%s%s: ${%s}    ',
                clr.w,
                labels[name],
                name
            ))
            if statusammo then
                append('Ammo: ' .. statusammo .. spc)
            end
        -- Offense mode
        elseif name == 'OffenseMode' then
            local defense = get_value('DefenseMode', 'None')
            if defense ~= 'None' then
                append(clr.w .. 'Defense Active: ')
                local defense_modes = {
                    Physical = 'PhysicalDefenseMode',
                    Magical = 'MagicalDefenseMode',
                    Resist = 'ResistDefenseMode',
                }
                local defense_state = defense_modes[defense]
                if defense_state then
                    append(string.format(
                        '%s%s: %s%s',
                        clr.h,
                        safe_string(get_current('DefenseMode', defense)),
                        safe_string(get_current(defense_state, '')),
                        clr.w
                    ))
                else
                    append(clr.h .. safe_string(defense) .. clr.w)
                end
                local extra = get_value('ExtraDefenseMode', 'None')
                if extra ~= 'None' then
                    append(string.format(
                        '%s / %s%s%s',
                        clr.n,
                        clr.h,
                        safe_string(extra),
                        clr.n
                    ))
                end
                append(spc)
            else
                append(string.format(
                    '%s%s: ${%s}',
                    clr.w,
                    labels[name],
                    name
                ))
                if get_state('HybridMode') then
                    local hybrid = get_value('HybridMode', 'Normal')
                    local hybrid_color = hybrid == 'Normal' and clr.w or clr.h
                    append(string.format(
                        '%s / %s%s%s',
                        clr.n,
                        hybrid_color,
                        safe_string(get_current('HybridMode')),
                        clr.n
                    ))
                end
                if get_state('ExtraMeleeMode') then
                    local extra = get_value('ExtraMeleeMode', 'None')
                    local extra_color = extra == 'None' and clr.w or clr.h
                    append(string.format(
                        '%s / %s%s%s',
                        clr.n,
                        extra_color,
                        safe_string(get_current('ExtraMeleeMode')),
                        clr.n
                    ))
                end
                append(spc)
            end
        -- Auto Samba
        elseif name == 'AutoSambaMode' then
            if value and value ~= 'Off' then
                append(string.format(
                    '%sAuto Samba: %s%s%s',
                    clr.w,
                    clr.h,
                    safe_string(value),
                    clr.n
                ))
                append(spc)
            end
        -- Idle mode
        elseif name == 'IdleMode' then
            if value ~= 'Normal' and get_value('DefenseMode', 'None') == 'None' then
                append(string.format(
                    '%s%s: ${%s}    ',
                    clr.w,
                    labels[name],
                    name
                ))
            end
            if is_enabled('Kiting') then
                append(string.format(
                    '%sKiting: %sOn%s    ',
                    clr.w,
                    clr.h,
                    clr.n
                ))
            end
        -- Passive mode
        elseif name == 'Passive' then
            if value ~= 'None' and get_value('DefenseMode', 'None') == 'None' then
                append(string.format(
                    '%s%s: ${%s}    ',
                    clr.w,
                    labels[name],
                    name
                ))
            end
        -- Treasure mode
        elseif name == 'TreasureMode' then
            if (value ~= 'None' or player.main_job == 'THF')
                and get_value('DefenseMode', 'None') == 'None' then
                append(string.format(
                    '%sTreasure: %s%s%s    ',
                    clr.w,
                    clr.h,
                    safe_string(value),
                    clr.n
                ))
            end
        -- Casting mode
        elseif name == 'CastingMode' then
            append(string.format(
                '%s%s: ${%s}    ',
                clr.w,
                labels[name],
                name
            ))
            local mb = get_value('MagicBurstMode', 'Off')
            if mb ~= 'Off' then
                append(string.format(
                    '%sMagic Burst: %s%s%s    ',
                    clr.w,
                    clr.h,
                    safe_string(mb),
                    clr.n
                ))
            end
            local death = get_value('DeathMode', 'Off')
            if death ~= 'Off' then
                append(string.format(
                    '%sDeath Mode: %s%s%s    ',
                    clr.w,
                    clr.h,
                    safe_string(death),
                    clr.n
                ))
            end
        -- Weaponskill mode
        elseif name == 'WeaponskillMode' then
            if value ~= 'Match' then
                append(string.format(
                    '%sWeaponskill: %s%s%s    ',
                    clr.w,
                    clr.h,
                    safe_string(value),
                    clr.n
                ))
            end
            local skillchain = get_value('SkillchainMode', 'Off')
            if skillchain ~= 'Off'
                and get_value('DefenseMode', 'None') == 'None' then
                append(string.format(
                    '%sSkillchain Mode: %s%s%s    ',
                    clr.w,
                    clr.h,
                    safe_string(skillchain),
                    clr.n
                ))
            end
        -- Elemental mode
        elseif name == 'ElementalMode' then
            append(string.format(
                '%sElement: %s%s%s    ',
                clr.w,
                color(clr, safe_string(value)),
                safe_string(value),
                clr.n
            ))
        -- Rune element
        elseif name == 'RuneElement' then
            if not get_value('AutoRuneMode', false)
                and (player.main_job == 'RUN' or player.sub_job == 'RUN') then
                local rune = safe_string(value)
                local rune_color = color(clr, rune)
                if data and data.elements and data.elements.runes_lookup then
                    local element = data.elements.runes_lookup[rune]
                    if element then
                        rune_color = color(clr, element)
                    end
                end
                append(string.format(
                    '%sRune: %s%s%s    ',
                    clr.w,
                    rune_color,
                    rune,
                    clr.n
                ))
            end
        -- Learning mode
        elseif name == 'LearningMode' then
            if value == true
                and get_value('DefenseMode', 'None') == 'None' then
                append(string.format(
                    '%sLearning Mode: %sOn%s    ',
                    clr.w,
                    clr.h,
                    clr.n
                ))
            end
        -- Compensator
        elseif name == 'CompensatorMode' then
            if value ~= 'Never' then
                append(string.format(
                    '%sCompensator: %s%s%s    ',
                    clr.w,
                    clr.h,
                    safe_string(value),
                    clr.n
                ))
            end
        -- Drain swap
        elseif name == 'DrainSwapWeaponMode' then
            if value ~= 'Never' then
                append(string.format(
                    '%sDrain Swap: %s%s%s    ',
                    clr.w,
                    clr.h,
                    safe_string(value),
                    clr.n
                ))
            end
        -- Extra songs
        elseif name == 'ExtraSongsMode' then
            if value ~= 'None' then
                append(string.format(
                    '%sSongs: %s%s%s    ',
                    clr.w,
                    clr.h,
                    safe_string(value),
                    clr.n
                ))
            end
        -- Dancer stance
        elseif name == 'DanceStance' then
            if value ~= 'None' then
                append(string.format(
                    '%sDance: %s%s%s    ',
                    clr.w,
                    clr.h,
                    safe_string(value),
                    clr.n
                ))
            end
        -- General stance
        elseif name == 'Stance' then
            if value ~= 'None' then
                append(string.format(
                    '%sStance: %s%s%s    ',
                    clr.w,
                    clr.h,
                    safe_string(value),
                    clr.n
                ))
            end
        -- Default modal display
        else
            local label = labels[name] or name
            append(string.format(
                '%s%s: ${%s}    ',
                clr.w,
                label,
                name
            ))
        end
    end
    -- Extra defense mode
    local extra_defense = get_value('ExtraDefenseMode', 'None')
    if extra_defense ~= 'None'
        and get_value('DefenseMode', 'None') == 'None' then
        append(string.format(
            '%sExtra Defense: %s%s%s    ',
            clr.w,
            clr.h,
            safe_string(extra_defense),
            clr.n
        ))
    end
    -- Update and display
    stateBox:update(info)
    stateBox:show()
end
-- Clean up display objects
function clear_job_states()
    if stateBox then
        stateBox:destroy()
        stateBox = nil
    end
end
-- Zone handling
windower.raw_register_event('outgoing chunk', function(id, data)
    if id == 0x00D and stateBox then
        stateBox:hide()
    end
end)
windower.raw_register_event('incoming chunk', function(id, data)
    if id == 0x00A and stateBox
        and get_value('DisplayMode', true) ~= false then
        stateBox:show()
    end
end)
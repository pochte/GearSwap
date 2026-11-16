-------------------------
-- Ullona_COR.lua
-- COR job logic. Weapon state tokens are single words; item names are mapped below.
-- WS handling deliberately never equips or reselects the ranged weapon.

main_weapon_items = {
    Naegling = "Naegling",
    Tauret = "Tauret",
    GletisKnife = "Gleti's Knife",
}

off_weapon_items = {
    GletisKnife = "Gleti's Knife",
    Tauret = "Tauret",
    NuskuShield = "Nusku Shield",
}

ranged_weapon_items = {
    Gun1 = "Phineus' Gun",
    -- Gun2 = "Item name when acquired",
    -- Gun3 = "Item name when acquired",
}

function get_sets()
    include('Sel-Include.lua')
    include('Ullona-shortcuts')
end

function job_setup()
    state.MainWeapon = M{['description']='Main Weapon'}
    state.OffWeapon = M{['description']='Off Weapon'}
    state.RangedWeapon = M{['description']='Ranged Weapon'}

    state.CompensatorMode = M{'Never', '300', '1000', 'Always'}
    state.AutoAmmoMode = M(true, 'Auto Ammo Mode')
    state.UseDefaultAmmo = M(true, 'Use Default Ammo')
    state.Buff['Triple Shot'] = buffactive['Triple Shot'] or false
    state.LuzafRing = M(true, "Luzaf's Ring")

    autows = 'Leaden Salute'
    rangedautows = 'Last Stand'
    autofood = 'Sublime Sushi'
    ammostock = 198

    define_roll_values()

    init_job_states(
        {'Capacity','AutoRuneMode','AutoTrustMode','AutoWSMode','AutoShadowMode','AutoFoodMode','RngHelper','AutoStunMode','AutoDefenseMode','LuzafRing'},
        {'AutoBuffMode','AutoSambaMode','MainWeapon','OffWeapon','RangedWeapon','OffenseMode','RangedMode','WeaponskillMode','ElementalMode','IdleMode','Passive','RuneElement','CompensatorMode','TreasureMode'}
    )

    state.MainWeapon:options('None', 'Naegling', 'Tauret', 'GletisKnife')
    state.OffWeapon:options('GletisKnife', 'Tauret', 'NuskuShield', 'None')
    state.RangedWeapon:options('None', 'Gun1', 'Gun2', 'Gun3')
end

-- Equip selected weapons before disabling their slots.
function lock_selected_weapons()
    enable('main', 'sub', 'range')

    local main_weapon = main_weapon_items[state.MainWeapon.value]
    local off_weapon = off_weapon_items[state.OffWeapon.value]
    local ranged_weapon = ranged_weapon_items[state.RangedWeapon.value]

    if main_weapon then equip({main=main_weapon}) end
    if off_weapon then equip({sub=off_weapon}) end
    if ranged_weapon then equip({range=ranged_weapon}) end

    if main_weapon then disable('main') end
    if off_weapon then disable('sub') end
    if ranged_weapon then disable('range') end
end

function job_state_change(stateField, newValue, oldValue)
    if stateField == 'Main Weapon' or stateField == 'MainWeapon' then
        enable('main')
        send_command('wait 0.2; gs c lockselectedweapons')
    elseif stateField == 'Off Weapon' or stateField == 'OffWeapon' then
        enable('sub')
        send_command('wait 0.2; gs c lockselectedweapons')
    elseif stateField == 'Ranged Weapon' or stateField == 'RangedWeapon' then
        enable('range')
        send_command('wait 0.2; gs c lockselectedweapons')
    end
end

function job_filtered_action(spell, eventArgs)
    if spell.type ~= 'WeaponSkill' then return end

    local main = player.equipment.main
    local dagger_equipped = (main == "Tauret" or main == "Gleti's Knife")

    if dagger_equipped and spell.english == 'Savage Blade' then
        windower.chat.input('/ws "Evisceration" '..spell.target.raw)
        cancel_spell()
        eventArgs.cancel = true
    elseif dagger_equipped and spell.english == 'Circle Blade' then
        windower.chat.input('/ws "Aeolian Edge" '..spell.target.raw)
        cancel_spell()
        eventArgs.cancel = true
    end
end

function job_pretarget(spell, spellMap, eventArgs)
end

function job_precast(spell, spellMap, eventArgs)
    if spell.action_type == 'Ranged Attack' then
        state.CombatWeapon:set(player.equipment.range)
    elseif spell.type == 'CorsairShot' then
        if not player.inventory['Trump Card'] and player.satchel['Trump Card'] then
            send_command('get "Trump Card" satchel')
            eventArgs.cancel = true
            windower.chat.input:schedule(1, '/ja "'..spell.english..'" '..spell.target.raw)
            return
        end
    end

    if spell.action_type == 'Ranged Attack' or spell.type == 'CorsairShot'
        or spell.english == 'Shadowbind'
        or (spell.type == 'WeaponSkill' and spell.skill == 'Marksmanship') then
        do_bullet_checks(spell, spellMap, eventArgs)
    end
end

function job_post_midcast(spell, spellMap, eventArgs)
    if spell.action_type == 'Ranged Attack' then
        if state.Buff['Triple Shot'] and sets.buff['Triple Shot'] then
            if sets.buff['Triple Shot'][state.RangedMode.value] then
                equip(sets.buff['Triple Shot'][state.RangedMode.value])
            else
                equip(sets.buff['Triple Shot'])
            end
        end
        if state.Buff.Barrage and sets.buff.Barrage then
            equip(sets.buff.Barrage)
        end
    end
end

function job_self_command(commandArgs, eventArgs)
    if commandArgs[1]:lower() == 'elemental' and commandArgs[2]:lower() == 'quickdraw' then
        windower.chat.input('/ja "'..data.elements.quickdraw_of[state.ElementalMode.value]..' Shot" <t>')
        eventArgs.handled = true
    elseif commandArgs[1]:lower() == 'lockselectedweapons' then
        lock_selected_weapons()
        eventArgs.handled = true
    end
end

function job_midcast(spell, action, spellMap, eventArgs)
    -- Never fire premium Quick Draw bullets accidentally with a ranged attack.
    if spell.action_type == 'Ranged Attack' then
        local ammo = player.equipment.ammo
        if ammo and (ammo:startswith('Hauksbok') or ammo == 'Animikii Bullet') then
            enable('ammo')
            equip({ammo=empty})
            add_to_chat(123, "Abort Ranged Attack: Don't shoot your good ammo!")
            return
        end
    end
end

function job_aftercast(spell, spellMap, eventArgs)
    if spell.type == 'CorsairRoll' and not spell.interrupted then
        display_roll_info(spell)
    end

    -- Only restore default ammo after a normal ranged attack. Never overwrite WS ammo.
    if spell.action_type == 'Ranged Attack' and state.UseDefaultAmmo.value then
        enable('ammo')
        equip({ammo=gear.RAbullet})
    end

    -- A WS must not trigger weapon re-selection: in particular, do not touch range.
    if spell.type ~= 'WeaponSkill' then
        send_command('wait 0.1; gs c lockselectedweapons')
    end
end

function job_buff_change(buff, gain)
    if buff:contains('Aftermath') then
        classes.CustomRangedGroups:clear()
        if player.equipment.range == 'Death Penalty' and buffactive['Aftermath: Lv.3'] then
            classes.CustomRangedGroups:append('AM')
        end
    end
end

function job_customize_melee_set(meleeSet)
    return apply_selected_weapons(meleeSet)
end

function job_customize_idle_set(idleSet)
    return apply_selected_weapons(idleSet)
end

function apply_selected_weapons(gearSet)
    local main_weapon = main_weapon_items[state.MainWeapon.value]
    local off_weapon = off_weapon_items[state.OffWeapon.value]
    local ranged_weapon = ranged_weapon_items[state.RangedWeapon.value]

    if main_weapon then gearSet = set_combine(gearSet, {main=main_weapon}) end
    if off_weapon then gearSet = set_combine(gearSet, {sub=off_weapon}) end
    if ranged_weapon then gearSet = set_combine(gearSet, {range=ranged_weapon}) end
    return gearSet
end

function job_update(cmdParams, eventArgs)
    send_command('wait 0.1; gs c lockselectedweapons')
end

function job_post_precast(spell, spellMap, eventArgs)
    if spell.type == 'WeaponSkill' then
        local ranged_ws = spell.skill == 'Marksmanship'
        local ws_set = ranged_ws and sets.precast.WS.Ranged or sets.precast.WS.Melee
        local mode = state.WeaponskillMode.value
        local ws_acc_mode = check_ws_acc()
        local use_acc = (mode == 'Acc') or (mode == 'Match' and ws_acc_mode and ws_acc_mode:contains('Acc'))

        if mode == 'Proc' and sets.precast.WS.Proc then
            equip(sets.precast.WS.Proc)
        elseif use_acc and sets.precast.WS.Acc then
            equip(ranged_ws and (sets.precast.WS.Ranged.Acc or sets.precast.WS.Acc)
                or (sets.precast.WS.Melee.Acc or sets.precast.WS.Acc))
        else
            equip(ws_set)
        end

        -- Choose ammunition independently of the armour set. No range slot is touched.
        local ws_ammo = gear.WSbullet
        if ranged_ws and data.weaponskills.elemental:contains(spell.english) then
            ws_ammo = gear.MAbullet
        end
        enable('ammo')
        equip({ammo=ws_ammo})

    elseif spell.type == 'CorsairShot' and spell.english ~= 'Light Shot' and spell.english ~= 'Dark Shot' then
        if (state.WeaponskillMode.value == 'Proc' or state.CastingMode.value == 'Proc') and sets.precast.CorsairShot.Proc then
            equip(sets.precast.CorsairShot.Proc)
        elseif state.CastingMode.value == 'Fodder' and sets.precast.CorsairShot.Damage then
            equip(sets.precast.CorsairShot.Damage)
        end
    elseif spell.action_type == 'Ranged Attack' then
        if buffactive.Flurry then
            if sets.precast.RA.Flurry and lastflurry == 1 then
                equip(sets.precast.RA.Flurry)
            elseif sets.precast.RA.Flurry2 and lastflurry == 2 then
                equip(sets.precast.RA.Flurry2)
            end
        end
    elseif spell.type == 'CorsairRoll' or spell.english == 'Double-Up' then
        if state.LuzafRing.value and item_available("Luzaf's Ring") then
            equip(sets.precast.LuzafRing)
        end
        if spell.type == 'CorsairRoll' and state.CompensatorMode.value ~= 'Never'
            and (state.CompensatorMode.value == 'Always' or tonumber(state.CompensatorMode.value) > player.tp) then
            if item_available('Compensator') then
                enable('range')
                equip({range='Compensator'})
            end
            if sets.precast.CorsairRoll.main and sets.precast.CorsairRoll.main ~= player.equipment.main then
                enable('main')
                equip({main=sets.precast.CorsairRoll.main})
            end
        end
    elseif spell.english == 'Fold' and buffactive['Bust'] == 2 and sets.precast.FoldDoubleBust then
        equip(sets.precast.FoldDoubleBust)
    end
end

function define_roll_values()
    rolls = {
        ["Corsair's Roll"]={lucky=5, unlucky=9, bonus='Experience Points'},
        ['Ninja Roll']={lucky=4, unlucky=8, bonus='Evasion'},
        ["Hunter's Roll"]={lucky=4, unlucky=8, bonus='Accuracy'},
        ['Chaos Roll']={lucky=4, unlucky=8, bonus='Attack'},
        ["Magus's Roll"]={lucky=2, unlucky=6, bonus='Magic Defense'},
        ["Healer's Roll"]={lucky=3, unlucky=7, bonus='Cure Potency Received'},
        ['Puppet Roll']={lucky=3, unlucky=7, bonus='Pet Magic Accuracy/Attack'},
        ['Choral Roll']={lucky=2, unlucky=6, bonus='Spell Interruption Rate'},
        ["Monk's Roll"]={lucky=3, unlucky=7, bonus='Subtle Blow'},
        ['Beast Roll']={lucky=4, unlucky=8, bonus='Pet Attack'},
        ['Samurai Roll']={lucky=2, unlucky=6, bonus='Store TP'},
        ["Evoker's Roll"]={lucky=5, unlucky=9, bonus='Refresh'},
        ["Rogue's Roll"]={lucky=5, unlucky=9, bonus='Critical Hit Rate'},
        ["Warlock's Roll"]={lucky=4, unlucky=8, bonus='Magic Accuracy'},
        ["Fighter's Roll"]={lucky=5, unlucky=9, bonus='Double Attack Rate'},
        ['Drachen Roll']={lucky=4, unlucky=8, bonus='Pet Accuracy'},
        ["Gallant's Roll"]={lucky=3, unlucky=7, bonus='Defense'},
        ["Wizard's Roll"]={lucky=5, unlucky=9, bonus='Magic Attack'},
        ["Dancer's Roll"]={lucky=3, unlucky=7, bonus='Regen'},
        ["Scholar's Roll"]={lucky=2, unlucky=6, bonus='Conserve MP'},
        ["Bolter's Roll"]={lucky=3, unlucky=9, bonus='Movement Speed'},
        ["Caster's Roll"]={lucky=2, unlucky=7, bonus='Fast Cast'},
        ["Courser's Roll"]={lucky=3, unlucky=9, bonus='Snapshot'},
        ["Blitzer's Roll"]={lucky=4, unlucky=9, bonus='Attack Delay'},
        ["Tactician's Roll"]={lucky=5, unlucky=8, bonus='Regain'},
        ["Allies' Roll"]={lucky=3, unlucky=10, bonus='Skillchain Damage'},
        ["Miser's Roll"]={lucky=5, unlucky=7, bonus='Save TP'},
        ["Companion's Roll"]={lucky=2, unlucky=10, bonus='Pet Regain and Regen'},
        ["Avenger's Roll"]={lucky=4, unlucky=8, bonus='Counter Rate'},
        ["Naturalist's Roll"]={lucky=3, unlucky=7, bonus='Enhancing Duration'},
        ["Runeist's Roll"]={lucky=4, unlucky=8, bonus='Magic Evasion'},
    }
end

function display_roll_info(spell)
    local rollinfo = rolls[spell.english]
    local rollsize = state.LuzafRing.value and 'Large' or 'Small'
    if rollinfo then
        add_to_chat(217, spell.english..' provides a bonus to '..rollinfo.bonus..'. Roll size: '..rollsize)
        add_to_chat(217, 'Lucky roll is '..tostring(rollinfo.lucky)..', Unlucky roll is '..tostring(rollinfo.unlucky)..'.')
    end
end

function do_bullet_checks(spell, spellMap, eventArgs)
    local equipped_ammo = player.equipment.ammo
    if equipped_ammo == 'Animikii Bullet' or equipped_ammo == 'Hauksbok Bullet' then
        cancel_spell()
        eventArgs.cancel = true
        enable('ammo')
        equip({ammo=item_available(gear.RAbullet) and gear.RAbullet or empty})
        add_to_chat(123, "Abort: Don't shoot your good ammo!")
        return
    end

    local bullet_name
    local bullet_min_count = 1

    if spell.type == 'WeaponSkill' then
        if spell.skill ~= 'Marksmanship' then return end
        bullet_name = data.weaponskills.elemental:contains(spell.english) and gear.MAbullet or gear.WSbullet
    elseif spell.type == 'CorsairShot' then
        bullet_name = gear.QDbullet
    elseif spell.action_type == 'Ranged Attack' then
        bullet_name = gear.RAbullet
        if state.Buff['Triple Shot'] then bullet_min_count = 3 end
    else
        return
    end

    local available_bullets = count_available_ammo(bullet_name)
    if not (available_bullets > 0) then
        if spell.type == 'CorsairShot' and equipped_ammo ~= 'empty' then
            add_to_chat(217, 'No Quick Draw ammo available, using equipped ammo: ('..equipped_ammo..')')
            return
        elseif spell.type == 'WeaponSkill' and (equipped_ammo == gear.RAbullet or equipped_ammo == gear.WSbullet or equipped_ammo == gear.MAbullet) then
            add_to_chat(217, 'No weaponskill ammo available, using equipped ammo: ('..equipped_ammo..')')
            return
        else
            add_to_chat(217, 'No ammo ('..tostring(bullet_name)..') available for that action.')
            eventArgs.cancel = true
            return
        end
    end

    if spell.type ~= 'CorsairShot' and bullet_name == gear.QDbullet and available_bullets <= bullet_min_count then
        add_to_chat(217, 'No ammo will be left for Quick Draw. Cancelling.')
        eventArgs.cancel = true
        return
    end

    if spell.type ~= 'CorsairShot' and available_bullets > 0 and available_bullets <= options.ammo_warning_limit then
        local msg = '**** LOW AMMO WARNING: '..bullet_name..' ****'
        local border = string.rep('*', #msg)
        add_to_chat(217, border)
        add_to_chat(217, msg)
        add_to_chat(217, border)
    end
end

function job_tick()
    if check_ammo() then return true end
    return false
end

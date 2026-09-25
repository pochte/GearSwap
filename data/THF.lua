-- THF.lua


-- Weapon-mode option values must stay single-word (spaces/apostrophes break the console
-- status bar display) -- real item names are looked up from the short token instead.
main_weapon_items = {
    Naegling = "Naegling",
    Tauret = "Tauret"
}

off_weapon_items = {
    GletisKnife = "Gleti's Knife",
    Sandung = "Sandung"
}

ranged_weapon_items = {
    Wingcutter = "Wingcutter"
}



-------------------------------------------------------------------------------------------------------------------
-- Initialization function for this job file.
-------------------------------------------------------------------------------------------------------------------

function get_sets()

    -- Load and initialize the include file.
    include('Sel-Include.lua')
    include('Ullona-shortcuts')

end



-------------------------------------------------------------------------------------------------------------------
-- Job setup.
-------------------------------------------------------------------------------------------------------------------

function job_setup()

    -- Construct our custom weapon-lock states here, before init_job_states() runs below.
    -- Unlike the library's own built-in states (Weapons, OffenseMode, etc.), these are new
    -- and must exist before init_job_states() reads them.
    state.MainWeapon = M{['description']='Main Weapon'}
    state.OffWeapon = M{['description']='Off Weapon'}
    state.RangedWeapon = M{['description']='Ranged Weapon'}


    state.Buff['Sneak Attack'] = buffactive['Sneak Attack'] or false
    state.Buff['Trick Attack'] = buffactive['Trick Attack'] or false
    state.Buff['Feint'] = buffactive['Feint'] or false
    state.Buff['Aftermath: Lv.3'] = buffactive['Aftermath: Lv.3'] or false


    -- For th_action_check() below: extends Treasure Hunter credit beyond the standard
    -- ranged-attack/Aeolian-Edge cases.
    info.default_ja_ids = S{35, 204}
    info.default_u_ja_ids = S{201, 202, 203, 205, 207}


    autows = "Rudra's Storm"
    rangedautows = "Last Stand"
    autofood = 'Soy Ramen'


    update_melee_groups()


    init_job_states(
        {
            "Capacity",
            "AutoRuneMode",
            "AutoTrustMode",
            "AutoNukeMode",
            "AutoWSMode",
            "AutoShadowMode",
            "AutoFoodMode",
            "AutoStunMode",
            "AutoDefenseMode",
        },
        {
            "AutoBuffMode",
            "AutoSambaMode",
            "MainWeapon",
            "OffWeapon",
            "OffenseMode",
            "WeaponskillMode",
            "IdleMode",
            "Passive",
            "RuneElement",
            "ElementalMode",
            "CastingMode",
        }
    )

end



-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

function job_filtered_action(spell, eventArgs)

    if spell.type == 'WeaponSkill' then

        local available_ws =
            S(windower.ffxi.get_abilities().weapon_skills)

        -- WS 112 is Double Thrust, meaning a Spear is equipped.
        if available_ws:contains(32) then

            if spell.english == "Rudra's Storm" then

                windower.chat.input(
                    '/ws "Savage Blade" '..spell.target.raw
                )

                cancel_spell()
                eventArgs.cancel = true

            end
        end
    end

end



function job_pretarget(spell, spellMap, eventArgs)

end



function job_precast(spell, spellMap, eventArgs)

    -- Amnesia -> Ecphoria Ring
    check_ecphoria_for_ja(spell)


    -- SATA -> Assassin's Charge chain
    if spell.type == 'WeaponSkill'
        and state.SATAMode
        and state.SATAMode.value == true then

        local abil_recasts =
            windower.ffxi.get_ability_recasts()


        if not buffactive['Sneak Attack'] then

            local sa_id =
                get_ability_recast_id_by_name('Sneak Attack')

            if sa_id
                and abil_recasts[sa_id] < latency then

                eventArgs.cancel = true
                cancel_spell()


                windower.chat.input(
                    '/ja "Sneak Attack" <me>'
                )

                windower.chat.input:schedule(
                    1,
                    '/ws "'..spell.english..'" '..spell.target.raw..''
                )

                return

            end
        end


        if not buffactive['Trick Attack'] then

            local ta_id =
                get_ability_recast_id_by_name('Trick Attack')

            if ta_id
                and abil_recasts[ta_id] < latency then

                eventArgs.cancel = true
                cancel_spell()


                windower.chat.input(
                    '/ja "Trick Attack" <me>'
                )

                windower.chat.input:schedule(
                    1,
                    '/ws "'..spell.english..'" '..spell.target.raw..''
                )

                return

            end
        end
    end


    -- Assassin's Charge before weapon skills.
    if spell.type == 'WeaponSkill'
        and not buffactive["Assassin's Charge"] then

        local abil_recasts =
            windower.ffxi.get_ability_recasts()

        local ac_id =
            get_ability_recast_id_by_name("Assassin's Charge")


        if ac_id
            and abil_recasts[ac_id] < latency then

            eventArgs.cancel = true
            cancel_spell()


            windower.chat.input(
                '/ja "Assassin\'s Charge" <me>'
            )

            windower.chat.input:schedule(
                1,
                '/ws "'..spell.english..'" '..spell.target.raw..''
            )

            return

        end
    end

end



function job_post_precast(spell, spellMap, eventArgs)

    if spell.type == 'WeaponSkill' then

        if (spell.english == 'Aeolian Edge'
            or spell.english == 'Cyclone')
            and state.TreasureMode.value ~= 'None' then

            equip(sets.TreasureHunter)

            return
        end


        local WSset =
            standardize_set(
                get_precast_set(spell, spellMap)
            )

        local wsacc = check_ws_acc()


        if WSset.ear1 == "Moonshade Earring"
            or WSset.ear2 == "Moonshade Earring" then

            -- Replace Moonshade Earring if we're at cap TP.
            if get_effective_player_tp(spell, WSset) > 3200 then

                if wsacc:contains('Acc')
                    and not state.Buff['Sneak Attack']
                    and not state.Buff['Trick Attack']
                    and sets.AccMaxTP then

                    equip(
                        sets.AccMaxTP[spell.english]
                        or sets.AccMaxTP
                    )

                elseif sets.MaxTP then

                    equip(
                        sets.MaxTP[spell.english]
                        or sets.MaxTP
                    )

                end
            end
        end


        if state.AmbushMode.value == true
            and sets.Ambush then

            if state.Buff['Sneak Attack'] == false
                and state.Buff['Trick Attack'] == false then

                equip(sets.Ambush)

            end
        end
    end


    if spell.english == 'Sneak Attack'
        or spell.english == 'Trick Attack'
        or spell.type == 'WeaponSkill' then

        if state.TreasureMode.value == 'SATA'
            or state.TreasureMode.value == 'Fulltime' then

            equip(sets.TreasureHunter)

        end
    end

end



function job_post_midcast(spell, spellMap, eventArgs)

    if state.TreasureMode.value ~= 'None'
        and spell.action_type == 'Ranged Attack' then

        equip(sets.TreasureHunter)

    end

end



function job_aftercast(spell, spellMap, eventArgs)

    -- Weaponskills wipe SATA/Feint.
    -- Turn those state vars off before default gearing is attempted.
    if spell.type == 'WeaponSkill'
        and not spell.interrupted then

        state.Buff['Sneak Attack'] = false
        state.Buff['Trick Attack'] = false
        state.Buff['Feint'] = false

    end

end



function job_post_aftercast(spell, spellMap, eventArgs)

    -- If Feint is active, put that gear set on top of regular gear.
    check_buff('Feint', eventArgs)

end



-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for non-casting events.
-------------------------------------------------------------------------------------------------------------------

function job_buff_change(buff, gain)

    -- Sel-Include.lua handles the user_buff_change dispatch.
    -- Do not call user_buff_change() here or it will fire twice.
    update_melee_groups()

end



-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

function get_custom_wsmode(spell, spellMap, defaut_wsmode)

    local wsmode


    if state.Buff['Sneak Attack'] then

        wsmode = 'SA'

    end


    if state.Buff['Trick Attack'] then

        wsmode = (wsmode or '') .. 'TA'

    end


    return wsmode

end



-------------------------------------------------------------------------------------------------------------------
-- Weapon lock enforcement.
--
-- The normal idle/melee customization puts the selected weapons into the set.
-- This function is an additional final enforcement step.
--
-- GearSwap can subsequently process another equipment update, so we explicitly
-- re-equip the selected weapons here after the normal gear handling has happened.
-------------------------------------------------------------------------------------------------------------------

function enforce_weapon_locks()

    -- Main weapon.
    if state.MainWeapon
        and state.MainWeapon.value ~= 'None' then

        local weapon =
            main_weapon_items[state.MainWeapon.value]

        if weapon then

            equip({
                main = weapon
            })

        end
    end


    -- Offhand weapon.
    if state.OffWeapon
        and state.OffWeapon.value ~= 'None' then

        local weapon =
            off_weapon_items[state.OffWeapon.value]

        if weapon then

            equip({
                sub = weapon
            })

        end
    end


    -- Ranged weapon.
    if state.RangedWeapon
        and state.RangedWeapon.value ~= 'None' then

        local weapon =
            ranged_weapon_items[state.RangedWeapon.value]

        if weapon then

            equip({
                range = weapon,
                ammo = empty
            })

        end
    end

end



-------------------------------------------------------------------------------------------------------------------
-- Called any time we attempt to handle automatic gear equips.
-------------------------------------------------------------------------------------------------------------------

function job_handle_equipping_gear(playerStatus, eventArgs)

    -- Check for SATA when equipping gear.
    check_buff('Sneak Attack', eventArgs)
    check_buff('Trick Attack', eventArgs)


    -- IMPORTANT:
    -- Re-apply the selected weapon locks LAST.
    -- This prevents the normal gear set from replacing the selected weapons.
    enforce_weapon_locks()

end



-------------------------------------------------------------------------------------------------------------------
-- Weapon selection
-------------------------------------------------------------------------------------------------------------------

function job_customize_idle_set(idleSet)

    -- Main weapon.
    if state.MainWeapon.value ~= 'None' then

        local weapon =
            main_weapon_items[state.MainWeapon.value]

        if weapon then

            idleSet = set_combine(
                idleSet,
                {
                    main = weapon
                }
            )

        end
    end


    -- Offhand weapon.
    if state.OffWeapon.value ~= 'None' then

        local weapon =
            off_weapon_items[state.OffWeapon.value]

        if weapon then

            idleSet = set_combine(
                idleSet,
                {
                    sub = weapon
                }
            )

        end
    end


    -- Ranged weapon.
    if state.RangedWeapon.value ~= 'None' then

        local weapon =
            ranged_weapon_items[state.RangedWeapon.value]

        if weapon then

            idleSet = set_combine(
                idleSet,
                {
                    range = weapon,
                    ammo = empty
                }
            )

        end
    end


    return idleSet

end



-- Modify the default melee set after it was constructed.
function job_customize_melee_set(meleeSet)

    -- Main weapon.
    if state.MainWeapon.value ~= 'None' then

        local weapon =
            main_weapon_items[state.MainWeapon.value]

        if weapon then

            meleeSet = set_combine(
                meleeSet,
                {
                    main = weapon
                }
            )

        end
    end


    -- Offhand weapon.
    if state.OffWeapon.value ~= 'None' then

        local weapon =
            off_weapon_items[state.OffWeapon.value]

        if weapon then

            meleeSet = set_combine(
                meleeSet,
                {
                    sub = weapon
                }
            )

        end
    end


    -- Ranged weapon.
    if state.RangedWeapon.value ~= 'None' then

        local weapon =
            ranged_weapon_items[state.RangedWeapon.value]

        if weapon then

            meleeSet = set_combine(
                meleeSet,
                {
                    range = weapon,
                    ammo = empty
                }
            )

        end
    end


    -- Ambush mode.
    if state.AmbushMode.value == true
        and sets.Ambush then

        meleeSet =
            set_combine(
                meleeSet,
                sets.Ambush
            )

    end


    -- Full-time Treasure Hunter.
    if state.TreasureMode.value == 'Fulltime' then

        meleeSet =
            set_combine(
                meleeSet,
                sets.TreasureHunter
            )

    end


    -- Extra melee modes.
    if state.ExtraMeleeMode.value == 'Suppa' then

        meleeSet =
            set_combine(
                meleeSet,
                sets.Suppa
            )

    elseif state.ExtraMeleeMode.value == 'DWMax' then

        meleeSet =
            set_combine(
                meleeSet,
                sets.DWMax
            )

    elseif state.ExtraMeleeMode.value == 'Parry' then

        meleeSet =
            set_combine(
                meleeSet,
                sets.Parry
            )

    end


    return meleeSet

end



-------------------------------------------------------------------------------------------------------------------
-- Custom commands
-------------------------------------------------------------------------------------------------------------------

function job_self_command(commandArgs, eventArgs)

end



function job_tick()

    return false

end



-------------------------------------------------------------------------------------------------------------------
-- Called by the 'update' self-command.
-------------------------------------------------------------------------------------------------------------------

function job_update(cmdParams, eventArgs)

    th_update(cmdParams, eventArgs)
    update_melee_groups()

end



-------------------------------------------------------------------------------------------------------------------
-- Function to display the current relevant user state when doing an update.
-------------------------------------------------------------------------------------------------------------------

function display_current_job_state(eventArgs)

    local msg = 'Melee'


    if state.CombatForm.has_value then

        msg =
            msg ..
            ' (' ..
            state.CombatForm.value ..
            ')'

    end


    msg = msg .. ': '


    msg =
        msg ..
        state.OffenseMode.value


    if state.HybridMode.value ~= 'Normal' then

        msg =
            msg ..
            '/' ..
            state.HybridMode.value

    end


    msg =
        msg ..
        ', WS: ' ..
        state.WeaponskillMode.value


    if state.DefenseMode.value ~= 'None' then

        msg =
            msg ..
            ', Defense: ' ..
            state[
                state.DefenseMode.value ..
                'DefenseMode'
            ].value

    end


    if state.Kiting.value == true then

        msg =
            msg ..
            ', Kiting'

    end


    if state.PCTargetMode.value ~= 'default' then

        msg =
            msg ..
            ', Target PC: ' ..
            state.PCTargetMode.value

    end


    if state.SelectNPCTargets.value == true then

        msg =
            msg ..
            ', Target NPCs'

    end


    msg =
        msg ..
        ', TH: ' ..
        state.TreasureMode.value


    add_to_chat(122, msg)

    eventArgs.handled = true

end



-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

-- State buff checks that will equip buff gear and mark the event as handled.
function check_buff(buff_name, eventArgs)

    if state.Buff[buff_name] then

        equip(
            sets.buff[buff_name]
            or {}
        )


        if state.TreasureMode.value == 'SATA'
            or state.TreasureMode.value == 'Fulltime' then

            equip(sets.TreasureHunter)

        end


        eventArgs.handled = true

    end

end



function update_melee_groups()

    if player.equipment.main then

        classes.CustomMeleeGroups:clear()


        if player.equipment.main == "Vajra"
            and state.Buff['Aftermath: Lv.3'] then

            classes.CustomMeleeGroups:append('AM')

        end
    end

end



-------------------------------------------------------------------------------------------------------------------
-- Treasure Hunter action checks
-------------------------------------------------------------------------------------------------------------------

function th_action_check(category, param)

    if category == 2
        or (category == 3 and param == 30)
        or (category == 6 and info.default_ja_ids:contains(param))
        or (category == 14 and info.default_u_ja_ids:contains(param)) then

        return true

    end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GEO.lua — Changelog
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Setup functions for this job. Generally should not be modified.
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Initialization function for this job file.
function get_sets()
    -- Make sure GearSwap's nested set tables exist before any included gear file
    -- attempts to define sets.precast.WS, sets.midcast, etc.
    sets = sets or {}
    sets.precast = sets.precast or {}
    sets.midcast = sets.midcast or {}
    sets.idle = sets.idle or {}
    sets.engaged = sets.engaged or {}
    sets.buff = sets.buff or {}

    -- Load and initialize the include files.
    include('Sel-Include.lua')
    include('Ullona-shortcuts')
    include('Smart-Caster.lua')
end

-- Setup vars that are user-independent. state.Buff vars initialized here will automatically be tracked.
function job_setup()

    state.Buff.Entrust = buffactive.Entrust or false
    state.Buff['Blaze of Glory'] = buffactive['Blaze of Glory'] or false

    LowTierNukes = S{'Stone', 'Water', 'Aero', 'Fire', 'Blizzard', 'Thunder',
        'Stone II', 'Water II', 'Aero II', 'Fire II', 'Blizzard II', 'Thunder II',
        'Stonega', 'Waterga', 'Aeroga', 'Firaga', 'Blizzaga', 'Thundaga'}
    MaxNukeTier = 5
    autows = 'Realmrazer'
    autofood = 'Miso Ramen'
    autoindi = 'Torpor'
    autoentrust = 'Fury'
    autoentrustee = '<p1>'
    autogeo = 'Frailty'
    autoindimelee = 'Fury'
    autogeomelee  = 'Frailty'
    autoindimage  = 'Focus'
    autogeomage   = 'Languor'

    last_indi = nil
    last_geo = nil
    blazelocked = false
    used_ecliptic = false

    state.ShowDistance = M(true, 'Show Geomancy Buff/Debuff distance')
    state.AutoEntrust = M(false, 'AutoEntrust Mode')
    state.CombatEntrustOnly = M(true, 'Combat Entrust Only Mode')
    state.AutoGeoAbilities = M(true, 'Use Geo Abilities Automatically')
    state.PetHPMode = M(false, 'Pet HP Mode')

    indi_timer = ''
    indi_duration = 180

    init_job_states({
        "Capacity",
        "AutoRuneMode",
        "AutoTrustMode",
        "AutoNukeMode",
        "AutoWSMode",
        "AutoShadowMode",
        "AutoFoodMode",
        "AutoStunMode",
        "AutoDefenseMode",
        "PetHPMode"
    },{
        "AutoBuffMode",
        "Weapons",
        "OffenseMode",
        "WeaponskillMode",
        "IdleMode",
        "Passive",
        "RuneElement",
        "ElementalMode",
        "CastingMode",
        "TreasureMode",
    })
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------=
function job_filtered_action(spell, eventArgs)
end
function job_filter_precast(spell, spellMap, eventArgs)

    if spell.english:startswith('Geo-') and pet.isvalid then
        eventArgs.cancel = true
        windower.chat.input('/ja "Full Circle" <me>')

        -- FIX: windower.chat.input is a function and does not have a :schedule method.
        send_command('@wait 1.3; input /ma "'..spell.english..'" '..spell.target.raw)
    end

end
function job_pretarget(spell, spellMap, eventArgs)

    if spell.type == 'Geomancy' then

        if spell.english:startswith('Indi') then

            if state.Buff.Entrust then

                if spell.target.type == 'SELF' then
                    add_to_chat(204, 'Entrust active - You can\'t entrust yourself.')
                    eventArgs.cancel = true
                end

            elseif spell.target.type ~= 'SELF' then

                if state.AutoEntrust.value
                    and ((spell.target.type == 'PLAYER' and not spell.target.charmed)
                    or (spell.target.type == 'NPC'))
                    and spell.target.in_party then

                    local spell_recasts = windower.ffxi.get_spell_recasts()
                    local abil_recasts = windower.ffxi.get_ability_recasts()

                    eventArgs.cancel = true

                    if spell_recasts[spell.recast_id] > 1.5 then
                        add_to_chat(123,
                            'Abort: ['..spell.english..'] waiting on recast. ('..
                            seconds_to_clock(spell_recasts[spell.recast_id]/60)..')')

                    elseif abil_recasts[93] > 0 then
                        add_to_chat(123,
                            'Abort: [Entrust] waiting on recast. ('..
                            seconds_to_clock(abil_recasts[93])..')')

                    else
                        send_command(
                            '@input /ja "Entrust" <me>; wait 1.1; input /ma "'..
                            spell.name..'" '..spell.target.name
                        )
                    end

                elseif spell.target.raw == '<t>' then
                    change_target('<me>')
                end
            end

        elseif spell.english:startswith('Geo') then

            if set.contains(spell.targets, 'Enemy') then

                if ((spell.target.type == 'PLAYER' and not spell.target.charmed)
                    or (spell.target.type == 'NPC' and spell.target.in_party)) then

                    eventArgs.cancel = true
                end

            elseif not (
                (spell.target.type == 'PLAYER'
                    and not spell.target.charmed
                    and spell.target.in_party)
                or (spell.target.type == 'NPC' and spell.target.in_party)
                or spell.target.raw == '<stpt>'
                or spell.target.raw == '<stal>'
                or spell.target.raw == '<st>'
            ) then
                change_target('<me>')
            end
        end
    end
end

function job_precast(spell, spellMap, eventArgs)

    -- Amnesia -> Ecphoria Ring.
    check_ecphoria_for_ja(spell)

    if spell.action_type == 'Magic' then

        if spellMap == 'Cure' or spellMap == 'Curaga' then

            gear.default.obi_back = gear.obi_cure_back
            gear.default.obi_waist = gear.obi_cure_waist

        elseif spell.skill == 'Elemental Magic' then

            if LowTierNukes:contains(spell.english)
                or spell.english:endswith('helix') then

                gear.default.obi_back = gear.obi_low_nuke_back
                gear.default.obi_waist = gear.obi_low_nuke_waist

            else

                gear.default.obi_back = gear.obi_high_nuke_back
                gear.default.obi_waist = gear.obi_high_nuke_waist
            end
        end

        if state.CastingMode.value == 'Proc' then
            classes.CustomClass = 'Proc'
        end

        smart_caster_precast(spell, spellMap, eventArgs)

    elseif buffactive.Bolster
        and (spell.english == 'Blaze of Glory'
        or spell.english == 'Ecliptic Attrition') then

        eventArgs.cancel = true
        add_to_chat(123,'Abort: Bolster maxes the strength of bubbles.')
    end
end

function job_post_precast(spell, spellMap, eventArgs)

    if spell.type == 'WeaponSkill' then

        local WSset = standardize_set(get_precast_set(spell, spellMap))

        if WSset.ear1 == "Moonshade Earring"
            or WSset.ear2 == "Moonshade Earring" then

            if sets.MaxTP
                and get_effective_player_tp(spell, WSset) > 3200 then

                equip(sets.MaxTP[spell.english] or sets.MaxTP)
            end
        end
    end
end

function job_post_midcast(spell, spellMap, eventArgs)

    if spell.skill == 'Elemental Magic'
        and default_spell_map ~= 'ElementalEnfeeble'
        and spell.english ~= 'Impact' then

        try_magic_burst()

        if spell.element == world.weather_element
            or spell.element == world.day_element then

            if state.CastingMode.value == 'Fodder' or state.CastingMode.value == 'Normal' then

                if spell.element == world.day_element then

                    if item_available('Zodiac Ring') then
                        sets.ZodiacRing = {ring2="Zodiac Ring"}
                        equip(sets.ZodiacRing)
                    end
                end
            end
        end

        if spell.element
            and sets.element
            and sets.element[spell.element] then

            equip(sets.element[spell.element])
        end

        -- Shared global MP recovery.
        try_recover_mp()

    elseif spell.skill == 'Geomancy' then

        if spell.english:startswith('Geo-') then

            if state.Buff['Blaze of Glory']
                and sets.buff['Blaze of Glory'] then

                equip(sets.buff['Blaze of Glory'])
                disable('head')
                blazelocked = true
            end

        elseif state.Buff.Entrust
            and spell.english:startswith('Indi-') then

            if sets.midcast.Geomancy.main == 'Idris'
                and item_available('Solstice') then

                equip({main="Solstice"})
            end
        end
    end
end

function job_aftercast(spell, spellMap, eventArgs)

    try_sublimation()

    if not spell.interrupted then

        if spell.english:startswith('Indi-') then

            if spell.target.type == 'SELF' then
                last_indi = string.sub(spell.english,6)
            end

            if not classes.CustomIdleGroups:contains('Indi') then
                classes.CustomIdleGroups:append('Indi')
            end

            if state.UseCustomTimers.value then
                send_command('@timers d "'..
                    spell.target.name..': '..indi_timer..'"')

                indi_timer = spell.english

                send_command('@timers c "'..
                    spell.target.name..': '..indi_timer..
                    '" '..indi_duration..
                    ' down spells/00136.png')
            end

        elseif spell.english:startswith('Geo-')
            or spell.english == "Mending Halation"
            or spell.english == "Radial Arcana" then

            eventArgs.handled = true

            if spell.english:startswith('Geo-') then
                last_geo = string.sub(spell.english,5)
            end

        elseif state.UseCustomTimers.value
            and (spell.english == 'Sleep'
            or spell.english == 'Sleepga') then

            send_command('@timers c "'..
                spell.english..' ['..spell.target.name..']" 60 down spells/00220.png')

        elseif state.UseCustomTimers.value
            and (spell.english == 'Sleep II'
            or spell.english == 'Sleepga II') then

            send_command('@timers c "'..
                spell.english..' ['..spell.target.name..']" 90 down spells/00220.png')
        end
    end

    if not player.indi then
        classes.CustomIdleGroups:clear()
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for non-casting events.
-------------------------------------------------------------------------------------------------------------------

function job_buff_change(buff, gain)

    smart_caster_buff_change(buff, gain)

    if player.indi
        and not classes.CustomIdleGroups:contains('Indi') then

        classes.CustomIdleGroups:append('Indi')

        if not midaction() then
            handle_equipping_gear(player.status)
        end

    elseif classes.CustomIdleGroups:contains('Indi')
        and not player.indi then

        classes.CustomIdleGroups:clear()

        if not midaction() then
            handle_equipping_gear(player.status)
        end
    end
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

function job_get_spell_map(spell, default_spell_map)

    if default_spell_map == 'Cure'
        or default_spell_map == 'Curaga' then

        if world.weather_element == 'Light' then
            return 'LightWeatherCure'

        elseif world.day_element == 'Light' then
            return 'LightDayCure'
        end

    elseif spell.skill == "Enfeebling Magic" then

        if spell.english:startswith('Dia') then
            return "Dia"

        elseif spell.type == "WhiteMagic"
            or spell.english:startswith('Frazzle')
            or spell.english:startswith('Distract') then

            return 'MndEnfeebles'

        else
            return 'IntEnfeebles'
        end

    elseif spell.skill == 'Geomancy' then

        if spell.english:startswith('Indi') then
            return 'Indi'
        end

    elseif spell.skill == 'Elemental Magic' then

        if default_spell_map == 'ElementalEnfeeble'
            or spell.english:contains('helix') then

            return

        elseif LowTierNukes:contains(spell.english) then
            return 'LowTierNuke'

        else
            return 'HighTierNuke'
        end
    end
end

function job_state_change(stateField, newValue, oldValue)
    try_offense_weapon_lock(stateField, newValue)
end

function job_customize_idle_set(idleSet)

    if state.PetHPMode.value and sets.PetHP then
        idleSet = set_combine(idleSet, sets.PetHP)
    end

    if buffactive['Sublimation: Activated'] then

        if (state.IdleMode.value == 'Normal'
            or state.IdleMode.value:contains('Sphere'))
            and sets.buff.Sublimation then

            idleSet = set_combine(idleSet, sets.buff.Sublimation)

        elseif state.IdleMode.value:contains('DT')
            and sets.buff.DTSublimation then

            idleSet = set_combine(idleSet, sets.buff.DTSublimation)
        end
    end

    if state.IdleMode.value == 'Normal'
        or state.IdleMode.value:contains('Sphere') then

        if player.mpp < 51 then

            if sets.latent_refresh then
                idleSet = set_combine(idleSet, sets.latent_refresh)
            end

            if (state.Weapons.value == 'None'
                or (state.UnlockWeapons and state.UnlockWeapons.value))
                and idleSet.main then

                local main_table = get_item_table(idleSet.main)

                if main_table
                    and main_table.skill == 12
                    and sets.latent_refresh_grip then

                    idleSet = set_combine(
                        idleSet,
                        sets.latent_refresh_grip
                    )
                end

                if player.tp > 10 and sets.TPEat then
                    idleSet = set_combine(idleSet, sets.TPEat)
                end
            end
        end
    end

    return idleSet
end

function job_update(cmdParams, eventArgs)

    classes.CustomIdleGroups:clear()

    if player.indi then
        classes.CustomIdleGroups:append('Indi')
    end
end

function job_pet_change(pet, gain)

    if not gain then
        used_ecliptic = false
    end

    if blazelocked then
        enable('head')
        blazelocked = false
    end
end

function display_current_job_state(eventArgs)
    display_current_caster_state()
    eventArgs.handled = true
end

function job_self_command(commandArgs, eventArgs)

    local lowerCommand = commandArgs[1]:lower()

    if lowerCommand == 'autoindi' and commandArgs[2] then

        autoindi = commandArgs[2]:ucfirst()

        add_to_chat(
            122,
            'Your Auto Indi- spell is set to '..autoindi..'.'
        )

        if state.DisplayMode.value then
            update_job_states()
        end

    elseif lowerCommand == 'autogeo' and commandArgs[2] then

        autogeo = commandArgs[2]:ucfirst()

        add_to_chat(
            122,
            'Your Auto Geo- spell is set to '..autogeo..'.'
        )

        if state.DisplayMode.value then
            update_job_states()
        end

    elseif lowerCommand == 'geo' and commandArgs[2] then

        local geoSpell = commandArgs[2]:ucfirst()

        windower.chat.input('/ma "Geo-'..geoSpell..'" <bt>')

        eventArgs.handled = true

    elseif lowerCommand == 'autoentrust' and commandArgs[2] then

        autoentrust = commandArgs[2]:ucfirst()

        add_to_chat(
            122,
            'Your Auto Entrust Indi- spell is set to '..autoentrust..'.'
        )

        if state.DisplayMode.value then
            update_job_states()
        end

    elseif lowerCommand:contains('trustee') and commandArgs[2] then

        autoentrustee = commandArgs[2]:ucfirst()

        add_to_chat(
            122,
            'Your Auto Entrustee target is set to '..autoentrustee..'.'
        )

        if state.DisplayMode.value then
            update_job_states()
        end

    elseif lowerCommand == 'automelee' then

        autoindi = autoindimelee
        autogeo = autogeomelee

        add_to_chat(
            122,
            'Auto Indi-/Geo- switched to MELEE profile: Indi-'..
            autoindi..' / Geo-'..autogeo..'.'
        )

        if state.DisplayMode.value then
            update_job_states()
        end

    elseif lowerCommand == 'automage' then

        autoindi = autoindimage
        autogeo = autogeomage

        add_to_chat(
            122,
            'Auto Indi-/Geo- switched to MAGE profile: Indi-'..
            autoindi..' / Geo-'..autogeo..'.'
        )

        if state.DisplayMode.value then
            update_job_states()
        end

    elseif lowerCommand == 'autohaste' then

        autoentrust = 'Haste'
        autoentrustee = '<st>'

        if not state.AutoEntrust.value then
            send_command('gs c toggle AutoEntrust')
        end

        add_to_chat(
            122,
            'Auto-Haste active: Entrust + Indi-Haste will follow your current <st> until you sub-target someone new.'
        )

        if state.DisplayMode.value then
            update_job_states()
        end

    elseif lowerCommand == 'elemental' then

        handle_elemental(commandArgs)
        eventArgs.handled = true

    elseif lowerCommand == 'smartcure' then

        handle_smartcure(commandArgs)
        eventArgs.handled = true
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Handling Elemental spells within GearSwap.
-------------------------------------------------------------------------------------------------------------------

function handle_elemental(cmdParams)

    if not cmdParams[2] then
        add_to_chat(123,'Error: No elemental command given.')
        return
    end

    local command = cmdParams[2]:lower()

    if command == 'spikes' then
        windower.chat.input(
            '/ma "'..data.elements.spikes_of[state.ElementalMode.value]..' Spikes" <me>'
        )
        return

    elseif command == 'enspell' then
        windower.chat.input(
            '/ma "En'..data.elements.enspell_of[state.ElementalMode.value]..'" <me>'
        )
        return

    elseif command == 'weather' then

        if player.sub_job == 'RDM' then

            windower.chat.input('/ma "Phalanx" <me>')

        else

            local spell_recasts = windower.ffxi.get_spell_recasts()

            if (player.target.type == 'SELF'
                or not player.target.in_party)
                and buffactive[data.elements.storm_of[state.ElementalMode.value]]
                and not buffactive['Klimaform']
                and spell_recasts[287] < spell_latency then

                windower.chat.input('/ma "Klimaform" <me>')

            else
                windower.chat.input(
                    '/ma "'..
                    data.elements.storm_of[state.ElementalMode.value]..
                    '"'
                )
            end
        end

        return
    end

    local target = '<t>'

    if cmdParams[3] then

        if tonumber(cmdParams[3]) then
            target = tonumber(cmdParams[3])

        else
            target = table.concat(cmdParams, ' ', 3)
            target = get_closest_mob_id_by_name(target) or '<t>'
        end
    end

    if command == 'nuke' then

        local spell_recasts = windower.ffxi.get_spell_recasts()

        if state.ElementalMode.value == 'Light' then

            if spell_recasts[29] < spell_latency
                and actual_cost(get_spell_table_by_name('Banish II')) < player.mp then

                windower.chat.input(
                    '/ma "Banish II" '..target
                )

            elseif spell_recasts[28] < spell_latency
                and actual_cost(get_spell_table_by_name('Banish')) < player.mp then

                windower.chat.input(
                    '/ma "Banish" '..target
                )

            else
                add_to_chat(
                    123,
                    'Abort: Banishes on cooldown or not enough MP.'
                )
            end

        else

            if player.job_points[(res.jobs[player.main_job_id].ens):lower()].jp_spent > 99
                and spell_recasts[
                    get_spell_table_by_name(
                        data.elements.nuke_of[state.ElementalMode.value]..' V'
                    ).id
                ] < spell_latency
                and actual_cost(
                    get_spell_table_by_name(
                        data.elements.nuke_of[state.ElementalMode.value]..' V'
                    )
                ) < player.mp then

                windower.chat.input(
                    '/ma "'..
                    data.elements.nuke_of[state.ElementalMode.value]..
                    ' V" '..target
                )

            else

                local tiers = {' IV',' III',' II',''}

                for k in ipairs(tiers) do

                    local spell_name =
                        data.elements.nuke_of[state.ElementalMode.value]..
                        tiers[k]

                    if spell_recasts[get_spell_table_by_name(spell_name).id]
                        < spell_latency
                        and actual_cost(
                            get_spell_table_by_name(spell_name)
                        ) < player.mp then

                        windower.chat.input(
                            '/ma "'..spell_name..'" '..target
                        )

                        return
                    end
                end

                add_to_chat(
                    123,
                    'Abort: All '..data.elements.nuke_of[state.ElementalMode.value]..
                    ' nukes on cooldown or not enough MP.'
                )
            end
        end

    elseif command == 'ninjutsu' then

        windower.chat.input(
            '/ma "'..
            data.elements.ninjutsu_nuke_of[state.ElementalMode.value]..
            ': Ni" '..target
        )

    elseif command == 'smallnuke' then

        local spell_recasts = windower.ffxi.get_spell_recasts()
        local tiers = {' II',''}

        for k in ipairs(tiers) do

            local spell_name =
                data.elements.nuke_of[state.ElementalMode.value]..
                tiers[k]

            if spell_recasts[get_spell_table_by_name(spell_name).id]
                < spell_latency
                and actual_cost(
                    get_spell_table_by_name(spell_name)
                ) < player.mp then

                windower.chat.input(
                    '/ma "'..spell_name..'" '..target
                )

                return
            end
        end

        add_to_chat(
            123,
            'Abort: All '..data.elements.nuke_of[state.ElementalMode.value]..
            ' nukes on cooldown or not enough MP.'
        )

    elseif command:contains('tier') then

        local spell_recasts = windower.ffxi.get_spell_recasts()

        local tierlist = {
            ['tier1']='',
            ['tier2']=' II',
            ['tier3']=' III',
            ['tier4']=' IV',
            ['tier5']=' V',
            ['tier6']=' VI'
        }

        local tiernum = {
            ['tier1']=1,
            ['tier2']=2,
            ['tier3']=3,
            ['tier4']=4,
            ['tier5']=5,
            ['tier6']=6
        }

        local requested = tiernum[command]

        if not requested then

            add_to_chat(
                123,
                'Abort: Unrecognized tier command "'..command..'".'
            )

        elseif requested > MaxNukeTier then

            add_to_chat(
                123,
                'Abort: GEO is capped at Tier '..MaxNukeTier..
                ' nukes -- Tier '..requested..' is not available.'
            )

        else

            windower.chat.input(
                '/ma "'..
                data.elements.nuke_of[state.ElementalMode.value]..
                tierlist[command]..
                '" '..target
            )
        end

    elseif command:contains('ara') then

        local spell_recasts = windower.ffxi.get_spell_recasts()

        local tierkey = {'ara3','ara2','ara'}

        local tierlist = {
            ['ara3']='ra III',
            ['ara2']='ra II',
            ['ara']='ra'
        }

        if command == 'ara' then

            for i in ipairs(tierkey) do

                local spell_name =
                    data.elements.nukera_of[state.ElementalMode.value]..
                    tierlist[tierkey[i]]

                if spell_recasts[get_spell_table_by_name(spell_name).id]
                    < spell_latency
                    and actual_cost(
                        get_spell_table_by_name(spell_name)
                    ) < player.mp then

                    windower.chat.input(
                        '/ma "'..spell_name..'" '..target
                    )

                    return
                end
            end

        else

            local spell_name =
                data.elements.nukera_of[state.ElementalMode.value]..
                tierlist[command]

            windower.chat.input(
                '/ma "'..spell_name..'" '..target
            )
        end

    elseif command == 'aga' then

        windower.chat.input(
            '/ma "'..
            data.elements.nukega_of[state.ElementalMode.value]..
            'ga" '..target
        )

    elseif command == 'helix' then

        windower.chat.input(
            '/ma "'..
            data.elements.helix_of[state.ElementalMode.value]..
            'helix" '..target
        )

    elseif command == 'enfeeble' then

        windower.chat.input(
            '/ma "'..
            data.elements.elemental_enfeeble_of[state.ElementalMode.value]..
            '" '..target
        )

    elseif command == 'bardsong' then

        windower.chat.input(
            '/ma "'..
            data.elements.threnody_of[state.ElementalMode.value]..
            ' Threnody" '..target
        )

    else

        add_to_chat(123,'Unrecognized elemental command.')
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Smart cure command.
-------------------------------------------------------------------------------------------------------------------

function handle_smartcure(cmdParams)

    local cureTarget

    if cmdParams[2] then

        if tonumber(cmdParams[2]) then

            cureTarget =
                windower.ffxi.get_mob_by_id(
                    tonumber(cmdParams[2])
                ) or player

        else

            cureTarget = table.concat(cmdParams, ' ', 2)
            cureTarget = get_closest_mob_by_name(cureTarget)

            if not cureTarget or not cureTarget.name then
                cureTarget = player.target
            end

            if not cureTarget or not cureTarget.name then
                cureTarget = player
            end
        end

    elseif player.target
        and (player.target.type == "SELF"
        or player.target.type == 'MONSTER'
        or player.target.type == 'NONE') then

        cureTarget = player

    elseif player.target then
        cureTarget = player.target

    else
        cureTarget = player
    end

    if cureTarget.status == 2 or cureTarget.status == 3 then
        windower.chat.input(
            '/ma "Arise" '..cureTarget.id
        )
        return
    end

    local spell_recasts = windower.ffxi.get_spell_recasts()

    if cureTarget.type == 'MONSTER' then

        if silent_can_use(4)
            and spell_recasts[4] < spell_latency then

            windower.chat.input(
                '/ma "Cure IV" '..cureTarget.id
            )

        elseif spell_recasts[3] < spell_latency then

            windower.chat.input(
                '/ma "Cure III" '..cureTarget.id
            )

        elseif spell_recasts[2] < spell_latency then

            windower.chat.input(
                '/ma "Cure II" '..cureTarget.id
            )

        else

            add_to_chat(
                123,
                'Abort: Appropriate cures are on cooldown.'
            )
        end

        return
    end

    local missingHP

    if cureTarget.in_alliance then

        local alliance_player =
            find_player_in_alliance(cureTarget.name)

        if alliance_player then
            cureTarget.hp = alliance_player.hp
        end

        local est_max_hp =
            cureTarget.hpp
            and cureTarget.hpp > 0
            and cureTarget.hp / (cureTarget.hpp/100)
            or cureTarget.hp

        missingHP =
            math.floor(est_max_hp - cureTarget.hp)

    else

        local est_current_hp =
            cureTarget.hpp
            and 1800 * (cureTarget.hpp/100)
            or 1800

        missingHP =
            math.floor(1800 - est_current_hp)
    end

    check_aurorastorm_for_cure(missingHP, cureTarget)

    if missingHP < 250 then

        if spell_recasts[1] < spell_latency then

            windower.chat.input(
                '/ma "Cure" '..cureTarget.id
            )

        elseif spell_recasts[2] < spell_latency then

            windower.chat.input(
                '/ma "Cure II" '..cureTarget.id
            )

        else

            add_to_chat(
                123,
                'Abort: Appropriate cures are on cooldown.'
            )
        end

    elseif missingHP < 600 then

        if spell_recasts[2] < spell_latency then

            windower.chat.input(
                '/ma "Cure II" '..cureTarget.id
            )

        elseif spell_recasts[3] < spell_latency then

            windower.chat.input(
                '/ma "Cure III" '..cureTarget.id
            )

        elseif spell_recasts[1] < spell_latency then

            windower.chat.input(
                '/ma "Cure" '..cureTarget.id
            )

        else

            add_to_chat(
                123,
                'Abort: Appropriate cures are on cooldown.'
            )
        end

    elseif missingHP < 900 then

        if spell_recasts[3] < spell_latency then

            windower.chat.input(
                '/ma "Cure III" '..cureTarget.id
            )

        elseif silent_can_use(4)
            and spell_recasts[4] < spell_latency then

            windower.chat.input(
                '/ma "Cure IV" '..cureTarget.id
            )

        elseif spell_recasts[2] < spell_latency then

            windower.chat.input(
                '/ma "Cure II" '..cureTarget.id
            )

        else

            add_to_chat(
                123,
                'Abort: Appropriate cures are on cooldown.'
            )
        end

    else

        if silent_can_use(4)
            and spell_recasts[4] < spell_latency then

            windower.chat.input(
                '/ma "Cure IV" '..cureTarget.id
            )

        elseif spell_recasts[3] < spell_latency then

            windower.chat.input(
                '/ma "Cure III" '..cureTarget.id
            )

        elseif spell_recasts[2] < spell_latency then

            windower.chat.input(
                '/ma "Cure II" '..cureTarget.id
            )

        else

            add_to_chat(
                123,
                'Abort: Appropriate cures are on cooldown.'
            )
        end
    end
end

function job_tick()

    if check_geo() then return true end
    if check_buff() then return true end
    if check_buffup() then return true end

    return false
end

function check_geo()

    if state.AutoBuffMode.value ~= 'Off'
        and not data.areas.cities:contains(world.area) then

        if not pet.isvalid then
            used_ecliptic = false
        end

        local abil_recasts =
            windower.ffxi.get_ability_recasts()

        if autoindi ~= 'None'
            and ((not player.indi) or last_indi ~= autoindi) then

            windower.chat.input(
                '/ma "Indi-'..autoindi..'" <me>'
            )

            tickdelay = os.clock() + 2.1
            return true

        elseif autoentrust ~= 'None'
            and abil_recasts[93] < latency
            and (player.in_combat
            or state.CombatEntrustOnly.value == false) then

            send_command(
                '@input /ja "Entrust" <me>; wait 1.1; input /ma "Indi-'..
                autoentrust..'" '..autoentrustee
            )

            tickdelay = os.clock() + 3.5
            return true

        end

        -- Pet (luopan) maintenance. This used to be an `elseif` sibling of the
        -- Geo- cast check below, which meant that once a luopan existed it
        -- ALWAYS won the branch and the Geo- cast could never fire again after
        -- the first one. Now it's checked independently so it can hand off to
        -- the Geo- cast when there's nothing to maintain.
        if pet.isvalid then

            local petmob = windower.ffxi.get_mob_by_target("pet")

            if petmob.distance:sqrt() > 50 then

                windower.chat.input(
                    '/ja "Full Circle" <me>'
                )

                tickdelay = os.clock() + 1.1
                return true

            elseif state.AutoGeoAbilities.value
                and abil_recasts[244] < latency
                and not used_ecliptic
                and not buffactive.Bolster then

                windower.chat.input(
                    '/ja "Ecliptic Attrition" <me>;'
                )

                used_ecliptic = true
                return true
            end
        end

        if autogeo ~= 'None'
            and last_geo ~= autogeo
            and (
                windower.ffxi.get_mob_by_target('bt')
                or data.spells.geo_buffs:contains(autogeo)
            ) then

            if player.in_combat
                and state.AutoGeoAbilities.value
                and abil_recasts[247] < latency
                and not buffactive.Bolster then

                windower.chat.input(
                    '/ja "Blaze of Glory" <me>;'
                )

                tickdelay = os.clock() + 1.1
                return true

            else

                windower.chat.input(
                    '/ma "Geo-'..autogeo..'" <bt>'
                )

                tickdelay = os.clock() + 3.1
                return true
            end
        end
    end

    return false
end

-------------------------------------------------------------------------------------------------------------------
-- Luopan Distance Tracking
-------------------------------------------------------------------------------------------------------------------

debuff_list = S{
    'Gravity','Paralysis','Slow','Languor','Vex','Torpor','Slip',
    'Malaise','Fade','Frailty','Wilt','Poison'
}

ignore_list = S{
    'SlipperySilas','HareFamiliar','SheepFamiliar','FlowerpotBill',
    'TigerFamiliar','FlytrapFamiliar','LizardFamiliar','MayflyFamiliar',
    'EftFamiliar','BeetleFamiliar','AntlionFamiliar','CrabFamiliar',
    'MiteFamiliar','KeenearedSteffi','LullabyMelodia','FlowerpotBen',
    'SaberSiravarde','FunguarFamiliar','ShellbusterOrob','ColdbloodComo',
    'CourierCarrie','Homunculus','VoraciousAudrey','AmbusherAllie',
    'PanzerGalahad','LifedrinkerLars','ChopsueyChucky','AmigoSabotender',
    'NurseryNazuna','CraftyClyvonne','PrestoJulio','SwiftSieghard',
    'MailbusterCetas','AudaciousAnna','TurbidToloi','LuckyLulush',
    'DipperYuly','FlowerpotMerle','DapperMac','DiscreetLouise',
    'FatsoFargann','FaithfulFalcorr','BugeyedBroncha','BloodclawShasra',
    'GorefangHobs','GooeyGerard','CrudeRaphie','DroopyDortwin',
    'SunburstMalfik','WarlikePatrick','ScissorlegXerin','RhymingShizuna',
    'AttentiveIbuki','AmiableRoche','HeraldHenry','BrainyWaluis',
    'SuspiciousAlice','HeadbreakerKen','RedolentCandi','CaringKiyomaro',
    'HurlerPercival','AnklebiterJedd','BlackbeardRandy','FleetReinhard',
    'GenerousArthur','ThreestarLynn','BraveHeroGlenn','SharpwitHermes',
    'AlluringHoney','CursedAnnabelle','SwoopingZhivago','BouncingBertha',
    'MosquitoFamilia','Ifrit','Shiva','Garuda','Fenrir','Carbuncle',
    'Ramuh','Leviathan','CaitSith','Diabolos','Titan','Atomos',
    'WaterSpirit','FireSpirit','EarthSpirit','ThunderSpirit',
    'AirSpirit','LightSpirit','DarkSpirit','IceSpirit'
}

luopantxt = {}

luopantxt.pos = {}
luopantxt.pos.x = -200
luopantxt.pos.y = 175

luopantxt.text = {}
luopantxt.text.font = 'Arial'
luopantxt.text.size = 12

luopantxt.flags = {}
luopantxt.flags.right = true

luopan = texts.new('${value}', luopantxt)

luopan:bold(true)
luopan:bg_alpha(0)
luopan:stroke_width(2)
luopan:stroke_transparency(192)

bt_color = '\\cs(230,118,116)'

windower.raw_register_event('prerender', function()

    local s = windower.ffxi.get_mob_by_target('me')

    if windower.ffxi.get_mob_by_target('pet') then
        myluopan = windower.ffxi.get_mob_by_target('pet')
    else
        myluopan = nil
    end

    local luopan_txtbox = ''
    local indi_count = 0
    local geo_count = 0

    local battle_target =
        windower.ffxi.get_mob_by_target('bt') or false

    if myluopan and last_geo then

        luopan_txtbox =
            luopan_txtbox..
            ' \\cs(0,255,0)Geo-'..
            last_geo..
            ':\\cs(255,255,255)\n'

        for i,v in pairs(windower.ffxi.get_mob_array()) do

            local DistanceBetween =
                ((myluopan.x - v.x) * (myluopan.x - v.x)
                + (myluopan.y - v.y) * (myluopan.y - v.y)):sqrt()

            if DistanceBetween < (6 + v.model_size)
                and not (v.status == 2 or v.status == 3)
                and v.name
                and v.name ~= ''
                and v.name ~= "Luopan"
                and v.valid_target
                and v.model_size > 0 then

                if debuff_list:contains(last_geo) then

                    if v.is_npc
                        and not (v.in_party or ignore_list:contains(v.name)) then

                        if battle_target and battle_target.id == v.id then

                            luopan_txtbox =
                                luopan_txtbox..
                                ' '..bt_color..
                                v.name.." "..
                                string.format("%.2f",DistanceBetween)..
                                "\\cs(255,255,255)\n"

                        else

                            luopan_txtbox =
                                luopan_txtbox..
                                ' '..v.name.." "..
                                string.format("%.2f",DistanceBetween)..
                                "\n"
                        end

                        geo_count = geo_count + 1
                    end

                else

                    if v.in_party then

                        luopan_txtbox =
                            luopan_txtbox..
                            ' '..v.name.." "..
                            string.format("%.2f",DistanceBetween)..
                            "\n"

                        geo_count = geo_count + 1
                    end
                end
            end
        end
    end

    if buffactive['Colure Active'] and last_indi then

        if myluopan then
            luopan_txtbox = luopan_txtbox..'\n'
        end

        luopan_txtbox =
            luopan_txtbox..
            ' \\cs(0,255,0)Indi-'..
            last_indi..
            ':\\cs(255,255,255)\n'

        for i,v in pairs(windower.ffxi.get_mob_array()) do

            local DistanceBetween =
                ((s.x - v.x) * (s.x - v.x)
                + (s.y - v.y) * (s.y - v.y)):sqrt()

            if DistanceBetween < (6 + v.model_size)
                and (v.status == 1 or v.status == 0)
                and v.name
                and v.name ~= ''
                and v.name ~= "Luopan"
                and v.name ~= s.name
                and v.valid_target
                and v.model_size > 0 then

                if debuff_list:contains(last_indi) then

                    if v.is_npc
                        and not (v.in_party or ignore_list:contains(v.name)) then

                        if battle_target and battle_target.id == v.id then

                            luopan_txtbox =
                                luopan_txtbox..
                                ' '..bt_color..
                                v.name.." "..
                                string.format("%.2f",DistanceBetween)..
                                "\\cs(255,255,255)\n"

                        else

                            luopan_txtbox =
                                luopan_txtbox..
                                ' '..v.name.." "..
                                string.format("%.2f",DistanceBetween)..
                                "\n"
                        end

                        indi_count = indi_count + 1
                    end

                else

                    if v.in_party then

                        luopan_txtbox =
                            luopan_txtbox..
                            ' '..v.name.." "..
                            string.format("%.2f",DistanceBetween)..
                            "\n"

                        indi_count = indi_count + 1
                    end
                end
            end
        end
    end

    luopan.value = luopan_txtbox

    if state.ShowDistance
        and state.ShowDistance.value
        and (
            (myluopan and geo_count ~= 0)
            or (buffactive['Colure Active'] and indi_count ~= 0)
        ) then

        luopan:visible(true)

    else
        luopan:visible(false)
    end
end)

function check_buff()

    if state.AutoBuffMode.value ~= 'Off'
        and not data.areas.cities:contains(world.area) then

        local spell_recasts =
            windower.ffxi.get_spell_recasts()

        local buff_list =
            buff_spell_lists[state.AutoBuffMode.value]

        if not buff_list then
            return false
        end

        for i in pairs(buff_list) do

            if not buffactive[buff_list[i].Buff]
                and (
                    buff_list[i].When == 'Always'
                    or (
                        buff_list[i].When == 'Combat'
                        and (player.in_combat or being_attacked)
                    )
                    or (
                        buff_list[i].When == 'Engaged'
                        and player.status == 'Engaged'
                    )
                    or (
                        buff_list[i].When == 'Idle'
                        and player.status == 'Idle'
                    )
                    or (
                        buff_list[i].When == 'OutOfCombat'
                        and not (player.in_combat or being_attacked)
                    )
                )
                and spell_recasts[buff_list[i].SpellID] < spell_latency
                and silent_can_use(buff_list[i].SpellID) then

                windower.chat.input(
                    '/ma "'..buff_list[i].Name..'" <me>'
                )

                tickdelay = os.clock() + 2
                return true
            end
        end

    else
        return false
    end

    return false
end

function check_buffup()

    if buffup ~= '' then

        local current_buff_list =
            buff_spell_lists[buffup]

        if not current_buff_list then

            add_to_chat(
                123,
                'Abort: Unknown buff list ['..tostring(buffup)..'].'
            )

            buffup = ''
            return false
        end

        local needsbuff = false

        for i in pairs(current_buff_list) do

            if not buffactive[current_buff_list[i].Buff]
                and silent_can_use(current_buff_list[i].SpellID) then

                needsbuff = true
                break
            end
        end

        if not needsbuff then

            add_to_chat(
                217,
                'All '..buffup..' buffs are up!'
            )

            buffup = ''
            return false
        end

        local spell_recasts =
            windower.ffxi.get_spell_recasts()

        for i in pairs(buff_spell_lists[buffup]) do

            if not buffactive[current_buff_list[i].Buff]
                and silent_can_use(current_buff_list[i].SpellID)
                and spell_recasts[current_buff_list[i].SpellID] < spell_latency then

                windower.chat.input(
                    '/ma "'..
                    current_buff_list[i].Name..
                    '" <me>'
                )

                tickdelay = os.clock() + 2
                return true
            end
        end

        return false

    else
        return false
    end
end

buff_spell_lists = {
	Auto = {--Options for When are: Always, Engaged, Idle, OutOfCombat, Combat
		{Name='Aurorastorm',	Buff='Aurorastorm',	SpellID=119,	When='Idle'},
		{Name='Reraise',		Buff='Reraise',		SpellID=135,	When='Always'},
		{Name='Aquaveil',		Buff='Aquaveil',	SpellID=55,		When='OutOfCombat'},
	},

	Default = {
		{Name='Stoneskin',		Buff='Stoneskin',	SpellID=54,		Reapply=false},
	},

	MageBuff = {
		{Name='Aquaveil',		Buff='Aquaveil',		SpellID=55,		Reapply=true},
		{Name='Stoneskin',		Buff='Stoneskin',		SpellID=54,		Reapply=false},
		{Name='Blink',			Buff='Blink',			SpellID=53,		Reapply=false},
	},
	
	FullMeleeBuff = {
		{Name='Aquaveil',		Buff='Aquaveil',		SpellID=55,		Reapply=true},
		{Name='Stoneskin',		Buff='Stoneskin',		SpellID=54,		Reapply=false},
		{Name='Blink',			Buff='Blink',			SpellID=53,		Reapply=false},
	},
	
}
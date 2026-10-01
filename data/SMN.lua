 -- SMN.lua — 
--[[
    Commands:
    gs c petweather
        Casts the appropriate storm for the current avatar.
    gs c siphon
        Dismiss avatar -> cast weather -> summon spirit -> Siphon -> release spirit
        -> re-summon avatar. Skips unavailable weather and preserves "no avatar out".
    gs c pact <type>
        Uses the current avatar's pact of the requested type.
        Types: cure, curaga, buffOffense, buffDefense, buffSpecial, buffSpecial2,
        debuff1, debuff2, sleep, nuke2, nuke4, bp70, bp75, bp99, physical,
        magical, astralflow.
    gs c pacthelp [avatar|type]
        Shows available pacts from the pacts table. No argument = current avatar.
    gs c elemental <type>
        Elemental shortcuts driven by state.ElementalMode.
        Types: spikes, enspell, weather, nuke, smallnuke, tierN, ara, aga,
        helix, enfeeble, bardsong.
    gs c conduitlock
        Toggles Astral Conduit gear locking.
    gs c smartcure [targetID|name]
        Selects the highest available cure tier (up to Cure IV) by missing HP.
        Dead targets are redirected to Cait Sith Raise II.
    Raise / Reraise
        Raise/Reraise commands and /ma casts are redirected through Cait Sith.
        Cait Sith is summoned if needed, then Raise II/Reraise II is used.
    Pact mappings
        See the pacts table in job_setup() -- it is the source of truth.
        Keep this comment and the table separate; do not duplicate mappings here.
    Notes:
        PactSpamMode uses Ctrl+\.
        Ctrl+` is reserved for the global ElementalMode cycle.
--]]
-- Initialization function for this job file.
function get_sets()
    include('Sel-Include.lua')
    include('Ullona-shortcuts')
    include('Smart-Caster.lua')
end
function job_setup()
    state.Buff["Avatar's Favor"] = buffactive["Avatar's Favor"] or false
    state.Buff["Astral Conduit"] = buffactive["Astral Conduit"] or false
    state.Buff['Aftermath: Lv.3'] = buffactive['Aftermath: Lv.3'] or false
    avatars = S{"Carbuncle","Fenrir","Diabolos","Ifrit","Titan","Leviathan","Garuda","Shiva","Ramuh","Odin","Alexander","Cait Sith","Siren"}
    spirits = S{"LightSpirit","DarkSpirit","FireSpirit","EarthSpirit","WaterSpirit","AirSpirit","IceSpirit","ThunderSpirit"}
    spirit_of = {Light="Light Spirit",Dark="Dark Spirit",Fire="Fire Spirit",Earth="Earth Spirit", Water="Water Spirit",Wind="Air Spirit",Ice="Ice Spirit",Lightning="Thunder Spirit"
    }
    magicalRagePacts = S{
        'Inferno','Earthen Fury','Tidal Wave','Aerial Blast','Diamond Dust','Judgment Bolt',
        'Izdubar Mantle Light','Howling Moon','Ruinous Omen','Clarsach Call','Impact',
        'Fire II','Stone II','Water II','Aero II','Blizzard II','Thunder II',
        'Fire IV','Stone IV','Water IV','Aero IV','Blizzard IV','Thunder IV',
        'Thunderspark','Burning Strike','Meteorite','Nether Blast','Flaming Crush',
        'Meteor Strike','Conflag Strike','Heavenly Strike','Wind Blade','Geocrush',
        'Grand Fall','Thunderstorm','Holy Mist','Lunar Bay','Night Terror',
        'Level ? Holy','Tornado II','Sonic Buffet'
    }
    pacts = {
        cure={Carbuncle='Healing Ruby'},
        curaga={Carbuncle='Healing Ruby II',Garuda='Whispering Wind',Leviathan='Spring Water'},
        buffoffense={Carbuncle='Glittering Ruby',Ifrit='Crimson Howl',Garuda='Hastega II',Ramuh='Rolling Thunder',Fenrir='Ecliptic Growl',Siren='Katabatic Blades'},
        buffdefense={Carbuncle='Shining Ruby',Shiva='Frost Armor',Garuda='Aerial Armor',Titan='Earthen Ward',Ramuh='Lightning Armor',Fenrir='Ecliptic Howl',Diabolos='Noctoshield',['Cait Sith']='Reraise II',Siren="Wind's Blessing"},
        buffspecial={Ifrit='Inferno Howl',Garuda='Fleet Wind',Titan='Earthen Armor',Diabolos='Dream Shroud',Carbuncle='Soothing Ruby',Fenrir='Heavenward Howl',['Cait Sith']='Raise II',Siren='Chinook'},
        buffspecial2={Carbuncle='Pacifying Ruby',Leviathan='Soothing Current',Shiva='Crystal Blessing'},
        debuff1={Shiva='Diamond Storm',Ramuh='Shock Squall',Leviathan='Tidal Roar',Fenrir='Lunar Cry',Diabolos='Pavor Nocturnus',['Cait Sith']='Eerie Eye',Siren='Lunatic Voice'},
        debuff2={Shiva='Sleepga',Leviathan='Slowga',Fenrir='Impact',Diabolos='Somnolence',Ramuh='Thunderspark',Siren='Bitter Elegy'},
        sleep={Shiva='Sleepga',Diabolos='Nightmare',['Cait Sith']='Mewing Lullaby'},
        nuke2={Ifrit='Fire II',Shiva='Blizzard II',Garuda='Aero II',Titan='Stone II',Ramuh='Thunder II',Leviathan='Water II',Siren='Tornado II'},
        nuke4={Ifrit='Fire IV',Shiva='Blizzard IV',Garuda='Aero IV',Titan='Stone IV',Ramuh='Thunder IV',Leviathan='Water IV',Siren='Torando II'},
        bp70={Ifrit='Flaming Crush',Shiva='Rush',Garuda='Predator Claws',Titan='Mountain Buster',Ramuh='Chaotic Strike',Leviathan='Spinning Dive',Carbuncle='Meteorite',Fenrir='Eclipse Bite',Diabolos='Nether Blast',['Cait Sith']='Regal Scratch'},
        bp75={Ifrit='Meteor Strike',Shiva='Heavenly Strike',Garuda='Wind Blade',Titan='Geocrush',Ramuh='Thunderstorm',Leviathan='Grand Fall',Carbuncle='Holy Mist',Fenrir='Lunar Bay',Diabolos='Night Terror',['Cait Sith']='Level ? Holy'},
        bp99={Ifrit='Conflag Strike',Titan='Crag Throw',Ramuh='Volt Strike',Siren='Hysteric Assault'},
        astralflow={Ifrit='Inferno',Shiva='Diamond Dust',Garuda='Aerial Blast',Titan='Earthen Fury',Ramuh='Judgment Bolt',Leviathan='Tidal Wave',Carbuncle='Izdubar Mantle Light',Fenrir='Howling Moon',Diabolos='Ruinous Omen',['Cait Sith']="Altana's Favor"},
        physical={Carbuncle='Poison Nails',Fenrir='Eclipse Bite',Ifrit='Flaming Crush',Titan='Mountain Buster',Leviathan='Spinning Dive',Garuda='Predator Claws',Shiva='Rush',Ramuh='Volt Strike',Diabolos='Blindside',['Cait Sith']='Regal Gash',Siren='Hysteric Assault'},
        magical={Carbuncle='Holy Mist',Fenrir='Lunar Bay',Ifrit='Meteor Strike',Titan='Geocrush',Leviathan='Grand Fall',Garuda='Wind Blade',Shiva='Heavenly Strike',Ramuh='Thunderstorm',Diabolos='Nether Blast',['Cait Sith']='Level ? Holy',Siren='Sonic Buffet'}
    }
    ConduitLock,ConduitLocked = true,nil
    state.PactSpamMode = M(false,'Pact Spam Mode')
    state.AutoPetMenu = M(true,'Auto Pet Menu')
    state.AutoFavor = M(true,'Auto Favor')
    state.AutoConvert = M(true,'Auto Convert')
    autows,autofood = 'Spirit Taker','Akamochi'
    init_job_states(
        {"Capacity","AutoRuneMode","AutoTrustMode","AutoNukeMode","PactSpamMode","AutoWSMode","AutoShadowMode","AutoFoodMode","AutoStunMode","AutoDefenseMode"},
        {"AutoBuffMode","Weapons","OffenseMode","WeaponskillMode","IdleMode","Passive","RuneElement","ElementalMode","CastingMode","TreasureMode"}
    )
end
function job_pretarget(spell,spellMap,eventArgs)
    handle_cait_redirect(spell,eventArgs)
end
function job_filter_precast(spell,spellMap,eventArgs)
    if pet.name == spell.english and pet.hpp > 50 then
        add_to_chat(122,"You already have that avatar active!")
        eventArgs.cancel = true
    elseif avatars:contains(spell.english) and pet.isvalid then
        eventArgs.cancel = true
        windower.chat.input('/pet Release <me>')
        windower.chat.input:schedule(2,'/ma "'..spell.english..'" <me>')
    end
    if state.Buff['Astral Conduit'] and spell.type:startswith('BloodPact') and player.mp < actual_cost(spell)*2 then
        local recasts = windower.ffxi.get_ability_recasts()
        local ws = S(windower.ffxi.get_abilities().weapon_skills)
        if player.tp > 999 and ws:contains(190) then
            add_to_chat(122,'Not enough MP; using Myrkr!')
            windower.chat.input('/ws Myrkr <me>')
        elseif player.sub_job == 'SCH' and buffactive['Sublimation: Complete'] then
            add_to_chat(122,'Not enough MP; using Sublimation!')
            windower.chat.input('/ja Sublimation <me>')
        elseif player.sub_job == 'RDM' and recasts[49] < latency and player.mp > 0 and player.hp > 400 and state.AutoConvert.value then
            eventArgs.cancel = true
            add_to_chat(122,'Not enough MP; Converting!')
            windower.chat.input('/ja Convert <me>')
        end
    end
end
function job_precast(spell,spellMap,eventArgs)
    if check_ecphoria_for_ja then check_ecphoria_for_ja(spell) end
    if spell.action_type == 'Magic' then
        if state.CastingMode.value == 'Proc' then
            classes.CustomClass = 'Proc'
        elseif state.CastingMode.value == 'OccultAcumen' then
            classes.CustomClass = 'OccultAcumen'
        end
        smart_caster_precast(spell,spellMap,eventArgs)
    end
end
function job_post_precast(spell,spellMap,eventArgs)
    if spell.type == 'WeaponSkill' then
        local set = standardize_set(get_precast_set(spell,spellMap))
        if (set.ear1 == "Moonshade Earring" or set.ear2 == "Moonshade Earring")
            and sets.MaxTP and get_effective_player_tp(spell,set) > 3200 then
            equip(sets.MaxTP[spell.english] or sets.MaxTP)
        end
    end
end
function job_post_midcast(spell,spellMap,eventArgs)
    if spell.skill == 'Elemental Magic' and default_spell_map ~= 'ElementalEnfeeble' and spell.english ~= 'Impact' then
        if state.MagicBurstMode.value ~= 'Off' then equip(sets.MagicBurst) end
        if spell.element == world.weather_element or spell.element == world.day_element then try_zodiac_ring(spell) end
        if spell.element and sets.element[spell.element] then equip(sets.element[spell.element]) end
    end
end
function job_aftercast(spell,spellMap,eventArgs)
    try_sublimation()
    if spell.interrupted then return end
    if state.UseCustomTimers.value and (spell.english == 'Sleep' or spell.english == 'Sleepga') then
        send_command('@timers c "'..spell.english..' ['..spell.target.name..']" 60 down spells/00220.png')
    elseif spell.skill == 'Elemental Magic' and state.MagicBurstMode.value == 'Single' then
        state.MagicBurstMode:reset()
        if state.DisplayMode.value then update_job_states() end
    elseif type(spell.type) == 'string' and spell.type:startswith('BloodPact') and state.DefenseMode.value == 'None' then
        petWillAct = os.clock()
        if ConduitLocked and ConduitLocked ~= spell.english then
            ConduitLocked = nil
            local slots = state.Weapons.value == 'None'
                and 'main','sub','range','ammo','head','neck','lear','rear','body','hands','lring','rring','back','waist','legs','feet'
                or 'range','ammo','head','neck','lear','rear','body','hands','lring','rring','back','waist','legs','feet'
            enable(slots)
        end
        equip(get_pet_midcast_set(spell,spellMap))
        local petSet = sets.midcast.Pet[spell.english]
        if state.Buff['Aftermath: Lv.3'] then
            if petSet and petSet.AM then
                equip(petSet.AM)
            elseif sets.midcast.Pet[spellMap] and sets.midcast.Pet[spellMap].AM then
                equip(sets.midcast.Pet[spellMap].AM)
            end
        end
        if state.CastingMode.value == 'Resistant' then
            if petSet and petSet.Acc then
                equip(petSet.Acc)
            elseif sets.midcast.Pet[spellMap] and sets.midcast.Pet[spellMap].Acc then
                equip(sets.midcast.Pet[spellMap].Acc)
            end
        end
        if sets.midcast.Pet[spellMap] and sets.midcast.Pet[spellMap][pet.name] then
            equip(sets.midcast.Pet[spellMap][pet.name])
        end
        if state.Buff['Astral Conduit'] and ConduitLock and not ConduitLocked then
            ConduitLocked = spell.english
            disable('main','sub','range','ammo','head','neck','lear','rear','body','hands','lring','rring','back','waist','legs','feet')
            add_to_chat(217,"Astral Conduit on, locking your "..spell.english.." set.")
        end
        eventArgs.handled = true
    elseif pet_midaction() or avatars:contains(spell.english) then
        if avatars:contains(spell.english) and state.AutoPetMenu.value and not cait_pending then
            send_command('wait 1.5;input /pet')
        end
        eventArgs.handled = true
    end
end
function job_pet_aftercast(spell,spellMap,eventArgs)
    if state.PactSpamMode.value and spell.type == 'BloodPactRage' then
        if windower.ffxi.get_ability_recasts()[173] == 0 then
            windower.chat.input('/pet "'..spell.name..'" <t>')
        end
    end
end
function job_buff_change(buff,gain)
    smart_caster_buff_change(buff,gain)
    if buff == 'Astral Conduit' and ConduitLocked and not gain then
        ConduitLocked = nil
        add_to_chat(217,"Astral Conduit has worn, enabling all slots.")
        if state.Weapons.value == 'None' then
            enable('main','sub','range','ammo','head','neck','lear','rear','body','hands','lring','rring','back','waist','legs','feet')
        else
            enable('range','ammo','head','neck','lear','rear','body','hands','lring','rring','back','waist','legs','feet')
        end
    end
end
function job_pet_status_change(newStatus,oldStatus,eventArgs)
    if pet.isvalid and not midaction() and not pet_midaction() and (newStatus == 'Engaged' or oldStatus == 'Engaged') then
        handle_equipping_gear(player.status,newStatus)
    end
end
function job_pet_change(petparam,gain)
    classes.CustomIdleGroups:clear()
    if gain then
        if avatars:contains(pet.name) then
            classes.CustomIdleGroups:append('Avatar')
        elseif spirits:contains(pet.name) then
            classes.CustomIdleGroups:append('Spirit')
        end
        if cait_pending and pet.name == 'Cait Sith' then fire_cait_pending:schedule(1.5) end
    elseif ConduitLocked then
        ConduitLocked = nil
        add_to_chat(217,"No Avatar summoned, enabling slots.")
        if state.OffenseMode.value == 'None' then
            enable('main','sub','range','ammo','head','neck','lear','rear','body','hands','lring','rring','back','waist','legs','feet')
        else
            enable('range','ammo','head','neck','lear','rear','body','hands','lring','rring','back','waist','legs','feet')
        end
    end
end
function job_get_spell_map(spell)
    if spell.type == 'BloodPactRage' then
        return magicalRagePacts:contains(spell.english) and 'MagicalBloodPactRage' or 'PhysicalBloodPactRage'
    elseif spell.type == 'BloodPactWard' then
        return spell.target.type == 'MONSTER' and 'DebuffBloodPactWard' or 'BloodPactWard'
    end
end
function job_customize_idle_set(idleSet)
    if buffactive['Sublimation: Activated'] then
        if (state.IdleMode.value == 'Normal' or state.IdleMode.value:contains('Sphere')) and sets.buff.Sublimation then
            idleSet = set_combine(idleSet,sets.buff.Sublimation)
        elseif state.IdleMode.value:contains('DT') and sets.buff.DTSublimation then
            idleSet = set_combine(idleSet,sets.buff.DTSublimation)
        end
    end
    if state.IdleMode.value == 'Normal' or state.IdleMode.value:contains('Sphere') then
        if player.mpp < 51 then
            if sets.latent_refresh then idleSet = set_combine(idleSet,sets.latent_refresh) end
            if (state.Weapons.value == 'None' or state.UnlockWeapons.value) and idleSet.main then
                local main = get_item_table(idleSet.main)
                if main and main.skill == 12 and sets.latent_refresh_grip then
                    idleSet = set_combine(idleSet,sets.latent_refresh_grip)
                end
                if player.tp > 10 and sets.TPEat then idleSet = set_combine(idleSet,sets.TPEat) end
            end
        end
    end
    if pet.isvalid then
        if pet.element == world.day_element then idleSet = set_combine(idleSet,sets.perp.Day) end
        if pet.element == world.weather_element then idleSet = set_combine(idleSet,sets.perp.Weather) end
        if sets.perp[pet.name] then idleSet = set_combine(idleSet,sets.perp[pet.name]) end
        if state.Buff["Avatar's Favor"] and avatars:contains(pet.name) then
            idleSet = set_combine(idleSet,sets.idle.Avatar.Favor)
        end
        if pet.status == 'Engaged' then
            idleSet = set_combine(idleSet,sets.idle.Avatar.Engaged)
            if sets.idle.Avatar.Engaged[pet.name] then
                idleSet = set_combine(idleSet,sets.idle.Avatar.Engaged[pet.name])
            end
        end
    end
    return idleSet
end
function job_update()
    classes.CustomIdleGroups:clear()
    if pet.isvalid then
        classes.CustomIdleGroups:append(avatars:contains(pet.name) and 'Avatar' or spirits:contains(pet.name) and 'Spirit' or nil)
    end
end
function job_self_command(commandArgs,eventArgs)
    local c = commandArgs[1]:lower()
    if c == 'petweather' then handle_petweather()
    elseif c == 'siphon' then handle_siphoning()
    elseif c == 'pact' then handle_pacts(commandArgs)
    elseif c == 'pacthelp' then handle_pacthelp(commandArgs)
    elseif c == 'elemental' then handle_elemental(commandArgs)
    elseif c == 'conduitlock' then
        ConduitLock = not ConduitLock
        add_to_chat(122,"Astral Conduit "..(ConduitLock and "now" or "no longer").." locks gear.")
    elseif c == 'smartcure' then handle_smartcure(commandArgs)
    else return end
    eventArgs.handled = true
end
function handle_petweather()
    if player.sub_job ~= 'SCH' then return add_to_chat(123,"You can not cast storm spells.") end
    if not pet.isvalid then return add_to_chat(123,"You do not have an active avatar.") end
    local element = pet.element == 'Thunder' and 'Lightning' or pet.element
    local storm = data.elements.storm_of[element]
    if storm then
        windower.chat.input('/ma "'..storm..'" <me>')
    else
        add_to_chat(123,'Error: Unknown element ('..tostring(element)..')')
    end
end
function handle_siphoning()
    local recasts = windower.ffxi.get_ability_recasts()
    if data.areas.cities:contains(world.area) then return add_to_chat(122,'Cannot use Elemental Siphon in a city area.') end
    if recasts[175] > 0 then return add_to_chat(123,'Abort: [Elemental Siphon] waiting on recast. ('..seconds_to_clock(recasts[175])..')') end
    local siphonElement,stormElement,releasedAvatar,dontRelease
    if pet.isvalid and spirits:contains(pet.name) then
        siphonElement,dontRelease = pet.element,true
        if player.sub_job == 'SCH' and pet.element == world.day_element and pet.element ~= world.weather_element
            and not S{'Light','Dark','Lightning'}:contains(pet.element) then
            stormElement = pet.element
        end
    elseif player.sub_job == 'SCH' and world.weather_element ~= 'None'
        and world.weather_intensity == 1
        and world.weather_element == data.elements.weak_to[world.day_element]
        and (not pet.isvalid or world.weather_element ~= pet.element) then
        stormElement = world.day_element
    end
    siphonElement = stormElement
        or (world.weather_element ~= 'None' and (world.weather_intensity == 2 or world.weather_element ~= data.elements.weak_to[world.day_element]) and world.weather_element)
        or world.day_element
    local command,wait = '',0
    if pet.isvalid and avatars:contains(pet.name) then
        command = 'input /pet "Release" <me>;wait 1.1;'
        releasedAvatar,wait = pet.name,10
    end
    if stormElement then
        command = command..'input /ma "'..data.elements.storm_of[stormElement]..'" <me>;wait 4;'
        wait = wait - 4
    end
    if not (pet.isvalid and spirits:contains(pet.name)) then
        command = command..'input /ma "'..spirit_of[siphonElement]..'" <me>;wait 4;'
        wait = wait - 4
    end
    command = command..'input /ja "Elemental Siphon" <me>;'
    wait = wait - .9
    if not dontRelease then
        command = command..'wait '..(wait > 0 and wait or 1.1)..';input /pet "Release" <me>;'
    end
    if releasedAvatar then
        command = command..'wait 1.1;input /ma "'..releasedAvatar..'" <me>'
    end
    send_command(command)
end
function handle_pacts(args)
    if data.areas.cities:contains(world.area) then return add_to_chat(123,'Abort: You cannot use pacts in town.') end
    if not pet.isvalid then return add_to_chat(123,'Abort: You do not have an Avatar summoned.') end
    if spirits:contains(pet.name) then return add_to_chat(123,'Abort: Spirits cannot use blood pacts.') end
    if not args[2] then return add_to_chat(123,'Abort: No blood pact type given.') end
    local pact = args[2]:lower()
    if not pacts[pact] then return add_to_chat(123,'Abort: Unknown blood pact type: '..pact) end
    if not pacts[pact][pet.name] then return add_to_chat(123,'Abort: '..pet.name..' does not have a pact of type ['..pact..'].') end
    if pact == 'astralflow' and not buffactive['astral flow'] then return add_to_chat(123,'Abort: Astral Flow not active.') end
    windower.chat.input('/pet "'..pacts[pact][pet.name]..'"')
end
function handle_pacthelp(args)
    local types = {'cure','curaga','buffoffense','buffdefense','buffspecial','buffspecial2','debuff1','debuff2','sleep','nuke2','nuke4','bp70','bp75','bp99','physical','magical','astralflow'}
    local avatars = {'Carbuncle','Ifrit','Shiva','Garuda','Titan','Ramuh','Leviathan','Fenrir','Diabolos','Cait Sith','Siren'}
    local seen = {}
    for _,v in ipairs(types) do seen[v] = true end
    for t in pairs(pacts) do if not seen[t] then types[#types+1] = t end end
    table.sort(types)
    local function show_avatar(name)
        add_to_chat(122,'--- '..name..' (gs c pact <type>) ---')
        local found = false
        for _,t in ipairs(types) do
            local bp = pacts[t] and pacts[t][name]
            if bp then add_to_chat(217,t..' -> '..bp); found = true end
        end
        if not found then add_to_chat(123,name..' has no pact commands.') end
    end
    local function show_type(t)
        add_to_chat(122,'--- gs c pact '..t..' ---')
        for _,name in ipairs(avatars) do
            if pacts[t][name] then add_to_chat(217,name..' -> '..pacts[t][name]) end
        end
    end
    local arg = args[2] and table.concat(args,' ',2):lower()
    if not arg then
        if pet.isvalid and ::avatars:contains(pet.name) then
            show_avatar(pet.name)
        else
            add_to_chat(122,'--- Pact types (gs c pact <type>) ---')
            add_to_chat(217,table.concat(types,', '))
            add_to_chat(122,'gs c pacthelp <avatar> or gs c pacthelp <type>')
        end
        return
    end
    if pacts[arg] then return show_type(arg) end
    for _,name in ipairs(avatars) do
        if name:lower() == arg then return show_avatar(name) end
    end
    if arg == 'alexander' or arg == 'odin' then
        return add_to_chat(122,arg:gsub('^%l',string.upper)..' auto-fires its own Astral Flow pact on summon -- no pact commands.')
    end
    add_to_chat(123,'Abort: no pact type or avatar called ['..arg..'].')
end
local cait_raise_spells = S{'Raise','Raise II','Raise III','Arise'}
local cait_reraise_spells = S{'Reraise','Reraise II','Reraise III','Reraise IV'}
cait_pending = nil
function fire_cait_pact(pact,target)
    local recast = windower.ffxi.get_ability_recasts()[174]
    if recast and recast > 0 then
        return add_to_chat(123,'Abort: [Blood Pact: Ward] on cooldown ('..seconds_to_clock(recast)..').')
    end
    windower.chat.input('/pet "'..pact..'"'..(target and ' '..target or ''))
end
function fire_cait_pending()
    local p = cait_pending
    cait_pending = nil
    if p and os.clock() < p.expires and pet.isvalid and pet.name == 'Cait Sith' then
        fire_cait_pact(p.pact,p.target)
    end
end
function smart_cait_pact(pact,target)
    if data.areas.cities:contains(world.area) then return add_to_chat(123,'Abort: You cannot use pacts in town.') end
    if pet.isvalid and pet.name == 'Cait Sith' then
        cait_pending = nil
        return fire_cait_pact(pact,target)
    end
    cait_pending = {pact=pact,target=target,expires=os.clock()+25}
    add_to_chat(122,'Summoning Cait Sith for ['..pact..']...')
    windower.chat.input('/ma "Cait Sith" <me>')
end
function smart_cait_raise(target)
    local t = player.target
    if not target and t and t.type ~= 'SELF' and t.type ~= 'MONSTER' and t.type ~= 'NONE' and (t.status == 2 or t.status == 3) then
        target = tostring(t.id)
    end
    smart_cait_pact('Raise II',target)
end
function handle_cait_redirect(spell,eventArgs)
    if spell.action_type ~= 'Magic' then return end
    if cait_raise_spells:contains(spell.english) then
        eventArgs.cancel = true
        smart_cait_raise()
    elseif cait_reraise_spells:contains(spell.english) then
        eventArgs.cancel = true
        smart_cait_pact('Reraise II','<me>')
    end
end
function handle_smartcure(args)
    local target
    if args[2] then
        target = tonumber(args[2]) and windower.ffxi.get_mob_by_id(tonumber(args[2]))
            or get_closest_mob_by_name(table.concat(args,' ',2))
            or player.target or player
    else
        target = player.target
        if not target or target.type == 'SELF' or target.type == 'MONSTER' or target.type == 'NONE' then
            target = player
        end
    end
    if target.status == 2 or target.status == 3 then
        return smart_cait_pact('Raise II',tostring(target.id))
    end
    if not silent_can_use(1) then return add_to_chat(123,'Abort: No Cure available on this sub job.') end
    local recasts = windower.ffxi.get_spell_recasts()
    local names = {'Cure','Cure II','Cure III','Cure IV'}
    local function cast(order)
        for _,n in ipairs(order) do
            if silent_can_use(n) and recasts[n] < spell_latency then
                return windower.chat.input('/ma "'..names[n]..'" '..target.id)
            end
        end
        add_to_chat(123,'Abort: Appropriate cures are on cooldown.')
    end
    if target.type == 'MONSTER' then return cast({4,3,2}) end
    local missingHP
    if target.in_alliance then
        target.hp = find_player_in_alliance(target.name).hp
        missingHP = math.floor(target.hp / (target.hpp / 100) - target.hp)
    else
        missingHP = math.floor(1800 - 1800 * target.hpp / 100)
    end
    check_aurorastorm_for_cure(missingHP,target)
    cast(missingHP < 250 and {1,2} or missingHP < 400 and {2,3,1} or missingHP < 650 and {3,4,2} or {4,3,2})
end
function job_tick()
    if check_favor() then return true end
    if check_buff() then return true end
    return check_buffup()
end
function check_favor()
    if state.AutoFavor.value and pet.isvalid and not buffactive["Avatar's Favor"] and not (buffactive.amnesia or buffactive.impairment)
        and windower.ffxi.get_ability_recasts()[176] < latency then
        windower.chat.input('/pet "Avatar\'s Favor" <me>')
        tickdelay = os.clock() + 1.1
        return true
    end
    return false
end
function handle_elemental(args)
    if not args[2] then return add_to_chat(123,'Error: No elemental command given.') end
    local c,e = args[2]:lower(),state.ElementalMode.value
    if c == 'spikes' then return windower.chat.input('/ma "'..data.elements.spikes_of[e]..' Spikes" <me>') end
    if c == 'enspell' then return windower.chat.input('/ma "En'..data.elements.enspell_of[e]..'" <me>') end
    if c == 'weather' then
        if player.sub_job == 'RDM' then return windower.chat.input('/ma "Phalanx" <me>') end
        local recasts = windower.ffxi.get_spell_recasts()
        if (player.target.type == 'SELF' or not player.target.in_party)
            and buffactive[data.elements.storm_of[e]]
            and not buffactive.Klimaform and recasts[287] < spell_latency then
            return windower.chat.input('/ma "Klimaform" <me>')
        end
        return windower.chat.input('/ma "'..data.elements.storm_of[e]..'"')
    end
    local target = args[3] and (tonumber(args[3]) or get_closest_mob_id_by_name(table.concat(args,' ',3))) or '<t>'
    if c == 'nuke' or c == 'smallnuke' then
        local recasts = windower.ffxi.get_spell_recasts()
        for _,tier in ipairs({' II',''}) do
            local spell = get_spell_table_by_name(data.elements.nuke_of[e]..tier)
            if recasts[spell.id] < spell_latency and actual_cost(spell) < player.mp then
                windower.chat.input('/ma "'..spell.name..'" '..target)
                windower.add_to_chat(7,'/ma "'..spell.name..'" '..target)
                return
            end
        end
        return add_to_chat(123,'Abort: All '..data.elements.nuke_of[e]..' nukes on cooldown or not enough MP.')
    end
    if c:contains('tier') then
        local tiers = {tier1='',tier2=' II',tier3=' III',tier4=' IV',tier5=' V',tier6=' VI'}
        return windower.chat.input('/ma "'..data.elements.nuke_of[e]..tiers[c]..'" '..target)
    elseif c == 'ara' then
        return windower.chat.input('/ma "'..data.elements.nukera_of[e]..'ra" '..target)
    elseif c == 'aga' then
        return windower.chat.input('/ma "'..data.elements.nukega_of[e]..'ga" '..target)
    elseif c == 'helix' then
        return windower.chat.input('/ma "'..data.elements.helix_of[e]..'helix" '..target)
    elseif c == 'enfeeble' then
        return windower.chat.input('/ma "'..data.elements.elemental_enfeeble_of[e]..'" '..target)
    elseif c == 'bardsong' then
        return windower.chat.input('/ma "'..data.elements.threnody_of[e]..' Threnody" '..target)
    end
    add_to_chat(123,'Unrecognized elemental command.')
end
function check_buff()
    if state.AutoBuffMode.value == 'Off' or data.areas.cities:contains(world.area) then return false end
    local list = buff_spell_lists[state.AutoBuffMode.value]
    if not list then return false end
    local recasts = windower.ffxi.get_spell_recasts()
    for _,b in ipairs(list) do
        local active,when = buffactive[b.Buff],b.When
        if not active
            and (when == 'Always' or (when == 'Combat' and (player.in_combat or being_attacked))
            or (when == 'Engaged' and player.status == 'Engaged')
            or (when == 'Idle' and player.status == 'Idle')
            or (when == 'OutOfCombat' and not (player.in_combat or being_attacked)))
            and recasts[b.SpellID] < spell_latency and silent_can_use(b.SpellID) then
            windower.chat.input('/ma "'..b.Name..'" <me>')
            tickdelay = os.clock() + 2
            return true
        end
    end
    return false
end
function check_buffup()
    if buffup == '' then return false end
    local list = buff_spell_lists[buffup]
    for _,b in ipairs(list) do
        if not buffactive[b.Buff] and silent_can_use(b.SpellID) then
            local recasts = windower.ffxi.get_spell_recasts()
            if recasts[b.SpellID] < spell_latency then
                windower.chat.input('/ma "'..b.Name..'" <me>')
                tickdelay = os.clock() + 2
                return true
            end
        end
    end
    add_to_chat(217,'All '..buffup..' buffs are up!')
    buffup = ''
    return false
end
buff_spell_lists = {
	Auto = {--Options for When are: Always, Engaged, Idle, OutOfCombat, Combat
		{Name='Reraise',	Buff='Reraise',		SpellID=113,	When='Always'},
		{Name='Haste',		Buff='Haste',		SpellID=57,		When='Always'},
		{Name='Refresh',	Buff='Refresh',		SpellID=109,	When='Always'},
		{Name='Stoneskin',	Buff='Stoneskin',	SpellID=54,		When='Always'},
	},
	Default = {
		{Name='Reraise',	Buff='Reraise',		SpellID=113,	Reapply=false},
		{Name='Haste',		Buff='Haste',		SpellID=57,		Reapply=false},
		{Name='Refresh',	Buff='Refresh',		SpellID=109,	Reapply=false},
		{Name='Aquaveil',	Buff='Aquaveil',	SpellID=55,		Reapply=false},
		{Name='Stoneskin',	Buff='Stoneskin',	SpellID=54,		Reapply=false},
		{Name='Blink',		Buff='Blink',		SpellID=53,		Reapply=false},
		{Name='Regen',		Buff='Regen',		SpellID=108,	Reapply=false},
		{Name='Phalanx',	Buff='Phalanx',		SpellID=106,	Reapply=false},
	},
}
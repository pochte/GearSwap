--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SMN.lua — Changelog
-- 2026-07-30: Added Fenrir's "Impact" (level 99 Dark-elemental Blood Pact: Rage, confirmed
--             via bg-wiki -- distinct from the player's own "Impact" spell of the same name)
--             into pacts.debuff2['Fenrir']. [FLAG]: this REPLACES the previous value there,
--             'Lunar Roar' -- pacts.* only holds one pact per avatar per category, so Lunar
--             Roar is no longer reachable via `gs c pact debuff2` for Fenrir specifically.
--             Lunar Roar remains fully reachable elsewhere via `gs c pact debuff1`? No --
--             debuff1['Fenrir'] is 'Lunar Cry', a different pact entirely. Net effect: Lunar
--             Roar is currently NOT reachable through any `gs c pact` command until told
--             otherwise -- flagging per My Lady's request rather than silently dropping it.
--             Added a Notes block below documenting every `gs c` command this file exposes
--             and exactly which avatar/pact each maps to, per My Lady's request. No new
--             commands were added -- `gs c pact <type>` already covers every category
--             requested (buffoffense/buffdefense/buffspecial/buffspecial2/debuff1/debuff2/
--             sleep/cure/curaga/nuke2/nuke4/bp70/bp75/bp99/astralflow/physical/magical).
-- 2026-07-26: Wired in Smart-Caster.lua (Afflatus/Arts/Storm-prep helpers -- whichever apply
--             to SMN's actual subjob at the time) and added handle_smartcure(). [ASSUMPTION]:
--             Cure access is via subjob only (typically /WHM or /RDM); silent_can_use
--             gracefully no-ops any tier you don't actually have, so this is safe regardless
--             of which sub you're running. Also confirmed the commented-out
--             job_pet_aftercast/job_self_command block further down (inside the old
--             "Pact buffs now handled by timers plugin" --[[ ]] comment) is genuinely inert --
--             only the live copies near the top of the file run; nothing here needed fixing.
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Setup functions for this job.  Generally should not be modified.
-------------------------------------------------------------------------------------------------------------------

-- Also, you'll need the Shortcuts addon to handle the auto-targetting of the custom pact commands.

--[[
    Custom commands:
    
    gs c petweather
        Automatically casts the storm appropriate for the current avatar, if possible.
    
    gs c siphon
        Automatically run the process to: dismiss the current avatar; cast appropriate
        weather; summon the appropriate spirit; Elemental Siphon; release the spirit;
        and re-summon the avatar.
        
        Will not cast weather you do not have access to.
        Will not re-summon the avatar if one was not out in the first place.
        Will not release the spirit if it was out before the command was issued.
        
    gs c pact [PactType]
        Attempts to use the indicated pact type for the current avatar.
        PactType can be one of:
            cure
            curaga
            buffOffense
            buffDefense
            buffSpecial
			buffSpecial2
            debuff1
            debuff2
            sleep
            nuke2
            nuke4
            bp70
            bp75 (merits and lvl 75-80 pacts)
			bp99 (newly released offensive pacts)
			physical (most commonly used physical pact by avatar)
			magical (most commonly used magical pact by avatar)
            astralflow

    gs c elemental [spikes|enspell|weather|nuke|smallnuke|tierN|ara|aga|helix|enfeeble|bardsong]
        Standard elemental-wheel shortcuts (see WHM/BLM/RDM.lua for the same pattern),
        driven off state.ElementalMode. NOTE: as of 2026-07-30, Ctrl+` was overridden by
        this job's own PactSpamMode toggle bind, which silently killed the global
        `gs c cycle ElementalMode` bind on SMN specifically -- see Ullona_Smn_Gear.lua's
        changelog. PactSpamMode has been moved to Ctrl+\ to restore the wheel.

    gs c conduitlock
        Toggles whether Astral Conduit locks your gear slots while active (ConduitLock var).

    gs c smartcure
        Missing-HP-based cure tier selection via your subjob's cure access (same pattern
        as every other job file). Independent of `gs c pact cure`/`curaga` below.

    -----------------------------------------------------------------------------------
    NOTES: gs c pact <type> -- full avatar/pact mapping (source of truth: the `pacts`
    table below, in job_setup(). This block is documentation only -- edit the table,
    not this comment, if the mapping ever changes).
    -----------------------------------------------------------------------------------
    cure          Carbuncle->Healing Ruby
    curaga        Carbuncle->Healing Ruby II, Garuda->Whispering Wind, Leviathan->Spring Water
    buffoffense   Carbuncle->Glittering Ruby, Ifrit->Crimson Howl, Garuda->Hastega II,
                  Ramuh->Rolling Thunder, Fenrir->Ecliptic Growl, Siren->Katabatic Blades
    buffdefense   Carbuncle->Shining Ruby, Shiva->Frost Armor, Garuda->Aerial Armor,
                  Titan->Earthen Ward, Ramuh->Lightning Armor, Fenrir->Ecliptic Howl,
                  Diabolos->Noctoshield, Cait Sith->Reraise II, Siren->Wind's Blessing
    buffspecial   Ifrit->Inferno Howl, Garuda->Fleet Wind, Titan->Earthen Armor,
                  Diabolos->Dream Shroud, Carbuncle->Soothing Ruby, Fenrir->Heavenward Howl,
                  Cait Sith->Raise II, Siren->Chinook
    buffspecial2  Carbuncle->Pacifying Ruby, Leviathan->Soothing Current, Shiva->Crystal Blessing
    debuff1       Shiva->Diamond Storm, Ramuh->Shock Squall, Leviathan->Tidal Roar,
                  Fenrir->Lunar Cry, Diabolos->Pavor Nocturnus, Cait Sith->Eerie Eye,
                  Siren->Lunatic Voice
    debuff2       Shiva->Sleepga, Leviathan->Slowga, Fenrir->Impact [CHANGED 2026-07-30,
                  was Lunar Roar -- see changelog], Diabolos->Somnolence, Ramuh->Thunderspark,
                  Siren->Bitter Elegy
    sleep         Shiva->Sleepga, Diabolos->Nightmare, Cait Sith->Mewing Lullaby
    nuke2         Ifrit->Fire II, Shiva->Blizzard II, Garuda->Aero II, Titan->Stone II,
                  Ramuh->Thunder II, Leviathan->Water II, Siren->Tornado II
    nuke4         Ifrit->Fire IV, Shiva->Blizzard IV, Garuda->Aero IV, Titan->Stone IV,
                  Ramuh->Thunder IV, Leviathan->Water IV, Siren->Tornado II [sic, likely a
                  pre-existing typo for "Tornado IV" -- left as-is, not part of this request]
    bp70          Ifrit->Flaming Crush, Shiva->Rush, Garuda->Predator Claws,
                  Titan->Mountain Buster, Ramuh->Chaotic Strike, Leviathan->Spinning Dive,
                  Carbuncle->Meteorite, Fenrir->Eclipse Bite, Diabolos->Nether Blast,
                  Cait Sith->Regal Scratch
    bp75          Ifrit->Meteor Strike, Shiva->Heavenly Strike, Garuda->Wind Blade,
                  Titan->Geocrush, Ramuh->Thunderstorm, Leviathan->Grand Fall,
                  Carbuncle->Holy Mist, Fenrir->Lunar Bay, Diabolos->Night Terror,
                  Cait Sith->Level ? Holy
    bp99          Ifrit->Conflag Strike, Titan->Crag Throw, Ramuh->Volt Strike,
                  Siren->Hysteric Assault
    astralflow    Ifrit->Inferno, Shiva->Diamond Dust, Garuda->Aerial Blast,
                  Titan->Earthen Fury, Ramuh->Judgment Bolt, Leviathan->Tidal Wave,
                  Carbuncle->Searing Light, Fenrir->Howling Moon, Diabolos->Ruinous Omen,
                  Cait Sith->Altana's Favor. Alexander and Odin are intentionally absent --
                  both auto-fire their own Astral Flow pact the instant they're summoned
                  and take no player command at all (confirmed via bg-wiki).
    physical      Carbuncle->Poison Nails, Fenrir->Eclipse Bite, Ifrit->Flaming Crush,
                  Titan->Mountain Buster, Leviathan->Spinning Dive, Garuda->Predator Claws,
                  Shiva->Rush, Ramuh->Volt Strike, Diabolos->Blindside, Cait Sith->Regal Gash,
                  Siren->Hysteric Assault
    magical       Carbuncle->Holy Mist, Fenrir->Lunar Bay, Ifrit->Meteor Strike,
                  Titan->Geocrush, Leviathan->Grand Fall, Garuda->Wind Blade,
                  Shiva->Heavenly Strike, Ramuh->Thunderstorm, Diabolos->Nether Blast,
                  Cait Sith->Level ? Holy, Siren->Sonic Buffet
--]]


-- Initialization function for this job file.
function get_sets()
    -- Load and initialize the include file.
    include('Sel-Include.lua')
  include('Ullona-shortcuts')
  include('Smart-Caster.lua')
end

-- Setup vars that are user-independent.  state.Buff vars initialized here will automatically be tracked.
function job_setup()

    state.Buff["Avatar's Favor"] = buffactive["Avatar's Favor"] or false
    state.Buff["Astral Conduit"] = buffactive["Astral Conduit"] or false
	state.Buff['Aftermath: Lv.3'] = buffactive['Aftermath: Lv.3'] or false

    avatars = S{"Carbuncle", "Fenrir", "Diabolos", "Ifrit", "Titan", "Leviathan", "Garuda", "Shiva", "Ramuh", "Odin", "Alexander", "Cait Sith", "Siren"}
    spirits = S{"LightSpirit", "DarkSpirit", "FireSpirit", "EarthSpirit", "WaterSpirit", "AirSpirit", "IceSpirit", "ThunderSpirit"}
	spirit_of = {['Light']="Light Spirit", ['Dark']="Dark Spirit", ['Fire']="Fire Spirit", ['Earth']="Earth Spirit",
        ['Water']="Water Spirit", ['Wind']="Air Spirit", ['Ice']="Ice Spirit", ['Lightning']="Thunder Spirit"}

    magicalRagePacts = S{
		'Inferno','Earthen Fury','Tidal Wave','Aerial Blast','Diamond Dust','Judgment Bolt','Searing Light','Howling Moon','Ruinous Omen','Clarsach Call','Impact',
		'Fire II','Stone II','Water II','Aero II','Blizzard II','Thunder II',
		'Fire IV','Stone IV','Water IV','Aero IV','Blizzard IV','Thunder IV',
		'Thunderspark','Burning Strike','Meteorite','Nether Blast','Flaming Crush',
		'Meteor Strike','Conflag Strike','Heavenly Strike','Wind Blade','Geocrush','Grand Fall','Thunderstorm',
		'Holy Mist','Lunar Bay','Night Terror','Level ? Holy','Tornado II','Sonic Buffet'}

    pacts = {}
    pacts.cure = {['Carbuncle']='Healing Ruby'}
    pacts.curaga = {['Carbuncle']='Healing Ruby II', ['Garuda']='Whispering Wind', ['Leviathan']='Spring Water'}
    pacts.buffoffense = {['Carbuncle']='Glittering Ruby', ['Ifrit']='Crimson Howl', ['Garuda']='Hastega II', ['Ramuh']='Rolling Thunder',
		['Fenrir']='Ecliptic Growl', ['Siren']='Katabatic Blades'}
    pacts.buffdefense = {['Carbuncle']='Shining Ruby', ['Shiva']='Frost Armor', ['Garuda']='Aerial Armor', ['Titan']='Earthen Ward',
		['Ramuh']='Lightning Armor', ['Fenrir']='Ecliptic Howl', ['Diabolos']='Noctoshield', ['Cait Sith']='Reraise II', ['Siren']="Wind's Blessing"}
    pacts.buffspecial = {['Ifrit']='Inferno Howl', ['Garuda']='Fleet Wind', ['Titan']='Earthen Armor', ['Diabolos']='Dream Shroud',
		['Carbuncle']='Soothing Ruby', ['Fenrir']='Heavenward Howl', ['Cait Sith']='Raise II', ['Siren']='Chinook'}
	pacts.buffspecial2 = {['Carbuncle']='Pacifying Ruby',['Leviathan']='Soothing Current',['Shiva']='Crystal Blessing'}
    pacts.debuff1 = {['Shiva']='Diamond Storm', ['Ramuh']='Shock Squall', ['Leviathan']='Tidal Roar', ['Fenrir']='Lunar Cry',
		['Diabolos']='Pavor Nocturnus', ['Cait Sith']='Eerie Eye', ['Siren']='Lunatic Voice'}
    -- [CHANGED 2026-07-30]: Fenrir's slot here was 'Lunar Roar', now 'Impact' (its real
    -- level-99 Dark-elemental Blood Pact: Rage, confirmed via bg-wiki -- not the player's
    -- own "Impact" spell of the same name). This was an explicit request; Lunar Roar is no
    -- longer reachable via any `gs c pact` command as a result -- see changelog at top of file.
    pacts.debuff2 = {['Shiva']='Sleepga', ['Leviathan']='Slowga', ['Fenrir']='Impact', ['Diabolos']='Somnolence', ['Ramuh']='Thunderspark',
		['Siren']='Bitter Elegy'}
    pacts.sleep = {['Shiva']='Sleepga', ['Diabolos']='Nightmare', ['Cait Sith']='Mewing Lullaby'}
    pacts.nuke2 = {['Ifrit']='Fire II', ['Shiva']='Blizzard II', ['Garuda']='Aero II', ['Titan']='Stone II',
		['Ramuh']='Thunder II', ['Leviathan']='Water II', ['Siren']='Tornado II'}
    pacts.nuke4 = {['Ifrit']='Fire IV', ['Shiva']='Blizzard IV', ['Garuda']='Aero IV', ['Titan']='Stone IV',
		['Ramuh']='Thunder IV', ['Leviathan']='Water IV', ['Siren']='Torando II'}
    pacts.bp70 = {['Ifrit']='Flaming Crush', ['Shiva']='Rush', ['Garuda']='Predator Claws', ['Titan']='Mountain Buster',
		['Ramuh']='Chaotic Strike', ['Leviathan']='Spinning Dive', ['Carbuncle']='Meteorite', ['Fenrir']='Eclipse Bite',
		['Diabolos']='Nether Blast',['Cait Sith']='Regal Scratch'}
    pacts.bp75 = {['Ifrit']='Meteor Strike', ['Shiva']='Heavenly Strike', ['Garuda']='Wind Blade', ['Titan']='Geocrush',
		['Ramuh']='Thunderstorm', ['Leviathan']='Grand Fall', ['Carbuncle']='Holy Mist', ['Fenrir']='Lunar Bay',
		['Diabolos']='Night Terror', ['Cait Sith']='Level ? Holy'}
	pacts.bp99 = {['Ifrit']='Conflag Strike',['Titan']='Crag Throw',['Ramuh']='Volt Strike', ['Siren']='Hysteric Assault'}
    pacts.astralflow = {['Ifrit']='Inferno', ['Shiva']='Diamond Dust', ['Garuda']='Aerial Blast', ['Titan']='Earthen Fury',
		['Ramuh']='Judgment Bolt', ['Leviathan']='Tidal Wave', ['Carbuncle']='Searing Light', ['Fenrir']='Howling Moon',
		['Diabolos']='Ruinous Omen', ['Cait Sith']="Altana's Favor"}
	
	--Most commonly used offensive pacts by avatar split into two categories.
	pacts.physical = {['Carbuncle']='Poison Nails',['Fenrir']='Eclipse Bite',['Ifrit']='Flaming Crush',['Titan']='Mountain Buster',
		['Leviathan']='Spinning Dive',['Garuda']='Predator Claws',['Shiva']='Rush',['Ramuh']='Volt Strike',['Diabolos']='Blindside',
		['Cait Sith']='Regal Gash',['Siren']='Hysteric Assault'}
	pacts.magical = {['Carbuncle']='Holy Mist',['Fenrir']='Lunar Bay',['Ifrit']='Meteor Strike',['Titan']='Geocrush',
		['Leviathan']='Grand Fall',['Garuda']='Wind Blade',['Shiva']='Heavenly Strike',['Ramuh']='Thunderstorm',['Diabolos']='Nether Blast',
		['Cait Sith']='Level ? Holy',['Siren']='Sonic Buffet'}

	ConduitLock = true
	ConduitLocked = nil
	state.PactSpamMode = M(false, 'Pact Spam Mode')
	state.AutoFavor = M(true, 'Auto Favor')
	state.AutoConvert = M(true, 'Auto Convert')
	
	autows = 'Spirit Taker'
	autofood = 'Akamochi'
	
	init_job_states({"Capacity","AutoRuneMode","AutoTrustMode","AutoNukeMode","PactSpamMode","AutoWSMode","AutoShadowMode","AutoFoodMode","AutoStunMode","AutoDefenseMode"},{"AutoBuffMode","Weapons","OffenseMode","WeaponskillMode","IdleMode","Passive","RuneElement","ElementalMode","CastingMode","TreasureMode",})
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------
-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.

function job_filtered_action(spell, eventArgs)

end

function job_pretarget(spell, spellMap, eventArgs)

end

function job_filter_precast(spell, spellMap, eventArgs)

	if pet.name == spell.english and pet.hpp > 50 then
		add_to_chat(122, "You already have that avatar active!")
		eventArgs.cancel = true
	elseif avatars:contains(spell.english) and pet.isvalid then
		eventArgs.cancel = true
		windower.chat.input('/pet Release <me>')
		windower.chat.input:schedule(2,'/ma "'..spell.english..'" <me>')
	end

	if state.Buff['Astral Conduit'] and spell.type:startswith('BloodPact') and player.mp < (actual_cost(spell) + actual_cost(spell)) then
		local abil_recasts = windower.ffxi.get_ability_recasts()
		local available_ws = S(windower.ffxi.get_abilities().weapon_skills)

		if player.tp > 999 and available_ws:contains(190) then
			add_to_chat(122,'Not enough MP to Pact while using Conduit, using Myrkr!')
			windower.chat.input('/ws Myrkr <me>')
		elseif player.sub_job == 'SCH' and buffactive['Sublimation: Complete'] then
			add_to_chat(122,'Not enough MP to Pact while using Conduit, using Sublimation!')
			windower.chat.input('/ja Sublimation <me>')	
		elseif player.sub_job == 'RDM' and abil_recasts[49] < latency and player.mp > 0 and player.hp > 400 and state.AutoConvert.value then
			add_to_chat(122,'Not enough MP to Pact while using Conduit, Converting!')
			eventArgs.cancel = true
			windower.chat.input('/ja Convert <me>')
		end
	end

end

function job_precast(spell, spellMap, eventArgs)
	if spell.action_type == 'Magic' then
		if state.CastingMode.value == 'Proc' then
            classes.CustomClass = 'Proc'
        elseif state.CastingMode.value == 'OccultAcumen' then
            classes.CustomClass = 'OccultAcumen'
        end

		-- [NEW] Wires in Smart-Caster.lua's shared Afflatus/Arts/Storm-prep helpers.
		-- Placed last, after SMN's own tailored precast logic above, so anything SMN
		-- already handles explicitly keeps priority.
		smart_caster_precast(spell, spellMap, eventArgs)
	end
end

function job_post_precast(spell, spellMap, eventArgs)
	if spell.type == 'WeaponSkill' then
		local WSset = standardize_set(get_precast_set(spell, spellMap))
		
		if (WSset.ear1 == "Moonshade Earring" or WSset.ear2 == "Moonshade Earring") then
			-- Replace Moonshade Earring if we're at cap TP
			if sets.MaxTP and get_effective_player_tp(spell, WSset) > 3200 then
				equip(sets.MaxTP[spell.english] or sets.MaxTP)
			end
		end
	end
end

function job_midcast(spell, spellMap, eventArgs)

end

function job_post_midcast(spell, spellMap, eventArgs)

	if spell.skill == 'Elemental Magic' and default_spell_map ~= 'ElementalEnfeeble' and spell.english ~= 'Impact' then
        if state.MagicBurstMode.value ~= 'Off' then equip(sets.MagicBurst) end
		if spell.element == world.weather_element or spell.element == world.day_element then
			-- [FIX 2026-08-30] Was an inline copy of the Zodiac Ring swap, identical to the
			-- same block duplicated in WHM/RDM/BLM/SCH. Consolidated into the shared
			-- try_zodiac_ring() helper (Ullona-Globals.lua) -- one source of truth now.
			try_zodiac_ring(spell)
		end
		
		if spell.element and sets.element[spell.element] then
			equip(sets.element[spell.element])
		end
    end
	
end

function job_aftercast(spell, spellMap, eventArgs)
	-- [NEW] Auto-reactivates Sublimation whenever it drops, if subbing SCH. No-ops
	-- harmlessly on any other subjob.
	try_sublimation()

    if not spell.interrupted then
		if state.UseCustomTimers.value and spell.english == 'Sleep' or spell.english == 'Sleepga' then
            send_command('@timers c "'..spell.english..' ['..spell.target.name..']" 60 down spells/00220.png')
        elseif spell.skill == 'Elemental Magic' and state.MagicBurstMode.value == 'Single' then
            state.MagicBurstMode:reset()
			if state.DisplayMode.value then update_job_states()	end
		elseif type(spell.type) == 'string' and spell.type:startswith('BloodPact') and state.DefenseMode.value == 'None' then
			petWillAct = os.clock()
			if ConduitLocked and ConduitLocked ~= spell.english then
				ConduitLocked = nil
				if state.Weapons.value == 'None' then
					enable('main','sub','range','ammo','head','neck','lear','rear','body','hands','lring','rring','back','waist','legs','feet')
				else
					enable('range','ammo','head','neck','lear','rear','body','hands','lring','rring','back','waist','legs','feet')
				end
			end
			equip(get_pet_midcast_set(spell, spellMap))
			if state.Buff['Aftermath: Lv.3'] then
				if sets.midcast.Pet[spell.english] and sets.midcast.Pet[spell.english].AM then
					equip(sets.midcast.Pet[spell.english].AM)
				elseif spellMap == 'PhysicalBloodPactRage' and sets.midcast.Pet.PhysicalBloodPactRage.AM then
					equip(sets.midcast.Pet.PhysicalBloodPactRage.AM)
				end
			end

			if state.CastingMode.value == 'Resistant' then
				if sets.midcast.Pet[spell.english] and sets.midcast.Pet[spell.english].Acc then
					equip(sets.midcast.Pet[spell.english].Acc)
				elseif spellMap == 'PhysicalBloodPactRage' and sets.midcast.Pet.PhysicalBloodPactRage.Acc then
					equip(sets.midcast.Pet.PhysicalBloodPactRage.Acc)
				elseif spellMap == 'MagicalBloodPactRage' and sets.midcast.Pet.MagicalBloodPactRage.Acc then
						equip(sets.midcast.Pet.MagicalBloodPactRage.Acc)
				end
			end
			
			if spellMap == 'PhysicalBloodPactRage' then
				if sets.midcast.Pet.PhysicalBloodPactRage[pet.name] then
					equip(sets.midcast.Pet.PhysicalBloodPactRage[pet.name])
				end
			elseif spellMap == 'MagicalBloodPactRage' then
				if sets.midcast.Pet.MagicalBloodPactRage[pet.name] then
					equip(sets.midcast.Pet.MagicalBloodPactRage[pet.name])
				end
			elseif spellMap == 'DebuffBloodPactWard' then
				if sets.midcast.Pet.BloodPactWard[pet.name] then
					equip(sets.midcast.Pet.BloodPactWard[pet.name])
				end
			end	
			
			if state.Buff['Astral Conduit'] and ConduitLock and ConduitLocked == nil then
				ConduitLocked = spell.english
				disable('main','sub','range','ammo','head','neck','lear','rear','body','hands','lring','rring','back','waist','legs','feet')
				add_to_chat(217, "Astral Conduit on, locking your "..spell.english.." set.")
			end
			eventArgs.handled = true
		elseif pet_midaction() or avatars:contains(spell.english) then
			eventArgs.handled = true
        end
    end
end

-- Runs when pet completes an action.
function job_pet_aftercast(spell, spellMap, eventArgs)
	if state.PactSpamMode.value == true and spell.type == 'BloodPactRage'then
		abil_recasts = windower.ffxi.get_ability_recasts()
		if abil_recasts[173] == 0 then
			windower.chat.input('/pet "'..spell.name..'" <t>')
		end
	end
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for non-casting events.
-------------------------------------------------------------------------------------------------------------------

-- Called when a player gains or loses a buff.
-- buff == buff gained or lost
-- gain == true if the buff was gained, false if it was lost.
function job_buff_change(buff, gain)
	-- [NEW] Lets Smart-Caster.lua react to Sublimation falling off (re-triggers try_sublimation).
	smart_caster_buff_change(buff, gain)

	if buff == 'Astral Conduit' and ConduitLocked ~= nil and not gain then
		ConduitLocked = nil
		add_to_chat(217, "Astral Conduit has worn, enabling all slots.")

		if state.Weapons.value == 'None' then
			enable('main','sub','range','ammo','head','neck','lear','rear','body','hands','lring','rring','back','waist','legs','feet')
		else
			enable('range','ammo','head','neck','lear','rear','body','hands','lring','rring','back','waist','legs','feet')
		end
	end
end

-- Called when the player's pet's status changes.
-- This is also called after pet_change after a pet is released.  Check for pet validity.
function job_pet_status_change(newStatus, oldStatus, eventArgs)
    if pet.isvalid and not midaction() and not pet_midaction() and (newStatus == 'Engaged' or oldStatus == 'Engaged') then
        handle_equipping_gear(player.status, newStatus)
    end
end


-- Called when a player gains or loses a pet.
-- pet == pet structure
-- gain == true if the pet was gained, false if it was lost.
function job_pet_change(petparam, gain)
    classes.CustomIdleGroups:clear()
    if gain then
        if avatars:contains(pet.name) then
            classes.CustomIdleGroups:append('Avatar')
        elseif spirits:contains(pet.name) then
            classes.CustomIdleGroups:append('Spirit')
        end
    else
		if ConduitLocked ~= nil then
			ConduitLocked = nil
			add_to_chat(217, "No Avatar summoned, enabling slots.")

			if state.OffenseMode.value == 'None' then
				enable('main','sub','range','ammo','head','neck','lear','rear','body','hands','lring','rring','back','waist','legs','feet')
			else
				enable('range','ammo','head','neck','lear','rear','body','hands','lring','rring','back','waist','legs','feet')
			end
		end
    end
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

-- Custom spell mapping.
function job_get_spell_map(spell)
    if spell.type == 'BloodPactRage' then
        if magicalRagePacts:contains(spell.english) then
            return 'MagicalBloodPactRage'
        else
            return 'PhysicalBloodPactRage'
        end
    elseif spell.type == 'BloodPactWard' then
		if  spell.target.type == 'MONSTER' then
			return 'DebuffBloodPactWard'
		else
			return 'BloodPactWard'
		end
    end
end

-- Modify the default idle set after it was constructed.
function job_customize_idle_set(idleSet)
    if buffactive['Sublimation: Activated'] then
        if (state.IdleMode.value == 'Normal' or state.IdleMode.value:contains('Sphere')) and sets.buff.Sublimation then
            idleSet = set_combine(idleSet, sets.buff.Sublimation)
        elseif state.IdleMode.value:contains('DT') and sets.buff.DTSublimation then
            idleSet = set_combine(idleSet, sets.buff.DTSublimation)
        end
    end

    if state.IdleMode.value == 'Normal' or state.IdleMode.value:contains('Sphere') then
		if player.mpp < 51 then
			if sets.latent_refresh then
				idleSet = set_combine(idleSet, sets.latent_refresh)
			end
			
			if (state.Weapons.value == 'None' or state.UnlockWeapons.value) and idleSet.main then
				local main_table = get_item_table(idleSet.main)

				if  main_table and main_table.skill == 12 and sets.latent_refresh_grip then
					idleSet = set_combine(idleSet, sets.latent_refresh_grip)
				end
				
				if player.tp > 10 and sets.TPEat then
					idleSet = set_combine(idleSet, sets.TPEat)
				end
			end
		end
   end

    if pet.isvalid then
        if pet.element == world.day_element then
            idleSet = set_combine(idleSet, sets.perp.Day)
        end
        if pet.element == world.weather_element then
            idleSet = set_combine(idleSet, sets.perp.Weather)
        end
        if sets.perp[pet.name] then
            idleSet = set_combine(idleSet, sets.perp[pet.name])
        end
        if state.Buff["Avatar's Favor"] and avatars:contains(pet.name) then
            idleSet = set_combine(idleSet, sets.idle.Avatar.Favor)
        end
        if pet.status == 'Engaged' then
            idleSet = set_combine(idleSet, sets.idle.Avatar.Engaged)
			if sets.idle.Avatar.Engaged[pet.name] then
				idleSet = set_combine(idleSet, sets.idle.Avatar.Engaged[pet.name])
			end
        end
    end
   
    return idleSet
end

-- Called by the 'update' self-command, for common needs.
-- Set eventArgs.handled to true if we don't want automatic equipping of gear.
function job_update(commandArgs, eventArgs)
    classes.CustomIdleGroups:clear()
    if pet.isvalid then
        if avatars:contains(pet.name) then
            classes.CustomIdleGroups:append('Avatar')
        elseif spirits:contains(pet.name) then
            classes.CustomIdleGroups:append('Spirit')
        end
    end
end

-- Set eventArgs.handled to true if we don't want the automatic display to be run.
function display_current_job_state(eventArgs)

end


-------------------------------------------------------------------------------------------------------------------
-- User self-commands.
-------------------------------------------------------------------------------------------------------------------

-- Called for custom player commands.
function job_self_command(commandArgs, eventArgs)
    if commandArgs[1]:lower() == 'petweather' then
        handle_petweather()
        eventArgs.handled = true
    elseif commandArgs[1]:lower() == 'siphon' then
        handle_siphoning()
        eventArgs.handled = true
    elseif commandArgs[1]:lower() == 'pact' then
        handle_pacts(commandArgs)
        eventArgs.handled = true
	elseif commandArgs[1]:lower() == 'elemental' then
		handle_elemental(commandArgs)
		eventArgs.handled = true			
    elseif commandArgs[1]:lower() == 'conduitlock' then
		if ConduitLock == true then
			ConduitLock = false
			add_to_chat(122, "Astral Conduit no longer locks gear.")
		elseif ConduitLock == false then
			ConduitLock = true
			add_to_chat(122, "Astral Conduit now locks gear.")
		end
	elseif commandArgs[1]:lower() == 'smartcure' then
		handle_smartcure(commandArgs)
		eventArgs.handled = true
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

-- Cast the appopriate storm for the currently summoned avatar, if possible.
function handle_petweather()
    if player.sub_job ~= 'SCH' then
        add_to_chat(123, "You can not cast storm spells.")
        return
    end
        
    if not pet.isvalid then
        add_to_chat(123, "You do not have an active avatar.")
        return
    end
    
    local element = pet.element
    if element == 'Thunder' then
        element = 'Lightning'
    end
    
    local storm = data.elements.storm_of[element]
    
    if storm then
        windower.chat.input('/ma "'..data.elements.storm_of[element]..'" <me>')
    else
        add_to_chat(123, 'Error: Unknown element ('..tostring(element)..')')
    end
end


-- Custom uber-handling of Elemental Siphon
function handle_siphoning()
	local abil_recasts = windower.ffxi.get_ability_recasts()
    if data.areas.cities:contains(world.area) then
        add_to_chat(122, 'Cannot use Elemental Siphon in a city area.')
        return
	elseif abil_recasts[175] > 0 then
        add_to_chat(123,'Abort: [Elemental Siphon] waiting on recast. ('..seconds_to_clock(abil_recasts[175])..')')
        return
    end

    local siphonElement
    local stormElementToUse
    local releasedAvatar
    local dontRelease
    
    -- If we already have a spirit out, just use that.
    if pet.isvalid and spirits:contains(pet.name) then
        siphonElement = pet.element
        dontRelease = true
        -- If current weather doesn't match the spirit, but the spirit matches the day, try to cast the storm.
        if player.sub_job == 'SCH' and pet.element == world.day_element and pet.element ~= world.weather_element then
            if not S{'Light','Dark','Lightning'}:contains(pet.element) then
                stormElementToUse = pet.element
            end
        end
    -- If we're subbing /sch, there are some conditions where we want to make sure specific weather is up.
    -- If current (single) weather is opposed by the current day, we want to change the weather to match
    -- the current day, if possible.
    elseif player.sub_job == 'SCH' and world.weather_element ~= 'None' then
        -- We can override single-intensity weather; leave double weather alone, since even if
        -- it's partially countered by the day, it's not worth changing.
        if world.weather_intensity == 1 then
            -- If current weather is weak to the current day, it cancels the benefits for
            -- siphon.  Change it to the day's weather if possible (+0 to +20%), or any non-weak
            -- weather if not.
            -- If the current weather matches the current avatar's element (being used to reduce
            -- perpetuation), don't change it; just accept the penalty on Siphon.
            if world.weather_element == data.elements.weak_to[world.day_element] and (not pet.isvalid or world.weather_element ~= pet.element) then
				stormElementToUse = world.day_element
            end
        end
    end
    
    -- If we decided to use a storm, set that as the spirit element to cast.
    if stormElementToUse then
        siphonElement = stormElementToUse
    elseif world.weather_element ~= 'None' and (world.weather_intensity == 2 or world.weather_element ~= data.elements.weak_to[world.day_element]) then
        siphonElement = world.weather_element
    else
        siphonElement = world.day_element
    end
    
    local command = ''
    local releaseWait = 0
    
    if pet.isvalid and avatars:contains(pet.name) then
        command = command..'input /pet "Release" <me>;wait 1.1;'
        releasedAvatar = pet.name
        releaseWait = 10
    end
    
    if stormElementToUse then
        command = command..'input /ma "'..data.elements.storm_of[stormElementToUse]..'" <me>;wait 4;'
        releaseWait = releaseWait - 4
    end
    
    if not (pet.isvalid and spirits:contains(pet.name)) then
        command = command..'input /ma "'..spirit_of[siphonElement]..'" <me>;wait 4;'
        releaseWait = releaseWait - 4
    end
    
    command = command..'input /ja "Elemental Siphon" <me>;'
    releaseWait = releaseWait - 1
    releaseWait = releaseWait + 0.1
    
    if not dontRelease then
        if releaseWait > 0 then
            command = command..'wait '..tostring(releaseWait)..';'
        else
            command = command..'wait 1.1;'
        end
        
        command = command..'input /pet "Release" <me>;'
    end
    
    if releasedAvatar then
        command = command..'wait 1.1;input /ma "'..releasedAvatar..'" <me>'
    end
    
    send_command(command)
end


-- Handles executing blood pacts in a generic, avatar-agnostic way.
-- commandArgs is the split of the self-command.
-- gs c [pact] [pacttype]
function handle_pacts(commandArgs)
    if data.areas.cities:contains(world.area) then
        add_to_chat(123, 'Abort:You cannot use pacts in town.')
        return
    end

    if not pet.isvalid then
        add_to_chat(123,'Abort: You do not have an Avatar summoned.')
        return
    end

    if spirits:contains(pet.name) then
        add_to_chat(123,'Abort: Spirits cannot use blood pacts.')
        return
    end

    if not commandArgs[2] then
        add_to_chat(123,'Abort: No blood pact type given.')
        return
    end
    
    local pact = commandArgs[2]:lower()
    
    if not pacts[pact] then
        add_to_chat(123,'Abort: Unknown blood pact type: '..tostring(pact))
        return
    end
    
    if pacts[pact][pet.name] then
        if pact == 'astralflow' and not buffactive['astral flow'] then
            add_to_chat(123,'Abort: Astral Flow not active.')
            return
        end
        
        -- Leave out target; let Shortcuts auto-determine it.
        windower.chat.input('/pet "'..pacts[pact][pet.name]..'"')
    else
        add_to_chat(123,'Abort: '..pet.name..' does not have a pact of type ['..pact..'].')
    end
end



--[[ Pact buffs now handled by timers plugin, no need for this code.

    -- Flags for code to get around the issue of slow skill updates.
    wards.flag = false
    wards.spell = ''

    -- Wards table for creating custom timers   
    wards = {}
    -- Base duration for ward pacts.
    wards.durations = {
        ['Crimson Howl'] = 60, ['Earthen Armor'] = 60, ['Inferno Howl'] = 60, ['Heavenward Howl'] = 60,
        ['Rolling Thunder'] = 120, ['Fleet Wind'] = 120,
        ['Shining Ruby'] = 180, ['Frost Armor'] = 180, ['Lightning Armor'] = 180, ['Ecliptic Growl'] = 180,
        ['Glittering Ruby'] = 180, ['Hastega'] = 180, ['Noctoshield'] = 180, ['Ecliptic Howl'] = 180,
        ['Dream Shroud'] = 180,
        ['Reraise II'] = 3600
    }
    -- Icons to use when creating the custom timer.
    wards.icons = {
        ['Earthen Armor']   = 'spells/00299.png', -- 00299 for Titan
        ['Shining Ruby']    = 'spells/00043.png', -- 00043 for Protect
        ['Dream Shroud']    = 'spells/00304.png', -- 00304 for Diabolos
        ['Noctoshield']     = 'spells/00106.png', -- 00106 for Phalanx
        ['Inferno Howl']    = 'spells/00298.png', -- 00298 for Ifrit
        ['Hastega']         = 'spells/00358.png', -- 00358 for Hastega
        ['Rolling Thunder'] = 'spells/00104.png', -- 00358 for Enthunder
        ['Frost Armor']     = 'spells/00250.png', -- 00250 for Ice Spikes
        ['Lightning Armor'] = 'spells/00251.png', -- 00251 for Shock Spikes
        ['Reraise II']      = 'spells/00135.png', -- 00135 for Reraise
        ['Fleet Wind']      = 'abilities/00074.png', -- 
    }

windower.raw_register_event('incoming chunk',
    function (id)
        if id == 0x62 then
            if wards.flag then
                create_pact_timer(wards.spell)
                wards.flag = false
                wards.spell = ''
            end
        end
    end)

-- =============================================================================
-- Smart cure command: NEW for SMN (didn't exist before). Same missingHP-estimate pattern
-- used across every other job (RDM/WHM/BLM/GEO/SCH). [ASSUMPTION]: SMN only has Cure access
-- via subjob (typically /WHM or /RDM); silent_can_use gracefully no-ops any tier you don't
-- actually have, so this is safe regardless of which sub you're running. Note this is for
-- YOUR own cures via /ma -- it's independent of the avatar 'pact cure'/'pact curaga'
-- commands, which already exist separately via handle_pacts().
-- =============================================================================
function handle_smartcure(cmdParams)
	local cureTarget
	if cmdParams[2] then
		if tonumber(cmdParams[2]) then
			cureTarget = windower.ffxi.get_mob_by_id(tonumber(cmdParams[2]))
		else
			cureTarget = table.concat(cmdParams, ' ', 2)
			cureTarget = get_closest_mob_by_name(cureTarget)
			if not cureTarget or not cureTarget.name then cureTarget = player.target end
			if not cureTarget or not cureTarget.name then cureTarget = player end
		end
	elseif player.target and (player.target.type == "SELF" or player.target.type == 'MONSTER' or player.target.type == 'NONE') then
		cureTarget = player
	elseif player.target then
		cureTarget = player.target
	else
		cureTarget = player
	end

	if cureTarget.status == 2 or cureTarget.status == 3 then
		windower.chat.input('/ma "Arise" '..cureTarget.id..'')
		return
	end

	local spell_recasts = windower.ffxi.get_spell_recasts()

	if cureTarget.type == 'MONSTER' then
		if silent_can_use(4) and spell_recasts[4] < spell_latency then
			windower.chat.input('/ma "Cure IV" '..cureTarget.id..'')
		elseif spell_recasts[3] < spell_latency then
			windower.chat.input('/ma "Cure III" '..cureTarget.id..'')
		elseif spell_recasts[2] < spell_latency then
			windower.chat.input('/ma "Cure II" '..cureTarget.id..'')
		else
			add_to_chat(123,'Abort: Appropriate cures are on cooldown.')
		end
		return
	end

	local missingHP
	if cureTarget.in_alliance then
		cureTarget.hp = find_player_in_alliance(cureTarget.name).hp
		local est_max_hp = cureTarget.hp / (cureTarget.hpp/100)
		missingHP = math.floor(est_max_hp - cureTarget.hp)
	else
		local est_current_hp = 1800 * (cureTarget.hpp/100)
		missingHP = math.floor(1800 - est_current_hp)
	end

	check_aurorastorm_for_cure(missingHP, cureTarget)

	if missingHP < 250 then
		if spell_recasts[1] < spell_latency then
			windower.chat.input('/ma "Cure" '..cureTarget.id..'')
		elseif spell_recasts[2] < spell_latency then
			windower.chat.input('/ma "Cure II" '..cureTarget.id..'')
		else
			add_to_chat(123,'Abort: Appropriate cures are on cooldown.')
		end
	elseif missingHP < 600 then
		if spell_recasts[2] < spell_latency then
			windower.chat.input('/ma "Cure II" '..cureTarget.id..'')
		elseif spell_recasts[3] < spell_latency then
			windower.chat.input('/ma "Cure III" '..cureTarget.id..'')
		elseif spell_recasts[1] < spell_latency then
			windower.chat.input('/ma "Cure" '..cureTarget.id..'')
		else
			add_to_chat(123,'Abort: Appropriate cures are on cooldown.')
		end
	elseif missingHP < 900 then
		if spell_recasts[3] < spell_latency then
			windower.chat.input('/ma "Cure III" '..cureTarget.id..'')
		elseif silent_can_use(4) and spell_recasts[4] < spell_latency then
			windower.chat.input('/ma "Cure IV" '..cureTarget.id..'')
		elseif spell_recasts[2] < spell_latency then
			windower.chat.input('/ma "Cure II" '..cureTarget.id..'')
		else
			add_to_chat(123,'Abort: Appropriate cures are on cooldown.')
		end
	else
		if silent_can_use(4) and spell_recasts[4] < spell_latency then
			windower.chat.input('/ma "Cure IV" '..cureTarget.id..'')
		elseif spell_recasts[3] < spell_latency then
			windower.chat.input('/ma "Cure III" '..cureTarget.id..'')
		elseif spell_recasts[2] < spell_latency then
			windower.chat.input('/ma "Cure II" '..cureTarget.id..'')
		else
			add_to_chat(123,'Abort: Appropriate cures are on cooldown.')
		end
	end
end

-- Function to create custom timers using the Timers addon.  Calculates ward duration
-- based on player skill and base pact duration (defined in job_setup).
function create_pact_timer(spell_name)
    -- Create custom timers for ward pacts.
    if wards.durations[spell_name] then
        local ward_duration = wards.durations[spell_name]
        if ward_duration < 181 then
            local skill = player.skills.summoning_magic
            if skill > 300 then
                skill = skill - 300
                if skill > 200 then skill = 200 end
                ward_duration = ward_duration + skill
            end
        end
        
        local timer_cmd = 'timers c "'..spell_name..'" '..tostring(ward_duration)..' down'
        
        if wards.icons[spell_name] then
            timer_cmd = timer_cmd..' '..wards.icons[spell_name]
        end

        send_command(timer_cmd)
    end
end

-- Runs when pet completes an action.
function job_pet_aftercast(spell, spellMap, eventArgs)
    if not spell.interrupted and spell.type == 'BloodPactWard' and spellMap ~= 'DebuffBloodPactWard' then
        wards.flag = true
        wards.spell = spell.english
        send_command('wait 4; gs c reset_ward_flag')
    end
end

-- Called for custom player commands.
function job_self_command(commandArgs, eventArgs)
    if commandArgs[1]:lower() == 'petweather' then
        handle_petweather()
        eventArgs.handled = true
    elseif commandArgs[1]:lower() == 'siphon' then
        handle_siphoning()
        eventArgs.handled = true
    elseif commandArgs[1]:lower() == 'pact' then
        handle_pacts(commandArgs)
        eventArgs.handled = true
    elseif commandArgs[1] == 'reset_ward_flag' then
        wards.flag = false
        wards.spell = ''
        eventArgs.handled = true
    end
end
--]]

function job_tick()
	if check_favor() then return true end
	if check_buff() then return true end
	if check_buffup() then return true end
	return false
end

function check_favor()
	if state.AutoFavor.value and pet.isvalid and not buffactive["Avatar's Favor"] and not (buffactive.amnesia or buffactive.impairment) then
		local abil_recasts = windower.ffxi.get_ability_recasts()
		
		if abil_recasts[176] < latency then
			windower.chat.input('/pet "Avatar\'s Favor" <me>')
			tickdelay = os.clock() + 1.1
			return true
		end
	end
	return false
end

function handle_elemental(cmdParams)
    -- cmdParams[1] == 'elemental'
    -- cmdParams[2] == ability to use
	
    if not cmdParams[2] then
        add_to_chat(123,'Error: No elemental command given.')
        return
    end
    local command = cmdParams[2]:lower()

	if command == 'spikes' then
		windower.chat.input('/ma "'..data.elements.spikes_of[state.ElementalMode.value]..' Spikes" <me>')
		return
	elseif command == 'enspell' then
		windower.chat.input('/ma "En'..data.elements.enspell_of[state.ElementalMode.value]..'" <me>')
		return
	--Leave out target, let shortcuts auto-determine it.
	elseif command == 'weather' then
		if player.sub_job == 'RDM' then
			windower.chat.input('/ma "Phalanx" <me>')
		else
			local spell_recasts = windower.ffxi.get_spell_recasts()
			if (player.target.type == 'SELF' or not player.target.in_party) and buffactive[data.elements.storm_of[state.ElementalMode.value]] and not buffactive['Klimaform'] and spell_recasts[287] < spell_latency then
				windower.chat.input('/ma "Klimaform" <me>')
			else
				windower.chat.input('/ma "'..data.elements.storm_of[state.ElementalMode.value]..'"')
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

	if command == 'nuke' or command == 'smallnuke' then
		local spell_recasts = windower.ffxi.get_spell_recasts()
	
		local tiers = {' II',''}
		for k in ipairs(tiers) do
			if spell_recasts[get_spell_table_by_name(data.elements.nuke_of[state.ElementalMode.value]..''..tiers[k]..'').id] < spell_latency and actual_cost(get_spell_table_by_name(data.elements.nuke_of[state.ElementalMode.value]..''..tiers[k]..'')) < player.mp then
				windower.chat.input('/ma "'..data.elements.nuke_of[state.ElementalMode.value]..''..tiers[k]..'" '..target..'')
				windower.add_to_chat(7,'/ma "'..data.elements.nuke_of[state.ElementalMode.value]..''..tiers[k]..'" '..target..'')
				return
			end
		end
		add_to_chat(123,'Abort: All '..data.elements.nuke_of[state.ElementalMode.value]..' nukes on cooldown or or not enough MP.')
		
	elseif command:contains('tier') then
		local spell_recasts = windower.ffxi.get_spell_recasts()
		local tierlist = {['tier1']='',['tier2']=' II',['tier3']=' III',['tier4']=' IV',['tier5']=' V',['tier6']=' VI'}
		
		windower.chat.input('/ma "'..data.elements.nuke_of[state.ElementalMode.value]..tierlist[command]..'" '..target..'')
		
	elseif command == 'ara' then
		windower.chat.input('/ma "'..data.elements.nukera_of[state.ElementalMode.value]..'ra" '..target..'')
		
	elseif command == 'aga' then
		windower.chat.input('/ma "'..data.elements.nukega_of[state.ElementalMode.value]..'ga" '..target..'')
		
	elseif command == 'helix' then
		windower.chat.input('/ma "'..data.elements.helix_of[state.ElementalMode.value]..'helix" '..target..'')
	
	elseif command == 'enfeeble' then
		windower.chat.input('/ma "'..data.elements.elemental_enfeeble_of[state.ElementalMode.value]..'" '..target..'')
	
	elseif command == 'bardsong' then
		windower.chat.input('/ma "'..data.elements.threnody_of[state.ElementalMode.value]..' Threnody" '..target..'')		
    else
        add_to_chat(123,'Unrecognized elemental command.')
    end
end

function check_buff()
	if state.AutoBuffMode.value ~= 'Off' and not data.areas.cities:contains(world.area) then
		local spell_recasts = windower.ffxi.get_spell_recasts()
		for i in pairs(buff_spell_lists[state.AutoBuffMode.Value]) do
			if not buffactive[buff_spell_lists[state.AutoBuffMode.Value][i].Buff] and (buff_spell_lists[state.AutoBuffMode.Value][i].When == 'Always' or (buff_spell_lists[state.AutoBuffMode.Value][i].When == 'Combat' and (player.in_combat or being_attacked)) or (buff_spell_lists[state.AutoBuffMode.Value][i].When == 'Engaged' and player.status == 'Engaged') or (buff_spell_lists[state.AutoBuffMode.Value][i].When == 'Idle' and player.status == 'Idle') or (buff_spell_lists[state.AutoBuffMode.Value][i].When == 'OutOfCombat' and not (player.in_combat or being_attacked))) and spell_recasts[buff_spell_lists[state.AutoBuffMode.Value][i].SpellID] < spell_latency and silent_can_use(buff_spell_lists[state.AutoBuffMode.Value][i].SpellID) then
				windower.chat.input('/ma "'..buff_spell_lists[state.AutoBuffMode.Value][i].Name..'" <me>')
				tickdelay = os.clock() + 2
				return true
			end
		end
	else
		return false
	end
end

function check_buffup()
	if buffup ~= '' then
		local needsbuff = false
		for i in pairs(buff_spell_lists[buffup]) do
			if not buffactive[buff_spell_lists[buffup][i].Buff] and silent_can_use(buff_spell_lists[buffup][i].SpellID) then
				needsbuff = true
				break
			end
		end
	
		if not needsbuff then
			add_to_chat(217, 'All '..buffup..' buffs are up!')
			buffup = ''
			return false
		end
		
		local spell_recasts = windower.ffxi.get_spell_recasts()
		
		for i in pairs(buff_spell_lists[buffup]) do
			if not buffactive[buff_spell_lists[buffup][i].Buff] and silent_can_use(buff_spell_lists[buffup][i].SpellID) and spell_recasts[buff_spell_lists[buffup][i].SpellID] < spell_latency then
				windower.chat.input('/ma "'..buff_spell_lists[buffup][i].Name..'" <me>')
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
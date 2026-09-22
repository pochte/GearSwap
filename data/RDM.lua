-- =============================================================================
-- RDM.lua — Changelog
-- 2026-08-13: [FIX] handle_elemental's 'weather' command (gs c elemental weather) was casting
--             Phalanx instead of the actual storm spell for any subjob other than SCH -- an
--             apparent leftover from before Phalanx was split into its own handle_phalanx()
--             command on 2026-08-09, never updated to match. Non-SCH now correctly casts
--             data.elements.storm_of[ElementalMode] (matching the SCH branch, minus the
--             Klimaform swap which only applies with SCH sub). This is what looked like
--             "weather and phalanx casting on the same keybind" -- there was only ever one
--             command involved; it was just casting the wrong spell.
-- =============================================================================

-- Initialization function for this job file.
function get_sets()
    -- Load and initialize the include file.
    include('Sel-Include.lua')
    include('Smart-Caster.lua')
include('Ullona-shortcuts.lua')
end


-- Setup vars that are user-independent.  state.Buff vars initialized here will automatically be tracked.
function job_setup()

    state.Buff.Saboteur = buffactive.Saboteur or false
	state.Buff.Stymie = buffactive.Stymie or false
	state.Buff.Chainspell = buffactive.Chainspell or false
	state.Buff['Aftermath: Lv.3'] = buffactive['Aftermath: Lv.3'] or false
	
    LowTierNukes = S{'Stone', 'Water', 'Aero', 'Fire', 'Blizzard', 'Thunder',
        'Stone II', 'Water II', 'Aero II', 'Fire II', 'Blizzard II', 'Thunder II',
        'Stonega', 'Waterga', 'Aeroga', 'Firaga', 'Blizzaga', 'Thundaga'}
    MaxNukeTier = 5
	
	autows = "Savage Blade"
	autofood = 'Pear Crepe'
	enspell = ''
	low_mp_reminded_at = 0
	phalanx_fallback_target = nil
	
	update_melee_groups()
	init_job_states({"Capacity","AutoRuneMode","AutoTrustMode","AutoNukeMode","AutoWSMode","AutoShadowMode","AutoFoodMode","AutoStunMode","AutoDefenseMode",},{"AutoBuffMode","AutoSambaMode","Weapons","OffenseMode","WeaponskillMode","IdleMode","Passive","RuneElement","ElementalMode","CastingMode",})
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

function job_filtered_action(spell, eventArgs)

end

function job_pretarget(spell, spellMap, eventArgs)

end

function job_precast(spell, spellMap, eventArgs)
	check_ecphoria_for_ja(spell)

	if spell.action_type == 'Magic' then
		if state.Buff.Chainspell then
			eventArgs.handled = true
		end
		if spell.skill == 'Enhancing Magic' and spell.target.type == 'SELF'
			and not buffactive.Composure and not state.Buff.Chainspell
			and spell.english ~= 'Phalanx' and spell.english ~= 'Phalanx II' then
			local abil_recasts = windower.ffxi.get_ability_recasts()
			if abil_recasts[50] < latency then
				eventArgs.cancel = true
				cancel_spell()
				windower.chat.input('/ja "Composure" <me>')
				windower.chat.input:schedule(2, '/ma "'..spell.english..'" '..spell.target.raw..'')
				return
			end
		end
		if buffactive.Accession and spell.english:endswith(' II') and data.spells.enspells:contains(spell.english) then
			local tier1_name = spell.english:gsub(' II$', '')
			eventArgs.cancel = true
			cancel_spell()
			windower.chat.input('/ma "'..tier1_name..'" '..spell.target.raw)
			return
		end
		if (spell.english == 'Cure' or spell.english == 'Cure II')
			and player.sub_job == 'SCH' and not buffactive['Aurorastorm'] then
			add_to_chat(167, 'Aurorastorm is down')
		end
		if spell.skill == 'Elemental Magic' and default_spell_map ~= 'ElementalEnfeeble'
			and spell.english ~= 'Impact' and player.sub_job == 'SCH'
			and not is_magic_bursting()
			and spell.element ~= world.weather_element
			and data.elements.storm_of[spell.element]
			and not data.spells.enspells:contains(spell.english) then

			local spell_recasts = windower.ffxi.get_spell_recasts()
			local storm_name = data.elements.storm_of[spell.element]

			if buffactive[storm_name] and not buffactive['Klimaform'] and spell_recasts[287] < spell_latency then
				eventArgs.cancel = true
				cancel_spell()
				windower.chat.input('/ma "Klimaform" <me>')
				windower.chat.input:schedule(2, '/ma "'..spell.english..'" '..spell.target.raw..'')
				return
			elseif spell_recasts[get_spell_table_by_name(storm_name).id] < spell_latency then
				eventArgs.cancel = true
				cancel_spell()
				windower.chat.input('/ma "'..storm_name..'" <me>')
				windower.chat.input:schedule(5, '/ma "'..spell.english..'" '..spell.target.raw..'')
				return
			end
		end

		if spellMap == 'Cure' or spellMap == 'Curaga' then
			gear.default.obi_back = gear.obi_cure_back
			gear.default.obi_waist = gear.obi_cure_waist
		elseif spell.skill == 'Elemental Magic' and default_spell_map ~= 'ElementalEnfeeble' then
			if LowTierNukes:contains(spell.english) or spell.english:endswith('helix') then
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
    end

end

function job_post_precast(spell, spellMap, eventArgs)
	if spell.type == 'WeaponSkill' then
		local WSset = standardize_set(get_precast_set(spell, spellMap))
		local wsacc = check_ws_acc()
		equip(WSset)

		if (WSset.ear1 == "Moonshade Earring" or WSset.ear2 == "Moonshade Earring") then
			-- Replace Moonshade Earring if we're at cap TP
			if get_effective_player_tp(spell, WSset) > 3200 then
				if wsacc:contains('Acc') and not buffactive['Sneak Attack'] and sets.AccMaxTP then
					equip(sets.AccMaxTP[spell.english] or sets.AccMaxTP)
				elseif sets.MaxTP then
					equip(sets.MaxTP[spell.english] or sets.MaxTP)
				else
				end
			end
		end
	end
end
function job_post_midcast(spell, spellMap, eventArgs)

	if spell.skill == 'Elemental Magic' and default_spell_map ~= 'ElementalEnfeeble' and spell.english ~= 'Impact' then
		try_magic_burst()
		try_zodiac_ring(spell)

		if spell.element and sets.element[spell.element] then
			equip(sets.element[spell.element])
		end
		try_recover_mp()
		
    elseif spell.skill == 'Enfeebling Magic' then
		if state.Buff.Stymie and state.CastingMode.value:contains('Resistant') then
			if sets.midcast[spell.english] and sets.midcast[spell.english].Fodder then
				equip(sets.midcast[spell.english].Fodder)
			elseif sets.midcast[spell.english] then
				equip(sets.midcast[spell.english])
			elseif sets.midcast['Enfeebling Magic'].Fodder then
				equip(sets.midcast['Enfeebling Magic'].Fodder)
			else
				equip(sets.midcast['Enfeebling Magic'])
			end
		end
		
		if state.Buff.Saboteur then
			equip(sets.buff.Saboteur)
		end

	elseif spell.skill == 'Enhancing Magic' then
		equip(sets.midcast['Enhancing Magic'])
	
		if buffactive.Composure and spell.target.type == 'PLAYER' then
			equip(sets.buff.ComposureOther)
		end

		if can_dual_wield and sets.midcast[spell.english] and sets.midcast[spell.english].DW then
			equip(sets.midcast[spell.english].DW)
		elseif can_dual_wield and sets.midcast[spellMap] and sets.midcast[spellMap].DW then
			equip(sets.midcast[spellMap].DW)
		elseif sets.midcast[spell.english] then
			equip(sets.midcast[spell.english])
		elseif sets.midcast[spellMap] then
			equip(sets.midcast[spellMap])
		end
    end
	if spell.skill == 'Enfeebling Magic' or spell.skill == 'Dark Magic' or default_spell_map == 'ElementalEnfeeble' or spell.english == 'Impact' then
		if item_available('Regal Gem') then
			equip({range=empty,ammo="Regal Gem"})
		end
	end
end

function job_aftercast(spell, spellMap, eventArgs)
    try_sublimation()
    if spell.english == 'Phalanx' and phalanx_fallback_target then
        if spell.interrupted then
            windower.chat.input('/ma "Phalanx II" '..phalanx_fallback_target)
        end
        phalanx_fallback_target = nil
    end

    if not spell.interrupted then
        if state.UseCustomTimers.value and spell.english == 'Sleep' or spell.english == 'Sleepga' then
            send_command('@timers c "'..spell.english..' ['..spell.target.name..']" 60 down spells/00220.png')
        elseif state.UseCustomTimers.value and spell.english == 'Sleep II' then
            send_command('@timers c "'..spell.english..' ['..spell.target.name..']" 90 down spells/00220.png')
		elseif data.spells.enspells:contains(spell.english) then
			enspell = spell.english
			update_melee_groups()
		end
	end
end

function job_buff_change(buff, gain)
	smart_caster_buff_change(buff, gain)

	if buff == enspell and not gain then
		enspell = ''
	end
	update_melee_groups()
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for non-casting events.
-------------------------------------------------------------------------------------------------------------------

function job_update(cmdParams, eventArgs)
	update_melee_groups()
end

    -- Allow jobs to override this code
function job_self_command(commandArgs, eventArgs)
	if commandArgs[1]:lower() == 'elemental' then
		handle_elemental(commandArgs)
		eventArgs.handled = true			
	elseif commandArgs[1]:lower() == 'phalanx' then
		handle_phalanx(commandArgs)
		eventArgs.handled = true
	elseif commandArgs[1]:lower() == 'smartcure' then
		handle_smartcure(commandArgs)
		eventArgs.handled = true
	elseif commandArgs[1]:lower() == 'enspell' then
		handle_enspell_shortcut(commandArgs)
		eventArgs.handled = true
	elseif commandArgs[1]:lower() == 'convert' then
		handle_convert(commandArgs)
		eventArgs.handled = true
	end
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

-- Modify the default idle set after it was constructed.
function job_customize_idle_set(idleSet)
    -- [FIX] Kaja Bow retired -- range/ammo come from sets.weapons.* (range=empty,
    -- ammo="Crepuscular Pebble"). Main/sub come from the selected weapon set, no pin here.
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
    
    return idleSet
end

function job_customize_melee_set(meleeSet)
    if state.Weapons.value ~= 'None' and enspell ~= '' then
		local enspell_element = data.elements.enspells_lookup[enspell]
		if sets.element.enspell and sets.element.enspell[enspell_element] then
			meleeSet = set_combine(meleeSet, sets.element.enspell[enspell_element])
		end

		local hachirin_avail = item_available('Hachirin-no-Obi')
		if hachirin_avail and enspell_element == world.weather_element and world.weather_intensity == 2 then
			meleeSet = set_combine(meleeSet, {waist="Hachirin-no-Obi"})
		elseif item_available("Orpheus's Sash") then
			meleeSet = set_combine(meleeSet, {waist="Orpheus's Sash"})
		elseif hachirin_avail and enspell_element == world.weather_element or enspell_element == world.day_element then
			meleeSet = set_combine(meleeSet, {waist="Hachirin-no-Obi"})
		end
	end

    return meleeSet
end
function display_current_job_state(eventArgs)
    display_current_caster_state()
    eventArgs.handled = true
end

-- Custom spell mapping.
function job_get_spell_map(spell, default_spell_map)
	if  default_spell_map == 'Cure' or default_spell_map == 'Curaga'  then
		if world.weather_element == 'Light' then
                return 'LightWeatherCure'
		elseif world.day_element == 'Light' then
                return 'LightDayCure'
        end
	end	
	if spell.skill == 'Enfeebling Magic' then
		if spell.english:startswith('Dia') then
			return "Dia"
		elseif spell.type == "WhiteMagic" or spell.english:startswith('Frazzle') or spell.english:startswith('Distract') then
			return 'MndEnfeebles'
        else
            return 'IntEnfeebles'
        end
    end	
	if spell.skill == 'Elemental Magic' and default_spell_map ~= 'ElementalEnfeeble'
		and not data.spells.enspells:contains(spell.english) then
        if LowTierNukes:contains(spell.english) then
            return 'LowTierNuke'
        else
            return 'HighTierNuke'
        end
    end
	
end

-- Handling Elemental spells within Gearswap.
function handle_enspell_shortcut(cmdParams)
	local element = data.elements.enspell_of[state.ElementalMode.value]
	local element_lower = element:lower()
	local tier2_name = 'En'..element_lower..' II'
	local tier1_name = 'En'..element_lower
	local spell_recasts = windower.ffxi.get_spell_recasts()
	local tier2_spell = get_spell_table_by_name(tier2_name)
	local tier1_spell = get_spell_table_by_name(tier1_name)
	-- Safety net: if either name still doesn't resolve (e.g. an element with no matching
	-- spell), bail cleanly instead of indexing .id on a false and crashing self_command again.
	if not tier1_spell then
		add_to_chat(123,'Abort: Could not find a spell named "'..tier1_name..'".')
		return
	end
	local tier2_id = tier2_spell and tier2_spell.id
	local tier1_id = tier1_spell.id

	if tier2_id and silent_can_use(tier2_id) and spell_recasts[tier2_id] < spell_latency then
		windower.chat.input('/ma "'..tier2_name..'" <me>')
	elseif spell_recasts[tier1_id] < spell_latency then
		windower.chat.input('/ma "'..tier1_name..'" <me>')
	else
		add_to_chat(123,'Abort: Enspell tiers on cooldown.')
	end
end
function handle_phalanx(cmdParams)
	local target = cmdParams[2] and table.concat(cmdParams, ' ', 2) or '<me>'
	phalanx_fallback_target = target
	windower.chat.input('/ma "Phalanx" '..target)
end

function handle_elemental(cmdParams)
    if not cmdParams[2] then
        add_to_chat(123,'Error: No elemental command given.')
        return
    end
    local command = cmdParams[2]:lower()

	if command == 'spikes' then
		windower.chat.input('/ma "'..data.elements.spikes_of[state.ElementalMode.value]..' Spikes" <me>')
		return
	elseif command == 'enspell' then
		if  (player.sub_job == 'NIN' or player.sub_job == 'DNC') then 
			windower.chat.input('/ma "En'..data.elements.enspell_of[state.ElementalMode.value]..'" <me>')
		else
			windower.chat.input('/ma "En'..data.elements.enspell_of[state.ElementalMode.value]..' II" <me>')
		end
		return
	elseif command == 'weather' then
		if player.sub_job ~= 'SCH' then
			windower.chat.input('/ma "'..data.elements.storm_of[state.ElementalMode.value]..'"')
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

    if command == 'nuke' then
		local spell_recasts = windower.ffxi.get_spell_recasts()
		
		if state.ElementalMode.value == 'Light' then
			if spell_recasts[29] < spell_latency and actual_cost(get_spell_table_by_name('Banish II')) < player.mp then
				windower.chat.input('/ma "Banish II" '..target..'')
			elseif spell_recasts[28] < spell_latency and actual_cost(get_spell_table_by_name('Banish')) < player.mp then
				windower.chat.input('/ma "Banish" '..target..'')
			else
				add_to_chat(123,'Abort: Banishes on cooldown or not enough MP.')
			end

		elseif state.ElementalMode.value == 'Dark' then
			if spell_recasts[219] < spell_latency and actual_cost(get_spell_table_by_name('Comet')) < player.mp then
				windower.chat.input('/ma "Comet" '..target..'')
			else
				add_to_chat(123,'Abort: Comet on cooldown or not enough MP.')
			end

		else
			if player.job_points[(res.jobs[player.main_job_id].ens):lower()].jp_spent > 99 and spell_recasts[get_spell_table_by_name(data.elements.nuke_of[state.ElementalMode.value]..' V').id] < spell_latency and actual_cost(get_spell_table_by_name(data.elements.nuke_of[state.ElementalMode.value]..' V')) < player.mp then
				windower.chat.input('/ma "'..data.elements.nuke_of[state.ElementalMode.value]..' V" '..target..'')
			else
				local tiers = {' IV',' III',' II',''}
				for k in ipairs(tiers) do
					if spell_recasts[get_spell_table_by_name(data.elements.nuke_of[state.ElementalMode.value]..''..tiers[k]..'').id] < spell_latency and actual_cost(get_spell_table_by_name(data.elements.nuke_of[state.ElementalMode.value]..''..tiers[k]..'')) < player.mp then
						windower.chat.input('/ma "'..data.elements.nuke_of[state.ElementalMode.value]..''..tiers[k]..'" '..target..'')
						return
					end
				end
				add_to_chat(123,'Abort: All '..data.elements.nuke_of[state.ElementalMode.value]..' nukes on cooldown or or not enough MP.')
			end
		end

	elseif command == 'ninjutsu' then
		windower.chat.input('/ma "'..data.elements.ninjutsu_nuke_of[state.ElementalMode.value]..': Ni" '..target..'')
		
	elseif command == 'smallnuke' then
		local spell_recasts = windower.ffxi.get_spell_recasts()
	
		local tiers = {' II',''}
		for k in ipairs(tiers) do
			if spell_recasts[get_spell_table_by_name(data.elements.nuke_of[state.ElementalMode.value]..''..tiers[k]..'').id] < spell_latency and actual_cost(get_spell_table_by_name(data.elements.nuke_of[state.ElementalMode.value]..''..tiers[k]..'')) < player.mp then
				windower.chat.input('/ma "'..data.elements.nuke_of[state.ElementalMode.value]..''..tiers[k]..'" '..target..'')
				return
			end
		end
		add_to_chat(123,'Abort: All '..data.elements.nuke_of[state.ElementalMode.value]..' nukes on cooldown or or not enough MP.')
		
	elseif command:contains('tier') then
		local spell_recasts = windower.ffxi.get_spell_recasts()
		local tierlist = {['tier1']='',['tier2']=' II',['tier3']=' III',['tier4']=' IV',['tier5']=' V',['tier6']=' VI'}
		local tiernum  = {['tier1']=1,['tier2']=2,['tier3']=3,['tier4']=4,['tier5']=5,['tier6']=6}
		local requested = tiernum[command]
		if not requested then
			add_to_chat(123,'Abort: Unrecognized tier command "'..command..'".')
		elseif requested > MaxNukeTier then
			add_to_chat(123,'Abort: RDM is capped at Tier '..MaxNukeTier..' nukes -- Tier '..requested..' is not available.')
		else
			windower.chat.input('/ma "'..data.elements.nuke_of[state.ElementalMode.value]..tierlist[command]..'" '..target..'')
		end
		
	elseif command == 'ara' then
		windower.chat.input('/ma "'..data.elements.nukera_of[state.ElementalMode.value]..'ra" '..target..'')
		
	elseif command == 'aga' then
		local spell_recasts = windower.ffxi.get_spell_recasts()
		if state.ElementalMode.value == 'Wind' and spell_recasts[185] < spell_latency and actual_cost(get_spell_table_by_name('Aero II')) < player.mp then
			windower.chat.input('/ma "Aeroga II" '..target..'')
		elseif state.ElementalMode.value == 'Earth' and spell_recasts[190] < spell_latency and actual_cost(get_spell_table_by_name('Stonega II')) < player.mp then
			windower.chat.input('/ma "Stonega II" '..target..'')
		elseif state.ElementalMode.value == 'Water' and spell_recasts[200] < spell_latency and actual_cost(get_spell_table_by_name('Waterga II')) < player.mp then
			windower.chat.input('/ma "Waterga II" '..target..'')
		else
			windower.chat.input('/ma "'..data.elements.nukega_of[state.ElementalMode.value]..'ga" '..target..'')
		end
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

function job_tick()
	if check_low_mp() then return true end
	if check_arts() then return true end
	if check_buff() then return true end
	if check_buffup() then return true end
	return false
end
-- CONVERT + CURE IV CHAIN
function handle_convert(cmdParams)
	if player.hpp < 75 then
		windower.chat.input('/echo HP too low to safely convert')
		return false
	end

	local abil_recasts = windower.ffxi.get_ability_recasts()

	-- Convert ability recast ID 49 (confirmed via Windower/Resources job_abilities.lua).
	if abil_recasts[49] and abil_recasts[49] < latency and not buffactive['amnesia'] then
		windower.chat.input('/ja "Convert" <me>')
		windower.chat.input:schedule(2, '/ma "Cure IV" <me>')
		return true
	else
		add_to_chat(123,'Abort: Convert is on cooldown.')
		return false
	end
end
-- LOW MP AUTO-CONVERT:
function check_low_mp()
	if player.mp >= 200 then return false end
	if os.clock() <= low_mp_reminded_at then return false end

	low_mp_reminded_at = os.clock() + 30

	if handle_convert() then
		tickdelay = os.clock() + 2.5
		return true
	end

	return false
end
function check_arts()	
	if buffup ~= '' or (not data.areas.cities:contains(world.area) and ((state.AutoArts.value and player.in_combat) or state.AutoBuffMode.value ~= 'Off')) then

 		local abil_recasts = windower.ffxi.get_ability_recasts()	

 		if not buffactive.Composure then	
			local abil_recasts = windower.ffxi.get_ability_recasts()	
			if abil_recasts[50] < latency then	
				tickdelay = os.clock() + 1.1
				windower.chat.input('/ja "Composure" <me>')	
				return true	
			end	
		end	

 		if player.sub_job == 'SCH' and not arts_active() and abil_recasts[228] < latency then	
			send_command('@input /ja "Light Arts" <me>')	
			tickdelay = os.clock() + 1.1
			return true	
		end	

 	end	

 	return false	
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


function handle_smartcure(cmdParams)
		if cmdParams[2] then
			if tonumber(cmdParams[2]) then
				cureTarget = windower.ffxi.get_mob_by_id(tonumber(cmdParams[2]))
			else
				cureTarget = table.concat(cmdParams, ' ', 2)
				cureTarget = get_closest_mob_by_name(cureTarget) 
				if not cureTarget.name then cureTarget = player.target end
				if not cureTarget.name then cureTarget = player end
			end
		elseif player.target.type == "SELF" or player.target.type == 'MONSTER' or player.target.type == 'NONE' then
			cureTarget = player
		else
			cureTarget = player.target
		end

		if cureTarget.status == 2 or cureTarget.status == 3 then
			windower.chat.input('/ma "Raise II" '..cureTarget.id..'')
			return
		end
		
		local missingHP
		local spell_recasts = windower.ffxi.get_spell_recasts()
		if cureTarget.type == 'MONSTER' then
			handle_elemental({'elemental', 'nuke', tostring(cureTarget.id)})
			return
		elseif cureTarget.in_alliance then
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
		elseif missingHP < 400 then
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
			elseif spell_recasts[4] < spell_latency then
				windower.chat.input('/ma "Cure IV" '..cureTarget.id..'')
			else
				add_to_chat(123,'Abort: Appropriate cures are on cooldown.')
			end
		else
			if spell_recasts[4] < spell_latency then
				windower.chat.input('/ma "Cure IV" '..cureTarget.id..'')
			elseif spell_recasts[3] < spell_latency then
				windower.chat.input('/ma "Cure III" '..cureTarget.id..'')
			else
				add_to_chat(123,'Abort: Appropriate cures are on cooldown.')
			end
		end
	end

function update_melee_groups()
	classes.CustomMeleeGroups:clear()
	
	if enspell ~= '' then
		if enspell:endswith('II') then
			classes.CustomMeleeGroups:append('Enspell2')
		else
			classes.CustomMeleeGroups:append('Enspell')
		end
	end
	
	if player.equipment.main and player.equipment.main == "Murgleis" and state.Buff['Aftermath: Lv.3'] then
		classes.CustomMeleeGroups:append('AM')
	end	
end

buff_spell_lists = {
	Auto = {--Options for When are: Always, Engaged, Idle, OutOfCombat, Combat
		{Name='Refresh III',	Buff='Refresh',		SpellID=894,	When='Always'},
		{Name='Haste II',		Buff='Haste',		SpellID=511,	When='Always'},
		{Name='Aurorastorm',	Buff='Aurorastorm',	SpellID=119,	When='Idle'},
		{Name='Reraise',		Buff='Reraise',		SpellID=135,	When='Always'},
		{Name='Aquaveil',		Buff='Aquaveil',	SpellID=55,		When='OutOfCombat'},
	},
	
	AutoMelee = {
		{Name='Haste II',		Buff='Haste',		SpellID=511,	When='Engaged'},
		{Name='Temper II',		Buff='Multi Strikes',SpellID=895,	When='Engaged'},
	},
	
	Default = {
		{Name='Refresh III',	Buff='Refresh',		SpellID=894,	Reapply=true},
		{Name='Haste II',		Buff='Haste',		SpellID=511,	Reapply=true},
		{Name='Stoneskin',		Buff='Stoneskin',	SpellID=54,		Reapply=false},
	},

	MageBuff = {
		{Name='Refresh III',	Buff='Refresh',			SpellID=894,	Reapply=true},
		{Name='Haste II',		Buff='Haste',			SpellID=511,	Reapply=true},
		{Name='Aquaveil',		Buff='Aquaveil',		SpellID=55,		Reapply=true},
		{Name='Stoneskin',		Buff='Stoneskin',		SpellID=54,		Reapply=false},
		{Name='Blink',			Buff='Blink',			SpellID=53,		Reapply=false},
		{Name='Gain-INT',		Buff='INT Boost',		SpellID=490,	Reapply=false},
	},
	
	FullMeleeBuff = {
		{Name='Refresh III',	Buff='Refresh',			SpellID=894,	Reapply=false},
		{Name='Haste II',		Buff='Haste',			SpellID=511,	Reapply=true},
		{Name='Aquaveil',		Buff='Aquaveil',		SpellID=55,		Reapply=true},
		{Name='Stoneskin',		Buff='Stoneskin',		SpellID=54,		Reapply=false},
		{Name='Blink',			Buff='Blink',			SpellID=53,		Reapply=false},
		{Name='Gain-STR',		Buff='STR Boost',		SpellID=486,	Reapply=false},
		{Name='Temper II',		Buff='Multi Strikes',	SpellID=895,	Reapply=true},
	},
	
	MeleeBuff = {
		{Name='Refresh III',	Buff='Refresh',			SpellID=894,	Reapply=false},
		{Name='Haste II',		Buff='Haste',			SpellID=511,	Reapply=false},
		{Name='Temper II',		Buff='Multi Strikes',	SpellID=895,	Reapply=true},
		{Name='Gain-STR',		Buff='STR Boost',		SpellID=486,	Reapply=false},
	},
	
	HybridCleave = {
		{Name='Refresh III',	Buff='Refresh',			SpellID=894,	Reapply=true},
		{Name='Haste II',		Buff='Haste',			SpellID=511,	Reapply=true},
		{Name='Temper II',		Buff='Multi Strikes',	SpellID=895,	Reapply=true},
		{Name='Shell V',		Buff='Shell',			SpellID=52,		Reapply=false},
	},
}
-- =============================================================================
-- BLM.lua — Changelog
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Setup functions for this job.  Generally should not be modified.
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Initialization function for this job.
function get_sets()
    -- Load and initialize the include file.
    include('Sel-Include.lua')
end

function job_setup()

	state.Buff['Mana Wall'] = buffactive['Mana Wall'] or false
	state.Buff['Manafont'] = buffactive['Manafont'] or false
	state.Buff['Manawell'] = buffactive['Manawell'] or false

    LowTierNukes = S{'Stone', 'Water', 'Aero', 'Fire', 'Blizzard', 'Thunder',
        'Stone II', 'Water II', 'Aero II', 'Fire II', 'Blizzard II', 'Thunder II',
        'Stonega', 'Waterga', 'Aeroga', 'Firaga', 'Blizzaga', 'Thundaga'}

    -- [ADDED 2026-08-14] Hard cap on nuke tier this job can cast, used by handle_elemental's
    -- explicit 'tierN' command (gs c elemental tier6, etc.) to refuse anything above what the
    -- job has access to instead of firing a nonexistent spell. BLM actually has Tier VI, so
    -- this mainly guards against typos (tier7, etc.) rather than a real cap. See RDM.lua/
    -- SCH.lua/GEO.lua for the Tier V version of this same guard.
    MaxNukeTier = 6
		
    AutoManawellSpells = S{'Impact'}
	AutoManawellOccultSpells = S{'Impact','Meteor','Thundaja','Blizzaja','Firaja','Thunder VI','Blizzard VI',}

	state.DeathMode = M{['description'] = 'Death Mode', 'Off', 'Single', 'Lock'}
	state.AutoManawell = M(true, 'Auto Manawell Mode')
	-- [FIX 2026-07-25]: state.RecoverMode retired -- MP recovery is now handled globally via
	-- try_recover_mp() (Ullona-Globals.lua), fixed at 75% MP with no modal to cycle.

	autows = 'Vidohunir'
	autofood = 'Pear Crepe'
	
	init_job_states({"Capacity","AutoRuneMode","AutoTrustMode","AutoNukeMode","AutoManawell","AutoWSMode","AutoShadowMode","AutoFoodMode","AutoStunMode","AutoDefenseMode"},{"AutoBuffMode","Weapons","OffenseMode","WeaponskillMode","IdleMode","Passive","RuneElement","ElementalMode","CastingMode","TreasureMode",})
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------
-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.

function job_filtered_action(spell, eventArgs)

end

function job_pretarget(spell, spellMap, eventArgs)
	if spell.action_type == 'Magic' then
		if state.AutoManawell.value and (AutoManawellSpells:contains(spell.english) or (state.CastingMode.value == 'OccultAcumen' and AutoManawellOccultSpells:contains(spell.english) and actual_cost(spell) > player.mp)) then
			local abil_recasts = windower.ffxi.get_ability_recasts()

			if abil_recasts[35] < latency and not buffactive['amnesia'] then
				eventArgs.cancel = true
				cancel_spell()
				send_command('@input /ja "Manawell" <me>;wait 1;input /ma '..spell.english..' '..spell.target.raw..'')
				return
			end
		end
	end
end

function job_precast(spell, spellMap, eventArgs)
	-- [ADDED 2026-08-09] Amnesia -> Ecphoria Ring: swaps ring2 to Ecphoria Ring the moment
	-- a job ability is attempted while Amnesia is up (see check_ecphoria_for_ja() in
	-- Ullona-Globals.lua for the actual logic -- this is just the required per-job wiring).
	-- Placed OUTSIDE the action_type=='Magic' block below since job abilities aren't Magic.
	check_ecphoria_for_ja(spell)

	if spell.action_type == 'Magic' then
		
        if state.CastingMode.value == 'Proc' then
            classes.CustomClass = 'Proc'
        elseif state.CastingMode.value == 'OccultAcumen' then
            classes.CustomClass = 'OccultAcumen'
        end
        if state.DeathMode.value ~= 'Off' then
            classes.CustomClass = 'Death'
        end
	end
end

function job_post_precast(spell, spellMap, eventArgs)

	if spell.action_type == 'Magic' and state.DeathMode.value ~= 'Off' then
		equip(sets.precast.FC.Death)
	elseif spell.type == 'WeaponSkill' then
		local WSset = standardize_set(get_precast_set(spell, spellMap))
		
		if (WSset.ear1 == "Moonshade Earring" or WSset.ear2 == "Moonshade Earring") then
			-- Replace Moonshade Earring if we're at cap TP
			if sets.MaxTP and get_effective_player_tp(spell, WSset) > 3200 then
				equip(sets.MaxTP[spell.english] or sets.MaxTP)
			end
		end
	end
	
	if state.Buff['Mana Wall'] and (state.IdleMode.value:contains('DT') or state.DefenseMode.value ~= 'None') then
		equip(sets.buff['Mana Wall'])
	end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_midcast(spell, action, spellMap, eventArgs)

end

function job_post_midcast(spell, spellMap, eventArgs)
	if spell.action_type == 'Magic' then
		if state.DeathMode.value ~= 'Off' and spell.english ~= 'Death' then
			if sets.midcast[spell.english] and sets.midcast[spell.english].Death then
				equip(sets.midcast[spell.english].Death)
			elseif sets.midcast[spellMap] and sets.midcast[spellMap].Death then
				equip(sets.midcast[spellMap].Death)
			elseif sets.midcast[spell.skill] and sets.midcast[spell.skill].Death then
				equip(sets.midcast[spell.skill].Death)
			else
				equip(sets.precast.FC.Death)
			end

		elseif is_nuke(spell, spellMap) and spell.english ~= 'Impact' then
			try_magic_burst()

			if player.hpp < 75 and player.tp < 1000 and state.CastingMode.value == 'Fodder' then
				if item_available("Sorcerer's Ring") then
					sets.SorcRing = {ring1="Sorcerer's Ring"}
					equip(sets.SorcRing)
				end
			end
			
			if spell.element == world.weather_element or spell.element == world.day_element then
				if state.CastingMode.value == 'Fodder' or state.CastingMode.value == 'Normal' then
					-- if item_available('Twilight Cape') and not LowTierNukes:contains(spell.english) and not state.Capacity.value then
						-- sets.TwilightCape = {back="Twilight Cape"}
						-- equip(sets.TwilightCape)
					-- end
					if spell.element == world.day_element then
						if item_available('Zodiac Ring') then
							sets.ZodiacRing = {ring2="Zodiac Ring"}
							equip(sets.ZodiacRing)
						end
					end
				end
			end
			
			if spell.element and sets.element[spell.element] then
				equip(sets.element[spell.element])
			end
			try_recover_mp()
		end
		
		if state.Buff['Mana Wall'] and (state.IdleMode.value:contains('DT') or state.DefenseMode.value ~= 'None') then
			equip(sets.buff['Mana Wall'])
		end
	end
end

function job_aftercast(spell, spellMap, eventArgs)
    -- Lock feet after using Mana Wall.
    if not spell.interrupted then
        if spell.english == 'Sleep' or spell.english == 'Sleepga' then
            send_command('@timers c "'..spell.english..' ['..spell.target.name..']" 60 down spells/00220.png')
        elseif spell.english == 'Sleep II' or spell.english == 'Sleepga II' then
            send_command('@timers c "'..spell.english..' ['..spell.target.name..']" 90 down spells/00220.png')
		elseif spell.english == "Death" and state.DeathMode.value == 'Single' then
			state.DeathMode:reset()
			if state.DisplayMode.value then update_job_states()	end
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
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

-- Custom spell mapping.
function job_get_spell_map(spell,default_spell_map)
    if default_spell_map == 'Cure' or default_spell_map == 'Curaga' then
        if world.weather_element == 'Light' then
            return 'LightWeatherCure'
        elseif world.day_element == 'Light' then
            return 'LightDayCure'
        end

    elseif spell.skill == 'Elemental Magic' then
        if default_spell_map == 'ElementalEnfeeble' or spell.english:contains('helix') then
            return
        elseif LowTierNukes:contains(spell.english) then
            return 'LowTierNuke'
        else
            return 'HighTierNuke'
        end

    elseif spell.skill == "Enfeebling Magic" then
        if spell.english:startswith('Dia') then
            return "Dia"
        elseif spell.type == "WhiteMagic" or spell.english:startswith('Frazzle') or spell.english:startswith('Distract') then
            return 'MndEnfeebles'
        else
            return 'IntEnfeebles'
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
	
	if state.DeathMode.value ~= 'Off' then
        idleSet = set_combine(idleSet, sets.idle.Death)
    end
	
    if state.Buff['Mana Wall'] then
		idleSet = set_combine(idleSet, sets.buff['Mana Wall'])
    end
    
    return idleSet
end

-- Modify the default melee set after it was constructed.
function job_customize_melee_set(meleeSet)

    if state.Buff['Mana Wall'] then
		meleeSet = set_combine(meleeSet, sets.buff['Mana Wall'])
    end

    return meleeSet
end

-- Function to display the current relevant user state when doing an update.
function display_current_job_state(eventArgs)
    display_current_caster_state()
    eventArgs.handled = true
end

function job_self_command(commandArgs, eventArgs)
		if commandArgs[1]:lower() == 'elemental' then
			handle_elemental(commandArgs)
			eventArgs.handled = true			
		elseif commandArgs[1]:lower() == 'smartcure' then
			handle_smartcure(commandArgs)
			eventArgs.handled = true
		end
end

function job_tick()
	if check_arts() then return true end
	if check_buff() then return true end
	if check_buffup() then return true end
	return false
end

function check_arts()
	if (player.sub_job == 'SCH' and not arts_active()) and (buffup ~= '' or (not data.areas.cities:contains(world.area) and ((state.AutoArts.value and player.in_combat) or state.AutoBuffMode.value ~= 'Off'))) then
	
		local abil_recasts = windower.ffxi.get_ability_recasts()

		if abil_recasts[232] < latency then
			windower.chat.input('/ja "Dark Arts" <me>')
			tickdelay = os.clock() + 1
			return true
		end

	end
	
	return false
end

-- Handling Elemental spells within Gearswap.
-- Format: gs c elemental <nuke, helix, skillchain1, skillchain2, weather>
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
			if player.job_points[(res.jobs[player.main_job_id].ens):lower()].jp_spent > 99 and spell_recasts[get_spell_table_by_name(data.elements.nuke_of[state.ElementalMode.value]..' VI').id] < spell_latency and actual_cost(get_spell_table_by_name(data.elements.nuke_of[state.ElementalMode.value]..' VI')) < player.mp then
				windower.chat.input('/ma "'..data.elements.nuke_of[state.ElementalMode.value]..' VI" '..target..'')
			else
				local tiers = {' V',' IV',' III',' II',''}
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
			add_to_chat(123,'Abort: BLM is capped at Tier '..MaxNukeTier..' nukes -- Tier '..requested..' is not available.')
		else
			windower.chat.input('/ma "'..data.elements.nuke_of[state.ElementalMode.value]..tierlist[command]..'" '..target..'')
		end
		
	elseif command:contains('aga') or command == 'aja' then
		local spell_recasts = windower.ffxi.get_spell_recasts()
		local tierkey = {'aja','aga3','aga2','aga1'}
		local tierlist = {['aja']='ja',['aga3']='ga III',['aga2']='ga II',['aga1']='ga',}
		if command == 'aga' then
			for i in ipairs(tierkey) do
				if spell_recasts[get_spell_table_by_name(data.elements.nukega_of[state.ElementalMode.value]..''..tierlist[tierkey[i]]..'').id] < spell_latency and actual_cost(get_spell_table_by_name(data.elements.nukega_of[state.ElementalMode.value]..''..tierlist[tierkey[i]]..'')) < player.mp then
					windower.chat.input('/ma "'..data.elements.nukega_of[state.ElementalMode.value]..''..tierlist[tierkey[i]]..'" '..target..'')
					return
				end
			end
		else
			windower.chat.input('/ma "'..data.elements.nukega_of[state.ElementalMode.value]..tierlist[command]..'" '..target..'')
		end
	elseif command == 'ara' then
		windower.chat.input('/ma "'..data.elements.nukera_of[state.ElementalMode.value]..'ra" '..target..'')
	elseif command == 'helix' then
		windower.chat.input('/ma "'..data.elements.helix_of[state.ElementalMode.value]..'helix" '..target..'')
	elseif command == 'ancientmagic' then
		windower.chat.input('/ma "'..data.elements.ancient_nuke_of[state.ElementalMode.value]..'" '..target..'')
	elseif command == 'ancientmagic2' then
		windower.chat.input('/ma "'..data.elements.ancient_nuke_of[state.ElementalMode.value]..' II" '..target..'')
	elseif command == 'enfeeble' then
		windower.chat.input('/ma "'..data.elements.elemental_enfeeble_of[state.ElementalMode.value]..'" '..target..'')
	elseif command == 'bardsong' then
		windower.chat.input('/ma "'..data.elements.threnody_of[state.ElementalMode.value]..' Threnody" '..target..'')
	else
        add_to_chat(123,'Unrecognized elemental command.')
    end
end
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
		-- Reaches for III first, IV as an upgrade if it's unlocked (ML30+) and off cooldown.
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
		-- Biggest HP gap: reach for IV first if unlocked, otherwise III is still the ceiling.
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
function check_buff()
	if state.AutoBuffMode.value ~= 'Off' and not data.areas.cities:contains(world.area) then
		local spell_recasts = windower.ffxi.get_spell_recasts()
		-- [FIX 5]: .Value → .value throughout — capital V returns nil in Sel's framework, silently killing the tick loop
		for i in pairs(buff_spell_lists[state.AutoBuffMode.value]) do
			if not buffactive[buff_spell_lists[state.AutoBuffMode.value][i].Buff] and (buff_spell_lists[state.AutoBuffMode.value][i].When == 'Always' or (buff_spell_lists[state.AutoBuffMode.value][i].When == 'Combat' and (player.in_combat or being_attacked)) or (buff_spell_lists[state.AutoBuffMode.value][i].When == 'Engaged' and player.status == 'Engaged') or (buff_spell_lists[state.AutoBuffMode.value][i].When == 'Idle' and player.status == 'Idle') or (buff_spell_lists[state.AutoBuffMode.value][i].When == 'OutOfCombat' and not (player.in_combat or being_attacked))) and spell_recasts[buff_spell_lists[state.AutoBuffMode.value][i].SpellID] < spell_latency and silent_can_use(buff_spell_lists[state.AutoBuffMode.value][i].SpellID) then
				windower.chat.input('/ma "'..buff_spell_lists[state.AutoBuffMode.value][i].Name..'" <me>')
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
		{Name='Reraise',		Buff='Reraise',			SpellID=113,	When= 'OutOfCombat'},
		{Name='Stoneskin',		Buff='Stoneskin',		SpellID=54,		When='Always'},
		{Name='Klimaform',		Buff='Klimaform',		SpellID=287,	When='Always'},
		{Name='Aquaveil',		Buff='Aquaveil',	SpellID=55,		When= 'OutOfCombat'}
	},
	
	Default = {
		{Name='Reraise',		Buff='Reraise',			SpellID=113,	Reapply=true},
		{Name='Haste',			Buff='Haste',			SpellID=57,		Reapply=false},
		{Name='Aquaveil',		Buff='Aquaveil',		SpellID=55,		Reapply=true},
		{Name='Stoneskin',		Buff='Stoneskin',		SpellID=54,		Reapply=false},
		{Name='Klimaform',		Buff='Klimaform',		SpellID=287,	Reapply=true},
	},
}
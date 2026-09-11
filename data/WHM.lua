-- =============================================================================
-- WHM.lua — Changelog
--11/9/2026: added display for what barspells are on what button for elemental wheel. 
-- =============================================================================

-- Initialization function for this job file.
function get_sets()    
    -- Load and initialize the include file.
    include('Sel-Include.lua')
    include('Smart-Caster.lua')
end

function job_setup()

    state.Buff['Afflatus Solace'] = buffactive['Afflatus Solace'] or false
    state.Buff['Afflatus Misery'] = buffactive['Afflatus Misery'] or false
	state.Buff['Divine Caress'] = buffactive['Divine Caress'] or false
	
	state.AutoCaress = M(false, 'Auto Caress Mode')
	state.Gambanteinn = M(false, 'Gambanteinn Cursna Mode')
	state.BlockLowDevotion = M(true, 'Block Low Devotion')
	
	autows = 'Mystic Boon'
	autofood = 'Miso Ramen'
	
	state.ElementalMode = M{['description'] = 'Elemental Mode','Light','Dark','Fire','Ice','Wind','Earth','Lightning','Water',}


	init_job_states({"Capacity","AutoRuneMode","AutoTrustMode","AutoNukeMode","AutoWSMode","AutoShadowMode","AutoFoodMode","AutoStunMode","AutoDefenseMode"},{"AutoBuffMode","Weapons","OffenseMode","WeaponskillMode","IdleMode","Passive","RuneElement","ElementalMode","CastingMode","TreasureMode",})
	
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
			windower.chat.input('/ma "Arise" '..cureTarget.id..'')
			return
		end

		if cureTarget.type ~= 'MONSTER' and not state.Buff['Afflatus Solace'] then
			local abil_recasts = windower.ffxi.get_ability_recasts()
			if abil_recasts[29] < latency then
				windower.chat.input('/ja "Afflatus Solace" <me>')
				send_command('wait 1; gs c '..table.concat(cmdParams, ' '))
				return
			end
		end
		
		local missingHP
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
			elseif spell_recasts[5] < spell_latency then
				windower.chat.input('/ma "Cure V" '..cureTarget.id..'')
			else
				add_to_chat(123,'Abort: Appropriate cures are on cooldown.')
			end
		elseif missingHP < 1400 then
			if spell_recasts[5] < spell_latency then
				windower.chat.input('/ma "Cure V" '..cureTarget.id..'')
			elseif spell_recasts[4] < spell_latency then
				windower.chat.input('/ma "Cure IV" '..cureTarget.id..'')
			elseif spell_recasts[6] < spell_latency then
				windower.chat.input('/ma "Cure VI" '..cureTarget.id..'')
			elseif spell_recasts[3] < spell_latency then
				windower.chat.input('/ma "Cure III" '..cureTarget.id..'')
			else
				add_to_chat(123,'Abort: Appropriate cures are on cooldown.')
			end
		else
			if spell_recasts[6] < spell_latency then
				windower.chat.input('/ma "Cure VI" '..cureTarget.id..'')
			elseif spell_recasts[5] < spell_latency then
				windower.chat.input('/ma "Cure V" '..cureTarget.id..'')
			elseif spell_recasts[4] < spell_latency then
				windower.chat.input('/ma "Cure IV" '..cureTarget.id..'')
			elseif spell_recasts[3] < spell_latency then
				windower.chat.input('/ma "Cure III" '..cureTarget.id..'')
			else
				add_to_chat(123,'Abort: Appropriate cures are on cooldown.')
			end
		end
	end
end


function job_filtered_action(spell, eventArgs)

end

function job_pretarget(spell, spellMap, eventArgs)

end

function job_precast(spell, spellMap, eventArgs)
	check_ecphoria_for_ja(spell)

	if spell.action_type == 'Magic' then

		if spellMap == 'Cure' or spellMap == 'Curaga' then
			gear.default.obi_waist = gear.obi_cure_waist
			gear.default.obi_back = gear.obi_cure_back
		elseif spell.english == 'Holy II' then
			gear.default.obi_waist = gear.obi_high_nuke_waist
		elseif spell.english == 'Holy' or (spell.skill == 'Elemental Magic' and default_spell_map ~= 'ElementalEnfeeble') then
			gear.default.obi_waist = gear.obi_nuke_waist
			gear.default.obi_back = gear.obi_nuke_back
		elseif spellMap == 'StatusRemoval' and not (spell.english == "Erase" or spell.english == "Esuna" or spell.english == "Sacrifice") then
			local abil_recasts = windower.ffxi.get_ability_recasts()
			if abil_recasts[32] < latency and not silent_check_amnesia() and state.AutoCaress.value then
				eventArgs.cancel = true
				windower.chat.input('/ja "Divine Caress" <me>')
				windower.chat.input:schedule(1,'/ma "'..spell.english..'" '..spell.target.raw..'')
				return
			end
		end
		smart_caster_precast(spell, spellMap, eventArgs)
	elseif spell.type == 'JobAbility' then
		local abil_recasts = windower.ffxi.get_ability_recasts()
		if spell.english == 'Devotion' and state.BlockLowDevotion.value and abil_recasts[28] < latency and player.hpp < 50 then
			eventArgs.cancel = true
			add_to_chat(123,'Abort: Blocking Devotion under 50% HP to prevent inefficient use.')
		end
	end
		
        if state.CastingMode.value == 'Proc' then
            classes.CustomClass = 'Proc'
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

function job_post_midcast(spell, spellMap, eventArgs)
    -- Apply Divine Caress boosting items as highest priority over other gear, if applicable.
    if spellMap == 'StatusRemoval' then
		if state.Buff['Divine Caress'] then
			equip(sets.buff['Divine Caress'])
		end
		if spell.english == 'Cursna' then
			if (player.sub_job == 'NIN' or player.sub_job == 'DNC') and sets.midcast.DWCursna then
				equip(sets.midcast.DWCursna)
			elseif state.Gambanteinn.value and item_available('Gambanteinn') then
				equip({main="Gambanteinn"})
			end
		end
		
	elseif spellMap == 'BarElement' then
		if (state.Buff['Light Arts'] or state.Buff['Addendum: White']) and sets.midcast.BarElement and sets.midcast.BarElement.LightArts then
			equip(sets.midcast.BarElement.LightArts)
		end
    elseif spell.skill == 'Elemental Magic' and default_spell_map ~= 'ElementalEnfeeble' and spell.english ~= 'Impact' then
        if state.MagicBurstMode.value ~= 'Off' then equip(sets.MagicBurst) end
		if spell.element == world.weather_element or spell.element == world.day_element then
			if state.CastingMode.value == 'Fodder' or state.CastingMode.value == 'Normal' then
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
	
end

function job_aftercast(spell, spellMap, eventArgs)
    if not spell.interrupted then
        if state.UseCustomTimers.value and spell.english == 'Sleep' or spell.english == 'Sleepga' then
            send_command('@timers c "'..spell.english..' ['..spell.target.name..']" 60 down spells/00220.png')
        elseif spell.skill == 'Elemental Magic' and state.MagicBurstMode.value == 'Single' then
            state.MagicBurstMode:reset()
			if state.DisplayMode.value then update_job_states()	end
        end
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for non-casting events.
-------------------------------------------------------------------------------------------------------------------

-- Custom spell mapping.
function job_get_spell_map(spell, default_spell_map)
    if spell.action_type == 'Magic' then
		if default_spell_map == 'Curaga' then
			if world.weather_element == 'Light' then
				return 'LightWeatherCuraga'
			elseif world.day_element == 'Light' then
				return 'LightDayCuraga'	
			end
		elseif default_spell_map == 'Cure' then
			if state.Weapons.value ~= 'None' then
				if state.Buff['Afflatus Solace'] then
					if world.weather_element == 'Light' then
						return '"MeleeLightWeatherCureSolace'
					elseif world.day_element == 'Light' then
						return 'MeleeLightDayCureSolace'
					else
						return "MeleeCureSolace"
					end
				elseif world.weather_element == 'Light' then
					return 'MeleeLightWeatherCure'
				elseif world.day_element == 'Light' then
					return 'MeleeLightDayCure'
				else
					return 'MeleeCure'
				end
			elseif state.Buff['Afflatus Solace'] then
				if world.weather_element == 'Light' then
					return 'LightWeatherCureSolace'
				elseif world.day_element == 'Light' then
					return 'LightDayCureSolace'
				else
					return "CureSolace"
				end
			elseif world.weather_element == 'Light' then
                return 'LightWeatherCure'
			elseif world.day_element == 'Light' then
                return 'LightDayCure'
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
end


function job_customize_idle_set(idleSet)
    if buffactive['Sublimation: Activated'] then
        if (state.IdleMode.value == 'Normal' or state.IdleMode.value:contains('Sphere')) and sets.buff.Sublimation then
            idleSet = set_combine(idleSet, sets.buff.Sublimation)
        elseif state.IdleMode.value:contains('DT') and sets.buff.DTSublimation then
            idleSet = set_combine(idleSet, sets.buff.DTSublimation)
        end
    end

    if state.IdleMode.value == 'Normal' or state.IdleMode.value:contains('Sphere') then
		if player.mpp < 80 then
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

-- Called by the 'update' self-command.
function job_update(cmdParams, eventArgs)
	if cmdParams[1] == 'user' then check_arts() end
end


-- Function to display the current relevant user state when doing an update.
function display_current_job_state(eventArgs)
    display_current_caster_state()
    eventArgs.handled = true
end

    -- Allow jobs to override this code
function job_self_command(commandArgs, eventArgs)
	if commandArgs[1]:lower() == 'smartcure' then
		handle_smartcure(commandArgs)
		eventArgs.handled = true
	elseif commandArgs[1]:lower() == 'smartcuraga' then
		handle_smartcuraga(commandArgs)
		eventArgs.handled = true
	elseif commandArgs[1]:lower() == 'smartcura' then
		handle_smartcura(commandArgs)
		eventArgs.handled = true
	elseif commandArgs[1]:lower() == 'elemental' then
		handle_elemental(commandArgs)
		eventArgs.handled = true
	elseif commandArgs[1]:lower() == 'barelement' then
		handle_barelement(commandArgs)
		eventArgs.handled = true
	elseif commandArgs[1]:lower() == 'barstatus' then
		handle_barstatus(commandArgs)
		eventArgs.handled = true
	elseif commandArgs[1]:lower() == 'smartregen' then
		handle_smartregen(commandArgs)
		eventArgs.handled = true
	elseif commandArgs[1]:lower() == 'whm' and commandArgs[2] and commandArgs[2]:lower() == 'nuke' then
		handle_holynuke(commandArgs)
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
	if buffup ~= '' or (not data.areas.cities:contains(world.area) and ((state.AutoArts.value and player.in_combat) or state.AutoBuffMode.value ~= 'Off')) then
		local abil_recasts = windower.ffxi.get_ability_recasts()

		if abil_recasts[29] < latency and not state.Buff['Afflatus Solace'] and not state.Buff['Afflatus Misery'] then
			send_command('@input /ja "Afflatus Solace" <me>')
			tickdelay = os.clock() + 1
			return true

		elseif player.sub_job == 'SCH' and not arts_active() and abil_recasts[228] < latency then
			send_command('@input /ja "Light Arts" <me>')
			tickdelay = os.clock() + 1
			return true
		end
		
	end

	return false
end

-- Bar-element wheel handler: gs c barelement. Always casts the AoE (-ra) tier, matching
-- the elemental resistance shield to whatever element the shared ElementalMode wheel is
-- currently set to (Ctrl+` to cycle). WHM never nukes, so there's no conflict reusing the
-- same wheel that would otherwise sit unused -- no need for a separate BarElementMode.
--
-- Deliberately NOT weather/day-aware: Bar-spells defend against an enemy's attack element,
-- not the ambient weather element -- casting off the weather would bar the wrong thing
-- entirely on, say, a Fire-day fight against a Wind-based bug. The wheel is the single
-- source of truth here; set it to whatever the current target actually needs.
--
-- ElementalMode includes Light and Dark (needed elsewhere for Banish/Comet). There's no true
-- Barlight or Bardark spell in the game, but Light/Dark are mapped here to a couple of
-- frequently-used Bar-status spells instead, purely for convenience -- Barparalyzra for Light,
-- Barpoisonra for Dark (both confirmed real WHM spells, not elemental Bar-spells; this is a
-- personal shortcut riding the same wheel/keybind, not a genuine Light/Dark Bar-element).
local bar_element_spells = {
	Fire      = 'Barfira',
	Ice       = 'Barblizzara',
	Wind      = 'Baraera',
	Earth     = 'Barstonra',
	Lightning = 'Barthundra',
	Water     = 'Barwatera',
	Light     = 'Barparalyzra',
	Dark      = 'Barsleepra', -- was Barpoisonra -- moved to make room for the Alt+A double-dip below [REVISED 2026-08-30]
}

function handle_barelement(cmdParams)
	local spell_name = bar_element_spells[state.ElementalMode.value]
	if not spell_name then
		add_to_chat(123,'Abort: No bar-spell mapped for '..tostring(state.ElementalMode.value)..'.')
		return
	end
	windower.chat.input('/ma "'..spell_name..'" <me>')
end

-- Bar-status handler: gs c barstatus (Alt+A). Reads the SAME ElementalMode wheel Ctrl+A
-- uses. Entries carry a 'type' field ('magic'/'ja') for flexibility, though every entry
-- currently in use is 'magic' -- Fire's Auspice was briefly (and incorrectly) flagged as a
-- JA; it's actually a White Magic spell too. Kept the type field in case a JA ever ends up
-- on this wheel later.
-- [REVISED 2026-08-30]: Dark and Water now both point at Barpoisonra -- a deliberate
-- double-dip, since Poison is common enough to want reachable from two wheel positions
-- without a full cycle. Barsleepra moved off Alt+A/Dark to Ctrl+A/Dark (see
-- bar_element_spells above) to make room. Fire's slot filled with Auspice (White Magic
-- spell, WHM Lv.55, reduces TP dealt to enemies + accuracy bonus on party members who get
-- missed within AoE) rather than a status spell, since Fire had nothing status-side to
-- place.
local bar_status_spells = {
	Fire      = {name = 'Auspice',      type = 'magic'}, -- Auspice -- WHM Lv.55 White Magic spell, not a JA -- Fire had no status spell to place
	Ice       = {name = 'Barvira',      type = 'magic'},  -- Virus -- icon is blue like ice
	Wind      = {name = 'Barsilencera', type = 'magic'},  -- Silence -- silence is wind-element based
	Earth     = {name = 'Barpetra',     type = 'magic'},  -- Petrify -- turns you to stone
	Lightning = {name = 'Baramnesra',   type = 'magic'},  -- Amnesia -- imps (first source) hit purple
	Water     = {name = 'Barpoisonra',  type = 'magic'},  -- Poison -- double-dip #1, reachable without scrolling to Dark
	Dark      = {name = 'Barpoisonra',  type = 'magic'},  -- Poison -- double-dip #2, same spell as Water above
	Light     = {name = 'Barblindra',   type = 'magic'},  -- Blind -- need light to see
}

-- Display-only helper: cycling the ElementalMode wheel (Ctrl+`) normally just echoes the
-- raw element name (e.g. "Elemental Mode: Dark"), which tells you nothing about what's
-- actually bound to it on this wheel. This reminds you which bar-element/bar-status spells
-- you're pointing at, "Bar" stripped, built straight from bar_element_spells / bar_status_spells
-- above so it can't drift out of sync with the real bindings.
-- Mote-Include calls job_state_change(stateField, new_value, old_value) automatically any
-- time a state changes -- this only reacts to the Elemental Mode field, every other state
-- (Weapons, CastingMode, etc.) is untouched.
function job_state_change(stateField, new_value, old_value)
    if stateField == 'Elemental Mode' then
        local elem_spell = bar_element_spells[new_value]
        local status_entry = bar_status_spells[new_value]
        local elem_name = elem_spell and elem_spell:gsub('^Bar', '') or '?'
        local status_name = status_entry and status_entry.name:gsub('^Bar', '') or '?'
        add_to_chat(160, 'Elemental Mode: '..new_value..'  ['..elem_name..' / '..status_name..']')
    end
end

function handle_barstatus(cmdParams)
	local entry = bar_status_spells[state.ElementalMode.value]
	if not entry then
		add_to_chat(123,'Abort: No status bar-spell mapped for '..tostring(state.ElementalMode.value)..'.')
		return
	end
	if entry.type == 'ja' then
		windower.chat.input('/ja "'..entry.name..'" <me>')
	else
		windower.chat.input('/ma "'..entry.name..'" <me>')
	end
end

-- Regen tier-down cascade: gs c smartregen [target]. No target -> <t> (current target).
-- Always tries the strongest tier first (Regen IV, WHM's ceiling -- no Regen V exists in the
-- game), stepping down through III/II/I on cooldown/not-yet-unlocked, same silent_can_use +
-- spell_recasts pairing already used by handle_smartcuraga/handle_holynuke. Added because
-- macro-mashing Regen IV directly just echoes "on cooldown" and does nothing once it's not
-- up -- this actually lands something.
function handle_smartregen(cmdParams)
	local target = '<t>'
	if cmdParams[2] then
		if tonumber(cmdParams[2]) then
			target = tonumber(cmdParams[2])
		else
			target = table.concat(cmdParams, ' ', 2)
			target = get_closest_mob_id_by_name(target) or '<t>'
		end
	end

	local spell_recasts = windower.ffxi.get_spell_recasts()
	local tiers = {'Regen IV','Regen III','Regen II','Regen'}
	for _, name in ipairs(tiers) do
		local spell = get_spell_table_by_name(name)
		if spell and silent_can_use(spell.id) and spell_recasts[spell.id] < spell_latency then
			windower.chat.input('/ma "'..name..'" '..target..'')
			return
		end
	end
	add_to_chat(123,'Abort: All Regen tiers on cooldown.')
end

-- Dedicated Holy/Banish tier-down nuke, completely independent of state.ElementalMode.
-- WHM's only nuke line is Light (Holy/Banish) -- the ElementalMode wheel now also drives
-- bar-spells (set to whatever element the enemy uses), so gs c elemental nuke breaks the
-- moment that wheel isn't sitting on Light. This bypasses the wheel entirely and always
-- steps down through the same Holy II -> Holy -> Banish III -> Banish II -> Banish cascade,
-- checking both recast and MP affordability at each tier, same logic as before -- just no
-- longer gated behind what the wheel happens to be set to.
function handle_holynuke(cmdParams)
	-- cmdParams[1] == 'whm', cmdParams[2] == 'nuke'
	-- cmdParams[3] (optional) == mob ID or name to target, same rules as handle_elemental

	local target = '<t>'
	if cmdParams[3] then
		if tonumber(cmdParams[3]) then
			target = tonumber(cmdParams[3])
		else
			target = table.concat(cmdParams, ' ', 3)
			target = get_closest_mob_id_by_name(target) or '<t>'
		end
	end

	local spell_recasts = windower.ffxi.get_spell_recasts()
	local tiers = {'Holy II','Holy','Banish III','Banish II','Banish'}
	for k in ipairs(tiers) do
		if spell_recasts[get_spell_table_by_name(tiers[k]).id] < spell_latency and actual_cost(get_spell_table_by_name(tiers[k])) < player.mp then
			windower.chat.input('/ma "'..tiers[k]..'" '..target..'')
			return
		end
	end
	add_to_chat(123,'Abort: All Holy/Banish nukes on cooldown or not enough MP.')
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
	
		if command == 'nuke' and state.ElementalMode.value == 'Light' then
			local tiers = {'Holy II','Holy','Banish III','Banish II','Banish'}
			for k in ipairs(tiers) do
				if spell_recasts[get_spell_table_by_name(tiers[k]).id] < spell_latency and actual_cost(get_spell_table_by_name(tiers[k])) < player.mp then
					windower.chat.input('/ma "'..tiers[k]..'" '..target..'')
					return
				end
			end
		else
			local tiers = {' II',''}
			for k in ipairs(tiers) do
				if spell_recasts[get_spell_table_by_name(data.elements.nuke_of[state.ElementalMode.value]..''..tiers[k]..'').id] < spell_latency and actual_cost(get_spell_table_by_name(data.elements.nuke_of[state.ElementalMode.value]..''..tiers[k]..'')) < player.mp then
					windower.chat.input('/ma "'..data.elements.nuke_of[state.ElementalMode.value]..''..tiers[k]..'" '..target..'')
					return
				end
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

-- Smart AoE cure: picks a Curaga tier based on the missing HP of whoever you have targeted,
-- then casts it centered on you. Thresholds are biased LOW on purpose -- it would rather
-- overheal the group with a stronger tier than risk your target dying on a weaker one.
function handle_smartcuraga(cmdParams)
	-- cmdParams[1] == 'smartcuraga'
	-- cmdParams[2] (optional) == mob ID or name to base the heal off of, same rules as smartcure

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
	elseif player.target and (player.target.type == 'SELF' or player.target.type == 'MONSTER' or player.target.type == 'NONE') then
		cureTarget = player
	elseif player.target then
		cureTarget = player.target
	else
		cureTarget = player
	end

	-- If the targeted ally is dead, raise them instead of curing -- Curaga does nothing for a ghost.
	if cureTarget.status == 2 or cureTarget.status == 3 then
		windower.chat.input('/ma "Arise" '..cureTarget.id..'')
		return
	end

	-- Estimate missing HP off the targeted person, same logic as smartcure.
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

	local spell_recasts = windower.ffxi.get_spell_recasts()

	-- Tier order to attempt, strongest-appropriate first, falling back to whatever's off cooldown.
	-- Curaga goes up to tier V (there is no Curaga VI) -- thresholds below are biased LOW on
	-- purpose, so it reaches for a stronger tier sooner rather than under-cure the group.
	local tiers
	if missingHP < 300 then
		tiers = {'Curaga', 'Curaga II', 'Curaga III', 'Curaga IV', 'Curaga V'}
	elseif missingHP < 600 then
		tiers = {'Curaga II', 'Curaga III', 'Curaga IV', 'Curaga V', 'Curaga'}
	elseif missingHP < 900 then
		tiers = {'Curaga III', 'Curaga IV', 'Curaga V', 'Curaga II', 'Curaga'}
	elseif missingHP < 1300 then
		tiers = {'Curaga IV', 'Curaga V', 'Curaga III', 'Curaga II', 'Curaga'}
	else
		tiers = {'Curaga V', 'Curaga IV', 'Curaga III', 'Curaga II', 'Curaga'}
	end

	for _, name in ipairs(tiers) do
		local spell = get_spell_table_by_name(name)
		if spell and silent_can_use(spell.id) and spell_recasts[spell.id] < spell_latency then
			windower.chat.input('/ma "'..name..'" '..cureTarget.id..'')
			return
		end
	end

	add_to_chat(123,'Abort: All Curaga tiers on cooldown.')
end

-- Smart self-only AoE cure: Cura's potency scales off damage YOU took while Afflatus Misery
-- is active, so it's only worth casting with Misery up. If Misery isn't active, this falls
-- straight through to handle_smartcuraga instead so the heal still lands with real strength.
function handle_smartcura(cmdParams)
	-- cmdParams[1] == 'smartcura'
	-- cmdParams[2] (optional) == mob ID or name to base the heal off of, same rules as smartcure

	if not state.Buff['Afflatus Misery'] then
		handle_smartcuraga(cmdParams)
		return
	end

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
	elseif player.target and (player.target.type == 'SELF' or player.target.type == 'MONSTER' or player.target.type == 'NONE') then
		cureTarget = player
	elseif player.target then
		cureTarget = player.target
	else
		cureTarget = player
	end

	-- If the targeted ally is dead, raise them instead of curing -- Cura does nothing for a ghost.
	if cureTarget.status == 2 or cureTarget.status == 3 then
		windower.chat.input('/ma "Arise" '..cureTarget.id..'')
		return
	end

	-- Estimate missing HP off the targeted person, same logic as smartcure/smartcuraga.
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

	local spell_recasts = windower.ffxi.get_spell_recasts()

	-- Cura tops out at tier III. Thresholds biased LOW, same philosophy as smartcuraga --
	-- reach for the stronger tier sooner rather than under-cure the group.
	local tiers
	if missingHP < 400 then
		tiers = {'Cura', 'Cura II', 'Cura III'}
	elseif missingHP < 900 then
		tiers = {'Cura II', 'Cura III', 'Cura'}
	else
		tiers = {'Cura III', 'Cura II', 'Cura'}
	end

	for _, name in ipairs(tiers) do
		local spell = get_spell_table_by_name(name)
		if spell and silent_can_use(spell.id) and spell_recasts[spell.id] < spell_latency then
			windower.chat.input('/ma "'..name..'" <me>')
			return
		end
	end

	add_to_chat(123,'Abort: All Cura tiers on cooldown.')
end

function check_buff()
	if state.AutoBuffMode.value ~= 'Off' and not data.areas.cities:contains(world.area) then
		local spell_recasts = windower.ffxi.get_spell_recasts()
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
		{Name='Reraise IV',		Buff='Reraise',		SpellID=848,	When='Idle'},
		{Name='Aurorastorm',	Buff='Aurorastorm',	SpellID=119,	When='Always'},
		{Name='Aquaveil',		Buff='Aquaveil',	SpellID=55,		When='OutOfCombat'},
	},
	Default = {
		{Name='Reraise IV',		Buff='Reraise',		SpellID=848,	Reapply=true},
		{Name='Aquaveil',		Buff='Aquaveil',	SpellID=55,		Reapply=true},
		{Name='Aurorastorm',	Buff='Aurorastorm',	SpellID=119,	Reapply=true},
	},
	Melee = {
		{Name='Reraise IV',		Buff='Reraise',		SpellID=848,	Reapply=false},
	},
}
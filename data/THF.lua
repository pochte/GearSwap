-- =============================================================================
-- THF.lua — Changelog
-- 2026-08-19: Added a SATA -> Assassin's Charge chain in job_precast(), gated behind
--             state.SATAMode. Before a WS, works through Sneak Attack -> Trick Attack ->
--             Assassin's Charge in order, using cancel/retry against the WS the same way
--             Assassin's Charge already did on its own -- each step only fires if the buff
--             isn't already up and the ability's off cooldown, otherwise it falls through to
--             the next one. Requires state.SATAMode to exist as a boolean state in the gear
--             file's user_job_setup() (same pattern as AmbushMode/ExtraMeleeMode) -- add it
--             there if it isn't defined yet, or this whole block just silently never fires.
-- 2026-08-09: Added check_ecphoria_for_ja(spell) call at the top of job_precast() --
--             correctly wires the Amnesia -> Ecphoria Ring precast hook here (see
--             Ullona-Globals.lua). This is the correct home for that call; a stray copy had
--             been accidentally pasted into Ullona_Thf_Gear.lua instead as a full function
--             definition, which was silently overriding this entire job_precast -- see that
--             file's own changelog for details. Fixed on both ends.
-- 2026-08-01: get_ability_recast_id_by_name() moved back OUT of THF.lua and into
--             Ullona-Globals.lua -- for real this time. Turns out it's genuinely shared: the
--             global smartwaltz system (Reverse Flourish pre-step) calls it too, not just
--             Assassin's Charge here. The previous "moved to Globals" changelog entry was
--             never actually true (the function was deleted from here but never added there),
--             which silently broke smartwaltz on every non-THF job while THF kept working by
--             accident, since this file happened to still define it. Now there's exactly ONE
--             copy, living in Globals where both callers can reach it -- nothing left here.
-- 2026-07-26: Added th_action_check() (ported from a friend's THF file) -- extends Treasure
--             Hunter credit to Provoke, Animated Flourish, and the unblinkable Quick/Box/
--             Stutter Step + Desperate/Violent Flourish, on top of the standard ranged-attack/
--             Aeolian Edge cases. Kept THF-specific rather than global since I can't confirm
--             whether Sel-TreasureHunter (not in this project's files) supports an
--             undocumented global variant the way the other Sel-Include hooks do -- the
--             literal th_action_check name is the safe, standard contract to rely on.
-- 2026-07-15: Added Assassin's Charge before every weapon skill, if it's not already up and
--             off cooldown -- guarantees the Triple Attack lands on the WS's first hit rather
--             than potentially going to waste on a random melee swing between skills. Uses a
--             name-based lookup against Windower's standard res.job_abilities resource table
--             instead of a hardcoded recast ID (which I couldn't verify from any source I had
--             access to, and didn't want to guess).
-- =============================================================================

-- Initialization function for this job file.
function get_sets()
    -- Load and initialize the include file.
    include('Sel-Include.lua')
  include('Ullona-shortcuts')
end

-- Setup vars that are user-independent.  state.Buff vars initialized here will automatically be tracked.
function job_setup()

    state.Buff['Sneak Attack'] = buffactive['Sneak Attack'] or false
    state.Buff['Trick Attack'] = buffactive['Trick Attack'] or false
    state.Buff['Feint'] = buffactive['Feint'] or false
	state.Buff['Aftermath: Lv.3'] = buffactive['Aftermath: Lv.3'] or false

	-- [NEW] For th_action_check() below: extends Treasure Hunter credit beyond the standard
	-- ranged-attack/Aeolian-Edge cases. JA IDs for actions that always carry TH: Provoke (35),
	-- Animated Flourish (204). Unblinkable JA IDs (still TH-eligible even though they can't
	-- be blinked away): Quick/Box/Stutter Step (201/202/203), Desperate/Violent Flourish
	-- (205/207) -- these only ever matter if subbing /DNC, harmless no-ops otherwise.
	info.default_ja_ids = S{35, 204}
	info.default_u_ja_ids = S{201, 202, 203, 205, 207}

	autows = "Rudra's Storm"
	rangedautows = "Last Stand"
	autofood = 'Soy Ramen'
	
	update_melee_groups()
	init_job_states({"Capacity","AutoRuneMode","AutoTrustMode","AutoWSMode","AutoShadowMode","AutoFoodMode","AutoStunMode","AutoDefenseMode",},{"AutoBuffMode","AutoSambaMode","Weapons","OffenseMode","WeaponskillMode","IdleMode","Passive","RuneElement","TreasureMode",})
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------
-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.

function job_filtered_action(spell, eventArgs)
	if spell.type == 'WeaponSkill' then
		local available_ws = S(windower.ffxi.get_abilities().weapon_skills)
		-- WS 112 is Double Thrust, meaning a Spear is equipped.
		if available_ws:contains(32) then
            if spell.english == "Rudra's Storm" then
				windower.chat.input('/ws "Savage Blade" '..spell.target.raw)
                cancel_spell()
				eventArgs.cancel = true
            end
        end
	end
end

function job_pretarget(spell, spellMap, eventArgs)

end

function job_precast(spell, spellMap, eventArgs)
	-- [ADDED 2026-08-09] Amnesia -> Ecphoria Ring: swaps ring2 to Ecphoria Ring the moment
	-- a job ability is attempted while Amnesia is up (see check_ecphoria_for_ja() in
	-- Ullona-Globals.lua for the actual logic -- this is just the required per-job wiring).
	check_ecphoria_for_ja(spell)

	-- [ADDED 2026-08-19] SATA -> Assassin's Charge chain, in SATAMode: before any weapon
	-- skill, work through Sneak Attack -> Trick Attack -> Assassin's Charge in order. Each
	-- step only fires if that buff isn't already up AND the ability is off cooldown; already
	-- being buffed or being on cooldown just skips to the next link in the chain rather than
	-- blocking it. Same cancel/retry shape as the existing Assassin's Charge check below --
	-- state.SATAMode needs a boolean state entry in user_job_setup() (gear file), same as
	-- AmbushMode/ExtraMeleeMode, if it isn't defined there already.
	if spell.type == 'WeaponSkill' and state.SATAMode and state.SATAMode.value == true then
		local abil_recasts = windower.ffxi.get_ability_recasts()

		if not buffactive['Sneak Attack'] then
			local sa_id = get_ability_recast_id_by_name('Sneak Attack')
			if sa_id and abil_recasts[sa_id] < latency then
				eventArgs.cancel = true
				cancel_spell()
				windower.chat.input('/ja "Sneak Attack" <me>')
				windower.chat.input:schedule(1,'/ws "'..spell.english..'" '..spell.target.raw..'')
				return
			end
		end

		if not buffactive['Trick Attack'] then
			local ta_id = get_ability_recast_id_by_name('Trick Attack')
			if ta_id and abil_recasts[ta_id] < latency then
				eventArgs.cancel = true
				cancel_spell()
				windower.chat.input('/ja "Trick Attack" <me>')
				windower.chat.input:schedule(1,'/ws "'..spell.english..'" '..spell.target.raw..'')
				return
			end
		end
	end

	-- Fires Assassin's Charge before any weapon skill if it's not already up and it's off
	-- cooldown -- guarantees a Triple Attack on the WS's first hit rather than letting it go
	-- to waste on a random melee swing between skills. Cancels the WS, uses the JA, then
	-- retries the same WS a moment later once the buff has landed.
	if spell.type == 'WeaponSkill' and not buffactive["Assassin's Charge"] then
		local abil_recasts = windower.ffxi.get_ability_recasts()
		local ac_id = get_ability_recast_id_by_name("Assassin's Charge")
		if ac_id and abil_recasts[ac_id] < latency then
			eventArgs.cancel = true
			cancel_spell()
			windower.chat.input('/ja "Assassin\'s Charge" <me>')
			windower.chat.input:schedule(1,'/ws "'..spell.english..'" '..spell.target.raw..'')
			return
		end
	end
end

function job_post_precast(spell, spellMap, eventArgs)
    
	if spell.type == 'WeaponSkill' then
		if (spell.english == 'Aeolian Edge' or spell.english == 'Cyclone') and state.TreasureMode.value ~= 'None' then
			equip(sets.TreasureHunter)
			return
		end
	
		local WSset = standardize_set(get_precast_set(spell, spellMap))
		local wsacc = check_ws_acc()
		
		if (WSset.ear1 == "Moonshade Earring" or WSset.ear2 == "Moonshade Earring") then
			-- Replace Moonshade Earring if we're at cap TP
			if get_effective_player_tp(spell, WSset) > 3200 then
				if wsacc:contains('Acc') and not state.Buff['Sneak Attack'] and not state.Buff['Trick Attack'] and sets.AccMaxTP then
					equip(sets.AccMaxTP[spell.english] or sets.AccMaxTP)
				elseif sets.MaxTP then
					equip(sets.MaxTP[spell.english] or sets.MaxTP)
				else
				end
			end
		end

		if state.AmbushMode.value == true and sets.Ambush then
			if state.Buff['Sneak Attack'] == false and state.Buff['Trick Attack'] == false then
				equip(sets.Ambush)
			end
		end
	end

    if spell.english == 'Sneak Attack' or spell.english == 'Trick Attack' or spell.type == 'WeaponSkill' then
        if state.TreasureMode.value == 'SATA' or state.TreasureMode.value == 'Fulltime' then
            equip(sets.TreasureHunter)
        end
    end
	
end

function job_post_midcast(spell, spellMap, eventArgs)
    if state.TreasureMode.value ~= 'None' and spell.action_type == 'Ranged Attack' then
        equip(sets.TreasureHunter)
    end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, spellMap, eventArgs)
    -- Weaponskills wipe SATA/Feint.  Turn those state vars off before default gearing is attempted.
    if spell.type == 'WeaponSkill' and not spell.interrupted then
        state.Buff['Sneak Attack'] = false
        state.Buff['Trick Attack'] = false
        state.Buff['Feint'] = false
    end
end

-- Called after the default aftercast handling is complete.
function job_post_aftercast(spell, spellMap, eventArgs)
    -- If Feint is active, put that gear set on on top of regular gear.
    -- This includes overlaying SATA gear.
    check_buff('Feint', eventArgs)
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for non-casting events.
-------------------------------------------------------------------------------------------------------------------

-- Called when a player gains or loses a buff.
-- buff == buff gained or lost
-- gain == true if the buff was gained, false if it was lost.
function job_buff_change(buff, gain)
	-- [REVERTED 2026-08-24] Removed the user_buff_change(buff, gain) call added here on the
	-- theory that this job-level job_buff_change was clobbering Sel-Include.lua's dispatch to
	-- user_buff_change. Having now actually seen Sel-Include.lua's buff_change() (line 2217),
	-- that theory was wrong: it calls user_buff_change unconditionally, completely independent
	-- of whether job_buff_change is defined -- there was never any clobbering. The added call
	-- was making Soul Devour/haste-tier/Amnesia-revert fire TWICE per buff event. Reverted.
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


-- Called any time we attempt to handle automatic gear equips (ie: engaged or idle gear).
function job_handle_equipping_gear(playerStatus, eventArgs)
    -- Check for SATA when equipping gear.  If either is active, equip
    -- that gear specifically, and block equipping default gear.
    check_buff('Sneak Attack', eventArgs)
    check_buff('Trick Attack', eventArgs)
end


function job_customize_idle_set(idleSet)
    return idleSet
end

-- Modify the default melee set after it was constructed.
function job_customize_melee_set(meleeSet)

    if state.AmbushMode.value == true then
        meleeSet = set_combine(meleeSet, sets.Ambush)
    end
	
    if state.TreasureMode.value == 'Fulltime' then
        meleeSet = set_combine(meleeSet, sets.TreasureHunter)
    end

    -- [FIX]: ExtraMeleeMode was defined with Suppa/DWMax/Parry options in the gear
    --        file's user_job_setup(), but nothing anywhere ever checked its value —
    --        toggling it silently did nothing. Wired in here the same way AmbushMode
    --        and TreasureMode already overlay onto the melee set. sets.Suppa/DWMax/Parry
    --        are still empty tables in the gear file — populate them with actual gear
    --        whenever you're ready, this just makes the toggle actually take effect.
    if state.ExtraMeleeMode.value == 'Suppa' then
        meleeSet = set_combine(meleeSet, sets.Suppa)
    elseif state.ExtraMeleeMode.value == 'DWMax' then
        meleeSet = set_combine(meleeSet, sets.DWMax)
    elseif state.ExtraMeleeMode.value == 'Parry' then
        meleeSet = set_combine(meleeSet, sets.Parry)
    end

    return meleeSet
end

function job_self_command(commandArgs, eventArgs)

end

function job_tick()

	return false
end

-- Called by the 'update' self-command.
function job_update(cmdParams, eventArgs)
    th_update(cmdParams, eventArgs)
	update_melee_groups()
end

-- Function to display the current relevant user state when doing an update.
-- Return true if display was handled, and you don't want the default info shown.
function display_current_job_state(eventArgs)
    local msg = 'Melee'
    
    if state.CombatForm.has_value then
        msg = msg .. ' (' .. state.CombatForm.value .. ')'
    end
    
    msg = msg .. ': '
    
    msg = msg .. state.OffenseMode.value
    if state.HybridMode.value ~= 'Normal' then
        msg = msg .. '/' .. state.HybridMode.value
    end
    msg = msg .. ', WS: ' .. state.WeaponskillMode.value
    
    if state.DefenseMode.value ~= 'None' then
        msg = msg .. ', ' .. 'Defense: ' .. state.DefenseMode.value .. ' (' .. state[state.DefenseMode.value .. 'DefenseMode'].value .. ')'
    end
    
    if state.Kiting.value == true then
        msg = msg .. ', Kiting'
    end

    if state.PCTargetMode.value ~= 'default' then
        msg = msg .. ', Target PC: '..state.PCTargetMode.value
    end

    if state.SelectNPCTargets.value == true then
        msg = msg .. ', Target NPCs'
    end
    
    msg = msg .. ', TH: ' .. state.TreasureMode.value

    add_to_chat(122, msg)

    eventArgs.handled = true
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

-- State buff checks that will equip buff gear and mark the event as handled.
function check_buff(buff_name, eventArgs)
    if state.Buff[buff_name] then
        equip(sets.buff[buff_name] or {})
        if state.TreasureMode.value == 'SATA' or state.TreasureMode.value == 'Fulltime' then
            equip(sets.TreasureHunter)
        end
        eventArgs.handled = true
    end
end

function update_melee_groups()
	if player.equipment.main then
		classes.CustomMeleeGroups:clear()
		
		if player.equipment.main == "Vajra" and state.Buff['Aftermath: Lv.3'] then
				classes.CustomMeleeGroups:append('AM')
		end
	end	
end

-- [NEW] Check for various actions that carry Treasure Hunter credit beyond the standard
-- ranged-attack/Aeolian-Edge cases (see the info.default_ja_ids/default_u_ja_ids lists in
-- job_setup above). Only called by the TH-tracking framework when TreasureMode isn't 'None'.
-- Category/param are as specified in the action event packet.
function th_action_check(category, param)
	if category == 2 or -- any ranged attack
		(category == 3 and param == 30) or -- Aeolian Edge
		(category == 6 and info.default_ja_ids:contains(param)) or -- Provoke, Animated Flourish
		(category == 14 and info.default_u_ja_ids:contains(param)) -- Quick/Box/Stutter Step, Desperate/Violent Flourish
		then return true
	end
end
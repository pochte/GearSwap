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
-- 2026-08-09: [REVISED] Phalanx handling moved from automatic precast interception to an
--             explicit command: gs c phalanx [target] (no target -> <me>). Precast
--             interception is removed entirely -- macros casting Phalanx/Phalanx II
--             directly now just go out as typed, no redirect. The command always attempts
--             Phalanx (tier 1) first via handle_phalanx() (near handle_elemental), and the
--             existing job_aftercast escalation to Phalanx II still applies if that tier 1
--             cast comes back spell.interrupted. This sidesteps the macro-targeting
--             ambiguity that kept defeating the precast-based approach.
-- 2026-08-09: [REVISED] Phalanx/Phalanx II redesigned again -- target-detection (both
--             spell.target.type and the identity-based spell.target.id follow-up) kept
--             failing to actually change behavior in practice. New approach per direct
--             instruction: abandon detection entirely, always attempt Phalanx (tier 1)
--             first regardless of target, then escalate to Phalanx II via job_aftercast
--             ONLY if that tier 1 cast comes back spell.interrupted == true. Tracked via
--             a new phalanx_fallback_target variable (job_setup).
-- 2026-08-09: [FIX] Phalanx/Phalanx II self-detection switched from spell.target.type ==
--             'SELF' to an identity check (spell.target.id == player.id). The type check
--             only reports 'SELF' for a literal <me> cast -- targeting yourself any other
--             way (clicking your own HP bar, tabbing to yourself and casting with <t>)
--             reported as 'PLAYER' instead, so the downgrade silently never fired for
--             Phalanx II cast that way, and the reverse (Phalanx -> Phalanx II upgrade)
--             had the same blind spot in the opposite direction.
-- 2026-08-09: [FIX] weather-before-nuke block had no exclusion for Enspells -- since
--             Enspells are Elemental Magic skill same as real nukes, casting Enfire/
--             Enfire II etc. was getting cancelled and detoured through a weather cast
--             first whenever weather didn't match, delaying a simple self-buff by 2-5
--             seconds for no reason. Excluded via data.spells.enspells:contains() check.
-- 2026-08-09: Added Accession-Enspell downgrade -- confirmed against the wiki that Accession
--             explicitly excludes Enstone II/Enaero II/Enwater II/Enblizzard II/Enthunder II/
--             Enfire II (same exclusion list Phalanx II is already on). Casting any Enspell
--             II while Accession is up now redirects to the tier I version instead, mirroring
--             the existing Phalanx II -> Phalanx redirect.
-- 2026-08-09: [FIX] Composure-first block (self-target Enhancing Magic) was catching
--             Phalanx II cast on yourself and detouring it through a Composure cast before
--             the Phalanx II->Phalanx downgrade below could run -- still landed as Phalanx
--             eventually, but delayed rather than instant. Excluded Phalanx/Phalanx II from
--             that block so the downgrade fires immediately again, as before.
-- 2026-08-09: Added check_ecphoria_for_ja(spell) call at the top of job_precast(), outside
--             the action_type=='Magic' block (job abilities aren't Magic) -- correctly wires
--             the Amnesia -> Ecphoria Ring precast hook (see Ullona-Globals.lua).
-- 2026-08-01: Cure/Cure II Aurorastorm handling downgraded from cancel-and-reschedule to a
--             non-blocking reminder. It used to cancel the cast, fire Aurorastorm, then
--             reschedule the real heal ~4 seconds later -- fragile, since any interruption
--             along that chain meant the actual heal never went out. Per direct instruction: a
--             party member's health always comes before weather, no exceptions. The Cure/Cure
--             II cast is now NEVER cancelled or delayed for Aurorastorm -- worst case you get a
--             chat reminder and the heal still lands immediately regardless.
-- 2026-08-01: Reworked the low-MP Convert logic into a shared handle_convert() core, used by
--             BOTH the automatic tick check and a new manual "gs c convert" command -- one
--             source of truth instead of two copies drifting apart. HP safety threshold raised
--             from 50% to 75% (Convert trades HP for MP roughly 1:1, and 50% still felt too
--             risky mid-fight). Below 75% HP it now echoes "HP too low to safely convert" and
--             refuses to fire, giving you a chance to heal up and try again -- previously it
--             silently echoed the generic "Low on MP" message instead, which didn't tell you
--             WHY it was refusing.
-- 2026-08-01: New check_low_mp(), hooked into job_tick(). If MP drops under 200, tries
--             Convert followed by a Cure IV a couple seconds later (once the MP has actually
--             landed). Convert trades HP for MP roughly 1:1, so this is skipped entirely if
--             Convert is on cooldown (ability recast ID 49, confirmed via Windower/Resources
--             job_abilities.lua) or HP is too low to risk it, echoes "Low on MP" instead
--             (rate-limited to once per 30s so it doesn't spam every tick).
-- 2026-07-15: Fixed WS gear getting clobbered when an active enspell's element matched current
--             weather at intensity 2 (e.g. Enfire II during a Firestorm cast on you). Root
--             cause: job_customize_melee_set's Hachirin-no-Obi swap (an ENGAGED-gear bonus,
--             correct behavior on its own) was somehow interfering with WeaponSkill gear too --
--             waist stuck on Hachirin-no-Obi, other WS-specific slots reverting to regular
--             engaged values instead of the weaponskill's own set. Rather than chase the exact
--             call-order interaction through a core file with no visibility into it, added a
--             final, unconditional re-equip of the correct WS gear at the start of
--             job_post_precast's WeaponSkill branch (before the existing Moonshade/MaxTP
--             override, so that override still layers on top correctly). WS gear now always
--             wins over whatever ran earlier in the same pass.
-- =============================================================================

-- Initialization function for this job file.
function get_sets()
    -- Load and initialize the include file.
    include('Sel-Include.lua')
    -- [ADDED 2026-08-30] Was never included at all for RDM -- get_sets() only had
    -- Sel-Include.lua and Ullona-shortcuts.lua. Every other job that subs SCH (WHM/BLM/GEO/
    -- SCH itself) already includes this. Enables smart_caster_precast()/try_sublimation()/
    -- smart_caster_buff_change(), now wired into job_precast/job_aftercast/job_buff_change
    -- above.
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

    -- [ADDED 2026-08-14] Hard cap on nuke tier this job can actually cast, used by
    -- handle_elemental's explicit 'tierN' command (gs c elemental tier6, etc.) to refuse
    -- anything above what the job has access to instead of firing a nonexistent spell at
    -- the server. RDM tops out at Tier V. BLM.lua should set MaxNukeTier = 6; SCH.lua and
    -- GEO.lua should each set MaxNukeTier = 5, the same way, in their own job_setup().
    MaxNukeTier = 5
	
	-- [FIX 2026-08-30] state.RecoverMode retired -- MP recovery is now handled globally via
	-- try_recover_mp() (Ullona-Globals.lua), fixed at 75% MP with no modal to cycle. Matches
	-- the same migration BLM.lua (2026-07-25) and GEO.lua (2026-08-30) already went through --
	-- RDM was the last mage job still carrying the old local modal.
	
	autows = "Savage Blade"
	autofood = 'Pear Crepe'
	enspell = ''
	low_mp_reminded_at = 0
	-- [ADDED 2026-08-09] Tracks the original target of a Phalanx/Phalanx II cast so
	-- job_aftercast can escalate to Phalanx II if the tier 1 attempt fails to land.
	phalanx_fallback_target = nil
	
	update_melee_groups()
	init_job_states({"Capacity","AutoRuneMode","AutoTrustMode","AutoNukeMode","AutoWSMode","AutoShadowMode","AutoFoodMode","AutoStunMode","AutoDefenseMode",},{"AutoBuffMode","AutoSambaMode","Weapons","OffenseMode","WeaponskillMode","IdleMode","Passive","RuneElement","ElementalMode","CastingMode",})
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

function job_precast(spell, spellMap, eventArgs)
	-- [ADDED 2026-08-09] Amnesia -> Ecphoria Ring: swaps ring2 to Ecphoria Ring the moment
	-- a job ability is attempted while Amnesia is up (see check_ecphoria_for_ja() in
	-- Ullona-Globals.lua for the actual logic -- this is just the required per-job wiring).
	-- Placed OUTSIDE the action_type=='Magic' block below since job abilities aren't Magic.
	check_ecphoria_for_ja(spell)

	if spell.action_type == 'Magic' then
		if state.Buff.Chainspell then
			eventArgs.handled = true
		end

		-- [NEW] Composure-first for self-target Enhancing Magic. If Composure isn't up
		-- when casting ANY Enhancing spell on yourself, pop Composure first so the buff
		-- that follows gets Composure's extended-duration bonus. Runs before the Phalanx/
		-- Phalanx II redirect below — on the rescheduled retry (once Composure is up)
		-- that logic still applies normally, since buffactive.Composure will be true by
		-- then. Skipped during Chainspell so it doesn't interrupt the burst-cast sequence.
		-- Recast ID 50 = Composure (confirmed via Windower/Resources job_abilities.lua) —
		-- checked here so this doesn't cancel your buff and fire a dead ability if
		-- Composure happens to be on cooldown; falls through to a normal cast instead.
		-- [FIX 2026-08-09] Excludes Phalanx/Phalanx II -- this block was catching the
		-- self-target Phalanx II->Phalanx downgrade below and detouring it through a
		-- Composure cast first (technically still landed as Phalanx on the delayed retry,
		-- but not the instant downgrade it used to be). Per direct instruction, restored to
		-- go straight to the downgrade logic below, no Composure detour, for these two.
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

		-- [NEW 2026-08-09] Accession-Enspell downgrade. Confirmed against the wiki: Accession
		-- explicitly does NOT work with Enstone II/Enaero II/Enwater II/Enblizzard II/
		-- Enthunder II/Enfire II -- same exclusion list Phalanx II is on, which is why that
		-- redirect already exists below. Casting tier II while Accession is up just spends
		-- the extra MP for nothing, so this redirects to tier I instead. Has to live here as
		-- its own check rather than folded into the Cure/Elemental/Phalanx elseif chain below,
		-- since Enspells are Elemental Magic skill and would already be claimed by that
		-- chain's Elemental Magic branch before ever reaching a later elseif for this.
		if buffactive.Accession and spell.english:endswith(' II') and data.spells.enspells:contains(spell.english) then
			local tier1_name = spell.english:gsub(' II$', '')
			eventArgs.cancel = true
			cancel_spell()
			windower.chat.input('/ma "'..tier1_name..'" '..spell.target.raw)
			return
		end

		-- [FIX] Used to cancel a Cure/Cure II cast, fire Aurorastorm, then reschedule the real
		-- heal ~4 seconds later -- fragile, since any interruption along that chain meant the
		-- actual heal never landed. Per direct instruction: a party member's health always
		-- comes before weather, full stop. This is now reminder-only -- the Cure/Cure II cast
		-- is NEVER cancelled or delayed for Aurorastorm, no matter what.
		if (spell.english == 'Cure' or spell.english == 'Cure II')
			and player.sub_job == 'SCH' and not buffactive['Aurorastorm'] then
			add_to_chat(167, 'Aurorastorm is down')
		end

		-- [NEW] Sub-SCH weather-before-nuke. If Magic Burst Mode is OFF and the nuke's
		-- element doesn't already match current weather, cast weather first (Klimaform if
		-- the storm's already up but Klimaform isn't, otherwise the storm spell itself),
		-- then reschedule the original nuke. SKIPPED ENTIRELY once Magic Burst Mode is on
		-- — no time to weather, burst only. Recast ID 287 = Klimaform (already used by
		-- the 'weather' command in handle_elemental below — reused here for consistency).
		-- [FIX 2026-08-09] Excludes Enspells -- this block had no exclusion for them, and
		-- Enspells are Elemental Magic skill same as real nukes, so casting Enfire/Enfire II
		-- etc. was getting cancelled and detoured through a weather cast first whenever the
		-- weather didn't match, delaying a simple self-buff by 2-5 seconds for no reason.
		-- Enspells are self-buffs, not burst nukes -- they were never meant to go through
		-- this detour at all.
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
		-- [REMOVED 2026-08-09] Automatic Phalanx/Phalanx II precast interception is gone --
		-- both spell.target.type and the identity-based spell.target.id follow-up kept
		-- failing to actually change behavior in practice (macro targeting apparently isn't
		-- reading the way GearSwap expects here). Replaced entirely by an explicit command,
		-- gs c phalanx [target] -- see handle_phalanx() near job_self_command below. Casting
		-- Phalanx/Phalanx II directly from a macro now just goes out as typed, no redirect.
		
        if state.CastingMode.value == 'Proc' then
            classes.CustomClass = 'Proc'
        end

		-- [ADDED 2026-08-30] Smart-Caster.lua wasn't wired in at all for RDM -- get_sets()
		-- didn't even include the file. Given RDM commonly subs SCH (Dark Arts/Light Arts/
		-- Addendum/Manifestation binds already exist in the gear file), this matters: Arts-
		-- aware precast handling and Sublimation auto-reactivation should apply here the
		-- same way they already do for WHM/BLM/GEO/SCH. Placed last, after RDM's own
		-- extensive tailored precast logic above (Composure-first, Accession-Enspell
		-- downgrade, Aurorastorm reminder, weather-before-nuke, Phalanx handling), so
		-- anything RDM already handles explicitly keeps priority -- this only runs if none
		-- of that already cancelled+returned. No-ops harmlessly when not subbing SCH.
		smart_caster_precast(spell, spellMap, eventArgs)
    end

end

function job_post_precast(spell, spellMap, eventArgs)
	if spell.type == 'WeaponSkill' then
		local WSset = standardize_set(get_precast_set(spell, spellMap))
		local wsacc = check_ws_acc()

		-- [FIX] Final, unconditional re-equip of the correct WS gear, done FIRST in this
		-- function (before the Moonshade/MaxTP override below, so that override can still
		-- correctly layer on top of it rather than getting undone by it). This exists because
		-- job_customize_melee_set's Hachirin-no-Obi swap (fires when an active enspell's
		-- element matches current weather at intensity 2 -- e.g. Enfire II during a Firestorm)
		-- was clobbering WS gear entirely: waist stuck on Hachirin-no-Obi and other WS-specific
		-- slots reverting to regular engaged values instead of the weaponskill's own set. Same
		-- fix pattern as the earlier ammo/range leak -- rather than chase the exact call-order
		-- interaction through a core file we don't have visibility into, just force-reassert
		-- the correct WS gear before anything else in this function runs. WS gear now always
		-- wins over whatever ran earlier in the same pass.
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

-- Run after the default midcast() is done.
-- eventArgs is the same one used in job_midcast, in case information needs to be persisted.
function job_post_midcast(spell, spellMap, eventArgs)

	if spell.skill == 'Elemental Magic' and default_spell_map ~= 'ElementalEnfeeble' and spell.english ~= 'Impact' then
		try_magic_burst()

		-- [RESTORED 2026-09-03] try_zodiac_ring() now actually exists (Ullona-Globals.lua) --
		-- it was being called before but was never defined, throwing a nil-global error on
		-- every matching Elemental Magic cast. The ring's bonus is day-element only, so the
		-- function itself checks spell.element against world.day_element internally; no
		-- weather check needed here anymore.
		try_zodiac_ring(spell)

		if spell.element and sets.element[spell.element] then
			equip(sets.element[spell.element])
		end
		
		-- [FIX 2026-08-30] Was a local state.RecoverMode modal ('35%'/'60%'/'Always'/'Never')
		-- that had to be manually cycled. Now calls the shared global try_recover_mp()
		-- (Ullona-Globals.lua) -- fixed 75% MP threshold, same RecoverBurst/
		-- ResistantRecoverBurst selection logic preserved exactly, no modal to forget to set.
		-- Matches the same migration BLM.lua and GEO.lua already went through -- RDM was the
		-- last mage job still carrying the old local modal, which is why it kept showing up
		-- on your display when the others didn't.
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
	
	-- [FIX] Kaja Bow retired -- Regal Gem now covers Magic Accuracy in every weapon mode, so
	-- this swap no longer excludes DualWeapons/EnspellMelee. (As written before, this block
	-- was actually dead code: state.Weapons only ever has three values -- None, DualWeapons,
	-- EnspellMelee -- and all three were excluded, so it could never fire.) The old
	-- unconditional Kaja Bow relock that used to run after this is gone too, since it was
	-- what re-equipped the bow after every precast regardless of what a midcast set wanted.
	if spell.skill == 'Enfeebling Magic' or spell.skill == 'Dark Magic' or default_spell_map == 'ElementalEnfeeble' or spell.english == 'Impact' then
		if item_available('Regal Gem') then
			equip({range=empty,ammo="Regal Gem"})
		end
	end
end

function job_aftercast(spell, spellMap, eventArgs)
    -- [ADDED 2026-08-30] Auto-reactivates Sublimation whenever it drops, if subbing SCH.
    -- No-ops harmlessly on any other subjob. Pairs with the smart_caster_precast() wiring
    -- added to job_precast above -- Smart-Caster.lua wasn't included in this job at all
    -- before now.
    try_sublimation()

    -- [ADDED 2026-08-09] Phalanx fallback escalation. Pairs with the always-try-tier-1-first
    -- redirect in job_precast above. If the tier 1 Phalanx cast we fired actually failed to
    -- land (spell.interrupted), escalate to Phalanx II on the same original target instead.
    -- If it landed fine, just clear the tracker -- no escalation needed. Checked first,
    -- before the not-interrupted block below, since this needs to run on BOTH outcomes.
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
		-- [FIX 2026-08-30] Removed the "reset MagicBurstMode after one Elemental Magic cast in
		-- Single mode" branch here -- MagicBurstMode is retired, folded into CastingMode.
		-- MB is now a PERSISTENT toggle per direct instruction; nothing auto-reverts it.
		elseif data.spells.enspells:contains(spell.english) then
			enspell = spell.english
			update_melee_groups()
		end
	end
end

function job_buff_change(buff, gain)
	-- [REVERTED 2026-08-24] Removed the user_buff_change(buff, gain) call added here on the
	-- theory that this job-level job_buff_change was clobbering Sel-Include.lua's dispatch to
	-- user_buff_change. Having now actually seen Sel-Include.lua's buff_change() (line 2217),
	-- that theory was wrong: it calls user_buff_change unconditionally, completely independent
	-- of whether job_buff_change is defined -- there was never any clobbering. The added call
	-- was making Soul Devour/haste-tier/Amnesia-revert fire TWICE per buff event. Reverted.
	--
	-- [ADDED 2026-08-30] smart_caster_buff_change(buff, gain) is a DIFFERENT function from
	-- user_buff_change above -- Ullona-Globals.lua's own user_buff_change never calls it, so
	-- there's no double-fire risk here the way there was with the reverted call. It just
	-- re-triggers try_sublimation() the instant Sublimation's buff state changes, for
	-- slightly more immediate reactivity than waiting on job_aftercast's own try_sublimation()
	-- call to catch it on the next cast. Matches the same wiring GEO.lua already has.
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
    -- [FIX] Kaja Bow retired -- range/ammo now just come from sets.weapons.DualWeapons /
    -- sets.weapons.EnspellMelee (range=empty, ammo="Crepuscular Pebble"), no override needed.
    -- EnspellMelee's main/sub pin stays since that's a weapon choice, not a Kaja Bow leftover.
    if state.Weapons.value == 'EnspellMelee' then
        idleSet = set_combine(idleSet, {main="Naegling", sub="Culminus"})
    end

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
    -- [FIX] Kaja Bow retired -- same reasoning as job_customize_idle_set above.
    if state.Weapons.value == 'EnspellMelee' then
        meleeSet = set_combine(meleeSet, {main="Naegling", sub="Culminus"})
    end

    if state.Weapons.value:contains('Enspell') and enspell ~= '' then
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

-- Set eventArgs.handled to true if we don't want the automatic display to be run.
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
-- Format: gs c elemental <nuke, helix, skillchain1, skillchain2, weather>
-- Quick enspell shortcut hooked to the elemental wheel: gs c enspell
-- Casts tier II of whatever element ElementalMode is currently set to (Fire/Ice/Wind/etc,
-- same Ctrl+` wheel used everywhere else). Falls back to tier I if II isn't learned yet
-- OR is on cooldown — same silent_can_use + spell_recasts pairing used for the Cure IV
-- checks in WHM/BLM's smartcure functions.
function handle_enspell_shortcut(cmdParams)
	local element = data.elements.enspell_of[state.ElementalMode.value]
	-- Real spell names only capitalize the leading "E" (Enfire, Enblizzard, Enstone...) --
	-- element comes back capitalized (e.g. "Fire", "Blizzard"), so it must be lowercased here
	-- or the concatenated name (e.g. "EnFire II") won't match anything in the spell resources
	-- and get_spell_table_by_name returns false instead of a table, crashing the .id lookup below.
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

-- [ADDED 2026-08-09] gs c phalanx [target] -- explicit command replacing the old precast-
-- interception approach (see job_precast changelog above for why that got abandoned).
-- No target given -> <me>. Always attempts Phalanx (tier 1) first; job_aftercast escalates
-- to Phalanx II on the same target if that tier 1 cast comes back spell.interrupted.
function handle_phalanx(cmdParams)
	local target = cmdParams[2] and table.concat(cmdParams, ' ', 2) or '<me>'
	phalanx_fallback_target = target
	windower.chat.input('/ma "Phalanx" '..target)
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
		if  (player.sub_job == 'NIN' or player.sub_job == 'DNC') then 
			windower.chat.input('/ma "En'..data.elements.enspell_of[state.ElementalMode.value]..'" <me>')
		else
			windower.chat.input('/ma "En'..data.elements.enspell_of[state.ElementalMode.value]..' II" <me>')
		end
		return
	elseif command == 'weather' then
		-- [FIX 2026-08-13] This branch was casting Phalanx instead of the actual weather/storm
		-- spell -- looks like a leftover from before Phalanx got split into its own
		-- handle_phalanx() command on 2026-08-09; this branch never got updated to match and
		-- was still firing the old Phalanx cast. Now casts the storm spell for the current
		-- ElementalMode element, same as the SCH branch below (minus the Klimaform swap, which
		-- only applies with SCH sub).
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

		-- [ADDED 2026-08-14] Job-tier-cap guard. Previously this branch blindly sent whatever
		-- tier was typed straight out via /ma -- 'gs c elemental tier6' on RDM (max Tier V)
		-- fired a cast attempt at a spell RDM doesn't have. Capping here means an over-tier
		-- request just aborts with a chat message instead of ever reaching windower.chat.input.
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

-- =============================================================================
-- CONVERT + CURE IV CHAIN
-- Shared core used by BOTH the automatic low-MP tick check (check_low_mp, below)
-- and the manual "gs c convert" command -- one source of truth for the HP-safety
-- and cooldown logic instead of two copies that could drift out of sync.
--
-- Convert trades HP for MP roughly 1:1 -- it's a swap, not a refill of either
-- stat. Below 75% HP this refuses to fire at all and echoes a warning instead, so
-- you can top yourself off (Waltz, a cure, whatever) and try again once it's
-- actually safe. At 75%+ HP, fires Convert immediately, then a Cure IV two
-- seconds later once the MP has landed.
-- =============================================================================
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

-- =============================================================================
-- LOW MP AUTO-CONVERT: hooked into job_tick(). If MP drops under 200, calls the
-- shared handle_convert() above. Rate-limited to one attempt every 30 seconds --
-- covers the HP-too-low warning, the on-cooldown abort, AND a successful Convert
-- alike, so a long fight sitting under 200 MP doesn't spam any of them every tick.
-- =============================================================================
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

-- [FIX 2]: Tiers capped at Cure IV throughout — Red Mage cannot cast Cure V or VI,
--          so those branches (copy-pasted from WHM/BLM originally) would have silently
--          done nothing when reached. Thresholds re-tuned to fall back sensibly within
--          the tiers RDM actually has access to.
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

		-- [FIX] Monster targets no longer cure-nuke at all. Cancels out and casts whatever
		-- nuke the ElementalMode wheel is currently set to instead, reusing handle_elemental's
		-- existing 'nuke' logic (tier fallback, MP check, all of it) rather than duplicating it.
		-- Also fixes a real crash that existed here before: this branch cast its spell but never
		-- returned, so execution fell through to `missingHP < 250` below with missingHP still
		-- nil (never assigned for monster targets), throwing "attempt to compare nil with
		-- number" every time smartcure was used on a monster.
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
			-- [FIX 2 cont.]: This branch previously reached for Cure V/VI first, which
			--          RDM can't cast. Now caps out at Cure IV, RDM's actual ceiling.
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
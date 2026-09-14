-- =============================================================================
-- Smart-Caster.lua — Changelog
-- 2026-08-09: [REVISED -- BUGFIX] Removed the self-shortcut and <t> resolution from SmartNa,
--             both added earlier this session. The self-shortcut's Bar-hint half was a real
--             bug: it checked YOUR OWN Bar-spell hints before ever considering a target, so
--             having e.g. Barblindra up on yourself (a ward, not a real debuff) silently
--             hijacked the cast onto yourself even while trying to cure an ally's ACTUAL
--             Blindness. <t> resolution also proved troublesome enough in practice to drop
--             rather than keep patching. Simplified to: explicit name wins if given,
--             otherwise always <st> -- click who you mean, yourself included.
-- 2026-08-09: [REVISED] SmartNa reworked to mirror handle_smartwaltz's pattern
--             (Ullona-Globals.lua): if you actually have a real debuff/hint yourself, it
--             cures YOU directly now, no targeting at all -- previously it would still try
--             to resolve a target first even when you were the one who needed curing. And
--             when you ARE resolving an ally target, <t> is only trusted if it isn't a
--             monster (same .type=='MONSTER' check smartwaltz uses) -- otherwise falls to
--             <st>. Closes the gap where meleeing with a monster targeted would have tried
--             to cast a curing spell at the monster.
-- 2026-08-09: [REVISED] SmartNa target resolution -- no more silent self-cast default.
--             gs c smartna now targets <t> (whatever's currently selected) if you have one,
--             or prompts <st> if you don't, rather than always assuming yourself. An
--             explicit name (gs c smartna <name>) still overrides both. Since the priority
--             chain was already inference from your own state either way (see [LIMITATION]
--             note below), self and targeted casts are now one unified flow instead of two
--             separate branches -- <t> resolving to yourself behaves exactly like the old
--             self-cast path.
-- 2026-08-09: [FIX] Self-cast SmartNa (gs c smartna, no target) never checked the Bar-spell
--             hint table -- only the targeted branch did. So Barwatera/Barpoisonra being up
--             on you (your own poison-prep signal, per direct instruction) did nothing when
--             you weren't already showing an actual Poison debuff. Mirrored the same hint
--             check into the self-cast branch now.
-- 2026-08-09: SmartNa targeted casts (gs c smartna <name>) upgraded from "always Cursna" to
--             a 3-step priority chain: (1) mirror whatever debuff YOU currently have onto the
--             target, (2) if you're clean, check your own Bar-status buffs as a hint toward
--             the expected threat (includes Barwatera as a deliberate poison-prep heuristic,
--             not the literal Bar-poison spell), (3) Cursna as the final catch-all. Per
--             direct instruction -- this is inference from your own state, not actual
--             detection of the target's specific debuff (still not possible, see
--             [LIMITATION] note in the SmartNa section below).
-- 2026-08-09: Added SmartNa (handle_smart_curena) -- auto-detects which status ailment
--             YOU are currently under and casts the matching -na spell (Poisona, Paralyna,
--             Blindna, Silena, Stona, Viruna), falling back to Cursna for anything without
--             its own dedicated cure (Doom, Curse, Amnesia, Charm, Terror) or if the
--             specific spell is on cooldown/unavailable. Wired up as a self-command
--             ("smartna") dispatched from Ullona-Globals.lua's user_self_command, nil-checked
--             so jobs that don't include this file don't error. [LIMITATION]: party-member
--             detection isn't reliable through Windower/GearSwap -- you can't tell WHICH
--             debuff someone else has, only that they have one -- so targeting anyone but
--             yourself always reaches straight for Cursna as the broadest catch-all rather
--             than pretending to detect something that can't actually be read. Reuses the
--             list from the existing SCH Accession block (already covers all these spell
--             names), so Accession-AoE / Celerity-fastcast apply automatically, no extra
--             wiring required.
-- 2026-08-01: Cure/Cure II Aurorastorm handling downgraded from cancel-and-reschedule to a
--             non-blocking reminder, matching the Curaga treatment below. It used to cancel the
--             cast, fire Aurorastorm, then reschedule the real heal ~1.2s later -- fragile,
--             since any interruption along that chain meant the actual heal never went out at
--             all. Per direct instruction: a party member's health always comes before weather.
--             The Cure/Cure II cast is now NEVER cancelled or delayed for any reason related to
--             Aurorastorm -- worst case you get a chat reminder and the heal still lands
--             immediately. WHM.lua's own duplicate version of this same cancel-and-reschedule
--             block was removed entirely (see its own changelog) since this is now the single
--             non-blocking source of truth for every job subbing SCH, not just WHM.
-- 2026-08-01: Removed the standalone Curaga Aurorastorm reminder added earlier -- it was
--             firing ALONGSIDE check_aurorastorm_for_cure() (Ullona-Globals.lua), which every
--             gs c smartcuraga/smartcura call already runs before the actual cast fires. Since
--             that resulting Curaga cast flows through job_precast -> smart_caster_precast()
--             regardless, both systems fired their own "Aurorastorm is down" message for the
--             exact same event -- visible as two back-to-back chat lines on the same tick.
--             check_aurorastorm_for_cure is the single source of truth for this reminder now;
--             nothing in Smart-Caster.lua echoes about Curaga/Aurorastorm anymore.
-- 2026-08-01: Narrowed the SCH Aurorastorm precast block from "any Healing Magic spell" down
--             to Cure/Cure II only, and added a self-preservation guard: never delay for
--             weather if healing yourself under 75% HP. Previously this fired for ANY Healing
--             Magic cast under Light Arts -- Cure I-VI, Curaga, Cursna, even Raise/Reraise --
--             with zero HP awareness, meaning it would delay an emergency Cure V/VI (or worse,
--             a raise) to go cast weather first. That's the exact conflict reported: Aurorastorm
--             firing before emergency cures. Now matches WHM.lua's own job_precast rule --
--             routine, low-stakes Cure/Cure II casts are worth a GCD delay for weather; nothing
--             else is.
-- =============================================================================

-------------------------------------------------------------------------------------------------------------------
-- SMART CASTER
-- SCH Stratagems, Storm Prep, WHM Afflatus, Klimaform, Sublimation Auto
-- Author: Lady Ullona | Retail FFXI / Windower
--
-- USAGE:
--   Place in your GearSwap/data/ folder.
--   In your job file's get_sets(), add:
--       include('Smart-Caster.lua')
--
--   Then wire up the helpers in your job file's own hook functions:
--
--       function job_precast(spell, spellMap, eventArgs)
--           smart_caster_precast(spell, spellMap, eventArgs)
--           -- ... rest of your precast logic ...
--       end
--
--       function job_aftercast(spell, spellMap, eventArgs)
--           try_sublimation()
--           -- ... rest of your aftercast logic ...
--       end
--
--       function job_buff_change(buff, gain)
--           smart_caster_buff_change(buff, gain)
--           -- ... rest of your buff_change logic ...
--       end
--
-- NOTE: Do NOT define job_precast / job_aftercast / job_buff_change inside
--       this file — doing so would silently overwrite your job file's versions.
--       Call the helper functions from your job file instead (as shown above).
-------------------------------------------------------------------------------------------------------------------

local LATENCY             = 0.1   -- seconds; recast must be below this to fire
local SUBLIMATION_INTERVAL = 5    -- seconds between sublimation re-checks
local sublimation_last_check = 0

-------------------------------------------------------------------------------------------------------------------
-- STRING HELPERS
-------------------------------------------------------------------------------------------------------------------
-- Safe startswith that won't error on nil strings
function string.startswith(str, prefix)
    return str and str:sub(1, #prefix) == prefix
end

-------------------------------------------------------------------------------------------------------------------
-- SCH HELPERS
-------------------------------------------------------------------------------------------------------------------
-- Returns 'light', 'dark', or 'none' depending on active Arts buff
function get_current_arts()
    if buffactive['Light Arts'] or buffactive['Addendum: White'] then
        return 'light'
    elseif buffactive['Dark Arts'] or buffactive['Addendum: Black'] then
        return 'dark'
    end
    return 'none'
end

-------------------------------------------------------------------------------------------------------------------
-- WEATHER CHECK
-- Returns true if the given element's weather or self-cast storm is active
-------------------------------------------------------------------------------------------------------------------
function has_weather(element)
    if world.weather_element == element then return true end

    local storms = {
        Fire      = 'Firestorm',
        Ice       = 'Hailstorm',
        Wind      = 'Windstorm',
        Earth     = 'Sandstorm',
        Lightning = 'Thunderstorm',
        Water     = 'Rainstorm',
        Light     = 'Aurorastorm',
        Dark      = 'Voidstorm',
    }

    return storms[element] and buffactive[storms[element]] or false
end

-------------------------------------------------------------------------------------------------------------------
-- SPELL AVAILABLE CHECK
-- Looks up a spell by name in res.spells and checks its recast timer
-------------------------------------------------------------------------------------------------------------------
function spell_available(name)
    local spell = res.spells:with('en', name)
    if not spell then return false end

    local recasts = windower.ffxi.get_spell_recasts()
    if not recasts then return false end

    return recasts[spell.recast_id] ~= nil and recasts[spell.recast_id] < LATENCY
end

-------------------------------------------------------------------------------------------------------------------
-- BLACK ENFEEBLING SPELLS (used to gate Manifestation)
-------------------------------------------------------------------------------------------------------------------
local black_enfeebles = {
    Poison=true, ['Poison II']=true, Poisonga=true, ['Poisonga II']=true,
    Bio=true, ['Bio II']=true, ['Bio III']=true,
    Blind=true, ['Blind II']=true,
    Burn=true, Choke=true, Shock=true, Drown=true, Rasp=true, Frost=true,
    Distract=true, ['Distract II']=true, ['Distract III']=true,
    Frazzle=true, ['Frazzle II']=true, ['Frazzle III']=true,
    Bind=true, Break=true, Breakga=true,
    Sleep=true, ['Sleep II']=true, Sleepga=true, ['Sleepga II']=true,
}

-------------------------------------------------------------------------------------------------------------------
-- CROWD CONTROL SPELLS
-- These must cast immediately — never prep weather first
-------------------------------------------------------------------------------------------------------------------
local crowd_control_spells = {
    Sleep=true, ['Sleep II']=true, Sleepga=true, ['Sleepga II']=true,
    Repose=true, Break=true, Breakga=true,
    Bind=true, Gravity=true, ['Gravity II']=true,
}

-------------------------------------------------------------------------------------------------------------------
-- SMART CASTER PRECAST
-- Call this at the top of your job file's job_precast().
-- Handles automatic ability usage before magic spells:
--   SCH: Auto-Arts, Aurorastorm, Celerity, Accession, Manifestation, Klimaform, Elemental Storms
--   WHM: Afflatus Solace / Misery
--   RDM: Composure
-------------------------------------------------------------------------------------------------------------------
function smart_caster_precast(spell, spellMap, eventArgs)
    if not spell or spell.action_type ~= 'Magic' then return end

    local abil_recasts = windower.ffxi.get_ability_recasts() or {}
    local arts         = get_current_arts()
    local is_sch_main  = player.main_job == 'SCH'
    local is_sch_sub   = player.sub_job  == 'SCH'
    local is_whm_main  = player.main_job == 'WHM'
    local is_rdm_main  = player.main_job == 'RDM'
    local target       = spell.target.raw or '<t>'

    -- Skip if a fast-cast stratagem is already running
    if buffactive['Alacrity'] or buffactive['Celerity'] then return end

    -------------------------------------------------------------------------------------------------------------------
    -- SCH: AUTO-ARTS
    -- Activates Light/Dark Arts if the wrong (or no) arts are up.
    -- FIX: Corrected ability recast IDs.
    --   Light Arts main=228, sub=230  |  Dark Arts main=229, sub=231
    -------------------------------------------------------------------------------------------------------------------
    if is_sch_main or is_sch_sub then
        local light_id = is_sch_main and 228 or 230  -- FIX: was 257
        local dark_id  = is_sch_main and 229 or 231  -- FIX: was 258

        if spell.skill == 'Black Magic' and arts ~= 'dark'
            and abil_recasts[dark_id] and abil_recasts[dark_id] < LATENCY then
            cancel_spell()
            send_command('input /ja "Dark Arts" <me>;wait 1.2;input /ma "'..spell.english..'" '..target)
            eventArgs.cancel = true
            return

        elseif spell.skill == 'White Magic' and arts ~= 'light'
            and abil_recasts[light_id] and abil_recasts[light_id] < LATENCY then
            cancel_spell()
            send_command('input /ja "Light Arts" <me>;wait 1.2;input /ma "'..spell.english..'" '..target)
            eventArgs.cancel = true
            return
        end
    end

    -------------------------------------------------------------------------------------------------------------------
    -- WHM: AFFLATUS SOLACE (single-target Cure spells)
    -- Ability recast ID 29 — unchanged, was already correct
    -------------------------------------------------------------------------------------------------------------------
    if is_whm_main
        and spell.skill == 'Healing Magic'
        and spell.english:startswith('Cure')
        and not spell.english:match('Curaga')
        and not buffactive['Afflatus Solace']
        and abil_recasts[29] and abil_recasts[29] < LATENCY then

        cancel_spell()
        send_command('input /ja "Afflatus Solace" <me>;wait 1.2;input /ma "'..spell.english..'" '..target)
        eventArgs.cancel = true
        return
    end

    -------------------------------------------------------------------------------------------------------------------
    -- WHM: AFFLATUS MISERY (Divine Magic and Esuna)
    -- Ability recast ID 30 — unchanged, was already correct
    -------------------------------------------------------------------------------------------------------------------
    if is_whm_main
        and (spell.skill == 'Divine Magic' or spell.english == 'Esuna')
        and not buffactive['Afflatus Misery']
        and abil_recasts[30] and abil_recasts[30] < LATENCY then

        cancel_spell()
        send_command('input /ja "Afflatus Misery" <me>;wait 1.2;input /ma "'..spell.english..'" '..target)
        eventArgs.cancel = true
        return
    end

    -------------------------------------------------------------------------------------------------------------------
    -- RDM: COMPOSURE (Enhancing Magic — keep it up)
    -- Ability recast ID 50 — unchanged, was already correct
    -------------------------------------------------------------------------------------------------------------------
    if is_rdm_main
        and spell.skill == 'Enhancing Magic'
        and not buffactive['Composure']
        and abil_recasts[50] and abil_recasts[50] < LATENCY then

        cancel_spell()
        send_command('input /ja "Composure" <me>;wait 1.2;input /ma "'..spell.english..'" '..target)
        eventArgs.cancel = true
        return
    end

    -------------------------------------------------------------------------------------------------------------------
    -- SCH: AURORASTORM REMINDER (Cure/Cure II in Light Arts)
    -- [FIX]: Used to cancel the cast, fire Aurorastorm, then reschedule the actual Cure/Cure II
    -- ~1.2s later -- fragile, since any interruption along that chain meant the real heal never
    -- landed. Per direct instruction: a party member's health always comes before weather, no
    -- exceptions. This is now reminder-only, same treatment as the Curaga case below -- the
    -- Cure/Cure II cast is NEVER cancelled or delayed, no matter what. If Aurorastorm's down,
    -- you get a heads-up in chat and the heal goes out immediately regardless.
    -------------------------------------------------------------------------------------------------------------------
    if (is_sch_main or is_sch_sub)
        and (spell.english == 'Cure' or spell.english == 'Cure II')
        and arts == 'light'
        and not has_weather('Light') then
        add_to_chat(167, 'Aurorastorm is down')
    end

    -------------------------------------------------------------------------------------------------------------------
    -- SCH: ACCESSION (status removal spells in Light Arts — make them AoE)
    -- FIX: Corrected ability recast ID 216 (was 245)
    -------------------------------------------------------------------------------------------------------------------
    if (is_sch_main or is_sch_sub)
        and spell.skill == 'Healing Magic'
        and arts == 'light'
        and not buffactive['Accession']
        and abil_recasts[216] and abil_recasts[216] < LATENCY then  -- FIX: was 245

        local accession_spells = {
            Poisona=true, Paralyna=true, Blindna=true,
            Silena=true,  Cursna=true,  Viruna=true,
            Stona=true,   Erase=true,
        }

        if accession_spells[spell.english] then
            cancel_spell()
            send_command('input /ja "Accession" <me>;wait 1.2;input /ma "'..spell.english..'" '..target)
            eventArgs.cancel = true
            return
        end
    end

    -------------------------------------------------------------------------------------------------------------------
    -- SCH: CELERITY (Cure spells in Light Arts — fast cast)
    -- FIX: Corrected ability recast ID 214 (was 244)
    -------------------------------------------------------------------------------------------------------------------
    if (is_sch_main or is_sch_sub)
        and spell.skill == 'Healing Magic'
        and spell.english:startswith('Cure')
        and arts == 'light'
        and abil_recasts[214] and abil_recasts[214] < LATENCY then  -- FIX: was 244

        cancel_spell()
        send_command('input /ja "Celerity" <me>;wait 1.2;input /ma "'..spell.english..'" '..target)
        eventArgs.cancel = true
        return
    end

    -------------------------------------------------------------------------------------------------------------------
    -- SCH: MANIFESTATION (black enfeebling in Dark Arts — make them AoE)
    -- FIX: Corrected ability recast ID 217 (was 246)
    -------------------------------------------------------------------------------------------------------------------
    if (is_sch_main or is_sch_sub)
        and spell.skill == 'Enfeebling Magic'
        and arts == 'dark'
        and black_enfeebles[spell.english]
        and not buffactive['Manifestation']
        and abil_recasts[217] and abil_recasts[217] < LATENCY then  -- FIX: was 246

        cancel_spell()
        send_command('input /ja "Manifestation" <me>;wait 1.2;input /ma "'..spell.english..'" '..target)
        eventArgs.cancel = true
        return
    end

    -------------------------------------------------------------------------------------------------------------------
    -- SCH: KLIMAFORM (Elemental Magic in Dark Arts when weather already matches)
    -- FIX: Klimaform is a Job Ability (/ja), not a spell (/ma).
    --      Was incorrectly using spell_available() and /ma.
    --      Fixed to use abil_recasts[222] and /ja.
    -------------------------------------------------------------------------------------------------------------------
    if spell.skill == 'Elemental Magic'
        and spell.element
        and (is_sch_main or is_sch_sub)
        and arts == 'dark'
        and has_weather(spell.element)
        and not buffactive['Klimaform']
        and abil_recasts[222] and abil_recasts[222] < LATENCY then  -- FIX: was spell_available('Klimaform')

        cancel_spell()
        send_command('input /ja "Klimaform" <me>;wait 1.2;input /ma "'..spell.english..'" '..target)  -- FIX: was /ma
        eventArgs.cancel = true
        return
    end

    -------------------------------------------------------------------------------------------------------------------
    -- SCH: ELEMENTAL STORMS (Elemental Magic — prep matching weather before nuking)
    -- Skips crowd-control spells; they need to land immediately.
    -- Only fires when HP >= 75% (risky to delay when low).
    -- [NEW] Only fires when NOT actively magic bursting — interrupting a burst chain to
    -- cast weather would tank burst timing/DPS. If MagicBurstMode isn't defined on the
    -- current job at all, treats that the same as "off" (safe default, no nil error).
    -------------------------------------------------------------------------------------------------------------------
    -- [FIX 2026-08-30] Was checking state.MagicBurstMode directly -- that state is retired,
    -- folded into CastingMode itself. is_magic_bursting() (Ullona-Globals.lua) already
    -- handles the "not defined on this job" safe-default case internally.
    local not_bursting = not is_magic_bursting()

    if spell.skill == 'Elemental Magic'
        and spell.element
        and (is_sch_main or is_sch_sub)
        and player.hpp >= 75
        and not_bursting
        and not has_weather(spell.element)
        and not crowd_control_spells[spell.english] then

        local storm = nil

        if is_sch_main then
            local storms = {
                Fire      = {'Firestorm II',   'Firestorm'},
                Ice       = {'Hailstorm II',   'Hailstorm'},
                Wind      = {'Windstorm II',   'Windstorm'},
                Earth     = {'Sandstorm II',   'Sandstorm'},
                Lightning = {'Thunderstorm II','Thunderstorm'},
                Water     = {'Rainstorm II',   'Rainstorm'},
                Light     = {'Aurorastorm II', 'Aurorastorm'},
                Dark      = {'Voidstorm II',   'Voidstorm'},
            }
            local list = storms[spell.element] or {}
            for _, s in ipairs(list) do
                if spell_available(s) then storm = s; break end
            end
        else
            local storms = {
                Fire='Firestorm', Ice='Hailstorm', Wind='Windstorm',
                Earth='Sandstorm', Lightning='Thunderstorm',
                Water='Rainstorm', Light='Aurorastorm', Dark='Voidstorm',
            }
            local s = storms[spell.element]
            if s and spell_available(s) then storm = s end
        end

        if storm then
            cancel_spell()
            send_command('input /ma "'..storm..'" <me>;wait 1.2;input /ma "'..spell.english..'" '..target)
            eventArgs.cancel = true
            return
        end
    end
end

-------------------------------------------------------------------------------------------------------------------
-- SMART STATUS REMOVAL (SmartNa)
-- Call via self-command: gs c smartna              -- prompts <st>, click who you mean
--                         gs c smartna <name>       -- explicit name, skips the prompt
--
-- Dispatch for this lives in Ullona-Globals.lua's user_self_command (nil-checked, so jobs
-- that never include('Smart-Caster.lua') just get a polite abort instead of an error).
--
-- RESOLUTION ORDER, per no-argument call:
--   1. Explicit name in cmdParams[2] -- always wins, skips the prompt entirely.
--   2. No name -- always <st>. Click who you mean, yourself included if you're the one who
--      needs curing.
--
-- [REVISED 2026-08-09] Used to have a self-shortcut (skip targeting if YOU had a real debuff
-- or Bar-spell hint) plus a <t>-if-not-a-monster fallback, mirroring handle_smartwaltz. Both
-- removed per direct instruction: the self-shortcut's Bar-hint half was the actual bug --
-- having e.g. Barblindra up on yourself (just a ward, not a real debuff) would silently
-- hijack the cast onto yourself even while trying to cure an ally's REAL Blindness, since it
-- ran before a target was ever considered. <t> resolution also proved troublesome enough in
-- practice to drop entirely rather than keep debugging. Simpler now: always <st> unless
-- named explicitly.
--
-- PRIORITY CHAIN (once a target is resolved via steps 1 or 2 above):
--   1. Mirror assumption: whatever YOU currently have (checked against self_status_cure_
--      priority) is assumed to also be on the target -- cast that matching spell. Nastier/
--      rarer conditions (Petrification, Doom, Amnesia, Charm, Terror) are checked ahead of
--      the everyday stuff (Poison, Silence, Paralysis, Blindness) since those are the ones
--      you'd want handled first if you somehow had two active at once.
--   2. Bar-status hint: no mirrored debuff on you, but you have a relevant Bar-spell up --
--      read as "I was expecting this," so it's used as the best guess. Includes Barwatera as
--      a deliberate Ulli-specific heuristic: cast ahead of an expected poison-water fight ->
--      treated the same as Barpoisonra for this purpose, since it's not the actual immunity
--      spell (Barpoisonra/Barpoison) but the same intent.
--   3. No mirror, no hint -- Cursna, the broadest catch-all.
--
-- [ASSUMPTION -- VERIFY AGAINST WIKI]: Cursna's exact cure list (Doom/Curse/Amnesia/Charm/
-- Terror/Plague routed here) is from memory, not re-checked against the wiki this session.
-- Worth a quick verification pass before relying on it in a real pull -- happy to adjust
-- the table if any of these turn out wrong.
--
-- [LIMITATION]: only YOUR OWN buffactive table is reliably readable here. There's no way
-- to ask Windower/GearSwap "what specific debuff is Ulli's party member under" -- only
-- whether they have some debuff icon at all. Steps 1 and 2 above are both inference from
-- your own state, not actual detection of the target -- that's a deliberate design choice
-- per your instruction, not a limitation being papered over. This means when <t> resolves to
-- an ally, you're still reading YOUR OWN buffs/hints to decide what to cast on them.
-------------------------------------------------------------------------------------------------------------------
local self_status_cure_priority = {
    {buff = 'Petrification', spell = 'Stona'},
    {buff = 'Doom',          spell = 'Cursna'},
    {buff = 'Curse',         spell = 'Cursna'},
    {buff = 'Curse II',      spell = 'Cursna'},
    {buff = 'Amnesia',       spell = 'Cursna'},
    {buff = 'Charm',         spell = 'Cursna'},
    {buff = 'Charm II',      spell = 'Cursna'},
    {buff = 'Terror',        spell = 'Cursna'},
    {buff = 'Plague',        spell = 'Cursna'},
    {buff = 'Silence',       spell = 'Silena'},
    {buff = 'Paralysis',     spell = 'Paralyna'},
    {buff = 'Blindness',     spell = 'Blindna'},
    {buff = 'Poison',        spell = 'Poisona'},
    {buff = 'Poison II',     spell = 'Poisona'},
    {buff = 'Virus',         spell = 'Viruna'},
}

-- Bar-status/Bar-element hint table -- used ONLY for the targeted branch, step 2, after the
-- mirror check above comes up empty. Barwatera included deliberately (poison-prep heuristic,
-- not the real Bar-poison spell) per direct instruction -- not a mix-up.
local bar_status_hint_priority = {
    {buff = 'Barparalyze',  spell = 'Paralyna'},
    {buff = 'Barparalyzra', spell = 'Paralyna'},
    {buff = 'Barpoison',    spell = 'Poisona'},
    {buff = 'Barpoisonra',  spell = 'Poisona'},
    {buff = 'Barwatera',    spell = 'Poisona'},  -- Ulli's poison-prep heuristic, not the real bar-poison spell
    {buff = 'Barblind',     spell = 'Blindna'},
    {buff = 'Barblindra',   spell = 'Blindna'},
    {buff = 'Barsilence',   spell = 'Silena'},
    {buff = 'Barsilencera', spell = 'Silena'},
    {buff = 'Barvirus',     spell = 'Viruna'},
    {buff = 'Barvira',      spell = 'Viruna'},
    {buff = 'Barpetrify',   spell = 'Stona'},
    {buff = 'Barpetra',     spell = 'Stona'},
}

-- Tries a spell on a given target, falling back to Cursna if the first choice is
-- unavailable (recast/unlocked). Returns true if something was cast, false if nothing was.
local function try_na_cast(spellName, target)
    if spell_available(spellName) then
        windower.chat.input('/ma "'..spellName..'" '..target)
        return true
    elseif spellName ~= 'Cursna' and spell_available('Cursna') then
        windower.chat.input('/ma "Cursna" '..target)
        return true
    end
    return false
end

function handle_smart_curena(cmdParams)
    local is_whm_main        = player.main_job == 'WHM'
    local is_rdm_main        = player.main_job == 'RDM'
    local is_sch_main_or_sub = player.main_job == 'SCH' or player.sub_job == 'SCH'

    if not (is_whm_main or is_rdm_main or is_sch_main_or_sub) then
        add_to_chat(123, 'Abort: SmartNa needs WHM/RDM main or SCH main/sub for -na spell access.')
        return
    end

    -- [REVISED 2026-08-09] Simplified to always <st> per direct instruction -- both the
    -- self-shortcut and the <t> resolution are gone now.
    --
    -- The self-shortcut turned out to be the real bug: it checked YOUR OWN Bar-spell hints
    -- before ever considering a target, so having e.g. Barblindra up on yourself (just a
    -- ward, not an actual debuff) would hijack the cast onto yourself even when you were
    -- trying to cure an ally's REAL Blindness. Bar-hints were only ever meant as a guess for
    -- an ally's condition (see PRIORITY CHAIN below) -- they should never trigger a self-cast
    -- on their own. <t> resolution is also gone -- proved troublesome enough in practice
    -- (per direct instruction) that it's not worth keeping even with the monster-type guard.
    --
    -- Net result: no name given -> always <st>, click who you mean (yourself included, if
    -- you're the one who actually needs curing). Only an explicit name skips the prompt.
    local target
    if cmdParams[2] then
        target = table.concat(cmdParams, ' ', 2)
    else
        target = '<st>'
    end

    -- Step 1: mirror -- assume the target has whatever YOU currently have.
    for _, entry in ipairs(self_status_cure_priority) do
        if buffactive[entry.buff] then
            if not try_na_cast(entry.spell, target) then
                add_to_chat(123, 'SmartNa: '..entry.spell..' unavailable for '..entry.buff..' (recast/unlocked).')
            end
            return
        end
    end

    -- Step 2: no mirrored debuff -- fall back to a Bar-spell hint if one's up.
    for _, entry in ipairs(bar_status_hint_priority) do
        if buffactive[entry.buff] then
            if not try_na_cast(entry.spell, target) then
                add_to_chat(123, 'SmartNa: no available -na spell for the '..entry.buff..' hint.')
            end
            return
        end
    end

    -- Step 3: no mirror, no hint -- Cursna, the broadest catch-all.
    if spell_available('Cursna') then
        windower.chat.input('/ma "Cursna" '..target)
    else
        add_to_chat(123, 'Abort: Cursna unavailable (recast/unlocked).')
    end
end

-------------------------------------------------------------------------------------------------------------------
-- SUBLIMATION AUTOMATION
-- Automatically re-activates Sublimation when the buff drops.
-- Call this from your job file's job_aftercast() and job_buff_change().
-- Only fires for SCH main or sub.
-- Will not fire if: Sublimation is already active, Refresh III is up,
--                   player is mid-action, or Amnesia is active.
-- FIX: Corrected ability recast ID 96 (was 36, which is a completely different ability)
-------------------------------------------------------------------------------------------------------------------
function try_sublimation()
    if player.main_job ~= 'SCH' and player.sub_job ~= 'SCH' then return end

    local now = os.time()
    if now < sublimation_last_check then return end
    sublimation_last_check = now + SUBLIMATION_INTERVAL

    -- Already active — nothing to do
    if buffactive['Sublimation: Activated'] or buffactive['Sublimation: Complete'] then return end

    -- Refresh III is better for MP recovery — don't waste the slot
    if buffactive['Refresh III'] then return end

    -- Don't interrupt casts or fire while silenced/amnesia'd
    if midaction() or buffactive['Amnesia'] or buffactive['Silence'] then return end

    local abil_recasts = windower.ffxi.get_ability_recasts()
    if not abil_recasts then return end

    -- FIX: Sublimation ability recast ID is 96, not 36
    if abil_recasts[96] and abil_recasts[96] < LATENCY then
        send_command('input /ja "Sublimation" <me>')
    end
end

-------------------------------------------------------------------------------------------------------------------
-- BUFF CHANGE HELPER
-- Call this from your job file's job_buff_change() to react to Sublimation falling off.
--
-- Example in your job file:
--   function job_buff_change(buff, gain)
--       smart_caster_buff_change(buff, gain)
--       -- ... rest of your buff_change logic ...
--   end
-------------------------------------------------------------------------------------------------------------------
function smart_caster_buff_change(buff, gain)
    if buff == 'Sublimation: Activated' or buff == 'Sublimation: Complete' then
        try_sublimation()
    end
end

-------------------------------------------------------------------------------------------------------------------
-- !! IMPORTANT — DO NOT ADD job_precast / job_aftercast / job_buff_change HERE !!
--
-- This is an include file. Defining GearSwap hook functions here would silently
-- overwrite the same functions in your job file (Lua last-definition wins).
-- Instead, call the helpers above from your job file's own hook functions.
-------------------------------------------------------------------------------------------------------------------
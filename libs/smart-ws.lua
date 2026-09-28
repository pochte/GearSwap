-- =============================================================================
-- smart-ws.lua — Changelog
-- 2026-09-27: [NEW] Extracted out of RDM.lua's handle_autows(), which hardcoded RDM's
--             three weapons inline. Standalone and job-agnostic now -- any job's gear file
--             can include('smart-ws.lua') and define its own ws_by_main_weapon /
--             ws_by_main_weapon_default tables to opt in; nothing here needs editing per
--             job. A job's job_self_command still needs its own stub wired to call
--             handle_autows() -- that hook has to live in the job .lua file itself, it
--             can't be supplied from an include (job_self_command gets overwritten/ignored
--             if defined anywhere else). See RDM.lua's 'castws' branch, tagged "THIS PART
--             HANDLES SMART WS FILE. ADD TO OTHER FILES LATER" for the pattern to copy.
-- =============================================================================

-- WEAPON-MODE WEAPONSKILL: gs c castws -- fires the WS matching state.MainWeapon's current
-- value, via the ws_by_main_weapon lookup table (and ws_by_main_weapon_default fallback)
-- that the including job's own gear file defines. Falls back to 'Savage Blade' if a job's
-- gear file forgets to define even a default, rather than erroring outright.
function handle_autows(cmdParams)
    local ws_name = ws_by_main_weapon and ws_by_main_weapon[state.MainWeapon.value]
    ws_name = ws_name or ws_by_main_weapon_default or 'Savage Blade'

    windower.chat.input('/ws "'..ws_name..'" <t>')
end

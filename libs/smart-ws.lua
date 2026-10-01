  
-- smart-ws.lua — Changelog
-- WEAPON-MODE WEAPONSKILL: gs c castws -- fires the WS matching state.MainWeapon's current
-- value, via the ws_by_main_weapon lookup table (and ws_by_main_weapon_default fallback)
-- that the including job's own gear file defines. Falls back to 'Savage Blade' if a job's
-- gear file forgets to define even a default, rather than erroring outright.
function handle_autows(cmdParams)
    local ws_name = ws_by_main_weapon and ws_by_main_weapon[state.MainWeapon.value]
    ws_name = ws_name or ws_by_main_weapon_default or 'Savage Blade'

    windower.chat.input('/ws "'..ws_name..'" <t>')
end

-- =============================================================================
-- SoulDevour.lua
-- =============================================================================
-- Purpose:
-- Wake yourself from Sleep / Sleep II / Lullaby by equipping a Tier 1 or Tier 2
-- Prime weapon with the Soul Devour effect.
--
-- Tier 2 is always preferred over Tier 1.
--
-- USAGE:
--     include('SoulDevour.lua')
-- =============================================================================

-- Required resources for item ID lookup
local res = require('resources')

-- =============================================================================
-- SOUL DEVOUR WEAPONS
-- =============================================================================

soul_devour_weapons = {
    MNK = {{tier1 = "Prime Fists",     tier2 = "Varga Purnikawa", slot = "main"}},
    PUP = {{tier1 = "Prime Fists",     tier2 = "Varga Purnikawa", slot = "main"}},
    RDM = {
        {tier1 = "Prime Dagger",    tier2 = "Mpu Gandring",  slot = "main"},
        {tier1 = "Prime Sword",     tier2 = "Caliburnus",    slot = "main"},
    },
    THF = {{tier1 = "Prime Dagger",    tier2 = "Mpu Gandring",  slot = "main"}},
    DNC = {{tier1 = "Prime Dagger",    tier2 = "Mpu Gandring",  slot = "main"}},
    BRD = {
        {tier1 = "Prime Dagger",    tier2 = "Mpu Gandring",  slot = "main"},
        {tier1 = "Prime Horn",      tier2 = "Loughnashade",  slot = "range"},
    },
    PLD = {
        {tier1 = "Prime Sword",     tier2 = "Caliburnus",    slot = "main"},
        {tier1 = "Prime Blade",     tier2 = "Helheim",       slot = "main"},
        {tier1 = "Prime Shield",    tier2 = "Duban",         slot = "sub"},
    },
    BLU = {{tier1 = "Prime Sword",     tier2 = "Caliburnus",    slot = "main"}},
    WAR = {
        {tier1 = "Prime Blade",     tier2 = "Helheim",       slot = "main"},
        {tier1 = "Prime Great Axe", tier2 = "Laphria",       slot = "main"},
    },
    DRK = {
        {tier1 = "Prime Blade",     tier2 = "Helheim",       slot = "main"},
        {tier1 = "Prime Scythe",    tier2 = "Foenaria",      slot = "main"},
    },
    RUN = {{tier1 = "Prime Blade",     tier2 = "Helheim",       slot = "main"}},
    BST = {{tier1 = "Prime Pickaxe",   tier2 = "Spalirisos",    slot = "main"}},
    DRG = {{tier1 = "Prime Lance",     tier2 = "Gae Buide",      slot = "main"}},
    NIN = {{tier1 = "Genshitanto",     tier2 = "Dokoku",        slot = "main"}},
    SAM = {{tier1 = "Genshito",        tier2 = "Kusanagi",      slot = "main"}},
    WHM = {{tier1 = "Prime Maul",      tier2 = "Lorg Mor",      slot = "main"}},
    GEO = {{tier1 = "Prime Maul",      tier2 = "Lorg Mor",      slot = "main"}},
    BLM = {{tier1 = "Prime Staff",     tier2 = "Opashoro",      slot = "main"}},
    SMN = {{tier1 = "Prime Staff",     tier2 = "Opashoro",      slot = "main"}},
    SCH = {{tier1 = "Prime Staff",     tier2 = "Opashoro",      slot = "main"}},
    COR = {{tier1 = "Prime Gun",       tier2 = "Earp",          slot = "range"}},
    RNG = {
        {tier1 = "Prime Bow",       tier2 = "Pinaka",        slot = "range"},
        {tier1 = "Prime Gun",       tier2 = "Earp",          slot = "range"},
    },
}

-- =============================================================================
-- BAGS TO SEARCH
-- =============================================================================

local SOUL_DEVOUR_BAGS = {"inventory", "safe", "safe2", "storage", "temporary", "locker", "satchel", "sack", "case", 
                          "wardrobe", "wardrobe2", "wardrobe3", "wardrobe4", "wardrobe5", "wardrobe6", "wardrobe7", "wardrobe8"}

-- =============================================================================
-- STATE
-- =============================================================================

local soul_devour_disabled_slot = nil

-- =============================================================================
-- ITEM OWNERSHIP CHECK
-- =============================================================================

function soul_devour_owns_item(item_name)
    if not item_name then return false end

    local items = windower.ffxi.get_items()
    if not items then return false end

    -- NOTE: don't pre-resolve item_name -> a single id via res.items:with("en", ...).
    -- Empyrean weapons keep the same display name across every augment rank, but
    -- each rank is a *different* item id under the hood. Pre-resolving grabs
    -- whichever id the resource table happens to list first (usually Rank 1),
    -- which will never match a reforged copy. Instead, resolve each bag item's
    -- own name and compare strings.
    for _, bag_name in ipairs(SOUL_DEVOUR_BAGS) do
        local bag = items[bag_name]
        if bag then
            for _, item in pairs(bag) do
                if type(item) == "table" and item.id and (item.count or 0) > 0 then
                    local item_res = res.items[item.id]
                    if item_res and item_res.en == item_name then
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- =============================================================================
-- ITEM AVAILABILITY CHECK (bag OR already worn in the target slot)
-- =============================================================================
-- soul_devour_owns_item() only scans bags, so it misses the common case where
-- the Soul Devour weapon is already your equipped main/sub and you don't also
-- own a spare copy sitting in a bag. Check what's currently worn first.

function soul_devour_item_available(item_name, slot)
    if not item_name or not slot then return false end

    if player and player.equipment and player.equipment[slot] == item_name then
        return true
    end

    return soul_devour_owns_item(item_name)
end

-- =============================================================================
-- DEBUG (temporary — safe to leave in, only fires when nothing is found)
-- =============================================================================

function soul_devour_debug_scan(item_name)
    if not item_name then return end

    local item_res = res.items:with("en", item_name)
    if not item_res then
        add_to_chat(167, 'SOUL DEVOUR DEBUG: resource lookup FAILED for "' .. item_name .. '" (name mismatch)')
        return
    end

    add_to_chat(207, 'SOUL DEVOUR DEBUG: resource lookup OK for "' .. item_name .. '" id=' .. tostring(item_res.id))

    local items = windower.ffxi.get_items()
    if not items then
        add_to_chat(167, 'SOUL DEVOUR DEBUG: windower.ffxi.get_items() returned nothing')
        return
    end

    local found_any = false
    for bag_name, bag in pairs(items) do
        if type(bag) == "table" then
            for _, item in pairs(bag) do
                if type(item) == "table" and item.id == item_res.id then
                    found_any = true
                    add_to_chat(207, 'SOUL DEVOUR DEBUG: FOUND in bag "' .. tostring(bag_name) .. '" count=' .. tostring(item.count))
                end
            end
        end
    end

    if not found_any then
        add_to_chat(167, 'SOUL DEVOUR DEBUG: item exists in resources but was NOT found in any bag windower can see')
    end
end

-- =============================================================================
-- FIND SOUL DEVOUR WEAPON
-- =============================================================================

function get_soul_devour_gear()
    if not player or not player.main_job then return nil end
    local candidates = soul_devour_weapons[player.main_job]

    if not candidates then return nil end

    -- Priority 1: Check all Tier 2 weapons first
    for _, candidate in ipairs(candidates) do
        if soul_devour_item_available(candidate.tier2, candidate.slot) then
            return {
                slot = candidate.slot,
                item = candidate.tier2,
            }
        end
    end

    -- Priority 2: Fall back to Tier 1 weapons
    for _, candidate in ipairs(candidates) do
        if soul_devour_item_available(candidate.tier1, candidate.slot) then
            return {
                slot = candidate.slot,
                item = candidate.tier1,
            }
        end
    end
    
    return nil
end

-- =============================================================================
-- SLEEP HANDLER
-- =============================================================================

function soul_devour_buff_change(buff, gain)
    if type(buff) ~= "string" then return end

    local buff_lower = buff:lower()
    if buff_lower ~= "sleep" and buff_lower ~= "sleep ii" and buff_lower ~= "lullaby" then
        return
    end

    if gain then
        -- Cancel Stoneskin so tick damage registers
        if buffactive["Stoneskin"] then
            if not state.CancelStoneskin or state.CancelStoneskin.value then
                send_command('input /cancel "Stoneskin"')
            end
        end

        local gear = get_soul_devour_gear()
        if gear then
            -- 1. Equip item FIRST
            local eq = {}
            eq[gear.slot] = gear.item
            equip(eq)

            -- 2. Lock the slot AFTER equipping
            if soul_devour_disabled_slot ~= gear.slot then
                disable(gear.slot)
                soul_devour_disabled_slot = gear.slot
            end

            add_to_chat(207, 'Soul Devour: equipped ' .. gear.item .. ' to break Sleep.')
        else
            add_to_chat(167, 'ERROR: Soul Devour found NOTHING. Time to nap on ' .. tostring(player.main_job) .. '!')

            -- Temporary: auto-diagnose why, per candidate, for this job
            local candidates = player and player.main_job and soul_devour_weapons[player.main_job]
            if candidates then
                for _, candidate in ipairs(candidates) do
                    soul_devour_debug_scan(candidate.tier2)
                    soul_devour_debug_scan(candidate.tier1)
                end
            end
        end
    else
        -- Unlock slot when sleep expires
        if soul_devour_disabled_slot then
            enable(soul_devour_disabled_slot)
            soul_devour_disabled_slot = nil
        end
        if type(handle_equipping_gear) == 'function' then
            handle_equipping_gear(player.status)
        end
    end
end

-- =============================================================================
-- SELF-REGISTRATION
-- =============================================================================

windower.register_event('gain buff', function(buff_id)
    local buff_res = res.buffs[buff_id]
    if buff_res then
        soul_devour_buff_change(buff_res.english, true)
    end
end)

windower.register_event('lose buff', function(buff_id)
    local buff_res = res.buffs[buff_id]
    if buff_res then
        soul_devour_buff_change(buff_res.english, false)
    end
end)

-- =============================================================================
-- MANUAL TEST HOOK (temporary — lets you trigger this without getting slept)
-- =============================================================================
-- Usage:
--   //gearswap souldevourtest       -> simulates gaining Sleep
--   //gearswap souldevourtestend    -> simulates Sleep wearing off (restores gear)

windower.register_event('addon command', function(...)
    local args = {...}
    local cmd = args[1] and args[1]:lower()

    if cmd == 'souldevourtest' then
        add_to_chat(207, 'Soul Devour: MANUAL TEST — simulating Sleep gain.')
        soul_devour_buff_change('Sleep', true)
    elseif cmd == 'souldevourtestend' then
        add_to_chat(207, 'Soul Devour: MANUAL TEST — simulating Sleep loss.')
        soul_devour_buff_change('Sleep', false)
    elseif cmd == 'souldevourdump' then
        local bag_name = args[2] or 'inventory'
        local items = windower.ffxi.get_items()
        local bag = items and items[bag_name]
        if not bag then
            add_to_chat(167, 'SOUL DEVOUR DUMP: no such bag "' .. tostring(bag_name) .. '"')
        else
            add_to_chat(207, 'SOUL DEVOUR DUMP: raw contents of "' .. bag_name .. '"')
            for slot_idx, item in pairs(bag) do
                if type(item) == "table" and item.id and (item.count or 0) > 0 then
                    local known = res.items[item.id]
                    local known_name = known and known.en or "??unknown to resources??"
                    add_to_chat(207, '  slot ' .. tostring(slot_idx) .. ': id=' .. tostring(item.id) .. ' -> "' .. known_name .. '"')
                end
            end
        end
    end
end)
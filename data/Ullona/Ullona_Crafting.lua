--[[
    Ullona-Crafting.lua

    Command-driven crafting and gathering equipment.

    Commands:
        gs c craft cook
        gs c craft wood
        gs c craft fishing
        gs c craft mine
        gs c craft harvest
        gs c craft log
        gs c craft dig
        gs c craft chocobo
        gs c craft off

    Add this file with:
        include('Ullona-Crafting.lua')

    IMPORTANT:
    This file defines craft_self_command(), but does not replace
    user_self_command(). Add the small dispatcher shown below to your
    existing user_self_command() function:

        if craft_self_command(cmdParams, eventArgs) then
            return
        end

    Put that near the beginning of user_self_command(), after any
    cmdParams/eventArgs nil guards.

    Empty placeholder sets intentionally equip nothing. The selected
    set's slots are still locked, so your current equipment stays put
    until you add gear to that set or use "gs c craft off".
]]

-- Ensure the parent set tables exist.
sets.Crafting = sets.Crafting or {}
sets.Gathering = sets.Gathering or {}

-----------------------------------------------------------------------
-- CRAFTING SETS
-- Add equipment as you acquire it. Unlisted slots are left untouched.
-----------------------------------------------------------------------

-- Alchemy
sets.Crafting.Alchemy = {
    -- main = "",
    -- sub = "",
    -- range = "",
    -- ammo = "",
    -- head = "",
    -- neck = "",
    -- ear1 = "",
    -- ear2 = "",
    -- body = "",
    -- hands = "",
    -- ring1 = "",
    -- ring2 = "",
    -- back = "",
    -- waist = "",
    -- legs = "",
    -- feet = "",
}

-- Bonecraft
sets.Crafting.Bonecraft = {
    -- main = "",
    -- sub = "",
    -- range = "",
    -- ammo = "",
    -- head = "",
    -- neck = "",
    -- ear1 = "",
    -- ear2 = "",
    -- body = "",
    -- hands = "",
    -- ring1 = "",
    -- ring2 = "",
    -- back = "",
    -- waist = "",
    -- legs = "",
    -- feet = "",
}

-- Clothcraft
sets.Crafting.Clothcraft = {
    -- main = "",
    -- sub = "",
    -- range = "",
    -- ammo = "",
    -- head = "",
    -- neck = "",
    -- ear1 = "",
    -- ear2 = "",
    -- body = "",
    -- hands = "",
    -- ring1 = "",
    -- ring2 = "",
    -- back = "",
    -- waist = "",
    -- legs = "",
    -- feet = "",
}

-- Cooking / Culinarian
sets.Crafting.Culinarian = {
    main = "Debahocho +1",
    head = "Chef's Hat",
    body = "Culinarian's Apron",
    -- sub = "",
    -- range = "",
    -- ammo = "",
    -- neck = "",
    -- ear1 = "",
    -- ear2 = "",
    -- hands = "",
    -- back = "",
    -- waist = "",
    -- legs = "",
    -- feet = "",
    -- Rings are deliberately omitted so you can choose your crafter rings.
}

-- Goldsmithing
sets.Crafting.Goldsmithing = {
    -- main = "",
    -- sub = "",
    -- range = "",
    -- ammo = "",
    -- head = "",
    -- neck = "",
    -- ear1 = "",
    -- ear2 = "",
    -- body = "",
    -- hands = "",
    -- ring1 = "",
    -- ring2 = "",
    -- back = "",
    -- waist = "",
    -- legs = "",
    -- feet = "",
}

-- Leathercraft
sets.Crafting.Leathercraft = {
    -- main = "",
    -- sub = "",
    -- range = "",
    -- ammo = "",
    -- head = "",
    -- neck = "",
    -- ear1 = "",
    -- ear2 = "",
    -- body = "",
    -- hands = "",
    -- ring1 = "",
    -- ring2 = "",
    -- back = "",
    -- waist = "",
    -- legs = "",
    -- feet = "",
}

-- Smithing
sets.Crafting.Smithing = {
    -- main = "",
    -- sub = "",
    -- range = "",
    -- ammo = "",
    -- head = "",
    -- neck = "",
    -- ear1 = "",
    -- ear2 = "",
    -- body = "",
    -- hands = "",
    -- ring1 = "",
    -- ring2 = "",
    -- back = "",
    -- waist = "",
    -- legs = "",
    -- feet = "",
}

-- Woodworking
sets.Crafting.Woodworking = {
    hands = "Carpenter's Gloves",
    -- main = "",
    -- sub = "",
    -- range = "",
    -- ammo = "",
    -- head = "",
    -- neck = "",
    -- ear1 = "",
    -- ear2 = "",
    -- body = "",
    -- ring1 = "",
    -- ring2 = "",
    -- back = "",
    -- waist = "",
    -- legs = "",
    -- feet = "",
}

-----------------------------------------------------------------------
-- GATHERING SETS
-----------------------------------------------------------------------

-- Fishing: full set from your original list, with Lu Shang's Fishing Rod.
-- Ring slots are intentionally omitted.
sets.Gathering.Fishing = {
    main = "Lu Shang's Fishing Rod",
    neck = "Fisher's Torque",
    body = "Fisherman's Smock",
    hands = "Fsh. Gloves",
    waist = "Fisherman's Rope",
    legs = "Fisherman's Hose",
    feet = "Waders",
}

sets.Gathering.Mining = {
    -- main = "",
    -- sub = "",
    -- range = "",
    -- ammo = "",
    -- head = "",
    -- neck = "",
    -- ear1 = "",
    -- ear2 = "",
    -- body = "",
    -- hands = "",
    -- ring1 = "",
    -- ring2 = "",
    -- back = "",
    -- waist = "",
    -- legs = "",
    -- feet = "",
}

sets.Gathering.Harvesting = {
    -- main = "",
    -- sub = "",
    -- range = "",
    -- ammo = "",
    -- head = "",
    -- neck = "",
    -- ear1 = "",
    -- ear2 = "",
    -- body = "",
    -- hands = "",
    -- ring1 = "",
    -- ring2 = "",
    -- back = "",
    -- waist = "",
    -- legs = "",
    -- feet = "",
}

sets.Gathering.Logging = {
    -- main = "",
    -- sub = "",
    -- range = "",
    -- ammo = "",
    -- head = "",
    -- neck = "",
    -- ear1 = "",
    -- ear2 = "",
    -- body = "",
    -- hands = "",
    -- ring1 = "",
    -- ring2 = "",
    -- back = "",
    -- waist = "",
    -- legs = "",
    -- feet = "",
}

sets.Gathering.Digging = {
    -- main = "",
    -- sub = "",
    -- range = "",
    -- ammo = "",
    -- head = "",
    -- neck = "",
    -- ear1 = "",
    -- ear2 = "",
    -- body = "",
    -- hands = "",
    -- ring1 = "",
    -- ring2 = "",
    -- back = "",
    -- waist = "",
    -- legs = "",
    -- feet = "",
}

sets.Gathering.Chocobo = {
    -- main = "",
    -- sub = "",
    -- range = "",
    -- ammo = "",
    -- head = "",
    -- neck = "",
    -- ear1 = "",
    -- ear2 = "",
    -- body = "",
    -- hands = "",
    -- ring1 = "",
    -- ring2 = "",
    -- back = "",
    -- waist = "",
    -- legs = "",
    -- feet = "",
}

-----------------------------------------------------------------------
-- COMMAND DISPATCH
-----------------------------------------------------------------------

local craft_lock_slots = {
    'main', 'sub', 'range', 'ammo',
    'head', 'neck', 'ear1', 'ear2',
    'body', 'hands', 'ring1', 'ring2',
    'back', 'waist', 'legs', 'feet',
}

local craft_commands = {
    -- Crafting aliases
    cook       = sets.Crafting.Culinarian,
    cooking    = sets.Crafting.Culinarian,
    culinarian = sets.Crafting.Culinarian,

    alchemy    = sets.Crafting.Alchemy,
    bone       = sets.Crafting.Bonecraft,
    bonecraft  = sets.Crafting.Bonecraft,
    cloth      = sets.Crafting.Clothcraft,
    clothcraft = sets.Crafting.Clothcraft,
    gold       = sets.Crafting.Goldsmithing,
    goldsmith  = sets.Crafting.Goldsmithing,
    goldsmithing = sets.Crafting.Goldsmithing,
    leather    = sets.Crafting.Leathercraft,
    leathercraft = sets.Crafting.Leathercraft,
    smith      = sets.Crafting.Smithing,
    smithing   = sets.Crafting.Smithing,
    wood       = sets.Crafting.Woodworking,
    woodworking = sets.Crafting.Woodworking,

    -- Gathering aliases
    fishing    = sets.Gathering.Fishing,
    fish       = sets.Gathering.Fishing,
    mine       = sets.Gathering.Mining,
    mining     = sets.Gathering.Mining,
    harvest    = sets.Gathering.Harvesting,
    harvesting = sets.Gathering.Harvesting,
    log        = sets.Gathering.Logging,
    logging    = sets.Gathering.Logging,
    dig        = sets.Gathering.Digging,
    digging    = sets.Gathering.Digging,
    chocobo    = sets.Gathering.Chocobo,
}

local function craft_chat(message)
    if windower and windower.add_to_chat then
        windower.add_to_chat(207, '[Crafting] ' .. message)
    end
end

function craft_self_command(cmdParams, eventArgs)
    if not cmdParams or string.lower(tostring(cmdParams[1] or '')) ~= 'craft' then
        return false
    end

    local selection = string.lower(tostring(cmdParams[2] or ''))

    if selection == 'off' or selection == 'unlock' or selection == 'normal' then
        enable(unpack(craft_lock_slots))
        craft_chat('Equipment slots unlocked.')
        return true
    end

    local selected_set = craft_commands[selection]
    if not selected_set then
        craft_chat('Unknown set. Use: craft cook/wood/alchemy/bone/cloth/gold/leather/smith/fishing/mine/harvest/log/dig/chocobo/off')
        return true
    end

    -- Clear any previous crafting/gathering lock before changing sets.
    enable(unpack(craft_lock_slots))

    -- Equip only the slots defined in this set.
    equip(selected_set)

    -- Lock every equipment slot, including both rings.
    disable(unpack(craft_lock_slots))

    craft_chat(selection .. ' set equipped; all equipment slots locked.')
    return true
end

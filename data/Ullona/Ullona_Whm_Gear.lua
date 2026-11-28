-- CHANGELOG
-- 2026-11-29: Fixed main/sub pairing (grips only on 2H, shields on 1H).
--             Fixed Weapons mode: MeleeWeapons now legal; added missing Melee* cure maps
--             so midcast no longer locks when Weapons ~= None.
-- 2026-11-28: Fixed Protect/Shell load order (moved below Enhancing Magic);
--             added Ebers Mitts +3 to StatusRemoval; swapped Embla Sash into
--             Enhancing Magic midcast; upgraded idle.PDT to use Daybreak/Genmei/Bunzi's.
-- 2026-11-19: Elite Royal Collar (San d'Oria citizen: Regen+3, DT-5%) now the neck in sets.idle / sets.idle.PDT (1 set(s)); replaces Null Loop there (Null Loop kept in all other sets).

--WHM_Gear.lua
function user_job_setup()
    state.OffenseMode:options('Normal','Acc')
    state.CastingMode:options('Normal','Resistant','SIRD','DT','MB','MB Resistant')
    state.IdleMode:options('Normal','PDT','MDT')
    state.PhysicalDefenseMode:options('PDT')
    state.MagicalDefenseMode:options('MDT')
    state.ResistDefenseMode:options('MEVA')
    -- 'None' = midcast free to swap staff+grip / club+shield
    -- 'MeleeWeapons' = lock Maxentius + shield (melee mode)
    state.Weapons:options('None','MeleeWeapons','DualWeapons')
    state.WeaponskillMode:options('Normal','Fodder')

    -- Force Macro Book 1 / Page 1
    set_macro_page(1, 1)

    -- Additional local binds
    send_command('bind != input /ja "Penury" <me>')                  -- Alt + =
    send_command('bind ^@!` gs c toggle AutoCaress')                 -- Ctrl + Win + Alt + `
    send_command('bind ^backspace input /ja "Sacrosanctity" <me>')   -- Ctrl + Backspace
    send_command('bind @backspace input /ma "Aurorastorm" <me>')     -- Win + Backspace
    send_command('bind !pause gs c toggle AutoSubMode')              -- Alt + Pause
    send_command('bind ^a gs c barelement')                          -- Ctrl + A
    send_command('bind !a gs c barstatus')                           -- Alt + A
    send_command('bind @a gs c smartregen')                          -- Win + A
    send_command('bind @f10 gs c smartna')                           -- Win + F10
end

-- Clear every bind this file sets so they don't linger after a job change/reload.
function user_job_unload()
    send_command('unbind !=')
    send_command('unbind ^@!`')
    send_command('unbind ^backspace')
    send_command('unbind @backspace')
    send_command('unbind !pause')
    send_command('unbind ^a')
    send_command('unbind !a')
    send_command('unbind @a')
    send_command('unbind @f10')
end

function user_job_lockstyle()
    send_command('input /lockstyleset 1')
end

-- Define sets and vars used by this job file.
function init_gear_sets()
    ----------------------------------------------------------------
    -- Weapons
    -- Grips ONLY equip with 2H (staff/pole). 1H (club/rod) MUST use a shield.
    ----------------------------------------------------------------
    sets.weapons.MeleeWeapons = {
        main="Maxentius",
        sub="Genmei Shield",          -- was Culminus (grip) — illegal with club
        range=empty,
        ammo="Crepuscular Pebble"
    }
    -- DualWeapons left empty on purpose (WHM almost never duals).
    -- Cycle past it or delete the option in user_job_setup if you prefer.
    sets.weapons.DualWeapons = {}

    -- Buff sets
    sets.buff.Sublimation = {waist="Embla Sash"}
    sets.buff.DTSublimation = {waist="Embla Sash"}

    -- Precast Sets
    sets.precast.FC = {
        main="Cath Palug Hammer",
        sub="Genmei Shield",          -- was Culminus
        head="Ebers Cap +3",
        body="Inyanga Jubbah +2",
        legs="Ayanmo Cosciales +2",
        hands="Fanatic Gloves",
        feet="Regal Pumps",
        neck="Voltsurge Torque",
        ear1="Malignance Earring",
        ear2="Loquacious Earring",
        ring2="Kishar Ring",
        ring1="Lebeche Ring",
        back="Alaunus's Cape",
        waist="Embla Sash"
    }

    sets.precast.FC.DT = set_combine(sets.precast.FC, {})

    sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {
        main="Daybreak",
        sub="Ammurapi Shield",
        body="Ebers Bliaut +3",
        legs="Gyve Trousers",
        neck="Null Loop",
        ear1="Magnetic Earring",
        waist="Siegel Sash",
        feet="Ebers Duckbills +3"
    })

    sets.precast.FC.Stoneskin = set_combine(sets.precast.FC['Enhancing Magic'], {
        legs="Querkening Brais",
        waist="Embla Sash",
        neck="Nodens Gorget"
    })

    sets.precast.FC['Healing Magic'] = set_combine(sets.precast.FC, {
        main="Vadose Rod",
        sub="Sors Shield",
        head="Piety Cap +4",
        body="Ebers Bliaut +3",
        legs="Ebers Pantaloons +3",
        feet="Hygieia Clogs",
        hands="Fanatic Gloves",
        neck="Cleric's Torque",
        ear1="Malignance Earring",
        ear2="Alabaster Earring",
        back="Alaunus's Cape",
        waist="Acerbic Sash +1",
        ring2="Janniston Ring"
    })

    sets.precast.Cure = set_combine(sets.precast.FC['Healing Magic'], {
        legs="Doyen Pants",
        body="Vanya Robe",
        ear1="Nourishing Earring",
        ear2="Mendicant's Earring",
        back="Pahtli Cape"
    })

    sets.precast.Aquaveil = set_combine(sets.precast.FC['Enhancing Magic'], {
        main="Vadose Rod",
        sub="Sors Shield"             -- was Culminus
    })

    sets.precast.FC.StatusRemoval = set_combine(sets.precast.FC['Healing Magic'], {
        legs="Piety Pantaloons +3",
        back="Alaunus's Cape",
        head="Ebers Cap +3",
        body="Ebers Bliaut +3",
        main="Mpaca's Staff",
        sub="Clemency Grip",          -- 2H + grip = legal
        legs="Ebers Pantaloons +3"
    })

    sets.precast.FC.Impact = set_combine(sets.precast.FC, {
        head=empty,
        body="Twilight Cloak"
    })

    -- Precast Job Abilities
    sets.precast.JA.Benediction = {body="Piety Bliaut +4"}
    sets.precast.JA.Devotion = {head="Piety Cap +4"}
    sets.precast.JA['Afflatus Misery'] = {legs="Piety Pantaloons +3"}

    -- Default weaponskill set
    sets.precast.WS = {
        neck="Fotia Gorget",
        ear1="Cessance Earring",
        ear2="Ebers Earring +1",
        ring1="Cornelia's Ring",
        ring2="Mars's Ring",
        waist="Fotia Belt",
        legs="Lengo Pants",
        feet="Medium's Sabots",
        head="Sukeroku Hachimaki"
    }

    -- Midcast and situational sets
    sets.Kiting = {
        feet="Herald's Gaiters",
        ammo="Crepuscular Pebble",
        main="Malignance Pole",
        sub="Daduchos Grip",          -- 2H + grip
        waist="Platinum Moogle Belt"
    }

    -- Latent refresh: NO main/sub here, otherwise low MP swaps your staff.
    sets.latent_refresh = {
        waist="Fucho-no-obi"
    }

    sets.latent_refresh_grip = {}
    sets.TPEat = {}
    sets.DayIdle = {}
    sets.NightIdle = {}
    sets.TreasureHunter = {
        ammo="Perfect Lucky Egg",
        waist="Chaac Belt"
    }

    -- Situational sets
    sets.Self_Healing = {ring1="Kunaji Ring"}
    sets.Cure_Received = {}
    sets.Self_Refresh = {}

    -- Conserve MP
    sets.ConserveMP = set_combine(sets.precast.FC, {
        head="Ebers Cap +3",
        feet="Medium's Sabots",
        ear1="Gifted Earring",
        ring2="Murky Ring",
        legs="SV loincloth +1"
    })

    sets.midcast.Teleport = sets.ConserveMP
    sets.midcast.FastRecast = sets.precast.FC

    -- Cure sets
    sets.midcast['Full Cure'] = sets.midcast.FastRecast

    sets.midcast.Cure = set_combine(sets.precast.FC['Healing Magic'], {
        main="Bunzi's Rod",
        sub="Sors Shield",
        waist="Hachirin-no-Obi",
        head="Ebers Cap +3",
        hands="Theophany Mitts +4",
        neck="Cleric's Torque",
        feet="Piety Duckbills +4",
        ear1="Nourishing Earring",
        ear2="Glorious Earring",
        ammo="Psilomene"
    })

    sets.midcast.Cure.DT = set_combine(sets.midcast.Cure, {})
    sets.midcast.CureSolace = set_combine(sets.midcast.Cure, {})

    sets.midcast.LightWeatherCure = set_combine(sets.midcast.Cure, {
        waist="Hachirin-no-obi",
        main="Chatoyant Staff",
        sub="Daduchos Grip",          -- 2H + grip = legal
        back="Twilight Cape"
    })

    sets.midcast.LightWeatherCureSolace = set_combine(sets.midcast.LightWeatherCure, {})

    -- Independent copies prevent changes propagating between sets.
    sets.midcast.LightDayCure = set_combine(sets.midcast.LightWeatherCureSolace, {})
    sets.midcast.LightDayCureSolace = set_combine(sets.midcast.LightWeatherCureSolace, {})

    -- Melee* maps required by job_get_spell_map when Weapons ~= 'None'.
    -- They keep the locked melee weapon while still using the cure midcast body.
    sets.midcast.MeleeCure = set_combine(sets.midcast.Cure, {})
    sets.midcast.MeleeCureSolace = set_combine(sets.midcast.CureSolace, {})
    sets.midcast.MeleeLightWeatherCure = set_combine(sets.midcast.LightWeatherCure, {})
    sets.midcast.MeleeLightWeatherCureSolace = set_combine(sets.midcast.LightWeatherCureSolace, {})
    sets.midcast.MeleeLightDayCure = set_combine(sets.midcast.LightDayCure, {})
    sets.midcast.MeleeLightDayCureSolace = set_combine(sets.midcast.LightDayCureSolace, {})

    -- Curaga
    sets.midcast.LightWeatherCuraga = set_combine(sets.midcast.LightWeatherCureSolace, {
        body="Theophany Bliaut +4"
    })

    sets.midcast.LightDayCuraga = set_combine(sets.midcast.LightWeatherCuraga, {})

    -- Status removal
    sets.midcast.StatusRemoval = set_combine(sets.midcast.FastRecast, {
        back="Alaunus's Cape",
        head="Ebers Cap +3",
        body="Ebers Bliaut +3",
        hands="Ebers Mitts +3",
        main="Mpaca's Staff",
        sub="Clemency Grip",          -- 2H + grip
        legs="Ebers Pantaloons +3"
    })

    sets.midcast.Cursna = set_combine(sets.midcast.StatusRemoval, {
        back="Alaunus's Cape",
        legs="Theophany Pantaloons +4",
        hands="Fanatic Gloves",
        body="Ebers Bliaut +3",
        ear2="Ebers Earring +1"
    })

    sets.midcast.Erase = set_combine(sets.midcast.StatusRemoval, {
        neck="Cleric's Torque"
    })

    -- Enhancing Magic
    -- 110 total Enhancing Magic Skill; caps even without Light Arts.
    sets.midcast['Enhancing Magic'] = {
        head="Umuthi Hat",
        body="Ebers Bliaut +3",
        legs="Piety Pantaloons +3",
        hands="Theophany Mitts +4",
        feet="Theophany Duckbills +4",
        neck="Null Loop",
        ear1="Andoaa Earring",
        ear2="Ebers Earring +1",
        ring2="Murky Ring",
        ring1="Vertigo Ring",
        back="Izdubar Mantle",
        waist="Embla Sash",
        main="Daybreak",
        sub="Ammurapi Shield"
    }

    -- PROTECT / SHELL (Defined after Enhancing Magic so set_combine inherits duration/skill)
    sets.midcast.Protect = set_combine(sets.midcast['Enhancing Magic'], {
        ring1="Sheltered Ring",
    })

    sets.midcast.Shell = sets.midcast.Protect
    sets.midcast.Protectra = sets.midcast.Protect
    sets.midcast.Shellra = sets.midcast.Shell

    sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {
        waist="Siegel Sash",
        legs="Shedir Seraweels",
        feet="Piety Duckbills +4",
        head="Umuthi Hat",
        neck="Nodens Gorget"
    })

    sets.midcast.Auspice = set_combine(sets.midcast['Enhancing Magic'], {})

    sets.midcast.Regen = set_combine(sets.midcast['Enhancing Magic'], {
        main="Bolelabunga",
        sub="Ammurapi Shield",
        body="Piety Bliaut +4",
        hands="Ebers Mitts +3",
        legs="Theophany Pantaloons +4",
        head="Inyanga Tiara +2",
        feet="Bunzi's Sabots"
    })

    sets.midcast.BarElement = set_combine(sets.midcast['Enhancing Magic'], {
        head="Ebers Cap +3",
        body="Ebers Bliaut +3",
        legs="Piety Pantaloons +3",
        hands="Dynasty Mitts",
        feet="Ebers Duckbills +3"
    })

    -- Divine Magic
    sets.midcast['Divine Magic'] = {
        main="Marin Staff +1",
        sub="Daduchos Grip",          -- 2H + grip
        ammo="Ghastly Tathlum",
        head="Inyanga Tiara +2",
        body="Vanya Robe",
        legs="SV loincloth +1",
        hands="Fanatic Gloves",
        feet="Inyanga Crackows +2",
        neck="Baetyl Pendant",
        ear1="Malignance Earring",
        ear2="Hecate's Earring",
        ring1="Locus Ring",
        ring2="Freke Ring",
        back="Izdubar Mantle",
        waist="Hachirin-no-Obi"
    }

    -- Magic burst set
    sets.MagicBurst = set_combine(sets.midcast['Divine Magic'], {
        main="Bunzi's Rod",
        sub="Ammurapi Shield",        -- was Culminus (grip on 1H rod)
        head="Bunzi's Hat",
        body="Bunzi's Robe",
        hands="Bunzi's Gloves",
        feet="Bunzi's Sabots",
        neck="Mizukage-no-Kubikazari",
        ring2="Freke Ring",
        ring1="Locus Ring"
    })

    sets.midcast.Impact = set_combine(sets.precast.FC.Impact, {})

    -- Elemental Magic
    sets.midcast['Elemental Magic'] = set_combine(sets.midcast['Divine Magic'], {})
    sets.midcast['Elemental Magic'].Resistant = set_combine(
        sets.midcast['Elemental Magic'],
        {neck="Erra Pendant"}
    )

    -- Dark Magic
    sets.midcast['Dark Magic'] = set_combine(sets.midcast['Elemental Magic'], {
        neck="Null Loop",
        ear2="Alabaster Earring",
        ring2="Archon Ring",
        ring1="Evanescence Ring",
        waist="Null Belt"
    })
    sets.midcast.Drain = set_combine(sets.midcast['Dark Magic'], {
        neck="Erra Pendant",
        waist="Fucho-no-obi",
        ring1="Evanescence Ring"
    })
    sets.midcast.Drain.Resistant = set_combine(sets.midcast['Dark Magic'], {})
    sets.midcast.Aspir = set_combine(sets.midcast.Drain, {})
    sets.midcast.Aspir.Resistant = set_combine(sets.midcast.Drain.Resistant, {})
    sets.midcast.Stun = {}
    sets.midcast.Stun.Resistant = set_combine(sets.midcast.Stun, {})

    -- Enfeebling Magic
    sets.midcast['Enfeebling Magic'] = {
        main="Mpaca's Staff",
        sub="Daduchos Grip",          -- 2H + grip
        head="Piety Cap +4",
        body="Theophany Bliaut +4",
        legs="Theophany Pantaloons +4",
        feet="Theophany Duckbills +4",
        neck="Null Loop",
        ear1="Malignance Earring",
        ear2="Ebers Earring +1",
        ring2="Kishar Ring",
        ring1="Crepuscular Ring",
        waist="Obstinate Sash",
        back="Null Shawl",
    }
    sets.midcast['Enfeebling Magic'].Resistant = set_combine(sets.midcast['Enfeebling Magic'], {
        main="Mpaca's Staff",
        hands="Cleric's Mitts +2",
        waist="Null Belt"
    })
    sets.midcast.ElementalEnfeeble = set_combine(sets.midcast['Enfeebling Magic'], {})
    sets.midcast.ElementalEnfeeble.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {})
    -- Independent copies for INT and MND enfeebles.
    sets.midcast.IntEnfeebles = set_combine(sets.midcast.ElementalEnfeeble, {})
    sets.midcast.IntEnfeebles.Resistant = set_combine(sets.midcast.ElementalEnfeeble.Resistant, {})
    sets.midcast.MndEnfeebles = set_combine(sets.midcast.ElementalEnfeeble, {})
    sets.midcast.MndEnfeebles.Resistant = set_combine(sets.midcast.ElementalEnfeeble.Resistant, {})

    -- Idle sets
    sets.idle = {
        main="Daybreak",
        sub="Genmei Shield",
        ammo="Psilomene",
        head="Inyanga Tiara +2",
        body="Ebers Bliaut +3",
        legs="Assiduity Pants +1",
        hands="Inyanga Dastanas +2",
        feet="Inyanga Crackows +2",
        neck="Elite Royal Collar",
        ear2="Ebers Earring +1",
        ear1="Alabaster Earring",
        ring2="Murky Ring",
        ring1="Inyanga Ring",
        back="Archon Cape",
        waist="Null Belt"
    }
    sets.idle.PDT = set_combine(sets.idle, {
        main="Daybreak",
        sub="Genmei Shield",
        head="Bunzi's Hat",
        body="Bunzi's Robe",
        hands="Bunzi's Gloves",
        legs="Bunzi's Pants",
        feet="Bunzi's Sabots",
        ring1="Murky Ring",
        ring2="Vertigo Ring",
    })
    sets.idle.MDT = set_combine(sets.idle, {})
    sets.idle.DTHippo = set_combine(sets.idle, {})
    sets.idle.Weak = set_combine(sets.idle, {})

    -- Resting
    sets.resting = set_combine(sets.idle, {
        main="Chatoyant Staff",
        sub="Daduchos Grip",          -- 2H + grip
        body="Inyanga Jubbah +2",
        legs="Assiduity Pants +1",
        ear2="Magnetic Earring"
    })

    -- Defense sets
    sets.defense.PDT = {
        main="Malignance Pole",
        sub="Daduchos Grip",          -- 2H + grip
        ammo="Crepuscular Pebble",
        head="Bunzi's Hat",
        neck="Null Loop",
        ear1="Alabaster Earring",
        ear2="Genmei Earring",
        body="Bunzi's Robe",
        hands="Bunzi's Gloves",
        ring1="Murky Ring",
        ring2="Vertigo Ring",
        back="Archon Cape",
        waist="Platinum Moogle Belt",
        legs="Bunzi's Pants",
        feet="Bunzi's Sabots",
    }
    sets.defense.MDT = {
        main="Malignance Pole",
        sub="Daduchos Grip",
        ammo="Crepuscular Pebble",
        head="Inyanga Tiara +2",
        neck="Null Loop",
        ear1="Alabaster Earring",
        ear2="Odnowa Earring +1",
        body="Bunzi's Robe",
        hands="Bunzi's Gloves",
        ring1="Murky Ring",
        ring2="Inyanga Ring",
        back="Archon Cape",
        waist="Platinum Moogle Belt",
        legs="Bunzi's Pants",
        feet="Bunzi's Sabots",
    }
    sets.defense.MEVA = {
        main="Daybreak",
        sub="Genmei Shield",
        ammo="Crepuscular Pebble",
        head="Bunzi's Hat",
        neck="Null Loop",
        ear1="Alabaster Earring",
        ear2="Odnowa Earring +1",
        body="Bunzi's Robe",
        hands="Bunzi's Gloves",
        ring1="Murky Ring",
        ring2="Inyanga Ring",
        back="Null Shawl",
        waist="Null Belt",
        legs="Bunzi's Pants",
        feet="Bunzi's Sabots",
    }

    -- Engaged sets
    sets.engaged = {
        legs="Perdition Slops"
    }
    -- Independent copies avoid accidental shared-table mutation.
    sets.engaged.Acc = set_combine(sets.engaged, {})
    sets.engaged.DW = set_combine(sets.engaged, {})
    sets.engaged.DW.Acc = set_combine(sets.engaged.DW, {})

    sets.buff['Divine Caress'] = {
        hands="Ebers Mitts +3"
    }
    sets.HPDown = {}
    sets.HPCure = {}
    sets.buff.Doom = set_combine(sets.buff.Doom, {})
end

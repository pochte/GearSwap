-- CHANGELOG
-- 2026-11-23: Rebuilt GEO casting/pet priorities: Lifestream for Geomancy/Indi casts;
--             Nantosuelta's for Luopan idle/survival; assumed Azimuth Gloves/Tights +3.
--             Geomancy casting now uses Idris + Dunna and the available skill pieces.
--             Azimuth Tights +3 added to Dark Magic and Magic Burst; Gloves +3 to Enfeebling.
-- 2026-11-19: Replaced Lissome Necklace with Null Loop in sets.engaged neck slot.
-- 2026-11-19: Elite Royal Collar (San d'Oria citizen: Regen+3, DT-5%) now the neck in sets.idle / sets.idle.PDT (1 set(s)); replaces Null Loop there (Null Loop kept in all other sets).
-- 2026-11-19: Replaced Platinum Moogle Belt with Null Belt (Regen+3, Eva/MEva/Acc/MAcc+30) in 3 idle set(s); the belt caused too much blood aggro. Defense/FC/other sets unchanged.

-- Ullona_Geo_Gear.lua
-- GEO gear setup.
-- AF (Geomancy/Geo.), Relic (Bagua) and Empyrean (Azimuth) pieces are tagged.

-- gs c castws fires the WS for the selected MainWeapon (handled by smart-ws.lua).
ws_by_main_weapon = {
    Idris = 'Exudation',
    KajaRod = 'Black Halo',
}
ws_by_main_weapon_default = 'Exudation'
include('smart-ws.lua')

function user_job_setup()
    -- Modes
    state.OffenseMode:options('Normal', 'None') -- Normal first: engaged set is used when engaged
    state.CastingMode:options('Normal', 'Resistant', 'Fodder', 'Proc', 'MB', 'MB Resistant')
    state.IdleMode:options('Normal', 'PDT')
    state.PhysicalDefenseMode:options('PDT', 'NukeLock', 'GeoLock', 'PetPDT')
    state.MagicalDefenseMode:options('MDT', 'NukeLock')
    state.ResistDefenseMode:options('MEVA')
    -- Main-hand lock: Ctrl+F7 cycles. Geomancy casts temporarily unlock it (see GEO.lua).
    state.MainWeapon:options('None', 'Idris', 'KajaRod')
    -- Sub-hand lock: Alt+F7 cycles. GEO is never /NIN so no dual wield.
    state.OffWeapon:options('None', 'GenmeiShield', 'AmmurapiShield', 'Culminus')
    -- AutoGeo defaults
    autoindi = "Fury"
    autogeo = "Frailty"

    -- AutoGeo profiles
    autoindimelee = "Fury"
    autogeomelee = "Frailty"
    autoindimage = "Focus"
    autogeomage = "Languor"

    -- Auto-Entrust
    autoentrustee = "<st>"
    autoentrust = "Haste"

    -- Indi duration
    indi_duration = 290

    -- Keybinds
    -- ^ = Ctrl, ! = Alt, @ = Win, ~ = Shift
    send_command('bind !f12 gs c toggle PetHPMode') -- Alt+F12: Pet HP mode
    send_command('bind @f10 gs c smartna')          -- Win+F10: SmartNa
    send_command('bind ^backspace input /ja "Entrust" <me>')
    send_command('bind !backspace input /ja "Life Cycle" <me>')
    send_command('bind @backspace input /ma "Sleep II" <t>')
    send_command('bind ^delete input /ma "Aspir III" <t>')
    send_command('bind @delete input /ma "Sleep" <t>')

    -- Dunna forever: no ammo, no other range items, slots locked.
    equip({range="Dunna", ammo="empty"})
    disable('range', 'ammo')

    -- Apply the default main-hand lock once everything has loaded.
    send_command('wait 3; gs c lockselectedweapons')

    set_macro_page(1, 4)
end

function user_job_unload()
    send_command('unbind !f12')
    send_command('unbind @f10')
    send_command('unbind ^backspace')
    send_command('unbind !backspace')
    send_command('unbind @backspace')
    send_command('unbind ^delete')
    send_command('unbind @delete')
end

function user_job_lockstyle()
    send_command('input /lockstyleset 4')
end

function init_gear_sets()
    -- Precast: Job Abilities
    sets.precast.JA = {
        Bolster = {body="Bagua Tunic"},
        ['Life Cycle'] = {
            body="Geomancy Tunic +3",-- AF
            back="Nantosuelta's Cape",
        },
        ['Radial Arcana'] = {feet="Bagua Sandals +3"}, -- Relic
        ['Mending Halation'] = {legs="Bagua Pants +3"}, -- Relic
        ['Cardinal Chant'] = {head="Geomancy Galero +1"}, -- AF
        ['Full Circle'] = {
            head="Azimuth Hood +3", -- Empy
            hands="Bagua Mitaines +3", -- Relic
        },
        ['Curative Recantation'] = {
            hands="Bagua Mitaines +3", -- Relic
        },
    }

    sets.buff.Entrust = {}
    sets.buff['Blaze of Glory'] = {
        head="Bagua Galero", -- Relic
        main="Idris",
    }

    -- Fast Cast
    sets.precast.FC = {
        main="Cath Palug Hammer",
        sub="Culminus",
        head="Nahtirah Hat",
        body="Agwu's Robe",
        hands="Agwu's Gages",
        legs="Geomancy Pants +3",
        feet="Regal Pumps",
        neck="Voltsurge Torque",
        ear1="Loquacious Earring",
        ear2="Malignance Earring",
        ring1="Naji's Loop",
        ring2="Kishar Ring",
        back="Null Shawl", -- Lifestream reserved for Geomancy/Indi midcast
        waist="Embla Sash",
    }

    sets.precast.FC.Geomancy = set_combine(sets.precast.FC, {
        main="Idris",
        sub="Genmei Shield",
    })

    sets.precast.FC['Elemental Magic'] = set_combine(sets.precast.FC, {
        hands="Bagua Mitaines +3",
        neck="Baetyl Pendant",
        ring1="Mallquis Ring",
    })

sets.precast.FC.Cure = set_combine(sets.precast.FC, {
    main="Daybreak",
    sub="Sors Shield",
    head="Vanya Hood",
    body="Vanya Robe",
    hands="Bokwus Gloves",
    feet="Vanya Clogs",
    ear1="Malignance Earring",
    ear2="Mendicant's Earring",
    ring1="Lebeche Ring",
    ring2="Janniston Ring",
    legs="Ayanmo Cosciales +2",
    back="Pahtli Cape"
})

    sets.precast['Healing Magic'] = set_combine(sets.precast.FC, {
        main="Daybreak",
        sub="Sors Shield",
        legs="Doyen Pants",
        body="Vanya Robe",
    })

    sets.precast.Cure = set_combine(sets.precast.FC.Cure, {
        legs="Doyen Pants",
        body="Vanya Robe",
        main="Daybreak",
        sub="Sors Shield",
        back="Pahtli Cape",
    })

    sets.Self_Healing = {ring1="Kunaji Ring"}
    sets.Cure_Received = {}
    sets.Self_Refresh = {feet="Inspirited Boots"}

    sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {
        main="Daybreak",
        sub="Ammurapi Shield",
        head="Nahtirah Hat",
        body="Jhakri Robe +2",
        legs="Geomancy Pants +3",
        hands="Geo. Mitaines +4",
        feet="Geomancy Sandals +3",
        ear1="Magnetic Earring",
        ear2="Gifted Earring",
        ring1="Murky Ring",
        ring2="Lebeche Ring",
        back="Null Shawl", -- Lifestream reserved for Geomancy/Indi midcast
        waist="Embla Sash",
    })

    sets.precast.FC.Stoneskin = set_combine(sets.precast.FC['Enhancing Magic'], {
        waist="Siegel Sash",
        legs="Querkening Brais",
        head="Umuthi Hat",
        neck="Nodens Gorget",
    })

    sets.precast.FC.Impact = set_combine(sets.precast.FC, {
        head="empty",
        body="Twilight Cloak",
    })

    sets.precast.FC.Dispelga = set_combine(sets.precast.FC, {
        main="Daybreak",
        sub="Culminus",
    })

    sets.precast.Aquaveil = set_combine(sets.precast.FC['Enhancing Magic'], {
        main="Vadose Rod",
        sub="Culminus",
    })

    -- Weaponskills
    -- Same physical WS set as RDM (Nyame assumed Path B), swapping out what GEO
    -- can't wear: Atrophy Gloves +4 -> Nyame Gauntlets, Sucellos's Cape -> Null Shawl.
    sets.precast.WS = {
        head="Nyame Helm", -- Path B
        body="Egbesu Frock",
        hands="Nyame Gauntlets", -- Path B
        legs="Nyame Flanchard", -- Path B
        feet="Nyame Sollerets", -- Path B
        neck="Fotia Gorget",
        ear1="Crepuscular Earring",
        ear2="Ishvara Earring",
        ring1="Cornelia's Ring",
        ring2="Mars's Ring",
        back="Null Shawl",
        waist="Fotia Belt",
    }

    sets.precast.WS['Black Halo'] = set_combine(sets.precast.WS, {
        ear1="Moonshade Earring",
    })

    -- Exudation: physical Club WS (50% INT / 50% MND), Idris only.
    sets.precast.WS['Exudation'] = set_combine(sets.precast.WS, {
        ear1="Moonshade Earring",
    })

    -- Flash Nova is magical: keeps the old magic-leaning WS base.
    sets.precast.WS['Flash Nova'] = {
        head="Jhakri Coronal +2",
        neck="Baetyl Pendant",
        ear1="Hecate's Earring",
        ear2="Malignance Earring",
        body="Jhakri Robe +2",
        hands="Jhakri Cuffs +2",
        ring1="Locus Ring",
        ring2="Freke Ring",
        back="Izdubar Mantle",
        waist="Hachirin-no-Obi",
        legs="Jhakri Slops +2",
        feet="Jhakri Pigaches +2",
    }

    -- Midcast
    sets.midcast.FastRecast = {}

    -- Geomancy potency / skill casting.
    -- Lifestream is reserved for actual Geo-/Indi- casts. Assumed augment target:
    -- Geomancy Skill +10 (and Indi duration if the roll also has it).
    -- Dunna remains locked in the range slot by user_job_setup().
    sets.midcast.Geomancy = {
        main="Idris",
        sub="Genmei Shield",
        head="Azimuth Hood +3",
        neck="Incanter's Torque",
        ear1="Gifted Earring",
        ear2="Azimuth Earring +1",
        body="Bagua Tunic",
        hands="Geo. Mitaines +4",
        ring1="Murky Ring",
        ring2="Vertigo Ring",
        back="Lifestream Cape",
        waist="Null Belt",
        legs="Bagua Pants +3",
        feet="Azimuth Gaiters +3",
    }

    -- Indi gets the same skill/potency core, plus the duration pieces.
    -- Idris is retained instead of Solstice: potency takes priority over +15s.
    sets.midcast.Geomancy.Indi = set_combine(sets.midcast.Geomancy, {
        main="Idris",
        back="Lifestream Cape",
        legs="Bagua Pants +3",
        feet="Azimuth Gaiters +3",
    })

    -- Healing Magic
    sets.midcast['Healing Magic'] = {
        main="Daybreak",
        sub="Sors Shield",
        head="Vanya Hood",
        body="Vrikodara Jupon",
        hands="Bokwus Gloves",
        neck="Nodens Gorget",
        ear1="Gifted Earring",
        ear2="Mendicant's Earring",
        ring1="Lebeche Ring",
        ring2="Janniston Ring",
        back="Tempered Cape +1",
        legs="Gyve Trousers",
        feet="Vanya Clogs",
    }

    sets.midcast.LightWeatherCure = {
        main="Daybreak",
        sub="Sors Shield",
        head="Vanya Hood",
        neck="Nodens Gorget",
        ear1="Gifted Earring",
        ear2="Malignance Earring",
        body="Vrikodara Jupon",
        hands="Bokwus Gloves",
        ring1="Janniston Ring",
        ring2="Lebeche Ring",
        back="Twilight Cape",
        waist="Hachirin-no-Obi",
        legs="Geomancy Pants +3",
        feet="Vanya Clogs",
    }

    sets.midcast.LightDayCure = set_combine(sets.midcast['Healing Magic'], {
        main="Daybreak",
        sub="Sors Shield",
    })

    sets.midcast.Cure = sets.midcast['Healing Magic']

    sets.midcast.Curaga = set_combine(sets.midcast.Cure, {
        main="Daybreak",
        sub="Sors Shield",
    })

    sets.midcast.Cursna = set_combine(sets.midcast['Healing Magic'], {
        neck="Nodens Gorget",
        hands="Bokwus Gloves",
        back="Tempered Cape +1",
        waist="Cornelia's Belt",
        feet="Vanya Clogs",
    })

    sets.midcast.StatusRemoval = set_combine(sets.midcast.FastRecast, {
        main="Cath Palug Hammer",
        sub="Sors Shield",
    })

    -- Elemental Magic
    sets.midcast['Elemental Magic'] = {
        main="Bunzi's Rod",
        sub="Ammurapi Shield",
        head="Azimuth Hood +3",
        body="Azimuth Coat +3",
        hands="Azimuth Gloves +3",
        neck="Baetyl Pendant",
        ear1="Malignance Earring",
        ear2="Hecate's Earring",
        ring1="Jhakri Ring",
        ring2="Freke Ring",
        back="Null Shawl", -- Nantosuelta's Cape is reserved for Luopan survival
        waist="Hachirin-no-Obi",
        legs="Azimuth Tights +3",
        feet="Azimuth Gaiters +3",
    }

    sets.midcast['Elemental Magic'].Resistant = {
        main="Mpaca's Staff",
        sub="Daduchos Grip",
        head="Azimuth Hood +3",
        body="Azimuth Coat +3",
        hands="Azimuth Gloves +3",
        neck="Incanter's Torque",
        ear1="Gwati Earring",
        ear2="Malignance Earring",
        ring1="Jhakri Ring",
        ring2="Freke Ring",
        waist="Null Belt",
        back="Null Shawl",
        legs="Azimuth Tights +3",
        feet="Azimuth Gaiters +3",
    }

    -- Keep these variants available for the GEO.lua casting-mode logic.
    sets.midcast['Elemental Magic'].Fodder = sets.midcast['Elemental Magic']
    sets.midcast['Elemental Magic'].Proc = sets.midcast['Elemental Magic']
    sets.midcast['Elemental Magic'].HighTierNuke = sets.midcast['Elemental Magic']
    sets.midcast['Elemental Magic'].HighTierNuke.Resistant = sets.midcast['Elemental Magic'].Resistant
    sets.midcast['Elemental Magic'].HighTierNuke.Fodder = sets.midcast['Elemental Magic']

    -- Dark Magic
    sets.midcast['Dark Magic'] = {
        main="Bunzi's Rod",
        sub="Ammurapi Shield",
        head="Mallquis Chapeau +2",
        body="Azimuth Coat +3",
        hands="Azimuth Gloves +3",
        legs="Azimuth Tights +3",
        feet="Azimuth Gaiters +3",
        neck="Erra Pendant",
        ear1="Alabaster Earring",
        ear2="Malignance Earring",
        ring1="Mallquis Ring",
        ring2="Evanescence Ring",
        back="Null Shawl", -- Nantosuelta's Cape is reserved for Luopan survival
        waist="Eschan Stone",
    }

    sets.midcast.Drain = set_combine(sets.midcast['Dark Magic'], {
        head="Bagua Galero",
        waist="Fucho-no-Obi",
        feet="Agwu's Pigaches",
    })

    sets.midcast.Aspir = set_combine(sets.midcast.Drain, {
        waist="Fucho-no-Obi",
        feet="Agwu's Pigaches",
    })

    sets.midcast.Stun = set_combine(sets.midcast['Dark Magic'], {
        main="Mpaca's Staff",
        sub="Daduchos Grip",
        neck="Null Loop",
        ear1="Crepuscular Earring",
        ring1="Mallquis Ring",
        ring2="Kishar Ring",
        back="Null Shawl",
        waist="Null Belt",
    })
    sets.midcast.Stun.Resistant = sets.midcast.Stun
    sets.midcast.Impact = sets.precast.FC.Impact

    -- Enfeebling Magic
    sets.midcast['Enfeebling Magic'] = {
        main="Mpaca's Staff",
        sub="Daduchos Grip",
        head="Mallquis Chapeau +2",
        body="Vanya Robe",
        hands="Azimuth Gloves +3",
        legs="Jhakri Slops +2",
        feet="Bagua Sandals +3",
        neck="Null Loop",
        ear1="Crepuscular Earring",
        ear2="Malignance Earring",
        ring1="Mallquis Ring",
        ring2="Kishar Ring",
        back="Null Shawl", -- Nantosuelta's Cape is reserved for Luopan survival
        waist="Null Belt",
    }

    sets.midcast['Enfeebling Magic'].Resistant = set_combine(
        sets.midcast['Enfeebling Magic'],
        {
            main="Chatoyant Staff",
            back="Null Shawl",
            ear1="Gwati Earring",
            ring1="Vertigo Ring",
        }
    )

    sets.midcast.Dispel = sets.midcast['Enfeebling Magic'].Resistant

    sets.midcast.Dispelga = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {
        main="Daybreak",
        sub="Culminus",
    })

    -- Treasure Hunter
    sets.TreasureHunter = {
        waist="Chaac Belt",
    }

    sets.midcast.Dia = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
    sets.midcast['Dia II'] = sets.midcast.Dia
    sets.midcast.Bio = sets.midcast.Dia
    sets.midcast['Bio II'] = sets.midcast.Dia

    -- Divine Magic
    sets.midcast['Divine Magic'] = set_combine(sets.midcast['Elemental Magic'], {
        body="Vanya Robe",
        feet="Medium's Sabots",
    })

    -- Enhancing Magic
    sets.midcast['Enhancing Magic'] = {
        main="Daybreak",
        sub="Ammurapi Shield",
        head="Geomancy Galero +1",
        body="Mallquis Saio +2",
        legs="Geomancy Pants +3",
        hands="Geo. Mitaines +4",
        feet="Geomancy Sandals +3",
        ear1="Magnetic Earring",
        ear2="Andoaa Earring",
        ring1="Murky Ring",
        ring2="Vertigo Ring",
        waist="Siegel Sash",
    }

    sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {
        waist="Siegel Sash",
        legs="Shedir Seraweels",
        head="Umuthi Hat",
        neck="Nodens Gorget",
    })

    sets.midcast.Refresh = set_combine(sets.midcast['Enhancing Magic'], {
        head="Umuthi Hat",
    })

    sets.midcast.Aquaveil = set_combine(sets.midcast['Enhancing Magic'], {
        main="Vadose Rod",
        sub="Culminus",
        head="Umuthi Hat",
        hands="Agwu's Gages",
        waist="Embla Sash",
        legs="Shedir Seraweels",
    })

    sets.midcast.BarElement = set_combine(sets.precast.FC['Enhancing Magic'], {
        legs="Shedir Seraweels",
    })

    sets.midcast.Protect = set_combine(sets.midcast['Enhancing Magic'], {
        ring2="Sheltered Ring", -- Not owned yet
        ear1="Gifted Earring",
        ear2="Malignance Earring",
        waist="Embla Sash",
    })

    sets.midcast.Protectra = sets.midcast.Protect
    sets.midcast.Shell = sets.midcast.Protect
    sets.midcast.Shellra = sets.midcast.Protect

    -- Idle, resting and pet sets
    sets.resting = {
        main="Chatoyant Staff",
        sub="Oneiros Grip",
        head="Nahtirah Hat",
        neck="Null Loop",
        ear1="Gifted Earring",
        ear2="Odnowa Earring +1",
        body="Geomancy Tunic +3", -- AF
        hands="Jhakri Cuffs +2",
        ring1="Murky Ring",
        ring2="Vertigo Ring",
        back="Archon Cape",
        legs="Assiduity Pants +1",
        feet="Jhakri Pigaches +2",
    }

    sets.idle = {
        main="Idris",
        sub="Genmei Shield",
        range="Dunna",
        ammo="empty",
        head="Azimuth Hood +3",
        neck="Elite Royal Collar",
        ear1="Alabaster Earring",
        ear2="Odnowa Earring +1",
        body="Azimuth Coat +3",
        hands="Bagua Mitaines +3",
        ring1="Archon Ring",
        ring2="Murky Ring",
        back="Archon Cape",
        waist="Fucho-no-Obi",
        legs="Assiduity Pants +1",
        feet="Bagua Sandals +3",
    }

    sets.idle.PDT = set_combine(sets.idle, {
        main="Idris",
        sub="Genmei Shield",
        head="Nyame Helm", -- Path B R15
        ear1="Genmei Earring",
        body="Nyame Mail", -- Path B R15
        hands="Nyame Gauntlets", -- Path B R15
        ring1="Murky Ring",
        ring2="Vertigo Ring",
        waist="Null Belt",
        legs="Nyame Flanchard", -- Path B R15
        feet="Nyame Sollerets", -- Path B R15
    })

    sets.idle.Pet = set_combine(sets.idle, {
        main="Idris",
        sub="Genmei Shield",
        head="Azimuth Hood +3", -- Luopan: Regen +5 / Damage Taken -12%
        ear1="Handler's Earring",
        ear2="Handler's Earring +1",
        body="Geomancy Tunic +3", -- AF
        hands="Geo. Mitaines +4", -- Luopan: Damage Taken -13%
        ring1="Murky Ring",
        ring2="Vertigo Ring",
        back="Nantosuelta's Cape", -- Ambuscade cape; pet augment assumed focused on Regen
        feet="Bagua Sandals +3",
        waist="Null Belt",
        legs="Assiduity Pants +1",
        neck="Bagua Charm +1",
    })

    -- Hybrid pet/PDT: retain Azimuth Hood +3, Geo. Mitaines +4 and Nantosuelta's
    -- Cape for the Luopan; add player-side defense only in slots that do not
    -- displace those pet-survival pieces.
    sets.idle.PDT.Pet = set_combine(sets.idle.Pet, {
        neck="Null Loop",
        body="Nyame Mail", -- Path B R15; player-side defense
        legs="Nyame Flanchard", -- Path B R15; player-side defense
    })

    -- Indi idle variants
    local indi_idle = {
        main="Idris",
        back="Nantosuelta's Cape", -- Pet-out idle cape; cast duration is calculated in midcast
        legs="Bagua Pants +3",
        feet="Azimuth Gaiters +3",
    }

    sets.idle.Indi = set_combine(sets.idle, indi_idle)
    sets.idle.Pet.Indi = set_combine(sets.idle.Pet, indi_idle)
    sets.idle.PDT.Indi = set_combine(sets.idle.PDT, indi_idle)
    sets.idle.PDT.Pet.Indi = set_combine(sets.idle.PDT.Pet, indi_idle)
    sets.idle.Weak = sets.idle.PDT

    -- Defense
    sets.defense.PDT = {
        main="Idris",
        sub="Genmei Shield",
        head="Nyame Helm", -- Path B R15
        neck="Null Loop",
        ear1="Alabaster Earring",
        ear2="Genmei Earring",
        body="Nyame Mail", -- Path B R15
        hands="Nyame Gauntlets", -- Path B R15
        ring1="Murky Ring",
        ring2="Vertigo Ring",
        back="Null Shawl",
        waist="Null Belt",
        legs="Nyame Flanchard", -- Path B R15
        feet="Nyame Sollerets", -- Path B R15
    }

    sets.defense.MDT = set_combine(sets.defense.PDT, {
        ear2="Odnowa Earring +1",
        ring2="Archon Ring",
        back="Null Shawl",
    })

    sets.defense.MEVA = {
        main="Daybreak",
        sub="Culminus",
        head="Agwu's Cap",
        neck="Null Loop",
        ear1="Alabaster Earring",
        ear2="Odnowa Earring +1",
        body="Agwu's Robe",
        hands="Agwu's Gages",
        ring1="Archon Ring",
        ring2="Shadow Ring",
        back="Null Shawl",
        waist="Null Belt",
        legs="Agwu's Slops",
        feet="Agwu's Pigaches",
    }

    sets.defense.PetPDT = sets.idle.PDT.Pet
    sets.defense.NukeLock = sets.midcast['Elemental Magic']
    sets.defense.GeoLock = sets.midcast.Geomancy.Indi

    -- Utility
    sets.Kiting = {
        feet="Geomancy Sandals +3",
        waist="Platinum Moogle Belt",
    }

    sets.PetHP = {
        head="Bagua Galero",
        back="Nantosuelta's Cape",
    }

    sets.latent_refresh = {waist="Fucho-no-Obi"}
    sets.latent_refresh_grip = {sub="Oneiros Grip"}
    sets.DayIdle = {}
    sets.NightIdle = {}
    sets.HPDown = {}
    sets.buff.Doom = sets.buff.Doom or {}

    -- Engaged (TP)
    -- Full Nyame (Path B) with RDM/BLM jewelry, limited to what GEO can wear
    -- (no Malignance, Sherida Earring, Sailfi Belt +1 or Sucellos's Cape).
    sets.engaged = {
        main="Idris",
        head="Nyame Helm", -- Path B
        neck="Null Loop",
        ear1="Cessance Earring",
        ear2="Crepuscular Earring",
        body="Nyame Mail", -- Path B
        hands="Nyame Gauntlets", -- Path B
        ring1="Petrov Ring",
        ring2="Rajas Ring",
        back="Null Shawl",
        waist="Eschan Stone",
        legs="Nyame Flanchard", -- Path B
        feet="Nyame Sollerets", -- Path B
    }

    sets.engaged.DW = {}

    -- Custom sets used by GEO.lua
    sets.RecoverMP = {}

    sets.MagicBurst = set_combine(sets.midcast['Divine Magic'], {
        main="Bunzi's Rod",
        sub="Ammurapi Shield",
        head="Agwu's Cap",
        body="Agwu's Robe",
        hands="Agwu's Gages",
        legs="Azimuth Tights +3",
        feet="Azimuth Gaiters +3",
        neck="Mizukage-no-Kubikazari",
        ring1="Locus Ring",
        ring2="Freke Ring",
    })

    sets.ResistantMagicBurst = sets.MagicBurst
    sets.buff.Sublimation = {waist="Embla Sash"}
    sets.buff.DTSublimation = {waist="Embla Sash"}

    -- Weapon sets (legacy: state.Weapons is retired on GEO; MainWeapon handles weapon locks)
    sets.weapons.Idris = {
        main="Idris",
        sub="Genmei Shield",
    }

    sets.weapons.DualWeapons = {
        main="Cath Palug Hammer",
        sub="Vadose Rod",
    }

    -- Placeholder sets referenced by GEO.lua
    sets.element = sets.element or {}
    sets.element.Fire = {}
    sets.element.Ice = {}
    sets.element.Wind = {}
    sets.element.Earth = {}
    sets.element.Water = {}
    sets.element.Thunder = {}
    sets.element.Light = {}
    sets.element.Dark = {}

    sets.RecoverBurst = sets.RecoverMP
    sets.ResistantRecoverBurst = sets.RecoverBurst
    sets.MaxTP = {}
end
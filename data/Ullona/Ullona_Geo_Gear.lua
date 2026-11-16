-- Ullona_Geo_Gear.lua
-- GEO gear setup.
-- AF (Geomancy/Geo.), Relic (Bagua) and Empyrean (Azimuth) pieces are tagged.

function user_job_setup()
    -- Modes
    state.OffenseMode:options('Normal', 'None') -- Normal first: engaged set is used when engaged
    state.CastingMode:options('Normal', 'Resistant', 'Fodder', 'Proc', 'MB', 'MB Resistant')
    state.IdleMode:options('Normal', 'PDT')
    state.PhysicalDefenseMode:options('PDT', 'NukeLock', 'GeoLock', 'PetPDT')
    state.MagicalDefenseMode:options('MDT', 'NukeLock')
    state.ResistDefenseMode:options('MEVA')
    state.Weapons:options('None', 'Idris', 'DualWeapons')

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
            body="Geo. Tunic +3",-- AF
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
legs="Geomancy Pants +2",
        feet="Regal Pumps",
        neck="Voltsurge Torque",
        ear1="Loquacious Earring",
        ear2="Malignance Earring",
        ring1="Naji's Loop",
        ring2="Kishar Ring",
        back="Lifestream Cape",
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
        body="Vrikodara Jupon",
        hands="Bokwus Gloves",
        feet="Vanya Clogs",
        ear1="Magnetic Earring",
        ear2="Mendicant's Earring",
        ring1="Lebeche Ring",
        ring2="Janniston Ring",
        legs="Gyve Trousers",
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
        legs="Geomancy Pants +1",
        hands="Geo. Mitaines +4",
        feet="Geomancy Sandals +3",
        ear1="Magnetic Earring",
        ear2="Gifted Earring",
        ring1="Murky Ring",
        ring2="Lebeche Ring",
        back="Lifestream Cape",
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
        head  = "Nyame Helm", -- Path B
        body  = "Egbesu Frock",
        hands = "Nyame Gauntlets", -- Path B
        legs  = "Nyame Flanchard", -- Path B
        feet  = "Nyame Sollerets", -- Path B
        neck  = "Fotia Gorget",
        ear1  = "Crepuscular Earring",
        ear2  = "Ishvara Earring",
        ring1 = "Cornelia's Ring",
        ring2 = "Mars's Ring",
        back  = "Null Shawl",
        waist = "Fotia Belt",
    }

    sets.precast.WS['Black Halo'] = set_combine(sets.precast.WS, {
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
        waist="Hachirin-no-obi",
        legs="Jhakri Slops +2",
        feet="Jhakri Pigaches +2",
    }

    -- Midcast
    sets.midcast.FastRecast = {}

    -- Geomancy skill
    sets.midcast.Geomancy = {
        main="Idris",
        sub="Culminus",
        head="Azimuth Hood +3",
        neck="Incanter's Torque",
        ear1="Gifted Earring",
        ear2="Azimuth Earring +1",
        body="Bagua Tunic",
        hands="Geo. Mitaines +4",
        ring1="Murky Ring",
        ring2="Vertigo Ring",
        back="Nantosuelta's Cape",
        waist="Platinum Moogle Belt",
        legs="Geomancy Pants +1",
        feet="Geomancy Sandals +3",
    }

    sets.midcast.Geomancy.Indi = set_combine(sets.midcast.Geomancy, {
        main="Solstice",
        back="Nantosuelta's Cape",
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
        legs="Geomancy Pants +1",
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
        main="Marin Staff +1",
        sub="Daduchos Grip",
        head="Jhakri Coronal +2",
        body="Jhakri Robe +2",
        hands="Jhakri Cuffs +2",
        neck="Baetyl Pendant",
        ear1="Malignance Earring",
        ear2="Hecate's Earring",
        ring1="Jhakri Ring",
        ring2="Freke Ring",
        back="Nantosuelta's Cape",
        waist="Hachirin-no-obi",
        legs="Jhakri Slops +2",
        feet="Jhakri Pigaches +2",
    }

    sets.midcast['Elemental Magic'].Resistant = {
        main="Mpaca's Staff",
        sub="Daduchos Grip",
        head="Jhakri Coronal +2",
        body="Jhakri Robe +2",
        hands="Agwu's Gages",
        neck="Incanter's Torque",
        ear1="Gwati Earring",
        ear2="Malignance Earring",
        ring1="Jhakri Ring",
        ring2="Freke Ring",
        waist="Null Belt",
        back="Null Shawl",
        legs="Jhakri Slops +2",
        feet="Medium's Sabots",
    }

    -- Keep these variants available for the GEO.lua casting-mode logic.
    sets.midcast['Elemental Magic'].Fodder = sets.midcast['Elemental Magic']
    sets.midcast['Elemental Magic'].Proc = sets.midcast['Elemental Magic']
    sets.midcast['Elemental Magic'].HighTierNuke = sets.midcast['Elemental Magic']
    sets.midcast['Elemental Magic'].HighTierNuke.Resistant = sets.midcast['Elemental Magic'].Resistant
    sets.midcast['Elemental Magic'].HighTierNuke.Fodder = sets.midcast['Elemental Magic']

    -- Dark Magic
    sets.midcast['Dark Magic'] = {
        main="Marin Staff +1",
        sub="Daduchos Grip",
        head="Mallquis Chapeau +2",
        body="Geo. Tunic +3", -- AF
        hands="Jhakri Cuffs +2",
        legs="Azimuth Tights +2",
        feet="Jhakri Pigaches +2",
        neck="Erra Pendant",
        ear1="Alabaster Earring",
        ear2="Malignance Earring",
        ring1="Mallquis Ring",
        ring2="Evanescence Ring",
        back="Nantosuelta's Cape",
        waist="Eschan Stone",
    }

    sets.midcast.Drain = set_combine(sets.midcast['Dark Magic'], {
        head="Bagua Galero",
        waist="Fucho-no-obi",
        feet="Agwu's Pigaches",
    })

    sets.midcast.Aspir = set_combine(sets.midcast.Drain, {
        waist="Fucho-no-obi",
        feet="Agwu's Pigaches",
    })

    sets.midcast.Stun = sets.midcast['Dark Magic']
    sets.midcast.Stun.Resistant = sets.midcast['Dark Magic']
    sets.midcast.Impact = sets.precast.FC.Impact

    -- Enfeebling Magic
    sets.midcast['Enfeebling Magic'] = {
        main="Mpaca's Staff",
        sub="Daduchos Grip",
        head="Mallquis Chapeau +2",
        body="Vanya Robe",
        hands="Azimuth Gloves +2",
        legs="Jhakri Slops +2",
        feet="Bagua Sandals +3",
        neck="Null Loop",
        ear1="Crepuscular Earring",
        ear2="Malignance Earring",
        ring1="Mallquis Ring",
        ring2="Kishar Ring",
        back="Nantosuelta's Cape",
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
        legs="Geomancy Pants +1",
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
        body="Geo. Tunic +3", -- AF
        hands="Jhakri Cuffs +2",
        ring1="Murky Ring",
        ring2="Vertigo Ring",
        back="Archon Cape",
        legs="Assid. Pants +1",
        feet="Jhakri Pigaches +2",
    }

    sets.idle = {
        main="Idris",
        sub="Genmei Shield",
        range="Dunna",
        ammo="empty",
        head="Azimuth Hood +3",
        neck="Null Loop",
        ear1="Alabaster Earring",
        ear2="Odnowa Earring +1",
        body="Azimuth Coat +3",
        hands="Bagua Mitaines +3",
        ring1="Archon Ring",
        ring2="Murky Ring",
        back="Archon Cape",
        waist="Fucho-no-Obi",
        legs="Assid. Pants +1",
        feet="Bagua Sandals +3",
    }

    sets.idle.PDT = set_combine(sets.idle, {
        main="Idris",
        sub="Genmei Shield",
        head="Nyame Helm",
        ear1="Genmei Earring",
        body="Jhakri Robe +2",
        hands="Bagua Mitaines +3",
        ring1="Murky Ring",
        ring2="Vertigo Ring",
        waist="Platinum Moogle Belt",
        legs="SV Loincloth +1",
    })

    sets.idle.Pet = set_combine(sets.idle, {
        main="Idris",
        sub="Genmei Shield",
        ear1="Handler's Earring",
        ear2="Handler's Earring +1",
        body="Geo. Tunic +3", -- AF
        hands="Geo. Mitaines +4",
        ring1="Murky Ring",
        ring2="Vertigo Ring",
        back="Nantosuelta's Cape",
        waist="Platinum Moogle Belt",
        legs="Assiduity Pants +1",
        neck="Bagua Charm +1",
    })

    sets.idle.PDT.Pet = set_combine(sets.idle.PDT, sets.idle.Pet, {
        neck="Null Loop",
    })

    -- Indi idle variants
    local indi_idle = {
        main="Idris",
        back="Nantosuelta's Cape",
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
        main="Malignance Pole",
        sub="Daduchos Grip",
        head="Nyame Helm",
        neck="Null Loop",
        ear1="Alabaster Earring",
        ear2="Genmei Earring",
        body="SV Separates +1",
        hands="SV Gauntlets +1",
        ring1="Murky Ring",
        ring2="Vertigo Ring",
        back="Archon Cape",
        waist="Platinum Moogle Belt",
        legs="SV Loincloth +1",
        feet="SV Gaiters +1",
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

    sets.latent_refresh = {waist="Fucho-no-obi"}
    sets.latent_refresh_grip = {sub="Oneiros Grip"}
    sets.DayIdle = {}
    sets.NightIdle = {}
    sets.HPDown = {}
    sets.buff.Doom = sets.buff.Doom or {}

    -- Engaged (TP)
    -- Full Nyame (Path B) with RDM/BLM jewelry, limited to what GEO can wear
    -- (no Malignance, Sherida Earring, Sailfi Belt +1 or Sucellos's Cape).
    sets.engaged = {
        main  = "Idris",
        head  = "Nyame Helm", -- Path B
        neck  = "Lissome Necklace",
        ear1  = "Cessance Earring",
        ear2  = "Crepuscular Earring",
        body  = "Nyame Mail", -- Path B
        hands = "Nyame Gauntlets", -- Path B
        ring1 = "Petrov Ring",
        ring2 = "Rajas Ring",
        back  = "Null Shawl",
        waist = "Eschan Stone",
        legs  = "Nyame Flanchard", -- Path B
        feet  = "Nyame Sollerets", -- Path B
    }

    sets.engaged.DW = {}

    -- Custom sets used by GEO.lua
    sets.RecoverMP = {}

    sets.MagicBurst = set_combine(sets.midcast['Divine Magic'], {
        main="Bunzi's Rod",
        sub="Culminus",
        head="Agwu's Cap",
        body="Agwu's Robe",
        hands="Agwu's Gages",
        legs="Agwu's Slops",
        feet="Agwu's Pigaches",
        neck="Mizukage-no-Kubikazari",
        ring1="Locus Ring",
        ring2="Freke Ring",
    })

    sets.ResistantMagicBurst = sets.MagicBurst
    sets.buff.Sublimation = {waist="Embla Sash"}
    sets.buff.DTSublimation = {waist="Embla Sash"}

    -- Weapon sets
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
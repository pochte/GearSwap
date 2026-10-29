-- Ullona_Geo_Gear.lua
-- GEO gear setup.
-- Relic (Bagua) and Empyrean (Azimuth) gear are placeholders for future upgrades.
-- AF (Geo./Geomancy) gear is used where owned; Geo. Tunic +1 is still missing.
function user_job_setup()
    -- Options
    state.OffenseMode:options('None', 'Normal')
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
    -- Auto-Entrust defaults
    autoentrustee = "<st>"
    autoentrust = "Haste"
    -- Additional local binds
    -- ^ = Ctrl, ! = Alt, @ = Win, ~ = Shift
    send_command('bind !f12 gs c toggle PetHPMode') -- Alt+F12: Pet HP mode
    send_command('bind @f10 gs c smartna') -- Win+F10: SmartNa
    send_command('bind ^backspace input /ja "Entrust" <me>')
    send_command('bind !backspace input /ja "Life Cycle" <me>')
    send_command('bind @backspace input /ma "Sleep II" <t>')
    send_command('bind ^delete input /ma "Aspir III" <t>')
    send_command('bind @delete input /ma "Sleep" <t>')
    indi_duration = 290
    -- Macro Book
    set_macro_page(1, 4)
end
-- Clear every bind this file sets so they don't linger after a job change/reload.
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
    -- Precast sets
    -- Job abilities
    -- Bolster's relic body is not owned yet; use Jhakri Robe +2.
    sets.precast.JA.Bolster = {
        body="Jhakri Robe +2",
        -- FUTURE RELIC: body="Bagua Tunic +1",
    }
    -- GEO AF body is not owned yet.
    sets.precast.JA['Life Cycle'] = {
        body="Jhakri Robe +2",
        back="Nantosuelta's Cape",
        -- FUTURE AF: body="Geo. Tunic +1",
    }
    sets.precast.JA['Radial Arcana'] = {
        feet="Geomancy Sandals +1",
        -- FUTURE RELIC: feet="Bagua Sandals +1",
    }
    sets.precast.JA['Mending Halation'] = {
        legs="Geo. Pants +1",
        -- FUTURE RELIC: legs="Bagua Pants +1",
    }
    sets.precast.JA['Cardinal Chant'] = {
        head="Geomancy Galero +1",
    }
    sets.precast.JA['Full Circle'] = {
        head="Geomancy Galero +1",
        hands="Geo. Mitaines +1",
        -- FUTURE EMPYREAN: head="Azimuth Hood +1",
        -- FUTURE RELIC: hands="Bagua Mitaines +1",
    }
    -- Indi duration in slots that would normally have skill.
    sets.buff.Entrust = {}
    -- FUTURE RELIC: head="Bagua Galero +1" for Blaze of Glory HP.
    sets.buff['Blaze of Glory'] = {}
    -- Fast Cast
    sets.precast.FC = {
        main="Cath Palug Hammer",
        sub="Culminus",
        head="Umuthi Hat",
        body="Agwu's Robe",
        legs="Lengo Pants",
        hands="Mallquis Cuffs +2",
        feet="Regal Pumps",
        neck="Voltsurge Torque",
        ear1="Malignance Earring",
        ear2="Loquac. Earring",
        ring1="Lebeche Ring",
        ring2="Kishar Ring",
        back="Alaunus's Cape",
        waist="Cornelia's Belt",
    }
    sets.precast.FC.Geomancy = set_combine(sets.precast.FC, {
        main="Solstice",
        range="Dunna",
        ammo="empty",
    })
    sets.precast.FC['Elemental Magic'] = set_combine(sets.precast.FC, {
        ear2="Malignance Earring",
        hands="Mallquis Cuffs +2",
    })
    sets.precast.FC.Cure = set_combine(sets.precast.FC, {
        main="Daybreak",
        sub="Sors Shield",
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
    sets.Self_Healing = {}
    sets.Cure_Received = {}
    sets.Self_Refresh = {
        feet="Inspirited Boots",
    }
    sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {
        main="Daybreak",
        sub="Ammurapi Shield",
        head="Umuthi Hat",
        body="Jhakri Robe +2",
        legs="Geo. Pants +1",
        hands="Geo. Mitaines +1",
        feet="Geomancy Sandals +1",
        ear1="Andoaa Earring",
        ear2="Gifted Earring",
        ring1="Murky Ring",
        ring2="Lebeche Ring",
        back="Estoqueur's Cape",
        waist="Embla Sash",
        -- FUTURE AF: body="Geo. Tunic +1",
        -- FUTURE RELIC: body="Bagua Tunic +1",
        -- FUTURE RELIC: hands="Bagua Mitaines +1",
        -- FUTURE EMPYREAN: feet="Azimuth Gaiters +1",
    })
    sets.precast.FC.Stoneskin = set_combine(
        sets.precast.FC['Enhancing Magic'],
        {
            waist="Siegel Sash",
            legs="Shedir Seraweels",
            head="Umuthi Hat",
            neck="Nodens Gorget",
        }
    )
    sets.precast.FC.Impact = set_combine(sets.precast.FC, {
        head="empty",
        body="Twilight Cloak",
    })
    sets.precast.FC.Dispelga = set_combine(sets.precast.FC, {
        main="Daybreak",
        sub="Culminus",
    })
    -- Weaponskill sets
    sets.precast.WS = {
        main="Cath Palug Hammer",
        sub="Culminus",
        ammo="Oshasha's Treatise",
        head="Jhakri Coronal +2",
        neck="Loricate Torque +1",
        ear1="Hecate's Earring",
        ear2="Malignance Earring",
        body="Jhakri Robe +2",
        hands="Jhakri Cuffs +2",
        ring1="Locus Ring",
        ring2="Mujin Band",
        waist="Null Belt",
        legs="Jhakri Slops +2",
        feet="Jhakri Pigaches +2",
        -- FUTURE EMPYREAN: head="Azimuth Hood +1",
        -- FUTURE RELIC: body="Bagua Tunic +1",
        -- FUTURE RELIC: hands="Bagua Mitaines +1",
        -- FUTURE RELIC: legs="Bagua Pants +1",
        -- FUTURE RELIC: feet="Bagua Sandals +1",
    }
    sets.precast.WS['Flash Nova'] = set_combine(sets.precast.WS, {
        ammo="Ghastly Tathlum",
        neck="Baetyl Pendant",
        ring1="Locus Ring",
        ring2="Mujin Band",
        back="Izdubar Mantle",
        waist="Hachirin-no-obi",
    })
    -- Midcast sets
    sets.midcast.FastRecast = {}
    -- Geomancy skill set.
    -- Uses AF skill pieces currently owned; substitutes for missing AF body.
    sets.midcast.Geomancy = {
        main="Solstice",
        sub="Culminus",
        range="Dunna",
        head="Geomancy Galero +1",
        neck="Incanter's Torque",
        ear1="Gifted Earring",
        ear2="Malignance Earring",
        body="Vedic Coat",
        hands="Geo. Mitaines +1",
        ring1="Defending Ring",
        ring2="Dark Ring",
        back="Nantosuelta's Cape",
        waist="Austerity Belt +1",
        legs="Geo. Pants +1",
        feet="Geomancy Sandals +1",
        -- FUTURE AF: body="Geo. Tunic +1",
        -- FUTURE RELIC: body="Bagua Tunic +1",
        -- FUTURE RELIC: hands="Bagua Mitaines +1",
        -- FUTURE RELIC: legs="Bagua Pants +1",
        -- FUTURE RELIC: feet="Bagua Sandals +1",
        -- FUTURE EMPYREAN: head="Azimuth Hood +1",
        -- FUTURE EMPYREAN: feet="Azimuth Gaiters +1",
    }
    -- Extra Indi duration while maintaining the skill cap.
    sets.midcast.Geomancy.Indi = set_combine(sets.midcast.Geomancy, {
        back="Nantosuelta's Cape",
        legs="Geo. Pants +1",
        feet="Geomancy Sandals +1",
        -- FUTURE RELIC: legs="Bagua Pants +1",
        -- FUTURE EMPYREAN: feet="Azimuth Gaiters +1",
    })
    sets.midcast['Healing Magic'] = {
        main="Bunzi's Rod",
        sub="Sacro Bulwark",
        head="Vanya Hood",
        body="Vrikodara Jupon",
        hands="Bokwus Gloves",
        neck="Nodens Gorget",
        ear1="Glorious Earring",
        ear2="Mendicant's Earring",
        ring1="Naji's Loop",
        ring2="Janniston Ring",
        back="Tempered Cape +1",
        legs="Vanya Slops",
        feet="Vanya Clogs",
    }
    sets.midcast.LightWeatherCure = {
        main="Chatoyant Staff",
        sub="Curatio Grip",
        ammo="Psilomene",
        head="Amalric Coif +1",
        neck="Phalaina Locket",
        ear1="Gifted Earring",
        ear2="Malignance Earring",
        body="Vrikodara Jupon",
        hands="Bokwus Gloves",
        ring1="Janniston Ring",
        ring2="Menelaus's Ring",
        back="Twilight Cape",
        waist="Hachirin-no-Obi",
        legs="Geo. Pants +1",
        feet="Vanya Clogs",
    }
    -- Cure set for Light day without Light weather.
    sets.midcast.LightDayCure = set_combine(sets.midcast['Healing Magic'], {
        main="Chatoyant Staff",
        sub="Achaq Grip",
    })
    sets.midcast.Cure = set_combine(sets.midcast['Healing Magic'], {})
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
        sub="Clemency Grip",
    })
    -- Elemental Magic
    sets.midcast['Elemental Magic'] = {
        main="Marin Staff +1",
        sub="Willpower Grip",
        ammo="Ghastly Tathlum",
        head="Jhakri Coronal +2",
        body="Jhakri Robe +2",
        hands="Jhakri Cuffs +2",
        neck="Baetyl Pendant",
        ear1="Malignance Earring",
        ear2="Hecate's Earring",
        ring1="Resonance Ring",
        ring2="Freke Ring",
        back="Nantosuelta's Cape",
        waist="Hachirin-no-obi",
        legs="Jhakri Slops +2",
        feet="Jhakri Pigaches +2",
        -- FUTURE EMPYREAN: head="Azimuth Hood +1",
        -- FUTURE RELIC: body="Bagua Tunic +1",
        -- FUTURE RELIC: legs="Bagua Pants +1",
        -- FUTURE RELIC: feet="Bagua Sandals +1",
    }
    sets.midcast['Elemental Magic'].Resistant = {
        main="Mpaca's Staff",
        sub="Willpower Grip",
        ammo="Ghastly Tathlum",
        head="Jhakri Coronal +2",
        body="Jhakri Robe +2",
        hands="Leyline Gloves",
        neck="Incanter's Torque",
        ear1="Gwati Earring",
        ear2="Malignance Earring",
        ring1="Resonance Ring",
        ring2="Freke Ring",
        waist="Null Belt",
        back="Null Shawl",
        legs="Jhakri Slops +2",
        feet="Jhakri Pigaches +2",
        range="Kaja Bow",
        -- FUTURE EMPYREAN: head="Azimuth Hood +1",
        -- FUTURE RELIC: body="Bagua Tunic +1",
        -- FUTURE RELIC: legs="Bagua Pants +1",
    }
    sets.midcast['Elemental Magic'].Fodder = set_combine(
        sets.midcast['Elemental Magic'],
        {}
    )
    sets.midcast['Elemental Magic'].Proc = set_combine(
        sets.midcast['Elemental Magic'],
        {}
    )
    sets.midcast['Elemental Magic'].HighTierNuke = set_combine(
        sets.midcast['Elemental Magic'],
        {}
    )
    sets.midcast['Elemental Magic'].HighTierNuke.Resistant = set_combine(
        sets.midcast['Elemental Magic'].Resistant,
        {}
    )
    sets.midcast['Elemental Magic'].HighTierNuke.Fodder = set_combine(
        sets.midcast['Elemental Magic'].Fodder,
        {}
    )
    -- Dark Magic
    sets.midcast['Dark Magic'] = {
        head="Jhakri Coronal +2",
        body="Jhakri Robe +2",
        legs="Jhakri Slops +2",
        hands="Jhakri Cuffs +2",
        feet="Jhakri Pigaches +2",
        neck="Erra Pendant",
        ear1="Alabaster Earring",
        ear2="Malignance Earring",
        ring1="Crepuscular Ring",
        ring2="Evanescence Ring",
        back="Nantosuelta's Cape",
        waist="Eschan Stone",
        ammo="Ghastly Tathlum",
        main="Marin Staff +1",
        sub="Willpower Grip",
    }
    sets.midcast.Drain = set_combine(sets.midcast['Dark Magic'], {
        neck="Erra Pendant",
        waist="Fucho-no-obi",
        feet="Agwu's Pigaches",
    })
    sets.midcast.Aspir = set_combine(sets.midcast.Drain, {
        waist="Fucho-no-obi",
        feet="Agwu's Pigaches",
    })
    sets.midcast.Stun = set_combine(sets.midcast['Dark Magic'], {})
    sets.midcast.Stun.Resistant = set_combine(sets.midcast['Dark Magic'], {})
    sets.midcast.Impact = set_combine(sets.precast.FC.Impact, {})
    -- Enfeebling Magic
    sets.midcast['Enfeebling Magic'] = {
        main="Mpaca's Staff",
        sub="Willpower Grip",
        head="Jhakri Coronal +2",
        body="Vanya Robe",
        hands="Jhakri Cuffs +2",
        legs="Jhakri Slops +2",
        feet="Skaoi Boots",
        neck="Null Loop",
        ear1="Gifted Earring",
        ear2="Malignance Earring",
        ring1="Mallquis Ring",
        ring2="Kishar Ring",
        back="Lifestream Cape",
        waist="Null Belt",
        range="Dunna",
        -- FUTURE RELIC: head="Bagua Galero +1",
        -- FUTURE RELIC: hands="Bagua Mitaines +1",
        -- FUTURE RELIC: legs="Bagua Pants +1",
    }
    sets.midcast['Enfeebling Magic'].Resistant = set_combine(
        sets.midcast['Enfeebling Magic'],
        {
            main="Chatoyant Staff",
            back="Null Shawl",
            ear1="Snotra Earring",
            sub="Willpower Grip",
            ring1="Vertigo Ring",
            neck="Null Loop",
        }
    )
    sets.midcast.Dispel = set_combine(
        sets.midcast['Enfeebling Magic'].Resistant,
        {}
    )
    sets.midcast.Dispelga = set_combine(
        sets.midcast['Enfeebling Magic'].Resistant,
        {
            main="Daybreak",
            sub="Culminus",
        }
    )
    sets.midcast.ElementalEnfeeble = set_combine(
        sets.midcast['Enfeebling Magic'],
        {}
    )
    sets.midcast.ElementalEnfeeble.Resistant = set_combine(
        sets.midcast['Enfeebling Magic'].Resistant,
        {}
    )
    sets.midcast.IntEnfeebles = set_combine(
        sets.midcast.ElementalEnfeeble,
        {}
    )
    sets.midcast.IntEnfeebles.Resistant = set_combine(
        sets.midcast.ElementalEnfeeble.Resistant,
        {}
    )
    sets.midcast.MndEnfeebles = set_combine(
        sets.midcast.ElementalEnfeeble,
        {}
    )
    sets.midcast.MndEnfeebles.Resistant = set_combine(
        sets.midcast.ElementalEnfeeble.Resistant,
        {}
    )
    -- Treasure Hunter
    sets.TreasureHunter = {
        ammo="Perfect Lucky Egg",
        waist="Chaac Belt",
    }
    sets.midcast.Dia = set_combine(
        sets.midcast['Enfeebling Magic'],
        sets.TreasureHunter
    )
    sets.midcast['Dia II'] = set_combine(
        sets.midcast['Enfeebling Magic'],
        sets.TreasureHunter
    )
    sets.midcast.Bio = set_combine(
        sets.midcast['Enfeebling Magic'],
        sets.TreasureHunter
    )
    sets.midcast['Bio II'] = set_combine(
        sets.midcast['Enfeebling Magic'],
        sets.TreasureHunter
    )
    sets.midcast['Divine Magic'] = set_combine(
        sets.midcast['Elemental Magic'],
        {
            feet="Medium's Sabots",
            body="Vanya Robe",
        }
    )
    -- Enhancing Magic
    sets.midcast['Enhancing Magic'] = {
        main=gear.gada_enhancing_club,
        sub="Ammurapi Shield",
        head="Geomancy Galero +1",
        body="Jhakri Robe +2",
        legs="Geo. Pants +1",
        hands="Geo. Mitaines +1",
        feet="Geomancy Sandals +1",
        ear1="Andoaa Earring",
        ear2="Gifted Earring",
        ring1="Murky Ring",
        ring2="Lebeche Ring",
        waist="Embla Sash",
        -- FUTURE AF: body="Geo. Tunic +1",
        -- FUTURE RELIC: body="Bagua Tunic +1",
        -- FUTURE RELIC: hands="Bagua Mitaines +1",
        -- FUTURE EMPYREAN: feet="Azimuth Gaiters +1",
    }
    sets.midcast.Stoneskin = set_combine(
        sets.midcast['Enhancing Magic'],
        {
            waist="Siegel Sash",
            legs="Shedir Seraweels",
            head="Umuthi Hat",
            neck="Nodens Gorget",
        }
    )
    sets.midcast.Refresh = set_combine(
        sets.midcast['Enhancing Magic'],
        {
            head="Amalric Coif +1",
        }
    )
    sets.midcast.Aquaveil = set_combine(
        sets.midcast['Enhancing Magic'],
        {
            main="Vadose Rod",
            sub="Culminus",
            head="Amalric Coif +1",
            hands="Regal Cuffs",
            waist="Emphatikos Rope",
            legs="Shedir Seraweels",
        }
    )
    sets.midcast.BarElement = set_combine(
        sets.precast.FC['Enhancing Magic'],
        {
            legs="Shedir Seraweels",
        }
    )
    sets.midcast.Protect = set_combine(
        sets.midcast['Enhancing Magic'],
        {
            ring2="Sheltered Ring",
            ear1="Gifted Earring",
            ear2="Malignance Earring",
            waist="Sekhmet Corset",
        }
    )
    sets.midcast.Protectra = set_combine(
        sets.midcast.Protect,
        {}
    )
    sets.midcast.Shell = set_combine(
        sets.midcast.Protect,
        {}
    )
    sets.midcast.Shellra = set_combine(
        sets.midcast.Protect,
        {}
    )
    -- Idle, resting, and pet sets
    sets.resting = {
        main="Chatoyant Staff",
        sub="Oneiros Grip",
        head="Befouled Crown",
        neck="Chrys. Torque",
        ear1="Etiolation Earring",
        ear2="Ethereal Earring",
        body="Jhakri Robe +2",
        hands="Jhakri Cuffs +2",
        ring1="Defending Ring",
        ring2="Dark Ring",
        back="Umbra Cape",
        legs="Assid. Pants +1",
        feet="Jhakri Pigaches +2",
    }
    sets.idle = {
        main="Daybreak",
        sub="Sacro Bulwark",
        ammo="Homiliary",
        head="Geomancy Galero +1",
        neck="Null Loop",
        ear1="Alabaster Earring",
        ear2="Malignance Earring",
        body="Jhakri Robe +2",
        hands="Jhakri Cuffs +2",
        ring1="Ayanmo Ring",
        ring2="Murky Ring",
        back="Archon Cape",
        waist="Null Belt",
        legs="Assid. Pants +1",
        feet="Jhakri Pigaches +2",
        -- FUTURE EMPYREAN: head="Azimuth Hood +1",
        -- FUTURE RELIC: body="Bagua Tunic +1",
    }
    sets.idle.PDT = {
        main="Malignance Pole",
        sub="Umbra Strap",
        ammo="Staunch Tathlum +1",
        head="Nyame Helm",
        neck="Loricate Torque +1",
        ear1="Genmei Earring",
        ear2="Ethereal Earring",
        body="Jhakri Robe +2",
        hands="Nyame Gauntlets",
        ring1="Defending Ring",
        ring2="Dark Ring",
        back="Umbra Cape",
        waist="Carrier's Sash",
        legs="Nyame Flanchard",
        feet="Mallquis Clogs +2",
    }
    -- Luopan present: prioritize pet survival and GEO utility.
    sets.idle.Pet = {
        main="Solstice",
        sub="Culminus",
        range="Dunna",
        head="Geomancy Galero +1",
        neck="Loricate Torque +1",
        ear1="Enmerkar Earring",
        ear2="Alabaster Earring",
        body="Jhakri Robe +2",
        hands="Geo. Mitaines +1",
        ring1="Defending Ring",
        ring2="Dark Ring",
        back="Nantosuelta's Cape",
        waist="Isa Belt",
        legs="Psycloth Lappas",
        feet="Geomancy Sandals +1",
        -- FUTURE EMPYREAN: head="Azimuth Hood +1",
        -- FUTURE RELIC: feet="Bagua Sandals +1",
        -- FUTURE RELIC: neck="Bagua Charm +1",
    }
    sets.idle.PDT.Pet = {
        main="Malignance Pole",
        sub="Umbra Strap",
        range="Dunna",
        head="Geomancy Galero +1",
        neck="Loricate Torque +1",
        ear1="Handler's Earring",
        ear2="Handler's Earring +1",
        body="Jhakri Robe +2",
        hands="Geo. Mitaines +1",
        ring1="Defending Ring",
        ring2="Dark Ring",
        back="Nantosuelta's Cape",
        waist="Isa Belt",
        legs="Hagondes Pants +1",
        feet="Geomancy Sandals +1",
        -- FUTURE EMPYREAN: head="Azimuth Hood +1",
        -- FUTURE RELIC: feet="Bagua Sandals +1",
    }
    -- Indi sets are used while an Indi spell is active.
    sets.idle.Indi = set_combine(sets.idle, {})
    sets.idle.Pet.Indi = set_combine(sets.idle.Pet, {})
    sets.idle.PDT.Indi = set_combine(sets.idle.PDT, {})
    sets.idle.PDT.Pet.Indi = set_combine(sets.idle.PDT.Pet, {})
    sets.idle.Weak = set_combine(sets.idle.PDT, {})
    -- Defense sets
    sets.defense.PDT = {}
    sets.defense.MDT = {}
    sets.defense.MEVA = {}
    sets.defense.PetPDT = sets.idle.PDT.Pet
    sets.defense.NukeLock = sets.midcast['Elemental Magic']
    sets.defense.GeoLock = sets.midcast.Geomancy.Indi
    sets.Kiting = {
        feet="Geomancy Sandals +1",
    }
    sets.PetHP = {
        head="Geomancy Galero +1",
        back="Nantosuelta's Cape",
        -- FUTURE RELIC: head="Bagua Galero +1",
    }
    sets.latent_refresh = {
        waist="Fucho-no-obi",
    }
    sets.latent_refresh_grip = {
        sub="Oneiros Grip",
    }
    sets.DayIdle = {}
    sets.NightIdle = {}
    sets.HPDown = {}
    sets.buff.Doom = set_combine(sets.buff.Doom or {}, {})
    -- Engaged sets
    sets.engaged = {}
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
    sets.ResistantMagicBurst = set_combine(sets.MagicBurst, {})
    sets.buff.Sublimation = {
        waist="Embla Sash",
    }
    sets.buff.DTSublimation = {
        waist="Embla Sash",
    }
    -- Weapon sets
    -- Idris is not owned yet; use your current club and shield.
    sets.weapons.Idris = {
        main="Cath Palug Hammer",
        sub="Culminus",
        -- FUTURE WEAPON: main="Idris",
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
    sets.RecoverBurst = set_combine(sets.RecoverMP, {})
    sets.ResistantRecoverBurst = set_combine(sets.RecoverBurst, {})
    sets.MaxTP = {}
end

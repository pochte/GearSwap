-- Ullona_Cor_Gear.lua
-- COR gear setup. One item per line.
-- COR AF / relic / empyrean pieces are not owned yet; relevant upgrade targets remain commented.
-- AF = Chasseur's (Chass./Chas.), Relic = Laksamana's (Laksa.), Empy = Lanun.
-- Camulus's Mantle is the COR JSE cape; Null Shawl is the shared placeholder.
-- Weapons are selected by MainWeapon / OffWeapon / RangedWeapon states in COR.lua.

function user_job_setup()
    state.OffenseMode:options('Normal', 'Acc')
    state.RangedMode:options('Normal', 'Acc')
    state.WeaponskillMode:options('Match', 'Normal', 'Acc', 'Proc')
    state.CastingMode:options('Normal', 'Resistant')
    state.IdleMode:options('Normal', 'PDT', 'Refresh')
    state.HybridMode:options('Normal', 'DT')
    state.PhysicalDefenseMode:options('PDT')
    state.MagicalDefenseMode:options('MDT')
    state.ResistDefenseMode:options('MEVA')
    state.ExtraMeleeMode = M{['description']='Extra Melee Mode', 'None', 'DWMax'}
    state.CompensatorMode:options('Always', '300', '1000', 'Never')

    -- Placeholder ammo. Upgrade targets: Chrono Bullet (RA/physical WS),
    -- Orichalcum Bullet (magical WS), Animikii Bullet (Quick Draw).
    gear.RAbullet = 'Steel Bullet'
    gear.WSbullet = 'Steel Bullet'
    gear.MAbullet = 'Steel Bullet'
    gear.QDbullet = 'Steel Bullet'
    options.ammo_warning_limit = 15

    -- Shared placeholder for all Camulus's Mantle variants.
    gear.cor_jse_back = 'Null Shawl'

    send_command('bind ^` gs c cycle ElementalMode')
    send_command('bind !` gs c elemental quickdraw')
    send_command('bind ^backspace input /ja "Double-up" <me>')
    send_command('bind @backspace input /ja "Snake Eye" <me>')
    send_command('bind !backspace input /ja "Fold" <me>')
    send_command('bind ^@!backspace input /ja "Crooked Cards" <me>')
    send_command('bind ^\\ input /ja "Random Deal" <me>')
    send_command('bind !\\ input /ja "Bolter\'s Roll" <me>')
    send_command('bind ^@!\\ gs c toggle LuzafRing')
    send_command('bind @f7 gs c toggle RngHelper')

    -- Weapon loadouts.
    send_command('bind !r gs c set MainWeapon Naegling;gs c set OffWeapon GletisKnife')
    send_command('bind ^q gs c set MainWeapon Tauret;gs c set OffWeapon GletisKnife')
    send_command('bind @q gs c set MainWeapon Naegling;gs c set OffWeapon NuskuShield;gs c set RangedWeapon Gun1')
    send_command('bind !q gs c set MainWeapon Naegling;gs c set OffWeapon NuskuShield')
    send_command('bind ^a gs c set MainWeapon None;gs c set OffWeapon None;gs c set RangedWeapon None;gs c set WeaponskillMode Match')
    send_command('bind ^!f7 gs c cycle RangedWeapon')
    send_command('bind @pause roller roll')

    select_default_macro_book()
end

function user_job_unload()
    send_command('unbind ^`')
    send_command('unbind !`')
    send_command('unbind ^backspace')
    send_command('unbind @backspace')
    send_command('unbind !backspace')
    send_command('unbind ^@!backspace')
    send_command('unbind ^\\')
    send_command('unbind !\\')
    send_command('unbind ^@!\\')
    send_command('unbind @f7')
    send_command('unbind !r')
    send_command('unbind ^q')
    send_command('unbind @q')
    send_command('unbind !q')
    send_command('unbind ^a')
    send_command('unbind ^!f7')
    send_command('unbind @pause')
end

function init_gear_sets()
    -- Job abilities.
    sets.precast.JA['Triple Shot'] = {
        -- body="Chasseur's Frac +3", -- get: AF
    }
    sets.precast.JA['Snake Eye'] = {
        -- legs="Lanun Trews +3", -- get: Empy
    }
    sets.precast.JA['Wild Card'] = {
        -- feet="Lanun Bottes +3", -- get: Empy
    }
    sets.precast.JA['Random Deal'] = {
        -- body="Lanun Frac +3", -- get: Empy
    }
    sets.precast.FoldDoubleBust = {
        -- hands="Lanun Gants +3", -- get: Empy
    }

    -- Phantom Roll. Roll-specific JSE upgrades are listed below.
    sets.precast.CorsairRoll = {
        -- head="Lanun Tricorne +3", -- get: Empy (Phantom Roll+)
        head="Nyame Helm",
        neck="Null Loop",
        ear1="Alabaster Earring",
        ear2="Genmei Earring",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        -- hands="Chasseur's Gants +3", -- get: AF (Phantom Roll+)
        ring1="Murky Ring",
        ring2="Vertigo Ring",
        back=gear.cor_jse_back, -- get: Camulus's Mantle (Phantom Roll+)
        waist="Platinum Moogle Belt",
        legs="Malignance Tights",
        feet="Malignance Boots",
    }
    sets.precast.LuzafRing = {ring2="Luzaf's Ring"}

    -- get: Chas. Culottes +3 (Caster's), Chass. Bottes +3 (Courser's),
    -- Chass. Tricorne +3 (Blitzer's), Chasseur's Frac +3 (Tactician's),
    -- Chasseur's Gants +3 (Allies').
    sets.precast.CorsairRoll["Caster's Roll"] = set_combine(sets.precast.CorsairRoll, {})
    sets.precast.CorsairRoll["Courser's Roll"] = set_combine(sets.precast.CorsairRoll, {})
    sets.precast.CorsairRoll["Blitzer's Roll"] = set_combine(sets.precast.CorsairRoll, {})
    sets.precast.CorsairRoll["Tactician's Roll"] = set_combine(sets.precast.CorsairRoll, {})
    sets.precast.CorsairRoll["Allies' Roll"] = set_combine(sets.precast.CorsairRoll, {})

    -- Quick Draw: magic accuracy set.
    sets.precast.CorsairShot = {
        ammo=gear.QDbullet,
        head="Mummu Bonnet +2",
        neck="Sanctity Necklace",
        ear1="Crep. Earring",
        ear2="Hecate's Earring",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        ring1="Crepuscular Ring",
        ring2="Kishar Ring",
        back=gear.cor_jse_back,
        waist="Eschan Stone",
        legs="Malignance Tights",
        feet="Malignance Boots",
    }
    sets.precast.CorsairShot.Damage = set_combine(sets.precast.CorsairShot, {
        neck="Baetyl Pendant",
        hands="Leyline Gloves",
        ring1="Resonance Ring",
        ring2="Locus Ring",
        legs="SV Loincloth +1",
    })
    sets.precast.CorsairShot.Proc = {
        ammo=gear.RAbullet,
        head="Nyame Helm",
        neck="Null Loop",
        ear1="Genmei Earring",
        ear2="Alabaster Earring",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        ring1="Murky Ring",
        ring2="Vertigo Ring",
        back=gear.cor_jse_back,
        waist="Platinum Moogle Belt",
        legs="Malignance Tights",
        feet="Malignance Boots",
    }
    sets.precast.CorsairShot['Light Shot'] = set_combine(sets.precast.CorsairShot, {})
    sets.precast.CorsairShot['Dark Shot'] = set_combine(sets.precast.CorsairShot['Light Shot'], {ring2="Archon Ring"})

    sets.precast.Waltz = {hands="Slither Gloves +1", feet="Rawhide Boots"}
    sets.Self_Waltz = {ring1="Asklepian Ring"}
    sets.precast.Waltz['Healing Waltz'] = {}

    -- Fast Cast.
    sets.precast.FC = {
        head="Ejekamal Mask",
        neck="Voltsurge Torque",
        ear1="Loquac. Earring",
        ear2="Magnetic Earring",
        body="Malignance Tabard",
        hands="Leyline Gloves",
        ring1="Kishar Ring",
        ring2="Lebeche Ring",
        back=gear.cor_jse_back,
        waist="Platinum Moogle Belt",
        legs="Malignance Tights",
        feet="Malignance Boots",
    }
    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {neck="Magoraga Beads"})
    sets.precast.FC.Cure = set_combine(sets.precast.FC, {ear2="Mendi. Earring"})

    -- Snapshot.
    sets.precast.RA = {
        ammo=gear.RAbullet,
        head="Meghanada Visor +2",
        -- head="Chass. Tricorne +3", -- get: AF
        body="Malignance Tabard",
        -- body="Laksa. Frac +3", -- get: Relic
        hands="Nzame Bracers",
        ring1="Crepuscular Ring",
        back=gear.cor_jse_back, -- get: Camulus's Mantle (Snapshot+10)
        legs="Malignance Tights",
        -- legs="Laksa. Trews +3", -- get: Relic
        feet="Meg. Jam. +2",
    }
    sets.precast.RA.Flurry = set_combine(sets.precast.RA, {})
    sets.precast.RA.Flurry2 = set_combine(sets.precast.RA, {})

    -- Exactly two WS armour sets. Ammo is selected by COR.lua, not by these sets.
    -- Nyame is treated as Path B Rank 15.
    sets.precast.WS = {}
    sets.precast.WS.Melee = {
        head="Nyame Helm",
        neck="Fotia Gorget",
        ear1="Moonshade Earring",
        ear2="Ishvara Earring",
        body="Nyame Mail",
        hands="Nyame Gauntlets",
        ring1="Cornelia's Ring",
        ring2="Rufescent Ring",
        back=gear.cor_jse_back, -- get: Camulus's Mantle (STR+20 / WSD+10%)
        waist="Fotia Belt",
        legs="Nyame Flanchard",
        feet="Nyame Sollerets",
    }
    sets.precast.WS.Ranged = {
        head="Meghanada Visor +2",
        neck="Fotia Gorget",
        ear1="Moonshade Earring",
        ear2="Crep. Earring",
        body="Nyame Mail",
        hands="Meg. Gloves +2",
        ring1="Cornelia's Ring",
        ring2="Bellona's Ring",
        back=gear.cor_jse_back, -- get: Camulus's Mantle (AGI+20 / WSD+10%)
        waist="Fotia Belt",
        legs="Nyame Flanchard",
        feet="Meg. Jam. +2",
    }
    sets.precast.WS.Melee.Acc = set_combine(sets.precast.WS.Melee, {
        head="Meghanada Visor +2",
        neck="Null Loop",
        ear2="Crep. Earring",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        ring2="Mars's Ring",
        waist="Null Belt",
        legs="Malignance Tights",
        feet="Malignance Boots",
    })
    sets.precast.WS.Ranged.Acc = set_combine(sets.precast.WS.Ranged, {
        neck="Null Loop",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        ring2="Crepuscular Ring",
        waist="Null Belt",
        legs="Malignance Tights",
        feet="Malignance Boots",
    })
    sets.precast.WS.Acc = sets.precast.WS.Melee.Acc
    sets.precast.WS.Proc = {
        head="Nyame Helm",
        neck="Null Loop",
        ear1="Genmei Earring",
        ear2="Alabaster Earring",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        ring1="Murky Ring",
        ring2="Vertigo Ring",
        back=gear.cor_jse_back,
        waist="Platinum Moogle Belt",
        legs="Malignance Tights",
        feet="Malignance Boots",
    }

    -- Max TP compatibility placeholders retained for shared include expectations.
    sets.MaxTP = {}
    sets.AccMaxTP = {}

    -- Midcast.
    sets.midcast.FastRecast = set_combine(sets.precast.FC, {})
    sets.midcast.Cure = {
        head="Ejekamal Mask",
        ear1="Loquac. Earring",
        ear2="Mendi. Earring",
        body="Malignance Tabard",
        hands="Leyline Gloves",
        ring1="Janniston Ring",
        ring2="Lebeche Ring",
        back=gear.cor_jse_back,
        waist="Acerbic Sash +1",
        legs="Carmine Cuisses +1",
        feet="Malignance Boots",
    }
    sets.Self_Healing = {ring1="Kunaji Ring", ring2="Asklepian Ring"}
    sets.Cure_Received = {ring1="Kunaji Ring", ring2="Asklepian Ring"}
    sets.Self_Refresh = {}
    sets.midcast.Utsusemi = sets.midcast.FastRecast

    -- Ranged attack accuracy / damage.
    sets.midcast.RA = {
        ammo=gear.RAbullet,
        head="Meghanada Visor +2",
        neck="Null Loop",
        ear1="Crep. Earring",
        ear2="Chas. Earring +1",
        body="Malignance Tabard",
        -- body="Laksa. Frac +3", -- get: Relic
        hands="Meg. Gloves +2",
        ring1="Crepuscular Ring",
        ring2="Rajas Ring",
        back=gear.cor_jse_back, -- get: Camulus's Mantle (AGI/R.Acc/Store TP)
        waist="Eschan Stone",
        legs="Malignance Tights",
        -- legs="Laksa. Trews +3", -- get: Relic
        feet="Meg. Jam. +2",
    }
    sets.midcast.RA.Acc = set_combine(sets.midcast.RA, {ring2="Longshot Ring", waist="Null Belt"})
    sets.buff['Triple Shot'] = {
        -- body="Chasseur's Frac +3", -- get: AF
    }

    sets.DayIdle = {}
    sets.NightIdle = {}
    sets.buff.Doom = set_combine(sets.buff.Doom, {})
    sets.resting = {}

    -- Idle / defense.
    sets.idle = {
        ammo="Crepuscular Pebble",
        head="Nyame Helm",
        neck="Null Loop",
        ear1="Alabaster Earring",
        ear2="Genmei Earring",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        ring1="Murky Ring",
        ring2="Meghanada Ring",
        back="Archon Cape",
        waist="Platinum Moogle Belt",
        legs="Carmine Cuisses +1",
        feet="Malignance Boots",
    }
    sets.idle.PDT = {
        ammo="Crepuscular Pebble",
        head="Nyame Helm",
        neck="Null Loop",
        ear1="Alabaster Earring",
        ear2="Genmei Earring",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        ring1="Murky Ring",
        ring2="Meghanada Ring",
        back="Archon Cape",
        waist="Platinum Moogle Belt",
        legs="Malignance Tights",
        feet="Malignance Boots",
    }
    sets.idle.Refresh = set_combine(sets.idle, {})

    sets.defense.PDT = {
        ammo="Crepuscular Pebble",
        head="Nyame Helm",
        neck="Null Loop",
        ear1="Alabaster Earring",
        ear2="Genmei Earring",
        body="Nyame Mail",
        hands="Nyame Gauntlets",
        ring1="Murky Ring",
        ring2="Meghanada Ring",
        back="Archon Cape",
        waist="Platinum Moogle Belt",
        legs="Nyame Flanchard",
        feet="Nyame Sollerets",
    }
    sets.defense.MDT = {
        ammo="Crepuscular Pebble",
        head="Nyame Helm",
        neck="Null Loop",
        ear1="Alabaster Earring",
        ear2="Odnowa Earring +1",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        ring1="Murky Ring",
        ring2="Archon Ring",
        back=gear.cor_jse_back,
        waist="Platinum Moogle Belt",
        legs="Malignance Tights",
        feet="Malignance Boots",
    }
    sets.defense.MEVA = {
        ammo="Crepuscular Pebble",
        head="Nyame Helm",
        neck="Null Loop",
        ear1="Alabaster Earring",
        ear2="Odnowa Earring +1",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        ring1="Archon Ring",
        ring2="Shadow Ring",
        back=gear.cor_jse_back,
        waist="Null Belt",
        legs="Malignance Tights",
        feet="Malignance Boots",
    }

    sets.Kiting = {legs="Carmine Cuisses +1"}
    sets.TreasureHunter = set_combine(sets.TreasureHunter, {})
    sets.DWMax = {feet="Rawhide Boots"}

    -- Engaged.
    sets.engaged = {
        ammo="Ginsen",
        head="Nyame Helm",
        neck="Lissome Necklace",
        ear1="Cessance Earring",
        ear2="Crep. Earring",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        ring1="Petrov Ring",
        ring2="Rajas Ring",
        back=gear.cor_jse_back, -- get: Camulus's Mantle (DEX/Acc/Store TP)
        waist="Sailfi Belt +1",
        legs="Malignance Tights",
        feet="Malignance Boots",
    }
    sets.engaged.Acc = set_combine(sets.engaged, {neck="Null Loop", ring2="Mars's Ring", waist="Null Belt"})
    sets.engaged.DT = set_combine(sets.engaged, {
        neck="Null Loop",
        ear1="Alabaster Earring",
        ring1="Murky Ring",
        waist="Platinum Moogle Belt",
    })
    sets.engaged.Acc.DT = set_combine(sets.engaged.Acc, {ear1="Alabaster Earring", ring1="Murky Ring"})
    sets.engaged.DW = set_combine(sets.engaged, {})
    sets.engaged.DW.Acc = set_combine(sets.engaged.Acc, {})
    sets.engaged.DW.DT = set_combine(sets.engaged.DT, {})
    sets.engaged.DW.Acc.DT = set_combine(sets.engaged.Acc.DT, {})
end

function select_default_macro_book()
    set_macro_page(1, 9)
end

function user_job_lockstyle()
    send_command('input /lockstyleset 9')
end

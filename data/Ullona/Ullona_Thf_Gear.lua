-- CHANGELOG
-- 2026-11-24:
--   Added Malignance Chapeau.
--   Added dedicated weaponskill sets using owned equipment.
--   Added ranged attack accuracy set.
--   Updated MDT and MEVA headpiece.
--   Consolidated duplicate Hide definition.
--
-- 2026-11-19:
--   Replaced Ejekamal Mask with Nyame Helm in sets.precast.FC.
--   Added Platinum Moogle Belt to sets.Kiting.
--   Documented Pillager's Vest +1 purpose in sets.precast.JA['Hide'].

-- Ullona_Thf_Gear.lua

function user_job_setup()
    state.OffenseMode:options('Normal','SomeAcc','Acc','FullAcc','Fodder')
    state.HybridMode:options('Normal','DT')
    state.RangedMode:options('Normal', 'Acc')
    state.WeaponskillMode:options('Match','Normal','DT','SomeAcc','Acc','FullAcc','Fodder','Proc')
    state.IdleMode:options('Normal', 'Sphere')
    state.PhysicalDefenseMode:options('PDT')
    state.MagicalDefenseMode:options('MDT')
    state.ResistDefenseMode:options('MEVA')

    state.MainWeapon:options('None','Naegling','Tauret')
    state.OffWeapon:options('None','GletisKnife','Tauret','Sandung')
    state.RangedWeapon:options('None','Wingcutter')

    state.ExtraMeleeMode = M{
        ['description']='Extra Melee Mode',
        'None',
        'Suppa',
        'DWMax',
        'Parry'
    }

    state.AmbushMode = M(false, 'Ambush Mode')

    set_macro_page(1, 6)

    send_command('bind ^` input /ja "Flee" <me>')
    send_command('bind !` input /ra <t>')
    send_command('bind @` gs c cycle SkillchainMode')
    send_command('bind @f10 gs c toggle AmbushMode')
    send_command('bind ^backspace input /item "Thief\'s Tools" <t>')
    send_command('bind !q gs c set MainWeapon Naegling;gs c set OffWeapon GletisKnife;gs c set RangedWeapon Wingcutter')
    send_command('bind !backspace input /ja "Hide" <me>')
    send_command('bind ^a gs c set MainWeapon None;gs c set OffWeapon None;gs c set RangedWeapon None;gs c set WeaponskillMode Match')
    send_command('bind ^\\\\ input /ja "Despoil" <t>')
    send_command('bind !\\\\ input /ja "Mug" <t>')
end

function user_job_unload()
    send_command('unbind ^`')
    send_command('unbind !`')
    send_command('unbind @`')
    send_command('unbind @f10')
    send_command('unbind ^backspace')
    send_command('unbind !q')
    send_command('unbind !backspace')
    send_command('unbind ^a')
    send_command('unbind ^\\\\')
    send_command('unbind !\\\\')
end

function user_job_lockstyle()
    send_command('input /lockstyleset 5')
end

function init_gear_sets()

  
    -- SPECIAL SETS
  

    sets.TreasureHunter = {
        hands="Plunderer's Armlets +1",
        feet="Skulker's Poulaines +3",
        waist="Chaac Belt",
        ammo="Perfect Lucky Egg"
    }

    sets.Kiting = {
        feet="Pillager's Poulaines +1",
        waist="Platinum Moogle Belt"
    }

    sets.buff.Doom = set_combine(sets.buff.Doom, {})
    sets.buff.Sleep = {}

    sets.buff['Sneak Attack'] = {
        hands="Skulker's Armlets +2",
        back="Toutatis's Cape"
    }

    sets.buff['Trick Attack'] = {
        back="Toutatis's Cape",
        hands="Pillager's Armlets +1"
    }

  
    -- EXTRA MELEE
  

    sets.Knockback = {}
    sets.Suppa = {}
    sets.DWEarrings = {}

    sets.DWMax = {
        waist="Patentia Sash",
        feet="Rawhide Boots"
    }

    sets.Parry = {}
    sets.Ambush = {}

  
    -- TREASURE HUNTER / TAGGING
  

    sets.precast.Step = {
        head="Mummu Bonnet +2",
        neck="Null Loop",
        ear2="Cessance Earring",
        ear1="Sherida Earring",
        body="Mummu Jacket +2",
        hands="Leyline Gloves",
        ring1="Mars's Ring",
        ring2="Meghanada Ring",
        waist="Sailfi Belt +1",
        legs="SV Loincloth +1",
        feet="Plunderer's Poulaines",
        ammo="Perfect Lucky Egg"
    }

    sets.precast.JA['Violent Flourish'] = {}

    sets.precast.JA['Animated Flourish'] =
        set_combine(sets.TreasureHunter, {})

    sets.precast.JA.Provoke =
        set_combine(sets.TreasureHunter, {})

  
    -- JOB ABILITIES
  

    sets.precast.JA['Collaborator'] = {
        head="Skulker's Bonnet +2"
    }

    sets.precast.JA['Accomplice'] = {
        head="Skulker's Bonnet +2"
    }

    sets.precast.JA['Flee'] = {
        feet="Pillager's Poulaines +1"
    }

    sets.precast.JA['Hide'] = {
        body="Pillager's Vest +1"
    }

    sets.precast.JA['Conspirator'] = {
        head="Skulker's Bonnet +2",
        body="Skulker's Vest +2",
        hands="Skulker's Armlets +2",
        legs="Skulker's Culottes +3",
        feet="Skulker's Poulaines +3"
    }

    sets.precast.JA['Steal'] = {
        legs="Pillager's Culottes +1",
        feet="Pillager's Poulaines +1",
        hands="Pillager's Armlets +1"
    }

    sets.precast.JA['Mug'] = {
        head="Plunderer's Bonnet"
    }

    sets.precast.JA['Despoil'] = {
        feet="Skulker's Poulaines +3",
        legs="Skulker's Culottes +3"
    }

    sets.precast.JA['Perfect Dodge'] = {
        hands="Plunderer's Armlets +1"
    }

    sets.precast.JA['Feint'] = {
        legs="Plunderer's Culottes +1"
    }

    sets.precast.JA["Assassin's Charge"] = {}

    sets.precast.JA['Sneak Attack'] =
        set_combine(sets.buff['Sneak Attack'], {})

    sets.precast.JA['Trick Attack'] =
        set_combine(sets.buff['Trick Attack'], {})

  
    -- WALTZ
  

    sets.precast.Waltz = {
        body="Gleti's Cuirass",
        head="Mummu Bonnet +2",
        hands="Slither Gloves +1",
        ring1="Asklepian Ring",
        feet="Rawhide Boots",
        ammo="Yamarang"
    }

    sets.Self_Waltz = set_combine(sets.precast.Waltz, {})

    sets.precast.Waltz['Healing Waltz'] =
        set_combine(sets.precast.Waltz, {})

  
    -- FAST CAST
  

    sets.precast.FC = {
        head="Nyame Helm",
        ear1="Alabaster Earring",
        ear2="Loquacious Earring",
        body="Skulker's Vest +2",
        hands="Leyline Gloves",
        waist="Cornelia's Belt",
        feet="Mummu Gamashes +2",
        legs="Malignance Tights",
        ring2="Murky Ring",
        neck="Voltsurge Torque",
        ring1="Lebeche Ring"
    }

    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {
        neck="Magoraga Beads",
        hands="Rawhide Gloves"
    })

  
    -- RANGED ATTACK
  

    sets.precast.RA = {}

    sets.midcast.RA = {
        head="Malignance Chapeau"
    }

    sets.midcast.RA.Acc = set_combine(sets.midcast.RA, {
        neck="Null Loop",
        waist="Null Belt"
    })

  
    -- WEAPONSKILLS - GENERAL
    -- Nyame assumed Path B Rank 15.
  

    sets.precast.WS = {
        head="Nyame Helm",
        neck="Fotia Gorget",
        ear1="Moonshade Earring",
        ear2="Ishvara Earring",
        body="Nyame Mail",
        hands="Nyame Gauntlets",
        ring1="Cornelia's Ring",
        ring2="Rufescent Ring",
        back="Toutatis's Cape",
        waist="Fotia Belt",
        legs="Nyame Flanchard",
        feet="Nyame Sollerets",
        ammo="Oshasha's Treatise"
    }

  
    -- WEAPONSKILL ACCURACY MODES
  

    sets.precast.WS.SomeAcc = set_combine(sets.precast.WS, {
        hands="Leyline Gloves",
        ring2="Meghanada Ring",
        ear2="Crepuscular Earring"
    })

    sets.precast.WS.Acc = set_combine(sets.precast.WS.SomeAcc, {
        neck="Sanctity Necklace",
        waist="Null Belt"
    })

    sets.precast.WS.FullAcc = set_combine(sets.precast.WS.Acc, {
        ring1="Mars's Ring",
        ear1="Alabaster Earring"
    })

    sets.precast.WS.DT = set_combine(sets.precast.WS, {
        head="Malignance Chapeau",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        legs="Malignance Tights",
        feet="Malignance Boots",
        ring1="Murky Ring",
        ring2="Meghanada Ring"
    })

    sets.precast.WS.Fodder = set_combine(sets.precast.WS, {
        back="Null Shawl"
    })

    sets.precast.WS.Proc = set_combine(sets.precast.WS, {
        head="Malignance Chapeau",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        legs="Malignance Tights",
        feet="Malignance Boots",
        neck="Null Loop",
        ring1="Mars's Ring",
        ring2="Meghanada Ring"
    })

  
    -- WS TP PRESERVATION
  

    sets.MaxTP = {}
    sets.AccMaxTP = {}

  
    -- DEDICATED WEAPONSKILL SETS
    -- Built only from equipment present in your supplied file.
  

    -- Rudra's Storm: DEX/WSD-oriented single-hit WS.
    sets.precast.WS["Rudra's Storm"] = set_combine(sets.precast.WS, {
        head="Nyame Helm",
        body="Nyame Mail",
        hands="Nyame Gauntlets",
        legs="Nyame Flanchard",
        feet="Nyame Sollerets",
        neck="Fotia Gorget",
        waist="Fotia Belt",
        ring1="Cornelia's Ring",
        ring2="Rufescent Ring"
    })

    -- Evisceration: critical hit / multi-hit focus.
    sets.precast.WS["Evisceration"] = set_combine(sets.precast.WS, {
        head="Mummu Bonnet +2",
        body="Mummu Jacket +2",
        hands="Mummu Wrists +2",
        legs="Mummu Kecks +2",
        feet="Mummu Gamashes +2",
        neck="Fotia Gorget",
        waist="Fotia Belt",
        ear1="Sherida Earring",
        ear2="Cessance Earring",
        ring1="Mars's Ring",
        ring2="Meghanada Ring"
    })

    -- Savage Blade: physical WSD/attack focused.
    sets.precast.WS["Savage Blade"] = set_combine(sets.precast.WS, {
        head="Nyame Helm",
        body="Nyame Mail",
        hands="Nyame Gauntlets",
        legs="Nyame Flanchard",
        feet="Nyame Sollerets",
        neck="Fotia Gorget",
        waist="Fotia Belt",
        ring1="Cornelia's Ring",
        ring2="Rufescent Ring"
    })

    -- Mandalic Stab: single-hit physical WS.
    sets.precast.WS["Mandalic Stab"] = set_combine(sets.precast.WS, {
        head="Nyame Helm",
        body="Nyame Mail",
        hands="Nyame Gauntlets",
        legs="Nyame Flanchard",
        feet="Nyame Sollerets",
        neck="Fotia Gorget",
        waist="Fotia Belt",
        ring1="Cornelia's Ring",
        ring2="Rufescent Ring"
    })

    -- Exenterator: multi-hit AGI WS.
    sets.precast.WS["Exenterator"] = set_combine(sets.precast.WS, {
        head="Mummu Bonnet +2",
        body="Mummu Jacket +2",
        hands="Mummu Wrists +2",
        legs="Mummu Kecks +2",
        feet="Mummu Gamashes +2",
        neck="Fotia Gorget",
        waist="Fotia Belt",
        ear1="Sherida Earring",
        ear2="Cessance Earring",
        ring1="Mars's Ring",
        ring2="Meghanada Ring"
    })

    -- Aeolian Edge: magic WS.
    sets.precast.WS["Aeolian Edge"] = set_combine(sets.precast.WS, {
        head="Nyame Helm",
        body="Nyame Mail",
        hands="Nyame Gauntlets",
        legs="Nyame Flanchard",
        feet="Nyame Sollerets",
        neck="Sanctity Necklace",
        waist="Fotia Belt",
        ring1="Cornelia's Ring",
        ring2="Murky Ring"
    })

  
    -- MIDCAST
  

    sets.midcast.FastRecast = {}

    sets.midcast.Utsusemi = set_combine(sets.midcast.FastRecast, {
        neck="Magoraga Beads"
    })

  
    -- MELEE SETS
  

    sets.engaged = {
        head="Malignance Chapeau",
        feet="Malignance Boots",
        neck="Anu Torque",
        ear2="Skulker's Earring",
        ear1="Sherida Earring",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        ring1="Petrov Ring",
        ring2="Rajas Ring",
        back="Toutatis's Cape",
        waist="Sailfi Belt +1",
        legs="Malignance Tights",
        ammo="Crepuscular Pebble"
    }

    sets.engaged.SomeAcc = set_combine(sets.engaged, {
        waist=gear.default.waist,
        neck="Sanctity Necklace",
        ear2="Cessance Earring"
    })

    sets.engaged.Acc = set_combine(sets.engaged.SomeAcc, {
        neck="Null Loop",
        ring1="Mars's Ring"
    })

    sets.engaged.FullAcc = set_combine(sets.engaged.Acc, {
        ring1="Mars's Ring",
        ear2="Cessance Earring",
        waist="Null Belt"
    })

    sets.engaged.Fodder = set_combine(sets.engaged, {
        back="Null Shawl"
    })

    sets.engaged.DT = set_combine(sets.engaged, {
        head="Malignance Chapeau",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        legs="Malignance Tights",
        feet="Malignance Boots",
        ring1="Murky Ring",
        ring2="Meghanada Ring"
    })

    sets.engaged.SomeAcc.DT = set_combine(sets.engaged.SomeAcc, sets.engaged.DT)
    sets.engaged.Acc.DT = set_combine(sets.engaged.Acc, sets.engaged.DT)
    sets.engaged.FullAcc.DT = set_combine(sets.engaged.FullAcc, sets.engaged.DT)
    sets.engaged.Fodder.DT = set_combine(sets.engaged.Fodder, sets.engaged.DT)

  
    -- IDLE / RESTING
  

    sets.resting = {}

    sets.idle = set_combine(sets.engaged, {
        head="Gleti's Mask",
        body="Gleti's Cuirass",
        hands="Gleti's Gauntlets",
        legs="Gleti's Breeches",
        feet="Gleti's Boots",
        waist="Null Belt"
    })

    sets.idle.Sphere = set_combine(sets.idle, {
        waist="Null Belt"
    })

    sets.idle.Weak = set_combine(sets.idle, {})

    sets.DayIdle = set_combine(sets.idle, {})
    sets.NightIdle = set_combine(sets.idle, {})

    sets.ExtraRegen = set_combine(sets.idle, {
        waist="Null Belt"
    })

  
    -- DEFENSE SETS
  

    -- Physical defense: retain Gleti's Mask for PDT.
    sets.defense.PDT = {
        ammo="Crepuscular Pebble",
        head="Gleti's Mask",
        neck="Null Loop",
        ear1="Alabaster Earring",
        ear2="Genmei Earring",
        body="Malignance Tabard",
        hands="Gleti's Gauntlets",
        ring1="Murky Ring",
        ring2="Meghanada Ring",
        back="Archon Cape",
        waist="Platinum Moogle Belt",
        legs="Malignance Tights",
        feet="Malignance Boots"
    }

    -- Magic defense: Malignance Chapeau for DT and magic evasion.
    sets.defense.MDT = {
        ammo="Crepuscular Pebble",
        head="Malignance Chapeau",
        neck="Null Loop",
        ear1="Alabaster Earring",
        ear2="Odnowa Earring +1",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        ring1="Murky Ring",
        ring2="Archon Ring",
        back="Null Shawl",
        waist="Platinum Moogle Belt",
        legs="Malignance Tights",
        feet="Malignance Boots"
    }

    -- Magic evasion: Malignance Chapeau.
    sets.defense.MEVA = {
        ammo="Crepuscular Pebble",
        head="Malignance Chapeau",
        neck="Null Loop",
        ear1="Alabaster Earring",
        ear2="Odnowa Earring +1",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        ring1="Archon Ring",
        ring2="Shadow Ring",
        back="Null Shawl",
        waist="Null Belt",
        legs="Malignance Tights",
        feet="Malignance Boots"
    }

  
    -- HASTE PRESETS
  

    sets.engaged.Haste_15 = set_combine(sets.engaged, {})
    sets.engaged.Haste_30 = set_combine(sets.engaged, {})
    sets.engaged.MaxHaste = set_combine(sets.engaged, {})

    ----- placeholder  
end

-- Ullona_Thf_Gear.lua
function user_job_setup()
    -- Options: Override default values
    state.OffenseMode:options('Normal','SomeAcc','Acc','FullAcc','Fodder')
    state.HybridMode:options('Normal','DT')
    state.RangedMode:options('Normal', 'Acc')
    state.WeaponskillMode:options('Match','Normal','DT','SomeAcc','Acc','FullAcc','Fodder','Proc')
    state.IdleMode:options('Normal', 'Sphere')
    state.PhysicalDefenseMode:options('PDT')
    state.MagicalDefenseMode:options('MDT')
    state.ResistDefenseMode:options('MEVA')

    -- Weapon states are constructed in THF.lua's job_setup().
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

    -- Macro Book
    set_macro_page(1, 6)

    -- Additional local binds
    send_command('bind ^` input /ja "Flee" <me>')                   -- Ctrl + ` : Flee
    send_command('bind !` input /ra <t>')                           -- Alt + ` : Ranged attack
    send_command('bind @` gs c cycle SkillchainMode')               -- Win + ` : Cycle SkillchainMode
    send_command('bind @f10 gs c toggle AmbushMode')                -- Win + F10 : Toggle AmbushMode
    send_command('bind ^backspace input /item "Thief\'s Tools" <t>') -- Ctrl + Backspace
    send_command('bind !q gs c set MainWeapon Naegling;gs c set OffWeapon GletisKnife;gs c set RangedWeapon Wingcutter') -- Alt + Q
    send_command('bind !backspace input /ja "Hide" <me>')           -- Alt + Backspace : Hide
    send_command('bind ^a gs c set MainWeapon None;gs c set OffWeapon None;gs c set RangedWeapon None;gs c set WeaponskillMode Match') -- Ctrl + A
    send_command('bind ^\\\\ input /ja "Despoil" <t>')              -- Ctrl + \
    send_command('bind !\\\\ input /ja "Mug" <t>')                  -- Alt + \
end

-- Clear every bind this file sets so they don't linger after a job change/reload.
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
    -- Delay is necessary for the game to finish loading the equipment model.
    send_command('input /lockstyleset 5')
end

-- Define sets and vars used by this job file.
function init_gear_sets()
    -- Special sets
    sets.TreasureHunter = {
        hands="Plunderer's Armlets +1",
        feet="Skulker's Poulaines +3",
        waist="Chaac Belt",
        ammo="Perfect Lucky Egg"
    }

    sets.Kiting = {
        feet="Pillager's Poulaines +1"
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

    -- Extra Melee sets. Apply these on top of melee sets.
    sets.Knockback = {}
    sets.Suppa = {}
    sets.DWEarrings = {}
    sets.DWMax = {
        waist="Patentia Sash", -- Enhances Dual Wield
        feet="Rawhide Boots" -- Dual Wield+3
    }
    sets.Parry = {}
    sets.Ambush = {}

    -- Weapons:
    -- Main/Off/Ranged are locked independently via state.MainWeapon,
    -- state.OffWeapon, and state.RangedWeapon, forced every pass in
    -- THF.lua's job_customize_idle_set/melee_set.
    --
    -- No sets.weapons.* table is needed here.
    -- MainWeapon=Tauret and OffWeapon=GletisKnife replace the old
    -- duplicated Tauret + Gleti's Knife weapon sets.
    -- RangedWeapon=Wingcutter and ammo handling are handled by
    -- the customize functions.
    -- OffWeapon=Sandung is the TH-farming pick.

    -- Actions used to tag Treasure Hunter.
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

    -- Precast Job Abilities
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

    -- Waltz set (CHR and VIT)
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

    -- Fast Cast
    sets.precast.FC = {
        head="Ejekamal Mask",
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
        neck="Magoraga Beads"
    })

    -- Ranged snapshot gear
    sets.precast.RA = {}

    -- Weaponskill sets
    -- General-purpose set for weaponskills without a dedicated set.
    -- Nyame assumed Path B, Rank 15.

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

    -- Accuracy overlay
    sets.precast.WS.SomeAcc = set_combine(sets.precast.WS, {
        hands="Leyline Gloves",
        ring2="Meghanada Ring",
        ear2="Crepuscular Earring"
    })

    sets.precast.WS.Acc = set_combine(sets.precast.WS.SomeAcc, {})
    sets.precast.WS.FullAcc = set_combine(sets.precast.WS.Acc, {})

    -- Swap to these when using Moonshade with WS at 3000 TP.
    sets.MaxTP = {}
    sets.AccMaxTP = {}

    -- Midcast sets
    sets.midcast.FastRecast = {}

    -- Specific spells
    sets.midcast.Utsusemi = set_combine(sets.midcast.FastRecast, {
        neck="Magoraga Beads"
    })

    -- Ranged gear
    sets.midcast.RA = {}
    sets.midcast.RA.Acc = {}

    -- Melee sets
    -- MUST be defined before sets.idle, which combines onto sets.engaged.
    sets.engaged = {
        head="Gleti's Mask",
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

    sets.engaged.DT = set_combine(sets.engaged, {})

    sets.engaged.SomeAcc.DT = set_combine(sets.engaged.SomeAcc, {})
    sets.engaged.Acc.DT = set_combine(sets.engaged.Acc, {})
    sets.engaged.FullAcc.DT = set_combine(sets.engaged.FullAcc, {})
    sets.engaged.Fodder.DT = set_combine(sets.engaged.Fodder, {})

    -- Idle/resting/defense sets
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

    -- Defense sets
    -- Defense sets don't touch main/sub/range: weapons are locked via MainWeapon/OffWeapon/RangedWeapon.
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
        feet="Malignance Boots",
    }

    sets.defense.MDT = {
        ammo="Crepuscular Pebble",
        head="Gleti's Mask",
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
        feet="Malignance Boots",
    }

    sets.defense.MEVA = {
        ammo="Crepuscular Pebble",
        head="Gleti's Mask",
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
        feet="Malignance Boots",
    }

    sets.engaged.Haste_15 = {}
    sets.engaged.Haste_30 = {}
    sets.engaged.MaxHaste = {}

    ----- placeholder -----
end
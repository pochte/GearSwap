-- CHANGELOG
-- 2026-11-19: Elite Royal Collar (San d'Oria citizen: Regen+3, DT-5%) now the neck in sets.idle / sets.idle.PDT (1 set(s)); replaces Null Loop there (Null Loop kept in all other sets).
-- 2026-11-19: Added Platinum Moogle Belt to sets.Kiting (moved out of idle).

-- Ullona_Rdm_Gear.lua — Changelog
-- 2026-10-15: [FIX] Standardized repeated ring and earring slot assignments.
--             Fixed duplicate ring2 in Elemental Magic.
--             Fixed duplicate Self_Refresh definitions, preserving both
--             Amalric Coif +1 and Inspirited Boots.
--             Standardized Alabaster Earring to ear2, Malignance Earring
--             to ear1, Murky Ring to ring2, and Mars's Ring to ring2.
--

ws_by_main_weapon = {
    Tauret = 'Exenterator',
    KajaRod = 'Black Halo',
}
ws_by_main_weapon_default = 'Savage Blade'
include('smart-ws.lua')

function user_job_setup()
    state.OffenseMode:options('Normal','Acc','FullAcc')
    state.HybridMode:options('Normal','DT')
    state.WeaponskillMode:options('Match','Proc')
    state.AutoBuffMode:options('Off','Auto','AutoMelee')
    state.CastingMode:options('Normal','Resistant','Fodder','Proc','MB','MB Resistant')
    state.IdleMode:options('Normal','PDT','MDT')
    state.PhysicalDefenseMode:options('PDT','NukeLock')
    state.MagicalDefenseMode:options('MDT')
    state.ResistDefenseMode:options('MEVA')

    state.MainWeapon:options('None','Naegling','KajaRod','Tauret')
    state.OffWeapon:options('Culminus','SacroBulwark','ArchdukeShield','DemersalDegen','Machaera','GletisKnife','Daybreak','None')

    -- Macro Book
    set_macro_page(1, 3)

    -- Modifier key: ^ = Ctrl, ! = Alt, @ = Win, ~ = Shift
    send_command('bind ^@!` input /ja "Accession" <me>')
    send_command('bind ^backspace input /ja "Saboteur" <me>')
    send_command('bind !backspace input /ja "Spontaneity" <t>')
    send_command('bind @backspace input /ja "Composure" <me>')
    send_command('bind != input /ja "Penury" <me>')
    send_command('bind @= input /ja "Parsimony" <me>')
    send_command('bind ^delete input /ja "Dark Arts" <me>')
    send_command('bind !pause input /ja "Light Arts" <me>')
    send_command('bind !delete input /ja "Addendum: Black" <me>')
    send_command('bind @delete input /ja "Manifestation" <me>')
    send_command('bind @f10 gs c smartna')
end

-- Clear every bind this file sets so they don't linger after a job change/reload.
function user_job_unload()
    send_command('unbind ^@!`')
    send_command('unbind ^backspace')
    send_command('unbind !backspace')
    send_command('unbind @backspace')
    send_command('unbind !=')
    send_command('unbind @=')
    send_command('unbind ^delete')
    send_command('unbind !pause')
    send_command('unbind !delete')
    send_command('unbind @delete')
    send_command('unbind @f10')
end

function user_job_lockstyle()
    send_command('input /lockstyleset 3')
end

function init_gear_sets()
    -- Weapons are independently locked through state.MainWeapon / state.OffWeapon.
    -- smart-ws.lua handles gs c castws.

    -- Precast Sets
    sets.precast.JA['Chainspell'] = {body="Vitiation Tabard +4"}

    sets.precast.Waltz = {}
    sets.precast.Waltz['Healing Waltz'] = {}

    -- Fast Cast
    sets.precast.FC = {
        main="Emissary",
        sub="Culminus",
        head="Atrophy Chapeau +4",
        body="Vitiation Tabard +4",
        legs="Ayanmo Cosciales +2",
        hands="Leyline Gloves",
        feet="Bunzi's Sabots",
        ear1="Malignance Earring",
        ear2="Lethargy Earring",
        ring1="Naji's Loop",
        ring2="Kishar Ring",
        waist="Embla Sash",
        neck="Voltsurge Torque"
    }

    sets.precast.FC.Enfeebling = set_combine(sets.precast.FC, {
        head="Lethargy Chappel +3"
    })

    sets.precast.Stoneskin = set_combine(sets.precast.FC, {
        waist="Siegel Sash",
        legs="Querkening Brais"
    })

    sets.precast.FC.Impact = set_combine(sets.precast.FC, {
        head=empty,
        body="Twilight Cloak",
        ring1="Archon Ring"
    })

    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {
        neck="Magoraga Beads"
    })

    sets.precast.FC.Dispelga = set_combine(sets.precast.FC, {
        main="Daybreak",
        sub="Culminus"
    })

    sets.precast['Healing Magic'] = set_combine(sets.precast.FC, {
        main="Daybreak",
        sub="Sors Shield",
        legs="Doyen Pants",
        body="Vanya Robe"
    })

    -- Weaponskill sets
    -- General-purpose physical WS set.
    -- Nyame assumed Path B, Rank 15.

    sets.precast.WS = {
        head="Nyame Helm",
        body="Egbesu Frock",
        legs="Nyame Flanchard",
        hands="Atrophy Gloves +4",
        feet="Nyame Sollerets",
        neck="Fotia Gorget",
        back="Sucellos's Cape",
        waist="Fotia Belt",
        ear1="Crepuscular Earring",
        ear2="Ishvara Earring",
        ring1="Cornelia's Ring",
        ring2="Mars's Ring",
        ammo="Oshasha's Treatise",
        range = empty
    }

    sets.precast.WS.Proc = sets.precast.WS

    sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {
        ear1="Moonshade Earring"
    })

    sets.precast.WS['Exenterator'] = set_combine(sets.precast.WS, {})

    sets.precast.WS['Black Halo'] = set_combine(sets.precast.WS, {
        ear1="Moonshade Earring"
    })

    -- Midcast Sets
    sets.RecoverMP = {}
    sets.midcast.FastRecast = sets.precast.FC

    sets.midcast['Healing Magic'] = {
        main="Bunzi's Rod",
        sub="Sacro Bulwark",
        head="Vanya Hood",
        body="Bunzi's Robe",
        hands="Bokwus Gloves",
        neck="Nodens Gorget",
        ear1="Gifted Earring",
        ear2="Mendicant's Earring",
        ring1="Naji's Loop",
        ring2="Janniston Ring",
        back="Ghostfyre Cape",
        legs="Atrophy Tights +3",
        feet="Vanya Clogs",
    }

    sets.precast.Cure = set_combine(sets.midcast['Healing Magic'], {
        legs="Doyen Pants",
        body="Vanya Robe",
        main="Daybreak",
        sub="Sors Shield",
        back="Pahtli Cape"
    })

    sets.midcast.Cure = set_combine(sets.midcast['Healing Magic'], {})

    sets.midcast.LightWeatherCure = {
        main="Chatoyant Staff",
        sub="Clemency Grip",
    }

    sets.midcast.LightDayCure = set_combine(sets.midcast['Healing Magic'], {
        main="Chatoyant Staff",
        sub="Clemency Grip",
    })

    sets.midcast.StatusRemoval = set_combine(sets.midcast.FastRecast, {})

    sets.midcast.Cursna = set_combine(sets.midcast['Healing Magic'], {
        neck="Nodens Gorget",
        hands="Bokwus Gloves",
        back="Tempered Cape +1",
        waist="Cornelia's Belt",
        feet="Vanya Clogs"
    })

    sets.midcast.Curaga = set_combine(sets.midcast['Healing Magic'], {})

    sets.Self_Healing = {}
    sets.Cure_Received = {}

    -- Enhancing Magic
-- Enhancing Magic
sets.precast['Enhancing Magic'] = set_combine(sets.precast.FC, {
    main="Daybreak",
    sub="Ammurapi Shield",
})

-- General Enhancing Magic (Duration)
sets.midcast['Enhancing Magic'] = {
    main="Daybreak",
    sub="Ammurapi Shield",
    head="Lethargy Chappel +3",
    body="Lethargy Sayon +3",
    legs="Lethargy Fuseau +3",
    hands="Lethargy Gantherots +3",
    feet="Lethargy Houseaux +3",
    neck="Duelist's Torque +1",
    ear1="Andoaa Earring",
    ear2="Lethargy Earring",
    ring1="Lebeche Ring",
    ring2="Murky Ring",
    back="Sucellos's Cape",
    waist="Embla Sash"
}

-- Enhancing Magic Skill / Potency
sets.EnhancingSkill = set_combine(sets.midcast['Enhancing Magic'], {
    back="Ghostfyre Cape",
    hands="Vitiation Gloves +3"
})

-- Protect / Shell (Duration)
sets.midcast.Protect = set_combine(sets.midcast['Enhancing Magic'], {
    ring1="Sheltered Ring",
})

sets.midcast.Shell = sets.midcast.Protect

-- Composure: Other targets
sets.buff.ComposureOther = {
    head="Lethargy Chappel +3",
    body="Lethargy Sayon +3",
    legs="Lethargy Fuseau +3",
    hands="Lethargy Gantherots +3",
    feet="Lethargy Houseaux +3",
}

-- Boost-Stat spells
sets.midcast.BoostStat = set_combine(sets.EnhancingSkill, {
    hands="Vitiation Gloves +3"
})

-- Self Refresh
sets.Self_Refresh = set_combine(sets.midcast['Enhancing Magic'], {
    head="Umuthi Hat",
    feet="Inspirited Boots"
})

-- Regen
sets.midcast.Regen = set_combine(sets.midcast['Enhancing Magic'], {
    main="Bolelabunga",
    sub="Ammurapi Shield",
    feet="Bunzi's Sabots",
})

-- Bar-element spells (Skill)
sets.midcast.BarElement = set_combine(sets.EnhancingSkill, {
    hands="Vitiation Gloves +3"
})

-- Temper (Skill / Potency)
sets.midcast.Temper = set_combine(sets.EnhancingSkill, {})
sets.midcast.Temper.DW = set_combine(sets.midcast.Temper, {})

-- Enspell (Skill / Potency)
sets.midcast.Enspell = set_combine(sets.EnhancingSkill, {
    legs="Vitiation Tights +4",
    head="Umuthi Hat",
    main="Archduke's Sword"
})

sets.midcast.Enspell.DW = set_combine(sets.midcast.Enspell, {})

-- Stoneskin (Skill / Potency)
sets.midcast.Stoneskin = set_combine(sets.EnhancingSkill, {
    waist="Siegel Sash",
    legs="Shedir Seraweels",
    head="Umuthi Hat",
    neck="Nodens Gorget",
})

-- Spikes
sets.midcast.ShockSpikes = set_combine(sets.midcast['Enhancing Magic'], {
    legs="Vitiation Tights +4"
})

sets.midcast.BlazeSpikes = set_combine(sets.midcast.ShockSpikes, {})
sets.midcast.IceSpikes = set_combine(sets.midcast.ShockSpikes, {})

-- Gain spells (Skill / Potency)
sets.midcast.Gain = set_combine(sets.EnhancingSkill, {
    hands="Vitiation Gloves +3"
})

-- Phalanx (Skill / Potency)
sets.midcast.Phalanx = set_combine(sets.EnhancingSkill, {
    back="Ghostfyre Cape",
})
-- Future Phalanx+ gear goes here.
sets.midcast.Phalanx.Self = set_combine(sets.midcast.Phalanx, {})


    -- Midcast: Enfeebling Magic
    sets.midcast['Enfeebling Magic'] = {
        main="Mpaca's Staff",
        sub="Daduchos Grip",
        head="Vitiation Chapeau +4",
        body="Lethargy Sayon +3",
        legs="Lethargy Fuseau +3",
        hands="Lethargy Gantherots +3",
        feet="Vitiation Boots +3",
        neck="Duelist's Torque +1",
        ear1="Malignance Earring",
        ear2="Lethargy Earring",
        ring1="Crepuscular Ring",
        ring2="Kishar Ring",
        back="Sucellos's Cape",
        waist="Null Belt",
        range = empty,
        ammo="Regal Gem"
    }

    sets.midcast['Enfeebling Magic'].Resistant = set_combine(sets.midcast['Enfeebling Magic'], {
        back="Null Shawl",
        ear1="Snotra Earring",
        sub="Daduchos Grip",
        ring1="Vertigo Ring",
        neck="Null Loop",
    })

    sets.midcast.DurationOnlyEnfeebling = set_combine(sets.midcast['Enfeebling Magic'], {
        body="Atrophy Tabard +4",
        ear1="Snotra Earring",
        waist="Obstinate Sash",
                main="Chatoyant Staff"
    })

    sets.midcast.Silence = set_combine(sets.midcast.DurationOnlyEnfeebling, {})
    sets.midcast.Silence.Resistant = sets.midcast['Enfeebling Magic'].Resistant

    sets.midcast.Sleep = set_combine(sets.midcast.DurationOnlyEnfeebling, {})
    sets.midcast.Sleep.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {
        waist="Null Belt"
    })

    sets.midcast.Bind = set_combine(sets.midcast.DurationOnlyEnfeebling, {})
    sets.midcast.Bind.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {
        waist="Null Belt"
    })

    sets.midcast.Break = set_combine(sets.midcast.DurationOnlyEnfeebling, {})
    sets.midcast.Break.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {
        waist="Null Belt"
    })

    sets.midcast.Dispel = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {})

    sets.midcast.Dispelga = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {
        main="Daybreak",
        sub="Culminus"
    })

    sets.midcast.SkillBasedEnfeebling = set_combine(sets.midcast['Enfeebling Magic'], {
        ear2="Alabaster Earring"
    })

    sets.midcast['Frazzle II'] = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {})

    sets.midcast['Frazzle III'] = set_combine(sets.midcast.SkillBasedEnfeebling, {})
    sets.midcast['Frazzle III'].Resistant = sets.midcast['Enfeebling Magic'].Resistant

    sets.midcast['Distract III'] = set_combine(sets.midcast.SkillBasedEnfeebling, {})
    sets.midcast['Distract III'].Resistant = sets.midcast['Enfeebling Magic'].Resistant

    sets.midcast['Gravity'] = set_combine(sets.midcast.SkillBasedEnfeebling, {
        legs="Chironic Hose"
    })

    sets.midcast['Gravity II'] = sets.midcast['Gravity']

    -- Elemental Magic
    sets.midcast['Elemental Magic'] = {
        main="Marin Staff +1",
        sub="Daduchos Grip",
        ammo="Ghastly Tathlum",
        head="Lethargy Chappel +3",
        body="Bunzi's Robe",
        legs="Lethargy Fuseau +3",
        hands="Lethargy Gantherots +3",
        feet="Vitiation Boots +3",
        neck="Baetyl Pendant",
        ear1="Malignance Earring",
        ear2="Hecate's Earring",
        ring1="Jhakri Ring",
        ring2="Freke Ring",
        back="Izdubar Mantle",
        waist="Hachirin-no-Obi",
        range = empty
    }

    sets.midcast['Elemental Magic'].Resistant = set_combine(sets.midcast['Elemental Magic'], {
        main="Mpaca's Staff",
        neck="Incanter's Torque",
        head="Atrophy Chapeau +4",
        waist="Null Belt",
        back="Null Shawl",
        ammo="Regal Gem"
    })

    sets.midcast['Elemental Magic'].Fodder = set_combine(sets.midcast['Elemental Magic'], {})
    sets.midcast['Elemental Magic'].Proc = set_combine(sets.midcast['Elemental Magic'], {})
    sets.midcast['Elemental Magic'].HighTierNuke = set_combine(sets.midcast['Elemental Magic'], {})
    sets.midcast['Elemental Magic'].HighTierNuke.Resistant = set_combine(sets.midcast['Elemental Magic'].Resistant, {})
    sets.midcast['Elemental Magic'].HighTierNuke.Fodder = set_combine(sets.midcast['Elemental Magic'].Fodder, {})

    sets.midcast.Impact = set_combine(sets.midcast['Elemental Magic'], {
        head=empty,
        body="Twilight Cloak"
    })

    -- Magic Burst
    sets.MagicBurst = set_combine(sets.midcast['Elemental Magic'], {
        main="Bunzi's Rod",
        sub="Culminus",
        head="Atrophy Chapeau +4",
        body="Bunzi's Robe",
        hands="Bunzi's Gloves",
        legs="Lethargy Fuseau +3",
        feet="Bunzi's Sabots",
        neck="Mizukage-no-Kubikazari",
        ring1="Locus Ring",
        ring2="Freke Ring",
    })

    sets.ResistantMagicBurst = set_combine(sets.MagicBurst, {})

    sets.midcast['Divine Magic'] = set_combine(sets.midcast['Elemental Magic'], {
        feet="Medium's Sabots",
        body="Vanya Robe",
    })

    -- Elemental enfeebles
    sets.midcast.Dia = sets.midcast['Enfeebling Magic']
    sets.midcast.Diaga = sets.midcast['Enfeebling Magic']
    sets.midcast['Dia II'] = sets.midcast['Enfeebling Magic']
    sets.midcast['Dia III'] = sets.midcast['Enfeebling Magic']
    sets.midcast.Bio = sets.midcast['Enfeebling Magic']
    sets.midcast['Bio II'] = sets.midcast['Enfeebling Magic']

    sets.midcast['Bio III'] = set_combine(sets.midcast['Enfeebling Magic'], {
        head="Vitiation Chapeau +4"
    })

    -- Dark Magic
    sets.midcast['Dark Magic'] = {
        head="Jhakri Coronal +2",
        body="Jhakri Robe +2",
        legs="Jhakri Slops +2",
        hands="Malignance Gloves",
        feet="Jhakri Pigaches +2",
        neck="Erra Pendant",
        ear1="Malignance Earring",
        ear2="Alabaster Earring",
        ring1="Crepuscular Ring",
        ring2="Evanescence Ring",
        back="Izdubar Mantle",
        waist="Null Belt",
        ammo="Ghastly Tathlum",
        range = empty,
        main="Marin Staff +1",
        sub="Daduchos Grip"
    }

    sets.midcast.Drain = set_combine(sets.midcast['Dark Magic'], {
        neck="Erra Pendant"
    })

    sets.midcast.Aspir = set_combine(sets.midcast.Drain, {
        waist="Fucho-no-Obi",
        feet="Merlinic Crackows"
    })

    sets.midcast.Stun = set_combine(sets.midcast['Dark Magic'], {})
    sets.midcast.Stun.Resistant = set_combine(sets.midcast['Dark Magic'], {})

    -- Buff and situational sets
    sets.buff.Saboteur = {
        hands="Lethargy Gantherots +3"
    }

    sets.buff.Sublimation = {waist="Embla Sash"}
    sets.buff.DTSublimation = {waist="Embla Sash"}

    sets.HPDown = {}
    sets.HPCure = {}
    sets.buff.Doom = {}

    -- Resting
    sets.resting = {
        main="Chatoyant Staff",
        sub="Oneiros Grip",
    }

    -- Idle
    sets.idle = {
        main="Daybreak",
        sub="Archduke's Shield",
        ammo="Crepuscular Pebble",
        head="Vitiation Chapeau +4",
        body="Lethargy Sayon +3",
        legs="Carmine Cuisses +1",
        hands="Malignance Gloves",
        feet="Malignance Boots",
        neck="Elite Royal Collar",
        ear1="Odnowa Earring +1",
        ear2="Alabaster Earring",
        ring1="Ayanmo Ring",
        ring2="Murky Ring",
        back="Archon Cape",
        waist="Null Belt",
        range = empty
    }

    sets.idle.PDT = set_combine(sets.idle, {
        main="Emissary",
        sub="Sacro Bulwark"
    })

    sets.idle.MDT = set_combine(sets.idle, {})
    sets.idle.Weak = set_combine(sets.idle, {})

    sets.idle.DTHippo = set_combine(sets.idle.PDT, {
        back="Archon Cape",
        legs="Carmine Cuisses +1",
        -- feet="Hippo. Socks +1"
    })

    -- Defense sets
    -- Defense sets don't touch main/sub: weapons are locked via MainWeapon/OffWeapon.
    sets.defense.PDT = {
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

    sets.defense.NukeLock = sets.midcast['Elemental Magic']

    sets.defense.MDT = {
        ammo="Crepuscular Pebble",
        head="Bunzi's Hat",
        neck="Null Loop",
        ear1="Alabaster Earring",
        ear2="Odnowa Earring +1",
        body="Bunzi's Robe",
        hands="Bunzi's Gloves",
        ring1="Murky Ring",
        ring2="Archon Ring",
        back="Null Shawl",
        waist="Platinum Moogle Belt",
        legs="Bunzi's Pants",
        feet="Bunzi's Sabots",
    }

    sets.defense.MEVA = {
        ammo="Crepuscular Pebble",
        head="Bunzi's Hat",
        neck="Null Loop",
        ear1="Alabaster Earring",
        ear2="Odnowa Earring +1",
        body="Bunzi's Robe",
        hands="Bunzi's Gloves",
        ring1="Archon Ring",
        ring2="Shadow Ring",
        back="Null Shawl",
        waist="Null Belt",
        legs="Bunzi's Pants",
        feet="Bunzi's Sabots",
    }

    sets.Kiting = {
        legs="Carmine Cuisses +1",
        main="Daybreak",
        sub="Sacro Bulwark",
        ammo="Crepuscular Pebble",
        waist="Platinum Moogle Belt"
    }

    sets.latent_refresh = {waist="Fucho-no-Obi"}
    sets.latent_refresh_grip = {
        main="Mpaca's Staff",
        sub="Oneiros Grip"
    }

    sets.DayIdle = {}
    sets.NightIdle = {}

    -- Elemental bonus overlay sets
    sets.element = {
        Fire = {},
        Ice = {},
        Wind = {},
        Earth = {},
        Lightning = {},
        Water = {},
        Light = {},
        Dark = {},
    }

    sets.element.enspell = {
        Fire = {},
        Ice = {},
        Wind = {},
        Earth = {},
        Lightning = {},
        Water = {},
        Light = {},
        Dark = {},
    }

    -- Situational sets
    sets.Self_Healing = {ring1="Kunaji Ring"}
    sets.Cure_Received = {}

    -- Self_Refresh is defined above and retains both intended pieces.

    -- Engaged
    sets.engaged = {
        head="Nyame Helm", -- Path B
        neck="Anu Torque",
        ear1="Sherida Earring",
        ear2="Cessance Earring",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        ring1="Petrov Ring",
        ring2="Rajas Ring",
        back="Sucellos's Cape",
        waist="Sailfi Belt +1",
        legs="Malignance Tights",
        feet="Malignance Boots",
        ammo="Crepuscular Pebble",
        range = empty
    }

    sets.engaged.Acc = set_combine(sets.engaged, {
        ammo="Ginsen",
        waist="Null Belt",
        ring2="Mars's Ring"
    })

    sets.engaged.FullAcc = set_combine(sets.engaged.Acc, {
        back="Null Shawl",
        neck="Null Loop",
    })

    sets.engaged.DT = set_combine(sets.engaged, {})
    sets.engaged.Acc.DT = set_combine(sets.engaged.Acc, {})
    sets.engaged.FullAcc.DT = set_combine(sets.engaged.FullAcc, {})

    sets.engaged.DW = set_combine(sets.engaged, {})
    sets.engaged.DW.Acc = set_combine(sets.engaged.Acc, {})
    sets.engaged.DW.FullAcc = set_combine(sets.engaged.FullAcc, {})
    sets.engaged.DW.DT = set_combine(sets.engaged, {})
    sets.engaged.DW.Acc.DT = set_combine(sets.engaged.Acc, {})
    sets.engaged.DW.FullAcc.DT = set_combine(sets.engaged.FullAcc, {})

    -- No named per-weapon-mode aliases needed.
    -- The library auto-selects sets.engaged.DW when dual-wielding.
end
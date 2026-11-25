-- Ullona_Rdm_Gear.lua
-- Restored from working duration commit + newer Malignance pieces kept
-- Enhancing duration fixed to match the version that was giving correct Haste/Refresh times

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
    state.OffWeapon:options('None','Culminus','SacroBulwark','ArchdukeShield','DemersalDegen','Machaera','GletisKnife','Daybreak')

    set_macro_page(1, 3)

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
    sets.TreasureHunter = {
        head="Wh. Rarab Cap +1",
        waist="Chaac Belt",
        ammo="Per. Lucky Egg"
    }

      -
    -- PRECAST
      -

    sets.precast.JA['Chainspell'] = {body="Vitiation Tabard +4"}

    sets.precast.Waltz = {}
    sets.precast.Waltz['Healing Waltz'] = {}

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

      -
        -- WEAPONSKILLS

    sets.precast.WS = {
        head="Nyame Helm",
        body="Egbesu Frock",
        hands="Atrophy Gloves +4",
        legs="Nyame Flanchard",
        feet="Nyame Sollerets",
        neck="Fotia Gorget",
        waist="Fotia Belt",
        ear1="Crepuscular Earring",
        ear2="Ishvara Earring",
        ring1="Cornelia's Ring",
        ring2="Mars's Ring",
        back="Sucellos's Cape",
        ammo="Oshasha's Treatise",
        range=empty
    }

    sets.precast.WS.Proc = sets.precast.WS

    sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {
        ear1="Moonshade Earring"
    })
    sets.precast.WS['Black Halo']   = set_combine(sets.precast.WS, {
        ear1="Moonshade Earring"
    })
    sets.precast.WS['Circle Blade'] = set_combine(sets.precast.WS, {
        ear1="Moonshade Earring"
    })

    -- Exenterator is multi-hit / accuracy focused
    sets.precast.WS['Exenterator'] = {
        head="Malignance Chapeau",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        legs="Malignance Tights",
        feet="Malignance Boots",
        neck="Fotia Gorget",
        waist="Fotia Belt",
        ear1="Moonshade Earring",
        ear2="Sherida Earring",
        ring1="Petrov Ring",
        ring2="Rajas Ring",
        back="Sucellos's Cape",
        ammo="Oshasha's Treatise",
        range=empty
    }

    -- Magical WS
    sets.precast.WS['Burning Blade'] = {
        head="Atrophy Chapeau +4",
        body="Bunzi's Robe",
        hands="Lethargy Gantherots +3",
        legs="Lethargy Fuseau +3",
        feet="Vitiation Boots +3",
        neck="Baetyl Pendant",
        ear1="Hecate's Earring",
        ear2="Malignance Earring",
        ring1="Jhakri Ring",
        ring2="Freke Ring",
        back="Izdubar Mantle",
        waist="Hachirin-no-Obi",
        ammo="Ghastly Tathlum",
        range=empty
    }
    sets.precast.WS['Red Lotus Blade'] = set_combine(sets.precast.WS['Burning Blade'], {})

    sets.precast.WS['Red Lotus Blade'] = set_combine(sets.precast.WS['Burning Blade'], {})

      -
    -- MIDCAST: HEALING (Vanya = healer augs)
      -

    sets.RecoverMP = {}
    sets.midcast.FastRecast = sets.precast.FC

    sets.midcast['Healing Magic'] = {
        main="Bunzi's Rod",
        sub="Sacro Bulwark",
        head="Vanya Hood",
        body="Vanya Robe",
        hands="Bokwus Gloves",
        neck="Nodens Gorget",
        ear1="Gifted Earring",
        ear2="Mendicant's Earring",
        ring1="Naji's Loop",
        ring2="Janniston Ring",
        back="Pahtli Cape",
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

    sets.midcast.Cure = set_combine(sets.midcast['Healing Magic'], {
        head="Vanya Hood",
        body="Vanya Robe",
        feet="Vanya Clogs",
        back="Pahtli Cape"
    })

    sets.midcast.LightWeatherCure = {
        main="Chatoyant Staff",
        sub="Clemency Grip",
    }

    sets.midcast.LightDayCure = set_combine(sets.midcast['Healing Magic'], {
        main="Chatoyant Staff",
        sub="Clemency Grip",
    })

    sets.midcast.StatusRemoval = set_combine(sets.midcast.FastRecast, {
        head = "Vanya Hood",
        neck = "Incanter's Torque",
        back = "Tempered Cape +1"
        -- hands = "Gendewitha Gages +1"
    })

    sets.midcast.Cursna = set_combine(sets.midcast['Healing Magic'], {
        neck="Nodens Gorget",
        hands="Bokwus Gloves",
        back="Tempered Cape +1",
        waist="Cornelia's Belt",
        feet="Vanya Clogs"
    })

    sets.midcast.Curaga = set_combine(sets.midcast['Healing Magic'], {})

    sets.Self_Healing = set_combine(sets.midcast.Cure, {ring1="Kunaji Ring"})
    sets.Cure_Received = {}

      -
    -- ENHANCING MAGIC  ★ Restored from the working duration commit
      -

    sets.precast['Enhancing Magic'] = set_combine(sets.precast.FC, {
        main="Daybreak",
        sub="Ammurapi Shield",
        waist="Siegel Sash",
        head="Lethargy Chappel +3",
        body="Lethargy Sayon +3",
        hands="Atrophy Gloves +4",
        legs="Lethargy Fuseau +3",
        feet="Lethargy Houseaux +3",
        back="Sucellos's Cape",   
        ear2="Lethargy Earring",
        neck="Duelist's Torque +1",
    })

    -- This exact set was giving correct durations
    sets.midcast['Enhancing Magic'] = {
        main="Daybreak",
        sub="Ammurapi Shield",
        head="Lethargy Chappel +3",
        body="Lethargy Sayon +3",
        hands="Atrophy Gloves +4",
        legs="Lethargy Fuseau +3",
        feet="Lethargy Houseaux +3",
        neck="Duelist's Torque +1",
        ear1="Andoaa Earring",
        ear2="Lethargy Earring",
        ring1="Lebeche Ring",
        ring2="Murky Ring",
        back="Sucellos's Cape",             -- duration
        waist="Embla Sash"
    }

    -- Refresh specifically (from working commit)
    sets.midcast.Refresh = set_combine(sets.midcast['Enhancing Magic'], {
        legs="Lethargy Fuseau +3",
        body="Vitiation Tabard +4"
    })
    sets.midcast['Refresh III'] = sets.midcast.Refresh

    sets.midcast.Haste = set_combine(sets.midcast['Enhancing Magic'], {})
    sets.midcast['Haste II'] = sets.midcast.Haste

    -- Composure on others
    sets.buff.ComposureOther = set_combine(sets.midcast['Enhancing Magic'], {
        head="Lethargy Chappel +3",
        body="Lethargy Sayon +3",
        hands="Lethargy Gantherots +3",
        legs="Lethargy Fuseau +3",
        feet="Lethargy Houseaux +3"
    })

    -- Skill set (Ghostfyre is correct here)
    sets.EnhancingSkill = set_combine(sets.midcast['Enhancing Magic'], {
        back="Ghostfyre Cape",
        hands="Vitiation Gloves +3"
    })
   sets.precast.Protect = set_combine(sets.precast['Enhancing Magic'], {ring1="Sheltered Ring"})
    sets.precast.Shell = sets.precast.Protect
    sets.midcast.Protect = set_combine(sets.midcast['Enhancing Magic'], {ring1="Sheltered Ring"})
    sets.midcast.Shell = sets.midcast.Protect

    sets.midcast.BoostStat = set_combine(sets.EnhancingSkill, {
        hands="Vitiation Gloves +3"
    })

    sets.Self_Refresh = set_combine(sets.midcast['Enhancing Magic'], {
        feet="Inspirited Boots"          -- self-refresh potency
    })

    sets.midcast.Regen = set_combine(sets.midcast['Enhancing Magic'], {
        main="Bolelabunga",
        sub="Ammurapi Shield",
        feet="Bunzi's Sabots"
    })

    sets.midcast.BarElement = set_combine(sets.EnhancingSkill, {
        hands="Vitiation Gloves +3"
    })

    sets.midcast.Temper = set_combine(sets.EnhancingSkill, {})
    sets.midcast.Temper.DW = set_combine(sets.midcast.Temper, {})

    sets.midcast.Enspell = set_combine(sets.EnhancingSkill, {
        legs="Vitiation Tights +4",
        head="Umuthi Hat",
        main="Archduke's Sword"
    })
    sets.midcast.Enspell.DW = set_combine(sets.midcast.Enspell, {})

    sets.midcast.Stoneskin = set_combine(sets.EnhancingSkill, {
        waist="Siegel Sash",
        legs="Shedir Seraweels",
        head="Umuthi Hat",
        neck="Nodens Gorget"
    })

    -- All three spike spells share this set
    sets.midcast.Spikes = set_combine(sets.midcast['Enhancing Magic'], {legs="Vitiation Tights +4"})

    sets.midcast.Gain = set_combine(sets.EnhancingSkill, {
        hands="Vitiation Gloves +3"
    })

    sets.midcast.Phalanx = set_combine(sets.EnhancingSkill, {
        back="Ghostfyre Cape"
    })
    sets.midcast.Phalanx.Self = set_combine(sets.midcast.Phalanx, {})

      -
    -- ENFEEBLING MAGIC
      -

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
        back="Ghostfyre Cape",
        waist="Obstinate Sash",
        ammo="Regal Gem",
        range=empty
    }

    sets.midcast['Enfeebling Magic'].Resistant = set_combine(sets.midcast['Enfeebling Magic'], {
        back="Null Shawl",
        ear1="Snotra Earring",
        ring1="Vertigo Ring",
        neck="Null Loop",
        legs="Chironic Hose"
    })

    -- Duration-focused enfeebles (Silence etc. if you ever want them)
    sets.midcast.DurationOnlyEnfeebling = set_combine(sets.midcast['Enfeebling Magic'], {
        main="Chatoyant Staff",
        body="Atrophy Tabard +4",
        ear1="Snotra Earring",
        waist="Obstinate Sash"
    })

    -- Sleep / Bind / Break / Gravity → full Resistant + Chironic
    sets.midcast.Sleep  = sets.midcast['Enfeebling Magic'].Resistant
    sets.midcast.Bind   = sets.midcast['Enfeebling Magic'].Resistant
    sets.midcast.Break  = sets.midcast['Enfeebling Magic'].Resistant
    sets.midcast.Gravity = sets.midcast['Enfeebling Magic'].Resistant
    sets.midcast['Gravity II'] = sets.midcast.Gravity

    -- Dispel
    sets.midcast.Dispel = sets.midcast['Enfeebling Magic'].Resistant
    sets.midcast.Dispelga = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {
        main="Daybreak",
        sub="Culminus"
    })

    -- Distract / Frazzle use default enfeebling (no special rules)
    -- (they will fall through to sets.midcast['Enfeebling Magic'])

      -
    -- ELEMENTAL / MB / DARK
      -

    sets.midcast['Elemental Magic'] = {
        main="Marin Staff +1",
        sub="Daduchos Grip",
        ammo="Ghastly Tathlum",
        head="Atrophy Chapeau +4",
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
        range=empty
    }

    sets.midcast['Elemental Magic'].Resistant = set_combine(sets.midcast['Elemental Magic'], {
        main="Mpaca's Staff",
        neck="Incanter's Torque",
        head="Atrophy Chapeau +4",
        waist="Null Belt",
        back="Null Shawl",
        ammo="Regal Gem"
    })

    sets.midcast.Impact = set_combine(sets.midcast['Elemental Magic'], {
        head=empty,
        body="Twilight Cloak"
    })

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
        ring2="Freke Ring"
    })

    sets.ResistantMagicBurst = set_combine(sets.MagicBurst, {
        back="Null Shawl",
        waist="Null Belt",
        ammo="Regal Gem"
    })

    sets.midcast['Divine Magic'] = set_combine(sets.midcast['Elemental Magic'], {
        feet="Medium's Sabots",
        body="Vanya Robe"
    })

    -- Dia / Bio never get resisted → pure Treasure Hunter
    sets.midcast.Dia = sets.TreasureHunter
    sets.midcast.Diaga = sets.TreasureHunter
    sets.midcast['Dia II'] = sets.TreasureHunter
    sets.midcast['Dia III'] = sets.TreasureHunter
    sets.midcast.Bio = sets.TreasureHunter
    sets.midcast['Bio II'] = sets.TreasureHunter
    sets.midcast['Bio III'] = sets.TreasureHunter

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
        range=empty,
        main="Marin Staff +1",
        sub="Daduchos Grip"
    }

    sets.midcast.Drain = set_combine(sets.midcast['Dark Magic'], {neck="Erra Pendant"})
    sets.midcast.Aspir = set_combine(sets.midcast.Drain, {
        waist="Fucho-no-Obi",
        feet="Merlinic Crackows"
    })
    sets.midcast.Stun = set_combine(sets.midcast['Dark Magic'], {
        back="Null Shawl",
        neck="Null Loop",
        ring1="Vertigo Ring"
    })

      -
    -- BUFFS / IDLE / DEFENSE / ENGAGED
      -

    sets.buff.Saboteur = {hands="Lethargy Gantherots +3"}
    sets.buff.Sublimation = {waist="Embla Sash"}
    sets.buff.DTSublimation = {waist="Embla Sash"}
    sets.HPDown = {}
    sets.HPCure = {}
    sets.buff.Doom = {}

    sets.resting = {
        main="Chatoyant Staff",
        sub="Oneiros Grip"
    }

    sets.idle = {
        main="Daybreak",
        sub="Archduke's Shield",
        ammo="Crepuscular Pebble",
        head="Malignance Chapeau",          -- newer piece kept
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
        range=empty
    }

    sets.idle.PDT = set_combine(sets.idle, {
        main="Emissary",
        sub="Sacro Bulwark"
    })

    sets.idle.MDT = set_combine(sets.idle, {
        head="Malignance Chapeau",
        body="Bunzi's Robe",
        hands="Bunzi's Gloves",
        legs="Bunzi's Pants",
        feet="Bunzi's Sabots",
        back="Null Shawl"
    })

    sets.idle.Weak = set_combine(sets.idle, {})
    sets.idle.DTHippo = set_combine(sets.idle.PDT, {
        back="Archon Cape",
        legs="Carmine Cuisses +1"
    })

    sets.defense.PDT = {
        ammo="Crepuscular Pebble",
        head="Malignance Chapeau",
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
        feet="Bunzi's Sabots"
    }

    sets.defense.NukeLock = sets.midcast['Elemental Magic']

    sets.defense.MDT = {
        ammo="Crepuscular Pebble",
        head="Malignance Chapeau",
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
        feet="Bunzi's Sabots"
    }

    sets.defense.MEVA = {
        ammo="Crepuscular Pebble",
        head="Malignance Chapeau",
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
        feet="Bunzi's Sabots"
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

    sets.element = {
        Fire={}, Ice={}, Wind={}, Earth={},
        Lightning={}, Water={}, Light={}, Dark={}
    }
    sets.element.enspell = {
        Fire={}, Ice={}, Wind={}, Earth={},
        Lightning={}, Water={}, Light={}, Dark={}
    }

    sets.Self_Healing = set_combine(sets.midcast.Cure, {ring1="Kunaji Ring"})
    sets.Cure_Received = {}

    -- Engaged (Malignance kept)
    sets.engaged = {
        head="Malignance Chapeau",
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
        range=empty
    }

    sets.engaged.Acc = set_combine(sets.engaged, {
        ammo="Ginsen",
        waist="Null Belt",
        ring2="Mars's Ring"
    })
    sets.engaged.FullAcc = set_combine(sets.engaged.Acc, {
        back="Null Shawl",
        neck="Null Loop"
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

    sets.engaged.Enspell = set_combine(sets.engaged, {
        head="Malignance Chapeau",
        body="Malignance Tabard",
        hands="Malignance Gloves",
        legs="Malignance Tights",
        feet="Malignance Boots",
        ear1="Sherida Earring",
        ear2="Cessance Earring",
        ring1="Petrov Ring",
        ring2="Rajas Ring"
    })
    sets.engaged.Enspell.DW = set_combine(sets.engaged.Enspell, {})
end

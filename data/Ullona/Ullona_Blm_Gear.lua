-- Blm_Gear.lua

function user_job_setup()
    -- Options: Override default values
    state.CastingMode:options('Normal','Resistant','OccultAcumen','MB','MB Resistant')
    state.OffenseMode:options('Normal')
    state.IdleMode:options('Normal','PDT','DTHippo')
    state.Weapons:options('None','BurstWeapons','Khatvanga','Lathi')

    -- Plain name on purpose: only one Taranus's Cape, so no augment matching needed.
    gear.nuke_jse_back = "Taranus's Cape"

    -- Death sets reference this (normally defined in BLM.lua; Grioavolr isn't in the inventory).
    gear.grioavolr_nuke_staff = "Marin Staff +1"

    -- Macro Book
    set_macro_page(1, 2) -- Page 1, Macro Book 2

    -- Additional local binds — every keybind noted below for quick reference.
    -- Modifier key: ^ = Ctrl, ! = Alt, @ = Win, ~ = Shift
    send_command('bind ^q gs c weapons Khatvanga;gs c set CastingMode OccultAcumen')  -- Ctrl + Q : Equip Khatvanga + set OccultAcumen casting mode
    send_command('bind !q gs c weapons Default;gs c reset CastingMode;gs c reset DeathMode')  -- Alt + Q : Reset weapons + CastingMode/DeathMode
    send_command('bind !r gs c set DeathMode Single;gs c set CastingMode MB')  -- Alt + R : One-shot Death + MB casting mode
    send_command('bind !\\\\ input /ja "Manawell" <me>')          -- Alt + \ : Manawell
    send_command('bind @f9 gs c cycle DeathMode')                 -- Win + F9 : Cycle DeathMode
    send_command('bind @^` input /ja "Parsimony" <me>')           -- Win + Ctrl + ` : Parsimony
    send_command('bind !pause gs c toggle AutoSubMode')           -- Alt + Pause : Toggle AutoSubMode
    send_command('bind ^backspace input /ma "Stun" <t>')          -- Ctrl + Backspace : Stun
    send_command('bind !backspace input /ja "Enmity Douse" <t>')  -- Alt + Backspace : Enmity Douse
    send_command('bind @backspace input /ja "Alacrity" <me>')     -- Win + Backspace : Alacrity
    send_command('bind != input /ja "Light Arts" <me>')           -- Alt + = : Light Arts
    send_command('bind @= input /ja "Addendum: White" <me>')      -- Win + = : Addendum: White
    send_command('bind ^delete input /ja "Dark Arts" <me>')       -- Ctrl + Delete : Dark Arts
    send_command('bind !delete input /ja "Addendum: Black" <me>') -- Alt + Delete : Addendum: Black
    send_command('bind @delete input /ja "Manifestation" <me>')   -- Win + Delete : Manifestation
    send_command('bind @f10 gs c smartna')                        -- Win + F10 : SmartNa
    send_command('bind @f8 gs c toggle AutoNukeMode')             -- Win + F8 : Toggle AutoNukeMode
end

-- Applies the lockstyle after the equipment model has loaded.
-- Clear every bind this file sets so they don't linger after a job change/reload.
function user_job_unload()
    send_command('unbind ^q')
    send_command('unbind !q')
    send_command('unbind !r')
    send_command('unbind !\\\\')
    send_command('unbind @f9')
    send_command('unbind @^`')
    send_command('unbind !pause')
    send_command('unbind ^backspace')
    send_command('unbind !backspace')
    send_command('unbind @backspace')
    send_command('unbind !=')
    send_command('unbind @=')
    send_command('unbind ^delete')
    send_command('unbind !delete')
    send_command('unbind @delete')
    send_command('unbind @f10')
    send_command('unbind @f8')
end

function user_job_lockstyle()
    send_command('input /lockstyleset 2')
end

function init_gear_sets()
    sets.weapons                 = sets.weapons or {}
    sets.weapons.Default         = sets.weapons.Default or {main="Marin Staff +1"}
    sets.weapons.BurstWeapons    = sets.weapons.Default

    -- Buff overlay sets
    sets.buff                    = sets.buff or {}
    sets.buff.Sublimation        = {waist="Embla Sash"}
    sets.buff.DTSublimation      = {waist="Embla Sash"}

    -- Precast: Job Abilities
    sets.TreasureHunter = {
        ammo="Perfect Lucky Egg",
        waist="Chaac Belt"
    }

    -- Mana Wall: equip back+feet for footwear lock benefit
    sets.precast.JA['Mana Wall'] = {
        back="Taranus's Cape",
        feet="Wicce Sabots +2"
    }

    -- Manafont: body gives the most benefit
    sets.precast.JA.Manafont = {body="Archmage's Coat +3"}

    -- Convert: empty — equip nothing special; keep whatever is on
    sets.precast.JA.Convert = {}

    -- Precast: Fast Cast
    sets.precast.FC = {
        main  = "Mpaca's Staff",
        sub   = "Daduchos Grip",
        head  = "Nahtirah Hat",
        body  = "Agwu's Robe",
        hands = "Agwu's Gages",
        legs  = "Agwu's Slops",
        feet  = "Regal Pumps",
        neck  = "Voltsurge Torque",
        ear1  = "Loquacious Earring",
        ear2  = "Malignance Earring",
        ring1 = "Naji's Loop",
        ring2 = "Kishar Ring",
        waist = "Embla Sash",
    }

    sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {
        ear1  = "Magnetic Earring",
        waist = "Embla Sash",
        main  = "Daybreak",
        sub   = "Ammurapi Shield",
    })

    -- Stoneskin: Siegel Sash + Shedir legs improve potency
    sets.precast.FC.Stoneskin = set_combine(sets.precast.FC['Enhancing Magic'], {
        waist = "Siegel Sash",
        legs  = "Querkening Brais",
        head  = "Umuthi Hat"
    })

    sets.precast.FC['Elemental Magic'] = set_combine(sets.precast.FC, {
        head  = "Wicce Petasos +2",
        neck  = "Baetyl Pendant",
        body  = "Wicce Coat +3",
        feet  = "Spaekona's Sabots +3",
        ring1 = "Mallquis Ring",
    })

    -- Cure precast: healing-focused FC set
    sets.precast.FC.Cure = set_combine(sets.precast.FC, {
        main  = "Vadose Rod",
        sub   = none,
        ammo  = "Psilomene",
        head  = "Vanya Hood",
        body  = "Vrikodara Jupon",
        hands = "Bokwus Gloves",
        legs  = "Gyve Trousers",
        feet  = "Vanya Clogs",
        neck  = "Voltsurge Torque",
        ear1  = "Magnetic Earring",
        ear2  = "Mendicant's Earring",
        ring1 = "Lebeche Ring",
        ring2 = "Janniston Ring",
        back  = "Pahtli Cape",
        waist = "Acerbic Sash +1",
    })

    sets.precast.FC.Curaga = sets.precast.FC.Cure

    sets.precast.FC.Impact = set_combine(sets.precast.FC, {
        head=empty,
        body="Twilight Cloak"
    })

    sets.precast.FC.Death = set_combine(sets.precast.FC, {
        main=gear.grioavolr_nuke_staff
    })

    sets.precast.WS = {
        neck  = "Fotia Gorget",
        ear1  = "Cessance Earring",
        ear2  = "Odnowa Earring +1",
        ring1 = "Cornelia's Ring",
        ring2 = "Mars's Ring",
        waist = "Fotia Belt",
        legs  = "Perdition slops"
    }

    sets.midcast.FastRecast = sets.precast.FC

    sets.midcast.Cure = {
        main  = "Bunzi's Rod",
        sub   = "Sors Shield",
        head  = "Vanya Hood",
        body  = "Vrikodara Jupon",
        hands = "Bokwus Gloves",
        feet  = "Vanya Clogs",
        neck  = "Nodens Gorget",
        ear1  = "Gifted Earring",
        ear2  = "Mendicant's Earring",
        ring1 = "Lebeche Ring",
        ring2 = "Janniston Ring",
        legs  = "Gyve Trousers",
    }

    sets.midcast.LightWeatherCure = set_combine(sets.midcast.Cure, {
        main="Chatoyant Staff",
        sub="Kaja Grip",
    })

    sets.midcast.LightDayCure = sets.midcast.LightWeatherCure
    sets.midcast.Curaga = sets.midcast.Cure
    sets.midcast.Cursna = set_combine(sets.midcast.Cure, {})
    sets.midcast.StatusRemoval = sets.midcast.FastRecast

    sets.precast.Aquaveil = set_combine(sets.precast.FC['Enhancing Magic'], {
        main="Vadose Rod",
        sub="Culminus",
    })

    -- Midcast: Enhancing / Stoneskin / Bar-spells
    sets.midcast['Enhancing Magic'] = {
        main  = "Daybreak",
        sub   = "Ammurapi Shield",
        head  = "Mallquis Chapeau +2",
        body  = "Mallquis Saio +2",
        hands = "Bokwus Gloves",
        legs  = "Shedir Seraweels",
        feet  = "Medium's Sabots",
        ear1  = "Magnetic Earring",
        ear2  = "Andoaa Earring",
        ring2 = "Vertigo Ring",
        waist = "Siegel Sash",
    }

    sets.midcast.Regen = set_combine(sets.midcast['Enhancing Magic'], {
        main="Bolelabunga",
    })

    sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {
        waist = "Siegel Sash",
        legs  = "Shedir Seraweels",
        feet  = "Medium's Sabots",
        head  = "Umuthi Hat"
    })

    sets.midcast.BarElement = set_combine(sets.precast.FC['Enhancing Magic'], {
        legs="Shedir Seraweels",
    })

    -- Midcast: Enfeebling Magic
    sets.midcast['Enfeebling Magic'] = {
        sub    = "Daduchos Grip",
        head   = "Mallquis Chapeau +2",
        body   = "Vanya Robe",
        hands  = "Wicce Gloves +2",
        legs   = "Wicce Chausses +2",
        feet   = "Skaoi Boots",
        neck   = "Sorcerer's Stole +1",
        ring1  = "Mallquis Ring",
        ring2  = "Kishar Ring",
        ear1   = "Crepuscular Earring",
        ear2   = "Malignance Earring",
        back   = "Taranus's Cape",
        waist  = "Null Belt",
    }

    sets.midcast['Enfeebling Magic'].Resistant = set_combine(sets.midcast['Enfeebling Magic'], {
        main  = "Mpaca's Staff",
        body  = "Spaekona's Coat +3",
        waist = "Null Belt"
    })

    sets.midcast.ElementalEnfeeble = set_combine(sets.midcast['Enfeebling Magic'], {
        back = "Taranus's Cape",
        body = "Spaekona's Coat +3",
        legs = "Archmage's Tonban +3",
        feet = "Archmage's Sabots +3"
    })

    sets.midcast.ElementalEnfeeble.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {})
    sets.midcast.IntEnfeebles = set_combine(sets.midcast.ElementalEnfeeble, {})
    sets.midcast.IntEnfeebles.Resistant = set_combine(sets.midcast.ElementalEnfeeble.Resistant, {})
    sets.midcast.MndEnfeebles = set_combine(sets.midcast.ElementalEnfeeble, {})
    sets.midcast.MndEnfeebles.Resistant = set_combine(sets.midcast.ElementalEnfeeble.Resistant, {})

    -- Midcast: Dark Magic
    sets.midcast['Dark Magic'] = {
        sub    = "Daduchos Grip",
        head   = "Mallquis Chapeau +2",
        body   = "Wicce Coat +3",
        hands  = "Archmage's Gloves +3",
        legs   = "Spaekona's Tonban +3",
        feet   = "Wicce Sabots +2",
        neck   = "Erra Pendant",
        ear1   = "Wicce Earring +1",
        ear2   = "Malignance Earring",
        ring1  = "Mallquis Ring",
        ring2  = "Evanescence Ring",
        back   = "Taranus's Cape",
    }

    sets.midcast.Drain = set_combine(sets.midcast['Dark Magic'], {
        neck="Erra Pendant",
        waist="Fucho-no-obi",
        feet="Agwu's Pigaches"
    })

    sets.midcast.Aspir = set_combine(sets.midcast.Drain, {
    })

    sets.midcast.Aspir.Death = sets.midcast['Dark Magic']

    sets.midcast.Impact = set_combine(sets.precast.FC.Impact or {}, {})

    -- Midcast: Elemental Magic
    sets.midcast['Elemental Magic'] = {
        main  = "Marin Staff +1",
        sub   = "Daduchos Grip",
        ammo  = "Ghastly Tathlum",
        head  = "Wicce Petasos +2",
        body  = "Wicce Coat +3",
        hands = "Wicce Gloves +2",
        legs  = "Wicce Chausses +2",
        feet  = "Wicce Sabots +2",
        neck  = "Baetyl Pendant",
        ear1  = "Malignance Earring",
        ear2  = "Wicce Earring +1",
        ring1 = "Jhakri Ring",
        ring2 = "Freke Ring",
        back  = "Taranus's Cape",
        waist = "Hachirin-no-Obi",
    }

    sets.midcast['Elemental Magic'].Resistant = set_combine(sets.midcast['Elemental Magic'], {
        main  = "Marin Staff +1",
        sub   = "Daduchos Grip",
        neck  = "Incanter's Torque",
        feet  = "Medium's Sabots",
        hands = "Spaekona's Gloves +2"
    })

    sets.midcast['Elemental Magic'].HighTierNuke = set_combine(sets.midcast['Elemental Magic'], {})
    sets.midcast['Elemental Magic'].HighTierNuke.Resistant = set_combine(sets.midcast['Elemental Magic'].Resistant, {})

    sets.midcast['Elemental Magic'].Proc = set_combine(sets.midcast['Elemental Magic'], {
        main   = "Marin Staff +1",
    })

    sets.midcast['Elemental Magic'].OccultAcumen = set_combine(sets.midcast['Elemental Magic'], {})

    sets.midcast.Impact.OccultAcumen = set_combine(
        sets.midcast['Elemental Magic'].OccultAcumen or {},
        {
            head=empty,
            body="Twilight Cloak",
        }
    )

    sets.RecoverMP = {
        body="Spaekona's Coat +3",
    }

    sets.MagicBurst = set_combine(sets.midcast['Elemental Magic'], {
        head  = "Archmage's Petasos +3",
        neck  = "Mizukage-no-Kubikazari",
        body  = "Agwu's Robe",
        hands = "Archmage's Gloves +3",
        legs  = "Archmage's Tonban +3",
        ring1 = "Locus Ring",
        ring2 = "Freke Ring",
        feet  = "Spaekona's Sabots +3",
        back  = "Taranus's Cape"
    })

    sets.ResistantMagicBurst = set_combine(sets.MagicBurst, {})

    -- Idle
    sets.idle = {
        main  = "Mpaca's Staff",
        sub   = "Kaja Grip",
        ammo  = "Crepuscular Pebble",
        head  = "Wicce Petasos +2",
        body  = "Jhakri Robe +2",
        hands = "SV Gauntlets +1",
        legs  = "Assiduity Pants +1",
        feet  = "Herald's Gaiters",
        neck  = "Null Loop",
        ear1  = "Alabaster Earring",
        ear2  = "Odnowa Earring +1",
        ring1 = "Archon Ring",
        ring2 = "Murky Ring",
        back  = "Archon Cape",
        waist = "Fucho-no-Obi"
    }

    sets.idle.PDT = set_combine(sets.idle, {})
    sets.idle.MDT = set_combine(sets.idle, {})
    sets.idle.DTHippo = set_combine(sets.idle, {})
    sets.idle.Weak = set_combine(sets.idle, {})
    sets.idle.Death = set_combine(sets.idle, {
        main=gear.grioavolr_nuke_staff
    })

    sets.resting = set_combine(sets.idle, {
        main = "Chatoyant Staff",
        body = "Jhakri Robe +2",
        legs = "Assiduity Pants +1",
    })

    sets.defense.PDT = {
        main="Malignance Pole",
        sub="Daduchos Grip",
        ammo="Crepuscular Pebble",
        head="Wicce Petasos +2",
        neck="Null Loop",
        ear1="Alabaster Earring",
        ear2="Genmei Earring",
        body="Mallquis Saio +2",
        hands="Wicce Gloves +2",
        ring1="Murky Ring",
        ring2="Vertigo Ring",
        back="Archon Cape",
        waist="Platinum Moogle Belt",
        legs="SV Loincloth +1",
        feet="Wicce Sabots +2",
    }

    sets.defense.MDT = {
        main="Malignance Pole",
        sub="Daduchos Grip",
        ammo="Crepuscular Pebble",
        head="Wicce Petasos +2",
        neck="Null Loop",
        ear1="Alabaster Earring",
        ear2="Odnowa Earring +1",
        body="Mallquis Saio +2",
        hands="Wicce Gloves +2",
        ring1="Murky Ring",
        ring2="Archon Ring",
        back="Null Shawl",
        waist="Platinum Moogle Belt",
        legs="SV Loincloth +1",
        feet="Wicce Sabots +2",
    }

    sets.defense.MEVA = {
        main="Daybreak",
        sub="Culminus",
        ammo="Crepuscular Pebble",
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

    sets.Kiting = {
        feet="Herald's Gaiters",
        main="Malignance Pole",
        sub="Kaja Grip",
        waist="Platinum Moogle Belt"
    }

    sets.latent_refresh = {waist="Fucho-no-obi"}
    sets.latent_refresh_grip = {sub="Oneiros Grip"}
    sets.TPEat = {}
    sets.DayIdle = {}
    sets.NightIdle = {}
    sets.HPDown = {}
    sets.HPCure = {}

    sets.Self_Healing = {ring1="Kunaji Ring"}
    sets.Cure_Received = {}
    sets.Self_Refresh = {}

    sets.buff.Doom = set_combine(sets.buff.Doom or {}, {})

    sets.buff['Mana Wall'] = {
        back=gear.nuke_jse_back,
        feet="Wicce Sabots +2"
    }

    sets.engaged = {
        main  = "Malignance Pole",
        sub   = "Daduchos Grip",
        head  = "Nyame Helm", -- Path B
        body  = "Nyame Mail", -- Path B
        hands = "Nyame Gauntlets", -- Path B
        legs  = "Nyame Flanchard", -- Path B
        feet  = "Nyame Sollerets", -- Path B
        neck  = "Peacock Amulet",
        ring2 = "Mars's Ring",
        back  = "Null Shawl",
        waist = "Null Belt",
    }

    sets.engaged.DT = sets.engaged
end